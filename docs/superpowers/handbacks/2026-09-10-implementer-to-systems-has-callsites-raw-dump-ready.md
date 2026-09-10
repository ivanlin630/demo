---
from: implementer
to: systems
status: open
slice: 半守衛普查 —— ★只做你授權的那一半（撈母體，不分類）
topic: ★母體 dump 落地：`docs/process/teams-has-callsites-raw.txt`，**86 處 ＋ 每處上下文三行 ＋ 所在函式名**｜★★而我【沒有分類】——你說判準要先定，否則會變成「你分完我再重分一次」，我照做｜★★★而我掃的時候看到一個【判準會遇到的形狀】先報你：同一行裡有兩種寫法混著（`if not state.teams.has(tid): continue` 這種【純過濾】，與 `state.teams.has(x) and <再讀它的欄位>` 這種【守衛＋取值】）—— 判準若只分兩類，第二種會兩邊都不像
---

# ① 產物

```
docs/process/teams-has-callsites-raw.txt
  86 處，每處：file:line ＋ 所在函式名 ＋ 上下文三行
★刻意不分類（照你的指示）。
```

# ② ★★而我掃的時候看到的三個形狀（★給你定判準時參考，不是我的分類）

```
(甲) 純過濾：`for tid in ids: if not state.teams.has(tid): continue`
     ⇒ 這一類最像【存活守衛】，而它擋不住 pending_erase（今天已血證三次）
(乙) 守衛＋取值：`if state.teams.has(x) and state.teams[x].<欄位> …`
     ⇒ ★它同時是「存在檢查」與「準備要讀它」⇒ ★★判準若只分兩類，這種會兩邊都不像
(丙) 純存在問句：`var alive: bool = state.teams.has(target_id)` 之類，用來決定【別的事】
     ⇒ 例如清 dangling ref、決定要不要記帳
⇒ ★★★而我要點出的是：**這三種的【修法】不同**——
   甲換 is_live_team／乙可能要換成 `var t = state.live_team(x)` 這種一次到位的取法／
   丙多半不該改（它問的就是「還在不在字典裡」）。
```

# ③ 我沒做的

```
★沒有分類、沒有改任何一處（照你的指示）。
★★而下一步等你的判準 —— ★★★若你要，我可以把判準【寫成可執行的分類器】
  （像 is_live_actor 那張的閘一樣），這樣 86 處的分類結果本身也會有守衛看著。
```
