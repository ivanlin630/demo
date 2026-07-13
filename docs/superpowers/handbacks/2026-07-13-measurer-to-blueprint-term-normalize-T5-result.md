---
from: measurer
to: blueprint
status: consumed
topic: term-normalize T5終驗——★9-zero收斂未達成：備戰/求和/駐守/吸納/訓練/買糧跨3seed幾乎全恆0(僅備戰seed7 1次/11634、貿易seed7 1次/6799，可視為噪音非收斂)，與implementer單元測試PASS矛盾；determinism CLEAN+0新增SCRIPT ERROR
---

# 量測回報：term-normalize T5（收尾）終驗——★負面結果

工單：`2026-07-13-implementer-to-measurer-term-normalize-T5.md`。`.worktrees/term-scale-normalize`（含T1-T5全commit @acd6f73）。

## ①headless/determinism——CLEAN
0新增SCRIPT ERROR（3個pre-existing同baseline）。determinism`t5_det1.json`/`t5_det2.json` **byte-identical**。

## ★②9-zero收斂——未達成，T5改動在organic下幾乎無可見效果

| option | seed1337 | seed42 | seed7 | T5是否有針對性修改 |
|---|---|---|---|---|
| 貿易 | 0 | 0 | 1(/6799) | 否（T1-T4已修） |
| 備戰 | 0 | 0 | 1(/11634) | **是**（T5.1 base校） |
| 求和 | 0 | 0 | 0 | 否（與備戰配對） |
| 駐守 | 0 | 0 | 0 | **是**（T5.1 settle_fit 0.6→0.9） |
| 乞食 | 0 | 0 | 0 | 否（known_issues記錄不修，符合預期） |
| 併入 | 0 | 0 | 0 | 否 |
| 吸納 | 0 | 0 | 0 | **是**（T5.3 absorb_drive調整） |
| 訓練 | 0 | 0 | 0 | **是**（T5.2 eval-gate對齊FORCE） |
| 買糧 | 0 | 0 | 0 | **是**（T5.1 buyfood_drive墊底改0.5-1範圍） |

**implementer本輪T5明確針對備戰/駐守/吸納/訓練/買糧五項做base term修改，且headless單元測試（`_test_t5_intra_layer`）PASS——但organic 3seed×3mo full_probe裡，這五項跨seed幾乎全部依然是0**（備戰僅seed7出現1次，佔applicable 11634次的0.0086%，統計上等同噪音，非收斂）。**驅動層診斷（diag gap分析）顯示gap確有縮小（前輪`diag-rerun-postnormalize`已報告），但gap縮小不代表argmax真的翻轉勝出**——base抬升幅度仍不足以讓這些option在跨層競爭中贏過`survival`/`覓食`/`建設`/`生產`四大贏家option。

這與本session前幾輪（command-tenure-growth）觀察到的同一模式一致：**孤立單元測試通過，不代表organic多隊競爭環境下真的有可觀測效果**。

## 判讀（誠實回報，不代判方向）
- normalize（T1-T5）整個arc的診斷方向正確（層內base競爭確實是根因，diag gap確實縮小），但**幅度仍遠不足以讓argmax真正翻轉**——這是「修對方向但劑量不夠」，而非「修錯方向」。
- 若要讓這幾個option真正被選中，可能需要比T5.1-T5.3更大幅度的base值調整，或重新檢視coeff/base相對權重比例（`weight(0-1.5) × eval(0-1) × coeff(0.15-1)`公式裡base的eval上限是否本質上就贏不了survival/覓食這類高頻option）。
- 我不代判具體tune幅度，回你裁下一步（續加碼T6，或接受「這幾個option本就該是稀有選項」的設計立場，改標記記錄而非繼續tune）。

## 產物
`t5_det1.json`/`t5_det2.json`（determinism），`t5_organic_3mo.json`（3seed×3mo終驗），`tools/orchestrator/runs/t5_opt_dist_readable.txt`（可讀分布表）。

## 待你
9-zero收斂驗收本輪**未通過**（5個T5針對性修改的option仍幾乎全0）。是否續加碼tune（T6）或改變驗收標準/設計立場，交你裁。
