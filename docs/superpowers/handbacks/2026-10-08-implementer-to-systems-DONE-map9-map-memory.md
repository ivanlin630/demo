---
from: implementer
to: systems
status: open
slice: 票 #9 地圖記憶（spec 2026-09-29-map-memory-and-godview-leak-HOW＋裁甲 0995cbbe2）
topic: ★交件、已併 main 20e37f90d（分支 tip 0cae4181a）｜全電池 118 支綠（5c05aa423，BATTERY_RC=0，摘要 docs/measurements/.battery/49104-20261008-180046.txt 在 .worktrees/mm2neg）｜world-fp 不變（707534a…）｜負對照 9 支全紅｜★順手修一個床抓到的洞：游標處在「沒去過」的格提早 return，地圖畫了 a? 游標處卻只說沒去過
---

## 做了什麼（照 spec §7／§8＋裁甲）

- **據點型別記在觀察裡**：`belief_system.gd` 據點子記錄加 `"type"`（唯一寫入點）；`known_outposts` 回傳帶 `type`。床斷言「每一筆都有 type」，不寫後備圖示。
- **renderer 只讀 belief overlay**（`scripts/ui/text_map_renderer.gd`）：`_cell` 不收 HexTileData（結構上讀不到 live 據點欄，檔內 `outpost_` 0 次）；優先序 @ ＞ 隊伍字母 ＞ ^村／#營／$市集 ＞ a?（belief_pos，同一條 3 天過期線）＞ 大寫（視野）＞ 小寫（team_tile_known）＞ ?。刪 `explored = in_vision` 與 TODO。
- **代號表一份**：`TextMapRenderer.team_codes`（a–z 去 f m p，23 個，第 24 支起 *；母體＝看得到＋belief 未過期，按 team_id）。地圖、右欄可互動目標（「[1] b Team5 …」）、游標處都經 `sim_bridge.get_team_codes` 讀同一份。
- **看得到＝vision_range(玩家隊, 日夜倍率)**：`sim_bridge.get_vision_mult()` 用 runner 那一顆 DayNightSystem（純讀）；地圖大寫區與游標處同一支。
- **游標處**：記得的隊改走 belief_pos（與地圖 a? 同線），帶 `heard`（最佳 claim 不是自己親見＝聽說，判法同 belief_system 的 firsthand）；印「b Team5（聽說，第 …）」。`best_claim` 從 `best_estimate` 抽出（best_estimate 回傳不變）。
- **圖例**：`TextMapRenderer.LEGEND`＝「@你 a隊 ^村 #營 $市集 a?記得 P看見 p記得 ?未知」，地圖框標題讀它。★第一輪電池終端自驗 (e-1) 紅：原本 56 欄，上框左半只裝得下 ~48 ⇒ 縮到 46 欄。

## 床格與證據

- `scripts/debug/map_memory_bed.gd`（invariant，註冊 `map-memory`）：P3、T、P1、P2、P10/P7c、P11（含游標處聽說）、P7b、P7（# 型別來自 belief／小寫／五層同幀）、P9、P12、P13、靜態 P4／P9b／P7e／P8。修前紅 13、P3／P9／P9b／P12／P2 修前即綠（守衛）。
- P7d 在 E2E：`terminal_e2e_bed.gd` 新格 **MM7D**（兩支看得到的隊：地圖字母＝游標處＝右欄，逐支）。
- R5F7 空地格原本用 `VISION_RADIUS` 常數挑「視野內」，現在權威是 vision_range ⇒ 床前提改讀同一支（不是放寬斷言）。
- 普查：`player_query_api._remembered_teams_at` 登記 A 類（live-team-census）。

## 負對照（detached worktree `.worktrees/mm2neg`，一次改回一處，跑完還原）

| 改回 | 紅的格 |
|---|---|
| belief 不寫 type | T |
| 視野回 VISION_RADIUS 常數 | P13 |
| heard 恆 false | P11 游標處 |
| 過期線兩處都拿掉（overlay＋team_codes） | P2 |
| 不畫記得的地形 | P7 ×2 |
| 字母表含 p | P7e |
| 圖例漏 $ | P8 |
| 右欄不印代號 | MM7D |

★誠實限：過期線**只拿掉其中一處**時床照綠——overlay 跟 team_codes 各守一道（代號母體本身就排除過期的隊），單改一處被另一處遮住；兩處一起拿掉才紅。

## 順手修（床抓到的）

- `PlayerQueryApi.tile_knowledge`：沒去過的格原本直接回 `{"status":"unvisited"}` ⇒ belief 記得在那裡的隊不會出現在游標處，而地圖在那一格畫 a?。改成 unvisited 也帶 `teams`；游標處印「沒去過｜隊伍：a Team5（聽說，…）」。

## 下一步

照序：#9 已併 ⇒ 換你合併 E2E（已知紅 0）→ 藍圖真跑 → 第五輪邀請。我回深層批，照你的序拿下一張（A2c rebase＋重量 fp 先）。
