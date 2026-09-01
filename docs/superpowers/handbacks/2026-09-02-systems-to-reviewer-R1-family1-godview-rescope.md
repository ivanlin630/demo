---
from: systems
to: reviewer
status: open
slice: 族①god-view 重定範圍
tier: R①
topic: ★★★我要主張「族①的兩個具名條目(#7 can_reach/#17 has_food_market)連同第三站 jhost【已經修好了】,清單是 stale」——這會讓 blueprint 重定序一整批,所以我自己不簽;★★我的前提是 file:line,但「已關」是【詮釋】不是原始事實(你我都吃過這個虧);★請 factcheck 三條坐實 + 一條負斷言(真剩餘母體=憲法閘 10 顆標記)
---

# 要你 factcheck 的四條

## ①`can_reach` —— 我主張 god-view 那半已關
```
faction_ai_system.gd:1432 "can_reach":
  var tgt_pos := BeliefSystem.belief_pos(state, f.leader_team_id, target_id)
  if tgt_pos == Vector2i(-1,-1): return false
  return _hex_dist(leader_team.tile_pos, tgt_pos) < 999
★我的斷言：【不讀 live 他隊位】⇒ 感知鐵律那條已守
★★而我【沒有】主張它沒問題：`<999` near-vacuous 仍開著（決策品質洞，不是 god-view）
```
★**要你查的是**：`belief_pos` 自己會不會在某條分支上回退成 live 真位？**若會，我這條就翻了。**

## ②`has_food_market` —— 我主張已關
```
faction_ai_system.gd:3626 `_nearest_market_outpost`：迭代 `state.team_market_known.get(team.team_id, {})`
★不是 `state.world.tiles` 全圖
```
★**要你查的是**：`_harvest_market_known` 往 `team_market_known` 塞東西的時候，**是不是自己就是 god-view**
（若它掃全圖塞已知，那 god-view 只是往上游搬了一層，而我會誤報「已關」）。★★**這一條我最沒把握。**

## ③jhost —— 我主張已關且錨也錯
```
清單寫 `decision_context.gd::gather :373`；★該路徑【不存在】，真身是 scripts/simulation/decision/decision_context.gd:675
   var _jpos := BeliefSystem.belief_pos(state, team.team_id, _jhost)
```

## ④★★★負斷言（最危險的一條，請重點打）
> **「族①真正剩下的是憲法閘 `constitution_baseline_v2.txt` 裡的 10 顆 `gv_*` 標記，除此之外沒有已知的 god-view 決策點。」**

★**我的證據只有**：憲法閘 `PASS (sites=74, removed=1)`＋baseline 裡 11 顆 `gv_mapscan/gv_teamstate` 標記。
★★**我知道這個證據不夠**：`known_issues` 自己就記著「constitution_gate god-view detector 盲點：間接 local-var 存取」
⇒ ★★★**我在條目裡寫的是「10 顆是下限不是全部」** —— **請你判這個保留夠不夠，或者這條負斷言根本不該送出去。**

# ★為什麼送 R① 而不是自己簽
```
★前提是 file:line 沒錯 —— ★★但「已關」是【詮釋】，不是【原始事實】
★★★而這個詮釋的後果是【blueprint 會取消一整批已排好的工】
⇒ 我自己抓不到自己的框；三條若有一條翻掉，我寧可在告訴 blueprint 之前翻
```
