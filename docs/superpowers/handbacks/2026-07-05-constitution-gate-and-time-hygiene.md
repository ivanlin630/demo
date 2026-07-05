# Hand Back: 序0 憲法防閘 + 時間 hygiene（3 機械修）

branch: `feat/constitution-gate`（已 push origin，未 merge）

## 實作摘要

4 個獨立 Task，全部零 sim 行為變（現根 `TICKS_PER_DAY=240` 下所有導出值 == 原硬編值）。

- `scripts/simulation/sim_runner.gd`（Task 1）— near/far team scan hoist 進各自 cadence gate。原 152-153 每 tick 無條件 O(N) 全掃兩次，唯一消費點在 `% NEAR_CADENCE` / `% FAR_ZONE_INTERVAL` gate 內；搬進 gate = 命中才算，值與時機相同，消滅 gate-miss tick 的純浪費。
- `scripts/simulation/faction_ai_system.gd`（Task 2+3）—
  - Task 2：10 個裸 cadence/timeout const 改為 `TimeScale.TICK_PER_DAY * N`（跨類別 const 引用，非 `TimeScale.days()` static func——const 初始化不接受 func 呼叫）。順帶修 `FLEE_TIMEOUT` 硬編 `5 * 240`（原不跟根）→ `TimeScale.TICK_PER_DAY * 5`。`* 36 / 24`、`* 12 / 24` 整數除盡（8640/24=360、2880/24=120）。
  - Task 3：`eta_days` 除數 `240.0` → `float(WorldState.TICKS_PER_DAY)`（殺硬編漂移，改根自動跟隨）。
- `scripts/debug/time_const_check.gd`（新增，Task 2）— 10 const 導出值 == 預期整數的斷言腳本；`PASS (fails=0)`。
- `scripts/debug/constitution_gate.gd`（新增，Task 4）— 沙盒憲法 site-freeze 掃描閘。鎖 `TaskArbiter.transition/try_set` 呼叫面 = 引擎外 task 指派。指紋 = `<relpath>::<enclosing_func>`。契約：current ⊆ baseline，新增=FAIL、移除(arc 溶解)=PASS。
- `scripts/debug/constitution_baseline.txt`（新增，Task 4）— 凍結 32 個當前指紋 manifest，8 known 違憲以 `# 序N` 標 arc 溶入序（threat 序1 / solo 序2 / vendetta 序4 / prosperity 序5 / dispatch 序6×2 / reaction 序7）。

### 與 plan 的差異

- Plan Step 3（Task 4）列 threat 序1 應標 `_evaluate_threat` 與 `_dispatch_threat_response` 兩 func；實掃 `_evaluate_threat`（@358-392）**無** `TaskArbiter` 呼叫 → 非指紋，只標 `_dispatch_threat_response`。屬 plan 誠實聲明的「不經 TaskArbiter → 跳過標註」。
- Vendetta try_set @775-776 的 enclosing func = `_evaluate_all_body`（plan 只給行號附近，實查確認），已於 baseline 註記。
- 其餘完全照 plan。

## 連動風險

- **`TimeScale` 單向依賴**：Task 2 讓 `faction_ai_system.gd` const 引用 `TimeScale.TICK_PER_DAY`（單向下游，合法）。若日後 `TimeScale` 反向引用 faction_ai 會成循環——現無此風險。
- **A2 時間根切換（×5→1，MOVE 48→240）**：本 slice **不動** `TICKS_PER_DAY`（仍 240），只讓常數導出就位。A2 落地時這 10 const + eta 除數會自動跟隨新根——但 A2 另需 ④沿途補給 / FOOD 消耗重校 / gen 承載力重校四件一個 landing（裸切會餓死潮，見 `time_scale.gd:11-13` 註）。本 slice 已為 A2 鋪好導出面。
- **憲法閘 coverage 限制（誠實聲明）**：閘只鎖 `TaskArbiter` mutation 面，**不**覆蓋 return-task-字串式違憲（如 `ambition_ladder.rung_task`）。那類靠 arc 逐張溶解 + review，非本機械閘。**建議系統 merge 後把此限制入 `invariants.md`**。
- **憲法閘未進 CI/回歸鏈**：`constitution_gate.gd` 目前為獨立手跑腳本，未掛進任何常駐驗收 harness。arc 期間若要真防新增違憲，需系統決定掛點（framework_validation 或獨立 gate step）。

## 待主 session 確認

- **建議後續 task**：
  1. 憲法閘掛進常駐回歸鏈（否則防閘靠人記得跑 = 形同虛設）。
  2. coverage 限制入 `invariants.md`（return-task 式違憲不在機械閘內）。
  3. baseline 的 8 known `# 序N` 標註是 arc 溶解進度追蹤錨——arc 每溶一個違憲子系統，對應指紋消失、閘印 `removed`，可作進度信號。
- **無 spec 未覆蓋的設計決策**：4 Task 全機械/校正，plan 步驟完備，無需裁定。
