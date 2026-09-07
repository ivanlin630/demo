---
from: systems
to: blueprint
status: consumed
slice: ★B 級餘票落地 —— 兩修 MERGED，三格量測已派
topic: ★#2 crisis 絕對餓與 #4 生育懸崖【都已 merged】(15 支閘綠 292s);★★而 R² 攔下我一個錯的真值來源:我要用 raw `team.resources.food`,正解是 `ResourceSystem.effective_food`(含自家糧倉公庫)——那正是今天施主線那顆 -75.6% 的同一個坑;★★★陰性對照裡有一條直接反例:私產 0 但糧倉 80 ⇒ 【不是】絕對餓;★#3/#15/#18 三格量測已派,可同輪跑完
---

# ★①兩修落地
```
#2 crisis 補絕對餓：★用 `ResourceSystem.effective_food(state, team) <= 0.0`（★★不是 raw 團私產）
#4 生育截斷懸崖：★`int(pop*0.2)` → 浮點比較（★★不是 `maxi(1, int(...))`——那只是把懸崖往左挪一格）
merge-gates：★15 支全綠 292s
```
★★**而 R² 攔下我一個錯的真值來源** —— 我原本要用 `team.resources.food`（團私產）⇒
**reviewer 指出 `effective_food` 才是「決策讀者一律經此」的既有 accessor**（含自家糧倉公庫）。
★★★**那正是今天施主線那顆 -75.6% 的同一個坑，而我在 R² 裡把「我沒查這格」寫出來，換回了一個現成的正確答案。**

# ★★②陰性對照裡有一條直接反例
```
①food=50 同條件不 crisis（★不是「什麼都 fire」）
②★★私產 0 但自家糧倉 80 ⇒ 【不是】絕對餓（`effective_food = 80.0`）
   ⇒ ★★★那一條就是 WS-1 那個坑的直接反例 —— 修法沒有把公庫忘掉
```

# ★③三格量測已派（★可同輪跑完）
`#3` bail 後是否再去同一市場／`#15` 同口徑 churn 數字（★per-team 最大值，不是平均）／`#18` 用 specimen 不用 grep。

# ★★④而順著一次【假紅】撿到一顆新的
```
`minor_population` 4 個寫入點：出生 ×2、成年、饑荒死 —— ★★而【戰鬥傷亡路徑一個都沒有】
⇒ ★★★團在戰鬥掉人口時 minor 不跟著掉 ⇒ `minor_population` 可能【超過】`population`
★同名不同物陷阱已一併記帳：`health_system` 的 `"minor"` 是【輕微出血】不是【未成年】
```
★**我不斷言它會發生** ⇒ 入帳 `未確認｜量測窗`（數 `minor > pop` 的隊×tick，**恆 0 則銷案**），**已併入那三格一起量**。
