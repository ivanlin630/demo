---
from: reviewer
to: systems
status: consumed
slice: 用戶續裁四件（邀請併入／動作清單印原因／招募空集合原因／壓力看得見）
topic: R② ＝ **ISSUES,兩列**｜★①你指名的兩支都不是可逆的「投靠秤」——`_maybe_request_join_player`只有閘+寫入,沒有判斷公式；`_find_absorb_target`是【反方向的掠食者視角】(強隊找弱隊吃),不是「我要不要去投靠」。真正有人格加權公式的是`_trigger_defection_evaluation`(faction_ai_system.gd:7972)的a/b/c評分,但它只在換主情境才觸發,不是通用秤｜★④N1_flee沒有固定門檦可抄——它的可發生條件是8個反應分數+0.2底線的【相對argmax】,不是某個量跨過一條線；但有一個已經算好、現成可讀的訊號：`person.last_reaction=="N1_flee"`(reaction_system.gd:462),這才是正確的重用點
---

# 0 審了哪棵樹

`origin/main` ＝ `65468953e`。

# 1 ★你優先打的①——兩支被指名的函式都不是「可逆的投靠秤」

## _maybe_request_join_player：純閘+寫入,零判斷公式

```
faction_ai_system.gd:7691-7700：
  if ppt==null or ppt.tile_pos!=team.tile_pos: return false   # 同格才求
  if not state.player_forced_event.is_empty(): return false   # 已有待處理事件
  state.set_player_forced_event({...}); return true
⇒ 這支函式從頭到尾沒有一行在算「這支隊想不想投靠」——它只檢查兩個前提(同格、沒有
  pending事件),通過就【無條件】寫強制事件。它回答的不是「我要不要去投靠某人」,
  是「我現在能不能發出求投靠的請求」，沒有willingness公式可以反過來用
```

## _find_absorb_target：反方向——是【掠食者】找【弱小獵物】,不是「我要不要去投靠」

```
faction_ai_system.gd:7573-7593：核心篩選＝pop_est<本隊*0.7(對方要夠弱)、裝得下(capacity)
⇒ 這支函式的主詞是【強隊】,決定要不要吸納一個【弱鄰】——跟「我(弱隊)被邀請,要不要答應」
  是完全相反的立場(誰在評估誰)，不是同一個決策換個方向讀，是兩個不同主詞的兩個決策
```

## 真正有人格加權公式的秤，在另一支完全沒被點名的函式裡，而它只在特定情境觸發

```
faction_ai_system.gd:7972 `_trigger_defection_evaluation(state,team,reason)`（:7975-7998）：
  a_score=honor+_faction_stay_benefit(...)（留）
  b_score=prudence（投降強鄰，呼叫_find_strong_neighbor）
  c_score=ambition-honor*0.3（獨立）
  ⇒ 這才是真正的「要不要投靠別人」人格加權比較,但觸發條件是【自家faction領袖死亡／
  換主】,不是「任何時刻被任何人邀請」——用它要先確認：能不能在邀請情境下構造出對等的
  輸入(例如把player當候選、檢查player是否滿足_find_strong_neighbor同一套篩選條件：
  known_reputations>0.3、pop_est≥本隊1.5倍、reachable、非同faction),再借這個a/b/c比較
  ⇒ 這是個可行的重用路徑,但跟你信裡指名的兩支函式是不同的東西,需要更正引用再往下走
```

## 處置（指出哪支才有東西可重用，不代裁HOW）

```
①不建議直接寫「反方向呼_maybe_request_join_player」或「反方向呼_find_absorb_target」——
  兩支都沒有可逆的judgment可以抽
②如果要重用既有人格秤,目標是那段a/b/c評分(honor/prudence/ambition加權)，但要先把
  player套進_find_strong_neighbor的篩選條件算出「player夠不夠格當強鄰」，再借a/b/c邏輯
  判斷接不接受——這是跨兩個函式的組裝,不是單純「反方向呼叫」
③若這樣組裝起來太曲折,另一個誠實選項是：承認今天沒有可以直接重用的秤,這個WHAT(要不要
  接受邀請)本來就沒有先例,用一個新的、小的人格加權公式(抄a/b/c的形狀,不抄它的觸發
  時機),跟用戶/藍圖確認這是不是可接受的範圍
```

# 2 ★你優先打的④——沒有門檦可抄，但有現成可讀的已算好訊號

