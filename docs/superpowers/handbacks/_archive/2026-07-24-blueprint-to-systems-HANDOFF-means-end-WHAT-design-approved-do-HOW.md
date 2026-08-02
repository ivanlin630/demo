---
from: blueprint
to: systems
status: consumed
topic: "[★HANDOFF·means-end/長程計畫 WHAT 設計定案+用戶核可→交你做 HOW 架構 spec+plan+slice·spec=docs/superpowers/specs/2026-07-24-long-range-planning-means-end-design.md·L1 大功能走 R①(新大框 factcheck)+R②(每 slice)+whole-system-first(建完當 whole 才 measure,別邊建邊 patch)·你 orientation=起始架構 map(擴 NeedOracle 沿鏈上傳+goal-as-chainable-option+宣告式 registry+投資折現,非新引擎)·material 續 PARK 到此建完] means-end/長程計畫系統 WHAT 設計 brainstorm 完+用戶核可(『Ok』),交你接手 HOW。設計在 `docs/superpowers/specs/2026-07-24-long-range-planning-means-end-design.md`。★摘要:機制全建(scope B:持久遠慾望 registry×means-end 依賴圖×applicability 湧現順序×折現/承諾)+內容全基礎層(food/material/tools/weapons/coin+所有設施,史詩後加資料)。脊椎=隊持久掛多慾望→宣告式 registry 拆子目標(前置五種:資源/定位/人力/設施/子目標)→applicable gate(前置滿才可選)→每 tick 挑當下最高 util applicable(順序湧現零腳本)→need 沿鏈上傳。多線=多慾望+委派是選項+多小隊平行+餘力配額+隱式協調(不建總參謀)。折現=投資型才折、人格當折現率(餓短視/穩遠視、權重非 gate)。承諾複用既有 hysteresis。有界=淺/只查 local applicable/無 plan-state(非復活 S2)。憲法=utility 餵 utility、人格 WEIGH 不 GATE、加 goal=加資料非 code。★你的工:①R①(這是新概念大框→寫 HOW spec 前 factcheck,尤其你 orientation 的『既有機械覆蓋度』斷言[option.applicable/rank_scored/NeedOracle 真能承載]要 code 坐實,別假設)②HOW 架構 spec(擴 NeedOracle 沿鏈上傳+goal-as-chainable-option+宣告式 registry+投資折現,補完整 map)③實作 plan+slice 切分(whole 建完才交付,但內部可分 slice)④R②每 slice⑤implementer。★紀律:whole-system-first(用戶原則②:整個建完當 whole 才回頭 measure 找不合理,別邊建邊 patch 症狀;建完前別 measure 個別症狀=broken 系統 measure 無意義)。★material 全續 PARK(伐木場/賽跑/regen/初始庫存/settle-motive/BUY/gate②)到此系統建完;建完後 material 供給側=下游 tuning 那時 measure 定。coin-liquidity(extract flat 0.4)也收進來=means-end『需 spendable coin→需 extract』自然涵蓋、取代 flat 閘。掛單噪音/hollow-economy=此根下游、自然消。★你 R① 若翻案設計某塊(如既有機械覆蓋不足需更多新增)回報我,WHAT 我調;純 HOW/架構/slice 你自主。開工。"
---

# ★HANDOFF：means-end/長程計畫 WHAT 設計定案 → 交 systems 做 HOW

## 狀態
WHAT 設計 brainstorm 完 + **用戶核可（「Ok」）**。交 systems 接手 HOW。
- **設計 spec**：`docs/superpowers/specs/2026-07-24-long-range-planning-means-end-design.md`（完整，12 節）。

## 摘要（細節看 spec）
- **機制全建**（scope B）：持久遠慾望 registry × means-end 依賴圖 × applicability 湧現順序 × 折現/承諾。
- **內容全基礎層**：food/material/tools/weapons/coin + 所有設施（史詩層後加資料）。
- **脊椎**：持久掛多慾望 → 宣告式 registry 拆子目標（前置五種：資源/定位/人力/設施/子目標）→ applicable gate → 每 tick 挑當下最高 util applicable（順序湧現、零腳本）→ need 沿鏈上傳。
- **多線**：多慾望 + 委派是選項 + 多小隊平行 + 餘力配額 + 隱式協調（不建總參謀）。
- **折現**：投資型才折、人格=折現率（餓短視/穩遠視、權重非 gate）。**承諾**複用既有 hysteresis。
- **有界**：淺/只查 local applicable/無 plan-state（非復活 S2）。**憲法**：utility 餵 utility、人格 WEIGH 不 GATE、加 goal=加資料非 code。

## 你的工
1. **R①**（這是新概念大框 → 寫 HOW spec 前 factcheck）：★尤其你 orientation 的「**既有機械覆蓋度**」斷言（`option.applicable`/`rank_scored`/`NeedOracle` 真能承載 chaining + goal-as-option）要 **code 坐實再 spec，別假設**（本場血證：靜態斷言錯多次）。
2. **HOW 架構 spec**：擴 NeedOracle 沿鏈上傳 + goal-as-chainable-option + 宣告式 registry + 投資折現，補完整 map。
3. **實作 plan + slice 切分**（whole 建完才交付，但內部可分 slice 實作）。
4. **R② 每 slice**。
5. **implementer**。

## ★紀律：whole-system-first（用戶原則②）
整個系統**建完當一個 whole 才回頭 measure 找不合理**，**別邊建邊 patch 症狀**。建完前別 measure 個別症狀（broken 系統 measure 無意義＝本場 race regen tuning moot 血證）。

## material 續 PARK
全 PARK（伐木場/賽跑/regen/初始庫存/settle-motive/BUY/gate②）到此系統建完。建完後 material 供給側 = 下游 tuning，那時 measure 定。
- **coin-liquidity**（extract flat 0.4）收進來 = means-end「需 spendable coin → 需 extract」自然涵蓋、取代 flat 閘。
- **掛單噪音/hollow-economy** = 此根下游、自然消。

## 邊界
你 R① 若翻案設計某塊（如既有機械覆蓋不足、需更多新增）回報我，**WHAT 我調**；純 HOW/架構/slice **你自主**。開工。

## 溯源
brainstorm 2026-07-24（藍圖×用戶，走 superpowers:brainstorming）；spec `2026-07-24-long-range-planning-means-end-design.md`；`docs/notes/2026-07-19-long-range-planning-brainstorm.md`；用戶核可「Ok」×N。
