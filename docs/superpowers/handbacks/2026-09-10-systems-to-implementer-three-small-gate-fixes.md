---
from: systems
to: implementer
status: consumed
slice: 紅閘清理 · 三件小刀（★都在 `scripts/debug`，不動世界）
topic: ★★★①`headless` 那支紅**不是行為回歸，是【床的固定值凍結在舊時間尺度】**：`TRADE_TIMEOUT = TICK_PER_DAY×6 = 8640`，而床把 `current_tick` 設 **1500** ⇒ **超時本來就不該 fire** —— 世界是對的，床是錯的｜★★②`bed_arm_gate.gd` **印 `★FAIL` 卻 `exit 0`** ⇒ runner 判成 no-verdict ⇒ 一個【真紅】被降級成【不可判】｜★③`bare-tick` 剩最後 1 顆，我已判 (c)，只要把理由寫進 code 註記
---

# ① ★★★headless：床凍結在舊時間尺度（★這一格我追到底了）

```
`scripts/debug/headless_test.gd:11008` `_test_trade_timeout`：
    state.world.current_tick = 1500 ／ t.task_start_tick = 0
    assert(t.current_task != TeamData.TASK_TRADE, "超時應解除 TRADE，實際=%s")
★而 `faction_ai_system.gd:158` `const TRADE_TIMEOUT := TimeScale.TICK_PER_DAY * 6`
  ＝ 1440 × 6 ＝ **8640**（`world_state.gd:16 TICKS_PER_DAY = TICKS_PER_HOUR × 24 = 1440`）
⇒ ★★1500 − 0 ＝ 1500 **遠小於** 8640 ⇒ **超時【正確地】沒有 fire**。
⇒ ★★★**世界沒有壞，床壞了** —— 而它壞的方式是【它的固定值凍結在某個舊的時間尺度】。
```

**修法（★不要寫 8641）**：

```
`state.world.current_tick = FactionAISystem.TRADE_TIMEOUT + 1`（★**由常數導出**）
⇒ ★★理由與界限第 26 條同一條：**寫字面值＝把「有人有權改它」這件事忘掉**，
  而時間統一 wave **已經改過一次**（×5→1）—— 它會再改。
⇒ ★★★而修完要順手看一眼**同一支床裡還有沒有別的固定 tick 值**踩同一個坑
  （`current_tick = <字面數字>` 這個形狀，同族一起處理，不要只修被抓到的這一顆）。
```

# ② ★★bed-arm：印 FAIL 卻 exit 0

```
`scripts/debug/bed_arm_gate.gd` 目前輸出：
    [BED-ARM-GATE] ★FAIL：25 張床建了世界，既不用 helper 也不在白名單
  而 **rc = 0** ⇒ runner 只能判「跑完了但沒印出它該印的結論」＝ **no-verdict**
  ⇒ ★**一個真紅被降級成不可判**，而這兩者的處置完全相反（界限第 23 條）。
⇒ 修法：**FAIL ⇒ 非零 exit**（★沿用其他床的慣例，別自己發明新碼）。
⇒ ★★而那 25 張床**本票不修**：它是【床層債】，數字留著且刻意可見。
```

# ③ bare-tick 最後 1 顆：★我判 (c) 白名單，理由如下（照抄進 code 註記即可）

```
`scripts/simulation/decision/goal_resolver.gd:631`
    return float(WorldState.TICKS_PER_DAY) / float(maxi(MovementSystem.move_cost_pure(...), 1))
★這**正是** `MOVE_TILES_PER_DAY` 那張 spec 規定的【正確推導】：
  ★★**用【每格的 tick 成本】去除一天的 tick 數 ⇒ 得到 tiles/day** ——
  而 spec 的核心鐵則就是「用成本、不用速度」（直接拿速度代會差約 TICKS_PER_DAY 倍）。
⇒ ★★★所以它不是「裸 tick 常數」，它是**單位換算的分子** ⇒ 判 (c)。
⇒ 註記寫法建議：`# bare-tick-ok: 單位換算分子（TICKS_PER_DAY ÷ 每格成本 ＝ tiles/day，
   見 MOVE_TILES_PER_DAY spec 的單位鐵則）`，再把形狀加進 `bare_tick_triage.gd` 規則表。
```

# ④ 驗收

```
①`headless` 回綠（★而交件要說出【失敗清單】前後的差，不是只說「綠了」）
②`bed-arm` 從 no-verdict 變成**明確的紅**（★★它現在應該紅，因為那 25 張床還在）
  ⇒ ★★★**這一格的「成功」是【紅得清楚】，不是變綠** —— 別為了讓它綠而去動白名單
③`bare-tick` 回綠（母體仍 185，只是那一顆被判掉）
④三支都不動 `scripts/simulation` 的行為（①③是註記與床，②是 exit code）
```
