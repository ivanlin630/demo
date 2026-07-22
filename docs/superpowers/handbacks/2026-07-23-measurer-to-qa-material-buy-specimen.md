---
from: measurer
to: qa
status: consumed
topic: "[§④b specimen·material-means-end-buy 買料 decision·想買卻買不到的故事] branch feat/material-buy ca199844。★故事:fix 讓 teams 想買 material(買料 option chosen 87-102×、post_buy.material 0→127)但買不到(deal seed1337=2/seed42=0)、weaponsmith 兩 seed 全 0 未建、weapon 未產。§④b 買料成交 sample(seed1337 2 筆):都 qty 1-2、買方 coin_after≈0.25-0.72(花到近0)、holding_after 9.8-13.5(遠低 weaponsmith 80)、stock_left≈0.1-1.3(把該點買乾)——即便成交也 coin-capped 到 1-2 單位,累積不到建 weaponsmith。你判:『想買卻買不到→仍建不了』故事 coherent 嗎?卡點(want-gate no_want 72% / coin 餓)哪個主導?判完 to:blueprint。"
measured_at_head: "branch ca199844 vs baseline d59b171b"
---

# §④b specimen：material-means-end-buy「想買卻買不到」→ QA 故事稽核

implementer 工單 item8：§④b bounded sample（買料 decision specimen）。branch `feat/material-buy` @ ca199844、seed1337+42、economy 探針。full verdict + 數字 → blueprint（`2026-07-23-measurer-to-blueprint-material-buy-verdict`），此為故事層。

## 故事：fix 讓「想買」，但「買不到」
- **想買 WIRED**：`買料` option chosen 102×（seed1337）/87×（seed42），`post_buy.material` 0→127。teams 現在真的想買 material 建 facility。
- **買不到**：material buy DEAL seed1337=**2**、seed42=**0**。weaponsmith 兩 seed **0→0 未建**，weapon 未產。

## ★§④b 買料成交 sample（seed1337 全 2 筆，`Probe.bump_sample`）
```
tick=9400  team=47(商業) buy material qty=2  holding_after=13.5  coin_after=0.25  stock_left=1.27  task=貿易
tick=13800 team=62(武力) buy material qty=1  holding_after=9.8   coin_after=0.72  stock_left=0.10  task=貿易
```
（seed42：0 筆成交——連這 2 筆都沒有。）

**讀法**：
- 兩筆都 **qty 只 1-2**（weaponsmith 需 80）。
- 買方成交後 **coin_after≈0.25-0.72＝花到近 0**——買 1-2 單位就沒錢了。
- `holding_after` 9.8-13.5＝**遠低於 weaponsmith 80**，買完仍差得遠。
- `stock_left`≈0.1-1.3＝**把該市場點買乾**（該點本來就沒多少貨）。

→ 即便極少數成交，**coin 餓 + 該點貨少 → 每筆只買 1-2 單位 → 永遠累積不到建 weaponsmith 的 80-120**。

## 對照 aggregate（bail 組成，seed1337）
- material buy 嘗試 81（武47/商34）；bail：no_want 58（**72%**）、cant_afford 7、carry_full 7、no_coin 4、no_stock 3；deal 2。
- ★no_want 72% = 到市場想買卻 `want=reserve−holding≤0`（reserve 被 liquidation-factor 稀釋 < 建設實需）。

## 你判什麼 → 判完 to:blueprint
1. 「teams 想買 material（選買料+張貼買單）卻買不到（deal≈0）→ 仍建不了 weaponsmith」——**故事 coherent 嗎**？是合理的「錢不夠/市場點貨少」還是機制斷（want-gate 誤擋）？
2. 兩卡點——**want-gate（no_want 72%）vs coin 餓（成交也只 1-2 單位）**——你眼球哪個主導？（決定第二半 fix 治哪個。）
3. fix「接上想買、沒接上買到」——這算**破 Gate B（進度半）**還是**未破**（結果 weaponsmith 仍 0）？

## 溯源
raw：`docs/measurements/2026-07-23-gateb-branch-{1337,42}.txt`（§④b sample + aggregate）。measured_at_head branch ca199844。instrumentation 已 revert、branch clean、determinism-safe（bump/read only）。
