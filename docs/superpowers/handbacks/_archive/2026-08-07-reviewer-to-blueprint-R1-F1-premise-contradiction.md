---
from: reviewer
to: blueprint
status: consumed
topic: "[R①判決=premise_contradiction(halt)，非CLEAN] F1人格化spec——親驗3靶citation,發現2/3靶指向錯誤或死亡code非blueprint要求confirm的那1項而已:★靶①(_evaluate_survival DESPERATION-entry人格化):親讀_evaluate_survival完整函式範圍(faction_ai_system.gd:3974-4535)全文搜尋DESPERATION_DAYS=零命中——這個函式根本沒有用到這個常數;更進一步親讀函式開頭:3995-3996『if uses_unified(team) or team.parent_team_id==-1: return #unified任隊/非子隊→求生走引擎(DecisionEngine);舊系統不雙觸發』——這代表對於已經走統一決策框架的team(本session整個資訊網/凝聚力/復甦arc都在餵這個統一引擎,理論上是絕大多數team)_evaluate_survival直接return什麼都不做,是legacy/近乎死亡的fallback code;真正在跑的DESPERATION_DAYS entry-gate其實散落在options.gd的多個applicable()(親grep到:89/141/172/182/252/268/284共7處)——若HOW照spec字面去改_evaluate_survival,改的會是death code,對統一引擎下的絕大多數team零實際效果,這正是本session recovery-r1已經抓過一次的『false confidence』同款risk;★靶②(_evaluate_uprising is_military硬persona-gate):親讀_evaluate_uprising完整函式(4535起)確認裡面沒有is_military這個變數,全域grep is_military只有一處命中在establish_crude_camp(:4083-4094,決定緊急紮營立起的outpost是military還civilian類型,雖被_evaluate_survival的TASK_CAMP分支呼叫但這是『立營型態分類』非『能不能起義』,是完全不同的兩個決策)——spec的WHAT敘述(硬persona-gate卡整段起義能力)描述的是一個不存在的機制;真正的_evaluate_uprising本身(我在勢力凝聚力arc那幾輪已經逐行審過)用的是avg_loy/unrest_turns/stress_sources前置門+ambition/prudence/honor/survival連續加權的stand/flee分數,早就是genuine連續秤非硬persona-gate,這輪spec想動的東西早就已經是好的;★靶③(_evaluate_new_outpost_location MINING_GREED_THRESHOLD)——這一個親驗坐實無誤,`(貪婪+野心)>=1.1`真的是硬persona-gate(faction_ai_system.gd:3467-3494),spec對這靶的描述精準;結論=blueprint要求我confirm的『靶①物理錨分離』這個問題本身連問都問錯了地方(因為靶①引用的函式根本不含DESPERATION_DAYS),而『免R①』的靶②實際上引用了一個不存在的機制、真正該檢查的_evaluate_uprising本身早就是genuine非硬gate——這不是『判準已定不用查』能跳過的東西,是citation本身錯了;唯一乾淨的是靶③;判決=premise_contradiction(halt)非CLEAN,要求systems重新audit靶①②的真實code位置(靶①=改options.gd裡7處applicable()還是統一引擎某處更上游的survival option?靶②=是否其實沒有真正對應的『起義硬gate』,這個靶該砍掉還是改指establish_crude_camp的is_military這個不同性質的決策?)"
---

# R①判決：F1人格化spec — premise_contradiction（halt），非CLEAN

## blueprint要求的窄範圍——我照做，但發現問題不只在那一項
blueprint這輪只要求我confirm一項（靶①的物理錨分離），靶②③因為WHAT judgment已定而免R①。我照這個範圍去查，但查靶①的過程中直接發現靶①的file:line citation本身有問題，連帶讓我往下也查了靶②③的citation正確性——結果是2/3靶的citation跟現實code對不上。這不是「憲法A判準要不要成立」這種WHAT層級的問題（那確實已經定案），是「這個靶指的到底是哪段code」這種事實層級的問題，屬於R①該抓的範疇。

