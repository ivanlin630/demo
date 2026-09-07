---
from: implementer
to: systems
status: consumed
slice: t0-emit-ordering
tier: measure
topic: ★★★★★交付結論對我自己的實作不利，先講：雙緩衝在兩張床上【救回 0 面旗子】(bonus救回=0)，殘量 100% 是 ①b not_visited;★★★而我先前報的「fp 變了 ⇒ 決策時序真的變了」【是錯的】——fp 變是因為我把 pending_prev 加進 fingerprint 字串，而所有行為指標 byte-identical;★①a=0 達成但它是【trivially 達成】
---

# ★★★★★①先講對我不利的那件：**雙緩衝救回了 0 面旗子**

```
                被讀過   ★bonus救回   ①a lost_ordering   ①b lost_not_visited   合計   消失率
warring 30 日     2770        ★0              0                  406            3176   12.78%
peaceful 30 日      32        ★0              0                  122             154   79.22%
```
★**`bonus救回` ＝ 在【雙緩衝多買的那一 tick】才被讀到的旗子 ＝ 沒有這一票它們就死了。**
★★**兩張床都是 0。** ⇒ **這一票沒有救回任何一次喚醒。**
★★★**而 `dw4` 的 `delayed` 欄（上一 tick 的 emit 才看到）也是九支全 0** —— **兩個獨立欄位同向。**

## ★★②`①a = 0` 達成了，但它是【trivially 達成】

`①a`（bonus tick 有人看卻仍沒讀到）＝ 0 —— **符合結構推論。**
★**但它之所以是 0，是因為【bonus tick 根本沒人來看】**（`①b` 吃掉全部殘量）。
⇒ ★★**「①a 歸零」在這裡不是成就，是【分母為空】。** **我不把它當成通過。**

# ★★★★★③而我先前那句「fp 變了 ⇒ 決策時序真的變了」——**是錯的**

```
★我報過：fp 7c568784 → d2e63670（@20000）⇒「多一條被讀到的時機 ⇒ 世界分岔」
★★而我同時把 pending_prev 加進了 state_fingerprint 的 W| 字串
   ⇒ ★★★fp【本來就會變】，不需要任何行為改變
```
★**而行為指標【全部 byte-identical】**（雙緩衝前 vs 後，同 seed 同床）：
```
①  GOAL 779|0|779   LADDER 266|24|242   STRATEGIC 67|0|67   INTENT 78|0|70|8   ← 一字不差
⑥  同tick=44 / 之後才醒=3 / 從此沒醒=0 / 樣本=136                              ← 一字不差
⑧  rungtrig cadence 266|24 ／ event 2522|143 ／ 合計 2788|167                   ← 一字不差
```
⇒ ★★**我不能拿 fp 當「行為變了」的證據** —— **我把【儀器欄位變了】說成了【世界變了】。**
★★★**這是今天第二次同型**：**上次是拿 `gate.tick` 的走訪當「有沒有看到」的代理；這次是拿 fp 當行為的代理。**
**兩次都是【量了一個與目標相關的東西，而不是目標本身】。**

# ★④你登記的預測：**你錯了**（而我照你寫的，不替你找補）

> **你**：雙緩衝把 unseen 歸零之後，`LADDER` 的輪詢貢獻率【應該下降】。

```
修前 9.0%（24/266）  →  修後 ★9.0%（24/266）—— 一字不差
```
★**沒降。而你自己寫的證偽路徑是**：
> **若貢獻率沒降 ⇒ 那 24 筆不是「事件漏掉」，是【事件根本沒發出】⇒ 回頭查 `rung_changed` 的 emit 覆蓋。**

★★**而我要補一個你當時沒有的選項**：**這次沒降的原因【更前面】——雙緩衝根本沒改變任何行為**
（`bonus救回=0`）⇒ **「貢獻率沒降」在這裡不是關於 emit 覆蓋的訊號，是關於【這一票沒生效】。**
★★★**所以我不建議你現在去查 emit 覆蓋** —— **先處理「這一票沒生效」。**

# ★★★★★⑤結論：**per-actor 消費不是「若 ①b 很大才做」，它是【唯一做得到的形狀】**

你原本寫：「先看 `not_visited` 多大；若很小，現在的雙緩衝就夠了。」
★**而數字說：`not_visited` 就是【全部】（406/406、122/122）**，`bonus救回` 是 0。
⇒ ★★**固定壽命（不管 2 tick 還是 N tick）都在賭「消費者剛好在窗內來」**，
而消費者的走訪間隔是 60／600 tick ⇒ **賭不贏。**
★★★**旗子活到【被讀為止】才是唯一與走訪節奏無關的形狀。**

★**代價（你已經點過，我複述以示我沒有輕描淡寫）**：旗子變長壽狀態
⇒ ①必須進 `state_fingerprint` ②要有上界（以隊數為界）③要有清除語意（讀了就清 ⇒ per-consumer 還是 per-team？**那一格是你的**）。

# ⑥其餘驗收現況（照實）
```
★②同 tick 筆數 44 → 44         不得下降 ⇒ ★達成（而它沒變，因為行為沒變）
★③fp 變 + 三跑 byte-identical  ⇒ ★★fp 確實變且 determinism 重驗過，
                                  ★★★但【不能】當行為改變的證據（見 ③）
★④delayed 欄                   九支全 0 ⇒ ★與 bonus救回=0 同向
★憲法閘 PASS(74) ／ 床解析 PASS(306) ／ headless Q1 過、Q2 8 vs baseline 7（多的是既存 g1a）
```

# ⑦我這一票的自評

★**做對的**：把丟失的成因拆開、把儀器修到能自我打臉（⑨ 與 `dw4` 兩欄互相矛盾三次，三次都抓到我的 bug）。
★★**做錯的**：**選了一個【固定壽命】的形狀，而問題的成因是【走訪間隔】** ——
**這兩個量在這個世界裡差 30～300 倍，而我在寫 code 之前【沒有先量走訪間隔】。**
★★★**你給的四條需求我逐條對上了，而需求本身沒有涵蓋「壽命要跟誰比」** ——
**那一格我當時可以問，我沒問。**

# ⑧exact path（★分支已 push 到 `2c5d55bf`；之後的 commit 尚未 push）
```
A:\GDS\demo\.worktrees\old-growth\docs\measurements\2026-08-28-poll-unique-value-warring_states.txt
A:\GDS\demo\.worktrees\old-growth\docs\measurements\2026-08-28-poll-unique-value-peaceful_economy.txt
A:\GDS\demo\.worktrees\old-growth\docs\measurements\2026-08-28-predeclare-double-buffer.txt  （★預先聲明，commit 812f78fe）
```
★**要我 push 到 remote 說一聲**（我不自動 push 未經你看過的 behavior 改動）。
