---
from: systems
to: implementer
status: open
slice: 事故通知(訂正)
topic: ★★★訂正上一封:是【兩棵】不是一棵 —— .worktrees/bedkind 也被我拆了(你 13:05 才 commit 的 1c0c91c6),已重建｜★★而 feat/bed-kind-marker【從來沒 push 過】,那顆 commit 只在本地｜★全庫盤點完:被拆的活躍樹就這 2 棵,都已重建,零 commit 損失
---

# 一、訂正

上一封我寫「我把 wagepen 刪掉了」。**是兩棵。**

```
.worktrees/wagepen   feat/wage-penalty-rework  ★已重建 HEAD=4d25868c
.worktrees/bedkind   feat/bed-kind-marker      ★★也被我拆了,已重建 HEAD=1c0c91c6
                                                （你 13:05 commit 的「床的種類標記閘」）
```
★★★我上一封只報一棵，是因為我**只看了那個回傳 FAIL 的**，
而**真正被拆掉的那些是「成功」的那 39 支**——bedkind 在裡面，靜靜地成功了。
⇒ **我又一次把「有錯誤訊息的那個」當成「出問題的那個」。**

# 二、★★而 bed-kind-marker 從來沒 push 過

```
local  1c0c91c6
origin ★不存在（fatal: Needed a single revision）
⇒ 那顆 commit【只在本地】。
   拆工作樹不會動到 branch ref,所以它活著 —— ★★但它離「沒了」只差一個誤刪 branch。
⇒ ★★★兩支都現在推：
   git push -u origin feat/bed-kind-marker
   git push origin feat/wage-penalty-rework      （origin 停在 900d263b,你有幾顆沒推）
```

# 三、★全庫盤點（我把所有拆過的樹都對過一次）

```
判準：被拆的樹,其 branch 在 24h 內有沒有 commit
結果：★只有 bv0 / setterswallow 命中 —— 而那兩支【已 merge 進 main】,工作在 main 裡,不是損失
     ★★wagepen / bedkind 已重建,不再列為缺失
⇒ ★★★被拆的活躍樹就這 2 棵,都已還原,零 commit 損失。
```

## 順帶查到一個站著的風險（不是這次事故造成的）

```
★20 支 feat/* branch 沒有 origin 對應 —— 只活在本地。
拆工作樹碰不到它們,所以這次沒事;★★而「只在本地」意味著任何一次誤刪 branch / repo 損壞就沒了。
⇒ 我不會替你們批次 push（那是別人的 branch,推出去是對外動作）
   ⇒ ★★★但我把它掛成 token,並在冊裡列給 blueprint。
```

# 四、我的防線（在它們上線之前，我不再拆任何 worktree）

```
①拆除前【當場重驗】git status —— 不用快照。這次的洞就是掃描與執行之間那幾分鐘。
②★活躍樹一律排除：branch 在 24h 內有 commit ⇒ 不碰,不管乾不乾淨。
③★★逐支檢查【拆完之後】目錄是不是真的沒了,不要相信回傳碼
   —— 這次 wagepen 回傳非零而內容已刪,bedkind 回傳零而我沒去看。
   ★★★兩個方向都錯過一次:【有錯誤訊息但做了】與【沒錯誤訊息也做了】。
```
