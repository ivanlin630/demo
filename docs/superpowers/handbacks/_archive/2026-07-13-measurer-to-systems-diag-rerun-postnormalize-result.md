---
from: measurer
to: systems
status: consumed
topic: diag post-normalize重跑結果——gap普遍縮小(備戰9-16x→3x/駐守10-15x→4-5x/買糧10x→3x)確認normalize方向對；★訓練own_util結構性趨零(gap達316x~inf,未被T1-T3覆蓋，非漸進小差)需獨立處理；吸納改善有限；乞食確認稀有非缺陷
---

# 量測回報：diag.* probe post-normalize 重跑（6 zero option 層內gap，3seed×3mo）

工單：`2026-07-13-systems-to-measurer-diag-rerun-postnormalize.md`。`.worktrees/term-scale-normalize`（沿用上輪跑法，determinism已CLEAN未重驗）。

## 逐option數字（跨3seed）

| option | appl_n範圍 | avg_coeff | avg_mainurg | gap(現) | gap(前輪,term-scale前) | 判讀 |
|---|---|---|---|---|---|---|
| **備戰** | 7451-12064 | 0.48-0.62 | 0.06-0.33 | **3.0-3.3x** | ~9-16x | ①該贏卻輸，gap明顯縮小 |
| **駐守** | 6026-7031 | 0.53-0.56 | 0.01-0.27 | **3.6-4.8x** | ~10-15x | ①該贏卻輸，gap明顯縮小 |
| **乞食** | 8-180 | 0.73-0.83 | 0.56-0.63 | 4.2-6.0x | ~9-18x | ②稀有（appl_n遠低於其他option的萬級量），gap也縮小 |
| **吸納** | 2079-2794 | 0.58-0.62 | 0.00-0.54 | 7.4-11.2x | ~5-25x | ①該贏卻輸但gap範圍偏大（超出1.5-5x框），改善有限 |
| **訓練** | 4-2115（跨seed劇烈波動） | 0.76-0.83 | 0.60-1.00 | **inf/inf/316.8x** | 已極大（結構性） | ③own_util結構性趨零（三seed`avg_ownutil`皆≈0.0000-0.0033），非漸進小差，T1-T3未覆蓋此option |
| **買糧** | 1741-3919 | 0.88-0.92 | 0.88-0.90 | **2.8-3.7x** | ~10x | ①該贏卻輸，gap明顯縮小（改善最顯著） |

## 對比前輪——normalize方向確認對，但深淺不一

- **備戰/駐守/買糧**：gap從~9-16x大幅壓到3-5x，normalize顯著見效，符合你「該贏卻輸，抬base可翻」的預判。
- **乞食**：gap同樣縮小，且`appl_n`（8-180）遠低於備戰/駐守量級（7000+），確認你「合理稀有」判讀，非缺陷。
- **吸納**：gap改善幅度不明顯（7.4-11.2x，仍超出你定義的1.5-5x「該贏卻輸」範圍），介於①②之間，值得留意但非本輪重點。
- **★訓練——結構性own_util趨零，非漸進問題**：三seed`avg_ownutil`分別0.0000/0.0000/0.0033，幾近於0，導致gap算出inf或316.8x（極端值）。這**不是「輸一截」而是「own utility算式本身沒給值」**——`訓練`option未被implementer的T1-T3 normalize bucket涵蓋（T1只列了8個survival-class term，訓練不在內）。這是獨立缺陷，需查`訓練`option對應的base eval term本身，非同一批「抬base一點」能解。

## 產物
`tn_diag_organic_3mo.json`（3seed×3mo diag full_probe），`tools/orchestrator/runs/tn_diag_readable.txt`（可讀分類表）。

## 待你
- 備戰/駐守/買糧/吸納：①該贏卻輸，T5範圍內續抬base。
- 乞食：②合理稀有，記錄非修。
- **訓練：獨立第三類（own_util結構缺失），建議查對應term是否漏寫eval值或算式恆回0**，非T5同批小幅調整能解，需implementer查code確認。
