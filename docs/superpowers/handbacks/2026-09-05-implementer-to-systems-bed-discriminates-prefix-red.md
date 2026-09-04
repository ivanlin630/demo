---
from: implementer
to: systems
status: consumed
slice: ★★★床的鑑別力【驗過了】：同一張床 main 紅、branch 綠
touches: `feat/colo-sight-control-bed` @ `6f622b6a`（★床檔複製到 `origin/main` 的 detached worktree 跑，main 樹沒被寫）
topic: ★★★同一張床兩邊跑:**main FAIL=1 ｜ branch FAIL=0**,而紅的正是設計來紅的那一格(G1 森林小 host,dist=0 `belief_pos=(-1,-1)`);★而陰性對照 G2(平原大 host)【兩邊都綠】⇒ 床不是「在 main 上什麼都紅」;★★另一個收穫:**main 上 G2 也是 `moved 0筆=48`／`resolve=0`** ⇒ 【JOIN resolve 只掛移動事件】是 **pre-existing**,不是這一刀帶進來的;★★★而 90 日窗**第五次被砍**,半卷已刪,照你的備案【不跑第六次】
---

# ★★★①鑑別力：同一張床、兩個 commit
| 場景 | `main`（cc63069c，★無這一刀） | `feat/old-growth-forest`（9dd5e337） |
|---|---|---|
| G1 森林·小 host dist=0（★設計來紅的） | **看見＝false ⇒ `[FAIL]`** | 看見＝true｜`saved_by_branch=98` ⇒ ✅ |
| G2 平原·大 host dist=0（★陰性對照） | 看見＝true ⇒ ✅ | 看見＝true｜`saved_by_branch=0` ⇒ ✅ |
| **總計 FAIL** | **1** | **0** |
```
★★G2 兩邊都綠 ⇒ **床不是「在 main 上什麼都紅」** —— 這一格才讓 G1 的紅有意義
★★★而 G1 紅的形狀正是預測的那個：dist=0、分數 0.16 < 0.3 ⇒ 機率閘擋掉 ⇒ `belief_pos=(-1,-1)`
   ⇒ 連 `commit JOIN` 都 false（★看不見就不會有 host 候選）
```

# ★★②順帶把 attribution 釘死（★這一條對你判 merge 有用）
```
★`main` 上 G2（看得見、`commit JOIN=true`、跑 48 tick）：
   `moved` 名單 **0 筆 = 48**｜`join.dispatch=0 meet_target=0 resolve=0`
⇒ ★★**【JOIN resolve 只掛移動事件】在 main 上就是這樣** —— **pre-existing，不是這一刀帶進來的**
⇒ ★★★所以「#4 不會綠」不能算在共位必見頭上；而你 `d82dadd9`／`276eddca` 已經獨立驗到同一條，兩邊對得起來
```

# ★③90 日窗第五次被砍 —— 照備案停
```
★`brvwfn6kl` 被砍｜半卷【已刪】不是「不引用」
★★照你 kill4 那封的備案：**不跑第六次 90 日** ⇒ 用控制床答「修好了沒有」
⇒ ★★★而誠實限照抄不改：**控制床證的是【機制通不通】，不是【世界裡多常發生】**
   ⇒ #3（`true<belief` 下降）與 #4 的【世界層數字】**目前沒有修後值**，我不編一個
★而若你要那個數字，我建議的形狀是：**merge 之後跟考程重跑一起量**（反正考程基線本來就要換一次）
   —— 而不是在 merge 前再賭一次 2.3 小時的窗
```

# ④現況
```
`feat/old-growth-forest` @ `9dd5e337`（＋origin/main merge）：#1/#2/#5/#6/#7 綠、#8 你已判定
`feat/colo-sight-control-bed` @ `6f622b6a`：床，★鑑別力已驗（本封）
★兩個 branch 都停著等你；★★而 `.worktrees/colo-ctrl`／`colo-main` 是我開的臨時 detached worktree
   —— ★★★用完我會拆，先留著是因為它們是【現在唯一能重跑這兩個數字的地方】
```
