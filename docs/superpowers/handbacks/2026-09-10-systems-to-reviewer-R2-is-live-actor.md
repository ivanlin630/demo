---
from: systems
to: reviewer
status: consumed
slice: is_live_actor 具名謂詞（blueprint 早先已核，C1 票①落地後解除阻塞）
topic: ★R² 送審：`specs/2026-09-10-is-live-actor-named-predicate-HOW.md`｜★★本票【不改任何行為】，真正的產出是一份普查：`for … in state.teams` 共 62 站，★而只有 2 站知道「殭屍窗」存在（判死到 tick 末 erase 之間，那支隊還在 state.teams 裡）｜★★★我要你打的是【我有沒有又把普查做成了在符號形狀上射箭畫靶】——母體我用裸 `in state\.teams`，而繞過這個寫法的迴圈會整批隱形
---

# 一句話

`teams_pending_erase`（`world_state.gd:69`）是對的設計（中途 erase 不安全），
★**代價是一個一 tick 的殭屍窗**：判死到 tick 末 erase 之間，那支隊**仍在 `state.teams` 裡**。
★★而這個判斷**沒有名字** ⇒ 只有兩處記得過濾，而且是**逐字重複的三行**
（`faction_ai_system.gd:4404-4406`／`npc_combat_system.gd:748-750`）。

# ★我要你優先打的三格

```
(1)★★★母體：我用 `grep -rn "in state\.teams" scripts/simulation scripts/data`（裸符號）＝62。
   ★而這只認得【一種寫法】。繞過它的形狀我想得到的有：
     `state.teams.values()` / `state.teams.keys()` / 先存成區域變數再迭代 /
     透過別的 accessor 拿到隊集合（`f.member_team_ids`、`team_discovered`、快照陣列…）
   ⇒ ★★這正是我今天被打過的「在符號形狀上射箭畫靶」——
     ★★★請你獨立決定母體該怎麼撈，不要沿用我的 pattern。
     （★若你撈出來的數字跟 62 不同，那個差額本身就是本票最重要的發現。）

(2)★「兩個名字」是不是過度設計：我給了 `is_live_team(tid)->bool` 與
   `pending_erase_set()->Dictionary`。理由是既有兩處消費的【不是布林】而是排除集合，
   只給布林消滅不了那段重複。★★但兩個介面就是兩個要維護的東西 ——
   若你認為一個就夠（例如讓 `succeed_or_disband_faction` 自己去 state 拿），直接打。

(3)★★★驗收②的三格：`is_live_team` 對【剛判死未 erase】回 false、【正常隊】回 true、
   【已 erase】回 false。★我特別要三格，是因為第一格與第三格【回同一個答案而理由不同】
   ⇒ 只驗第三格會讓殭屍窗那格完全沒被測到。
   ⇒ 請打：這樣夠不夠？還有沒有第四種狀態（例如 `teams` 有但 `pending` 也有、
     而 cleanup 已經跑過一半的那個瞬間）？
```

# 我自己先招的兩件

```
①普查的 [C] 待判類【必須存在】——讀 code 判不出某站點「應該」過濾，那是語意判斷。
  ★一份沒有 [C] 的普查是可疑的：它表示分類者把不確定的塞進了 A 或 B。
②[A] 類裡的每一條都是【潛在 bug】，★而本票【不修】——
  逐站後果不同（有的無害、有的會讓死人繼承派系），混在一張票裡會變成無法驗收的大改。
  ⇒ 清單交 blueprint 判優先序、分票開。★若你認為這是「發現了不修」，直接打我。
```
