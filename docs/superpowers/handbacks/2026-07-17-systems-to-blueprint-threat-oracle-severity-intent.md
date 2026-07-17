---
from: systems
to: blueprint
status: consumed
topic: "[意圖裁定·threat-oracle 收斂 arc 前置] stream② registry 收官,真統一剩 3 收斂 arc。threat-oracle(序3 首)需你裁 threat-severity 行為意圖:威脅越大,備戰/迎戰 util 該越高(severity-scaling)嗎?——現況 `terms.gd:180` 迎戰 `好戰*0.7+(1-threat_react)*0.2`=威脅越大越低(反直覺)。此為 threat 收斂進全 pool 的前置(無 severity-scaling→強威脅下 threat 被貿易1.3壓過,seam#1 血證)。純 HOW 我自扛,但『威脅越大越該打/備』是行為 WHAT。"
---

# 意圖裁定：threat-oracle 收斂 arc 的 threat-severity 行為

## 背景（framework 做好進度）
- **stream② registry program 收官**（3 seams merged:option/facility/sim_runner，byte-identical，擴充達成）。
- **stream① 零殘留**：gate 91→72（S1 移除 2 + bucketB 標 17），剩=legit scaffolding + 真統一-tracker + B2 序5。
- **真統一剩 = 3 收斂 arc**（seam#1 結論:threat/survival/ambient filtered subset 各編碼真選擇語意，非 scaffolding，需各自獨立設計 arc 才能 sound 收斂進統一 rank）。**threat-oracle=序3 首**。

## 要你裁的行為意圖（非我 systems 自決）
threat-oracle 的核心=**threat 選項 util 隨威脅嚴重度 scaling**。現況坐實（seam#1 R² 血證，`terms.gd`）：
- 迎戰 `:180` = `好戰*0.7 + (1−threat_react)*0.2` → **威脅越大 util 越低**（註「威脅越大越不敢正面」）。
- 備戰 `:176` = `慎重*0.9+好戰*0.2`（不隨威脅變）。
- threat util 天花板 ~0.8-1.0，被貿易(1.3)/野心(1.5)結構性壓過（現靠 filtered-hard 子集 gate 保 threat 奪 argmax，非 util 量級）。

**收斂進全 pool 需 severity-scaling**（否則強威脅下 threat 被發展選項稀釋，seam#1 finding 1）。但「威脅越大該越傾向備戰/迎戰 or 越傾向逃/求和」=**行為 WHAT**：
1. **備戰/迎戰隨威脅上升**（強敵當前→更備戰/更迎戰）？還是
2. **迎戰隨威脅下降但逃/求和上升**（強敵→不敢正面→逃或屈）＝現況迎戰-down 的意圖延伸？還是
3. **人格分流**（好戰→迎戰隨威脅上升、怯懦→逃隨威脅上升）＝威脅是 amplifier 非固定方向？

## 我的 systems 傾向（供參，你裁）
傾向 **#3 人格分流**：威脅嚴重度=amplifier，方向由人格（好戰/膽量/求生欲）決定——好戰者威脅越大越迎戰、怯者越大越逃。這樣 severity-scaling 保「threat 在全 pool 有量級競秤」+ 人格決定戰/逃（合決策模型:引擎秤人格）。連 [[project_desperation_economy]] 敗北出路（膽量秤逃/戰）。但方向是你的 call。

## 不急（無斷點但非阻塞你）
threat-oracle 是大 arc，你裁意圖後我出 spec→R²(建議異質,核心 redirect)→impl。同時我可續 stream① 零殘留尾（純 HOW 不等你）。**你回意圖前我不動 threat-oracle 設計**（避免在未定意圖上寫 spec=前提先驗紀律）。

## 溯源
seam#1 R² threat 收斂 FLAWED 結論（`specs/2026-07-17-seam1-control-flow-convergence.md` §R²）；[[project_unification_matrix]] 統一路線圖序3 threat-oracle；[[project_desperation_economy]]；`terms.gd:176/180`。
