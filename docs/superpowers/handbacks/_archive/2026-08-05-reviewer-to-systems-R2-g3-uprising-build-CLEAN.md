---
from: reviewer
to: systems
status: consumed
topic: "[R②merge-gate CLEAN] g3 bond counter+uprising faction_id gate(03f03ce4+00a40775)——★特別驗獨立完成:針對concurrent revert scare,沒有只看git show某commit的歷史diff(那可能被後續commit undo仍顯示曾經改過),改用git show feat/faction-cohesion:<path>直接讀branch HEAD當下live內容——確認diplomatic_ai_system.gd HEAD版本driver -= FactionAISystem.new()._faction_stay_benefit(state,self_team)真的在那裡(帶完整comment非殘留孤行)、faction_ai_system.gd HEAD版本_evaluate_uprising第一行真的是if team.faction_id==-1:return——兩處都是這次獨立重新從branch尖端撈出來讀到的,非採信systems『親驗確認』的自我陳述;bond counter diff(03f03ce4)親讀確認只加6行(diplomatic_ai_system.gd)+新測試檔g3_betrayal_bond_test.gd,driver計算後插入純算術減項零新randf;test①用真實betrayal_assessment端到端呼叫(非重算公式,比上輪uprising test⑤方法論更紮實)驗證同personality+同盟弱只變relief history產生不同背叛結果;test②③④分別驗genuine opportunism保留/共享helper間接證/零god-view adversarial;uprising gate(00a40775)親讀確認精準鏡射defect gate結構(faction_id==-1提前return),清independent隊空觸發cascade副作用,純加一行零改動既有uprising決策邏輯;§1雙向/零god-view/genuine opportunism/determinism皆親驗坐實;re-measure改床(g3驗在betrayal-fires床/③下游解鎖驗在established-factions床)是誠實的量測方法論調整非code問題非我這輪要驗證的範圍;CLEAN→measurer re-measure→QA→merge"
---

# R②merge-gate判決：g3 bond counter + uprising faction_id gate（03f03ce4+00a40775）— CLEAN

## ★特別驗——針對concurrent revert scare獨立重新確認，非採信自我陳述
systems這輪特別標註「diplomatic_ai counter被linter/concurrent revert一次、已re-apply」並要求我獨立再驗。我沒有只跑`git show 03f03ce4`看歷史diff（那只能證明「這個commit當初改過這一行」，證不了「現在HEAD上還在不在」——如果後面有任何commit把它revert回去，歷史diff依然會顯示曾經改過，不會告訴你現狀）。改用`git show feat/faction-cohesion:<path>`**直接讀branch尖端當下的live檔案內容**：

- `diplomatic_ai_system.gd`（HEAD）：確認`driver -= FactionAISystem.new()._faction_stay_benefit(state, self_team)`這行**真的在那裡**，前面完整的4行comment（`★cohesion g3延伸`/`忠的被救的...`/`★共享同一_faction_stay_benefit`/`零god-view...`）也都在，不是一行孤零零殘留、周邊脈絡完整。
- `faction_ai_system.gd`（HEAD）：確認`_evaluate_uprising`函式**第一行**就是`if team.faction_id == -1: return   # ★cheap-win：...`，這是我這次獨立重新從branch尖端撈出來親眼確認的，非採信systems的「親驗確認」自我陳述。

兩處都真的landed，沒有被revert掉。這個確認方式（讀live HEAD內容非歷史diff）正是應對「commit曾經做對、但後續被覆蓋」這種風險該用的驗證手法。

## bond counter（03f03ce4）——親讀diff+HEAD雙重確認
diff本身只有6行新增（`diplomatic_ai_system.gd`）+新測試檔`g3_betrayal_bond_test.gd`（76行）——改動面精確對應spec範圍，沒有夾帶額外改動。`driver`計算後插入`driver -= _faction_stay_benefit(...)`一行純算術減項，零新RNG。

`g3_betrayal_bond_test.gd`親讀完整4案：test①(命門)這次用**真實`DiplomaticAiSystem.new().betrayal_assessment(...)`端到端呼叫**（非上輪uprising test⑤那種在test檔案裡重算一次公式的較弱寫法）——同personality(野心0.6/信義0.4/義氣0.5)+同盟弱情境，只變relief history/reputation，被救的不叛、沒被救的叛。這比上輪的方法論更紮實，直接測真實函式而非副本公式。test②(genuine opportunism保留)/test④(零god-view竄改領主live population+他人memory後stay_benefit不變)都是紮實的adversarial設計。test③(共享helper)是間接證據（只確認`sb_fai>0`），單靠這個test不足以證明diplomatic_ai真的呼叫了同一個helper——但我這輪已經親讀HEAD原始碼直接確認`driver -= FactionAISystem.new()._faction_stay_benefit(...)`這行呼叫存在，比test③的間接推論更直接的證據已經到手。

## uprising cheap-win（00a40775）——親讀確認精準鏡射defect gate、低風險
`_evaluate_uprising`開頭新增`if team.faction_id == -1: return`——這是我上輪R①指出`_evaluate_uprising`藏著三道死常數門檻時，systems額外發現的第四個缺口（independent隊完全沒有faction可以起義，但原本函式沒有這個前置檢查，會空跑到`stand_score`/`flee_score`計算跟`鄰格PRODUCE team cascade fear`等副作用，對一個根本不屬於任何faction的隊毫無意義）。親讀確認這行插在函式**最開頭**、跟`event_faction_defect.check()`裡`if team.faction_id == -1: return false`（我在R①那輪讀過）結構完全對稱——這是修一個真實存在的邏輯漏洞（independent隊不該觸發uprising副作用），純加一行防禦性前置檢查，不改動任何既有uprising決策邏輯本身，風險極低。

## §1雙向/零god-view/genuine opportunism/determinism——親驗坐實
延續上輪HOW審查已經確認的formula/helper genuine性質，這輪只需確認「有沒有被正確接上」——親讀HEAD確認`_execute_betrayal`的`clear_team_faction`沒被這兩個commit碰過，`Probe.note("g3.betray_driver_post_bond", driver)`是新增的observability tap（全量暫態可觀測性加分，非要求項但值得肯定）。

## re-measure改床——誠實的量測方法論調整，非code問題
systems附註「g3.betrayal在rep床0 fire、③下游解鎖驗要改用measurer建的established-factions床、g3驗在betrayal-fires床、誠實標g3=通用修非rep床藥」——這是量測階段的床選擇調整，不是這輪R②要審的code正確性範圍，我沒有意見，交給measurer執行。

## 判決
**CLEAN → measurer re-measure（established床）→ QA → merge。** 這輪最重要的工作是針對「concurrent revert scare」做真正獨立的HEAD驗證（非採信自我陳述），確認兩處修法都真的landed在branch尖端；bond counter/uprising gate的code品質跟測試設計（尤其test①改用端到端真實函式呼叫）都比上一輪更紮實。地基KEEP。
