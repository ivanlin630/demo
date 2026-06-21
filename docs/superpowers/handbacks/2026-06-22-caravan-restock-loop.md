# Hand Back: 商隊餓死修 — 返家補給迴路

> 子 session `feat/caravan-restock`，執行 plan `2026-06-22-caravan-restock-loop.md`。
> **狀態：Task 1 實作完成且全綠；Task 2 驗收顯示履約「未脫 0」——measure-first 找到根因，回報 systems 裁示。**

## 實作摘要

### Task 1（done，commit `19ca44e`）— 返家補給 option
- `scripts/simulation/decision/decision_context.gd`：加 `has_home_outpost: bool` 欄位 + gather（`FactionAISystem.new()._find_own_outpost(state,team) != (-1,-1)`）。
- `scripts/simulation/decision/terms.gd`：加 `const RESTOCK_DAYS = 5.0` + `restock_need` term eval（`clampf((RESTOCK_DAYS-food_days)/RESTOCK_DAYS, 0, 1.5)`）。
- `scripts/simulation/decision/options.gd`：REGISTRY 加 `"返家補給":[["restock_need","survival_pressure"]]`；applicable 加守衛（`is_merchant and food_days<RESTOCK_DAYS and has_home_outpost`）；to_task → `TASK_RETURN_HOME` + `_find_own_outpost`。**現有守衛全未動**（藍圖裁定無 gate）。
- `scripts/debug/headless_test.gd`：加 `_test_merchant_restock`（4 案：旅途糧低有家=候選+RETURN_HOME(2,2)／糧足=無／無家流民=無／生產隊=無），註冊於 `_test_role_applicable()` 後。

**回歸閘全綠**：`merchant restock OK` + `role applicable OK` + `TC7 divergence OK (3 leader 3 option)` + `投靠守恆整合 OK` + InvariantAudit(population/faction/subteam) 全 OK + `=== DONE ===`，0 assert/SCRIPT ERROR。coin_eq 守恆 0。**TC1/4/6/7 原樣，現有守衛零影響。**

### Task 2（驗收 only，無 code 改 → 跳 commit）
- `world_sim.gd` 跑滿一輪量測。temp diag 探針已加→測→**已回滾**（faction_ai_system.gd 無淨改動）。

## 履約「未脫 0」根因（measure-first，硬證據）

修後 `world_sim` 量測（vs 基準）：

| 指標 | 基準（修前） | 修後 | 判定 |
|---|---|---|---|
| `訂單履約率` | 0.0% | **0.0%** | 未脫 0 |
| `g1.merchant_survival` | ~164 | **164（一字不差）** | 返家補給零效果 |
| `g1.market_arrive` | ~63 | 58 | 無升 |
| `[Market]成交` | 0 | 1 | 無常態 |

temp diag 探針（530 次商隊 `_decide_unified`）拆解：
- `diag.merchant_has_home = 529/530` → **商隊幾乎都有家**（推翻「無家→不適用」假設）。
- `diag.restock_window = 55` → 適用窗（糧低+有家）命中 **55 次**。
- `diag.restock_chosen` **= 0（key 從未建立）** → 返家補給適用 55 次，**勝出 0 次**。

**根因 = 兩重複合缺陷，使返家補給 dead-on-arrival：**

1. **適用窗內 util 太弱，恆輸 argmax。**
   `util(返家補給) = weight("survival_pressure")=1.0 × restock_need`。
   `WARNING_DAYS=3`（survival 觸發門檻）< `RESTOCK_DAYS=5` → 乾淨 proactive 窗 = food_days **3–5** 這一帶。該帶 `restock_need = (5−d)/5 = 0.2 ~ 0.4`。
   同時 `util(貿易) = weight("economic")(0.3+貪婪≈1.0) × economic_opp(有貨+arb≈0.8) ≈ 0.8`，再加 `COMMITMENT_BONUS 0.3`（商隊現行多為貿易）≈ **1.1**。
   → 返家補給(0.2–0.4) 被貿易(1.1) 輾壓，55 次窗內 0 勝。
   **Plan Self-Review 宣稱「restock_need×survival 權重壓過治理/貿易」與量測相反。**

2. **restock_need 要強(→1.0)需 food_days→0，但那時商隊已 latch 進 SURVIVAL_TASK。**
   `faction_ai_system.gd:785-790`：商隊 `current_task in SURVIVAL_TASKS` → `Probe.bump("g1.merchant_survival")` + `continue`，**早於 `_decide_unified`**。一旦 food_days<3 進 survival，引擎（含返家補給）再不獲呼叫 → 即使 restock_need 此時夠強也來不及。此 latch 為架構**明文延後項**（786-787 comment：「本 WS 不硬修 survival」）。

兩缺陷夾擊：返家補給強的區（<3）被 latch 鎖在門外，能進的區（3–5）又太弱選不上。

## 連動風險
- `decision/*`：本次只**加** option/term/欄位，現有 row/守衛/term 未動 → 對 TC1/4/6/7、生產隊、sub-project A 零影響（回歸證實）。
- `faction_ai_system.gd`：diag 探針已回滾，無淨改動。
- survival 系統（`_trigger_survival`/WARNING_DAYS/SURVIVAL_TASKS latch）**完全未碰**（believability 護欄遵守）。

## 待主 session（systems）確認 — 二選一或並用

返家補給機制正確落地但**因兩個設計參數/架構互動而無效**。皆屬設計/平衡決策（curve 值、latch 行為），逾實作 session 權限，不自行 retune：

1. **強化 proactive util（平衡）**：proactive 窗(3–5)需讓返家補給壓過貿易。選項：拉高 `restock_need` curve（如非線性/加 base）、給返家補給獨立高權重 key、或加 commit-bypass。但須權衡 believability（別讓商隊一糧降就跑回家、崩 specialization）。**RESTOCK_DAYS=5 與 WARNING=3 的窄 2 天窗是否足夠也待裁。**
2. **拆 survival latch（架構，已明文延後）**：`faction_ai_system.gd:785-790` 讓商隊在 survival 仍能評返家補給（survival↔返家補給 應同層或讓返家補給 proactive 先於 latch 觸發）。否則 RESTOCK_DAYS 永遠只能在 3–5 窄帶起作用。

**建議**：先做 (1) 把 proactive 窗做有效（最小變動驗證迴路成立），量測 restock_chosen>0 與 merchant_survival 下降後，再評是否需 (2)。

**建議加常態探針**（仿既有 `g1.merchant_survival`）：`g1.restock_chosen` / `g1.restock_window`，供下一輪 measure-first 免再臨時插樁。（Probe taxonomy 屬 systems owner，故回報不自加。）

## believability 量測（藍圖守則）
- 返家補給目前零觸發 → 未影響 task 分布，無 specialization mush，無異常蓋城。TC7 三 leader 仍三分歧（霸主建設/商人貿易/隱士駐守）。
- 無家/瀕餓商隊仍走既有 survival（守護欄成立，測案 3 反例綠）。
- 真 believability（迴路成立後商隊貿易占多數、carried 週期回補）**待 systems 決 (1)/(2) 後重測**。
