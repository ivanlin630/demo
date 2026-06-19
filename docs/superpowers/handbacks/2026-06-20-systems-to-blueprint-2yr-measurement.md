---
from: systems
to: blueprint
status: consumed
topic: 2 年長期世界量測定論 — emergent 魂「真沒條件非沒跑夠久」+ 首輪 3 待裁更新
ruling: 見 2026-06-20-blueprint-to-systems-measurement-rulings.md。#1 履約+囤積壓力都YES(=root,最高優先)；#2 信假對但0裁決過頭→修技能spread不修門檻；#3 場景YES但先修#1重量再定。
---

# 2 年長期世界量測定論（承首輪 `spine-measurement`）

首輪（90 天 game_sim_test 有玩家）你已收。問題：玩家死→game_over 凍世界→量不到長期 emergent。已建純 NPC 長跑量測台（`world_sim`，無玩家→世界跑滿 2 年）重量。**結論性負結果**，更新首輪 3 待裁。

## 關鍵定論：emergent 魂 = 真沒條件，不是沒跑夠久

90 天 vs 2 年（同 harness 無玩家，**8× 時長**）：

| 訊號 | 90 天 | 2 年 | 判讀 |
|---|---|---|---|
| order/ambition/detect/trust | 隨時長 scale | scale | 時間線性，正常 |
| **立國 faction_found** | 0 | 0 | ❌ |
| **復仇 vendetta** | 0 | 0 | ❌ |
| **血仇 feud** | 0 | 0 | ❌ |
| **scout 查證** | 0 | 0 | ❌ |
| **誘殺 ambush** | 0 | 0 | ❌ |
| **鑄幣 mint** | 0 | 0 | ❌ |

8× 時長，6 條魂全 0。SpineTrace 全程佐證：2 年無一條社會連結成形（feud/gratitude/trust 邊恆 0、vendetta 恆 -1）。bump site 已逐鍵確認真存在（非探針沒接）。

→ **首輪待裁 #3 定論**：預設 8 隊 config **永遠造不出觸發條件**（不確定攻擊+偽裝、血仇對、立國路徑、鑄幣 outpost）。**跑再久都不會自己長出來。要量這 6 條魂，必須設專門觸發場景。**

## 首輪 3 待裁 — 2 年數據更新

### #1 G1 訂單履約 0% → 跑久**不會自閉**
90 天 0%、2 年 0%（order_placed 572→3873 持續發、fulfilled 恆 0）。訂單只 expire 不成交。**附證**：末態食物囤積 4–5 萬（無消耗/腐壞壓力）→ 經濟半空轉，同源。
**問藍圖**：訂單該真履約（買單→賣方/商隊送達扣量）還是「撲空=需求訊號不保證成交」就是設計？囤積是否該有消耗/腐壞壓力？= G1 經濟閉環 WHAT。

### #2 識破裁決恆 0 → 跑久**不出現**
90 天 12/2/0、2 年 31/2/0（信假/生疑/裁決）。謊幾乎全被信、零裁決。leader 技能在此 config 偏低 → detection 永遠輸。
**問藍圖**：預期（亂世多數被騙、識破要強 NPC）還是過頭？= 調 DETECT 門檻 / 鋪高技能 NPC / 接受。feel 你定。

### #3 觸發場景 → **由 2 年數據證實為「缺場景」**
非缺時長（上方定論）。
**問藍圖**：要不要排專門觸發場景 config 來驗這 6 條魂？量哪些 feel、各場景該長什麼樣（偽裝誘殺對局 / 預置血仇 / 立國競逐 / 鑄幣經濟）= WHAT。系統可建場景台（world_sim 已是底），但量什麼你定。

## 系統域（不佔你決策，回報知會）
- **#4 trust 飽和**（首輪報）：2 年 down5578/up3228，reconcile 每觀察 tick 重跑。我自評修。
- **known_reputations 懸空死隊 bug**（world_sim 強審計揭 ~2380 violations）：隊死後重注入。良性但 audit 噪。系統 systematic-debug 修。

## 待你回
- #1 G1 閉環 WHAT（含囤積消耗壓力）
- #2 識破 feel 方向
- #3 觸發場景：要做嗎、量哪些、各場景願景

（量測台 world_sim 已建好，藍圖一旦定 #3 場景願景 → 系統建對應 config 即可量。）
