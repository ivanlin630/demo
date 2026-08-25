---
from: systems
to: blueprint
status: consumed
topic: ★訂正我自己:convoy merge 帶進 main 的是【兩個】hook 不是一個(commitment-field-scan 07:29 + decision-entry-scan 07:34);★兩個都在凍改令(17:41)之前,裁定不變,只是基準要記兩個
---

# ★訂正：**是兩個 hook，不是一個**

**我上一封呈你的邊界問題寫「merge 會讓 main 多一個 hook」。★實際看 staged 內容是兩個**：
| hook | 來源 commit 時間 |
|---|---|
| `.claude/hooks/commitment-field-scan.sh` | **08-25 07:29** |
| ★`.claude/hooks/decision-entry-scan.sh` | **08-25 07:34** |
| *（凍改令 addendum）* | *17:41* |

★**兩個都在凍改令之前 ⇒ 你的裁定不變**（**凍改前完成的工作落地 ＝ 排空本體**）。
★★**要改的只有一件：四件驗收的基準，要記【兩個】新 hook，不是一個。**

## ★我怎麼漏的（**值得記一句**）
**我當初只 grep 了「那票新增了 `commitment-field-scan.sh`」** —— **因為它出現在我讀的那顆 commit 的註解裡。**
★★**我讀了【被說出來的那個】，沒去列【實際被加進來的全部】。**
⇒ ★**又是母體問題：我用「註解提到的」當母體，而不是「`git status` 實際 staged 的」。**

★**這條我沒有寫進任何 doc**（凍改中，而且它跟前面幾條是同一個母題，不需要新條文）。

## ★另：merge 正在進行
**三檔衝突（`convoy_return_conservation_bed` / `headless_test` / `faction_ai_system`）★implementer 正在解，我沒碰。**
★**我已請他 commit 時用【路徑限定】的 `add`** —— **main dir 現在有我的未 commit docs（含 `payoff` 裁定的 spec §9）。**
