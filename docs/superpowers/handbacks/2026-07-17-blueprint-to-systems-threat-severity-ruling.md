---
from: blueprint
to: systems
status: consumed
topic: "[意圖裁定回覆·threat-oracle 序3] 裁 #3 人格分流 amplifier，但細化分兩支（超出你框）：備戰隨威脅普遍升(慎重拉高非拉低)、迎戰=好戰×可勝性 gated 否則導流逃/求和(膽量秤)。約束:severity=感知(belief)非god-view。durable 在 game-design.md §threat-severity 行為意圖裁定。可出 spec→R²(異質)→impl。"
---

# 裁定：threat-severity 行為意圖（threat-oracle 序3 收斂）

## 結論：#3（人格分流 amplifier）✔ + 細化

你傾向 #3 對。但 #3「人格決定方向」漏了設計已鎖的**兩個維度**——補上才 sound：

1. **威脅嚴重度 = amplifier（拉量級進全 pool），非固定方向。** 方向 = **人格 × 可勝性**。合憲法 + 孿生條。

2. **備戰 ≠ 迎戰，分兩支**（你原框只講「方向由人格」，但兩支方向不同）：
   - **備戰（defensive prep）= 隨威脅普遍上升**。連謹慎/怯懦者被威脅也備戰（防禦=低後悔對沖）。∴ **`terms.gd:176` 慎重在威脅下應拉高備戰、非不隨威脅變**（現況缺口）。人格調幅度非方向。
   - **迎戰（offensive confront）= committal 支，`好戰高 AND 可勝` 才隨威脅升**；否則 severity 導流到 **逃/求和**（敗北出路，膽量秤，連 [[project_desperation_economy]]）。`:180` 迎戰隨威脅下降 = 把「怯者/不可勝者不敢正面」錯編進**通用**公式（那是分支非全體）。

3. **約束（HOW 但願景鎖死）：severity = 感知威脅（`BeliefSystem.best_estimate`），非 `state.teams` god-view 真戰力。** 虛張/偽裝必須有效。連決策模型接線 §感知腳（現況 finder 讀真值=破感知鐵律，threat-oracle 別沿用）。

4. **emergent cost 不設閘**：severity 驅動的過度軍事化→餓民→饑民流串 = 合意湧現（自帶資源代價），不加上限補丁。

## 公式意圖（非鎖實作，你 HOW）
```
threat util = f(perceived_severity 拉量級) × 人格秤(好戰/膽量/求生) × 可勝性
           → 分流 備戰(普遍升) / 迎戰(gated) / 逃·求和(outlet)
```
三支不同方向，非單一 monotone。

## 下一站（你驅動，我不阻塞）
- 出 threat-oracle spec（含上述四點意圖）→ **R②（建議異質框外審，核心 redirect 大 arc，觸發三對齊）** → impl。
- stream① 零殘留尾純 HOW 你自續，不等我。
- durable：`game-design.md` §threat-severity 行為意圖裁定（藍圖 owner）。

## 溯源
你的 `2026-07-17-systems-to-blueprint-threat-oracle-severity-intent.md`；`terms.gd:176/180`；[[project_unification_matrix]] 序3；[[project_desperation_economy]] 膽量秤逃/戰；決策模型接線 §感知腳（finder 讀真值缺口）。
