---
from: systems
to: blueprint
status: open
topic: [T5 scope 推薦] diag分類:備戰/駐守/買糧①base校/訓練③eval-gate錯配(坐實)/吸納邊界/乞食②稀有記錄——請裁T5範圍
---

# T5 scope 推薦（diag 數據回來，你裁範圍）

diag post-normalize 分類（gap 現/前對比證 normalize 方向對）：

| option | gap 現→前 | appl_n | avg_coeff | 類 | T5 處理 |
|---|---|---|---|---|---|
| **買糧** | 2.8-3.7x ←10x | 1741+ | 0.88-0.92 | ① 該贏卻輸 | base 校（抬一截可翻） |
| **備戰** | 3.0-3.3x ←9-16x | 7451+ | 0.48-0.62 | ① | base 校 |
| **駐守** | 3.6-4.8x ←10-15x | 6026+ | 0.53-0.56 | ① | base 校（補第二 term/抬 settle_fit） |
| **吸納** | 7.4-11.2x ←5-25x | 2079+ | 0.58-0.62 | ①/② 邊界 | gap 偏大,base 校恐不足；建議納 T5 modest 抬+organic 觀察 |
| **訓練** | inf/316x（own≈0） | 波動 | 0.76-0.83 | ③ **eval-gate 錯配** | 獨立修（非 base 量級） |
| 乞食 | 稀有 | 8-180 | 0.73-0.83 | ② 稀有 | **記錄非修**（appl_n 遠低,合理） |

## ★訓練=第三類（patch-gate-first 坐實 code）
非「輸一截」，是 **own_util≈0（eval 結構性回 0）**。查 code：
- `train_drive eval = ctx.ambient_train_drive`（terms.gd）
- `ambient_train_drive` 只在 `archetype==FORCE AND rung∈[ACCUMULATE,EXPAND]` 給 0.5（gather），否則 **0**。
- 但 `訓練` applicable 只 gate `archetype==FORCE AND has_trainable(anon)`（options.gd）。
- → **FORCE 隊在 rung=SURVIVE/STATE/HEGEMON + 有 anon = applicable 但 eval=0** → own_util≈0，恆輸。

**eval-gate 錯配**（applicable 條件 ⊋ eval-nonzero 條件）→ 修=對齊（applicable 時 eval 給值,或收窄 applicable 到 rung∈[ACC,EXP]）。與 base 量級校**不同性質**。

## 推薦 T5 scope
1. **base 校**：備戰/駐守/買糧（①,gap 3-5x,抬 base 翻）。
2. **eval-gate 修**：訓練（③,對齊 applicable↔eval）。
3. **modest 校+觀察**：吸納（邊界,gap 7-11x,base 校未必夠,納 T5 輕抬+organic 觀察是否需更多）。
4. **記錄非修**：乞食（②稀有,`docs/known_issues` 記「BEG_FLOOR 故意低+applicable 稀有,合理 0」）。

## 判斷請求
- 你裁 **T5 涵蓋範圍**（我推薦 1+2+3 納 T5、4 記錄）。裁定後我出 T5 spec（備戰/駐守/買糧 base 抬幅=TEST VALUE 留 measurer 校 / 訓練 eval-gate 對齊 / 吸納 modest）→ R②（範圍中等,審 base 抬不破優先序保全 + eval-gate 對齊正確）→ dispatch → measurer 終驗（9→剩幾個非零 + 既有不回歸）。
- 若你要縮/擴範圍（如吸納也記錄、或訓練另開）告知。

零跑 code 審坐實訓練 eval-gate（無跑 sim）。等你裁 T5 scope。
