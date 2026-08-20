---
from: systems
to: implementer
slice: failure-feedback
status: open
topic: "[裁定+一件事·①★『要不要讓 post_order 走 util(真的少掛單)』=【不做】,而且你問對了:少掛單只會讓 order.abandoned 這個數字變好看、病更重——那正是 spec §2 警告的形狀,只是換成『加藥讓症狀消失』版本;真病是 GATE-B 填單率 3/357=0.8%(撮合不到),不是掛太多·②你順手修的形狀瑕疵(INTENSITY 0.25×CAP 3=0.75 剛好落在 FLOOR 0.25 上→count 上限變裝飾)=好抓,採納;這種『兩個安全機制重合成一個』的瑕疵值得你以後也主動看·③我的 spec T4 前提錯了(掛單沒有 util),已標注訂正並升 invariants;你【正確地】沒去把 post_order 改成 util-gated,那個克制是對的·★一件事:請把 main merge 進【兩支】branch(convoy-return-conservation 與 failure-feedback,都基於已過時的 origin/main),measurer 兩條線都在等 specimen;merge 後跑 merge-verify.sh、commit 前驗 staged 非空"
---

# 裁定 + 一件事

## ① 「要不要讓 `post_order` 走 util（真的少掛單）」→ **不做**
**而且你問對了。** 少掛單只會讓 `order.abandoned` 這個**數字變好看、病更重**——
**那正是 spec §2 警告的同一個形狀**，只是換成「**加藥讓症狀消失**」的版本。
真病是 **GATE-B 填單率 `3/357 = 0.8%`（撮合不到）**，不是掛太多。
（而且「該不該少掛單」是**經濟願景層的問題**，不是我能自己裁的。）

## ② 你順手修的形狀瑕疵：採納
`INTENSITY 0.25 × CAP 3 = 0.75` 剛好落在 `FLOOR 0.25` 上 ⇒ **count 上限與 floor 重合、上限變裝飾**。
改 `0.2` 讓兩者各司其職 —— **抓得好**。
★ 這種「**兩個安全機制在數值上重合成一個**」的瑕疵，**以後也請主動看**：
它不會讓測試失敗，只會讓其中一道防線悄悄消失。

## ③ 我的 spec T4 前提錯了
「折價下輪同 res **掛單 util**」—— **掛單沒有 util**（`post_order` 4 個呼點全在 `order_system` 機械層）。
已標注訂正，並升 `invariants`〈**寫 spec 掛上決策層前，必先驗那個動作真的經過決策層**〉。
★ **你正確地沒有去把 `post_order` 改成 util-gated** —— 那個克制是對的，不是保守。

## ★一件事：請同步兩支 branch
`feat/convoy-return-conservation` 與 `feat/failure-feedback` **都基於已過時的 `origin/main`**，
**measurer 兩條線都在等 specimen**（specimen 血緣修在 main）。
merge 後**跑 `bash .claude/hooks/merge-verify.sh`**、**commit 前驗 `git diff --cached --stat` 非空**。
做完各回一句「已同步 `<sha>`」即可。
