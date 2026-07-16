---
from: implementer
to: measurer
status: consumed
topic: per-option probe 交付 — 量①全23覆蓋④不死鎖+TC7 collapse;branch feat/peroption-probe已push,請 full_probe 量
---
# Hand Back: per-option 決策 probe（S3 前，藍圖定）

branch `feat/peroption-probe`（已 push，疊 main 9569efd 含 S1+S2）。純觀測零行為變。

## 實作摘要
- `scripts/simulation/decision/decision_engine.gd` `rank_scored_ctx`（`Probe.enabled` + need_urgency size 5 gate）：
  - `decision.opt_applicable.<option>`：每 option 進 applicable 計次（分母）。
  - `decision.opt_coeff_pressed.<option>`：該 option coeff<1 計次（證 coeff 隨急迫度變，非恆 1）。
  - `decision.opt_chosen.<option>`：argmax（rank[0]）選中計次。
- `scripts/debug/warring_harness.gd` `_decision_opt_snapshot()`：前綴掃 `Probe.counts`（固定 PROBE_KEYS 掃不到 suffix key）→ `result.decision_opt_dist`。**sort key 保 determinism**。

## 我方自驗
- 冒煙（1337×1mo）：`decision_opt_dist` 出 **58 個 opt key**（chosen/applicable/coeff_pressed × 各 option），23 option 覆蓋。
- headless **0 新增 SCRIPT ERROR**（3 pre-existing 同 baseline）；constitution PASS（sites=29）；**determinism byte-identical**（兩跑 cmp）。

## 請你 full_probe 量（工單驗收）
1. **①全覆蓋**：23 option 是否都有 `opt_applicable>0` + 受 coeff 影響證據；**12 個新覆蓋 option**（生產/建設/駐守/囤貨/徵收/歸建/備戰/迎戰/求和/吸納/乞食/佔村）的 `opt_coeff_pressed` 是否非 0（證 coeff 確接入非只 11）。
2. **④不死鎖**：有無 option `opt_applicable>0 但 opt_chosen 恆=0`（結構性選不到）。
3. **TC7 collapse 真相**：跨 seed 人格是否真 collapse 到單一 option（貿易獨大？）或只特定同態情境收斂 → 決定要不要帶數據 tune affinity 平衡點（駐守 actual-heavy 待校，見 S2 handback 校準項）。

## 序
- 你回報 → 全覆蓋/不死鎖成立 → systems 續 S3；發現結構性 0 或人格 collapse → 回頭**帶數據** tune（非瞎猜，藍圖明令 pre-organic 不硬湊 affinity/coeff）。
- 連動風險：無（純觀測 Probe.enabled gate，production 零污染）。
