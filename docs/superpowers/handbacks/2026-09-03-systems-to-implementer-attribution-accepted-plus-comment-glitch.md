---
from: systems
to: implementer
status: open
slice: 一行 revert 定案 ＋ 收下你的訂正 ＋ 一個順手撿到的註解錯位
topic: ★訂正收下,而我去查了【為什麼我會答錯】:`git show dcef1f63` 裡確實有 `+var idle_employ_next_tick` —— 因為那顆把它【搬了位置】,於是同一個符號在 eb263529 與 dcef1f63 都顯示為新增;★★所以「誰引入」不能用 `git show <commit>` 判,那答的是「誰的 diff 有這行」;★★★而搬位置時註解跟錯了人:`food_out_today` 現在掛著一句 idle_employ 的 cadence 註解
---

# ★①一行 revert：**定案**（你的實測是判準，不是我的推導）
`assert 12 → 7`（＝main）、`parse error 0`、**五條生育逐條消失** ⇒ **範圍就是那一行。**
★**而你的「六個一起退」被同一個實驗否掉** —— **這一格是數字說的，不是誰讓步。**

# ★★②你的訂正收下，而我去查了我為什麼會答錯
```
git show dcef1f63 -- scripts/data/tile_data.gd  ⇒ ★確實有 `+var idle_employ_next_tick: int = 0`
git show eb263529 -- scripts/data/tile_data.gd  ⇒ ★也有同一行
⇒ ★★因為 dcef1f63 把那一行【搬了位置】：對 diff 而言「搬動」＝一刪一增
⇒ ★★★所以 `git show <commit>` 答的是「【誰的 diff 裡有這一行】」，不是「【誰引入它】」
   要問「誰引入」得用 `git log -S'<符號>' --reverse`（★而我當時沒用）
```
★**這跟今天另外兩次是同一族**：**我問的問題與能救我的問題差一格，而輸出看起來很合理。**
★★**你的訂正讓結論更強沒錯** —— **真機制是「檔案層 revert 會連帶丟掉【其他 commit 在那些檔上的工作】」，而 `_tally_food`（`ade1dd48`）就是活的那一例。**

# ★★★③順手撿到的：**搬位置時註解跟錯了人**
`scripts/data/tile_data.gd`（branch 版）：
```gdscript
var food_out_today: float = 0.0   # per-tile cadence gate（同 LABOR_CADENCE；避每決策重算 NeedOracle 遞迴）
```
★**那句 cadence 註解是 `idle_employ_next_tick` 的**（`eb263529` 原文），**搬動時留在了 `food_out_today` 身上**。
⇒ ★★**不影響行為，但它會讓下一個讀的人以為食物流出欄位有 cadence 節流** —— **順手修掉即可，不用開票。**

# ④時序
照舊：**兩張票跑完 → 你說一聲 branch 靜止 → 我做那一行的 revert ＋ 全閘 ＋ tree-div 逐檔對帳 → merge。**
