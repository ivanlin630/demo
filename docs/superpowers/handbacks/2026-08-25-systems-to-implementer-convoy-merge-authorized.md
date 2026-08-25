---
from: systems
to: implementer
status: open
slice: convoy-return-task-authority
topic: ★merge 准(blueprint 裁:凍改前完成的工作落地=排空本體,非改工作流);★merge 前三閘 + merge 後兩驗;★★新 hook 首次在 main 上跑,依我自己立的法要驗它真的響
---

# ★merge 准

**blueprint 裁定原文**：**「凍改前完成的工作落地 ＝ 排空本體，非改工作流；不准則凍改令自鎖死。」**
★**新 hook 入基準已標給用戶；四件驗收以【merge 後的 main】為基準。**

## ★merge 前三閘（照既有規矩）
1. **`.\tools\godot.ps1 --headless --script scripts/debug/constitution_gate.gd`**
2. **融合驗／framework 綠**
3. ★**`git diff --stat` 掃帶入檔** —— ★★**別 session 的 WIP 今天已經在 main dir 掃入過一次**，這條不是形式。

## ★★merge 後兩驗（**我這邊也會跑一次**）
1. ★**`bash .claude/hooks/commitment-field-scan.sh`** —— ★★**它第一次在 `main` 上跑。**
   **依我自己立的法（「閘說會響，要驗它真的響」）：★如果它此刻是綠的，那只證明【現在沒有未分類欄位】，不證明【它會響】。**
   ⇒ ★**若你還沒自測過「故意加一個未分類欄位 ⇒ 它紅」，補一次**（★**你在 `Probe` 那次做過同樣的事，形狀一樣**）。
2. ★**`bash .claude/hooks/dormant-module-scan.sh`** —— ★**`CommitmentFields` 是新 `class_name`，確認它不會變成第 4 個 dormant。**
   （★**我看到 `persist_strength.gd` 有呼叫 `CommitmentFields.build_tile`，所以預期不會 —— 但那是我讀的，跑一次比較實在。**）

## ⇒ merge 完，`convoy` 三件齊
**判決信 ✓ ｜ `porcelain` ✓ ｜ merged ✓** ⇒ ★**排空清單剩兩張。**

★**其餘照舊**：`acquisition-paths-wire-in` 等 380 分類／`failure-memory ①` 排你之後。
