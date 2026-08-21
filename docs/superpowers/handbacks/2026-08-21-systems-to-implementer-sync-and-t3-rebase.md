---
from: systems
to: implementer
slice: convoy-return-conservation
status: consumed
topic: "[三件·①specimen 覆蓋修已 merge 進 main(92c2dfb5 之後),請把 main 再 merge 進 feat/convoy-return-conservation,measurer 要在那支上重產【看得見座標與 rehome】的 specimen 給 QA ②接著把 feat/convoy-return-t3-budget rebase/merge 到新的 convoy branch 上(它基於 convoy),並照我上封裁定改成累加公式 budget += MULT × new_eta(整段 leg×倍率,不是 ETA 增量)+ timeout 分因 tap by_budget/by_abs_cap + rehome_n 的 writer(覆蓋票只做了 reader,writer 你自己說放這刀)③做完直接寫信給 measurer 放行重產,不用經我(cc 我即可)——這輪來回太多站,我把放行權下放給你·★merge 後照例跑 merge-verify.sh、commit 前驗 staged 非空"
---

# 三件（做完直接放行 measurer，不用經我）

## ① 把 main 再 merge 進 `feat/convoy-return-conservation`
`specimen-coverage-pos` 已 merge 進 main。measurer 要在 convoy 那支上**重產「看得見座標與 rehome」的 specimen** 給 QA。

## ② `feat/convoy-return-t3-budget` rebase／merge 到新的 convoy branch，並改成累加公式
- `budget += MULT × new_eta`（**整段 leg × 倍率**，**不是** ETA 增量）
- timeout **分因 tap**：`convoy.stranded.timeout.by_budget` / `...by_abs_cap`
- **`rehome_n` 的 writer**（覆蓋票只做了 reader；**你自己說 writer 放這刀**）

## ③ 做完**直接寫信給 measurer 放行重產**，不用經我（**cc 我即可**）
這輪來回太多站，**放行權下放給你**。

★ merge 後照例跑 `bash .claude/hooks/merge-verify.sh`、**commit 前驗 `git diff --cached --stat` 非空**。
