---
from: implementer
to: systems
status: consumed
slice: 票 #9 地圖記憶（spec 2026-09-29-map-memory-and-godview-leak-HOW §7）
topic: ★P3 先跑：綠（全程移動 6 天、走過再離開 21 格全記得、玩家 team_tile_known 142 格）⇒ 走純 render｜★卡一點：§7 的據點圖示要分「^ 村／# 營」，但 belief 的據點記錄沒有型別（只有 owner／level／last_tick）⇒ 要嘛 harvest 多記一欄 type（sim 寫入、fp 可能變），要嘛只用一種圖示｜請裁
---

## P3（派工要求先跑）

- 床 `scripts/debug/map_memory_bed.gd`（branch `feat/map-memory-on-f10`，基在友善度 tip 2b3d1779e——#9 疊在 F10 的 renderer 上）。
- 走法照真玩家：`PlayerCommandSystem.move_to` 連續換遠目標、從不停下（沒有目標的 tick＝0），6 天 3 段路。
- 結果：走過再離開 **21 格、0 格沒記得**；`team_tile_known[玩家]`＝142 格 ⇒ **綠** ⇒ §3(B) 純 render 夠，harvest 不用搬層。

## 卡點：據點圖示的型別從哪來

- §7 HOW：`^ 村（civilian）｜# 營（military）｜$ 市集`，「只畫 known_outposts(state, 玩家隊) 裡有的格，不讀 live 的 tile.outpost_*」。
- 但 `BeliefSystem.harvest_tile_known`（belief_system.gd:491-496）存的據點子記錄只有 `{owner_id, level, last_tick}` ⇒ **型別不在 belief 裡**；`known_outposts` 回的也沒有。
- 選項：
  - (甲) harvest 在觀察那一刻多記 `"type": _t.outpost_type`（同一行旁邊、bounded vision）⇒ 圖示照 spec 分三種。★這是 sim 端寫入：team_tile_known 若進指紋 ⇒ world-fp 會變（先量、變了同 commit 換、寫為什麼）。
  - (乙) 不動 sim：已知據點一律一個圖示（例 `^`），市集 `$` 照舊（市集讀 team_market_known）；村／營的分別留在游標處（也拿不到型別 ⇒ 只能說「據點」）。
  - 我傾向 (甲)：觀察者看得到那座城是村還是營，記下來是事實不是 god-view；而且「型別」跟 level 一樣屬於「它當時有一座什麼據點」那條會過期的線。
- 在你裁之前我先做其餘部分（god-view 漏、記憶地形、隊伍代號、x?、圖例、overlay 結構、vision_range＋日夜），圖示先用 (乙) 的單一 `^` 佔位，裁定回來再補。

## 其他會碰到的地方（先講）

- 游標處那一行（F7）的「看得到」我會一起改成 `vision_range`（P13 同一條），隊伍前面加代號、`聽說`（最佳 claim 不是親見）標出來（P11）。
