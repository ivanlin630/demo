---
from: blueprint
to: qa
status: consumed
topic: "[★用戶要:別重量、看現成資料坐實『130隊怎麼來』·現成非凍驗run1(docs/measurements/2026-07-31-nonfreeze-verify-1337-run1.json 42778B+.txt 2.2MB,6mo warring seed1337)已含答案·★preliminary(我從verdict摘要數字):人口444→387(↓淨死12.84%)但隊數~91→133(↑)=非人口增加是FRAGMENTATION(縮水人口碎成更多更小隊,avg~7→~3人/隊)·我上則theorize『生>死人口淨長』錯(沒查現成資料猜反,session教訓又犯)·★求QA挖run1現成檔坐實:①人口vs隊數逐月軌跡(確認pop↓teams↑碎裂非成長)②★team-creation源breakdown:6mo裡新隊主要哪來(unrest_split警壓分裂?population overflow?beast spawn?subteam?reaction?manpower?)——raw log/probe counts應有g1或創隊事件·③avg team size趨勢(碎化程度)·★別重跑(用戶明令)、只讀run1既有output·這定『為什麼130隊』的真源→我才知煞車踩哪(整併?調unrest分裂?beast cull?)] 用戶要:別重量、QA看run1現成檔。preliminary=人口↓(444→387)隊數↑(91→133)=碎裂非成長,我猜反了。求QA坐實:①pop vs teams逐月②team-creation源breakdown(unrest-split?overflow?beast?誰狂生隊)③avg隊size。只讀既有run1 output別重跑。"
---

# ★用戶令：別重量，QA 看現成 run1 資料坐實「130 隊怎麼來」

## 背景
measurer 附帶發現：warring 世界膨脹到 130+ 隊（超 memory 目標 50）+ O(N²) per-tick 成本。用戶問「為什麼」，**明令別重跑量測、用現成資料**（非凍驗 run1 6mo 已產出）。

## ★preliminary（我從 verdict 摘要數字，待你坐實）
- **人口 444→387（↓，淨死 12.84%）** 但 **隊數 ~91→133（↑）** = **不是人口增加、是 FRAGMENTATION**（縮水的人口碎成更多更小的隊，avg ~7→~3 人/隊）。
- 我上則 theorize「生>死、人口淨長」= **錯**（沒查現成資料、猜反，session 教訓又犯）。**所以請你用資料坐實、別信我的摘要推論。**

## 求 QA 挖現成檔（別重跑）
讀 `docs/measurements/2026-07-31-nonfreeze-verify-1337-run1.json`（42778B）+ `.txt`（2.2MB，6mo warring seed1337 raw log）：
1. **人口 vs 隊數逐月軌跡**（確認 pop↓ teams↑ 碎裂、非成長）。
2. **★team-creation 源 breakdown**：6mo 裡新隊**主要哪來**——`unrest_split`（warring 壓力鬧分裂）？`population overflow`？`beast spawn`？`subteam`？`reaction`？`manpower`？（raw log 的創隊 print / probe counts 應可拆）。
3. **avg team size 趨勢**（碎化程度）。

## 為什麼要這個
**「為什麼 130 隊」的真源坐實了，才知道煞車踩哪**：整併小隊？調 unrest 分裂率？beast cull？——別又猜。**只讀既有 run1 output，別重跑**（用戶明令、warring 6mo 貴）。

## 序
QA 讀 run1 → 回我「pop/teams 軌跡 + 創隊源 breakdown + avg size」→ 我據此跟 systems 談效率/世界樣貌怎麼治。**非緊急、不擋現 flow-fix merge**（那條 determinism 驗跑它的）。

## 溯源
`2026-08-01-measurer-to-blueprint-warring-perf-scaling-finding`（已 consumed，O(N²)+130隊）；用戶令「別重量、QA 看上次結果」+ 我 pop-growth 誤判被用戶戳。
