# Hand Back: wave1 序1 — threat 子系統溶入引擎

status: open

## 實作摘要

融合非刪：`faction_ai_system.gd` 的 threat 手算 argmax（`_dispatch_threat_response`）溶進統一決策引擎。4 威脅反應成 REGISTRY option 由 term/weight 秤，撕手算，鏡射既有 survival 雙路。全 10 Task 完成，融合驗雙關全綠。

改動檔案（每檔一行）：
- `scripts/simulation/decision/decision_context.gd` — 加 `threat_react/threat_id/threat_pos/threat_threshold/is_resident` 欄位 + gather 內鏡射舊 `_evaluate_threat` raw 掃描（over ALL discovered，非 reputation-filtered `_max_threat`）。
- `scripts/simulation/decision/terms.gd` — 加 `prepare_drive/defend_drive/pacify_drive` eval term（**additive personality-dominant，人格 baked in eval**，weight=1.0，同 intent_fit 法）+ weight `prepare/defend/pacify`=1.0。
- `scripts/simulation/decision/options.gd` — 加 `備戰/迎戰/求和` REGISTRY row + threat-gated applicable（迎戰 併居民排除）+ to_task（局部 gather 取 threat_pos/id，避改 17 caller 簽名）。
- `scripts/simulation/decision/decision_engine.gd` — `rank_threat(ctx)` + `THREAT_OPTION_SET`；survival(FLEE) 特例用 raw `threat_react` 舊公式。
- `scripts/simulation/faction_ai_system.gd` — `_evaluate_threat` 撕手算換引擎 rank_threat 迴圈；刪 `_dispatch_threat_response`+`_flee_target`；unified 隊 early-return（threat 由 `_decide_unified` 主 rank 處理）；`_wire_threat_task` 共用 helper（`_evaluate_threat` 與 `_decide_unified` 兩路接 aux target）；`is_resident_static`；Probe 率表 bump。
- `scripts/debug/constitution_baseline.txt` — 移 `_dispatch_threat_response` 指紋，加 `_evaluate_threat`（序1）。sites=32 不變，gate PASS。
- `scripts/debug/threat_dissolution_check.gd`（新）— 融合驗核心：repertoire 4 原型 + 居民守衛 + unified 路徑 + 率表。
- `scripts/debug/headless_test.gd` — 退役 4 `_test_dispatch_*` + `_eng_dispatch_setup`（直呼已刪 func）；repertoire 驗移至融合驗 harness。

### 與 spec/plan 的差異（重要）

**term magnitude 結構改為 additive personality-dominant（偏離 plan 的 multiplicative eval×weight）**：
- plan 原設 `eval=threat_react × weight=人格公式`。實測 `threat_react` **unbounded**（`ThreatAssessment.score` 的 power_ratio 可大，弱隊遇強隊 threat_react 達 3.27）→ 求和/備戰 util 爆量（2.75/2.45）壓過 survival 絕境 drive（投靠 2.1），p2a 測試 regress（義氣絕境隊選 求和 而非 投靠）。
- 舊 `_dispatch_threat_response` scores 是 **additive personality-dominant**（threat 只作 ±0.2/0.3 小 modifier，PREPARE/求和 根本不吃 threat magnitude）。**改為忠實鏡射舊公式**：人格 baked in eval，weight=1.0（同 codebase 既有 intent_fit/attack_drive 法）。survival(FLEE) 在 rank_threat 特例用舊 `求生欲*0.8+(threat_react−0.5)*0.3`。
- 結果：threat option magnitude 回 0..~1 有界 → survival 絕境（drive 2~8）正確碾壓 → 保舊 survival>threat 優先序（舊 `_evaluate_survival` 先於 `_evaluate_threat` 跑、threat 只在 idle 觸發的隱含優先序）。

## 融合驗結果（雙關）

**5a repertoire（設計正確性閘）**：4 人格原型 rank_threat[0] 全落各自反應 —
FLEE(求生欲0.9)→survival、DEFEND(好戰0.9非居民)→迎戰、PREPARE(慎重0.9)→備戰、PACIFY(貪婪0.8信義0.7)→求和。居民守衛：好戰居民 迎戰 排除 applicable、備戰/survival/求和 仍可。**repertoire 沒少**。

