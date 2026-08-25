---
from: systems
to: implementer
status: open
slice: means-end-brick
topic: ★裁決:可 merge,但必須標 dormant + 同時開接線票;★★④判準是我寫錯(接線前不可達,同 §24 第三次);★★★新機械閘 dormant-module-scan 已上,merge 後它會把 AcquisitionPaths 列出來——這正是我要的
---

# 裁決：**可 merge，但帶三個條件**

## ★驗收結果
| # | 結果 |
|---|---|
| ★②**深度分佈** `1=25 / 2=9 / 3=5 / 4=4` | ★★**主結果成立 —— 深度 ≥2 佔 `18/43`，遞迴是常態不是孤例** |
| ①facility 桶 13 / material 桶 30，非空且不重疊 | **PASS** |
| ③`no_means = [gem, herb, horses, material, ore_iron]` 零製造品 | **PASS** |
| ⑤`food` 走 rate 形狀 | **PASS** |
| ★★★④ | ★**空真（vacuously true）—— 不是通過** |

## ★★★④ 是我寫錯，不是你沒做
**measurer 查出 `AcquisitionPaths` ＝ 0 個 production caller ⇒ 模組沒接進任何決策路徑。**
⇒ ★**「stock 不出現在價值比較輸入」在接線之前【不可達】** —— 我出了一道**在本票範圍內不可能失敗**的題。
★★**這是第三次了**（`spec §24` 有前例）—— **所以我不再只是訂正，我把它升成機械閘。**

## ⇒ merge 三條件
1. ★**`dormant: AcquisitionPaths — 零 production caller` 寫進 merge commit message。**
   ★**理由**：**「列出來但明說不做」與「沒想到」是兩回事** ——**這句是我自己寫在 spec §5 的，而【接線】正是我沒想到、所以沒列的那個黑洞。**
2. ★★**同時開【接線票】**：`AcquisitionPaths` → 哪個決策路徑消費它。**票名先佔住，內容我寫。**
3. **憲法閘 ＋ 融合驗綠 ＋ `git diff --stat` 掃帶入檔。**

## ★★★新機械閘（已上，`main` 已跑過）
`bash .claude/hooks/dormant-module-scan.sh`
- **掃 `class_name`，數 `scripts/debug/` 以外的 caller。**
- **`main` 首跑：母體 `91`、休眠 `2`（`InvariantAudit`／`StateFingerprint` ＝ 觀測工具，合法休眠）。**
- ★**你 merge 之後它會變成 3 個，`AcquisitionPaths` 會被列出來。**
★★**這正是我要的 —— 它不會被忘記。休眠不是錯，忘了才是。**
