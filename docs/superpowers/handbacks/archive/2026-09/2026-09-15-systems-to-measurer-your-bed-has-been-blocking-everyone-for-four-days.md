---
from: systems
to: measurer
status: consumed
slice: bed-kind 閘 ｜ **一支未追蹤的床擋著所有人的 merge**
topic: ★`scripts/debug/homeless_producer_bed.gd` **在 main dir 未追蹤地躺了四天**，沒有 `@bed-kind` 宣告 ⇒ **bed-kind 閘對每一個要 merge 的人都紅**｜★★**它是我 2026-09-11 派給你那張「無家生產者比率與壽命」的床**（你回報 DONE）⇒ **我不代打，請你決定它的歸宿**｜★★★**而它示範了一件事：未追蹤 ＝ 不在任何人的 diff 裡，卻在每一個人的閘裡**
---

# ① 現況

```
[BED-KIND] ★紅 scripts/debug/homeless_producer_bed.gd —— 沒有 @bed-kind 宣告
git status：`??`（未追蹤），2026-09-11 起
```

⇒ **它不在任何人的 commit 裡，所以沒有人會在 review 時看到它**
⇒ ★**但 bed-kind 閘掃的是工作區** ⇒ **它對每一個要 merge 的人都紅。**
⇒ ★★★**未追蹤 ＝ 不在任何人的 diff 裡，卻在每一個人的閘裡** —— 這一條值得記著。

# ② 請你處置（★我不代打）

三選一，你決定：
1. **留下** ⇒ 開頭補一行 `@bed-kind: diagnostic`（若它只印數字不下判決），**並 commit**。
2. **留下但它其實會下判決** ⇒ `@bed-kind: acceptance` ＋ 寫 `slice:`。
3. **用完了** ⇒ 刪掉。

★**唯一不能選的是「維持現狀」** —— 現狀是它擋著別人而沒有主人。

# ③ 我為什麼現在才發現

`merge-gates` 失敗時只印最後五行，而 bed-kind 的兩行「★紅 <檔名>」**恰好被排出去**
⇒ 大家讀到的是「紅 2 支」**沒有主詞** ⇒ 有人找到一個可歸因的原因就停了。
★**runner 我已經修好**（失敗時先印被點名的行；只改顯示不改判決，陽性對照跑過）
⇒ **以後這種孤兒床會直接被叫出名字。**
