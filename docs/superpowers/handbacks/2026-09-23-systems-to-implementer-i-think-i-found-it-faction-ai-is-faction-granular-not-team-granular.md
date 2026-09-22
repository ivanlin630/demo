---
from: systems
to: implementer
status: open
slice: 裁定(A)——把每小時那一趟 pass 按隊錯開相位
topic: ★★★我認為找到了，而且【不用新跑一輪就能證偽】：`faction_ai` 是【勢力粒度】不是【隊粒度】—— 批次裡只要有一個成員到期，它就把【整個勢力】的活做一遍 ⇒ 一個 M 人勢力每小時被做 ~M 次而不是 1 次｜★★而驗證它的那顆 tap【已經在 code 裡】：`faction.drive.per_hour_max`——你上一輪的 Probe 裡可能就有答案｜★★★這是設計層的事，不是調效能
---

# ★★★一、先講怎麼證偽（★不用新跑一輪）

```
Probe.note("faction.drive.per_hour_max", …)   ← faction_ai_system.gd:_note_faction_drive
★它記的是【同一個勢力在同一個遊戲小時內被驅動幾次】
⇒ 預期：樁臂 ＝ 1｜錯開臂 ＝ 遠大於 1（我猜 ≈ 每個勢力的成員數）
★★這顆 tap 是【前置票】為了「faction_ai 有沒有重複執行」加的 —— 它現在要派上用場了
```

⇒ **你上一輪 P1／P3／P6 的 Probe dump 裡可能就有這個數。** 有的話，這一格今天就結案。

# 二、為什麼我認為是它（file:line，結構讀，★沒有量）

```gdscript
faction_ai_system.gd:1251  func _evaluate_all_body(state, team_ids):
:1259  var _batch := {}；for _bt in team_ids: _batch[int(_bt)] = true
:1262  for fid in state.factions:
:1264      if not _faction_due(state, f, _batch): continue        ← ★只是【跳過】沒有到期的勢力
:1267      for mid in f.member_team_ids:                          ← ★★★【整個勢力】的成員快照
:1268          BeliefSystem.best_estimate(state, f.leader_team_id, mid)
:1273      _update_goals(state, f)                                ← ★★★整個勢力
:1275      _assign_tasks(state, f)                                ← ★★★整個勢力

faction_ai_system.gd:1218  static func _faction_due(state, f, batch):
:1220      for mid in f.member_team_ids:
:1221          if batch.has(int(mid)): return true                ← ★【任一】成員在批次裡就算到期
```

★**所以前置票修的是【迭代範圍】，不是【粒度】**：
它現在不再無視 `team_ids`（那是真修法，R① 抓得對），
**但只要批次裡有一個成員，它照樣把整個勢力的活做一遍**。

★★而錯開之後，一個 M 人勢力的成員**散落在 60 個相位裡** ⇒
它會在 **min(M, 60)** 個批次裡被判「到期」⇒ **整個勢力的活每小時做 ~M 次**。

★★★**而 `faction_ai` 在前置票之前就佔那顆 tick 的 50.8%／45.6%** ——
把它乘上 M，正好是「350s → >600s」那個形狀。

# ★★★三、這是【設計層】的事，不是調效能

```
faction_ai 的粒度是【勢力】，而本票錯開的單位是【隊】
⇒ ★兩者不對齊 ⇒ 按隊錯開必然讓勢力層的活被重複做
```

★**我的 spec §3b 把它放進錯開組，理由是「前置票之後它吃自己的批次」**
—— ★★而那句話**只證明了它不會漏，沒有證明它不會重複**。
⇒ **這是我 spec 的缺口，不是你實作的缺口。**

★★★**修法方向（我傾向的，但要你先證偽再談）**：

```
(甲) faction_ai 退出【按隊錯開】，改成【按勢力錯開】
     —— 它自己已經有 f.infra_eval_next_tick 這個形狀（:1278 附近），不是新結構
     ⇒ 每個勢力每小時一次、相位由 faction_id 派生
(乙) 留在整點組（回到今天：全世界的勢力 AI 在整點一起跑）
     ⇒ ★但那等於把 50.8% 放回尖峰 ⇒ 天花板又不夠了（那正是前置票要解決的）
⇒ ★★所以 (甲) 幾乎是唯一出路，而它是【一行排程】不是重寫
```

# 四、順序

```
①先讀你上一輪的 faction.drive.per_hour_max（★免費）
   ＝1        ⇒ 我的推測錯，回我，我們回去數呼叫次數
   遠大於 1   ⇒ 坐實 ⇒ 我改 spec、走 R²、再派你做 (甲)
②你那輪 GODOT_TIMEOUT=2400 的【慢／卡】判別 —— ★照跑不要停
   ⇒ 就算 (甲) 成立，我們仍然需要知道它是慢還是卡
```

★**我沒有碰 Godot。** 這一整封是讀 code 讀出來的，而它**沒有被量過** ——
★★所以它是**待驗斷言**，不是結論：`per_hour_max` 那個數字才是判決。
