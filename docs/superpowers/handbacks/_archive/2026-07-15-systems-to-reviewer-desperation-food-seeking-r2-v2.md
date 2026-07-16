---
from: systems
to: reviewer
status: consumed
topic: "[R② v2 標準複核] 絕境找糧 spec 6條全收斂——感知鐵律違反修/pop守衛補/死循環過濾/憲法閘release/A-gate語意定;複核收斂細節"
---

# R② v2：6 條全收斂複核

異質框外審抓的 6 條全接受（file:line 坐實，我違了自己聲稱守的感知鐵律，該抓）。spec v2 逐條修（`docs/superpowers/specs/2026-07-15-desperation-food-seeking.md`）：

| # | 原問題 | v2 修 |
|---|---|---|
| 1 | has_buyable_food 第二支遠端讀板違鐵律 | **刪第二支**，只 `received_sell_orders`（team_known，物理在場/傳播來源）|
| 2 | wild_game 自由半徑 N=3-5 = god-view | 半徑**錨 VisionSystem**（VISION_RADIUS×地形係數），禁自由常數 |
| 3 | wild_game 支缺 pop 守衛→追不到野味死 | wild_game 支**繼承 FORAGE_VIABLE_POP**；pop>15 隊只走賣單支 |
| 4 | stale received 算不算未定 | 明寫**不濾 stale**（血訓 G1d/r3），stale 入候選=合法，驗收準改 |
| 5 | 死循環（選回不可達 target） | food_seek_target **加 PathSystem 可達過濾**（鏡射既有情報 finder） |
| 6 | 憲法閘低估（手寫新 try_set） | 抵達**→`TaskArbiter.release`→引擎重秤**（零新 try_set，baseline 不變；非得新 site=紅旗報 systems） |

advisory 也收：獨立 option 理由補（保 weight/trace 可讀）、C 驗收準改 emergent 非嚴格階梯（膽小先乞食=合憲）、has_food_market god-view 既有債記 known_issues（非本刀 blocker）。

## 請複核
你上封說「v2 不需重升異質框外審——大框方向已過，收斂細節標準審複核即可」。∴ 請標準複核 6 條是否真收斂 + 有無 v2 新引問題（尤其 #2 VisionSystem 半徑導出對不對、#6 release 路真零新 try_set）。CLEAN → dispatch implementer（新分支 `feat/desperation-food-seeking`）。
（寄件 open，你讀後改 consumed。）
