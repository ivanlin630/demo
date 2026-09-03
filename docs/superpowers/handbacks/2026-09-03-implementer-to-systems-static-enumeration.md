---
from: implementer
to: systems
status: open
slice: production 可變 static 逐個列舉（★跨 run 會不會被清）
touches: scripts/simulation/path_system.gd, scripts/simulation/decision/goal_resolver.gd, scripts/simulation/faction_ai_system.gd, scripts/simulation/npc_combat_system.gd, scripts/simulation/interaction_system.gd, scripts/simulation/decision/need_oracle.gd, scripts/data/world_state.gd, scripts/simulation/owner_outpost_index.gd, scripts/simulation/sim_runner.gd
topic: ★★★除了 `_fall_seen`,我再撈到一個【影響決策/世界】的:`_path_cache` 沒有清除點,而它的失效鍵是【tick 值】——★跨 run 時 tick 從 0 重來 ⇒ 第二輪 tick 0 會吃到第一輪 tick 0 的舊路徑;★★我掃到的是 32 個 static var(你列 15),多出來的多是旗標與唯讀表,我逐類標;★而唯讀四表我 grep 過寫入點＝0,不是「看起來像常數」
---

# ★①掃法（★先講，因為漏了要能補）
```
grep -rn "^static var" scripts/simulation scripts/data --include=*.gd  ⇒ ★32 個
★★你列 15 —— 差額多在【旗標(bool)】與【唯讀表】，我照你的話一併標，不省略
★★★而我這個掃法漏得掉的：`const` 裡藏可變容器／autoload 單例成員／`static func` 內的 `static` 區域變數
   （★GDScript 沒有後者，但前兩者我【沒有】查 ⇒ 明列為誠實限）
```

# ★★★②有清除點的（★附 file:line）
| static | 清除點 | 影響類 |
|---|---|---|
| `_fai_ph`（faction_ai:775） | `faction_ai_system.gd:804 _fai_ph.clear()` | (a) 只影響計時統計 |
| `_mf_seq`（interaction:38） | `interaction_system.gd:44 _mf_seq.clear()`（同 tick 換 tick 即清） | (a) |
| `_sssp_cache`（path:34） | `path_system.gd:37 clear_sssp()`（★production 無呼叫端）＋ **鍵＝`state.world.get_instance_id()`（path_system.gd:43）** | (c) 自帶失效鍵 |
| `driver_ledger`（world_state:159） | `world_state.gd:187 driver_ledger.clear()` | (a) |
| `_construction_visiting`（need_oracle:32） | `need_oracle.gd:62` 出口設 false（★入口 :44 設 true） | (c) 呼叫樹內自清 |

# ★★★③**沒有清除點**的（★這是重點）
| static | 影響類 | 證據 / 說明 |
|---|---|---|
| ★`_fall_seen`（goal_resolver:492） | **(a) 只影響 Probe** | 它唯一守的就是 `:534 Probe.bump("goal.res_fall_distinct.…")`；★★而**今天已實測**：同 process 第二輪整組不 bump（順序對調 ⇒ 差異換邊） |
| ★★★`_path_cache`（path_system:23） | **★★(b) 影響決策/世界** | `:104-110`：鍵＝`from/to` 座標，**新鮮度靠 entry 裡的 `tick == state.world.current_tick`**；★**跨 run 時 tick 從 0 重來** ⇒ **第二輪 tick 0 會命中第一輪 tick 0 的舊 result** ⇒ 路徑（可達性/ETA）是決策輸入 |
| `_a2b_remote_tribute_payers`（faction_ai:20） | (b) 但**自清** | `interaction_system.gd:627` 收到 settle 就 `erase`；★**沒 settle 的 payer 會殘留**，跨 run 可能讓第二輪的同 id 被誤判成「已 dispatch」 |
| `_combat_track` / `_cas_carry`（npc_combat:44/47） | (b) 但**自清** | `:326-327`／`:479` 戰鬥結束 `erase`；★**戰鬥沒走到結束就殘留**（同 id 跨 run 會接續舊 round/pop_start） |
| `_mk_verify_rows`（faction_ai:787） | (a) | 只在 `:3857` append，供 `_mk_verify` 開時的驗證輸出 |

## ★而 `_path_cache` 那條我要特別標
```
★它【看起來】自帶失效（entry 存 tick、比對 current_tick）——★★而那個鍵在單一 run 內成立、跨 run 不成立
⇒ ★★★這正是你要的 (c) 的反例：【自帶失效鍵】必須證明鍵真的會變，而 tick【會歸零重來】
⇒ 對照組：`_sssp_cache` 用 `get_instance_id()`，★那個鍵跨 run 會變（新 WorldData）⇒ 才算真 (c)
   ★★（誠實限：Godot 的 instance id 在物件釋放後【可能被重用】—— 機率低，但那不是「不可能」）
```

# ★④旗標類（bool/int：不是容器，但一樣會跨 run 殘留）
```
`trace_infra`(faction_ai:4938)／`shadow`(owner_outpost_index:25)／`force_full_hd`(sim_runner:126)
`phase_timing`(sim_runner:129)／`suppress_observe_noise`(path_system:7)／`driver_ledger_enabled`(world_state:160)
`_mk_verify`(faction_ai:786)／`_mk_path`(faction_ai:780)／`_mf_tick`(interaction:37)
`_observer_guard_warned`(sim_runner:78)／`_registry_assumptions_checked`(sim_runner:190)
`epoch`/`shadow_checks`/`shadow_fails`/`legacy_visits`(owner_outpost_index:21/26/27/29)
`driver_ledger_cap`/`driver_tick_hint`(world_state:161/162)
⇒ ★這些【由開它的人負責關】；★★而床若忘了關，下一支床就在【不同的儀器狀態】下跑
⇒ ★★★我今天就用過 `trace_infra = true` 而沒有關 —— 同一 process 內若再跑別的東西就會受影響
   （★我的床是一支一 process，所以沒出事；但那是【運氣】不是【設計】）
```

# ★⑤唯讀四表（★你說要根據，不是印象）
```
`GoalRegistry.REGISTRY`／`DecisionOptions.REGISTRY`／`SimRunner.SYSTEMS`／`FACILITY_DEFICIT_DEF`
⇒ grep 寫入形式（`X[...] =`／`.erase`／`.clear`／`.append`／`.merge`）在 scripts/simulation + scripts/data ⇒ ★命中 0
⇒ ★★所以「唯讀」有根據；★★★而誠實限：**若有人用區域變數持有再改**（`var r = REGISTRY; r[...] = ...`
   —— Dictionary 是參照型別），我這個 grep 抓不到
```

# ⑥我沒有做的
```
★不修（你的規矩）；★★不把 static 改成非 static（會動決定性）
★★★而若要修，我建議的最小刀是【給 `_path_cache` 一個與 `_sssp_cache` 同款的世界鍵】
   —— 而那是建議不是動手
```
