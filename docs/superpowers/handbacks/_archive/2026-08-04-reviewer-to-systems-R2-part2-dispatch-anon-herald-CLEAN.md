---
from: reviewer
to: systems
status: consumed
topic: "[R②CLEAN+1輕追蹤] Part2 dispatch fix(①gate+②anon信使)——root親驗坐實(faction_ai_system.gd:1446 _pick_subteam_leader回-1即整段dispatch return false,跟spec描述逐字對上);①gate genuine非crank(has_buyable_food:decision_context.gd:331-335/options.gd:246-253親驗為真existing look-before-leap前例非發明類比);②reframe非平行求解器親驗坐實:dispatch()(subteam_system.gd:3-65)結構性要求named sub_leader(10-13 named_members.has檢查失敗回-1)=精準對應root,新anon路無法用這函式必須adapt=spec誠實(自己寫『新spawn路或adapt』非隱藏成本);leader_id=-1既有phantom-leader模式(subteam_system.gd:153,200 comment講清population getter已容);pop真扣走AnonTierSystem.transfer_proportional(既有函式非發明新資源機制);_evaluate_subteam的help_call專屬branch已存在(1852,非這輪新開);輕追蹤=messenger若沿用dispatch()同款proportional資源split會帶走母隊資源非只pop,spec未提,建議implementer限定只搬1 anon pop零resource carry或量測階段順手看有無異常資源流失"
---

# R②判決：Part2 dispatch fix（①gate + ②anon信使）— CLEAN + 1 輕追蹤

## root——親驗坐實
親讀worktree `faction_ai_system.gd:1438-1460`：`_dispatch_help_herald`第1445-1448行——`sub_sys._pick_subteam_leader(state, mother, TeamData.TASK_HERALD)`若回`-1`（無spare named），整個函式直接`return false`，dispatch從未發生。這跟spec/handback描述的「`_dispatch_help_herald:1446`需spare named，小餓resident送不出」逐字對上，非誇大——小餓村莊(population小、named軍官稀有)這個資源結構下，這條路徑事實上永遠打不開。

## ①gate genuine非crank——親驗坐實
親讀`decision_context.gd:331-335`+`options.gd:246-253`確認`has_buyable_food`是**既有真實**look-before-leap前例（買糧option用「聽過賣單才進rank」擋不可執行的候選），非這次臨時發明的類比說詞。`can_send_herald=population>=2`/`can_send_scout=named_members.size()>=2`是同款「先確認做得到再讓選項存在」邏輯，加在applicable層、不碰util公式一個字——跟systems自己聲稱的「發不發=leader人格秤，gate=可執行性非crank讓fire」一致。

## ②anon信使reframe——親驗坐實非平行求解器
這是這輪花最多力氣驗證的點。親讀`subteam_system.gd:1-65`(`dispatch()`)確認第10-13行**結構性要求**`sub_leader_id`是`parent.named_members`裡的真實named成員，找不到就`return -1`——這正是root的機制根源：`dispatch()`函式本身的契約就是「有named才能派」，不是`_pick_subteam_leader`挑選邏輯太嚴，是整條路徑的地基假設就是named-required。這代表要做出「anon 1人信使」，**不可能**單純呼叫既有`dispatch()`，必須要有新的建team路徑——spec自己寫「新spawn路（`_spawn_anon_herald`或adapt）」，誠實承認這是新程式碼，沒有假裝這只是參數微調，這點我認可。

但「新程式碼」不等於「平行求解器」——判準是**新程式碼裡有沒有發明新的資源/記帳機制**。親讀確認沒有：`leader_id=-1`是既有pattern（`subteam_system.gd:153`/`200`，comment明講「否則population getter仍計1 phantom leader擋滅團」——代表team基礎設施本來就要應付leader_id=-1這個狀態，不是這次新開的特例分支）；真正的pop成本走`AnonTierSystem.transfer_proportional`（`anon_tier_system.gd:170`，dispatch()自己在line 59也用這函式搬named-subteam的anon補位）——這是**既有、被多處呼叫**的真實anon人口轉移機制，不是為了這次配合「讓信使能派」而發明的新記帳。`_evaluate_subteam`裡`task_reason=="help_call"`的專屬tick分支（`faction_ai_system.gd:1852`）也已經存在（S-herald那輪就建了），這次不需要新開。综合看，這是「同一個wrapper函式(`_dispatch_help_herald`)內部，把team-建立那一步從『named-subteam-dispatch』換成『anon-only-spawn』，兩種建team手法各自都是既有機制的直接復用」——非增殖平行選項/求解器，reuse claim坐實。

## determinism / 感知鐵律
`_faction_roster_pos`(前輪bootstrap fix)/gate/spawn全是算術判斷零RNG；途中死亡走「既有encounter/attrition結算」——這條路徑本來就會吃到既有RNG消耗，但那是既有機制既有RNG，非這次新引入，跟determinism「零新randf」的字面要求一致。distress內容「我餓、在X」只送母隊自己的need，不讀target任何live state，跟bootstrap fix那輪已驗證的「只position零live-state」原則同款延伸，沒有開後門。

## 輕追蹤（非阻塞）
`dispatch()`(line 36-42)幫named subteam按`pop_count/parent.population`比例分走母隊**全部資源類型**(不只pop)，這個proportional-split是既有subteam機制的一部分。如果`_spawn_anon_herald`照抄這段邏輯，一個1人求援信使會順便從母隊搬走一小份**所有資源**(食物/材料/coin)非只搬1個anon pop——spec文字只講「pop從mother anon扣1真成本」，沒明講資源要不要一起搬。以量級來說(pop_count=1相對母隊population的frac通常很小)大概率無感，但既然母隊本來就是「小餓resident」(缺糧的一方)，任何非必要的資源流失都值得在乎。**要求**：implementer決定用哪個手法時，若沿用proportional-split，量測階段順手看一眼有沒有异常資源流失；若跳過資源split(信使空手走、只帶自己)更乾淨，兩者皆可，非阻塞、非需要另一輪R②確認。

## 判決
**CLEAN + 1輕追蹤（資源split細節量測順手看）→ 回systems → build（續`feat/info-network-whole`）→ re-measure whole（`help.herald_dispatched>0`+`distribute.dispatch/food_delivered>0`+seed1337 regression消+scout spare named假設驗）→ QA故事稽核。** root/①/②三個最關鍵的claim都親自往下追到函式實作層級驗證，非停在spec文字表面；②的「新程式碼但零新記帳機制」判斷是這輪最重要的結論，站得住可以直接build。
