# Hand Back: wave1 序3.5 — threat preempt（強威脅打斷非緊急 task）

status: open

## 實作摘要

忙碌目標對壓境攻擊者盲（idle-gate seam）已斷。`_evaluate_threat` idle-gate 擴充為三分支：idle→原路；busy-preemptible + threat_react≥`threshold+PREEMPT_MARGIN`→打斷 task 派 defensive；busy-urgent（戰鬥/social/緊急）→不評。門檻由既有 threat_react 訊號（power_ratio+approach+hostility）天然滿足「能傷你」，**無新增 tag/label 判斷**。接 approach→感知→反應因果脊椎，非新機制。全 3 Task 完成，雙關驗全綠。

改動檔案（每檔一行）：
- `scripts/simulation/faction_ai_system.gd` — 加 `PREEMPT_MARGIN`(2.0)+`PREEMPTIBLE_TASKS` 常數；`_evaluate_threat` idle-gate 換三分支 gate（idle unified skip/一般門檻 vs busy-preemptible 高門檻）。
- `scripts/debug/threat_preempt_check.gd`（新）— 融合驗雙關 harness（該出現 + 反向守 3）。

## 與 spec/plan 的差異（重要）

1. **PREEMPT_MARGIN = 2.0，非 plan 建議的 0.5**。plan 假設 0.5 足以分離「壓境」與「弱敵」。實測 threat_react 組成 `approach·1 + hostility·1 + (power_ratio−1)·0.5`（threat_assessment.gd:19），approach/hostility 各 weight 1.0 壓過 power（0.5）→ **逼近但弱+敵意** 敵 react≈1.49（approach 1 + hostility 0.95 主導，power 負貢獻小），margin 0.5（門檻 0.86）會誤觸 preempt，破反向守 ②c。measured：該出現(碾壓)react=5.52、②c(逼近但弱)=1.49 → margin 須 ∈(1.13, 5.16)，取 **2.0**（門檻 2.36，雙側留餘裕）。語意：power_ratio 須 ≳5（碾壓）才把 react 推過門檻 = 天然「能傷你」。**margin=TEST VALUE，待 wave QA 校抖動 vs 靈敏。**

2. **`TeamData.TASK_MOVE` 不存在**（spec §4a/plan Step1 誤列）→ 未列入 PREEMPTIBLE_TASKS（引用不存在常數＝編譯錯）。實碼無「移動」task，移動走各 task 內 `move_target`。

## Follow-up 修（系統確認：定居生產隊 seam 未接）

初版 PREEMPTIBLE_TASKS 缺 `TASK_PRODUCE`。定居 resident 生產隊經 `interaction_system:1065 transition("生產"=TASK_PRODUCE)` 進 TASK_PRODUCE（**非** TASK_MANUFACTURE）→ 藍圖核心「犁田遇劫匪放犁」case（定居村挨打）仍盲。TASK_PRODUCE 已在 interruptible(fai:2398)、PRIO_AMBIENT(10) 低優先 → 該 preemptible。

**修**：
- `PREEMPTIBLE_TASKS` 加 `TeamData.TASK_PRODUCE`（現 8 項：生產/製造/建設/貿易/治理/訓練/覓食/紮營）。
- harness 加 ③（unified 生產隊 + resident guard）：
  - **③a 該出現**：定居生產隊（TASK_PRODUCE、TAG_PRODUCE=unified）遇壓境(react=5.52) → 放下生產派**逃跑**。unified 忙碌隊走 preempt path 確證。
  - **③b resident guard**：居民生產隊（自家 outpost，`is_resident`→迎戰排除）遇壓境 → 派**非迎戰** defensive（逃跑），迎戰排除後 rank_threat 仍給反應**不卡死**。✓
  - **③c 反向守**：TASK_PRODUCE + 弱(0.69)/中立帶刀(0.91) 非逼近 → 續生產。✓
- 全回歸重跑綠（下表更新）。**seeded 不變 52/9/1/381**（TASK_PRODUCE seeded-neutral）；**rerise flee=12 不變**——WarringHarness 世界無「resident 生產隊挨壓境攻擊」情境，TASK_PRODUCE seam 由確定性 harness ③ 證活，非 seeded 湧現。定居村挨打的 defensive 顯化需真有壓境攻擊定居點的世界軌跡（wave QA live 觀察）。

## 融合驗結果（雙關，ALL PASS）

- **① 該出現**：忙碌隊（TASK_MANUFACTURE、好戰 leader、10 pop、非居民）+ 壓境攻擊者（40 武裝、敵意 rep 0.05、逼近）→ react=5.52 > 門檻 2.36 → 放下製造派 **逃跑(FLEE)**。✓
- **② 反向守 3**（禁讀 tag，由 threat_react 低分自然滿足）：
  - a) 弱(3武裝)+敵意+非逼近 → react=0.69 → 續製造 ✓
  - b) 中立帶刀商隊(rep 1.0 友好、12 武裝、非逼近) → react=0.91 → 續製造 ✓
  - c) 逼近但弱(3武裝+敵意+逼近) → react=1.49 → 續製造 ✓
- 三反向皆綠 = 「見武裝就恐慌」防線成立。

## ★反龜縮驗（seam 斷坐實）

**seeded defensive threat dispatch（threat_dissolution rate 表，seed 1337/1200t）：flee 0 → 12**（baseline total=0 → 現 total=12，全 FLEE）。忙碌目標現會反應壓境攻擊 → offensive 22.5% 不對稱的 defensive 下游開始顯化。

## 回歸 + seeded 漂移

| 閘 | 結果 |
|---|---|
| preempt 雙關 | ALL PASS |
| framework | PASS=7 DORMANT=0 |
| threat/solo/rung dissolution | ALL PASS（threat live-seam 仍綠） |
| constitution | PASS（sites=32 removed=0，指紋不變——改在既有 `_evaluate_threat`） |
| seeded 重現 | OK（同 seed 逐點重現，probe_capture=0） |

**seeded 漂移**：48/8/1/380 → **52/9/1/381**（teams/factions/established/pop）。preempt 加 12 FLEE dispatch → 同 seed 世界軌跡分歧。plan 明允此漂移（defensive 反應升→漂移，QA wave 判）。漂移幅度小。
（註：pre-impl headless seeded 未獨立截；48/8/1/380 為 plan 記錄之先值。同 harness 的 rate 表 0→12 為乾淨 before/after，機制確定性由重現閘保。）

## 連動風險 / 待藍圖

1. **preempt task churn / 抖動**：preempt 走 PRIO_THREAT(70) 打斷 PRIO_DISPATCH(50) task。release 檢查（威脅消失）回 **idle** 非原 task → 忙碌隊被 preempt 後威脅退，回 idle 由主 AI 重派（非自動續原製造）。頻繁遭遇下可能 製造→逃→idle→製造 churn。THREAT_CADENCE=1 日 限重評頻率，緩解。實測 seeded 未見暴 churn（僅 12 FLEE/1200t），但 margin 調低會放大——wave QA 觀察點。
2. **unified 生產隊 preempt 覆蓋** — ✅ 已修（見上 Follow-up）。TASK_PRODUCE 納入，harness ③a/③b 證 unified 生產隊 + resident guard 皆正確 preempt。
3. **PREEMPT_MARGIN=TEST VALUE**：2.0 由本 harness 4 點校，非世界實跑分佈。wave QA 需看 seeded/live 抖動率定案。
