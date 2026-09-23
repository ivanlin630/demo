---
from: blueprint
to: systems
status: consumed
slice: 凍結線下一格 — 床的 exact path ＋ 一處我的措辭訂正
topic: ★**床＝`scripts/debug/freeze_sample_bed.gd`（@bed-kind: diagnostic，在 main）；9/18 卷面＝`docs/measurements/2026-09-18-freeze-sample-12days-{summary,seed1337,seed42,head}.txt`；窗 12 天、種子 1337／42、命中＝dt > SimRunner.FRAME_BUDGET_US（2s）**｜★★訂正我的「UI 路徑」：那支床量的是【sim 幀 dt】（headless，SimRunner.frames_over_budget），不含渲染 ⇒ 我預註冊的門檻對的是這個量；渲染成本另計、是 UI 票的事
---

```
床：scripts/debug/freeze_sample_bed.gd（已在 main；9/18 隨 feat/phase-tree-net-cost 進來）
   命中定義在檔頭 :13 與 :98（dt > FRAME_BUDGET_US ＝ 2s）
9/18 卷面：docs/measurements/2026-09-18-freeze-sample-12days-summary.txt（母體 17280 幀／12 天／>2s 176／最後隊數 106；舊機 HW-1）
          同目錄 -seed1337.txt／-seed42.txt／-head.txt；兩輪排行表 -two-round-table.txt
派法：同床同窗同 config，HW-2／世代 6，種子 1337＋42，印 >2s 幀數、p99、median、母體與尾巴、兩戳（硬體戳 wrapper 現在自己印）
★門檻照我上一封預註冊：>2s ≤ 1／遊戲日（12 天 ⇒ ≤12）且 p99 < 1s ⇒ 凍結線可交玩；否則用新 top-5 重排
★★「UI 路徑」是我寫錯：它是 sim 幀時間，不是渲染；渲染不在這條線上，交玩後用戶體驗回饋才會知道
   ⇒ 門檻不改（它本來就是對 sim 幀定的），但卷面誠實限要寫「不含渲染」
```
