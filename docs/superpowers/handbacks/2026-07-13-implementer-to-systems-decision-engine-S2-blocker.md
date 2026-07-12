---
from: implementer
to: systems
status: consumed
topic: [卡點 S2.3] coeff 接入撞 2 govern 單元測(plan Step4 說無新FAIL)—solo belonging=1恆宰+治理不在AFFINITY;需裁決
---
# 卡點：S2.3 coeff 接入新破 2 個 govern 單元測

worktree `feat/decision-needs-hierarchy`。S2.1/S2.2 已 commit（affinity 表 + coeff 公式，測全綠）。S2.3（rank_scored_ctx ×= coeff）接入後，headless 新增 **2 FAIL**——但 plan S2.3 Step 4 明列 **Expected: headless 無新 FAIL**。∴ 接點語意不符，停下呈報（不自改 decision 語意）。

## 現象（file:line）
接 coeff 後新破（除 3 pre-existing p2a/beg_join/strategic_reads）：
- `_test_govern_warmonger_roams:12632`：好戰/野心高 solo（軍隊 tag）→ 斷言 `task != 治理`，**實際=治理**。
- `_test_govern_enough_stops:12643`：慎重高但公庫達標 solo → 斷言 `task != 治理`，**實際=治理**。
- 兩者皆走 `_evaluate_solo:1770 → DecisionEngine.rank_scored`（coeff 生效路徑）。

## 機制分析（precise）
1. **solo 隊 belonging raw 恆=1.0**（`compute_raw`：`faction_id==-1 → L_BELONGING=1.0`）+ **actual raw=1.0**（未達 STATE milestone）。單 gather EWMA 首更 → urgency≈`[survival, 0, 0.25, esteem, 0.25]`。這兩測 food=100 → survival raw 0；ambition_cap/rung 預設 0 → esteem raw 0。→ urgency 集中 belonging/actual。
2. **coeff 壓 esteem-class 攻擊/掠奪/貿易**（affinity esteem 主導，但 solo urgency esteem≈0 → alignment 低 → coeff 降）。而 **「治理」不在 AFFINITY 23 表** → `affinity_of("治理")=均勻[0.2×5]` → alignment=0.2·Σurgency（不隨任一層塌） → **相對不被壓** → 治理 util×coeff 相對抬升 → 贏過被壓的攻擊/掠奪。
3. ∴ 兩效應疊：(a) solo belonging/actual 恆高使 esteem/survival 選項普遍被壓；(b) **治理（+任何非 AFFINITY option）默認均勻 → coeff 對其近中性 → 系統性佔便宜**。warmonger 本該攻擊/掠奪、vault-full 本該非治理，現都被 coeff 翻成治理。

## 需裁決（不猜，三案）
**A. AFFINITY 補「治理」（+盤點其他非 REGISTRY-key 但會被 rank 的 task）**：治理=定居長治→給 actual/esteem 傾向 affinity（如 `[0.2,0.1,0.1,0.1,0.5]` 近駐守）→ 不再默認均勻佔便宜。但需先確認 rank 路徑實際會出現哪些非 REGISTRY option（治理從何進 rank？REGISTRY 無「治理」key，S2.1 測只涵蓋 REGISTRY.keys()，治理漏網）。
**B. solo belonging raw 重估**：`faction_id==-1 → belonging=1.0` 恆宰讓所有 solo 決策被 belonging 主導，可能過強（獨立隊≠都在找歸屬）。改 solo belonging 為較低 base 或依人格。屬 compute_raw 設計層。
**C. 更新這 2 單元測為 coeff 後語意**：若「solo 缺歸屬 → 傾向抱團/治理而非窮兵黷武」是**預期新行為**（需求金字塔本意=低層未滿足壓抑高層冒險），則 warmonger-roams/enough-stops 的舊斷言過時 → 更新測。但這是 decision 語意判斷（屬你/blueprint）。

我傾向 **A+可能C**：治理漏出 AFFINITY 是明確覆蓋 bug（非 REGISTRY key 卻進 rank→默認均勻佔便宜違「全 23 統一」意圖）；補上後若 warmonger 仍被 belonging 壓成治理，則屬 B/C 的設計語意（需求層本意 vs 舊測預期）。**但治理如何進 rank（REGISTRY 無此 key）我需你確認**——可能 _evaluate_solo 有 govern 特殊 option 注入，或 AFFINITY 該涵蓋的 option 集 ≠ REGISTRY.keys()。

## 附
- S2.1/S2.2 已 commit（綠）。S2.3 code 在工作區未 commit（等裁決可能改 affinity/compute_raw）。
- determinism/融合閘待裁定後一次跑齊。
- standby 等回，不冷啟、不自改 decision 語意、不問 user。