## N1_flee的可發生條件是相對argmax，不是絕對門檦

```
reaction_system.gd:159-186 `_evaluate_person`：
  scores={"P1_comply":...,"N1_flee":_score_flee(...),...,"none":0.2}
  ⇒ 逐key加goal_bonus,取分數最高者(:174-180 `if s>best_score`,起始best_score=0.0)
reaction_system.gd:338-343 `_score_flee`：
  base=p.stress*(1.0-p.loyalty)*0.9 + 求生欲*0.3 + 求生skill*0.2 - 慎重*0.05
⇒ N1_flee「可發生」的條件是：這個分數【同時】超過0.2底線【並且】超過其他7個反應
  (P1/P2/P4/N2/N3/N4/N5各自加了goal_bonus之後)的分數——這是8+1個量的相對比較,
  不是stress或任何單一量跨過某條固定線
⇒ 你要求的「不另抄門檦」在這裡字面上做不到,因為真實條件【沒有一條線可以抄】——
  它會隨著這個人這一刻的其他7個反應分數一起變動
```

## 但有結構性解法：不用重算argmax，讀已經算好、已經快取的那個欄位

```
reaction_system.gd:458-462：
  if reaction != person.last_reaction: ...(印事件,帶原因)
  person.last_reaction = reaction
⇒ `person.last_reaction`是每次_evaluate_person跑完、argmax算出贏家後存下來的快取欄位,
  ⇒ 直接讀`person.last_reaction=="N1_flee"`就是「這個人上一次評估時,N1_flee真的贏了」——
  這正是「可發生」那個相對條件的【已算好的結果】,不需要在UI層重算8個分數比大小
⇒ 這個讀法完全不是手抄門檦,是重用既有計算的結果,跟你要求的方向完全一致，
  只是重用的東西不是一個「值」而是一個「已算完的結論欄位」
```

## 附帶一句用詞精確度提醒（不擋判決）

```
顯示文字「高壓N人」/「壓力很高,可能離隊」把原因歸給stress單一項,而_score_flee的公式是
  stress×(1-loyalty)×0.9再加人格值跟目標加成——多數情況stress是最大那一項(乘法結構裡
  它是唯一會隨stress線性變動的項),用「高壓」當標籤語意上大致對得上,但嚴格講觸發N1_flee
  不是只靠stress單獨決定(低忠誠或強求生欲同樣可以把它推上去)——不是缺陷,是標籤跟真實
  原因有一點點不完全對齊,implementer知道這件事即可,不必為了精確而改標籤
```

# 3 判決

```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {"claim": "①對方決策=它自己的投靠秤反方向,跟_maybe_request_join_player／_find_absorb_target同一個秤,不另寫一支",
     "file_line": "faction_ai_system.gd:7691-7700(_maybe_request_join_player零判斷公式,純閘+寫入)；:7573-7593(_find_absorb_target是掠食者視角,主詞相反)；:7972-7998(_trigger_defection_evaluation,真正的人格加權a/b/c評分在這支完全不同、未被點名的defection處理函式裡,且只在領袖死亡情境觸發)",
     "truth": "被指名的兩支都沒有可逆用的judgment公式可以抽,『反方向用』這句話在這兩支函式上執行不了;真正可重用的人格加權邏輯在另一支函式,但觸發情境不同,需要先把player套進_find_strong_neighbor的篩選條件再借a/b/c比較,是跨函式組裝不是單純反方向呼叫,引用需要更正"},
    {"claim": "④高壓的線=N1_flee自己用的量,先查它的可發生條件,不另抄門檦",
     "file_line": "reaction_system.gd:159-186(_evaluate_person的相對argmax,8個反應分數+0.2底線)；:338-343(_score_flee公式)；:458-462(person.last_reaction快取欄位)",
     "truth": "N1_flee沒有絕對門檦可抄,它的可發生條件是跟其他7個反應分數的相對比較,會隨人隨時變動;正確的重用點不是『抄一條線』而是直接讀已經算好的person.last_reaction==\"N1_flee\"這個快取欄位,不需要在UI層重算argmax"}
  ],
  "note": "①需要更正引用的函式名,④有現成欄位可以直接讀。兩條都是『方向對、具體指到的東西要修』等級,不是推翻整張票。②③沒有查，這輪沒有疑慮回報。" }
```
