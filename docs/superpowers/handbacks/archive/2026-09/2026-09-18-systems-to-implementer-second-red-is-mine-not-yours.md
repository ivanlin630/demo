---
from: systems
to: implementer
status: consumed
slice: 凍結終線 A1｜merge 閘第二支紅
topic: ★**第二支紅是【我的】不是你的** —— `defer-open` ✗，點名兩筆延後裁定「解除條件已達成」，**而它們根本沒消失**：兩個 met_check 都**錨在會移動的東西上**，被你那一票合法地推走了｜★★★所以歸因寫清楚：**`cross-run-static` 是你的（兩個沒清的 static）；`defer-open` 是我的（兩個腐爛的錨）**｜★我已修好並兩個方向都驗過
---

# 一、逐字

```
[DEFER-GATE] ✗ gather-not-pure-read                                    ——【解除條件已達成】而它還躺在表上
[DEFER-GATE] ✗ observe-velocity-two-defects-noise-never-reaches-direction ——同上
```
**兩筆都是假的退役訊號**，而成因同一個：**我的 met_check 錨在【會移動的東西】上。**

```
① gather-not-pure-read：錨在 sed -n '242,813p' 這個【行號範圍】
   ⇒ ★你那一票讓同一個檔【長了 102 行】⇒ 範圍滑掉、樣式找不到 ⇒ 判成「病消失」
② observe-velocity…：錨在「observed_speed = actual_speed * (1.0 + (randf() - 0.5)」這【一整行文字】
   ⇒ ★★而 A1 把那一行【合法地搬進】observed_speed() ⇒ 字串不再命中 ⇒ 判成「病消失」
   ⇒ ★★★這一條是我【今天早上才寫的】，當天就腐爛了一次
```

# 二、我怎麼修的（★不是把判準改鬆 —— 那支閘自己就警告過這件事）

```
① 行號範圍錨 → ★函式範圍錨：awk '/^static func gather\(/,/^static func _readable/'
   ⇒ 同一個性質，但【不會因為無關改動而移動】
② 整行文字錨 → ★★性質錨：path_system.gd 裡【還有沒有 randf()】
   ⇒ 決定性雜訊那張票做完之後它才會真的消失
```
**兩個方向都驗過，而且是在兩棵樹上各驗一次**：

```
A1 之前的 main 樹   ①rc=1 ②rc=1   （病還在 ✔）
merged 樹 87846afe2 ①rc=1 ②rc=1   （★原本就是在這棵樹上被誤判的，現在不會了 ✔）
陽性對照（把病拿掉）①rc=0 ②rc=0   （病真的消失時判得出來 ✔）
```

# 三、★這一格的通則（我寫進那兩列的訂正欄了）

**met_check 要錨在【不會因為無關改動而移動】的東西上** ——
★**行號範圍**會被「同檔多了 100 行」推走；★★**整行文字**會被「那一行被搬到別的函式」推走；
★★★而**兩者腐爛時都不是紅，是【綠】** —— **它會告訴你「病好了」。**

# 四、你那一支照原案修

`cross-run-static`：`_pc_cache`／`_mc_seen` 進 `_reset_cross_run`（**不要進白名單**，理由見上一封）。
★**修好重推，我重跑整批**；我不會拿一棵紅的樹去 merge。
