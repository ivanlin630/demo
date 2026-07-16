---
from: systems
to: implementer
status: consumed
topic: observer 據點點擊無詳情——靜態鏈全對，runtime bug，帶診斷除錯（feat/observer-inspect）
---

# observer 據點 inspect：GUI 點擊無詳情（用戶手驗抓）

worktree `feat/observer-inspect`。用戶手驗：資源顯示 OK（gap1 過）；**據點方塊有畫、可見**，但**點空地方塊右面板不跳詳情**（連「此格無據點」都沒？需你確認）。

## 我已驗（靜態鏈全對，排除以下）
- wiring：`observer_main.gd:143` `_map.tile_selected → _inspect.select_tile` ✅ 接了。
- `select_tile`(:58) 設 `_selected_tile`；`_render_detail`(:80) `_selected_tile!=(-1,-1)→_render_outpost_detail`(:125)→`query_outpost` ✅。
- key：`query_outpost` 用 `tpos.x*1000+tpos.y`；`world.tiles` keyed by `tile_id = ox*1000+oy`；`tile_pos=Vector2i(ox,oy)` ✅ 匹配。
- 座標系：`pixel_to_hex` 回 `(c,r)` 用 `_hex_center(c,r)`，與 draw 的 `_hex_center(tpos.x,tpos.y)` 同系 → 點擊 hex == tile_pos ✅。
- headless 測 24/24 過（含 query_outpost civ/mil/無主/非據點）。

## ∴ runtime bug，嫌疑（你 GUI 跑得動，逐一驗）
1. **click 沒到 `_unhandled_input`**：inspect 面板/其他 Control 吃掉 event？`_observer` flag？加 print 在 `world_map_view:265 _unhandled_input` 頂 + `:277 tile_selected.emit` 前確認 emit。
2. **`select_tile` 有被呼但 `_detail` 沒更新**：print in `_render_outpost_detail` 頂 + query 回傳。看是 query 回 {}（→座標沒中據點=precision）還是根本沒進來（→signal 沒接通 runtime）。
3. **click precision**：方塊小(4-8px)，點到鄰格空 tile → query {} → 「此格無據點」。若是此=discoverability，非 signal bug。
4. **refresh() 覆蓋**：週期 `refresh()`(:54,0.25s) 呼 `_render_detail`——確認沒把 `_selected_tile` 洗掉或 team-list select 蓋回隊詳情。

## 順帶（用戶原始痛點，spec 缺陷我認）
- **被隊佔的據點點不到**（`tile_selected` 只在 `here.is_empty()` emit，:274）：多數據點有 owner 駐隊 → 點選到隊、據點永遠點不到 + 圓圈蓋掉方塊。**修向**：點隊時若該格有據點→team 詳情附據點段（誰的+誰守正是重點）；或方塊畫於隊圓圈之上/offset。這條併入本 bug 修。

## 完後
handback to:systems status:open 報根因 + 修法 + 重手驗。read-only 不動 sim。
