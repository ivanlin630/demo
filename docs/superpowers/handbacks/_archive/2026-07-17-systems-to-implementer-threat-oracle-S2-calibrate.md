---
from: systems
to: implementer
status: consumed
topic: "[裁定+calibrate·S2 over-shoot] 單元對(方向/四象限)但 organic 揭 threat 碾平經濟(迎戰 44-105x/economy→0)=blueprint② 禁的偽裝硬閘在 scale 現形,非設計意圖。calibrate down:THREAT_BOOST_FLOOR 0.6→1.0(boost 只在真高威脅)、THREAT_BOOST_MAX 1.2→0.5、迎戰加 k_conf=0.6 dampen(好戰×severity×modulate×0.6)、SEVERITY_MAX 1.5→1.2。tune-loop:改值→to:measurer organic 2-3seed(迎戰率 moderate+economy 進程非零)→未收斂再調。方向/零fall-through/cap 架構不動,只常數。"
---

# S2 calibrate：over-shoot 收斂（threat 碾平經濟修）

## 裁定
單元/結構層全對（方向/四象限/2 R² char bed/gate/dissolution）——**但 organic scale 揭 over-shoot**：迎戰 44-105x 暴增 + economy 聚落進程歸零（seed1337 全滅/seed42 部分）。這 = **blueprint② 明禁的「threat 碾平 trade=偽裝硬閘」在族群 scale 現形**（char bed 窄構造 R² 場景1 過，但 organic 破——threat option 系統性碾壓）。**非設計意圖**（blueprint「emergent cost 不設閘」是資源後果，非 threat util 碾平選項）→ calibrate down。
- **★教訓**：behavior-change 的 R² 驗收場景須 organic scale 驗，非只 char bed 窄構造（measurer 補做 organic 抓到，好活）。

## calibrate（架構/方向/cap-原則不動，只 TEST VALUE 常數收斂）
第一輪值（tune-loop 初值，未收斂再調）：
- **THREAT_BOOST_FLOOR: 0.6 → 1.0**（boost 只在**真高威脅**觸發，非每個 threat_react≥0.6 都 boost——現況 floor 太低=boost 常 fire=碾平主因）。
- **THREAT_BOOST_MAX: 1.2 → 0.5**（boost 弱化,threat 競秤但不碾壓;仍 < SURVIVAL_BOOST_MAX 2.5）。
- **迎戰加 dampen k_conf=0.6**：`好戰 × severity × modulate_win × 0.6`（迎戰 base 過強是 44x 主因之一）。
- **SEVERITY_MAX: 1.5 → 1.2**（severity 量級整體收）。
- 備戰/求和/FLEE 式不動（迎戰是碾平主犯;備戰普遍升是意圖）。若調後求和仍過高再議。

## tune-loop
1. 改上列常數 → commit。
2. → **to:measurer organic 2-3 seed×2mo**：迎戰選中率（目標 **moderate 上升非 44x**——threat 有意義但不碾平）+ **economy 進程非零**（build_outpost/farm/merge/rung 恢復，非歸零）+ 四象限 char bed 仍 PASS（方向不變）。
3. 未收斂（迎戰仍暴增 or economy 仍受重壓）→ measurer 回報數字，我再調常數（可能再降 BOOST_MAX/k_conf or 升 FLOOR）。收斂=threat 有意義 + settlement game 存活。

## 目標（blueprint 原則:threat 該重 + 別碾平 trade + emergent cost 資源扛）
threat-response 隨威脅**有意義上升**（severity-scaling 意圖保）**但**經濟/聚落 game 存活（迎戰不系統性碾壓 develop/trade）。converged 結果我送 blueprint 覆審 macro 平衡（how warlike 是他 vision）。

## 溯源
S2 measurer organic 揭 over-shoot（`2026-07-17-measurer-to-systems-threat-oracle-S2-verified.md`）；blueprint② cap=零殘留硬要求（uncapped/過強=偽裝硬閘）；spec §S2 measure R² 場景1（organic scale 才真驗）。
