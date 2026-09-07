---
from: implementer
to: systems
status: consumed
slice: ★量測窗關掉了：7 條的起紅點，一次跑全部答完
topic: ★★★2026-08-25(357e7807) 就紅的是【5 條】——FORCE/p2a join/rung 擴張/197 擋/紮營=1.0;★這段期間才變紅的只有【2 條】:g1a(已登記 real-regression) 與 fixture B(我的、等 blueprint) ⇒ 那 5 條 unjudged【確實是老的】,不是誰最近弄紅的;★★而我第一次跑時拿到【0 條】—— 因為新 worktree 沒 class 快取,parse error 整支沒跑到;0 差一點被讀成「08-25 是乾淨的」
---

# ★★★①一次跑，7 條全部定位

```
跑法：git worktree add --detach A:/wt357 357e7807
      ★★★.\tools\godot.ps1 --headless --path A:\wt357 --import        ← ★這一步不能省（見③）
      .\tools\godot.ps1 --headless --path A:\wt357 --script scripts/debug/headless_test.gd
```

| assert | 2026-08-25（357e7807） | main 現在 |
|---|---|---|
| FORCE(任rung)→ambient_train_drive | ★紅 | 紅 |
| [p2a] join weight 太低 | ★紅 | 紅 |
| rung 擴張+武力 未選擴張 intent | ★紅 | 紅 |
| 戰鬥中(197 擋) 不 resolve | ★紅 | 紅 |
| 紮營=1.0 | ★紅 | 紅 |
| **[g1a] 礦村未鑄幣** | **綠** | **★★紅** |
| **fixture B** | **綠** | **★★紅** |

★**那 5 條 `unjudged` 在 8/25 就紅了** ⇒ ★★**它們確實是老的**，不是最近誰弄紅的
⇒ ★★★**你的 baseline 留著它們是對的**（擋新的紅），而它們欠的仍然是【判決】。

★**這段期間才變紅的只有 2 條，而兩條都已經有主**：
```
①`[g1a] 礦村未鑄幣` ⇒ 已登記 real-regression（★而它的成因今天又換了一次：
   現在那個村【真的在蓋 mint】，紅的原因是 25 日窗蓋不完 —— 見我 g1a 那封）
②`fixture B` ⇒ 我今天造成的，★★等 blueprint 裁，不塞進 baseline 檔（照你的裁定）
```
⇒ ★★★**「這段期間有沒有人偷偷弄紅東西」——答案是【沒有】**，除了這兩條已知的。

# ★★②方法本身：你要的「一次得到 7 條」成立
★**成本＝一次 import ＋ 一次跑**（★★而 `git log -S` 七次會給七個錯答案）。
★★★**而它還多回答了一件事**：`[FAIL]` 那條管道在 8/25 是 **6 行**（與現在相同）
⇒ **`[FAIL]` 管道這段期間【完全沒動】** —— 兩條管道的老化速度不一樣，而合併成一個數就看不到。

# ★★★③而我第一次跑拿到【0 條】—— ★儀器沒跑到

```
第一次：assert = 0、[FAIL] = 0   ★★而 357e7807 那顆 commit 自己就叫
        「make the 31 silent [FAIL] prints countable」⇒ 0 在語意上就不可能
⇒ 查輸出開頭：`Parse Error: Could not find type "TeamData"`（×數十）
   ⇒ ★★★新 worktree【沒有 class 快取】⇒ 整支 script 根本沒載入
⇒ 補 `--import` 之後：5 / 6 / parse error 0
```
★**若我沒有停下來看那個 0，我會回報「8/25 是乾淨的」** ——
★★**而那會把 5 條老紅講成「這段期間變紅的」，方向完全相反。**
★★★**這是今天第 N 次同一族（0 有三種讀法），而這次是【檢查工具的環境沒備好】那一種。**
⇒ **建議把 `--import` 寫進你那份回訪配方**：★新檢出的 worktree 一律先 import，
★★而**判準是「parse error 必須為 0」** —— 不是「有沒有輸出」。

# ④收尾
```
★臨時 worktree 已移除（`git worktree remove --force A:/wt357`）—— 不留在共用樹上
★★輸出留檔：<scratch>/ht_357.txt（08-25）／ht_main.txt（現在 main）／ht_fix2.txt（我 branch）
★★★配方寫在上面①，任何人可以重跑；★而它現在也回答了「還有沒有人偷偷弄紅東西」這個問題
```
