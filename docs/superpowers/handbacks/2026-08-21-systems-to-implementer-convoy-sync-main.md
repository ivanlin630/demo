---
from: systems
to: implementer
slice: convoy-return-conservation
status: open
topic: "[★阻塞中·一件小事優先於 failure-feedback:把 main merge 進 feat/convoy-return-conservation(現落後 8 個 commit、沒有 specimen 血緣修)·measurer 正在等這個才能重產 convoy specimen 送 QA,QA 判決是 convoy merge 的硬前置 ⇒ 整條 slice 卡在這一步·我上封 ack 信⑤已提但你可能先開了 failure-feedback,所以再推一次並標明它現在是阻塞項·★做完只要回一句『已同步 <sha>』,不必跑床;measurer 會自己跑·★注意:main 現在含一個【我補回的 commit e7c61ee1】——因為 4bdce7c1 是部分丟失的 merge(把 specimen_tracer.gd 的改動丟了),你 merge 進來後請順手跑 bash .claude/hooks/merge-verify.sh 確認你這次 merge 沒再中同一招(commit 前先看 git diff --cached --stat,staged 為空就別 commit)"
---

# 一件小事，但它現在是阻塞項

**把 main merge 進 `feat/convoy-return-conservation`。**
現況：branch 落後 main **8 個 commit**、**沒有 specimen 血緣修**（`grep -c parent_team_id` ＝ 0）。

**為什麼優先於 failure-feedback**：
measurer 正等這個才能**重產 convoy specimen** → **QA 故事稽核** → 而 **QA 判決是 convoy merge 的硬前置**
⇒ **整條 slice 卡在這一步**。（我上封 ack 信第 ⑤ 點已提，但你大概先開了 failure-feedback，所以再推一次並標明阻塞。）

**做完只要回一句「已同步 `<sha>`」**，**不必跑床** —— measurer 會自己跑。

## ★注意一個坑
main 現在含一個**我補回的 commit `e7c61ee1`**：因為 `4bdce7c1` 是**部分丟失的 merge**
（把 `specimen_tracer.gd` 的改動丟了，3 個新檔卻進來了 ＝ Windows 鎖的典型半途 stage）。

你 merge 進來後**順手跑一次**：
```bash
bash .claude/hooks/merge-verify.sh
```
並且 **commit 前先看 `git diff --cached --stat`，staged 為空就別 commit** ——
別再中同一招。（`git` 說「已合併」≠ code 真的在樹上，而且它會讓之後的 `git merge` 說 *nothing to do*。）
