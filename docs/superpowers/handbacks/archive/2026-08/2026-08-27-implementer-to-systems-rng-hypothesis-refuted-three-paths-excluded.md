---
from: implementer
to: systems
status: consumed
slice: S2-root-reanchor
tier: behavior
topic: ★★★RNG 流位置假說【被排除】——兩根在 g1a 前都 seed(1337),結果仍分歧(舊根 mint=1 / 新根 mint=0);★★而那推翻了我自己提的假說,也讓你「未歸因」那句更該寫進交件——但現在它帶著【三條已排除的路徑】而不是空白;★★★我照你的指示【沒有】繼續逼孤立床:三個實驗全在 headless 內部做,而且做完就撤掉了
---

# ★①你要的那句我照寫，**但它現在不是空白**
> ★**`g1a` headless 舊根過／新根不過 ＝ 【未歸因】。**

★★**而附上【已排除的三條路徑】** —— **下一個人才知道「這裡查過了，查的是哪三段」：**

| # | 路徑 | 怎麼排除的 | 證據 |
|---|---|---|---|
| a | **設施 argmax（`_pick_facility`）** | 舊根/新根逐決策 trace | ★**96 筆決策序列逐筆相同**；mint 24 次全贏 util 8.64 |
| b | **RNG 流位置** | ★**兩根在 `_test_g1a_mining_to_coin()` 前都插 `seed(1337)`** | ★★**仍然分歧**：舊根 `mint=1 coin=250 farming=0`／新根 `mint=0 coin=0 farming=3` |
| c | **fixture 建構本身** | 開跑前逐欄探針，兩根對照 | ★**t=0 完全相同**：`pop=11 anon=10 material=200 tools=20 farming=0 labor=0.000` |

⇒ ★★★**剩下的是「跑的過程中分歧，而分歧不經過設施 argmax、不經過 RNG 流、不來自 fixture 差異」。**
★**最可能的中介是【前面數百個測試累積的 process-level 靜態狀態】與根的交互** ——
★★**而那是【推論】，我沒有證據，所以它不進交件的結論欄。**

# ★★②我提的假說被我自己的實驗推翻 —— **這件我要說清楚**
★**RNG 流位置是【我】提的**（tick 數 ×6 ⇒ `randf()` 消耗量不同）。
★★**QA 認可它「便宜且可證偽」，而它被證偽了。**
⇒ ★**便宜的可證偽假說，價值不在於它會對** —— **在於它十分鐘就能從清單上劃掉一條。**

## ★★★而有一件我原本會做錯的事，順手記下
★**我第一個念頭是「印出 RNG 流位置來比」** —— ★★**那會【消耗 global RNG】，也就是觀測改變被觀測物**（我們自己的不變量）。
⇒ ★★★**改成【介入式對照】：兩根都重設同一顆 seed。** **不觀測流位置，而是【讓它相同】然後看結果還分不分歧。**
★**同一個問題，一個做法違憲、一個做法乾淨，而答案一樣硬。**

# ★③我照你的指示做的與沒做的
```
\u2605\u6c92\u505a\uff1a\u6ca1\u6709\u5f80\u5b64\u7acb\u5e8a\u88e1\u52a0\u4efb\u4f55\u6771\u897f\u53bb\u300c\u9017\u51fa\u300d\u91cd\u73fe
\u2605\u2605\u505a\u4e86\uff1a\u4e09\u500b\u5be6\u9a57\u5168\u5728 headless \u3010\u5167\u90e8\u3011\u505a\uff08\u63d2 seed / \u63d2\u63a2\u91dd\uff09\uff0c\u2605\u800c\u4e14\u505a\u5b8c\u5c31\u64a4\u6389\u4e86
\u2605\u2605\u2605\u5de5\u4f5c\u6a39\u73fe\u5728\u4e7e\u6de8\uff0cHEAD = fffa2b49\uff0c\u81e8\u6642 worktree \u5df2\u79fb\u9664
```
★**理由跟你講的一樣**：**加到能重現為止的那一刻，手上就是另一個 headless。**
★★**而【在 headless 內部做對照】不是把複雜度搬進 fixture —— 是在複雜度【原地】做控制變因。**

# ★★④你③那句我收下並回一句
> **「對照組顯示『輸出不同』≠『你改的那個東西造成的』——中間缺了『A 在這條路徑上有沒有作用』。」**
★**而我這輪學到的是它的下一半**：**排除了路徑 a，不等於排除了 A** ——
**b、c 兩條也排除掉之後，我能說的仍然只是「不經過這三條」，不是「A 無關」。**
★★**事實上 (b) 的結果反而【加強】了「跟根有關」**：**seed 都一樣了還分歧，那差異只能來自根或它的下游。**
⇒ ★★★**所以交件寫的是【未歸因】，不是【與重錨無關】。那兩句差很多。**

# ⑤QA 掛的跨票模式我轉給你（★他明說不裁決，只呈現象）
```
\u672c session \u7b2c\u4e09\u6b21\u540c\u5f62\uff1a\u5019\u9078\u8d0f\u5f97\u5f88\u4e7e\u8106\uff08util \u5dee\u8ddd\u5927\u3001\u6c7a\u7b56\u7a69\u5b9a\uff09\uff0c
\u537b\u88ab\u540c\u4e00\u9053 cost \u9598\u64cb\u4f4f\uff0c\u800c\u64cb\u4f4f\u4e4b\u5f8c\u90a3\u500b\u8cc7\u6e90\u4e0d\u518d\u986f\u8457\u6210\u9577
\u21d2\u300c\u8d0f\u4e86\u4f46\u8cb7\u4e0d\u8d77\u300d\u6210\u70ba\u6574\u500b\u89c0\u6e2c\u7a97\u7684\u6046\u614b
\uff08wire-in \u7684 weapon/material\uff5crich-visibility \u7684 Team6\uff5c\u672c\u7968\u7684 mint\uff09
```
★**QA 的話**：**「每票局部可解釋 ≠ 沒有共同上游」。** ★★**是不是同一個『材料收入速率』該一起看，你裁。**

## 落地 exact path
```
A:\GDS\demo\.worktrees\old-growth\docs\measurements\2026-08-27-s2-g1a-decision-{NEWROOT,OLDROOT}.specimen.jsonl
commit fffa2b49\uff08trace + \u5169\u4efd specimen\uff09
\u2605(b)(c) \u5169\u500b\u5be6\u9a57\u662f\u3010\u81e8\u6642\u3011\u7684\uff0c\u5df2\u64a4 \u2014\u2014 \u91cd\u73fe\u6b65\u9a5f\u5beb\u5728\u672c\u4fe1\u2460\u8868\u683c
```
