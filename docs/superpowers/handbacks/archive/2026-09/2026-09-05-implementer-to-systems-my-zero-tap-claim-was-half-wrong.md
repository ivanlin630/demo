---
from: implementer
to: systems
status: consumed
slice: ★訂正：我說「格①零新 tap 就能算」——**只對了一半**，而我自己先踩了那個坑
touches: `scripts/debug/three_tickets_bed.gd`（★卷面補印，★★不在凍結範圍）
topic: ★★★tap 確實存在(`crisis.abs_hunger.team.<id>`,per-team 無 cap),★但**卷面只印前 8 名** ⇒ 21 隊裡 13 隊【在卷上不存在】⇒ 我的交叉腳本回 `starved distinct teams = **0**`,而真值是 **21**;★★也就是說我自己把【我找不到】讀成【沒有】—— 今天講過三次的同一件事,這次是我犯;★★★修法在【卷面】不在【世界】:`scripts/debug/` 不在凍結範圍,且只是多印字 ⇒ 零 RNG 零 state;而「所以世界不變」是【宣稱】,所以我給它自檢:重跑後比對 `fire 次數 8410` 與 `相異隊數 21`
---

# ★★★①我的話錯在哪（★精確地）
```
★我說：「production 已有 `crisis.abs_hunger.team.<id>`（per-team、無 cap）⇒ 零新 tap 就能算」
   ⇒ ★★前半【對】：那個 tap 真的存在，而且真的沒有 cap
   ⇒ ★★★後半【錯】：**卷面只把它印成「相異隊數 = 21｜前 8 名：…」**
     —— 而 `Probe.counts` 的原始 key【不會自己出現在卷上】
⇒ ★所以「零新 tap」成立，但「零新【卷面】」不成立 —— **而我把兩件事混成一句話**
```

# ★★②而我自己先踩了那個坑（★這一段我要留著）
```
交叉腳本輸出：`seed 1337: starved distinct teams = 0`
   ⇒ ★而真值是 **21**（卷上白紙黑字寫著「★相異隊數 = 21」）
⇒ ★★我的腳本 grep 的是 `crisis.abs_hunger.team.(\d+)`，而卷上那 21 個 id 只有 8 個以
   `team1=1440` 這種形狀出現、其餘 13 個【完全沒出現】
⇒ ★★★也就是【我找不到】被我的腳本輸出成【0】—— 而 0 看起來像個答案
★而它沒有害到任何人的唯一原因是：**我先跑了對帳**，而 `teams=0 vs decisions=4470` 太荒謬
   ⇒ ★★★對帳不是儀式，它今天第二次擋下我自己的錯（第一次是 `[INTERIM]` 那個 grep）
```

# ★③修法與它的自檢
```
★改的是 `scripts/debug/three_tickets_bed.gd`：多印一行【全名單（team_id:次數，降序）】
   ⇒ ★★`scripts/debug/` **不在凍結範圍**（凍的是 `scripts/simulation|scripts/data|config`）
   ⇒ ★★★而它只是多印字：零 RNG、零 state 改動
★而「所以世界逐位元不變」是【宣稱】⇒ 我給它一個自檢，用【卷上既有的兩個數字】：
   **`fire 次數 = 8410`** 與 **`相異隊數 = 21`**（seed 1337）
   ⇒ ★重跑後若這兩個變了，就是我這一改動【動到了世界】—— 而那會推翻上面整段
```

# ④在飛（★exact path）
```
跑批 `bvdqd80o3`｜三張｜落地 `…/scratchpad/r3b_{1337,42,7}.txt`
★舊的三張（`r3_*.txt`）**我先留著**——★★它們是自檢的對照組（比 8410／21）
   ⇒ ★★★比完之後才決定留哪一份當卷；**在那之前我不宣稱哪一份是基線**
```
