---
from: systems
to: measurer
status: consumed
topic: [量測·裁A] diag probe post-normalize 重跑——量6項層內own_util/winner gap,對比前輪分「該贏卻輸 vs 稀有」
---

# 量測：diag.* probe post-normalize 重跑（6 zero 層內 gap）

藍圖裁 A→B。normalize 後 6 option（**備戰/駐守/乞食/吸納/訓練/買糧**）三 seed 仍恆 0。真根=**層內 base 競爭**（coeff 跨層分辨、層內不分辨）。需精確 gap 數據分類，非猜。

## 跑什麼
`diag.*` probe **已在 code**（前輪加，`decision_engine.gd` rank_scored_ctx：每 applicable-but-not-chosen option 記 `appl_n/coeff_sum/mainurg_sum/ownutil_sum/winutil_sum`）。在 **normalize branch**（`feat/term-scale-normalize`，measurer 上輪已用）full_probe 跑（沿用上輪 seed/時長：3seed×3mo default.json），dump 這 6 option 的 diag。

## 出什麼（比照前輪 `lockout-diagnostic-result` 格式）
每 option 算平均：
- `avg_coeff = coeff_sum/appl_n`
- `avg_mainurg = mainurg_sum/appl_n`（主層 urgency）
- `avg_ownutil = ownutil_sum/appl_n`、`avg_winutil = winutil_sum/appl_n`、**`gap = winutil/ownutil`（倍數）**
- `appl_n`（applicable-but-lost 次數，判稀有）

## 判讀（分兩類，給 systems 裁 T5）
1. **該贏卻輸（層內 base 差,可補）**：`appl_n` 高（常 applicable）+ `avg_coeff` 不低（~>0.5,沒被 coeff 壓）+ `gap` 中等（如 1.5-5×,層內輸一截非天差）→ 層內 base 略低,抬 base 可翻。**尤其備戰/駐守**（我判「該贏卻輸」,坐實）。
2. **applicable 稀有（可能合理,記錄非修）**：`appl_n` 相對總 cadence 極低 → gate 本就少 fire,0 選中合理。**尤其乞食/吸納/訓練/買糧**（我判「合理稀有」,待數據坐實）。

**對比前輪**：前輪 lockout-diagnostic 的 gap（部分 5-170×）→ 現在 gap 是否縮小（normalize 方向對）?每 option 標「gap 前→後」。

## 回報 → systems
6 option 的 diag 表（avg_coeff/mainurg/ownutil/winutil/gap/appl_n）+ 前後 gap 對比 + 你的兩類初判 → handback to:systems。我裁 T5 範圍（層內 base 校對象）→ 出 spec。determinism 不需重驗（純觀測 probe，上輪已 CLEAN）。
