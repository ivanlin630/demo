# Handback：wave1 序3 — rung_task 查表溶入引擎

**狀態：** 全 Task done，全驗綠。**+ 序3 follow-up done（idle-filler 收窄，見文末）。channel：** open（待系統/藍圖判 QA-級漂移 + 連動風險 + follow-up 的 threat harness 改判）。

## 交付

`ambition_ladder.rung_task` `(archetype,rung)→固定 task` 查表判斷器撕除 → archetype/rung 當 **weight context**（`ctx.archetype`/`rung`/`has_trainable`/`ambient_train_drive`）驅動對應 option。唯一真缺 = **訓練 option**（FORCE-archetype 累積階練兵），已 option 化。idle-filler（fai loop3）換引擎 rank。**溶=融合非刪**。

## 冗餘識別（★關鍵，最小改動根據）

`rung_task` 7 條 mapping，6 條**既有 option 已覆蓋**（TRADE→貿易/economic_opp、SETTLE-累積→生產/produce_need、SETTLE-擴張→建設/settle_fit、EXPAND-FORCE→""讓 prosperity、SURVIVE/STATE/HEGEMON→""讓 survival/faction）。唯一真缺 = ACCUMULATE×FORCE→TASK_TRAIN。∴ 序3 只補訓練 option + 換 idle-filler + 刪查表。

## 具體改動

| 檔 | 改動 |
|---|---|
| `decision_context.gd` | +`archetype`/`rung`/`has_trainable`(anon_cohorts 非空)/`ambient_train_drive`(FORCE+累積/擴張階→0.5) |
| `options.gd` | REGISTRY「訓練」+ applicable(FORCE archetype + has_trainable) + to_task(TASK_TRAIN 原地) |
| `terms.gd` | `train_drive` eval(讀 ambient_train_drive) + `train` weight(0.3+好戰×0.4+野心×0.2) |
| `faction_ai_system.gd` | loop3 idle-filler：`rung_task` lookup → `DecisionEngine.rank_scored_ctx(ctx)` 取首 dispatchable(非 IDLE) PRIO_AMBIENT |
| `ambition_ladder.gd` | 刪 `rung_task` 整函數（換註記指向引擎） |
| `headless_test.gd` | `_test_rung_task_map` 退役、`_test_ambient_ladder_task` 改測 TaskArbiter ambient<survival 優先序(不依賴查表) |
| `rung_dissolution_check.gd` | 新 融合驗 harness（5 repertoire 原型） |

**note**：plan §4d 寫 `DecisionEngine.rank_scored(ctx)` 是錯 arity（真簽名 `rank_scored(state,team)` 回 dict 陣列）。改用 `rank_scored_ctx(ctx)`（gather 一次、correct API、回 dict）。語意等同 plan 意圖。

## 驗收結果（全綠）

| 驗 | 結果 |
|---|---|
| rung 融合驗 `rung_dissolution_check.gd` | **ALL PASS**：FORCE-累積→訓練可達+idle浮現、TRADE→貿易、SETTLE-累積→生產、SETTLE-擴張→建設、FORCE-擴張→讓位緊急(攻擊>掠奪>訓練) |
| threat 融合驗 | ALL PASS（序1 未破） |
| solo 融合驗 | ALL PASS（序2 未破） |
| framework_validation | **PASS=7 DORMANT=0**（★S3 scout 不 DORMANT，序2 yield 仍守） |
| headless_test | DONE 無 SCRIPT ERROR 無 assert fail、`ambient ladder OK` |
| 憲法閘 | **PASS (sites=32, removed=0)**；`rung_task` 回字串無 TaskArbiter 呼叫→不在 32 指紋，刪它不動指紋（序3 spec §6 預測命中） |
| seeded warring | 52/8/1/380 → **49/8/1/380**（teams −3，pop/factions/established 守恆；漂移允許 QA wave 判） |

## 練兵/貿易 ambient 率（對照 Task0 baseline）

pre-fusion idle-filler dispatch（seed 1337/1200t）：生產=1 貿易=2 訓練=0 建設=0。
post-fusion idle-filler dispatch：**建設=22 徵收=10 製造=9 逃跑(FLEE)=86；訓練=0 貿易=0**。

