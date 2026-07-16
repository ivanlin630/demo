---
from: implementer
to: systems
status: consumed
topic: observer 設施全欄 + 據點列表完成——query 測 32/32；GUI 手驗待用戶
---

# observer 續：設施全欄 + 據點列表 — 完成

worktree `feat/observer-inspect` @ `a8bfe3b`（接 15b6de7）。

## #2 設施全欄（真缺陷修）
- `query_outpost` 回 **`facilities_nonzero`**（iterate `OutpostSystem.FACILITY_DEF`，各 `current_level_key` tile level >0 才收，DRY=權威在 FACILITY_DEF，未來加設施自動出）；**移除單獨 `weaponsmith_level` 欄**（併入）。
- `+FACILITY_LABEL`（8 設施中文）+ `facility_label()`。
- panel `_outpost_lines` 設施行改列 `facilities_nonzero`（「設施：農場Lv3 冶煉廠Lv1」；空「（無設施）」）——team 附段 + select_tile 詳情共用。

## #1 據點列表面板
- `query_all_outposts(state)`：iterate `state.world.tiles`，據點濾（`outpost_type!="" and level>0`）→ 摘要（pos/type/level/owner_team/faction/facility_count），sort by tile_id 穩定。+`ObserverBridge` wrapper。
- panel 加第二 `ItemList`「據點」，`item_selected → select_tile(tpos)`（複用據點詳情路）。
- 與隊列表**並存**、sentinel 互斥：點據點列表→`_selected_tile` 設 + `_selected` 清 + 隊列表 deselect；點隊/select_team→據點列表 deselect。`select_tile` 反向高亮對應據點列項。`refresh()` 週期重建兩列表、雙 sentinel 正確反映。

## 閘（全綠）
| 閘 | 結果 |
|---|---|
| `--headless --import` | 無 error |
| query 測（擴充） | **32/32 PASS**：`facilities_nonzero`（civ farming=3/mint=1、mil weaponsmith=2/smeltery=1、weaponsmith_level 單欄已移除）；`query_all_outposts`（3 據點、非據點格不入、facility_count） |
| `constitution_gate` | `PASS (sites=30, removed=0)` |

## 待用戶手驗
- 據點列表可瀏覽 + 點選 → 據點詳情（全設施非零）。
- 隊/據點兩列表切換無殘留（sentinel 互斥）。
- 點 owner 駐隊據點方塊 → 隊詳情附「駐守據點」段含全設施。

read-only 不動 sim。完成判定 systems + 用戶手驗。
