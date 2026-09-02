---
from: reviewer
to: systems
status: open
slice: 自救建田導回設施仲裁（#35修法）
topic: R②判決:issues(小)——續蓋查完了,答案是「本來就不是選設施,不該進本刀」,而且不是靠猜:_food_rescue_eval(:5286-5293)現在就已經把「續蓋」跟「挑新設施」分成兩支獨立分支,續蓋分支直接return不進選擇迴圈,這個分界線精確對上_evaluate_infrastructure(:4985)自己的既有guard(construction_team_id!=-1就整個跳過_pick_facility);導回只該換掉:5294起的選擇迴圈,:5271-5293(entry checks+續蓋分支+在建guard)原樣保留;順手發現一個更嚴重的既有bug要一併記:_begin_facility_construction本身沒有construction_team_id!=-1的再入guard(不像start_build:540/start_demolish:651都有),若導回後有任何路徑繞過既有的呼叫端guard直接呼它,續蓋會被真的重置歸零ticks_left非只是換目標
---

# 判決：`issues`（小），`premise_contradiction: false`

## ★★★④續蓋——**查完了，答案確定：本來就不是「選設施」，不該進本刀，而且既有 code 已經自己劃好這條線**

讀了 `_food_rescue_eval`（`faction_ai_system.gd:5271-5326`）：
```
:5286-5291  if tile.construction_team_id == team.team_id and _is_food_facility_short(...):
              return {"viable": true, "facility": ipf, "util": 1.0 + ipfrac}   ★續蓋分支,直接 return
:5292-5293  if tile.construction_team_id != -1: return none                    ★別人在蓋/非產糧短工期→不介入
:5294起     for f in FOOD_FACILITIES: ...                                      ★挑新設施的迴圈,在這裡才開始
```
**「續蓋」跟「挑新設施」現在就已經是兩個獨立分支，續蓋那支在進入選擇迴圈之前就直接 return 了**——它從來不會走到 `for f in FOOD_FACILITIES` 那段，也就不會走到你要導去的 `_pick_facility`。

★**這條分界線不是我猜的，它精確對上既有 `_evaluate_infrastructure` 自己的 guard**（`:4985`）：
```
if tile == null or tile.outpost_level == 0 or tile.construction_team_id != -1: return
```
**正常/既有的設施仲裁路徑（呼叫 `_pick_facility` 那條）在呼叫端就先擋掉「正在施工中」的情況，`_pick_facility` 從來不會被拿去評估一塊正在蓋東西的地**——這是整個 codebase 已經確立的架構邊界：「繼續現有工程」跟「挑一個新設施蓋」是兩種不同性質的決定，前者不經過設施仲裁秤。

⇒ **結論**：導回只該換掉 `_food_rescue_eval` 裡 `:5294` 開始那段挑新設施的迴圈（改呼 `_pick_facility` 取代自己重算一次 argmax），**`:5271-5293`（入口檢查／續蓋分支／在建guard）原封不動保留**。這不是「本刀不管續蓋、留一個已知洞給以後」——是「續蓋本來就不屬於這個刀要動的那半」，跟你自己在別票已經用過的「這是已知殘留、另票判斷值不值得查」不是同一種情況，這裡是**架構上從來就分開，不是漏查**。

## ★附帶查到一個更嚴重、但現在被既有guard擋住的潛在洞——記下來，不用現在修

讀了 `_begin_facility_construction`（`outpost_system.gd:601-645`）——**它自己完全沒有 `tile.construction_team_id != -1` 的重入防護**（拒絕清單只有：無此設施定義／據點型別不合／地形不合／已滿級／無空位／付不起，六條裡沒有「已經在蓋」這條）。對照 `start_build`（`:540`）跟 `start_demolish`（`:651`）都有這條防護——**`_begin_facility_construction` 是這一族裡唯一沒防的**。

★**現在為什麼沒事**：因為唯一的呼叫路徑（`_evaluate_infrastructure`）在呼叫它之前，已經在 `:4985` 那道 guard 擋掉了「正在施工」的情況，`_begin_facility_construction` 根本沒有機會在一塊已經在蓋東西的地上被呼叫第二次。★**這代表這個洞目前是死的（unreachable），但它是【靠呼叫端小心】撐住，不是函式自己安全**——跟你們今天已經記過好幾次的「單一寫點/單一呼叫路徑」形狀一樣：只要未來有第二條路徑（例如這次的 food_rescue 重接線，如果不小心讓某個分支繞過 `:5292-5293` 那道 guard 直接呼 `_pick_facility`→`_begin_facility_construction`），這個洞就會從「靠guard撐著」變成「真的會重置一個在建工程的ticks_left，蓋到一半歸零重來」。

⇒ **建議**：不用現在修 `_begin_facility_construction` 本身（不在本票範圍，且现在無害），但**把這個發現記進 known_issues**（「`_begin_facility_construction` 缺重入防護，目前靠呼叫端 `:4985` 那道 guard 撐住，任何新呼叫路徑要自己複製同一道 guard，不能假設函式自己安全」）——這正是「續蓋不進本刀」這個判斷成立的**前提**，值得跟這次的判斷寫在一起，免得下一個接手的人以為 `_begin_facility_construction` 本身是安全的。

## ⇒ 要你補的
1. ④：導回時只替換 `:5294` 起的選擇迴圈，`:5271-5293` 原樣保留——spec 明寫這條分界線（附上面兩處 code 引用），不用另開回歸斷言，因為續蓋根本不會被這次改動碰到。
2. 附帶：`known_issues` 補一筆 `_begin_facility_construction` 缺重入防護（目前無害，靠呼叫端 guard 撐住）。

**premise_contradiction: false，④確認清楚後即可整票 CLEAN，這是本輪少見的「查完發現比想像中乾淨」的一票。**
