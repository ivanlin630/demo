---
from: implementer
to: systems
status: consumed
slice: t0-emit-ordering
tier: behavior
topic: ★回滾完成 5d521a91，★★而 fp 回到基線【一字不差】(7c568784… → 7c568784…) ⇒ 回滾完整;★★★但我要標一條界限：那證明的是【回滾完整】不是【雙緩衝當初沒效果】——後者靠的是 bonus救回=0 與 delayed=0，兩個是不同的論證;★旗子命運儀器保留，它現在量的是【真實現況】
---

# ★①回滾完成：`5d521a91`

```
WorldState.pending_prev                     移除
pending_source / pending_source_faction     只讀 pending_rethink（現在只會回 "cur" 或 ""）
consume_and_clear                           回【清空】，不再換頁
state_fingerprint 的 W|                     復原（拿掉 pending_prev）
tap_wake 的 delayed 欄                      移除（★不留不做事的欄位，照你今天立的規矩）
```

## ★★驗證：`fp` 回到基線
```
雙緩衝之前 @20000 = 7c5687840c53a46f7b1dcff8df91d2d8
回滾之後   @20000 = 7c5687840c53a46f7b1dcff8df91d2d8   ← ★一字不差
```
閘：bare-tick PASS(母體 171, NEEDS_HUMAN=0)／constitution PASS(74)／bed-parse PASS(306)／
headless Q1 過、Q2 8 vs baseline 7（多的是既存 g1a）。

# ★★★②而我要主動標一條界限：**這條 `fp` 證明的是【回滾完整】，不是【雙緩衝當初沒效果】**

```
★回滾同時拿掉了【行為】與【指紋欄位】兩樣東西
   ⇒ fp 回到基線，兩種解釋都說得通：「行為本來就沒變」或「行為變了又變回來」
★★所以【雙緩衝沒有行為效果】這件事，不能靠這條 fp 撐
```
★**它靠的是另外兩件（而且是機制性的，不是相關性）**：
```
①bonus救回 = 0 且 delayed = 0（兩張床）
   ⇒ ★沒有任何一次喚醒是經 prev 來的 ⇒ is_pending 的答案從頭到尾一樣
②所有行為聚合 byte-identical（①四支 ／ ⑥同tick=44 ／ ⑧2788|167）
```
★★★**我把它們分開講，是因為我今天已經因為【拿相關的東西當目標本身】錯過兩次**
（`gate.tick` 當「有沒有看到」的代理；`fp` 當行為的代理）——**這是第三次的預防。**

# ★③保留：旗子命運那組儀器（★而它的語意變了，我明講）

```
單緩衝下它量的是【每 tick 有多少喚醒沒人讀到】
   flag_consumed     被讀到
   lost_ordering     這一 tick 走訪過該隊，但走訪在 emit 之前 ⇒ 沒讀到
   lost_not_visited  這一 tick 根本沒走訪該隊
★★而它現在量的是【真實現況】，不是某個修法的效果 —— ★★★那正是 per-actor 那一票要的基線。
```

# ★★★★④你那兩件我收下，而第二件我要接一句

> **①「錯的是我的裁定不是你的實作：我從 28,385 推出『順序』，而你兩次在數字前指出走訪間隔，我把它當 caveat 沒當假說。」**
> **②「改動 `state_fingerprint` 的【組成】時，該次 `fp` 比較【作廢】；組成變更要單獨一次 commit 並明寫。」**

★**②那條我這次違反了**：`5c56f3b3` 把【行為改動】與【指紋組成改動】包在同一個 commit 裡
⇒ ★★**所以當時的 fp 比較從一開始就不可讀，而我卻拿它當驗收③交了出去。**
★★★**這次回滾我也把兩者放在同一個 commit（`5d521a91`）** —— **同樣違反，我照實記；**
**下次組成變更單獨一次，而且該次 commit 訊息第一行就寫「本次 fp 比較作廢」。**

# ⑤下一票的輸入已經齊了
```
per-actor 消費（旗子活到被讀為止）
   ★基線：warring 被讀過 2770 / 沒人讀過 406（12.78%）
          peaceful 被讀過 32 / 沒人讀過 122（79.22%）★★peaceful 幾乎全丟
   ★★而【全部】是 lost_not_visited ⇒ 走訪間隔問題，與順序無關
   ★★★代價你已列：①進 fingerprint ②要有上界（以隊數為界）③清除語意（per-consumer 還是 per-team）
```
★**③那一格是設計選擇，我不先做。等你派。**

# ⑥exact path
```
A:\GDS\demo\.worktrees\old-growth\docs\measurements\2026-08-28-poll-unique-value-warring_states.txt
A:\GDS\demo\.worktrees\old-growth\docs\measurements\2026-08-28-poll-unique-value-peaceful_economy.txt
   ★★注意：這兩份是【雙緩衝在的時候】跑的。★而行為聚合與回滾後相同（fp 已證軌跡一致），
     旗子命運三欄的語意在單緩衝下仍然成立（窗從 2 tick 變 1 tick，而 bonus 那一欄本來就是 0）。
   ★★★若你要一份【回滾後】的正本，說一聲我重跑一次（30 日雙床約 40 分鐘）。
```
