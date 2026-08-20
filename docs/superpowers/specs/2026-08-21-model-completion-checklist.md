# 模型完工清單(長跑前置閘的正典清單、用戶令 2026-08-21)

status: DRAFT(blueprint WHAT 盤點;各項現況待 systems code-verify 後轉 CANONICAL)
owner: blueprint(WHAT 清單本體);現況欄=systems 驗證權威
用戶令:「模型與統一框架哪還沒做完,一起入清單,全做完再跑長跑。」——本清單=下輪長考(診斷/驗收皆同)的前置閘實體。
★憲章(用戶原話 2026-08-21):「**下次長跑後不要再看到已知的模型問題。我可以接受未知或未實裝項目。不然會一直影響我們調參數、甚至未來項目的判斷。車組裝好了我們再上路跑。**」——三分法:已知壞=禁上路/未知=診斷考的目的/未實裝=豁免可但考卷明標「未裝,相關行為不讀」(防「沒裝」誤讀成「壞了」)。

## A. 反射弧本體(思考模型四邊補完)
| # | 件 | 現況(待驗) |
|---|---|---|
| A1 | 行動邊:dispatch-drop 合規盤點(convoy 7 silent false+order.abandoned/JOIN/建設 try_set/trade bail 逐族=消滅 or 有反饋失敗事件) | 列舉票 in-flight |
| A2 | 失敗回饋邊:失敗律落地(隊層 recent_failures+連續折價+失效升 T0) | HOW 已裁待 slice |
| A3 | 成功回饋單邊病:site_thrived 全期零筆(升級完工真發生後才有教材;§3c 工期落地連動驗) | 依賴鏈 |
| A4 | T0 事件匯流排(所有突發事件→喚醒;時間包/效能 arc 同體) | spec LOCKED 待執行 |
| A5 | **★邊界待用戶劃**:前瞻/承諾/means-end=長程計劃脊椎 arc(模型圖上有、從未實作;單獨大 arc) | 未開工 |

## B. 統一決策框架未收編/斷裂
| # | 件 | 現況(待驗) |
|---|---|---|
| B1 | 引擎外決策存量盤點 | ★**systems 已盤完（2026-08-21、見下 §B1 明細）**：寫入側乾淨、決策側找到 **4 個真存量** |
| B1b | **★mini-scorer 平行決策層窮盡盤點**(uprising 自帶算分/DiplomaticAiSystem accept-reject 各一例;全站還有幾套?)+B1 丙 4 站處置(收編 or 合憲標注;dormant 死枝坐實後刪) | blueprint 核准入列 2026-08-21 |
| B2 | 商隊 survival 履約(統一框架 B 首序舊帳) | 待驗(可能已折入) |
| B3 | capture/flip encounter-only(headless 恒不 fire)=戰爭科目結構廢考 | 戰爭之路已定案未修 |
| B4 | intent 從不選征服(survival-mode 收斂;B3 修後才測得出真偽) | 同上 |
| B5 | alliance/betray 決策層無選項(結盟=敘事標籤沒接行動) | 戰爭之路 scope |
| B6 | 手不聽腦殘目:subteam-idle-latch(HIGH 舊帳)+建設 try_set noop 族 | 待驗(部分可能已修) |
| B7 | 持守統一(23 硬鎖→人格加權秤;手不聽腦②型根治) | arc 已立案 PARK |

## C. 已排定修復(考前隊列既有,列此對齊)
效能五刀(B/C 重定靶量測中)/時間重錨+層級制包/生育連續調速(merge 待驗收)/game_over 附身鏡頭修/GATE-B(待 A1 列舉定修法)/workshop-不蓋之謎(facility-score 快照)/七病(EWMA cadence 相依/manufacturing day_fraction/移動信念 2→5/turn 打架/魔法數/命名/debug 鏡)。

## D. 結構債雜項(模型週邊、影響考卷判讀)
| # | 件 | 擋考? |
|---|---|---|
| D1 | 領導成長管道斷(established④;統領 0.08→cap6=村結構性小) | 人口/規模科目污染→擋 |
| D2 | anon 2c-2(晉升釋放 anon) | 待驗影響面 |
| D3 | loop1 correctness 債/pop_mult 飽和/FA7 FA8 | 邊緣,可豁免標注 |
| D4 | 死常數人格化 backlog | ★**用戶裁：擋考**（質地類全清才考）。systems 已窮盡盤點裸平骰側，**4 隻已知 + 2 隻新發現 + 1 邊界**（見 §D4 明細） |
| D5 | 軍民 Slice B(團型梯度) | 待驗依賴 |

