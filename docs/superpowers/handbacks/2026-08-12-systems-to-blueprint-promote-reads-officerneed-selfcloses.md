---
from: systems
to: blueprint
status: open
topic: "[★硬讀答死循環疑(build 前抓讚)=promote_util 已讀 officer_need+創 named→鏈自閉無死循環、我 officer_need 補同時修 train+promote·硬讀(非猜、6×教訓、feat/named-scarcity-ab):①_try_promote_advisor:1714 var demand=officer_need(state,team)→promote 被 officer_need 驅動(satisfier)②:1720 util=promote_util(demand,...)>THRESHOLD 才 fire③:1736 state.add_member(team,new_named.id)→promote 創 named(spare+1)→下 tick officer_need=(desired−spare)/desired 降(terminator)·∴★鏈自閉無死循環:officer_need 高+候選(quality 過)→promote fire(side-action、info_side_dispatch cadence)→add_member→need 降→停;officer_need 高+無候選(全平民 quality<threshold)→promote 不 fire→train(main-task、養候選 tier-up)→候選夠格→promote fire→終止·train(main argmax task)/promote(side-action parallel)不同層不競 argmax·★用戶擔心的死循環(train 無限練不提拔)真根=promote 沒讀 officer_need→但硬讀確認 promote 已讀(demand=officer_need)+已創 named→死循環不存在;唯一 train-forever=promote 永不 fire despite 候選=多疑 lord pmult→0 永不提(genuine 弱勢非 bug、多疑不信人合理)·★current realistic dormancy 真根=officer_need 低(villages-only 缺 dispatch-demand)使『train util 低+promote util 低』兩者都 dormant(promote_util=officer_need 0.04×pmult×quality<<0.3)→我 officer_need dispatch-demand 補(已 dispatch implementer)★同時修 train(need 驅)+promote(need 驅)=一補解兩者、鏈自閉·∴不需額外死循環 fix、officer_need 補是核心;implementer 補完 realistic 驗『officer_need 高→(無候選)train→tier-up→(候選)promote→named+1→need 降→停』終止性即證·★我已在給 implementer 的 officer_need 補 handback 加驗收②bounded(bench 足/無 dispatch-demand→need 趨零不練)——涵蓋終止性、但補明確加驗『promote 降 need 終止(非無限練)』·merge 續 hold 待 realistic 驗終止+真 fire·序:implementer officer_need 補完→R²(核 promote 讀 need+termination+dispatch-demand 抓壓力)→measurer realistic 驗終止+真解→QA→merge·地基 KEEP·用戶 build 前 QA design 抓死循環=紀律讚(我 B framing 漏 promote-as-satisfier 半、硬讀補回)"
---

# ★硬讀答死循環疑 = promote 已讀 officer_need + 創 named → 鏈自閉無死循環

用戶 build 前抓死循環讚。硬讀（非猜、6×教訓、`feat/named-scarcity-ab`）：

## 硬讀結果
1. `_try_promote_advisor:1714` `var demand = officer_need(state, team)` → **promote 被 officer_need 驅動**（satisfier）。
2. `:1720` `util = promote_util(demand, ...)` > THRESHOLD 才 fire。
3. `:1736` `state.add_member(team, new_named.id)` → **promote 創 named（spare+1）→ 下 tick officer_need=(desired−spare)/desired 降**（terminator）。

## ∴ ★鏈自閉、無死循環
- officer_need 高 + 候選（quality 過）→ promote fire（side-action、info_side_dispatch cadence）→ add_member → need 降 → 停。
- officer_need 高 + 無候選（全平民 quality<threshold）→ promote 不 fire → train（main-task、養候選 tier-up）→ 候選夠格 → promote fire → 終止。
- train（main argmax task）/ promote（side-action parallel）**不同層不競 argmax**。
- ★用戶擔心的死循環（train 無限練不提拔）真根=promote 沒讀 officer_need——**但硬讀確認 promote 已讀（demand=officer_need）+ 已創 named → 死循環不存在**；唯一 train-forever=promote 永不 fire despite 候選=多疑 lord pmult→0 永不提（genuine 弱勢非 bug）。

## ★current realistic dormancy 真根 + 一補解兩者
= officer_need 低（villages-only 缺 dispatch-demand）使「train util 低 + promote util 低」兩者都 dormant（promote_util=officer_need 0.04×pmult×quality<<0.3）→ 我 **officer_need dispatch-demand 補（已 dispatch）★同時修 train（need 驅）+ promote（need 驅）= 一補解兩者、鏈自閉**。∴不需額外死循環 fix、officer_need 補是核心。

## 序
已在 implementer officer_need 補 handback 加驗收 bounded；補明確加驗「promote 降 need 終止（非無限練）」。implementer 補完 → R²（核 promote 讀 need + termination + dispatch-demand 抓壓力）→ measurer realistic 驗**終止性**（練→提拔→need 降→停）+ 真解 → QA → merge。merge 續 hold 待 realistic 驗終止+真 fire。地基 KEEP。
