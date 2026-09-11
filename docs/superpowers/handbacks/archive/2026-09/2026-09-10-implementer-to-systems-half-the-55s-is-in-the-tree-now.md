---
from: implementer
to: systems
status: consumed
slice: 相位樹 v4 ｜ 守衛移位 ＋ 納母體
topic: ★守衛移到 `rank_scored` 入口（母體 733 → 1096）＋成對對照床三格綠｜★★而 55.62 s **只納進來一半**：`from_subteam` 107 次／6.79 s 已在樹上，**`from_solo_body` 仍在另一個容器**（solo 在 `evaluate_all` 之外）—— ★★★這不是遺漏，是【兩個容器】要先被裁｜★榜首**沒有換人**（leader 211.96 s），而 v3→v4 **不可逐格相比**（樣本 196 → 675）
---

★落地：`docs/measurements/2026-09-10-phase-tree-self-us-v4.txt`（commit `96ddbc2bd`）
  ＋ 成對對照床 `scripts/debug/rank_src_guard_bed.gd`

# ① 守衛移位（你給的修法，照做）

```
`unified.rank.from_<src>` 的累加點：`faction_ai_system.gd:3212`（母體 733 次）
  ⇒ 搬進 `DecisionEngine.rank_scored` 入口（母體 **1096 次**＝真母體）
★成對對照（床，三格全綠）：
  ①不帶 src 呼叫 ⇒ 報告【具名】列出 `unified.rank.from_unknown`（不是只說「有未登記」）
  ②帶 src ⇒ 同一條路不紅
  ③母體地板：兩趟各自的鍵都真的出現在報告裡（★否則兩格都是「什麼都沒跑」的假綠/假紅）
★★而移位有一個【口徑副作用】，它自己就是一格證據：
  舊口徑含 `rank_scored` 之後那 90 行（reorder／funnel／dump）
  ⇒ `assign.leader_unified` 的 self 從 **0.09 s → 1.75 s**（tot 213.71、兒子 tot 211.96）
  ⇒ ★那 90 行只佔 0.8% —— 偏差不大，但它**掛在錯的名字下**，而現在掛對了。
```

# ② ★★55.62 s 只進來一半（★而另一半卡在【容器】不是【接線】）

```
`unified.rank.from_subteam`：**107 次／6.79 s，父親 `loop2.subteam`**
  ⇒ ★`loop2` 的子隊分支**本來連相位鍵都沒有** ⇒ 我新開了容器 `loop2.subteam`（root）
    ⇒ self 3.12 s／tot 9.91 s／kids 1 ⇒ 樹接對了（兒子被減掉）
`unified.rank.from_solo_body`：★**不在本表** —— solo 在 `evaluate_all` **之外**
  （錯開票把 `_evaluate_solo` 移出去了 ⇒ 它的帳在 `loop2.solo*` 那個容器，而本 dump 只印 evaluate_all 的 `_fai_ph`）
  ⇒ ★★所以「把 55.62 s 納進樹」目前**只做到一半**，而剩下那一半**不是接線問題**：
    要把它納進同一張表，得先決定【solo 的帳怎麼跟 evaluate_all 合併】——★★★那是你的裁量，我沒有做也沒有提做法。
`from_unknown`：**0 次** ⇒ 沒有第三個沒報名的呼叫端。
★★★訂正一則（上封我列了三個呼叫端）：`decision_engine.gd:484 rank()` **只被 debug 腳本呼叫**
  （`headless_test`／`buyfood_measure`），sim 內 **0 次** ⇒ 那 363 次全是 `:3773` ＋ `:4030`。
```

# ③ 榜（★★而它有一條硬的誠實限）

```
未登記 **0**／負 self **0**
1. unified.rank.from_leader  611 次  self 211.96 s
2. unified.rank.from_member  673 次  self 178.40 s
3. loop3.orders_ambition     675 次  self 172.67 s
4. loop3.misc                675 次  self 156.08 s
5. loop3.threat              675 次  self  52.07 s（tot 73.51、kids 1）
…（全表在檔裡）
★榜首**沒有換人**。
★★★而 v3（196 樣本）與 v4（675 樣本）**不可逐格相比**：
  分段計時的 Probe 讓每個 tick 變慢 ⇒ 更多 tick 越過 100 ms ⇒ **母體本身變了**
  ⇒ 所以我只講「順位」與「樹的形狀」，**不講任何 v3→v4 的百分比**
  （★而這正是上一封「兩個尺度的結論不可互換」的同一件事，只是這次換成了兩個母體。）
```

# ④ 我沒做的

```
①沒把 solo 容器與 evaluate_all 合併（見 §②）
②沒動任何 term／候選生成（你的序 ③ 還沒到）
③`loop2.subteam` 這個新容器是**我為了讓 `from_subteam` 有真父親而開的**
  ⇒ ★若你認為子隊的帳應該掛在別處（例如併進 `loop2.member_strategy`），這一格要退回改。
```
