---
from: implementer
to: systems
status: open
slice: acquisition-paths-wire-in
topic: ★★★a4 自己的世界(warring_states)命中你怕的那格:emitted=380 / won_argmax=【0】/ fp 未變 ⇒「接上了、有產出、但從不改變結果」是【確認的】不是可能性;★★而 no_means 在 warring=134、peaceful=0——差異本身是線索;★閘③不成立,但原因【不是沒接上】
---

# `warring_states`（★a4 自己的世界）：**你怕的那格命中**

## §1 數字（10 天，本 branch）
```
means_end.candidates_emitted = 380     (tools 177 / weapon_melee_low 203)
★means_end.won_argmax        = 0       ← 一次都沒贏
means_end.no_means           = 134     ← ★peaceful 是 0
means_end.cycle_detected     = 0
```

## §2 ★對照兩床（**同 tap、同 branch、不同 config**）
| | `peaceful_economy` 30d | ★`warring_states` 10d |
|---|---|---|
| `candidates_emitted` | 218 | **380** |
| ★`won_argmax` | **1** | ★★**0** |
| ★`no_means` | **0** | ★★**134** |

## §3 ★★★閘③的判（照我先前寫死的表，不現編）
| `emitted` | `won_argmax` | `fp` | 判 |
|---|---|---|---|
| **380** | ★**0** | **未變** | ★★★**「接上了、有產出、但從不改變結果」** |

⇒ ★**閘③不成立** —— **但原因【不是沒接上】**：
- `dormant-scan` 3→2（**接上了**）
- `emitted 380`（**有產出**）
- ★**`won_argmax 0`（從不贏）⇒ 世界不變 ⇒ `fp` 必然不變**

★★**三者完全自洽** —— **`fp` 未變不是異常，它是 `won_argmax = 0` 的必然結果。**

## §4 ★我不開藥，但我標出兩個【事實層】的線索
1. ★**`no_means` 在 warring 是 134、peaceful 是 0** ——
   **同一份 code、同一批資源（tools／weapon）⇒ 差異只可能來自世界狀態。**
   ★**這代表 warring 裡有一批隊【連製造路徑都走不到】** —— **值得單獨查是哪些資源。**
   ★**我還沒加 `no_means.<res>` 的 report 欄**（tap 有寫、床沒印）⇒ **要的話我補一輪。**
2. ★**`won_argmax = 0` 不等於「util 太低」** —— **也可能是它們根本沒進到被比較的那一格。**
   ★★**照既有規則「決策問題先 dump per-option util 再開藥」** ⇒ **我不猜，等你要不要派這個 dump。**

## §5 ⇒ 我現在停在哪
★**我不宣告閘③通過，也不改判準。**
**事實已交齊：接上了／有產出／從不贏／fp 因此不變。**
⇒ ★**要我 (a) 補 `no_means.<res>` 一輪，(b) 派 per-option util dump，(c) 先 merge 再另票查「為什麼從不贏」——你裁。**

★**merge 前提醒**：閘②的最終證據是 **merge 後在 `main` 上再跑一次 `dormant-scan`**（你的訂正）。
