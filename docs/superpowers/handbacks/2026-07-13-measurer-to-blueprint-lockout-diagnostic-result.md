---
from: measurer
to: blueprint
status: consumed
topic: zero-option三類分流結果——★9個死鎖option全部歸類「base-util競爭」(③)，無一項符合「真coeff-lockout」(②)標準；★TC7貿易確認為base-util競爭非coeff壓制(own_util僅贏家util的1/50~1/170)；意味修法方向=affinity/base權重tune，非S3鬆綁coeff
---

# 量測回報：zero-option 三類分流診斷（3seed×3mo full_probe）

工單：`2026-07-13-implementer-to-measurer-lockout-diagnostic-probe.md`。`.worktrees/peroption-probe`（feat/peroption-probe @5e9438b）。determinism CLEAN（`diag_det1.json`/`diag_det2.json` byte-identical）。headless 0新增SCRIPT ERROR。

## 分類結果（9個零選中option逐項，跨3seed）

| option | avg_coeff (3seed範圍) | avg_mainurg | ownutil vs winutil | 分類 |
|---|---|---|---|---|
| **貿易** | 0.61-0.62 | 0.22-0.59 | 0.03 vs 1.5-5.1（**50-170倍差**） | ③base-util競爭 |
| 備戰 | 0.49-0.62 | 0.10-0.31 | 0.24-0.31 vs 2.8-3.9 | ③base-util競爭 |
| 求和 | 0.46-0.59 | 0.10-0.31 | 0.12-0.13 vs 2.8-3.9 | ③base-util競爭 |
| 駐守 | 0.55-0.61 | 0.03-0.47 | 0.16-0.20 vs 2.0-2.4 | ③base-util競爭 |
| 乞食 | 0.86-1.00 | 0.88-1.00 | 0.63-1.07 vs 9.0-11.4（appl_n極低1-245） | ①稀有 + ③base-util |
| 併入 | 0.53-0.66 | 0.00-0.15 | 1.26-1.52 vs 7.9-9.0 | ③base-util競爭 |
| 吸納 | 0.58-0.61 | 0.00-0.01 | 0.07-0.13 vs 0.5-3.2 | ③base-util競爭 |
| 訓練 | 0.74-0.83 | 0.51-0.99 | ~0.00 vs 0.5-3.3 | ③base-util競爭 |
| 買糧 | 0.90-0.90 | 0.92-0.92 | 0.91-1.06 vs 9.9（**~10倍差，coeff幾乎不壓**） | ③base-util競爭 |

## ★核心發現：無一項落入②真coeff-lockout

判準要求 `avg_coeff<0.5` **且** `avg_mainurg>0.6` 同時成立——**9個option裡沒有任何一個同時滿足兩條件**。多數option的`avg_coeff`落在0.5-0.9區間（並未被壓到<0.5），部分（買糧`0.90`、乞食`0.86-1.00`、訓練`0.74-0.83`）幾乎沒被coeff壓制過。**S3「卡住自動鬆綁」對這9個option不對症**——它們不是被coeff壓死，是**自身base utility結構性偏低**，怎麼鬆綁coeff都救不回來（coeff接近1時仍輸給winner 5-170倍）。

## ★TC7貿易——確認為base-util競爭，非collapse誤判
貿易`avg_coeff≈0.61`（中等，非重壓），`ownutil=0.03` vs `winutil=1.5-5.1`——**50到170倍的落差**，是9個option裡差距最懸殊的。貿易的own-util算式本身給出的分數就趨近0，無論coeff怎麼調都翻不了身。implementer信§原本疑慮「貿易獨大」是誤判方向，**真相是貿易own-util公式本身壓過低**。

## 判讀（誠實分類，不代判tune方向）
- 9個option全數落③（或①+③複合，乞食）——**修法方向應是affinity/base utility權重tune，非S3 coeff-lockout鬆綁**。
- `mainurg`（主層急迫度）普遍偏低（0.00-0.47，多數<0.3）也是共同特徵——這些option對應的需求層本身在organic世界裡很少進入高急迫態，這本身可能是另一條線索（affinity層映射是否精準，或這些option對應的需求layer觸發門檻）。
- 是否要動base_util公式/affinity表/mainurg計算方式，交你裁——我只分類現象。

## 產物
`diag_det1.json`/`diag_det2.json`（determinism），`diag_organic_3mo.json`（full_probe），`tools/orchestrator/runs/diag_readable.txt`（跨seed可讀分類數字）。

## 待你
S3序（卡住自動鬆綁）本輪數據顯示**對這9個option不對症**（非coeff壓制問題）——是否仍照原序dispatch S3，或先處理base-util/affinity權重，交你判。
