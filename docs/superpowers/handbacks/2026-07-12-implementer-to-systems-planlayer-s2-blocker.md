---
from: implementer
to: systems
status: consumed
topic: [卡點 S2] plan_phase_drive 撞 TC7 divergence 硬bar—SEEK_FOOD偏置貿易collapse個性分歧(reviewer貿易watch-item坐實);需裁決
---
# 卡點：S2 plan_phase_drive 破 `_test_tc7_divergence` 框架硬 bar

worktree `feat/plan-layer-s2`（疊 main d67a7a7 含 S1）。Task2 全實作完（team_data plan_phase 欄 / decision_context derive_plan_phase + _phase_option_bias / terms plan_phase_drive / options 7 格 REGISTRY / weight 1.0）。**我 2 新測 `_test_plan_phase_derive`+`_test_plan_phase_bias` 皆 PASS**。但迴歸新破一框架不變量測，停下呈報（S1 式，不猜改框架硬 bar）。

## 現象（file:line）
`_test_tc7_divergence:14757`（標「過不了=框架失敗」硬 bar）：3 種 leader 同情境應選 3 不同 option。
- 實測：霸主→建設、商人→**貿易**、隱士→**貿易**（隱士原 駐守，本 slice 後翻貿易）→ uniq=2 → fail。
- 機制：3 隊 `_mk_merchant_team`（食 500 在糧倉）**未設 `food_flow_avg`**（default 0.0）→ `derive_plan_phase` 見 0.0<ACCUMULATE_FLOW_MIN(0.5) → 全判 **PHASE_SEEK_FOOD** → `_phase_option_bias` 給 {覓食,買糧,貿易}+0.4 → 隱士（駐守 util 弱）被 +0.4 貿易 蓋過 → 翻貿易，撞商人。

## 雙重根（誠實拆）
1. **測試 artifact**：`_mk_merchant_team:14659` 只塞糧倉 food，**不設 `food_flow_avg`**（真 sim 由 ResourceSystem.resolve_consumption 維護；富隊真 sim food_flow>0.5 不會 SEEK_FOOD）。∴ TC7 富隊被誤判缺糧。
2. **設計真張力（reviewer R² 貿易 watch-item 坐實）**：即使正當 SEEK_FOOD，+0.4 貿易 會把**非商人個性**（隱士）推去貿易 → collapse 個性分歧。reviewer S2 spec 已標「求糧偏貿易 vs intent_fit 致富偏貿易 窄邊緣疊加，MAG 0.4 壓低風險可控，measurer 觀察」——此為該 lens 在**單元硬 bar**上的實體化。**注意**：3 隊 pop=5<8，即使修 food_flow 使非 SEEK_FOOD，仍落 PHASE_GROW → +0.4 {紮營,返家補給} → 可能另一種 collapse（隱士 駐守→紮營）。∴ 純改 food_flow 未必乾淨救 TC7。

## 需裁決（不猜，等 systems；三案）
**A. 測試現實化**：TC7（+相關 `_mk_merchant_team` 用例）設 `food_flow_avg` 反映富隊（>0.5）→ 不誤 SEEK_FOOD。**缺點**：pop=5<8 → 落 GROW 仍偏 {紮營/返家}，隱士或再 collapse；且遮蔽「shared 缺口→分歧收斂」性質（可能真實但 TC7 假設不再成立）。
**B. 設計收窄 map**：SEEK_FOOD map **移除「貿易」**（貿易=商人路徑；非商人缺糧該走覓食/買糧，非被推去貿易）→ 降 cross-個性 collapse + 化解 reviewer 貿易疊加 watch。**動 spec `_phase_option_bias`**（設計層，你裁）。GROW 的 {紮營} 對 non-camp 個性同類風險，或一併審。
**C. 接受 baseline 位移 + 放寬 TC7**：plan-layer 本就「shared 缺口→phase 偏置收斂分歧」（餓隱士該考慮貿易/覓食換糧=合理）→ TC7「3 leader 必 3 option」在 plan-layer 世界過嚴，改「≥2 種模式」（比照 plan §驗收誠實化用語）。**動框架不變量語意，你裁**。

我傾向 **B**（貿易本商人路徑，SEEK_FOOD 給非商人覓食/買糧已足；移除貿易化解 reviewer watch + 保 TC7 個性分歧不需動框架 bar）。但涉 spec `_phase_option_bias` 設計 + 可能連 GROW/紮營 同審 → 設計層歸你。

## 附
- 除 TC7，headless 其餘 = **3 pre-existing**（`_test_p2a_survival_terms`/`_test_beg_join_social_resolve`/`_test_strategic_reads_ladder`，S1 已對照 d67a7a7 baseline 同集）。∴ 本 slice **淨新增 = TC7 一項**。
- 我 2 phase 測 PASS。determinism/融合閘待裁定後一次跑齊再交 measurer。
- code 已在 worktree（未 commit，等裁決可能改 map）。standby 等回，不冷啟、不問 user。
