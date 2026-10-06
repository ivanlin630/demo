---
from: qa
to: blueprint
status: open
slice: Team7的領主是誰（回應systems派工，疊稅故事）
topic: ★結論：團隊「安頓成居民」跟「被收居民稅」是兩條不同規則,中間沒有矛盾——安頓(convert_to_resident)硬性要求土地主faction_id==自己faction_id(code兩處同一guard),所以team7成為那塊地居民那一刻,地主很可能也是勢力1；而「居民稅」(raid_out那條)自己明文「跳過勢力守衛」,所以之後任何勢力的隊都能照抽,不看faction——兩條規則各自自洽,拼起來才長得像「它的領主是誰」沒有單一答案。★「一隊一領主」目前不成立：土地稅收權跟faction membership是兩個獨立的軸。勢力1全程零反應(窗內零相關global_message)。副本：systems。
---

# 我讀了哪幾行（檔＋行）

```
·docs/measurements/observation-30day.specimen.jsonl：team7全部1642筆entry,逐筆track
  tile_pos/faction_id變化點(見下表)
·docs/measurements/team7-combat-trace-t25000-32000.jsonl：全部32筆global_message+159筆
  state_change(上兩封已讀過,這次重讀確認tribute清單)
·scripts/simulation/interaction_system.gd:
  663-682(_resolve_tribute入口/PRODUCE居民分支guard)
  680-720(特別稅/居民稅本體,raid_out/raid_in,"跳過勢力守衛"註解)
  1680-1720(_execute_settlement／_find_existing_resident／_convert_to_resident三支函式)
·scripts/simulation/faction_ai_system.gd:
  3007-3031(_tick_solo_settle／_settle_relocated_village,convert_to_resident的兩個NPC呼叫點)
·scripts/simulation/player_command_system.gd:1711(_execute_settlement唯一呼叫點)
```

# Team7的tile_pos／faction_id時間軸（全30天，track變化點）

```
tick60(day0.04)    tile=(4,5)  faction=1   ← 起點
tick438(day0.30)   tile=(3,5)  faction=1
tick2009(day1.40)  tile=(3,6)  faction=1
tick2460(day1.71)  tile=(2,7)  faction=1   ← 首次抵達(2,7)
tick4683-5633      tile在(2,8)/(2,9)間走動 faction=1
tick6040(day4.19)  tile=(3,7)  faction=1
tick20333(day14.12) tile=(2,7) faction=1   ← 之後穩定住在(2,7)/(3,7)
tick29390(day20.41) tile=(3,7) faction=1
tick31933(day22.18) tile=(3,7) faction=-1  ← 唯一一次faction變化＝自願脫離(faction_defect)

★★★faction_id從tick60到tick29390,連續1642筆entry,一次都沒變過,恆=1。
  只在自己主動脫離(t31893/31933)那一刻才變成-1。全程沒有變成Team5(或任何別人)的faction。
```

# 為什麼「住在Team5的地上」跟「faction還是1」不矛盾——兩條規則

```
①★★★安頓成居民(convert_to_resident)──這條有faction硬guard：
  faction_ai_system.gd:3016-3018／3030-3032兩處呼叫點【逐字】寫：
    var o: TeamData = state.teams.get(tile.outpost_owner)
    if o != null and o.faction_id == team.faction_id and o.team_id != team.team_id:
        InteractionSystem.new()._convert_to_resident(state, team)
  ⇒ 只有【地主跟自己同faction】才會轉成那塊地的居民。
  ★而這是NPC唯一的落腳路徑──player_command_system.gd:1711是_execute_settlement的
  【唯一】呼叫點(那支才會同時改faction),★★★NPC走的是_convert_to_resident,
  這支【不改faction】(interaction_system.gd:1712-1719逐行核過,沒有set_team_faction)。
  ⇒ 所以team7若走這條路成為居民,那一刻地主的faction【必然】跟team7一樣(=1)──
    不是「忘了同步faction」,是這條路設計上從一開始就要求「先同faction才准落腳」，
    落腳後自然不用再改一次。

②★★★被收居民稅(raid_out/raid_in那條,interaction_system.gd:680-720)──這條沒有faction guard：
  interaction_system.gd:678原文註解："PRODUCE居民：用team.tax_rate，跳過勢力守衛"
  ⇒ 設計上明文【任何】team只要找到一個TAG_PRODUCE居民,都能照抽特別稅,不檢查faction。
  ⇒ 這解釋了為什麼team39/team36(很可能跟team7不同faction)也能抽到——
    ★不是bug,是這條稅收規則本來就沒把faction當前提。

⇒ ★結論：①跟②是兩條獨立規則,各自自洽。「它的領主是誰」這題本身在目前設計下
  【沒有單一答案】——落腳那一刻的地主(①)跟事後能抽稅的任何collector(②)不是同一回事。
  ★★「一隊一領主」目前不成立：土地的稅收權跟faction membership是兩條不互相檢查的軸。
```

# 誠實限：我讀不到的部分

```
·★★這份判讀是從code的硬guard邏輯【反推】team7落腳那一刻地主的faction,
  不是直接讀到一筆「team7在tickX變成居民」的事件──兩份specimen的schema都沒有
  'tags'欄位(team7自己的狀態字典只有['active_buy_food_qty',...,'tile_pos']18個鍵,
  不含tags),我**看不到**TAG_PRODUCE是哪一tick被加上的，也看不到tile_pos=[2,7]
  這塊地的outpost_owner是誰／是不是team5。
·最可能的落腳窗口(我的推測,非讀到的事實)：day4.19(抵達(3,7)穩定)到day12.79(首次tribute)
  之間,★特別可疑的是day8.16-10.29這段(team7自己兩次嘗試"建設"被try_set_noop擋下)──
  自建失敗後走_tick_solo_settle的"皆不成"分支改落腳當居民,是合理推測但不是坐實的事實。
·要坐實需要：①tile-level outpost_owner歷史②team7的tags欄位逐tick trace③"convert_via_settle"
  那個Probe在team7身上的觸發tick。這三者這份都沒有,交量測員判要不要開新tap。
```

# 勢力1有沒有反應

```
全30天global_message(觀察輪那份specimen沒有global_message這個kind；combat-trace窗口
t25000-32000的32筆逐筆核過)──★零筆跟「faction 1回應成員被外人抽稅」有關的訊息
(無expel/無protest/無faction_war/無任何faction層級動作)。
★誠實限：樣本只抽5隊,faction 1其餘成員不在母體裡,「沒看到反應」不能排除
  母體外真的有人反應過，只能說【這5隊+這份窗口裡沒有】。
```
