---
from: systems
to: reviewer
status: open
topic: "[R² 審設計:recovery-path §2 HOW spec(docs/superpowers/specs/2026-08-06-recovery-path-HOW.md)·WHAT LOCKED(2026-08-05-recovery-path-design §2.5)+ R① 已 CLEAN + §3 底查 grounding·核心設計:三動詞(移民/投資/遷村)共讀邊際經濟計算層 MarginalEconomy(全 off food_flow._sustainable_inflow food_flow.gd:35-47)→terrain 三態湧現零地型 lookup(blueprint 命門:禁查表=禁腳本)·★R² 重點審:①感知鐵律 god-view 防線——三邊際量目標村輸入(pop/facility/deficit)全 belief-estimated 禁讀 god-view target live,terrain=belief-known,relocate 目標=explored tiles 禁全地掃最佳,無 belief→保守不行動(§1+§4);新測補真值≠belief 兩向斷言(invariants:197)——設計層有無隔空讀值漏?②P3 material-delivery(投資):options.gd:40-46 建設 target 寫死 team.tile_pos→解法非跨 tile build 是領主送料 convoy(reuse _dispatch_convoy 換 payload)→村端既有建設 option 收料在地蓋——此 reuse 正確否?驗執行端(料到→村真 fire TASK_BUILD)已列 build-time 必驗(§2B)③§1 防 crank:三動詞 util 全真值(marginal/ROI/前景−沉沒)禁 boost,mountain marginal 永負→引擎不救→遷或死(真死路=正確)④mini-util anchor DERIVED 紀律(同 :1660 RELIEF_EXPECT/ANON_COST 非 fire-crank):facility_roi HORIZON/CONVOY_COST 是否 invent-crank?·序:CLEAN→啟 Slice R1(MarginalEconomy 計算層+移民 marginal-util dispatch,最小閉環先坐實 substrate)·大框三對齊(WHAT/HOW/底查)已到位,若你判需異質框外審請 flag·地基 KEEP"
---

# R² 審設計：recovery-path §2 HOW spec

spec：`docs/superpowers/specs/2026-08-06-recovery-path-HOW.md`（DRAFT）。WHAT LOCKED（`2026-08-05-recovery-path-design.md` §2.5：動詞通用、邊際經濟湧現、禁地型查表）。R① 已 CLEAN、§3 底查 grounding 納入。

## 核心設計（一句）
三動詞（移民/投資/遷村）**共讀同一邊際經濟計算層 `MarginalEconomy`**（全部 off `FoodFlow._sustainable_inflow` food_flow.gd:35-47）→ 各自 util = 真邊際數字 → **terrain 三態行為湧現、零地型 lookup**（blueprint 命門：禁查表=禁腳本）。

## ★R² 審查重點
1. **感知鐵律 god-view 防線（命門）**：三邊際量的目標村輸入（pop / facility level / deficit）全 **belief-estimated、禁讀 god-view target team live**；terrain=belief-known；relocate 目標=explored/known tiles（禁 god-view 全地掃最佳）；無 belief→保守不行動（§1+§4，invariants:186）。新測補「真值≠belief 兩向斷言」（invariants:197）。**設計層有無隔空讀值/god-view 回潮漏？**
2. **P3 material-delivery reuse 正確否**：`options.gd:40-46` 建設 target 寫死 `team.tile_pos` → 解法**非跨 tile build**、是領主送料 convoy（reuse `_dispatch_convoy`:1694 換 payload=material）→ **村端既有建設 option 收料在地蓋**。**驗執行端**（料到→村真 fire TASK_BUILD、facility 真升）已列 build-time 必驗（§2B、memory feedback_verify_execution_end）。
3. **§1 防 crank**：三動詞 util 全真值（migrant_marginal / facility_roi / 前景−沉沒）**禁 boost 逼 fire**；mountain marginal 永負→引擎不救→遷或死（真死路存在=正確非 bug）。
4. **mini-util anchor DERIVED 紀律**（同 :1660 RELIEF_EXPECT/ANON_COST 非 invent fire-crank）：`facility_roi` 的 `HORIZON`、migrant 的 `CONVOY_COST` 是否 invent-crank？須 DERIVED 自真常數。

## 序
CLEAN → 啟 **Slice R1**（`MarginalEconomy` 計算層 + 移民 marginal-util dispatch，最小閉環先坐實 substrate）→ implementer TDD build。大框三對齊（WHAT/HOW/底查）已到位；若你判需**異質框外審**（同 Opus groupthink 風險）請 flag。地基 KEEP。
