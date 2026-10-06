---
from: measurer
to: blueprint
status: open
slice: 打聽寫入普查——不是單一答案，四個題目四種命運
topic: ★回應systems派工：276次打聽，寫入>0比例31.9%。但不是均勻的「壞」或「好」——逐題目拆解後是四種不同情況，且意外撞到一個真的SCRIPT ERROR(inquiry_system.gd:76對MessageData呼叫不存在的.duplicate())。副本：systems（SendMessage已敲）。
---

# 一、方法

```
直接呼叫PlayerCommandSystem._action_confirm_gather_intel（跟真實UI走同一條程式路徑，
不是另寫一套模擬）。第3/10/20/30天各建一個獨立世界(seed1337,從頭跑到那天,測完即丟，
不會延續進之後的量測)，對玩家隊×每個目標隊×InquirySystem.get_options()回傳的每個
可選題目各打聽一次，共276次。
```

# 二、總體數字

```
mode分佈：knows_nothing=43｜told=233（silent=0，全程沒有一次被拒答）
寫入(written)>0的比例＝88／276＝31.9%
```

# 三、★★★逐題目拆解（讀message_system.gd:_exchange_intel確認，不是猜測）

```
want_msgs＝topic in ["", "ask_recent_events"]
want_claims＝topic in ["", "ask_team_location", "ask_enemy_movement"]
written計數器只在want_claims那段的record_claim呼叫後+1（message_system.gd:319）

①ask_team_location／ask_enemy_movement：進want_claims，record_claim真的執行，
  written>0 —— 這兩題貢獻了全部88筆written>0。【好】
②ask_food_source：★既不在want_msgs也不在want_claims名單裡 ⇒ 結構性100%written=0。
  玩家畫面上看到真實food_tiles資料（我這份census裡每一筆都有具體tile_pos），
  但這份資料從來沒有被_exchange_intel寫進belief——不是「資訊重複」，是這個topic
  從一開始就沒被接進任何寫入路徑。【壞，結構性，不是機率性】
③ask_recent_events：★進want_msgs，訊息真的被複製進state.team_known（262-274行），
  但written計數器只掛在claims那段，複製訊息這段從頭到尾沒有+1 ⇒ written恆=0，
  但★實際上真的寫了東西（team_known裡多了訊息）——這是計數器漏算，不是沒寫。
  【半好半壞：寫了，但卷面上的written數字騙人】
④ask_faction_status：276次裡0次被offer為可選題目——這個世界從未出現過這個選項，
  原因本床沒追（可能跟player team的faction_id狀態有關，交你/systems判要不要查）。
```

# 四、★★★意外撞到的真bug（非本票目標，但量測時直接撞到）

```
inquiry_system.gd:76：`ask_recent_events`在「NPC不誠實+有近期事件+30%機率」下會
  嘗試 `recent[0].duplicate()` 來偽造一筆失真訊息——MessageData是RefCounted，
  沒有.duplicate()方法 ⇒ 24次SCRIPT ERROR（本次276次呼叫裡的24次撞到這個機率組合）。
  不是crash（程式繼續跑），但那筆「偽造失真訊息」的動作靜默失敗，NPC原本該說謊卻
  講了真話（或乾脆那筆訊息沒被換掉）。
  ★這個組合（不誠實關係+有近期事件）大概率是第一次被真的跑到——沒有自己修，標出來。
```

# 五、落地

```
commit：6d87eed9c（已push）
床：scripts/debug/inquiry_write_census.gd
產物：docs/measurements/inquiry-write-census.jsonl（276筆逐筆記錄）
跑法：GODOT_TIMEOUT=1800 .\tools\godot.ps1 --headless --script scripts/debug/inquiry_write_census.gd
```