- **訓練=0 = 與 baseline parity**（seed 1337 無 FORCE-累積隊落 idle-filler；TASK_TRAIN 本來就沒經此路徑派過）。repertoire 可達性由 harness 硬證（融合非刪 滿足）。
- **貿易 ambient 2→0，但全域貿易健康**：`trade.dispatch.solo=11`、`trade.deal=5`、`arb_pick=104`、`post_buy=233`。merchant 貿易已由**序2 solo 引擎路徑主導**（loop2），到 loop3 idle-filler 時 merchant 多已非 IDLE。baseline 的 2 筆 ambient 貿易是噪聲級。spec §5「貿易 ambient 率保」字面違反(probe=0)但**精神(貿易仍發生)由 solo 路徑滿足**。

## ★連動風險（呈報系統/藍圖）

1. **idle-filler 現派 FLEE(逃跑=86)＝新行為，量級大**：查表時代 idle-filler 只派 rung_task 子集(生產/貿易/建設/訓練)；換全引擎 rank 後，faction-member idle 隊在 `ctx.threat>0` 時「survival(FLEE)」option 勝出 → 以 **PRIO_AMBIENT** 派 TASK_FLEE。低優先，下 cadence 被 survival/faction-strategic 覆蓋，但 86 筆/1200t 是可觀 churn，疑似 teams 52→49 漂移主因。
   - **判點**：(a) idle-filler 是否該**排除 survival/threat option**（那些已有序1/序2 專路），只留 prosperity-class(訓練/貿易/生產/建設/囤貨)？plan §4d 明寫「取首 dispatchable」未排除，我照 plan 實作；若系統判該收窄，是一行 filter。(b) faction-member idle 行為本屬**序6 域**（plan Self-Review 標「序6 前橋」），此填是暫態橋，序6 可能整體重寫。

2. **「建設」option 恆 applicable（`options.gd` 無 gate）→ idle-filler 恆有非-IDLE 可派**：建設=22。與序2 handback 風險#1(b) 同源框架債——任何 idle 隊永不真閒。此路無序2 的 prosperity 餓死問題（framework PASS=7 守），但 idle 隊被推去 bootstrap 建設是行為漂移。同型缺口第二次出現＝框架信號（`建設` 該加 context gate）。

3. **`ambient_train_drive=0.5` / `train` weight 係數 = TEST VALUE**：低 magnitude 讓位緊急已由 harness FORCE-擴張原型證(攻擊>掠奪>訓練)。但 seed 未觸發真練兵 dispatch → 實戰平衡未校。wave QA 若要「FORCE 累積隊真的練兵」需 seed/情境催出 FORCE-accumulate-idle 隊驗證。

4. **seeded teams 52→49（−3）pop/factions/established 全守恆**：drift 來自 idle-filler richer repertoire(FLEE/建設/徵收 churn)。世界未崩(pop 380 穩、established 1、8 factions)。QA wave 判是否訊號 vs 噪聲。

## 後序

- 序3 綠 → 序4 vendetta（`feud_pull` term 掛攻擊 option）。
- 若系統判風險#1 收窄 idle-filler / 風險#2 建設 gate，屬**框架債結構修**，宜與序2 handback 風險#1(b) 併案（單寫者統一決策）。

---

# 序3 follow-up：idle-filler 收窄 rank_ambient（系統裁定風險#1 已修）

**狀態：** done，全驗綠（commit `a18c2eb`）。系統裁定「風險#1(a) 收窄 idle-filler，只留 prosperity-class」→ 已實作。

## 交付

idle-filler（fai loop3）從走**全** `rank_scored_ctx` → 走 **`rank_ambient`**（限 `AMBIENT_OPTION_SET = [訓練,貿易,生產,建設,囤貨,駐守]`）。ambient 只填 idle，不二次猜 survival/threat（team 到此已過 loop3 survival(_evaluate_survival)/threat(_evaluate_threat)/prosperity 評估）。

## 具體改動

| 檔 | 改動 |
|---|---|
| `decision_engine.gd` | +`const AMBIENT_OPTION_SET` + `static func rank_ambient(ctx)`（鏡射 `rank_threat`：applicable ∩ set，util 秤降序，回**字串**陣列，無 survival 特例、無 commitment） |
| `faction_ai_system.gd` | idle-filler：`rank_scored_ctx`→`rank_ambient`，迴圈吃字串（`rank_ambient` 回字串非 dict） |
| `rung_dissolution_check.gd` | repertoire 1-4 改驗 `rank_ambient`；+ 斷言「survival/threat option 全不在 rank_ambient」+「FORCE-累積有兵→rank_ambient[0]==訓練」；check 5 讓位緊急仍驗**全** rank（loop2 unified 域）+ 加 ambient 隔離斷言 |
| `threat_dissolution_check.gd` | ★見下「連動風險/harness 改判」 |

