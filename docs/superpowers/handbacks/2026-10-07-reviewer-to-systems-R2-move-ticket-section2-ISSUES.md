---
from: reviewer
to: systems
status: open
slice: M 票 §2：推進停點＝玩家相關事件＋休息兩段確認
topic: R② ＝ **ISSUES,一列**｜★你優先打的三題都有答案：5類停點裡3類有既有kind(找上門/被攻擊或遭遇/成員死亡離隊),2類沒有(敵對進相鄰/抵達,抵達是設計上不走kind系統);Space/X/G/L(走到抵達)四支已經共用`_advance_stop_reason`(text_ui_main.gd:1104,分支feat/move-command-one-tick已落地,休息還沒接)；★但那支共用函式本身是繞過WorldEvents的手刻快照差分,不是從既有kind系統導出——跟§2①自己要求的「禁手抄」字面上矛盾,「成員死亡或離隊」就是這個矛盾第一個咬人的案例(WorldEvents早有kind,但共用函式完全沒讀過)
---

# 0 審了哪棵樹

`origin/feat/move-command-one-tick` ＝ `95df344e0`（merge了origin/main的01111008c），§1的實作已落地未push前的那顆改動＝`e48c7d06d`。spec檔在`origin/main`最新。

# 1 ★你優先打的三題——逐一核對完

## 題1+2：5類停點裡,哪些今天有kind，「敵對進相鄰」有沒有

```
找上門/提案到達 ⇒ world_events.gd:70 FUNC_KINDS裡的"forced_event_arrived" ✓有kind
被攻擊或遭遇開始 ⇒ "combat_engaged"(FUNC_KINDS)／"combat_start"(MESSAGE_KINDS) ✓有kind
成員死亡或離隊 ⇒ "member_died"／"member_left"(FUNC_KINDS) ✓有kind
敵對隊進入同格或相鄰格 ⇒ ★只有「同格」有覆蓋,是interaction_system.gd:272-277設
  state.player_pre_encounter(NPC.combat_target==玩家且同格才會設)——★★「相鄰格」(距離1,
  不是同格)★★零覆蓋,git grep player_hostile_teams(:278既有敵意清單)全部用途都是靜態
  成員名單讀寫,沒有任何一處做「跟玩家距離是不是1」的逐tick計算 ⇒ 真的沒有,要新增
抵達目的地 ⇒ 不是WorldEvents的kind,是M票§①④自己那套獨立機制(上一幀move_target轉
  (-1,-1)且人在那格)——這個本來就不打算走kind系統,是設計上刻意分開的另一類停點,
  不是漏掉
```

## 題3：幾支推進迴圈要共用停點判斷

```
`origin/feat/move-command-one-tick`已落地(e48c7d06d)：GLOBAL_ADVANCE_KEYS=
  [KEY_SPACE,KEY_X,KEY_G,ARRIVE_KEY(L)]——這四支已經共用同一支`_advance_stop_reason`
  (text_ui_main.gd:1104-1112)：Space/X/G走`_report_key_advance`,L走
  `_report_arrive_advance`,兩個wrapper都呼同一支`_advance_stop_reason`判斷為什麼停
⇒ 休息(§2②,這張票的新功能)今天還沒有推進請求路徑——它要新接,接的時候呼同一支
  `_advance_stop_reason`即可,不是另開第五套
```

# 2 ★附帶但重要的結構性發現：共用函式本身沒有走「既有kind系統」,是手刻的快照差分

```
`_advance_stop_reason`讀的是`result.events`,這些events來自sim_bridge.gd:_diff_events
  (:302-315)——★這支函式【不讀WorldEvents.player_events或任何kind欄位】,它是獨立地
  比對幾個state欄位的推進前後值(encounter_active／team_discovered.size()／
  player_forced_event_id／player_pre_encounter.is_empty())手動合成"type"字串：
  "encounter_triggered"／"pre_encounter"／"forced_event_arrived"／"new_team_spotted"
  ⇒ 這四個字串裡只有"forced_event_arrived"剛好跟WorldEvents的kind同名,但也是【獨立
  判斷】不是讀那個kind欄位算出來的("pre_encounter"/"new_team_spotted"/
  "encounter_triggered"在WorldEvents裡根本沒有對應kind)
⇒ 這正好撞上§2①自己那句「停點清單從既有事件類型導出...禁手抄」——★已經落地的那支
  共用函式本身就是一次手刻,不是從既有kind導出的
⇒ 具體咬人的地方：「成員死亡或離隊」WorldEvents早就有kind(member_died/member_left,
  而且已經在玩家事件流裡顯示),但_advance_stop_reason的match清單裡完全沒有讀它——
  不是因為沒有kind可用,是因為這支函式從一開始就沒有去讀WorldEvents那份,
  只讀了幾個特定state欄位
```

## 處置（指出矛盾與缺口，不代裁要不要重構）

```
不建議現在把_diff_events整個改成讀WorldEvents.player_events(範圍比這張小票大,
  §1已經落地不宜大改)；但「成員死亡或離隊」這兩類要補的話,最省事的路是讓
  _diff_events額外讀WorldEvents.player_events裡seq大於上次讀到的那些、kind屬於
  {member_died,member_left}的筆數有沒有變化(用player_event_seq當游標,跟事件流UI
  讀法同源),不要另外手動偵測population變化(population變化的原因很多種,不等於
  「成員死亡或離隊」這個語意,用kind讀才對得上spec文字要的語意)
「敵對進相鄰」要新增kind的話,寫入點要挑能算出「每tick跟玩家距離」的那個迴圈
  (跟vision/移動解算同一處),不要在_diff_events裡逐tick重新掃全部hostile teams算距離
  (那是把運算搬到UI層,違反這類計算該在模擬層的既有分工)
```

# 3 判決

```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {"claim": "停點清單從既有事件類型導出,禁手抄",
     "file_line": "sim_bridge.gd:291-315(_snapshot/_diff_events，手動比對state欄位不讀WorldEvents.player_events)；text_ui_main.gd:1104-1112(_advance_stop_reason比對的type字串跟WorldEvents的kind只有一個同名、且是獨立判斷)；world_events.gd:70(member_died/member_left早有kind卻沒被讀)",
     "truth": "已經落地的共用停點函式本身不是從WorldEvents的kind系統導出的,是手刻的state快照差分；這不影響已經覆蓋的4類(找上門/遭遇/同格來犯/看到新隊)正確運作,但要補『成員死亡或離隊』時,正確做法是讓_diff_events去讀WorldEvents.player_events的kind欄位(跟事件流UI同源),不是再手動偵測一個近似指標；敵對進相鄰的新kind寫入點要放在模擬層算距離的地方,不要搬進UI層逐tick重算"}
  ],
  "note": "三題都有明確答案：3類有kind(找上門/遭遇含同格來犯/成員死亡離隊)、1類沒有(敵對進相鄰)、1類設計上不走kind(抵達)；四支推進鍵已共用，休息待新接同一支。附帶的結構性發現不擋這張票繼續,但要在『補成員死亡離隊』那一步正確處理，不要延續手刻差分的模式。" }
```
