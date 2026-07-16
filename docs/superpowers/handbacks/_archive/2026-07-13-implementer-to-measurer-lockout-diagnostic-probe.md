---
from: implementer
to: measurer
status: consumed
topic: zero-option 三類分流診斷 probe 交付 — branch feat/peroption-probe已push,請 full_probe 分類9-zero
---
# Hand Back: zero-option 三類分流診斷 probe（裁 A）

branch `feat/peroption-probe`（已 push，續前 per-option probe 同 branch，疊 main 9569efd）。純觀測零行為變。

## 實作摘要
- `decision_engine.gd` `rank_scored_ctx`（排序後、`Probe.enabled` gate）：對**每 applicable 但非 rank[0]** 的 option 記 4 訊號：
  - `diag.<opt>.appl_n`（分母：applicable-but-lost 次數）
  - `diag.<opt>.coeff_sum`（Σcoeff → 平均 coeff）
  - `diag.<opt>.coeff_pressed`（cf<0.5 計次）
  - `diag.<opt>.mainurg_sum`（主層 urgency Σ）、`ownutil_sum`（自 util post-coeff）、`winutil_sum`（winner util）
- `need_hierarchy.gd` `main_layer_of(opt)`：option 主 affinity 層 argmax。
- `warring_harness._decision_diag_snapshot`：掃 `Probe.counts`+`Probe.amounts` 的 `diag.*` → `result.decision_diag`。sort 保 determinism。

## 我方自驗
- 冒煙（1337×1mo）：`decision_diag` 出 **115 個 diag key**。headless **0 新增 SCRIPT ERROR**（3 pre-existing）；constitution PASS；**determinism byte-identical**。

## 請你 full_probe 分類（工單，每 zero-option 按三類）
- **applicable 稀有**：`diag.<opt>.appl_n` 相對總 cadence 極低 → gate 稀有（可能合理，非缺陷）。
- **真 coeff-lockout**：`coeff_sum/appl_n` 平均 <0.5 **且** `mainurg_sum/appl_n` >0.6（主層高急迫卻被壓）→ 鬆綁(S3)對症。
- **base-util 競爭**：`coeff_sum/appl_n` 高(~>0.7) **且** `winutil_sum/appl_n` ≫ `ownutil_sum/appl_n`（coeff 沒壓、純輸 base util）→ affinity/base 權重待 tune。
- 順帶：**TC7 貿易獨大歸哪類**（base-util vs coeff）。

## 序
- 你分類結果 → to:blueprint（裁下一步：稀有=記錄 / base-util=帶數據 tune / lockout=排 S3）。
- 守：純觀測、不 pre-tune、不問 user（藍圖明令先分類再定藥）。連動風險：無。
