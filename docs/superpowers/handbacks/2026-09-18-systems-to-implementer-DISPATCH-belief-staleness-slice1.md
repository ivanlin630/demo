---
from: systems
to: implementer
status: consumed
slice: 位置 belief 過期線物理化 — **Slice 1（只加介面，不改讀者）**
topic: ★**派工（R² CLEAN）**，但**排在你隊列第三位**：凍結終線 →（已派）求居／佔村 → 本票｜★★核心是一個**不對稱**：`belief_pos()` 現在替【所有讀者】做同一個判斷，而攻擊要準、偵查本來就是要去看舊的｜★★★形狀鎖死：`tolerance_tiles` 是**必填、無預設值**的參數 —— **忘記定＝跑不動**，不是靜默通過
---

# 一、這一票在做什麼

`belief_system.gd:10` 的 `BELIEF_STALE_TICKS = 3 天`（自己標著 `TEST VALUE`）是**全域死常數**，
而 `belief_pos()` 超過它就回 `(-1,-1)` ⇒ **供給端替所有讀者做了同一個判斷**。

```
★規模（先報，而它當場打掉我的第一個判準）
   baseline_tiles_per_day() = 6 格/日｜最慢端 = 2 格/日
   ⇒ 現行 3 天線 ＝ 容許【18 格】漂移
   ★我原本要寫「可能已移出那一格 ⇒ 過期」＝ 4 小時 ⇒ 比現行【緊 18 倍】⇒ 世界會壞 ⇒ 作廢
```

# 二、Slice 1 的範圍（★只造尺，不量東西）

```
新增 BeliefSystem.position_estimate(state, observer_team_id, target_id,
                                    tolerance_tiles: float) -> Dictionary
  { pos, age_ticks, drift_tiles, blind }
    drift_tiles ＝ age_ticks × baseline_tiles_per_day() ÷ TICKS_PER_DAY
    ★錨定過的目標（ACT_SETTLED／ACT_BUILDING）用【最慢那一端】估（既有形狀，前票已立）
    blind ＝ (沒看過) or (drift_tiles > tolerance_tiles)
★★既有 `belief_pos()` 一行不動；★★★一個讀者都不遷
```
★**造尺的票不准同時改世界** —— 否則「尺對不對」與「世界變好沒」會混在同一個 fp 裡。

# 三、★★★`tolerance_tiles` 必填、無預設值（這是 R² 升級的一格）

```
舊模式：供給端全域硬切          ⇒ 讀者無從置喙（＝現在的病）
我原本寫的：讀者自己看 age/drift ⇒ ★「看不看」是讀者的良心 ⇒ 忘了就吃到 18 天前的位置而不會紅
現在：容忍度是【必填參數】       ⇒ ★★尺仍然是呼叫端給的，但【有沒有拿尺】變成「沒有就跑不動」
```
★R² 的原話我留在 spec 裡：「**紅的形式是【執行期缺參數】而不是【閘紅】**」——
**能在語言層紅的，就不要留給閘。**

# 四、★本票的第一個動作：先把【借用】拆掉

`BELIEF_STALE_TICKS` 現在**同時**是兩種語意：

```
(A) 位置 belief 過期線        belief_system.gd:135／140／451
(B) ★失敗記憶 TTL（乞食被拒） interaction_system.gd:1564／player_command_system.gd:1008／sim_runner.gd:385
    （`FailureMemory.record(..., ttl_ticks, ...)` 的實參）
```
`interaction_system.gd:1558` 的註解自己寫著「**借這件事自己的週期**」——
★**借的對象一旦變成函式，就沒有「一個數字」可借了**；不先拆，Slice 2 會**靜默改掉乞食被拒的記憶長度**。
⇒ **立 `AID_REFUSED_TTL_TICKS: int = WorldState.TICKS_PER_DAY * 3`（值不變＝行為不變），四個實參改指它。**

# 五、驗收（spec §5 有完整表，這裡挑三格提醒）

- **1-e｜fp ＋ 逐 tick 行為軌跡逐字相同** ← 本票只加介面，動了就是越界
- **1-c｜`position_estimate()` 的陽性對照**：把 `drift_tiles` 係數改 0 ⇒ 某格必須紅（否則沒人真的讀它＝尺沒接電）
- **1-h｜少傳 `tolerance_tiles` 的呼叫必須跑不動**（證明沒有人偷偷給了預設值）
- **1-f｜`anchoredness_freshness_bed.gd:195` 的內容錨同票更新，不是刪掉** ——
  ★那個錨現在會擋住這一票，**而那正是它在做它的工作**。

★**spec**：`docs/superpowers/specs/2026-09-18-belief-staleness-is-physical-HOW.md`（R² **CLEAN**，建議已吸收）。
★★**排序**：**先做完凍結終線**（含那顆指紋敏感度的陽性對照），再求居／佔村，最後這一票。**不要平行開三個 branch。**
