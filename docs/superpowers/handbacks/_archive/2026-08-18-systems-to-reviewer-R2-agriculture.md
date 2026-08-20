---
from: systems
to: reviewer
status: consumed
topic: "[R² 農業(農田獨立生產線+drift正位+⑥據點放大器)HOW審·spec=2026-08-18-settlement-agriculture-HOW.md·★大經濟改須審·審點:①★前提fact-check(負斷言、我已窮盡no-head):farm_yield chokepoint全樹0處(未建)確認?farming_level唯一產糧用法=resource_system:289 gain*=(1+farming_level×0.5)gather乘數(drift)確認?=mechanism-intents農田row『獨立產糧不經野地池』的code與表不符②★★經濟擾動風險(大改命門):drift正位移除:289 gather乘數→農田tile gather yield掉(farming_level不再boost採集)+新獨立農田生產線→食物從哪來的分佈大變、恐擾既有food-tension校準(FOOD_PER_PERSON 0.8/regen rate/granary)=淨效果安全否?會不會mass-starve or爆倉?(建議gate要求before/after食物帳)③禁crank(命門):農田產出=真物理等級×單位×勞力工位×季節、labor從勞力池抽guns-vs-butter、farming_level升級走既有construction spine真工期真料、非白灌boost④冗餘查:獨立農田線vs既有野地池gather=雙源(不同、intended)非框架冗餘?⑤據點放大器⑥:effective_pop_cap=領導基數×據點結構放大器=genuine據點投資回報非死常數pop曲線?L0不放大(守S2a界線)?⑥守恆:farm_yield chokepoint TileBank.deposit tagged守恆稽核含農業⑦感知鐵律:農業自家據點自家勞力自家糧倉own-state·此slice待R²CLEAN→農業a plan→dispatch(base post-S2b main e38f74d8)·地基KEEP"
---

# R² 農業（農田獨立生產線 + drift 正位 + ⑥ 據點放大器）HOW 審

spec=`docs/superpowers/specs/2026-08-18-settlement-agriculture-HOW.md`。**★大經濟改須審**。

## 審點
1. **★前提 fact-check（負斷言、我已窮盡 no-head）**：`farm_yield` chokepoint **全樹 0 處**（未建）確認？`farming_level` 唯一產糧用法=`resource_system:289 gain*=(1+farming_level×0.5)` gather 乘數（drift）確認？=mechanism-intents「農田」row「獨立產糧不經野地池」的 **code 與表不符**。
2. **★★經濟擾動風險（大改命門）**：drift 正位**移除 :289 gather 乘數** → 農田 tile gather yield 掉（farming_level 不再 boost 採集）+ 新獨立農田生產線 → **食物從哪來的分佈大變、恐擾既有 food-tension 校準**（FOOD_PER_PERSON 0.8/regen/granary）=淨效果安全否？會不會 mass-starve or 爆倉？（建議 gate 要求 **before/after 食物帳**）。
3. **禁 crank（命門）**：農田產出=真物理（等級×單位×勞力工位×季節）、labor 從勞力池抽 guns-vs-butter、farming_level 升級走既有 construction spine 真工期真料、非白灌 boost。
4. **冗餘查**：獨立農田線 vs 既有野地池 gather=**雙源**（不同、intended）非框架冗餘？
5. **據點放大器⑥**：`effective_pop_cap=領導基數×據點結構放大器`=genuine 據點投資回報**非死常數 pop 曲線**？**L0 不放大**（守 S2a 界線）？
6. **守恆**：farm_yield chokepoint TileBank.deposit tagged、守恆稽核含農業。
7. **感知鐵律**：農業自家據點自家勞力自家糧倉 own-state。

## 時序
待 R² CLEAN → 農業a plan → dispatch implementer（base post-S2b main `e38f74d8`）。地基 KEEP。
