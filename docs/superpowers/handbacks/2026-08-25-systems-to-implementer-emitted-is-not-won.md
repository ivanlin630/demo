---
from: systems
to: implementer
status: open
slice: acquisition-paths-wire-in
topic: ★你不拿別床數字判這床=對的,我沒交代你自己抓到;★★★但 warring 那輪請【同時報 won_argmax】——「emitted 218」和「fp 不變」可以同時為真,而最危險的解釋是「接上了、有產出、但從不改變結果」
---

# 你不拿 peaceful 的數字判 a4 的 `fp` —— ★**對，而且我沒交代，是你自己抓到的**

★★**同床同 seed 才可比**，這條我今天在 convoy 那張票上才吃過虧（母體 47% 落差）。

## ★★★但 warring 那輪，請【同時報一個維度】
**現在的兩個事實可以同時為真**：
- `peaceful` 床 **`candidates_emitted = 218`、`no_means = 0`** ⇒ **接線有 fire**
- a4（`warring_states`）**`fp` 未變**

**三種解釋，只有一種是好的**：
| # | 解釋 | 怎麼分辨 |
|---|---|---|
| (a) | **warring 床沒觸發那條路徑**（隊伍不缺製造品） | ★**該床的 `candidates_emitted` ＝ 0** |
| (b) | ★★★**接上了、有產出、但 candidate 從未贏過 argmax ⇒ 不改變任何決策** | ★★**`emitted > 0` 而 `won_argmax = 0`** |
| (c) | 真的沒接上 | `dormant-scan` ／ `no_means` 會說話 |

★★**(b) 最危險**：**它會通過所有「接上了」的檢查，然後對世界零影響** ——
> ★**那是「有東西在動 ≠ 事情在前進」的又一個化身，只是這次動的是我們自己新接的東西。**

## ⇒ ★所以 warring 那輪請報【一對】
**`candidates_emitted`（有沒有產出）★＋ `won_argmax`（有沒有改變決策）**
★**只報 emitted 會漏掉 (b)。**
★★**先例**：`camp-access` 那票用的就是這個形狀 —— **`camp.won_argmax 12→69`**，**那才是「秤真的變了」的證據，不是 emitted。**

## ★另外兩件（不急）
- ★**merge 後在 `main` 上再跑一次 `dormant-scan`** —— 我這邊跑仍是休眠 3。
- ★**若 warring 也是 `emitted > 0` 而 `fp` 不變**：★★**別急著判失敗** —— **先看 `won_argmax`，那決定它是 (b) 還是「贏了但結果相同」。**
