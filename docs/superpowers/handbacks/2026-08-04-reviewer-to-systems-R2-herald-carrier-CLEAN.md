---
from: reviewer
to: systems
status: consumed
topic: "[R②CLEAN] herald非team輕carrier+A③名冊full——★root B親驗到比diagnostic敘述更精確的機制證據:faction_ai_system.gd:786-787是唯一succession偵測點,對任何team.leader_id==-1無條件呼on_leader_death,event_system.gd:57-63確認無named時真的從匿名晉升新leader——這代表兩輪前建的anon-herald(leader_id=-1 phantom-leader設計)只要進full-sim就會被這個機制升級成真named,完全吃掉當初『信使不需named軍官』的設計意圖,B root比spec文字描述的還嚴重;親查faction_ai_system.gd:777-779發現beast_kind的單點exemption precedent(『野獸不進決策迴圈』)——親自比較過『比照beast加一行exemption』這條更便宜的路線,但herald需要免的系統是succession+cull+subteam-routing+combat-target四處而非一處,不像beast只需這一個迴圈內continue,de-team選擇比scatter四處exemption更站得住非blueprint武斷;reuse親驗:_deposit_help_need(faction_ai_system.gd:1486)/market_orders(order_system.gd既有board陣列)/_try_herald_side(1534,精準對上)皆真existing非新造;A③名冊full=既有_find_own_outpost同款position-only欄位讀取邏輯只是從『查一個team』廣化成『查全faction找最近』,同款risk profile;anon detach的1pop不需額外lifecycle追蹤(這codebase anon是cohort聚合計數非individual PersonData,detach=真sink cost非遺留孤兒record);CLEAN→build續feat/info-network-whole→re-measure on FACTION bed"
---

# R②判決：herald 非team輕carrier + A③名冊refine — CLEAN

## ★root B——親驗到比spec文字描述更精確、更嚴重的機制證據
這輪我沒有停在「diagnostic json講了什麼」，直接往下追succession機制的實際觸發點。親讀`faction_ai_system.gd:773-787`確認：**這是整個full-sim對`team.leader_id==-1`的唯一偵測點**（comment自己寫「唯一偵測點」）——`for tid in state.teams.keys()`每tick遍歷**所有**team，只要`leader_id==-1`就無條件呼叫`EventSystem.on_leader_death`。親讀`event_system.gd:31-63`確認這個函式的邏輯：先找named成員接班，找不到→**`PersonGenerator.generate_for_team(state, team, "member")`真的從匿名晉升一個新named leader**（"從匿名晉升新領袖"）。

這代表：兩輪前(`Part2 dispatch fix`)建的anon-herald——`leader_id=-1`的phantom-leader設計，本意是「信使不需要named軍官、就一個匿名跑腿」——**只要這個team真的活過一個full-sim tick，就會被這個succession安全網當成「leader失效的正常team」，自動晉升一個anon成named leader**。這完全吃掉了兩輪前那個設計的本意（省一個named軍官），比spec文字「on_leader_death promote 1-pop出throwaway named」聽起來還更精確——不是「偶爾」或「某些情況」，是**每個leader_id=-1的team每tick都會被這條路徑抓到**，B root的嚴重度是我自己往下讀code驗證到的，非照抄診斷描述。

## ★我主動比較過更便宜的替代方案——支持de-team而非只是接受blueprint裁定
既然要挑戰這個「整個team-ness模型都要拿掉」的大決定，我specifically去找有沒有更小範圍的修法。親讀`faction_ai_system.gd:777-779`確認codebase**已經有一個現成的exemption precedent**：`beast_kind != ""`的team在這個迴圈開頭直接`continue`，comment明講「野獸不進決策迴圈：不succession晉升領袖(leader_id=-1非「死領袖」)」——這證明「幫特定類型team加一條exemption跳過succession」這招在這個codebase不是禁忌，已經有人這樣做過。

但這條路線對herald不夠：spec/handback列出herald需要豁免的系統是**succession+cull+subteam-routing+combat-target**四處，不是只有這一個succession迴圈。beast只需要在**這一個**迴圈裡continue一次就夠（因為beast不參與cull/subteam-routing/combat-target的方式，可能本來就有各自獨立的豁免或本來就不會被那些系統誤傷——這點我沒有逐一查證每一處，但至少succession這裡是單點解決）。herald若比照beast做法，**至少要在四個不同系統各補一條`if task_reason=="help_call": continue`**——這才是真正的「補丁閘」味道（散在四處的特判），而非一次性的、乾淨的「這個東西本來就不是team」的模型修正。相較之下，「非team物件」是**一次性**把herald從所有這些系統的迭代範圍裡拿掉，非疊加四個豁免點。這個比較讓我認為de-team的選擇站得住，非我單純接受blueprint的裁定文字。

## reuse——親驗坐實非新平行機制
`_deposit_help_need`(`faction_ai_system.gd:1486-1501`)親讀確認完整存在、簽名`(state, origin_id, helper)`跟spec描述的直接deposit呼叫方式吻合。`market_orders`(`order_system.gd`多處，Part1看板relay建的既有tile board陣列)確認存在，可以直接reuse當作「領主不在座時留言在board」的目標容器。`_try_herald_side:1534`（上輪side-dispatch建的函式）親讀確認就是spec講的reframe對象，行號精準對上。三個reuse對象全部真實存在，非文字上聽起來像復用實則另起爐灶。

## A③名冊full——同款position-only風險，廣化範圍合理
`_resolve_help_target`要做的事是把「查一個特定team自己的outpost」(`_find_own_outpost`單team版)廣化成「查整個faction所有member的outpost，挑最近」——欄位讀取(`outpost_owner`/`outpost_level`/`faction_id`)完全同一組，跟bootstrap fix那輪已經驗證過的position-only、零live-state風險profile一致，只是掃描範圍從一個team擴大到faction全員。這個廣化直接對應「mobile-lord自己沒有outpost、但faction有座城」這個真實案例，邏輯上站得住。

## anon detach——不需要額外lifecycle追蹤
一開始我對「detach的1個anon person在letter物件裡沒有team home，會不會變成孤兒record/population計算漏洞」有疑慮，但這codebase的anon是**聚合計數模型**（非individual PersonData，見既有anon cohort架構——`AnonTierSystem.transfer_proportional`操作的是整數計數非物件）。spec文字「detach 1 pop（真成本、自限）」明確是**故意的sunk cost**（送信使=花掉1人力，非借出去之後要收回），不是遺留的孤兒記錄，這個疑慮排除。

## 感知鐵律/determinism
payload=origin自己的food買單snapshot(讀自己的need非target live state)、名冊target position-only、letter遍歷走`Array`(insertion-order deterministic)、攔截=物理co-location比對零RNG——全部跟前幾輪已經驗證過的模式一致，沒有新開後門。

## 判決
**CLEAN → 回systems → build（續`feat/info-network-whole`）→ re-measure on FACTION bed（症1端到端：letter抵seat deposit→領主聞→distribute fire[util 0.659已證]→糧真到resident）→ QA故事稽核。** 這輪對B root跟「有沒有更便宜替代方案」都往下追到具體code層級驗證，非停在spec/diagnostic文字表面；A③/reuse/anon-lifecycle三點也都親自排除了我自己想到的疑慮，非照單全收。
