---
from: measurer
to: blueprint
status: open
topic: main HEAD代表隊完整3mo fidelity trace(Team6)——★整體判讀:像構想,連貫/遇險合理反應/危機內同需求換策略皆有實例；仍有怪點：紮營時覓食util(1.00)明顯高於紮營(0.68)卻選紮營(疑似防衛hold模式下覓食target暫不可達,非bug是威脅期合理避戰行為，但值得你/用戶親眼判斷是否符合直覺)
---

# 量測回報：main HEAD 代表隊完整 3mo fidelity trace（質化，非數字）

工單：`2026-07-13-systems-to-measurer-main-fidelity-trace.md`。**main HEAD = `4b40b79`**（今日決策引擎重構完整鏈全部merged：S1五層急迫度/S2 coeff+phase退役/normalize T1-T5/cadence T-cad1-2/survival-path/same-need-fallthrough）。

## 選隊
**Team6**（獨立隊，非owner），population軌跡`[8,8,8,11]`（月3成長至11，非純穩定也非死亡——有故事但存活茁壯，波折幅度3）。全程`intent=防衛`（慎重/威脅驅動，"備戰守土"）——這支隊從頭到尾自我定位是防衛姿態，非致富/擴張型。90天內`decision_count=1712`（cadence機制頻繁重評，符合本輪已知的重評頻率現象）。

## 時間軸（節選代表性片段）

**day1（tick10）—開局，食足，日常覓食**
```
intent=防衛(慎重/威脅驅動,備戰守土)
winner=覓食 task=覓食
candidates: 覓食0.47 > 備戰0.28 > 迎戰0.19 > 建設0.11 > 求和0.10 > survival0.00
狀態: pop=8 food=179.7(食足) coin=8
```
→ 食物充裕，覓食平順dispatch，日常經濟活動。

**day~23（tick5540）—持續覓食期，逐漸累積**
```
winner=覓食 task=覓食
candidates: 覓食0.90 > 建設0.33 > 備戰0.32 > 迎戰0.19 > 求和0.12 > 吸納0.11 > survival0.00
beliefs: [對鄰隊Team10的觀察: population≈10, current_task=覓食, armed=1]
狀態: pop=8 food仍充足
```
→ 開始有belief（對鄰隊觀察）出現，隊伍持續覓食累積，同時對周遭環境保持警覺（防衛intent的why持續是「慎重/威脅驅動」）。

**day26（tick6200-6330）—★轉折：改紮營，非覓食**
```
winner=紮營 task=紮營 tgt=(15,7)（連續13次决策皆選紮營，非覓食）
candidates: 覓食1.00 > 紮營0.68 > 買糧0.30   ← 覓食util明明更高
狀態: pop=8 food=19.0→18.0(緩降，非危急)
```
→ **★怪點所在**：覓食(1.00)明顯高於紮營(0.68)，理論上argmax該選覓食，但連續13次選了紮營。這符合本session稍早診斷的「同需求fallthrough」機制——**紮營也在PASSIVE_SURVIVAL_SET裡**（implementer的same-need-fallthrough修法涵蓋），推測是覓食在當下位置暫時不可dispatch（可能因為所在(15,7)附近wild_game枯竭或威脅阻擋移動），fallthrough落到同組的紮營而非亂跳到不相關option——**機制上是「對」的（同需求類內轉移，非落到生產這種不相關選項），但行為上看起來「該覓食卻窩著不動」，直覺上略怪**，是否構想上期待「威脅期就地固守優先於覓食」需你/用戶親眼判斷是否符合預期。

**day90（tick21600）—月尾，成長茁壯**
```
winner=覓食 task=覓食
candidates: 覓食0.77 > 生產0.49 > 建設0.34 > 備戰0.32 > 駐守0.31 > 求和0.12 > survival0.00
狀態: pop=11(成長!) food(priv=96/gran=59.3/eff=155.3,食足有餘) coin=5 mat=45
```
→ 回到常態覓食+生產經濟活動，population從8成長到11，糧倉(gran=59.3)開始累積盈餘，物資(mat=45)也累積，是健康成長軌跡的收尾。

## ★我的判讀（誠實，像就說像，怪就指出）

**像構想的地方**：
1. **需求驅動可辨識**：開局食足→日常覓食生產；威脅期→防衛姿態+就地固守（紮營）；危機過後→回常態經濟並成長——整體弧線讀得出「日常→謹慎防備→成長」的故事。
2. **不再有前幾輪發現的病態**：全程`survival`option util恆0.00（食足無威脅時不再spurious FLEE，這是今天survival-path修法的直接成果）；覓食失敗時fallthrough落在同需求組（紮營、非生產這種不相關選項），機制上正確。
3. **belief/觀察痕跡**：能看到隊伍對鄰隊的belief快照（population/task/武裝估計），有「認知」的味道，非純機械。

**還怪的地方**：
1. **威脅期優先序倒掛**：day26片段裡覓食util(1.00)>紮營(0.68)，理論上該選覓食卻連續13次選紮營——是fallthrough機制運作（覓食暫不可dispatch），但從**旁觀者視角看，這隊「明明想覓食卻窩著不動」，沒有explicit的「因為威脅所以放棄覓食改防守」的敘事線索**（candidates只顯示util數字，沒有威脅來源/等級的直接展示），故事的因果沒有完全講清楚，需要懂內部機制才看得出「為什麼」。
2. **90天1712次決策**（cadence觸發頻率仍偏高，前幾輪已回報過，非本輪新發現，但仍是「決策頻率是否符合直覺」的開放問題——人類看故事通常期待「發生了什麼事才做決定」，非每隔幾tick就重算一次。

## 產物
`tools/orchestrator/runs/main_story_trace.txt`（Team6完整trace，main HEAD 4b40b79）。

## 待你（轉用戶）
整體方向是「像」的（需求驅動+不再spurious逃跑+同需求換策略機制對），但威脅期「為何不覓食改紮營」的因果對玩家/觀察者而言不夠直白，這是否要緊，交你/用戶判斷。
