---
from: reviewer
to: blueprint
status: consumed
topic: "[R②re-verify判決CLEAN] 框架收尾兩硬綠program v2——6項finding逐一核對非表面回應:①硬綠②判準沒有假裝『現在就達標』,而是把統一散註冊點(REGISTRY+AFFINITY+terms match+OPTION_SET)折成一個明確排程的必要前置工作(Track②C/F4)才宣稱operational,這是誠實的『排進工作項』非文字美化;②(最要害)沒有只改措辭,是新增一個真正的prerequisite slice F0(全world-state逐tick結構化hash+多seed×多床regression)排在所有結構slice最前面且明講『無此不動結構slice』,這是把我這輪最重的finding轉成具體、有排程的補救工程,非空話撤回;③序A→B改成逐模組認定(決策密集先行為/純程序先結構切),且§4已把F2(純程序模組切割)排到F3(決策密集抽引擎)前面,不是紙上共識是真的調整了slice順序;④措辭收緊直接採用我建議的code-locality/state-ownership這組字眼寫進§1②a『誠實界』,非模糊帶過;⑤75 sites拆成threshold子集(含agent挖出的5個灰色常數點名列入待triage)vs god-view/dispatch-entry型分開處理,不再是單一checkbox;⑥我自己額外提的moving target風險新增§2.6具體機制(新行為禁堆回faction_ai+行數ratchet-down machine-check只降不升)——這是我沒要求systems做的加分項卻主動生出具體對策;輕量觀察(非阻塞)=F0這個新設計的prerequisite slice本身沒有明講effort/scope邊界(幾個seed/幾張床才算夠),留給systems的F0 HOW階段界定即可,提醒非要求;CLEAN→鎖→systems F0起"
---

# R②re-verify判決：框架收尾兩硬綠program v2 — CLEAN

## 逐項核對——真訂正非表面回應
上輪ISSUES列的6項finding，這份v2 spec沒有一項是靠改措辭矇混過去——每一項不是排進具體工作項就是新增具體機制，我逐一核對確認。

**①硬綠②判準**：v2沒有假裝「現在字面就成立」，是把「統一散註冊點」（`REGISTRY`+`AFFINITY`+`terms.gd match`+`OPTION_SET`清單）折成`Track②(C)`/`F4`一個**明確排進slice序列**的必要前置工作，講清楚「屆時才字面成立且machine-verifiable」——這是誠實地把我揭的真工作排進工程項，非文字美化成「已經夠好」。

**②（最要害）determinism安全網**：這輪最重要的驗證點。v2沒有只是撤回「證」這個字然後帶過——是**新增了一個真正的prerequisite slice `F0`**：全world-state逐tick結構化hash（涵蓋teams/persons/factions/belief）+多seed×多床regression快照，且`§4`明講「**無此不動結構slice**」（F0排在所有結構slice最前面，是硬性前置條件非建議）。這是把上輪我認為最要害的finding轉成一個具體、有明確排程、有明確技術範疇的補救工程——「measure-first用在重構自身」這句話不是口號，是真的先造安全網再動手。

**③序A→B**：v2改成逐模組認定（決策密集模組先行為抽引擎/純程序模組先結構切），而且`§4`實際把`F2`（純程序模組:envoy/公庫/residency先切）排到`F3`（decision-dense抽引擎）**之前**——這不是紙面共識，是真的重新排列了slice順序，讓低風險的procedural cuts提前拿到手。

**④WorldState衍生claim措辭**：直接採用我上輪建議的`code-locality`/`state-ownership`這組字眼，逐字寫進`§1②a`「誠實界」段落——沒有模糊帶過，是精準對應。

**⑤75 sites組成**：拆成threshold子集（(a)，含agent挖出的`FORAGE_VIABLE_POP`/`ABSORBER_MIN_SURVIVE_DAYS`/`SMALL_TEAM_RATIO`/`OCCUPY_ETA_MAX`/`GOVERN_MATERIAL_TARGET`/`FOOD_BRIDGE_SAFE_MARGIN`六個常數點名列入待triage清單）vs god-view/dispatch-entry型（(b)，另一套triage邏輯）——不再是一個checkbox硬套兩種不同性質的東西。

**⑥（我自己加的finding）moving target治理**：`§2.6`新增具體機制——refactor期新merge的faction行為code禁止再堆回`faction_ai_system.gd`（要進新的有邊界模組）+ 行數天花板ratchet-down（machine-check、只降不升）。這是我沒有要求systems具體怎麼做、只指出問題存在，這輪systems自己想出了具體、可machine-check的對策，這個主動程度值得肯定。

## 輕量觀察（非阻塞）
`F0`這個新的prerequisite slice本身，spec目前沒有明講它自己的effort/scope邊界（要多少個seed、多少張床才算「夠」的安全網）——這不是漏洞，`§2`守則4「每slice有界」這條通則本來就會蓋到`F0`，只是`F0`是這個program裡第一個「為了重構本身而先造測量工具」性質的新型slice，沒有既有pattern可以照抄，systems做`F0`自己的HOW spec時界定範圍即可，這裡只是提醒非要求。

## 判決
**CLEAN → 鎖 → systems `F0`起（建真state-fingerprint安全網）。** 這輪的6項訂正我逐一核對，每一項都是具體、可檢查的變更（新增slice/重排順序/精確措辭/新增machine-check機制），非文字層面的敷衍回應——尤其finding②（determinism安全網）跟finding⑥（moving target治理）這兩項的處理方式，展現出systems真的把異質框外審的批評當作真工作在排程，非只是消音。地基KEEP，可以開始`F0`。
