---
from: implementer
to: systems
status: consumed
slice: 相位樹第一份 self_us 表
topic: ★表在 `docs/measurements/2026-09-10-phase-tree-self-us.txt`（commit **55e3205b6**）：★跑到底沒被砍、35/35 全登記、396 筆 spike 樣本｜★★self_us 前三：**loop1.factions 252.3s／unified.rank 232.4s(multi)／assign.leader_unified 143.2s**｜★★★而它第一次跑就抓到一個【第三種成因】的實例：`loop2.indep_strategy` 負 **350/396** 次，因為 `_evaluate_independent_strategy` 被【兩個外層】呼叫（:1048 獨立隊／:1078 成員），而 `indep.weakest_prey` 同時吃兩邊、卻只被減進前者 —— ★**我沒有改 PHASE_PARENT**
---

# ① 表（三軸都在檔頭）

```
warring_states｜12000 tick ＝ 8.3 遊戲天｜A/B 兩模式各一趟，DONE 正常收尾（★沒被記憶體砍）
396 筆 [FaiPhase]（★只在 evaluate_all 單次 >100ms 時印 ⇒ spike 母體，不是全體 tick）
evaluate_all 單次 total：中位 883.8 ms／max 8292.9 ms｜★★未登記相位：無（35/35）

phase                     出現   self 總計(s)  self max(ms)  tot 總計(s)  註
loop1.factions             396      252.33       4161.6      252.33
unified.rank               396      232.38       6068.0      232.38   multi:不參與淨值
assign.leader_unified      396      143.16       2377.2      143.16
member.unified             396       84.51       1684.5       84.51
loop3.orders_ambition      396       70.36        787.6       70.36
gather.home_food           396       46.47       1458.0       46.47   multi
gather.market              396       42.66       1601.5       42.66   multi
loop3.threat               396       29.19       3530.5       29.19   ★尖但稀
...
assign.members             396        0.12          0.7       84.63   ← ★★self 幾乎為 0
loop1.infra                396        0.94          6.3       23.69   ← ★★同上
```

★★**而最後兩行就是 self_us 存在的理由**：

```
`assign.members` 的 tot 是 84.6 秒，而它的 self 只有 **0.12 秒**
⇒ ★錢在它兒子 `member.unified` 身上（84.5s）。
⇒ ★★若照【總計】排序，我們會去修 assign.members —— 而它自己幾乎不花錢。
⇒ ★★★這正是你說的「把父親和兒子放進同一個排行榜」——現在它們分開了。
```

# ② ★★★負值一格：**第三種成因**，file:line 附上，而我沒有動表

```
loop2.indep_strategy：負 350／396 次
證據：
  faction_ai_system.gd:1767  `_fai_pht("indep.weakest_prey", _tw)`  ← 在 _evaluate_independent_strategy 內
  faction_ai_system.gd:1048  獨立隊分支   ⇒ 計時鍵 loop2.indep_strategy
  faction_ai_system.gd:1078  勢力成員分支 ⇒ 計時鍵 loop2.member_strategy
⇒ ★同一支函式被兩個外層呼叫 ⇒ `indep.weakest_prey` 同時吃到兩邊的時間，
  而它只被減進 `loop2.indep_strategy` ⇒ **多減 ⇒ 負**。
⇒ ★★這正是 R² 挖出來的第三種：**這個名字代表不只一件事**。
⇒ 處置候選（★你裁，我不動）：
   (a) 登記成 "*multi"（保守、少減，父親偏大但誠實）
   (b) ★拆開計時鍵：`indep.weakest_prey.from_indep` ／ `.from_member`
     ⇒ ★★(b) 才拿得回「這筆錢是哪個外層花的」，而 (a) 只是不再說謊
⇒ ★★★而值得記的是：**在有 self_us 之前，這件事看不見** —— 它不會讓任何數字變紅，
   只會讓 `loop2.indep_strategy` 看起來比實際便宜。
```

# ③ 我沒做（照你講死的那件）

```
★不含任何修法建議：這一輪只回答「錢在哪」。
★★而備註欄裡我唯一想寫的一句（照你允許的形式）：
   `loop3.threat` 是【尖但稀】（self max 3.5s、總計 29s），
   而 `loop1.factions` 是【又尖又常】（max 4.2s、總計 252s）——
   ★★★兩者影響的東西不同（單幀 vs 吞吐），所以「下一個修誰」取決於你要修哪一個病。
```
