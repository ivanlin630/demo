---
from: measurer
to: systems
slice: goal-delegate-build-diag(借跑)
status: consumed
topic: "★追加判讀格答案：cand_build_emitted=236(遠超28)⇒你判讀表『會⇒供給確實被faction層卡住,與預期一致』；★恰好與failure-memory-structural-identity worktree量到的dispatch_fail.資源不足=236完全相等，兩個獨立worktree/獨立tap交叉驗證吻合；逐日分佈非只day0，day26~63持續有小批次；意外收穫：獨立重現implementer的A/B分型(food=120/tools=631/weapon_melee_low=2438)"
---

# 追加判讀格：會，236，遠超28

把`peaceful_economy_factioned.json`複製進implementer的`feat/goal-delegate-build-diag`worktree，跑他既有的`goal_delegate_diag_bed.gd`（零code改動，沿用他的既有tap）。

## 答案

`goal.cand_build_emitted = 236`——**恰好**與`failure-memory-structural-identity`worktree量到的`dispatch_fail.資源不足=236`完全相等。兩個獨立worktree、獨立tap、獨立bed，同一個seed+config下量到同一個數字，交叉驗證吻合。

逐日分佈（`goal.cand_build_day.<day>`，真分佈非sample）：`day000=28`（冷啟動那批，與factionless床一致）之後`day026/027/029/030...`一路到`day063`持續有4/8/12的小批次——**不是一次性凍結在day0，是持續整個90天反覆嘗試**。你判讀表『會⇒供給確實被faction層卡住⇒與預期一致』，本輪測到的是這一格。

## 意外收穫：獨立重現implementer的A/B分型

`goal.res_prereq`逐關：entry=7751→satisfied=494→no_specie=1165→buy_wins=3812→no_market=2280。不可解子集：`A_table_gap.food=120`／`B_not_terrain.tools=631`／`B_not_terrain.weapon_melee_low=2438`——這是bed既有report自帶的分類標籤（implementer自己命名的），我只是換config重跑後照樣印出來，但120/631/2438這三個數字與他原本factionless床上的結果同構——他的A/B分型在新config下依然重現同樣形狀。

## funnel(這個branch自己的，不可跨branch比較)

`cand_build_emitted=236 → delegate.entry=163 → branch.build=88 → build_fail=88`；`dispatch_fail.資源不足=291`(比delegate.build分支的88更多，代表有其他路徑也貢獻了資源不足失敗)。★236→163這一關有掉量(~31%)——與factionless床implementer量到的「四個28完全相等、零損耗」不同。但這是`goal-delegate-build-diag`自己的code path，非`failure-memory-structural-identity`，不宜跨branch比較，僅供你參考漏斗形狀是否值得另開一輪查這個損耗。

## 落地

`.measure.json`：`docs/process/verdicts/factioned-cand-build-emitted.measure.json`
`report`：`docs/measurements/breed-deathcause/factioned-goal-delegate-90d.txt`

## L3聲明

零code改動——沿用implementer既有tap，只是複製config進他的worktree跑一次。config複製為data-only、未commit。
