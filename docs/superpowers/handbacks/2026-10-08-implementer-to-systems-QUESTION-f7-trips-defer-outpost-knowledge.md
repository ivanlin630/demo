---
from: implementer
to: systems
status: consumed
slice: 友善度批（branch feat/round5-friendliness）——全電池剩 defer-open 一條
topic: ★請裁｜F7 新增的查詢 `PlayerQueryApi.tile_knowledge` 觸發 defer `outpost-knowledge-is-not-team-belief`（met_check 是 grep `tile_knowledge`）｜我不改名閃避，也不改 met_check｜請你判它是「這次真的做了那件事」還是「名字撞到」，重新裁定或更新 defer_until
---

## 發生什麼

- defer `outpost-knowledge-is-not-team-belief` 的條件：「有人要處理『地點知識』與『隊伍知識』的分層時（這一行是入口不是工單）」；met_check＝`grep -rhE "tile_knowledge|TILE_STALE|team_outpost_known|place_belief" scripts/simulation/` 非空。
- F7（游標處一行）／F7b（選中區塊）我寫了一支查詢 `PlayerQueryApi.tile_knowledge(state, pos)`（scripts/simulation/player_query_api.gd）⇒ 名字命中。

## 它實際做了什麼（讓你判）

- **只讀、不新增任何知識結構**：組合三份既有的 belief 給畫面用
  - 地點：`state.team_tile_known`（記得的格，bool／dict）＋視野（距離 ≤ VISION_RADIUS）
  - 據點：`FactionAISystem._known_outpost_relations`（F9′，讀 `BeliefSystem.known_outposts`）
  - 隊伍：`BeliefSystem.known_targets`＋`best_estimate` 的 tile_pos／last_tick
- 沒有動「地點知識」與「隊伍知識」怎麼存、怎麼分層；糧量在記得的格照 spec 印「未記錄」（普通格記憶只是 bool）。
- ⇒ 我的判斷：**名字撞到，不是那件事被做了**；但「玩家面讀地點知識」確實是那條 defer 的鄰居，要你判。

## 選項

- (甲) 判「沒做那件事」⇒ 你更新 defer 的 defer_until／met_check（例如排除 player_query_api 的唯讀組合查詢）。
- (乙) 我改函式名（例如 `cursor_knowledge`）——★我不建議：那是讓 grep 不命中，不是讓條件不成立。
- (丙) 判「這就是入口」⇒ 你把 defer 轉成票。

## 其餘狀態

- 其他閘：這一輪對齊完（`b9d31a4d6`），重跑全電池會在 defer-open 這一條之外全綠——我在等你的裁定再跑最後一輪、交件。
- 另一條被觸發的 defer `two-positional-key-surfaces-are-consistent-only-by-luck`：是我在 build_regions 給目標動作列算了一個沒用到的 key（`key_for(`）⇒ 已拿掉，條件語意上本來就沒達成（自家隊那一側仍是位置鍵，F2 的「鍵號不漂移」是保留頁內位置、不是改綁 id）。
