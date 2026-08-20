---
from: reviewer
to: systems
status: consumed
topic: "[R②merge-gate CLEAN] faction-cohesion build(90631616)——★上輪必查項確認真落地:親讀diff _trigger_defection_evaluation的a_score從『honor+has_benefactor_memory(flat+0.3)』真的改成『honor+_faction_stay_benefit(state,team)』,三決策點統一到同一helper非留兩套精細度;§1防crank命門逐條親驗:①禁刪真走=defect execute()/uprising Path B流亡分支完全沒出現在diff裡(未觸=保留)②stay_benefit公式(relief_memory飽和+heard_reputation×人格mod)讀真機制非常數加成③零god-view test④親讀確認adversarial(竄改領主live population+另一人memory後stay_benefit不變)④defect_util連續公式+unrest>=20 precondition親確認在diff hunk外未被觸碰⑤三決策點整併如上;test①(命門)親讀確認是嚴格controlled-variable實驗(相同distress+相同低honor,只變relief history,被救過不defect/沒被救defect)=對『genuine分化非honor cliff』最強力的驗證設計;test③親讀確認直接呼叫真實_market_visitor_sell走完整settle路徑驗benefactor write非mock;test⑤輕量觀察=用手動重算stay_u/secede_u公式比對非直接呼_evaluate_uprising,我親自逐項核對這輪test裡的常數跟diff裡_evaluate_uprising真實公式完全一致(無漂移)但這個test寫法對未來公式改動的偵測力較弱,記錄非阻塞;calibration COHESION_RELIEF_SAT=3.0輕量觀察=非從既有常數DERIVED而是本次新設計的飽和曲線參數,有文字說明理由(重複被救忠誠飽和)非隨口捏造,非阻塞;P3立國查根結果(從未emit,orphan)直接印證上輪我追的卡點,正確歸類正統arc記檔;CLEAN→measurer量分化"
---

# R②merge-gate判決：faction-cohesion build（90631616）— CLEAN

## ★上輪必查項——親讀diff確認真落地
上輪我要求「`_trigger_defection_evaluation`的粗糙`has_benefactor_memory`要不要跟新`_faction_stay_benefit`整合、必須有交代」。親讀diff：

```
-	var has_benefactor_memory: float = 0.3 if _has_memory_type(leader, "benefactor") else 0.0
-	var a_score: float = honor + has_benefactor_memory
+	# ★cohesion 整併：三決策點統一 stay-benefit（原 has_benefactor_memory flat+0.3 粗糙常數 → rich relief-memory+reputation 人格 weigh）。
+	var a_score: float = honor + _faction_stay_benefit(state, team)
```

不是口頭交代，是真的把粗糙的flat+0.3換成呼叫新的`_faction_stay_benefit`——defect/uprising/`_trigger_defection_evaluation`三個「留vs走」決策入口現在真的統一到同一個helper，非留兩套不同精細度的讀法散落。這個要求被完整落地。

## §1防crank命門——逐條親驗

**①禁刪真走**：親讀diff，`event_faction_defect.gd`的`execute()`函式完全沒出現在diff裡（改動只在`check()`）——`clear_team_faction`這行原封不動。`_evaluate_uprising`的Path B（流亡）也完全沒出現在diff裡——只有Path A（守城）被改成有條件判斷。走的一側（defect exit/流亡exit）確認保留、沒被焊死。

**②禁boost逼留**：`_faction_stay_benefit`公式`(W_RELIEF×relief_mem + W_REP×heard_rep) × pmod`——`relief_mem`讀真實`_benefactor_strength`（自己memory裡type=="benefactor"筆數飽和）、`heard_rep`讀真實`known_reputations`——不是一個憑空的忠誠加成常數，是兩個真實機制的組合，人格只modulate（`pmod=0.5+(honor+trust)*0.5`，範圍[0.5,1.5]，非直接乘出天文數字）。無配額指標，親讀量測段確認。

**③零god-view**：`test④`(`_test_zero_godview`)親讀確認是adversarial測試——竄改**領主的live population**（`AnonCohort.add(...999)`）跟**另一個人的memory**（模擬god-view式全知統計）後，assert`stay_benefit`完全不變。這代表函式真的只讀`leader`自己的`memory`陣列跟自己`team.known_reputations`，不會被別處的動態真實狀態污染，跟本session一路要求的adversarial驗證風格一致。

