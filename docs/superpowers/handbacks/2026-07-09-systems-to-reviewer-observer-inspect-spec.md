---
from: systems
to: reviewer
status: consumed
topic: 審 observer inspect 擴充 spec（隊全資源 + 據點 inspect，read-only）
---

# 請審：observer inspect 擴充 spec

spec：`docs/superpowers/specs/2026-07-09-observer-inspect-expand.md`

## 背景
藍圖 WHAT（用戶親提兩缺口）：①隊詳情只露 food+coin，18 資源藏著 ②據點無 inspect path。read-only god-view，系統自決 seam 不需藍圖 sign-off。並行 A2c-1。

## 請對抗審（read-only 低風險，重 seam 正確性/DTO 完整）
1. **`query_outpost` 邊界**：`state.world.tiles.get(tpos)` null / `outpost_type==""` / `outpost_level<=0` 回 `{}` 是否漏 case（e.g. outpost_owner=-1 無主但有 level 的中立據點該不該顯示——spec 現以 type+level 判存在、owner 另欄，對嗎）。
2. **owner team_id→faction 轉換**：`_owner_faction_of` 讀 `state.teams.get(owner).faction_id`，owner team 已滅（id 存但 team 沒了）時 `team_label` 回「隊N(已滅)」、faction 回 ""——這 graceful degrade 對嗎，或該標「原主已滅」。
3. **複用 vs 新 panel**：spec 傾向 `ObserverInspectPanel` 加 `select_tile` 與 team 詳情互斥切換（`_selected`/`_selected_tile` sentinel）。有無 state 混淆風險（map pick 隊 vs tile 交替）。
4. **`tile_selected` 既有 emit 複用**：`world_map_view.gd:277` 點空 tile 已 emit，spec 只在 observer_main 接。核此 signal 真的 always emit（非只玩家模式；`_observer` 分支內 :277 在 here.is_empty() 時 emit，對嗎）。
5. **field 名**：`HexTileData`（非 TileData）的 outpost_type/level/owner/weaponsmith_level/garrison/resources/resource_cap 名稱正確否。

無異議即鎖 spec 排下游（並行 A2c-1）。回信 to:systems status:open。
