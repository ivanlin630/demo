---
from: reviewer
to: blueprint
status: consumed
topic: "[R①判決CLEAN+1補充發現] 勢力凝聚力spec前提——P1親驗坐實:event_faction_defect.gd:4/16確認DEFECT_HONOR_THRESHOLD=0.35真是硬布林門檻(check()函式回傳honor<0.35 or trust<0.35,零util weighing);P2親驗坐實:faction_ai_system.gd:4571/4577兩條uprising結局路徑(守城/流亡)皆unconditional呼state.clear_team_faction(team),零讀任何後果變數;P3親驗坐實且往下多追一層:_declare_established(:4498-4510)只在:1820『if「立國」in f.goals』才會被呼,真正卡點比spec引用的g2.faction_found更早一步——是f.goals何時真的被賦予「立國」這個目標,這條線索交給systems HOW階段查根;★P4(重點驗)親驗坐實非誇大:_evaluate_uprising(:4535-4553)完整讀過,前段avg_loy/unrest_turns/stress_sources三道硬門檻+後段stand_score/flee_score只讀ambition/prudence/honor/survival四項人格值,從頭到尾零relief/labor/distribute訊號讀取,defect的check()同樣零讀取,P4『留vs走決策不讀真好處』成立非誇大;★意外發現:_evaluate_uprising自己藏了三道spec P1沒提到的額外死常數門檻(avg_loy>=0.2/unrest_turns<60/stress_sources<2),範圍比P1單獨引用的DEFECT_HONOR_THRESHOLD更大,要求HOW階段『拆死常數出口』的刀口把這三道也納入考量非只拆義氣/信義那組;CLEAN→等exit-attribution量測一起鎖spec"
---

# R①判決：勢力凝聚力前提(P1-P4) — CLEAN + 1補充發現

## P1——親驗坐實
親讀`event_faction_defect.gd:1-16`：`DEFECT_HONOR_THRESHOLD: float = 0.35`(:4)、`check()`函式(:6-16)——`unrest_turns<20`前濾後，直接`return honor < DEFECT_HONOR_THRESHOLD or trust < DEFECT_HONOR_THRESHOLD`。這是一個**純布林門檻函式**，回傳值就是這個比較式本身，沒有任何util weighing、沒有連續值進rank——「叛離死門檻」這個定性精準，非誇大。

## P2——親驗坐實
親讀`faction_ai_system.gd:4569-4581`：`stand`(守城)分支`:4571`跟`flee`(流亡)分支`:4577`都是`state.clear_team_faction(team)`一行、**無條件執行**、前後沒有任何if判斷或util比較會影響這一步是否發生。起義的兩種結局路徑（守城/流亡）都會讓team脫離faction，不管當下的人格/情勢是否支持「換領主但留在勢力」這個選項——「起義後果無條件清、無秤」這個定性坐實。

## P3——親驗坐實，且往下多追一層卡點
親讀`:4498-4510`（`_declare_established`）+`:1820-1821`（唯一呼叫點）：`_declare_established`只在`if "立國" in f.goals:`這個條件成立時才會被呼叫、`Probe.bump("g2.faction_found")`在函式最後一行——這代表`g2.faction_found`永遠不會fire的真正機制是**這個faction的`goals`陣列裡從沒出現過「立國」這個字串**。spec引用`g2.faction_found=0`是對的，但我往下多追了一層：真正該查的根不是「`_declare_established`函式邏輯有沒有bug」，是「什麼條件下`f.goals`會被塞進「立國」」——這條線索比spec原本點名的位置更精確一點，交給systems HOW階段「查根」時可以省一步。

## ★P4（重點驗）——親驗坐實，非誇大
這是這輪最重要的查核點——「留vs走決策入口有沒有讀任何benefit信號」。我完整讀過`_evaluate_uprising`(`:4535-4553`)全函式：前段三道硬門檻(`avg_loy>=0.2`/`unrest_turns<60`/`_count_stress_sources<2`全是`return`提前退出)、後段`stand_score`/`flee_score`只讀`leader.values.get("野心"/"慎重"/"義氣"/"求生欲")`四個人格值——**從頭到尾沒有出現任何`relief`/`labor`/`distribute`/`convoy`/`benefit`相關的讀取**。`event_faction_defect.check()`同樣只讀`unrest_turns`+兩個人格值。P4「真好處存在但留走決策不讀這些」成立，非誇大——如果這條決策鏈裡藏著某個我沒看到的benefit讀取，這輪R①就該halt要求spec刀口重寫，但沒有找到，P4站得住。

## ★意外發現——`_evaluate_uprising`自己藏了三道spec沒提到的死常數門檻
親讀`:4539-4542`確認`avg_loy>=0.2`/`unrest_turns<60`/`_count_stress_sources(state,team)<2`三個提前`return`——這些**都是spec P1沒有引用到的額外死常數門檻**（spec P1只點名`event_faction_defect.gd`的`DEFECT_HONOR_THRESHOLD`）。「起義」這條路本身在真正走到`stand_score`/`flee_score`這個（目前已經算genuine的）人格weighing之前，要先通過三道硬布林篩選——這代表「拆死常數出口」這個主刀如果只拆`DEFECT_HONOR_THRESHOLD`跟起義後的`state.clear_team_faction`，會漏掉起義**要不要發生**這一關的三道閘。

**要求**：HOW階段的「拆死常數出口」範圍應該一併考慮這三道門檻是否也要秤入util（例如`avg_loy`/`unrest_turns`/`stress_sources`本身可以連續進util而非硬gate、或至少明確交代為什麼這三道保留為前置篩選是合理的（例如「純粹的可執行性檢查/look-before-leap」而非「留走傾向」本身）。這不是premise錯誤，是給HOW設計範圍的補充情報。

## 判決
**CLEAN + 1補充發現（起義觸發前三道額外死常數門檻，供HOW階段刀口參考）→ 等exit-attribution量測一起鎖spec → systems R②。** P1-P4皆親驗坐實，P4這個「重點驗」項目我完整讀過兩個決策入口的全函式非只挑幾行，確認零benefit信號讀取；P3多追一層卡點；意外發現的三道額外門檻不影響CLEAN判決，是给後續HOW設計的加值情報。
