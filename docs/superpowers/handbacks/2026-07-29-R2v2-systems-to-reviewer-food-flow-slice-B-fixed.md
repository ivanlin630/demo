---
from: systems
to: reviewer
status: open
topic: "[R²v2·糧流SLICE B訂正你3項(必回)·①硬性:配糧改sub.resources.food(frac-split實際持有非carry_capacity重量上限空放行)+B1建通用食物撥付top-up=第5真新建(food從不因cost補OUTPOST_COST無food key)+礦山bootstrap 2651-2674收編取代非疊加②引用改_dispatch_builder:2603-2698(非1250-1252母隊獨立隊路無子隊)③hunt_ev隊技能非tile+既有hunt_preview:40-46非新建+折扣公式候選(clampf(wild_game/expected_take)或e^遞減)B2 R²具體·spec同檔更新] 3項全訂正。①硬性已改sub.resources.food+top-up第5真新建。請複審→CLEAN→implementer B1。"
---

# R²v2：糧流 SLICE B 訂正你 3 項

你 R² ISSUES 全對（異質 file:line 抓），訂正如下（spec 同檔 §2/§3 已更新）：

## ①★★硬性訂正：配糧測 sub.resources.food + 第 5 真新建 top-up
- **carry_capacity（重量上限）≠實際糧**你抓對（gate 空放行=修了等於沒修假陰性）。改：go/no-go 測 **`子隊實際糧 = sub.resources.food`**（dispatch frac-split `pop_count/parent.pop×parent.food`，subteam:36-40）vs `burn×ETA×safe_margin`。
- **★第 5 真新建（被「配糧」措辭蓋住）＝通用食物撥付/top-up**：food 從不因 cost 補（OUTPOST_COST 無 food key、`_fund_subteam` 只補 cost dict）→ B1 建通用糧 top-up（母隊撥 food 到子隊夠 burn×ETA，不夠則 no-go）。**礦山 ad-hoc bootstrap（2651-2674）B1 通用糧橋收編取代**（+2721 upgrade 同款），非兩層補貼疊加。

## ②引用訂正
真派建造子隊 = **`_dispatch_builder`（faction_ai:2603-2698，經 `_dispatch_goal_delegate`:2836）**，非 1250-1252（`_evaluate_independent_strategy` 母隊獨立隊路、`parent_team_id!=-1 return`、無子隊 create）。spec §2 已改標。

## ③打獵 EV 訂正
- **hunt_ev = hunt_chance × hunt_yield 是隊技能算非 tile**（tile 只決定有無獵物/耗盡）；★既有 `hunt_preview`（:40-46）純算術可抽=**非新建**，禁呼 `hunt_small_game`（:22 randf 污染）。
- **★折扣公式候選（B2 R² 具體落）**：`route_ev = Σ hunt_ev × discount(wild_game)`，`discount=clampf(wild_game/expected_take,0,1)` 或 `e^(−cumulative/stock)`——B2 dispatch 前定，非 implementer 發揮。規模訂正：B2 真工作量=路線聚合+折扣（非發明 hunt 公式）。

## ★reviewer focus（複審訂正）
1. **①sub.resources.food + top-up 真擋 A1 victim 否**（實際糧非重量上限、food 從不 cost 補→top-up 第 5 真新建、礦山 bootstrap 收編非疊加）？
2. ②引用 `_dispatch_builder:2603-2698` 對否？
3. ③折扣公式候選合理否（B2 R² 具體）+ hunt_ev 措辭訂正對否？

**CLEAN → implementer B1（糧橋+top-up+派遣閘、harvest-only inflow、解 A1 真 victim）→ measurer → QA A1 子隊真不餓死。** 有洞 → 回 `to:systems`。
