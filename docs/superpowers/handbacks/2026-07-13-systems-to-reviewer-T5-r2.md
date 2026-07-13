---
from: systems
to: reviewer
status: consumed
topic: [R②·T5] 層內base校+訓練eval-gate對齊——審抬base不破優先序保全+對齊正確;dispatch前
---

# R② 設計審：T5（層內 base 校 + 訓練 eval-gate 對齊）

## 前置
- 藍圖裁 T5 範圍(`T5-scope-decision`)。spec `docs/superpowers/specs/2026-07-13-term-normalize-T5-intra-layer.md`。
- diag 坐實真根=層內 base 競爭（coeff 跨層分辨、層內不分辨）；normalize「in-band≠competitive」漏判補齊。
- premise（層內 gap 3-5x/訓練 own_util≈0/eval-gate 錯配）已 measurer diag + code 審坐實→免 R①,僅 R②。

## 內容
- **T5.1 base 校**：prepare_drive(備戰 慎·0.9+好·0.2)/settle_fit(駐守 0.6→0.9)/buyfood(0.5+0.5·dist_disc)——抬 favorable 人格達競爭 band、unfavorable 仍低（禁 flat-floor 保梯度）。
- **T5.2 訓練 eval-gate 對齊**：ambient_train_drive 給值條件 FORCE+rung∈[ACC,EXP] → 僅 FORCE（drop rung；applicable 的 anon gate 已供 context）。
- **T5.3 吸納 modest**：absorb yield floor 0.3+0.7→0.5+0.5。
- **T5.4 乞食**→known_issues（不修）。

## 請 R② 重點查
1. **優先序保全（最高風險）**：抬 base 是否致 **non-favorable 情境 over-select**？——備戰抬(慎·0.9)後,**無威脅隊**是否 spurious 備戰（applicable gate threat_react≥threshold 擋否）；駐守抬 0.9 後,**野心隊**是否被駐守蓋過生產/建設（生產/建設有 ambition_drive 第二 term,野心>某值仍該贏——查抬 0.9 後臨界野心值合理否）；買糧 floor 0.5 後,**不餓隊**是否 spurious 買糧（applicable gate food<DESPERATION 擋否）。核心：coeff 跨層 gate + applicable gate 是否足擋 over-select,或 base 抬破防。
2. **人格梯度保**：prepare 新式 `慎·0.9+好·0.2` 是否好戰隊(慎低)仍低→迎戰贏（非 flat 全抬）。
3. **訓練 eval-gate 對齊正確**：drop rung 後,FORCE 隊有 anon 恆 eval 0.5——是否 over-train（applicable has_trainable+FORCE + coeff esteem 調是否足限）；rung 語意（原限 ACC/EXP=成長階練兵）drop 後是否失合理性,或 coeff 已承接該調控。
4. **駐守單-term 補足**：0.6→0.9 是否足匹配雙-term 生產/建設(settle_fit 0.4+ambition_drive),還是應補第二 term（我選抬單值,較小改；查是否夠）。
5. determinism/值域 [0,1]（clampf）。

## 註
- 全 TEST VALUE,幅度 measurer 校。
- CLEAN 則 dispatch implementer T5。有 blocker/優先序破防回 verdict。