## ★靶①——引用的函式根本不含這個常數，且很可能是死code
親讀`_evaluate_survival`完整函式（`faction_ai_system.gd:3974-4535`）全文搜尋`DESPERATION_DAYS`——**零命中**。這個函式根本沒有用到spec聲稱要人格化的那個常數。

更進一步，親讀函式開頭`:3995-3996`：

```
if uses_unified(team) or team.parent_team_id == -1:
	return   # unified 任隊 / 非子隊 → 求生走引擎(DecisionEngine);舊系統不雙觸發
```

這代表對於任何已經走**統一決策框架**的team——而本session整個資訊網/勢力凝聚力/復甦路徑arc從頭到尾都在往這個統一引擎裡餵功能，理論上現在絕大多數team都是「unified」——`_evaluate_survival`直接`return`、什麼都不做。這是**legacy/近乎死亡的fallback**，只服務極少數non-unified的邊緣case。

真正在跑、決定「絕境要不要進」的DESPERATION_DAYS entry-gate，其實散落在`options.gd`的多個`applicable()`（親grep確認7處：`:89/141/172/182/252/268/284`）。**如果HOW照spec字面去改`_evaluate_survival`，改的會是死code，對統一引擎下的絕大多數team零實際效果**——這正是本session`recovery-r1`已經真實發生過一次的「false confidence」同款風險（候選/決策生成看似改了，實際執行端零效果）。

## ★靶②——`is_military`根本不在`_evaluate_uprising`裡，那是另一個決策
親讀`_evaluate_uprising`完整函式（`:4535`起）確認裡面**沒有`is_military`這個變數**。全域grep`is_military`整個檔案**只有一處命中**——在`establish_crude_camp`（`:4083-4094`），這個函式是「緊急紮營立outpost時決定型態是military還civilian」，雖然會被`_evaluate_survival`的`TASK_CAMP`分支呼叫，但這是**「立營型態分類」**，跟spec描述的**「能不能起義」**是完全不同的兩個決策，只是剛好變數名字撞了、都用`martial>0.6 or ambition>0.7`這個形狀的門檻。spec的WHAT敘述「硬persona-gate卡整段起義能力」描述的是一個**不存在的機制**。

而`_evaluate_uprising`本身——我在勢力凝聚力arc那幾輪已經逐行審過（`avg_loy`/`unrest_turns`/`stress_sources`前置門+`ambition`/`prudence`/`honor`/`survival`連續加權的`stand_score`/`flee_score`）——早就是**genuine連續秤**，不是硬persona-gate，這輪spec想「de-patch」的東西根本已經是好的，不需要再動。

## 靶③——親驗坐實無誤
`_evaluate_new_outpost_location`的`is_greedy_leader = (貪婪+野心) >= MINING_GREED_THRESHOLD(1.1)`（`faction_ai_system.gd:3467-3494`）親讀確認精準——這是真的硬persona-gate，spec對這一靶的描述跟現實code完全對得上。

## 判決
**premise_contradiction（halt），非CLEAN。** blueprint要求我confirm的「靶①物理錨分離」這個問題本身問錯了地方——靶①引用的函式根本不含`DESPERATION_DAYS`；「免R①」的靶②引用了一個實際上不存在（或者說，引用錯了函式）的機制，真正該檢查的`_evaluate_uprising`本身早就是genuine。這不是「判準已經定案所以可以跳過查」能規避的問題，是citation本身錯了，HOW階段不能拿著錯的地址去蓋房子。

**要求**：systems重新audit靶①②的真實code位置——
1. 靶①：真正要人格化的DESPERATION_DAYS entry-gate是`options.gd`裡那7處`applicable()`（還是統一引擎更上游、決定要不要把「絕境」這個信號送進去的某處）？`_evaluate_survival`這個citation要撤換。
2. 靶②：是否其實**沒有**一個真正對應「起義硬gate」的機制存在（`_evaluate_uprising`本身已經genuine）？如果沒有，這個靶該從F1砍掉；如果blueprint認為`establish_crude_camp`的`is_military`（性質完全不同：立營型態分類）也值得比照憲法A處理，那需要重新寫WHAT描述、非沿用「起義能力被排除」這個錯誤敘述。

靶③維持乾淨，不受影響。
