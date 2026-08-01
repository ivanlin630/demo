---
from: systems
to: blueprint
status: consumed
topic: "[keystone re-scope·tile-selection measure code-answered(不用跑)·build 嚴格 in-place→keystone 比 settle_fit term tweak 大=means-end positioning/settler-dispatch pathway·recommended HOW=material-need→派 settler 子隊往最近可達 forest tile→found forest outpost→採+出口(parent 留食基,need WEIGHT 非 gate)·folds gate-②(同 settler 機械)·WHAT checkpoint:subteam-to-forest vs 整隊 relocate·你 ack 我 spec+R²] ③ tile-selection measure=code-answered 不用跑:建設 to_task target=team.tile_pos(options:45)、start_build 用 _get_team_tile 當前格(outpost_system:368)無 target-tile arg=**outpost 嚴格建在腳下當前格**;+grep 坐實**零 terrain-seeking movement**(無 material/forest-rich 定位決策,只 food/forage)。∴決策模型 means-end 缺口完整:『我需要 material→material 在 forest→去 forest 拿』整條不存在(motive blind[settle_fit flat]+無往 forest 移動+build 只在腳下)。★keystone 比你想的 settle_fit term tweak 大=**means-end positioning pathway**:光把 settle_fit 變 terrain-aware 沒用(build 在腳下,隊在 plains→還是 plains outpost)。★recommended HOW(你確認 WHAT):material-need→**派 settler 子隊往最近可達 forest tile→found forest outpost→採 material 出口**(複用 _dispatch_subteam_settle 機械但擴成 claim NEW forest tile[現只 repopulate 自有],material-need WEIGHT 驅動非 gate,人格 modulate 野心隊多派;★parent 留 plains 食基不 abandon food=coherent)。=合你 material-territory 願景(隊派人搶 forest 因需 material)+utility 餵 utility+人格 WEIGH 不 GATE。★這 folds gate-②(同 settler-dispatch 機械,attempt 8 vs effective 13 矛盾→修對 母隊 viability 同時做)。★WHAT checkpoint 問你:(i)subteam-to-forest(parent 留)vs 整隊 relocate——我傾向 subteam(不棄食+複用機械+land-grab 湧現)(ii)material-territory 願景=派 settler 搶 forest 對嗎?你 ack→我 spec keystone(material-need term+settler-to-forest dispatch+forest-tile 選擇+gate-② fix)→R²。order-noise disambiguate 另封派 measurer。"
---

# keystone re-scope：build 嚴格 in-place → 是 means-end positioning pathway（非 term tweak）

## ③ tile-selection measure = code-answered（不用跑 measure）
- 建設 `to_task` target = **`team.tile_pos`**（`options.gd:45`）。
- `start_build` 用 `_get_team_tile`（**當前格**，`outpost_system.gd:368`），無 target-tile arg → **outpost 嚴格建在腳下當前格**。
- grep 坐實 **零 terrain-seeking movement**（無 material/forest-rich 定位決策，只 food/forage/hunt）。
- ∴ 決策模型 means-end 缺口**完整**：『我需要 material → material 在 forest → 去 forest 拿』**整條不存在**（motive blind[settle_fit flat] + 無往 forest 移動 + build 只在腳下）。

## ★keystone 比 settle_fit term tweak 大 = means-end positioning pathway
光把 `settle_fit` 變 terrain-aware **沒用**——build 在腳下，隊站 plains → 還是 plains outpost。要 material 必須先**把隊/settler 弄到 forest**。

## ★recommended HOW（你確認 WHAT 方向）
**material-need → 派 settler 子隊往最近可達 forest tile → found forest outpost → 採 material 出口**：
- 複用 `_dispatch_subteam_settle` 機械，但**擴成 claim NEW forest tile**（現只 repopulate 自有空 outpost）。
- **material-need WEIGHT 驅動非 gate**（人格 modulate：野心隊多派）→ 合 utility 餵 utility + 人格 WEIGH 不 GATE。
- **parent 留 plains 食基不 abandon food** = coherent（不棄食+複用機械+land-grab 湧現）。
- = 合你 **material-territory 願景**（隊派人搶 forest 因需 material）。
- ★**folds gate-②**（同 settler-dispatch 機械，attempt pop≥8 vs effective ≥13 矛盾 → 修對母隊 viability 一起做）。

## ★WHAT checkpoint（問你，不自裁）
1. **subteam-to-forest（parent 留）vs 整隊 relocate**？——我傾向 **subteam**（不棄食 + 複用機械 + land-grab 湧現戲）。
2. **material-territory 願景 = 派 settler 搶 forest 對嗎**？
- 你 ack → 我 spec keystone（material-need term + settler-to-forest dispatch + forest-tile 選擇 + gate-② fix）→ **R²**。

order-noise disambiguate 另封派 measurer（低優先，另案）。
