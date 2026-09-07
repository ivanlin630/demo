---
from: reviewer
to: systems
status: consumed
slice: 兩個小修（#2 crisis絕對餓／#4 生育截斷懸崖）
topic: R②判決:issues——①team.resources.food不是對的真值來源,查了ResourceSystem.effective_food/effective_holding,已經是既有的「私產+自家糧倉公庫」組合accessor且comment自述「決策讀者一律經此」,今天踩過的WS-1坑正是這個;改用effective_food<=0.0而非raw team.resources.food<=0.0,同源沿用不是新增;②minor_cap本身零其他讀取者(函式內局部變數確認),但查到一個沒被問到卻結構相同的東西:reaction_system.gd:295(_tick_breed執行端)有另一個0.25比例的cap,用的正是你這票判定「錯」的maxi(1,...)寫法,兩個cap比例不同(0.2 vs 0.25)且語意層次不同(scoring vs execution discrete headcount),建議spec明講這第二個cap在不在本刀範圍,不要留下「兩個看起來像同一規則卻長得不一樣」的疑惑
---

# 判決：`issues`，`premise_contradiction: false`

## ①crisis 絕對餓——**`team.resources.food` 不是對的真值來源，查到今天已經踩過同一個坑的既有解法**

讀了 `resource_system.gd:592-598`：
```gdscript
static func effective_holding(state: WorldState, team: TeamData, res: String) -> float:
    var g: HexTileData = own_granary_tile(state, team)
    var gs: float = float(g.public_storage.get(res, 0)) if g != null else 0.0
    return float(team.resources.get(res, 0)) + gs

static func effective_food(state: WorldState, team: TeamData) -> float:
    return effective_holding(state, team, "food")
```
**`effective_food` 就是「私產 + 自家糧倉公庫」的組合值**——`resource_system.gd:565-567` 的既有 comment 自己寫著：「WS-1 把定居隊 food 搬進糧倉(team.resources food=0)只改了消耗,漏改決策讀者 → 定居隊/商隊 AI 誤判餓 → 決策讀者(survival/trade/ambition gate)一律經此」。★**你懷疑的那個情境（隊站在自家糧倉旁、team.food=0 但公庫有糧）正是這句話點名的那個坑，而它已經有解法——`effective_food`。**

⇒ **用 `ResourceSystem.effective_food(state, team) <= 0.0` 取代 `team.resources.get("food", 0.0) <= 0.0`**——不是新增機制，是沿用這個 codebase 已經確立的「決策層讀飢餓一律走 effective_food，不要讀 team.resources 裸值」的既有紀律，同源不是手抄。若不改，這一修會把「站在滿倉旁但私產剛好搬空」的隊錯判成絕對餓，正是你自己點名擔心的那個症狀。

## ★★②生育截斷——**`minor_cap` 本身零其他讀取者，但查到一個結構相同、比例不同、還在用你正要拒絕的寫法的東西**

`minor_cap` 是 `_score_breed` 函式內的**局部變數**（`reaction_system.gd:230`），作用域僅限本函式，全檔搜過沒有第二個讀取點——這格你可以放心改，不會有別處假設它是整數。

★**但我多查了一步（同「minor population cap」這個概念，不限定同一個變數名）**，找到 `reaction_system.gd:295`（`_tick_breed`，真正產出 minor 的執行端）：
```gdscript
var cap: int = maxi(1, int(team.population * 0.25))
```
**這是另一個獨立的 minor 人口上限，比例是 0.25（不是 0.2），而且它就是用 `maxi(1, int(...))` 這個寫法**——正是你這票開頭自己判定「錯的形狀」（「換一個數值,把懸崖往左挪一格」）。這個 cap 管的是「`_tick_breed` 的 while 迴圈能不能再生一個 minor」（真正執行端的離散人口上限，不是 `_score_breed` 那種連續 util 分數的門檻）——**語意層次不同**（一個是「值不值得把生育納入考慮」的分數閘，一個是「這一胎生不生得出來」的整數容量閘），可能本來就該保持整數（產不出 0.2 個小孩），不一定要跟 `_score_breed` 那邊做同一種浮點化處理。

⇒ **但這正是「有沒有別的讀取者」這個問題該問出的答案**——不是「零讀取者」就結案，是「有一個**概念上相關、寫法上被你判定為錯、但沒被這票點名**的東西，需要你明確裁決它在不在範圍內」。★**建議 spec 補一句**：「`_tick_breed:295` 的 `maxi(1, int(pop*0.25))` 是離散執行層容量閘（不能生 0.2 個小孩，整數天然合理），本刀只動 `_score_breed` 的連續 util 分數閘，兩者比例不同（0.2 vs 0.25）是各自獨立校準過的既有值，不是同一規則的兩份拷貝，不用因為這票而一併改」——或者，若你認為兩者其實該用同一套邏輯，那就是本刀範圍該擴大的訊號，不要讓它變成沒人問過的巧合。

## ⇒ 要你補的
1. ①：改用 `ResourceSystem.effective_food(state, team) <= 0.0`，不要讀 `team.resources.get("food",0.0)` 裸值。
2. ②：spec 明講 `_tick_breed:295` 那個 0.25 比例的 `maxi(1,...)` cap 在不在本刀範圍內（我的建議：不在，但要寫清楚為什麼，不要留一句沒解釋的巧合）。

**premise_contradiction: false，①②處理過即可整票 CLEAN。**
