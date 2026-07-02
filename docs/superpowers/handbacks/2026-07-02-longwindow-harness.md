# Hand Back: 長窗複利驗收 harness

Plan：`docs/superpowers/plans/2026-07-02-longwindow-harness.md`
Branch：`feat/longwindow-harness`

## 實作摘要

- **`scripts/debug/longwindow_bed.gd`（新）** — 長窗複利驗收 harness（純 debug，SceneTree）。
  seeded warring 長跑（同 `WarringHarness` seed 播 → 逐 tick 確定），env `LW_SEED`(1337)/`LW_MONTHS`(6)/`LW_PHASE`。
  - **Task1** per-wolf 複利 timeline：開跑挑代表隊 3-5 隻（狼餬口×2=武力+野心 desc、絕境×1=food_days 最低、知足×1=SETTLE/TRADE），逐月記 effective_food / food_flow / raid 派出(task 上升沿抽樣) / pop / rung / faction_id / 存活；死了印死於何月。+ per-wolf **[GateWait]** 乾等訊號（FORCE+野心 想 raid 但本月 0 raid + 地圖有弱鄰，連續 N 月 → 標）。
  - **Task2** assimilate 生命週期分流表（讀 `asm.*` probe + harness 死亡分流）。
  - **Task3** tick 曲線（per-tick wall-time median/p99/max + spike%）+ 全鏈漏斗一張表。
- **`scripts/simulation/manpower_system.gd`（改，僅 probe 行，全 `Probe.enabled` guard）** — captive group 生命週期探針：
  - `_check_trajectory`：首次觀測 group → `asm.created` + `asm.created_morale_sum`（stamp `_lw_created_tick`，僅 Probe.enabled 時寫）；同化達標 → `asm.completed` + `asm.completed_dur_sum`。
  - `_revolt` → `asm.interrupted_scatter`；`_flee` → `asm.escaped`（fled）/ `asm.released`（釋放）。
  - **零行為變**：所有寫入（含 group stamp）在 `Probe.enabled` guard 內；off 時零路徑差（見驗收 pointwise）。
  - `asm.interrupted_death`（holder 持 captive 時滅團）**不在 production**（erase_teams 不路由 captive，需全域視角）→ 由 bed 每日快照 holder-captive set 差集偵測。`asm.moved`（轉手）**現無代碼路徑**（captive 不在 holder 間轉移）→ 未埋，恆 0。

### 與 spec 差異
- 「food_flow<0.5 獨立隊」：`food_flow_avg` 為 EMA，setup 當下=0（未跑）→ 選狼時此值 0，實際靠 FORCE archetype + 野心 desc 選（門檻在 t=0 恆過）。archetype 於 setup 亦未 derive → 選擇當下改用 `AmbitionLadder.derive_archetype(leader)` 現算（同源，非讀空 `team.ambition_archetype`）。
- interrupted_death 改 bed 偵測（理由如上），非 manpower_system 埋 probe。

## 驗收（1 月 smoke，seed 1337）

- **per-wolf 表**（格式樣本）：
  ```
  --- 狼餬口 Team32（野心=0.92 archetype=武力）---
     月 | eff_food | food_flow | raid | pop | rung | fid | 存活
      1 |    104.0 |     -7.20 |    1 |   9 |  0   |  -1 | 是
  --- 知足 Team29（野心=0.50 archetype=定居）---
      1 |    248.2 |     -3.23 |    0 |   8 |  0   |  -1 | 是
  ```
  → 武力狼月1 各派 1 raid、定居/商業 0 raid（機制對；1 月太短未見完整複利弧，長跑才顯）。
- **asm 分流表**：`created=4（morale 均=0.244） completed=0 interrupted=2（scatter=1/escaped=1/released=0/death=0）`。asm.* keys 出現 ✓。
- **漏斗表**：`conq.intent=60 → prosperity_reached=3 → combat_entered=16 → capture=4 → asm created=4/completed=0 → wolf growth=+0 → found=1`；CONQUER winner: loot=0 prosp=59 other=1。
- **tick 曲線**：`median=337us p99=345273us max=1024680us (3040x)  spike(>3×median)=735 (10.2%)` — die-off/encounter spike 如期浮現（known_issues 佐證數據）。
- **0 SCRIPT ERROR**。

## 回歸（全綠）

- headless：**1 FAIL（弱目標未加入攻擊 goal）= pre-existing**，無新增 FAIL。
- framework_validation：**PASS=7 DORMANT=0**（7/7）。
- coin_eq / pointwise：`seeded_warring_bed` 對 main baseline（seed 1337，1 月）逐點 **total_diffs=0** → Task2 probe 純觀測、零行為變確證。

## 連動風險

- **`ManpowerSystem`**：僅加 `Probe.enabled`-guard 觀測行 + captive group 多一 top-level key `_lw_created_tick`（僅 Probe.enabled 時）。`InvariantAudit._check_captive_cohort` 只驗 `cohorts` 子鍵、headless captive 測不斷言 group key set → 無破。pointwise total_diffs=0 已證。
- **無其他系統受影響**（bed 為獨立 debug 檔）。

## 待主 session 確認

- **長窗未跑**（plan 定：主 session 收 merge 後機器獨占跑，防爭用）。建議指令：
  ```powershell
  cd A:\GDS\demo   # 或 merge 後的主 checkout
  $env:LW_SEED=1337; $env:LW_MONTHS=6; $env:GODOT_TIMEOUT=3600
  .\tools\godot.ps1 --headless --script scripts/debug/longwindow_bed.gd
  # 相位歸因（spike 拆解）：另加 $env:LW_PHASE=1（tick 曲線 spike tick 印 [PhaseSpike]/[FaiPhase]）
  # 6-12 月：GODOT_TIMEOUT 拉到 3600+，背景跑；多 seed 換 LW_SEED 重跑
  ```
- **裁①c（長窗看複利弧再裁量級）**：需 6-12 月 per-wolf 表判 raid 頻率↑是否伴糧積累↑（複利），1 月 smoke 不足。
- **裁②（assimilate 慢 vs 結構性）**：smoke 顯 interrupted(2) > completed(0)（結構性傾向：captive 暴動/逃在同化前），但樣本小（created=4）；長窗放大再定。
- **新 probe key 清單**（供他 bed 復用）：`asm.created` / `asm.completed` / `asm.interrupted_scatter` / `asm.escaped` / `asm.released`（counts）；`asm.created_morale_sum` / `asm.completed_dur_sum`（amounts，除 count 得均值）。`asm.interrupted_death` = bed-local（非 Probe）。`asm.moved` 未埋（無路徑）。
- **建議後續**：captive interrupted 若長窗續碾 completed，考慮 morale cadence/init 檢討（現 `CAPTIVE_INIT_MORALE`≈0.244、`MORALE_KIND`+0.02/日 → 標稱 ~38 天同化，暴動閾 0.08 極易在初期觸）— 屬 assimilate 平衡，非本 harness scope。
