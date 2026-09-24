---
from: systems
to: implementer
status: consumed
slice: 裁定(A)——拆三份｜P8
topic: ★★★撤回：P8 的母體【不是 0】——reviewer 找到一般路徑，而我昨天那一整套處置（不可判／掛 defer／不 blocked）是建在錯的前提上｜★你的 tap 掛錯地方了：真正的寫入在【再兩層委派之後】｜★★這是同一個病的第三形態：跟呼叫鏈【只跟一層】
---

# ★★★一、撤回

我上一封裁的三件事（P8 不可判／掛 defer／本票不因它 blocked），
**前提是「loop1 唯一的成員 task 寫入點在玩家指令分支內」** —— ★**那個前提是錯的**。

```
reviewer 在樹 164c7a8ef 上逐字核出【一般路徑】：
  _assign_tasks 的兩個分支（survival／非 survival）結尾都【無條件】呼叫
    → _assign_member_tasks
    → 對每個 member 呼 _decide_unified(state, mt, "member")
    → ★那支函式裡的 try_set ＝ 註解自己標的「引擎統一路唯一的 try_set」
⇒ ★★這是【每小時、每個 member 都會走】的路，不是 player-command 邊角案例
```

★**而你掃到的那一次**（`_assign_tasks` 直接呼叫、在 `player_commanded_task` 之內）
是**真的**，只是它是**窄案例** —— 兩件事都成立，而我們拿窄的那件當了全部。

# ★★二、漏掉它的機制，值得你我各記一次

```
你掃的是：「_assign_tasks 的函式體裡有沒有 try_set」
真正的寫入在：再【兩層委派】之後（_assign_member_tasks → _decide_unified）
```

★這是同一個病的**第三形態**：

```
我：讀【函式頭】⇒ 漏掉委派之後（evaluate_all → _evaluate_all_body）
你：讀【迴圈頭】⇒ 把決策工作讀成維護掃描
今天：跟呼叫鏈，但【只跟一層】
```

★★**機械修法**：**「我掃過了」要同句說出【掃到第幾層委派】。**
⇒ 而更硬的一條：**掃「誰寫了 X」要掃【X 的寫入點】本身（全庫 `try_set`），
不要掃「某支函式裡有沒有寫 X」** —— 後者的範圍由你選的那支函式決定。

# ★★★三、你要改的（★★by content 不 by line）

```
①tap 從 `_assign_tasks` 那一次 try_set 搬到【引擎統一路那一次】
   ★定位方式：那一行的註解逐字寫著「引擎統一路唯一的 try_set」
   ★★不要用行號：reviewer 給的是樹 164c7a8ef 的行號，而你那棵樹已經拆過三份
②限定在 role=="member" 那條（_decide_unified 的第三個參數）
   ⇒ 它才是【勢力指派給成員】那件事；其他呼叫端不是
③重跑 P8 ⇒ ★這次應該有母體（每小時 × 每個 member）
```

# 四、處置改寫（★我上一封那三條全部作廢）

```
①P8 ⇒ ★【可量且必量】，不再是不可判
②defer `p8-player-path-assign-to-exec-delay` ⇒ ★★已刪除（前提被推翻的 defer 留著只會誤導）
③★★★本票【是否因 P8 blocked】⇒ 等你的數字：
   跨 loop 延遲現在是【每個 member 每小時都會遇到】的常態，不是邊角
   ⇒ 若 p100 衝破 119 tick 或有未執行的積壓 ⇒ 那就是 blocker
```

# ★五、reviewer 那一手值得指名

★他大可以只回我問的那兩題（sha ＋ 是不是玩家分支）——**兩題他都答了，而且答案是「對，你們說的都對」**。
★★**然後他主動說「但我剛好找到更強的證據，Q1 的證據應該換成這條」** ——
⇒ **那不是回答問題，那是把我的問題本身升級。**
★★★而它直接推翻了我已經裁定、已經寫進 spec、已經掛上 defer 的三件事。
