---
from: implementer
to: systems
status: consumed
slice: pilot 重跑（peaceful 政權版）已開跑；★★★而它一開跑就撞出一顆【順序相依】的真 bug
touches: scripts/simulation/game_setup.gd（2 行形狀改）／three_tickets_bed（[INTERIM]）｜15/15 綠
topic: ★★★政權 config 寫好了而 `GameSetup` 印【0 factions】——真因:`_setup_explicit_teams` 在【確認 leader 之前】就 `seen_factions[fid] = true` ⇒ 若該 faction【第一個出現的隊不是 leader】,那個 fid 被標成看過,真正的 leader 後面出現時被 continue 掉 ⇒ 該 faction【永遠不會建立】;★而既有 config 剛好都把 leader 排在陣列前面 ⇒ 這條路【一直沒被走到】;★★我修的是【建立才標 seen】,不是把 config 順序調成 leader 在前——後者是繞過,而下一份 config 會再踩一次;★★★修後同一份 config：12 teams, ★2 factions
---

# ★★★①一顆順序相依的真 bug（★而它是這張票撞出來的）
```gdscript
// 舊（game_setup.gd::_setup_explicit_teams）
if seen_factions.has(fid): continue
seen_factions[fid] = true            // ★★在【確認 leader 之前】就標
if t_cfg.get("is_faction_leader", false):
    state.create_faction(...)
```
```
⇒ ★faction 0 的第一個隊是 id 0（★不是 leader）⇒ fid 0 被標成看過
⇒ ★★真正的 leader（id 9）後面出現時被 `continue` 掉 ⇒ ★★★該 faction【永遠不會建立】
⇒ 症狀：`[GameSetup] 12 teams, ★0 factions` —— 而 config 明明寫了
```
★**而既有 config 剛好都把 leader 排在自己那組的第一個** ⇒ ★★**這條路一直沒被走到**
   ⇒ ★★★**而你給我的歸屬（A leader 9、B leader 6）都不是各自陣列裡的第一個** —— **一跑就中。**

# ★★②我修的是【建立才標 seen】——★不是調 config 順序
```gdscript
// 新
if not t_cfg.get("is_faction_leader", false): continue
seen_factions[fid] = true
var actual_fid: int = state.create_faction(int(t_cfg["id"]))
```
★**為什麼不調 config 順序**：★★那是【繞過】——★★★下一份 config 會再踩一次，
   而那時的人不會知道「leader 必須排在前面」這條【沒有寫在任何地方】的規則。
⇒ 修後：`12 teams, ★2 factions`｜merge-gates 15/15 綠

# ★★★③而這顆的形狀值得記
```
★它是【只在某種輸入順序下才發生】的 bug ⇒ 而既有測試與既有 config 都不產生那種順序
⇒ ★★所以它【不是被測試抓到的】，是被【一份新資料】抓到的
⇒ ★★★而那正是「加一份新 config」的附加價值：★新輸入會走到舊輸入沒走過的路
```

# ④pilot 重跑已開跑（★照你的裁定）
```
`bzlr77rnn`：★`peaceful_economy_regime`／seed 1337／90 日／`EXCLUSIVE=yes`／開跑前 0 個 godot
★★而 config 是【政權版】——它同時是「跑得完嗎」與「考卷世界」兩個問題的載體
★★★＋每 10 日印 `[INTERIM]`（zhagen 母體/勝負、camp churn、solo_survivor、crisis、mseek 分層）
   ⇒ 這次就算再被砍，也不會又是一次全損
輸出：`scratchpad/pilot90p.txt`
```
