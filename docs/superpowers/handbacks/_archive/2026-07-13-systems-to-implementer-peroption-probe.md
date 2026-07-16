---
from: systems
to: implementer
status: consumed
topic: [補probe·優先S3] per-option 選中次數 probe——量①全23覆蓋 ④不死鎖 + TC7 collapse;比照 rung_dist
---

# 補 per-option 選中次數 probe（優先於 S3，藍圖定）

S2 已 merge(main)。藍圖裁：續 S3 前先補 per-option 選中次數 probe——現有 `coeff_applied_n`/`coeff_lowhalf` 聚合總數**量不出** spec 核心驗收①(全 23 覆蓋)④(軟降權不死鎖)。這是重構價值主張(「23 全接入非只 11」=解「N 瞎子」的直接證據)，先量避 established 那種「修完才發現沒解真根」。

## 做什麼
在 decision dispatch 路（`DecisionEngine.rank_scored_ctx` argmax 選中點，或 _decide_unified/_evaluate_solo 落 option 處）加 **per-option 選中次數 probe**，比照既有 `rung_dist`/`plan_phase_dist` 分布 probe 模式（grep 找範例）：
- **選中分布**：`Probe.bump("decision.opt_chosen.<option名>")`——每 option 被選中(rank[0])計次。23 option 各一 key。
- **候選分布**（分母，判「結構性選不到」）：`Probe.bump("decision.opt_applicable.<option名>")`——每 option 進 applicable 計次。→ measurer 可算「applicable 過但選中率恆 0」=結構性死鎖(④)。
- **coeff 影響證據**（①全覆蓋）：per-option 平均 coeff 或 coeff<1 計次(`decision.opt_coeff_pressed.<option>`)——證原本無 bias 的 12 option(生產/建設/駐守/囤貨/徵收/歸建/備戰/迎戰/求和/吸納/乞食/佔村)coeff 確實隨急迫度變(非恆 1)。

實作注意：
- option 名做 key 後綴（中文 key 可，比照現有 probe）。
- `Probe.enabled` gate（不污染 production perf）。
- **零行為變**（純觀測，不改 decision）→ determinism 不動。
- probe 只加、不 tune affinity/coeff（藍圖明令 pre-organic 不硬湊）。

## 回報
probe 加完 + headless 無新 error → handback to:measurer，請跑 full_probe 量：
- **①全覆蓋**：23 option 是否都有 opt_applicable>0 的受 coeff 影響證據；12 個新覆蓋 option 的 coeff_pressed 是否非 0。
- **④不死鎖**：有無 option `applicable>0 但 chosen 恆=0`（結構性選不到）。
- **TC7 collapse 真相**：跨 seed 人格是否真 collapse 到單一 option（貿易獨大？），或只是特定同態情境收斂——這決定要不要帶數據 tune affinity 平衡點(如駐守 actual-heavy 待校)。

## 序
measurer 回報 → 全覆蓋/不死鎖成立→續 S3；發現結構性 0 或人格 collapse→回頭帶數據 tune(非瞎猜)。守：純觀測、不 pre-tune、不問 user。
