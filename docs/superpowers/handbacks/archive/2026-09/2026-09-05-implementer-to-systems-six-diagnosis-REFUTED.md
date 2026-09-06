---
from: implementer
to: systems
status: consumed
topic: ⑥ 的成因診斷被量測打掉；真根是 LOD 相位 ＋ 本床看不見（不是 PRODUCE early-return）
---

# ⑥：`TAG_PRODUCE` early-return 不是成因 —— 量測打掉了它

## 一、先講結論

**我照 GO 刪了 `salary_system.gd:30-32` 的 PRODUCE early-return，`_pay_salary` 的進入次數還是 `0`。**

而我的 entry tap 就在 `_pay_salary` 的【最上面】（取代了原本 early-return 的位置）
⇒ **0 的成因不在 `_pay_salary` 裡面，這個函式根本沒被呼叫。**

原診斷的證據是「連收尾兩個【無條件】print 都 0 次」——
★而那個證據【同時相容於】「早退了」與「根本沒進來」。**又是一個 0 底下住著兩種東西。**

## 二、三格分開記之後

```
★判別：`tick` 被呼叫 792 次 ｜ 其中 modulo 命中 4 次 ｜ 未命中 788 次
   ★★★同一刻【世界上實際有幾隊】：20隊=1｜22隊=2｜23隊=1
   ★★命中當下 `team_ids` 的大小分布：000隊=4
進入 `_pay_salary` 次數 = 0
```

- ①`tick` 沒被呼叫 → **否**（792 次）
- ②modulo 從不命中 → **否**（命中 4 次＝30 日窗的 4 個發薪日，一次不少）
- ③`team_ids` 是空的 → **是，4/4 全空**，★而同一刻世界上有 20–23 隊

## 三、為什麼是空的（兩層，兩層都不是薪資的錯）

**第一層 — 本床把所有隊都推進 far 批次。**
`three_tickets_bed.gd:72` 是 `runner.advance_tick(state, Vector2i(-1, -1))`
⇒ 沒有一隊在 `player_pos` 的 `LOD_NEAR_RADIUS=3` 內
⇒ `_get_near_teams` 恆回空、`_get_far_teams` 回全部。
（`lod_perf_bed.gd:6` 的註解早就寫過這句：「無玩家世界→全隊 far」。）

**第二層 — far pass 的相位與發薪日永不重合。**

| | 閘 | 值 |
|---|---|---|
| near pass | `tick % NEAR_CADENCE == 0` | 60 |
| far pass | `tick % FAR_ZONE_INTERVAL == 0` | 100 |
| 發薪 | `tick % SALARY_INTERVAL == 0` | 10080 |

```
payday k=1..4:  t=10080/20160/30240/40320
  near_pass? True True True True      （10080 % 60 == 0）
  far_pass?  False False False False  （10080k % 100 = 80k%100 ≠ 0，k 非 5 的倍數）
  k=5 (t=50400) 才第一次 True —— 而 30 日窗根本跑不到 payday 5
```

⇒ **薪資只由 near 批次遞送，而 near 批次在本床恆空 ⇒ 一個人都沒發過。**
⇒ ★★★這不是「居民隊被 early-return 擋掉」，是**整個薪資軸在任何 headless 床上都不可觀測**。

## 四、★這是一類，不是一顆（我掃過了）

**受害條件**＝`current_tick % INTERVAL` 這種【裸 modulo】閘，長在 `shape:"teams"` 且 `LOD_BOTH` 的 step 裡，
而 `INTERVAL` 不是 `FAR_ZONE_INTERVAL(100)` 的倍數。

`scripts/simulation/` 全掃 `current_tick % `，扣掉 whole-state 的（harvest/captive/population 走
`_step4c_harvest_tick(state)`／`_step_captives(state)`／`check_overflow`，都在 LOD 塊之外，安全），
剩下【真的長在 teams-shaped BOTH step 裡】的只有三處：

| 站點 | INTERVAL | %100 | 判定 |
|---|---|---|---|
| `salary_system.gd:31` | 10080 | 80 | ★**far 隊 4/5 的發薪日拿不到**（本床＝全部） |
| `faction_ai_system.gd:1170` | `TICKS_PER_MONTH`=43200 | 0 | 安全（兩個 pass 都命中） |
| `faction_ai_system.gd:1499` 定期徵收 | `effective_interval` 動態（`maxi(int(COLLECT_INTERVAL*(1.5-greed)*(1+honor*K)),10)`） | 隨機 | ★**同一類**：只在恰好是 100 倍數時 far 隊才徵得到 |

★★而**策略層是免疫的**：`INFRA_INTERVAL`/`C_*` 那一整排（`DecisionTier.T3_STRATEGIC`=4320，
4320%100=20，本來會中招）**走的是 `CadenceStagger.next_tick(cur, last_eval, id, cadence)`**
——它比的是 `last_eval_tick` 不是精確 modulo ⇒ 相位錯開不會漏。全 repo 23 個 stagger 呼叫點。

⇒ ★★★**`CadenceStagger` 就是這個問題的既有解**，而 salary 與 1499 是**還沒遷過去的兩顆**。

## 五、我做了什麼／沒做什麼

- ⑥ 的 code 改動（刪 PRODUCE early-return）**留著**——你 GO 過、R² CLEAN、零新機制。
  它是不是有效我現在**答不了**，因為在原床上這條路一次都沒跑到。
- **沒有**自己去改 LOD 相位／沒有動 `SALARY_INTERVAL`／沒有把 salary 遷去 `CadenceStagger`
  ——那是 seam 決策，你的格子。
- 加了 `FULL_HD=1` 環境開關到 `three_tickets_bed.gd`（`SimRunner.force_full_hd`，既有 knob、既有先例
  ——`need_oracle_verify_bed`/`coin_b_verify_bed` 等 9 支床都這樣用）：全隊 near、無 far 降頻
  ⇒ 10080%60==0 ⇒ 發薪日一定被涵蓋。**已標成 judged-world：RNG 路徑不同，fp 不可與預設床互比。**
  正在跑 30 日 peaceful 取 ⑥ 的逐發薪日數字（unrest/忠誠逐 day7/14/21/28 印，不聚合）。

## 六、要你裁的兩件

1. **⑥ 的驗收要不要收 judged-world 的數字？** 目前沒有第二條路能看見它。
   （若要預設床的數字，得先解掉相位——那就變成先做 seam 再回頭驗 ⑥。）
2. **相位這一類要不要開票？** 我的讀法是「把 salary 與 `faction_ai:1499` 遷到 `CadenceStagger`」，
   零新機制、跟策略層同形。但那是你的格子，我不自己動。

## 七、順帶：我自己踩的一個坑（記錄用）

第一版判別 tap 寫 `Probe.bump("salary.tick.mod.%d" % (bool))` ——
**GDScript 把 bool 格式成 `"true"/"false"` 不是 `0/1`** ⇒ key 變 `.true`/`.false`，讀者找 `.1`/`.0`
⇒ **兩格都印 0**。
★而【792 次呼叫，命中 0、未命中 0】這個和對不起來 —— **是那個不平把儀器的毛病露出來的**，
不是我特地去查。守恆式對帳這次是自己叫出來的。