**5b 率表（該出現還出現）**：seeded warring(1337,1200t) `threat.dispatch` 聚合 = 18 > 0。逐類 flee=13 prepare=4 defend=1 pacify=0，**與融合前 baseline 逐類完全相同**（非 unified threat 路徑零行為變）。pacify=0 此 seed/窗（稀有，非退化；逐類可達性由 5a 證）。

**Task7 unified**：健康 MERCHANT 隊遇敵意逼近敵 → 主 rank ranked=`[survival,備戰,迎戰,建設,求和,覓食]`，threat option 浮現頂端（不被日常決策壓過）。

## seeded 漂移評估（不機械守恆，交 QA 判）

| | teams | factions | established | pop |
|---|---|---|---|---|
| 融合前 baseline | 46 | 8 | 1 | 380 |
| 融合後 | 48 | 8 | 1 | 382 |

**漂移來源**：非 unified threat 路徑逐類分佈**零變**（flee13/prepare4/defend1/pacify0 不動）→ 漂移純來自 **unified 隊 threat option 進主 rank 競爭**（unified 隊遇威脅偶選 備戰/迎戰/求和/survival，微調軌跡）。**判定：合理非退化** —— factions/established 守恆、pop 穩、世界健康（無滅團潮/歸零）。非零漂移符合預期（threat 融合理應影響分佈）；漂移小（±2 teams）因 unified 隊威脅事件本就稀少。**請 QA 覆判「新分佈合理非退化」。**

## 回歸

- headless_test：`=== DONE ===`，無 SCRIPT ERROR / assertion fail，seeded 48/8/1/382。
- framework_validation：PASS=7 DORMANT=0。
- threat_dissolution_check：ALL PASS（repertoire/居民守衛/unified/率表）。
- constitution_gate：PASS（sites=32，removed=0）。

## 連動風險（主 session 決定是否補修）

- **`_decide_unified` aux target 接線**：unified 隊選 迎戰/求和 時 `_wire_threat_task` 補 `prosperity_target_id`/`order_target_id`/`order_task`（舊 `_dispatch_threat_response` 對 unified idle 隊做的事，新路由改由主 rank 但接線保住）。DEFEND task 的 prosperity_target 消費端 / 求和 tribute_offer 外交鏈若對 unified 隊有時序假設，值得一驗（測 harness 已證 target 有設，但未跑完整 DIPLOMACY resolution 迴圈）。
- **survival(FLEE) 雙語意**：主 rank 的 survival option 用 reputation-filtered `ctx.threat`（軟，merchant 不逃中立商伴）；rank_threat 的 survival 特例用 raw `threat_react`（硬，鏡射舊 threat 反應）。兩語意刻意分離，但同名 option 兩處不同計分 —— 若日後有人統一 survival scoring 需知此差異（已註釋標明）。
- **`_evaluate_threat` unified early-return 位置**：放在 idle-gate 後、release-check（DEFEND/PREPARE/FLEE 消失釋放）**之後**（保守：release 仍對 unified 成立）。unified 隊實務走 `_decide_unified` 派 threat task（PRIO_DISPATCH 非 PRIO_THREAT）→ 其 release 靠主 rank option 變 non-applicable 自然換手，非靠 `_evaluate_threat` release。fresh sim 無 pre-existing PRIO_THREAT unified task，安全；長跑未見異常。
- **訊號 reconcile（待藍圖 threat-signal handback）**：spec 提及的訊號呈報藍圖若要求改 threat 反應語意（如求和訊號傳播），本實作預設可 merge，該調整為後續 task。

## 待主 session 確認

- **term magnitude 結構偏離 plan（additive 非 multiplicative）**：實測驅動的忠實鏡射修正（見上「與 spec 差異」）。請確認此偏離獲認可（架構上更貼舊行為，非繞過）。
- **seeded 漂移 48/8/1/382 覆判**：交 QA 判「合理非退化」。
- 建議後續：unified 隊 threat 反應（求和/迎戰）跑一次完整多 tick 情境驗 tribute_offer/DEFEND resolution 端到端（本 arc 只驗 target 接線 + option 浮現，未驗下游 resolver）。
