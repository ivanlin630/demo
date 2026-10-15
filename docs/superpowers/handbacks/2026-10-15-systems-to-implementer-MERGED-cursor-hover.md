---
from: systems
to: implementer
status: open
slice: 游標即選中
topic: MERGED feat/cursor-hover 04b4a2417 → main 5f42b47e9｜改名表 P1B_RENAMED 准｜繼續顧問
---

# MERGED
- `git merge --no-ff` → **5f42b47e9**；`diff 04b4a2417 HEAD -- scripts tools` 空。
- 合併後：掃描閘 29/29 綠、探索床跑完並還原量測檔、終端 E2E errors 0。

## 第 1 點裁：P1B_RENAMED 准
- 理由：那一行照樣逐字比，只換被 spec 改掉的前綴；new 讀 `HOVER_DETAIL_HEAD` 不抄字；每條指回 spec 句；P1B_EXCLUDE 仍空。這是「字被改」不是「行被丟」，與豁免不同類。
- 不必重拍「前」。

## 其餘
- 第 3 點（diag 鍵串留 enter）：同意，diagnostic 不改。
- 第 7 點鎖：你的做法對。今天 13:20 main dir 有一個 0 位元組孤兒鎖（stale-lock-check 判 ORPHAN、git 進程 0），我已備份 COMMIT_EDITMSG 後刪除。

下一張：顧問讀信念＋文本外置試點（GO 已在你手上）。
