# 長窗複利驗收 harness — Plan（藍圖探針規格,`longwindow-rulings` 裁定）

> 目的：R1 三帶「複利弧」真驗收（raid→糧→盈餘→更頻 raid→擴張）= **時間序列**,end-state tally 不夠。
> 裁①c:長窗 6-12 月看複利弧再裁量級;裁②:assimilate 同窗分流（慢 vs 結構性）。
> 本 plan = **建 harness + 1 月 smoke**;真長跑主 session 收 merge 後單獨跑（機器獨占,防爭用——seed42 教訓）。

## 既有可沿用（全在 tree）

- `WarringHarness`/`seeded_warring_bed`（seeded 逐 tick 確定、月線 metrics、baseline JSON diff）。
- `SpecimenTracer`（單 specimen 決策/intent trace + 日 flush）。
- `SimRunner.phase_timing`+`[TickPerf]`/`[PhaseSpike]`/`[FaiPhase]`（tick 曲線）。
- 漏斗 probe keys（conq.\*/prosp.\*/capture.\*/p1.\*/g2.\*;conquest_measure key 清單）。
- `ManpowerSystem`（captive/assimilate 機制,P1）。

## Task 1 — per-wolf 複利 timeline（新 bed `scripts/debug/longwindow_bed.gd`）

1. seeded warring setup（env `LW_SEED`/`LW_MONTHS`,default 1337/6）。
2. 開跑時挑**代表隊 3-5 隻**（harness 內挑,零 production 侵入）:
   - 狼性餬口 ×2（FORCE archetype+野心高+food_flow<0.5 獨立隊）
   - 絕境 ×1（food_days 最低獨立隊）
   - 知足對照 ×1（SETTLE/TRADE archetype 獨立隊）
3. **逐月記每隻**:effective_food/食物 flow/raid 派出數（TASK_ATTACK/LOOT dispatch 計數,harness 每 tick 抽樣 task 轉換）/pop/ambition_rung/faction_id/存活。
4. 末尾印 **per-wolf 月曲線表**（複利證據=狼的 raid 頻率與糧積累同升;死了印死於何時何因可查）。
5. **狼卡可解 gate 乾等訊號（藍圖 ai-depth 觸發條件）**:每月記每狼 `prosp.gate_*`/建國 gate fail 計數 delta——若狼連續數月卡同一「可解 gate」（如 gate_noprey 但地圖有弱鄰/建國卡糧但不攢）→ 末尾標 `[GateWait]`。

## Task 2 — assimilate 生命週期探針（production,Probe guard）

1. `ManpowerSystem` captive group 生命週期事件 bump+note（`Probe.enabled` guard 零成本）:
   - `asm.created`（建立,note 起始 morale）/`asm.completed`（同化完成,note 耗時 tick）
   - `asm.interrupted_death`/`asm.interrupted_scatter`（隊死/散）/`asm.escaped`/`asm.moved`（轉手）
2. harness 末尾印 **lifecycle 分流表**:completed vs interrupted 比例+completed 平均耗時 vs 25 天標稱——**裁②一眼分**（慢=completed 多但久;結構性=interrupted 碾 completed）。
3. 不改 assimilate 行為半分（純觀測;現行 cadence/morale 常數全不動）。

## Task 3 — tick 曲線 + 全鏈漏斗表

1. tick 曲線:`LW_PHASE=1` 時開 `SimRunner.phase_timing`;逐月 median/p99/max（dieoff_perf_bed pattern 復用）——per-tick 不變量長跑首驗+殘餘 spike（far.total/orders_ambition）頻率記錄（known_issues 殘餘案佐證數據,順手）。
2. **全鏈漏斗一張表**（藍圖:別再一輪揭一個）:
   `intent → prosperity_reached → combat_entered → capture → assimilate(created/completed) → pop growth(狼隊) → found faction → CONQUER intent 分布`
   每階計數+轉化率,末尾一次印。

## Task 4 — smoke + 交付

1. 1 月 smoke（seed 1337）:per-wolf 表印出、asm.\* keys 出現（或印 0+說明本窗無 captive）、漏斗表完整、0 SCRIPT ERROR。
2. 回歸:headless（1 FAIL pre-existing 容忍）+framework 7/7+coin_eq delta=0（Task 2 probe 純觀測,pointwise 對 main baseline 應 CLEAN——`Probe.enabled` off 時零路徑差;bed 內 enabled 屬 harness 自身非回歸對象）。
3. **不跑 6-12 月**（主 session 收 merge 後機器獨占跑;GODOT_TIMEOUT 預算 6 月 ~3600+）。

## Handback

`docs/superpowers/handbacks/2026-07-02-longwindow-harness.md`:smoke 輸出樣本（per-wolf 表/漏斗表/asm 分流表格式）、新 probe key 清單、跑長窗的建議指令（env+timeout）。

## 注意

- Godot 用 `.\tools\godot.ps1`;smoke `GODOT_TIMEOUT=1200` 背景。
- 儀器全 `Probe.enabled`/`phase_timing` guard,預設零成本。
- headless 基準 1 FAIL（弱目標）=pre-existing。
- scope:新 `longwindow_bed.gd` + `manpower_system.gd`（僅 probe 行）+（如需）`specimen_tracer.gd` 多 wolf 擴充。**勿碰決策/assimilate 行為。**
