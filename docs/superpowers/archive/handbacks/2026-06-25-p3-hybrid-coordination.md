# Hand Back: P3 混合協調 seam（faction stakes → unified 隊引擎響應）

branch: `feat/p3-hybrid-coordination`（已 push）

## 實作摘要

讓 unified 隊（merchant/produce）經統一決策引擎響應派系 `攻擊` stakes directive。霸主決策步零改（複用既有 `_update_goals` 攻擊 directive + readiness/belief gate）。

改檔（每檔一行）：
- `scripts/simulation/decision/decision_context.gd`：加 `faction_directive`/`faction_attack_target`/`faction_attack_target_pos`/`leader_loyalty` 欄；gather 注入 `leader_values["_loyalty"]` + 讀 `state.factions[fid].goals` 認 `攻擊` directive + `_nearest_independent` 設 target（複用既有 `_fa`）。
- `scripts/simulation/decision/terms.gd`：加 `FACTION_DUTY_DRIVE`/`DEFECT_AMBITION_K`/`ATTACK_DRIVE_BASE` const + `_duty_factor` helper；eval `faction_duty`(WHETHER)/`attack_drive`(HOW 染色)；weight `faction_duty`（脫軌逃閥）。
- `scripts/simulation/decision/options.gd`：REGISTRY 加 `攻擊` row + applicable 守衛（directive=攻擊 且有 target）+ to_task（→ TASK_ATTACK + combat_target）。
- `docs/invariants.md`：加「混合協調（faction stakes vs team 日常）」段。
- `scripts/debug/headless_test.gd`：3 個 p3 測（faction_duty term、attack option、war believability）+ 2 helper（`_mk_unified_faction_member`/`_mk_independent_target`）。

## 與 spec/plan 差異

1. **attack_drive 受 loyalty 調（偏離 plan 的 flat 0.3）**：plan Step 4 寫 `attack_drive` 回固定 `0.3`。但實測叛逆 member（低忠誠高野心）的 attack util = `0.3 × attack_weight(~0.85, 用 default 好戰/殘忍 0.5)` ≈ 0.255，仍蓋過其個人驅力（貿易 ~0.08/生產 ~0.15）→ rebel 仍攻擊 → 脫軌逃閥失效、Task2 rebel 測必 fail。
   - 修法：`attack_drive` eval 亦乘 `_duty_factor(loy, 野心)`（與 `faction_duty` weight 共用同因子）。語意：叛離者既無 duty 亦無「為派系參戰」的個人驅力（「這不是我的仗」），與 plan 自身「個人參戰基值」措辭一致。
   - 影響：believability (a) 不變（fierce/meek 同忠誠 0.8 → 同因子 → 仍由 attack weight 分高下，u_f 0.314 > u_m 0.103）。
   - 新增 const `ATTACK_DRIVE_BASE`（plan 內聯 0.3，我抽常數）。

2. 測試走 manual-WorldState 風格（仿既有 P2a helper），非 plan 草稿的 `GameSetup.setup`。等價、更輕、與既有 p1/p2a 測一致。

## 量測（Task 3）

- **headless**：3 p3 測 PASS，全測 0 `SCRIPT ERROR`，`=== DONE ===`。
  - soldier(忠誠好戰)→TASK_ATTACK(ct=601)；rebel(低忠誠高野心)→建設(脫軌逃閥生效)；peace(無 directive)→建設；starving(糧危)→覓食(survival 碾壓)。
- **world_sim 2yr**：不變量違反累計=0；2yr 不全滅、存活隊穩。
  - **本 run 無派系觸發 攻擊 directive**：僅 1 faction founded、商業 archetype（rung=1）、未達 established+attack_score gate。屬 unseeded rare tail；機制由 headless 證（plan Step 3 允許）。**無 over-war**（世界非全戰，T4 跑掠奪/貿易日常）。
- **framework**：S1-S6 全 PASS、DORMANT=0。
- **multi sanity**：4 scenario `[CoinAudit] delta=0`（守恆無破）。

## 連動風險（主 session 決定是否補修）

- **`faction_duty` 量級（FACTION_DUTY_DRIVE=1.5）**：高壓日常 term。weight 受 loyalty 調=非無限，但忠誠 member 的 1.5×0.9=1.35 會穩蓋日常（貿易/生產 ~0.1-0.3）。意圖如此（派系開戰=協同），但若量測顯忠誠隊「一有 directive 就全停日常去打仗」過頻 → 調降。
- **脫軌逃閥鬆緊（DEFECT_AMBITION_K=1.0）**：`loy − max(0,野心−0.5)×1.0`。野心 0.9+忠誠 0.2→0、忠誠 0.9+野心 0.5→0.9。中間帶（如忠誠 0.6 野心 0.7）→0.4=半參戰。閾未量測 tune。
- **loyalty 注入 `leader_values["_loyalty"]`**：`_` 前綴非人格鍵，既有 term 的 `v.get("好戰"/"野心"…)` 不誤讀。但 leader_values 現多一鍵——若未來有 term 遍歷 values keys（非具名 get）需注意。目前無此 term。
- **`攻擊` option 與既有 vendetta 路徑並存**：兩者皆可致 TASK_ATTACK 但來源分離（見下 TC3）。

## TC3 接線現況（私人脫軌 feud → 攻擊）

- 新 `攻擊` option **只**由 faction directive（`faction_duty`/`attack_drive`）觸發，**不**讀 feud。
- 私人血仇脫軌攻擊仍走既有路徑：`NpcAiSystem.vendetta_target`（讀 leader 最強 feud 邊 + 衝動 gate）→ `faction_ai.evaluate_all` 以 `PRIO_VENDETTA(55)` try_set TASK_ATTACK。未動。
- 兩路語意分離（派系協同戰 vs 個人血仇），**本塊未接 feud→攻擊 option**（避過早 scope，依 plan scope guard）。
- 待確認：是否要讓 unified 隊的 feud 也走新 `攻擊` option（統一攻擊入口），或維持 vendetta 獨立路徑。建議維持分離直到有需求。

## 待主 session 確認

- `FACTION_DUTY_DRIVE`(1.5) / `DEFECT_AMBITION_K`(1.0) / `ATTACK_DRIVE_BASE`(0.3) 皆 TEST VALUE，待 world_sim 量測（需 warlike faction run）tune。
- attack_drive 受 loyalty 調的偏離（§差異 1）——是否認可此設計（建議認可，脫軌逃閥所需）。
- 後續 stakes option 序：徵收/外交/立國/結盟/大徵收（本塊只 攻擊）。
- world_sim 未自然觸發攻擊 directive——是否需 seeded/構造 warlike faction 的專測驗 emergent 協同 war（目前僅 headless unit 證機制）。
