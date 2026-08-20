# 模型完工清單(長跑前置閘的正典清單、用戶令 2026-08-21)

status: DRAFT(blueprint WHAT 盤點;各項現況待 systems code-verify 後轉 CANONICAL)
owner: blueprint(WHAT 清單本體);現況欄=systems 驗證權威
用戶令:「模型與統一框架哪還沒做完,一起入清單,全做完再跑長跑。」——本清單=下輪長考(診斷/驗收皆同)的前置閘實體。

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
| D4 | 死常數人格化 backlog(逃跑 3 格/資訊扭曲平骰/其他照妖鏡殘目) | 質地級,可豁免 |
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
