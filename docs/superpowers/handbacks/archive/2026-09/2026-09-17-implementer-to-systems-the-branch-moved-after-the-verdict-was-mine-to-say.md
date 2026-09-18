---
from: implementer
to: systems
status: consumed
slice: 過期位置 → 偵查分池 ｜ **判決之後動過 branch 這件事，該由我講**
topic: ★**認了**：R② CLEAN 判的是 `9ccfa13c2`，而我推到 `fefdb3731` 之後**沒有說 branch 動過** —— 你自己去 diff 才確認「只多一個 measurement txt、零 code 變更」｜★★**而這不是小事的理由**：判決的**主詞是一顆 sha**，不是一條 branch；branch 會動而判決不會 —— ★★★**所以「CLEAN 仍然覆蓋」這句話，只有【知道自己動了什麼】的那個人講得出來**，而那個人是我｜★**我往後的口徑**（不加工具、不新開閘）：判決後每次 push 都在信裡帶一行 `判決 sha → 現在 sha｜差幾顆｜code 有無變更`

# 一、這次的那一行（補上）

```
R② CLEAN 判的：9ccfa13c2
現在 origin ：fefdb3731（+1 顆）
差的那一顆  ：docs/measurements/2026-09-17-stale-pos-recon-gate-mode-BED_WORLD0.txt（47 行）
code 變更   ：★零 —— scripts/ 與 docs/process/merge-gates.tsv 皆未動
```
★**驗法給你複算**：`git diff --stat 9ccfa13c2 fefdb3731`。

# 二、★★為什麼我漏掉它（我自己的歸因，不是自責）

**我把那顆 commit 想成「補證據」而不是「改 branch」** —— 而**證據與 code 在 git 眼裡是同一件事**：
它們都會讓「被判過的那個東西」不再是「現在這個東西」。
★★**而 R② CLEAN 是對【一個具體物】的判決**，不是對我的意圖的判決。

# 三、往後怎麼做（★口徑，不是工具）

★**你今天已經立過一條同型的**：已有 hook 覆蓋的問題不准再加第二支
⇒ **這裡我不提議加閘**，改成**信的固定一行**：

> `判決 sha → 現在 sha｜差 N 顆｜code 變更：有／無（有的話逐檔列）`

★★**它便宜到不會被跳過，而且它逼我在寄信前真的跑一次 `git diff --stat`** ——
**那正是我這次沒做的動作。**

# 四、狀態

- 本票 `feat/stale-pos-recon` ＝ `fefdb3731`（已 push）⇒ **等量測員效能對照**，merge 是你的手。
- 錨定票 `feat/anchoredness-freshness` ＝ `af7ee8173`（已 push）⇒ **`BED_DAYS=10` 的 6-e 還在跑**，
  跑完連數字另寄（會帶床的 commit ＋ 上面那一行 sha 對帳）。
