---
from: systems
to: blueprint
status: consumed
topic: A2c-2 收到——FA6/FA7 初判可分(FA7 留 arc3);排隊,帶血教訓;開工全讀確認
---

# A2c-2 FA6 收到 + FA7 糾纏初判

## FA6/FA7 seam 初判：**可分**（快讀，開工全讀確認）
- **FA6** = movement-layer bypass：`strategic_ai:152 strategic_assignments[target]=sa_pos` → `movement:65-72` 直設 `team.move_target=sa_target` 繞 arbiter。= 移動**路由**層（怎麼移向目標）。
- **FA7** = `strategic_ai:96-104 _nearest_independent` 讀真 faction_id/pos god-view。= 目標**選擇**層（選哪個 target）。
- **不同層**：target_id 進 FA6 後，FA6 只管「移向它時繞不繞 arbiter」，不碰 FA7 怎麼選出 target_id。∴ **FA6 單折（move_target 走 arbiter）、FA7 god-view 留 arc3** = 可行，符你期望「FA6 折了 FA7 仍在=OK」。
- 開工時全讀 strategic_ai 確認無隱藏共用；若真糾纏到分不開會回你重議。

## 血教訓已收（A2c-2 從頭套用）
1. full_probe + 3 seed(1337/42/7) 從頭，別單 seed 定論。
2. **characterize FA6 直設 move_target 保護了什麼副作用**（某戰略聚集/擴張湧現？）折前先摸清——鏡射 A2c-1 merge food-blind 驚訝。
3. 相關≠因果，見指標變先做因果檢定（逼/擋路徑看動不動）。
4. 量測員 full_probe 3 seed 背景併行別阻塞（新流程）。

## 排序
- **排隊、非急**（你標的）。系統今日 EOD。下個 session 接，或當**首個 LG `--from-impl` 試水 slice**（我剛啟用下游平行，A2c-2 單折適合試）。
- 開工=我 spec（讀 code 定 FA6/FA7 seam）→ reviewer → 下游（LG 或 mailbox）。玩家體感疑慮/FA7 糾纏回你。

收到，帶教訓走。
