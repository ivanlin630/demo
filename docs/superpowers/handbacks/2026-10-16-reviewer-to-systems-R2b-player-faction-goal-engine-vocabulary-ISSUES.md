---
from: reviewer
to: systems
status: consumed
slice: 玩家勢力目標改用引擎詞 第二輪（main c6562444f）
topic: R② 第二輪 ＝ **ISSUES（小，一處；M1、M3 與同版項全數對得上）**｜M2 的「外殼前後快照加 override＋target」在外殼內取不到變化：action 先寫欄位，進 _update_goals 時前後值已相同
---

# 核對（對 spec diff e87a7fb73..c6562444f）
```
✓ M1 directive_stamp_test ③ 列進同 commit 改舊床（玩家領導佈置＋「徵收」）；n6 註明新版 ③ 不紅、不是雙守。
✓ M3 理由首條「盟主隊長不存在」、門檻印實際值（0.4−(野心−0.5)×0.2／0.6）、call site 留 survival return 之後、兩路既有差寫明；G4c 六列＋全過列＋野心 0.59／0.60；G4d 抽前抽後。
✓ 同版：G1 四前提＋belief 距離、G1b 地板＋API、fp 之外的 Probe 計數、f==null 容忍＋to_task 全 grep、兩顯示點＋payload、殘留舊詞清、G5 改 goal_drivers 非空、_nearest_independent 其他使用者列出、立國後目標清除的回句。
```

# 一處（M2 的做法寫法不通）
```
spec §二 末條：「_update_goals 外殼的前後快照加 player_goal_override 與 player_goal_target」。
   · 外殼（faction_ai_system.gd:1905-1911）的「前」是在【進入 _update_goals 時】拷貝 f.goals／f.goal_drivers。
     玩家改目標的路徑是：_action_set_faction_goal 先寫 f.player_goal_override／target（player_command_system.gd:1801），之後該勢力的下一次 _update_goals 才跑。
     ⇒ 進外殼時 override／target 【已經是新值】；外殼裡拷貝的「前」值＝新值，「後」值＝新值 ⇒ 永遠相等 ⇒ 「攻擊 X」改「攻擊 Y」仍判沒變。
     （goals／drivers 能做快照是因為它們是外殼內 _rebuild_goals 才改的；override／target 是外殼外被改的，性質不同。）
   · 照 spec 字面實作 ⇒ G1c 會紅，實作端會被迫自己決定怎麼辦。
   ⇒ 改成二選一寫進 spec（我偏 a）：
       a FactionData 存「上次套用的」兩欄（例 applied_goal_override／applied_goal_target，或一個 applied_goal_key 字串）；外殼比 現值 vs 上次套用值，不同 ⇒ 蓋戳記，然後把上次套用值更新成現值。
       b action 在寫欄位的同一處直接蓋 directive_change_tick（值有變才蓋，重申不蓋）。
     a 保持「戳記只在 _update_goals 外殼蓋」這個單一寫入點（:1902-1904 註解的初衷）；b 多一個寫入點。
   · 這兩個新欄位不入 fp（_emit_factions 不印 override／target），不影響 world-fp。
   · G1c 與 n7 的設計不變：n7＝外殼不比（或不更新）applied 欄位 ⇒ G1c 紅。G1c 要在【改對象之後、_update_goals 之前】先斷言 _directive_fresh 仍 false（證明戳記確實是外殼蓋的、不是 action 順手蓋的——a 路徑時）。
```

# 判決
```
verdict: issues（小）
必補：M2 寫法（a 或 b）
補完不需再審；其餘 dispatch 可進行
```