## ★邊界裁定(用戶劃線 2026-08-21)
1. **A5 脊椎=不擋**:豁免標注「無前瞻,計畫類行為不讀」;脊椎=考後主軸,屆時自帶專屬診斷考。
2. **B3-B5 戰爭之路=全豁免**:戰爭科目標廢考(capture/intent/結盟三斷不考前修);warring config 仍跑(它測壓力下的經濟/人口/效能),只是戰爭欄不讀。
3. **D4 質地類=擋**:照妖鏡殘目(逃跑 3 格/資訊扭曲平骰/問詢說謊/顧問誤導+systems 盤點的其餘死常數平骰)**清完才考**。

## 閘規則(已立法,引用)
驗收考=清單清零;診斷考=科目對齊審(被蓋科目先修或降級)。本清單=閘的實體;systems 驗完現況欄轉 CANONICAL,每修一件勾一件。


---

## §B1 明細（systems code-verify、2026-08-21）

### 方法（負斷言紀律）
兩側各自窮盡：**寫入側** ＝ `\.current_task *= *` 全站（117 命中，**逐行看過**）；**決策側** ＝ `TaskArbiter.try_set` 全站（**20 站，逐站讀 caller 語境**）。

### 寫入側：**乾淨**（零違規）
117 個命中**絕大多數是讀**（`==` 比較）。真正的寫入僅五類、且皆有既有註記：
- 新 team 建立豁免：`population_system:62`（overflow 流亡）／`reaction_system:403`（放逐生成）／`subteam_system:62,117,148`（子隊 dispatch task）
- tutorial：`recruit_tutorial:16`
- **arbiter 自身**：`task_arbiter:76,96,107,122,143`
∴ **沒有任何系統繞過 arbiter 直接改 task**。

### 決策側：20 站分三類
**(甲) 引擎路徑（rank → to_task → try_set）4 站**：`_decide_unified:2626`（`td["task"]`）／`_decide_subteam:2941`／`_trigger_survival:4899`／`_evaluate_all_body:930`（`rank_ambient`）。
另 `_decide_unified:2579`（BUILD@SURVIVAL）＝**引擎選項「自救建田」的執行端**（`opt` 由 rank 選出）→ 歸甲。
**(乙) 玩家/命令/回復通道 6 站**（合法非引擎）：`_assign_tasks:2453`（`player_commanded_task`）／`player_command_system:241,565,1021`／`sim_runner:278`＋`interaction:1327`（乞食超時回復）／`interaction:639 _deliver_order`（信使送達命令，玩家 `PRIO_PLAYER`／NPC `PRIO_DISPATCH`）。
**(丙) ★真存量：引擎外決策 4 站**
| 站 | 性質 | 判讀 |
|---|---|---|
| `_evaluate_uprising:5384/5388` | **自帶 mini-scorer**：`stand = 野心×0.5 + 慎重×0.3 + 義氣×0.2` vs `flee = 求生×0.5 + (1−義氣)×0.3`，`stand > flee` 二選一 | **人格加權＝合憲**（非死常數門檻），但**自成一套評分、不經 DecisionEngine** ＝ **統一框架的真缺口** |
| `_commit_conquest_attack:337/352` | scout↔attack 切換由**手寫條件**（`_is_stuck` / `_was_scout`）決定 | 意圖來自戰略層，但**切換點是手寫分支**、非 util 秤 |
| `_try_invite_nearby_exile:651` | ★**跨隊指派**：A 隊在 B 隊回 `accept` 後**直接對 B 隊 `try_set(SETTLE)`** | 決策點其實在 `DiplomaticAiSystem.handle_diplomacy_message`（另一套 mini 決策層）→ **受邀方除 accept/reject 外無自主權** |
| `_evaluate_independent_strategy:1403` | 建國吞併 ATTACK；★**註解自陳「此分支現不觸；weak prey 已由 prosperity defer 收」** | **dormant（自陳）→ 待 probe 坐實**；若真死 → 該刪不該留（死枝會誤導後人） |

### ★由此浮出的下一層問題（非 B1 本體、記此備查）
`DiplomaticAiSystem.handle_diplomacy_message` 是**另一個自成一套的決策層**（accept/reject 外交提案）。B1 只盤 `try_set` 側；**「還有幾套 mini-scorer 平行於統一引擎」是更大的盤點**（uprising 是一例、diplomacy 是一例）→ 建議列為 **B1b**。


---

## §D4 明細（systems 窮盡盤點、2026-08-21）

### 方法
`randf()/randf_range/randi()/randi_range` 全 `scripts/simulation` **140 命中逐行看過**。
**先排除非決策類**（合法）：世界生成 `world_generator` 38／`person_generator` 16／`game_setup` 15；**ID 生成**（`str(randi())`）；**加權抽樣**（`message_system:149`、`anon_tier_system:114/128`）；**不確定性模擬**（`vision_system:110/127`、`path_system:196`、`distortion_engine` 的 `randf_range` 估值扭曲）。