**④defect_util連續**：親讀diff hunk範圍——`@@ -11,9 +11,18 @@`起點在原檔第11行（`var leader = state.persons.get(...)`），這代表原檔第9-10行的`if team.unrest_turns < DEFECT_UNREST_THRESHOLD: return false`precondition**在這個diff hunk之外、完全沒被觸碰**，跟spec承諾的「保unrest>=20不動」一致。新公式`defect_util = distress_pressure*loyalty_deficit - stay_benefit`親讀確認是連續值運算，`fire if defect_util>0`取代了原本的`honor<0.35 or trust<0.35`布林比較。

**⑤三決策點整併**：見上方「必查項」段落，確認為真。

## test①（命門）——嚴格controlled-variable實驗，這是我看過這個session裡設計最紮實的分化測試之一
親讀`_test_defect_differentiation`：`saved`跟`neglected`兩個member**honor/trust/unrest完全相同**（0.2/0.2/25），**唯一變數**是`benefactor_n`（3 vs 0）跟`lord_rep`（0.8 vs 0.5）——assert被救過的不defect、沒被救的defect。這種「鎖死其他變數只變一個」的實驗設計，直接證明是`stay_benefit`這個新機制造成分化，而非其他因素巧合造成——這是對「genuine分化、非honor cliff」這個核心claim最有說服力的驗證方式，非空泛斷言。

## test③——真實settle路徑integration test，非mock
`_test_benefactor_write`直接建構porter/resident/tile完整場景，呼叫真實的`InteractionSystem.new()._market_visitor_sell(...)`（`override_ask=0.0`免費直注路徑，這條路我在前幾輪distribute免費直注relief已經完整審過），驗證跑完整條settle路徑後resident leader真的拿到benefactor memory——這是integration-level驗證，非只測`write_memory`呼叫本身。

## 輕量觀察（非阻塞）

**test⑤方法論較弱**：`_test_uprising_consequence`的comment自己寫明「純算術驗決策式(不觸完整`_evaluate_uprising`)」——測試是在test檔案裡重新手動打一次`stay_u`/`secede_u`公式，非直接呼叫`_evaluate_uprising`本身。我親自逐項核對這輪test裡用的常數（`0.9×0.5`/`0.5×0.6+(1-0.9)×0.4`）跟diff裡`_evaluate_uprising`真實公式（`secede_u = ambition*0.6+(1.0-honor)*0.4`/`stay_u = honor*0.5+_faction_stay_benefit(...)`）**完全一致**、這次沒有漂移。但這種「重算公式比對」的測試寫法，未來如果有人改了`_evaluate_uprising`裡的真實公式而忘記同步改test，測試依然會綠燈（因為它驗證的是自己重打的副本非原函式）——比較理想是讓測試真的呼叫`_evaluate_uprising`並讀tap驗證。記錄給implementer/systems參考，非阻塞這次merge。

**calibration `COHESION_RELIEF_SAT=3.0`**：這個「被救3次忠誠飽和」的常數不是從既有常數DERIVED（不像L3那輪`MARKET_ARB_NORM`直接抄`DELIVER_PAYOFF_NORM`），是這次新設計的飽和曲線參數，comment有交代理由（「重複被救忠誠飽和」邊際遞減概念）——非隨口捏造但也非嚴格錨定，屬於這個session一路要求的calibration追蹤項，非阻塞。

## P3立國查根——結果印證上輪追的卡點，範圍歸類正確
commit message「★立國goal查根結果：『立國』goal token從未被emit（無`_emit_goal(...,"立國")`caller；consume`:1820`+erase`:4501`皆orphaned）」——這正是我上輪R①追到`_declare_established`只在`"立國" in f.goals`才觸發、真正卡點更早的那條線索的答案：根本沒有emit點，整條路從頭到尾orphan。歸類「立國/正統arc legitimacy」記檔非本arc順修，這個範圍判斷合理——這確實是一個比「調一下assign條件」大得多的坑（涉及正統/王朝arc的WHAT層決定），不該塞進這次cohesion arc。

## 判決
**CLEAN → measurer量分化（好vs爛領主壽命+該散照散、無配額）→ QA故事稽核 → 用戶。** 上輪必查項親讀diff確認真落地；§1防crank五條逐一核對到具體diff/test內容；test①的controlled-variable設計是這輪最值得肯定的地方。兩個輕量觀察（test⑤方法論/calibration常數來源）記錄供參考，皆非阻塞。地基KEEP。
