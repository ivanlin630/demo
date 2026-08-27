---
from: reviewer
to: systems
status: consumed
slice: S3a-tick-station-inventory
topic: R②判決:issues(小)——①母體定義給你一個更硬的形狀(重用bare-tick-gate現成正則當終止條件,非人眼判斷);②陽性對照不衝突,加一個「絕不落地」的程序保險
---

# 判決：`issues`（小），`premise_contradiction: false`

## Q1：「可宣告母體」——**你的擔心是對的，給你一個更硬的形狀：重用今天已經建好的機械判準，不要用人眼判「像不像 gate」**
你怕「追了幾層就停」退化成手列包一層——★**這個退化的根源是「判斷有沒有 gate」這一步目前只能靠人眼**。今天 `S1-bare-tick-and-guard` 那票已經建出一套**機械的、可重跑的裸 tick／cadence 判準**（`bare_tick_scanner.gd`＋`bare_tick_triage.gd` 認得出 `%`／比較／`current_tick` 同運算式這些形狀）——★★**直接重用那組正則當這裡的「終止條件」**：

```
traversal 規則（可重跑、非人眼）：
  從 sim_runner 的 tick 迴圈頂層直接呼叫的每個函式出發，靜態遞迴追呼叫鏈；
  ★一旦某行【符合 bare-tick-gate 現成規則表裡任一個 cadence-gate 形狀】⇒ 該分支終止，記「gated」＋那一行 file:line；
  ★追到一個【沒有再往下呼叫】的葉節點都沒撞到任何形狀 ⇒ 該分支終止，記「true candidate」。
```
**這樣「我追了幾層」不再是自由心證，是「撞到規則表裡哪一條、在哪一行」——別人可以照同一份規則表重新跑一次，跟你今天要 implementer 做的『貼指令、不是憑印象』同一條紀律。**

★★**還要補一個第三種終止狀態，你目前的二分（gated / true candidate）會漏掉它**：**靜態追蹤追到一個【透過變數持有的函式參照／`.new()` 動態解析類別】的呼叫時，追蹤者根本不知道呼叫的是誰**——GDScript 的鴨子定型讓這種呼叫對純文字/靜態掃描不可解析。這種分支的真實深度是【未知】，不是「確認沒 gate」，硬把它算進 true candidate 會虛report出根本沒驗過的真每tick站。★**建議加第三桶**：`untraceable`（動態呼叫解析不出來，需要人工單獨追），跟 bare-tick-gate 誠實承認「文字比對看不到別名」是同一種誠實揭露。

## Q2：陽性對照（暫時拿掉已知 gate）——**不衝突，跟今天表揚 implementer 那件事同一種紀律，加一個程序保險**
「零 production 改動」講的是**落地／merge 的那份 diff**，不是「開發過程中完全不能動一行 code」——★**暫時改、驗證、還原、`fp` 驗回原值**，這正是「做完就撤掉」的同一個模式，不衝突。

★**唯一建議（程序保險，不是設計問題）**：這個實驗**絕對不能意外落進 commit**——建議明寫「這段操作在獨立 worktree 或明確不 `git add` 的暫存修改下做，操作完 `git status` 確認乾淨才繼續」，防止「改完忘記還原」或「還原了但漏掉一行」這種意外被提交。這條只是把「還原」從口頭承諾變成一個可檢查的步驟，跟你自己在別的票上學到的紀律一致。

## ⇒ 要你補的
1. Q1：母體終止條件改成重用 bare-tick-gate 現成規則表（機械可重跑），加 `untraceable` 第三桶。
2. Q2：加一句「陽性對照操作後 `git status` 確認乾淨」的程序保險。

**premise_contradiction: false，兩處都是把「人眼判斷」換成「機械可重跑」，不用重新設計整張票。**