### ★裸平骰決策點（D4 靶）
| # | 站 | 平骰 | 備註 |
|---|---|---|---|
| 1–4 | `distortion_engine:28/31/54/60` | `0.4`／`0.5`／`0.3`／`0.4` | ＝**「資訊扭曲平骰」本尊**（位置偏移／origin 錯置／task 謠言 ×2） |
| 5 | `inquiry_system:70` | `0.3` | ＝**「問詢說謊 30%」** |
| 6 | `advisor_system:37` | `0.5` | ＝**「顧問誤導 50%」**（錯高估 vs 錯低估對半） |
| **7** | **`message_system:173`** | **`0.3`** | ★**新發現、不在原四隻清單**：`"malicious" if randf()<0.3 else "silent"` |
| **8** | **`equipment_system:79`** | **`0.5`** | ★**新發現**：`recovered = 2 if randf()<0.5 else 0`（戰後裝備回收；偏 world-mechanic，但仍是對半平骰） |
| 9 | `ambush_system:42` | `AMBUSH_BASE_CHANCE` | **邊界**：死常數但屬**世界機制觸發率**（非人格決策）→ 是否納入交 blueprint |

### 已人格化/合憲（**不是** D4 靶、列此免重複盤）
`diplomatic_ai_system:130`（慎重³ 加權骰、有 `gate-ok` 註記）／`:325`（`margin × BETRAY_MARGIN_CHANCE`，margin 由情勢算）／`advisor_system:22`（`randf() < skills[skill]`）／`manpower_system:146`（`p_flee` 計算值）／`faction_ai:2889`（`fail_chance` 計算值）／`hunt_system:22`（`chance` 計算值）。

### 死常數側（非骰）
＝ `constitution_gate` 的 **`threshold`(9) + `rng`(3)** 兩類（gate 已在列舉、baseline 75→74）。**逐站清單需跑 gate 的 verbose 列舉取得**（本輪只取到型別分佈）→ **列為 D4 的第二批**，與裸平骰分開消化。
★注意：`gate-ok:` 註記的站是**已判合憲**（如慎重³ 骰、event-ID），**不在 D4 靶內**。


---

## §排程（systems 出、effort 序、2026-08-21）

★**原則**：①**依賴先於規模**（改法形狀未定的，先定形狀）②**能平行就平行**（implementer 主線 + 小票並行）③**擋考的大 arc 先估規模再排**（否則考期無法預估）。

### Phase 0（形狀先定，**擋住後面所有 A 類**）
- **A2 失敗律 slice**：隊層 `recent_failures` + 連續折價 + 失效升 T0（HOW 已裁）。
  ★**必須先做**：A1 那批 drop 點的**修法形狀**由它定義（「消滅 or 變成有反饋的失敗事件」——沒有反饋機制就無處可接）。

### Phase 1（主線，序列）
1. **A1 dispatch-drop 合規盤點 → 修**：convoy 7 站（列舉票 in-flight）→ `order.abandoned`（94.4% 靜默）→ JOIN → 建設 `try_set` noop → trade market bail，**逐族**。
2. **B6 手不聽腦殘目**：`subteam-idle-latch`（HIGH 舊帳）+ 建設 noop 族 ← **先驗現況**（可能部分已修）。
3. **B1 丙 4 站處置**（blueprint 指引）：**跨隊指派優先議**（受邀方無自主權＝違自主決策精神）→ dormant 死枝**坐實即刪** → conquest scout↔attack 手寫切換 → uprising **合憲可標注、不硬收**。

### Phase 2（平行小票，可與 Phase 1 同時跑）
- **D4 質地類**：裸平骰 6 隻 + 邊界 1 隻（`distortion` ×4／`inquiry`／`advisor`／★新發現 `message_system:173`／`equipment_system:79`／邊界 `ambush`），**一隻一票**；死常數側（gate `threshold`+`rng`）為第二批。

### Phase 3（我的活，與上面並行）
- **B1b**：mini-scorer 平行決策層**窮盡盤點**（已知兩例：`uprising`、`DiplomaticAiSystem.handle_diplomacy_message`）。
- **B7 持守統一** spec（arc 已立案 PARK → 需 unpark）。
- **★D1 領導成長管道**（established④）：**這是本清單的長桿**——arc 級、擋考。**先出規模估算再排期**，不要假設它能塞進考前窗。

### 待驗項（measurer/我 code-read，可插空）
**B2** 商隊 survival 履約是否已折入／**D2** anon 2c-2 影響面／**D5** 軍民 Slice B 依賴／**A3** `site_thrived` 零筆（依賴 §3c 工期落地）。

### ★風險與誠實預估
- **長桿 ＝ D1**（領導成長管道）與 **A1 逐族納管**（族數多）。**考期以清單清零為準、非日曆**（用戶已定）。
- **C 類（效能 arc 剩餘刀 + 時間包 S1–S7）本身就是多輪**；與 A/B/D 並行會搶 implementer——**同一時間最多兩條 implementer 線**（主線 + 小票），第三條要排隊。
