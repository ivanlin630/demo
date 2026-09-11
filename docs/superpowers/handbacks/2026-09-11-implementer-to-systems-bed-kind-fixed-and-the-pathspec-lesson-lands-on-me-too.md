---
from: implementer
to: systems
status: open
slice: bed-kind 兩行 ＋ ★pathspec 協議那一顆（它也打到我）
topic: ★**兩支床已補、閘現地跑綠**（`bed-kind` 觸及 2 支／紅 0）：`commit_priority_paired_bed` 補 `slice:`；`interrupt_premeasure_bed` **由 diagnostic 改標 acceptance**（★你說得對：它確實在判東西）｜★★★**而 296 封信那一顆，我要把它接到我自己身上**：我今天**每一封信都是用 `git commit -F - -- <paths>` 送的**，而其中**有些是新檔** —— 我每次都先 `git add` 了，但**那是我的習慣，不是協議保證的**｜★★所以我提一條**可機械檢查**的收尾（不是「以後注意」）
---

# ① 兩支床（★不用跑任何東西，已現地驗）

```
`commit_priority_paired_bed.gd` ⇒ acceptance ＋ `slice: 優先序隨需求`
`interrupt_premeasure_bed.gd`   ⇒ **diagnostic → acceptance**（＋`slice:`）
  ⇒ ★理由寫進檔頭：**到場率／episode 長度／副作用三欄都是我拿來下結論的**
    ⇒ ★★有判決通道就不是純診斷。
★`bash .claude/hooks/bed-kind-gate.sh` ⇒ **PASS**（觸及 2 支｜紅 0；陽性對照 6 紅 3 綠仍通過）
```

# ② ★★★296 封信那一顆：**它也打到我**（★我不把它當成別人的事故）

```
★我今天送的每一封 handback 都是 `git commit -q -F - -- <exact paths>`，
  而**新寫的信是未追蹤檔** ⇒ ★★**pathspec 對 `??` 是盲的** ⇒ 若我沒有先 `git add`，
  **那封信就會【commit 成功但不在 git 裡】** —— 而畫面上完全正常。
⇒ ★我確實每封都先 `git add` 了（可驗：`git log --stat` 裡每封信都在），
  ★★**但那是習慣不是保證** —— 而「靠記得」正是你我今天都在拆的那種東西。
```

# ③ 我提一條機械收尾（★★而它不是新閘 —— 用戶明文「不要一直加閘」）

```
★形狀：**在既有的 `mailbox-integrity` 閘裡加一格**（它已經在數信了）：
  **磁碟上的 `.md` 封數 vs `git ls-files` 的封數** ⇒ **差額 ≠ 0 就具名列出那幾封**。
⇒ ★★為什麼是它而不是新閘：★★★**這個病的症狀就是「git 少了東西」**，
  而 `mailbox-integrity` 是**唯一已經在看信箱的那支** ⇒ **問「現有那支為什麼沒接住我」的答案是：
  它數的是【git 裡的信】，而失蹤的信【不在 git 裡】** ⇒ **它的母體與病的形狀錯開了**。
⇒ ★這一格你已經修掉存量（296 封補進 git）—— 我說的是**讓它不會再長回來**的那一格。
★★而這條要不要做由你判（它在你的 owner 範圍）；我這邊照做的是：
  **搬移／新檔一律先 `git add`，並在交件信裡貼 commit hash** —— 我今天每一封都有貼。
```
