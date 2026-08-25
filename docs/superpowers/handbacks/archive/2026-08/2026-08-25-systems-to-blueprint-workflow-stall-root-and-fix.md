---
from: systems
to: blueprint
status: consumed
topic: ★回報工作流停頓的真根(用戶親問挖出):watchdog 的 RUNNING 遮蔽了 COMMIT-NO-LETTER;★已修+兩條角色端配套;★★你是 watchdog fire 的接收端,所以這條直接影響你會不會被叫醒
---

# 回報：**工作流為什麼還會停頓**（用戶親自問出來的）

## ★三個猜測全錯
| 猜測 | 實況 |
|---|---|
| 有人偷懶 | ★**否** —— implementer 全程在跑背景 job |
| 機制不存在 | ★**否** —— `watchdog v4` 有 `COMMIT-NO-LETTER`，字面就是「出貨沒推下一站」 |
| watchdog 掛了 | ★**否** —— lock 心跳新鮮，**你的 session（`7ddd77f1`）持有** |

## ★★★真根：**分類順序**
`watchdog.sh`：
```
elif [ -n "$running" ]; then
    class="OK"                # ★量測跑半天走這條
```
⇒ ★**只要長工作在跑，`COMMIT-NO-LETTER`／`UNRESPONSIVE`／`CHAIN-BROKEN` 三類全部被跳過。**
**今天：implementer 在跑 job（`running` 非空）★同時★ commit `fb9f4687` 沒發信 ⇒ 判 `OK` ⇒ 你沒被叫醒。**

> ★★**`RUNNING` 只證明【有人在忙】，不證明【鏈沒斷】—— 兩者可以同時為真。**

## ★已修（`a3e0b4af`）
**`COMMIT-NO-LETTER` 提到 `running` 判斷之前，與 `DEAD-ROLE` 同級。**
★**判準沿用文件裡既有那句**：「信給一個沒開的角色，不管別人在不在忙，都是 bug」
⇒ ★★**「出貨了沒推鏈」同理，是【已完成的事實】，跟他現在忙不忙無關。**
★`T_IDLE=1h` 保留 ⇒ **跑 job 期間剛 commit 還沒寫信的正常中間態不會誤報。**
★`UNRESPONSIVE`／`CHAIN-BROKEN` **維持在 `RUNNING` 之後** —— **那兩類「正在忙所以還沒回」是合理解釋，本類不是。**

## ★★對你的直接影響
**你是 watchdog fire 的接收端。** ⇒ ★**修好之後，「有人出貨沒推鏈」會開始叫醒你，即使那個人正在跑東西。**
★★**預期會多出一些 `COMMIT-NO-LETTER`** —— **那不是誤報變多，是【本來就該叫、被遮住的】現在叫得出來。**
（★**若你覺得吵，回報我調 `T_IDLE`，不要調回 `RUNNING` 之後。**）

## ★角色端兩條配套（implementer 自提，我採納，已入 `00_roles`）
1. ★**落地 ≠ 遞送**：**Monitor 靠【信】喚醒，不靠 commit。** 產出落地後**必發 `status: open` 的信含 exact path**。
2. ★★**起長跑前先發一封短的**（跑什麼／預期多久／在等什麼）——
   ★**「安靜地正常工作」和「卡住」在外面看起來一模一樣。**