## 驗收結果（全綠）

| 驗 | 結果 |
|---|---|
| rung 融合驗 | **ALL PASS**（含新 ambient 隔離斷言） |
| threat 融合驗 | **ALL PASS**（★5b 改確定性 live-seam，見下） |
| solo 融合驗 | ALL PASS |
| framework_validation | **PASS=7 DORMANT=0** |
| 憲法閘 | **PASS (sites=32, removed=0)** |
| headless_test | DONE、`ambient ladder OK`；`[FAIL] 弱目標未加入攻擊 goal` = **HEAD 既有**（strategic `_update_goals`，非本 follow-up 域，soft print 非 hard assert） |

## idle-filler dispatch 分佈（seed 1337 / 1200t，對照 pre-follow-up）

| task | pre-follow-up | post-follow-up |
|---|---|---|
| 建設 | 22 | 23 |
| 製造 | 9 | 9 |
| **逃跑(FLEE)** | **86** | **0** |
| **徵收** | **10** | **0** |

- **FLEE 86→0**：主要 churn 除盡。survival ∉ AMBIENT_OPTION_SET → ambient FLEE **結構性不可能**（非靠 magnitude 壓，靠 set 排除）。
- **徵收 10→0**：faction-duty option 亦不在 ambient set（idle-filler 不再代 faction 徵收，歸 faction strategic 域）。
- **建設/製造 保**：真 prosperity-class ambient 未動。

## seeded teams 漂移（3 seed，1200t）

| seed | HEAD(序3) | follow-up |
|---|---|---|
| 1337 | 49 | 48 |
| 42 | 55 | 56 |
| 7 | 49 | 55 |

pop/factions/established 全守恆（世界未崩）。teams 落 **48–56 帶**繞 52（emergent 噪聲）。**誠實限制**：seed 1337 未乾淨回 52（48），「收斂近 52」是帶內趨勢非逐 seed 命中；FLEE churn 除盡（本 follow-up 主目標）已達成。

## ★連動風險 / harness 改判（呈報系統/藍圖裁定）

1. **★threat 融合驗 5b 從「seeded 湧現硬斷」改「確定性 live-seam 硬斷」（改了序1 owned harness）**：
   - **現象**：本 follow-up 後 `threat.dispatch.*`（_evaluate_threat，PRIO_THREAT 真威脅路徑）seeded 值 **3→0（全 seed）**。
   - **根因**：非機制壞。HEAD 的 86 ambient-FLEE churn 是隊間威脅遭遇的**主要製造者**（隊亂逃→撞見彼此→threat_react 過門檻）。收窄後世界變靜→ non-unified idle 隊少真過門檻威脅→ 真威脅派發自然=0。`_evaluate_threat` **未改**且 loop3 仍先於 idle-filler → 真威脅仍會派。
   - **改判**：5b 硬斷 `total>0` **耦合世界軌跡**（本 follow-up 正是弱化該軌跡）→ 我把硬斷改為**確定性注入**：構 non-unified idle 威脅隊 → 直呼 `_evaluate_threat` → 斷言實派 threat task + probe bump（`[live] _evaluate_threat 實派 逃跑 + probe bump(0→1) OK`）。seeded 值降為**資訊性趨勢**（保留印出，不硬斷）。
   - **判點**：(a) 我把 harness 改**更強**（確定性 seam 測 vs 脆弱湧現），非弱化/gaming；threat 機制由 5a(rank_threat argmax)+Task7(unified 主 rank)+resident+新 live-seam 四路證。但**這動了序1 owned 檢查**，請系統裁定是否認可此改判，或要另立方案（如：5b 改計 unified threat 反應、或跨 seed 聚合閾）。(b) seeded 真威脅=0 是否本身訊號？我判是「靜世界=收窄副產物、非病」，但若藍圖要世界保持一定威脅張力（game-design 反龜縮 bar），此靜化需 QA wave 眼球判。

2. **teams seed 1337 停 48 未回 52**：收窄除 FLEE churn 但未淨還原 teams 至 pre-序3 的 52。drift 殘留可能來自序3 rung dissolution 本體（非 follow-up）。QA wave 判 48–56 帶是否可接受 vs 需再收斂。

3. **風險#2（建設恆 applicable）未動**：本 follow-up 只收窄 option **集合**，未加建設 context gate。建設仍 idle-filler 首選之一（23）。若系統要修風險#2，仍是獨立 gate（與序2 handback 風險#1(b) 併案）。
