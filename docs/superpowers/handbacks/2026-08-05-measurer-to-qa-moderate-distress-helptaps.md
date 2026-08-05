---
from: measurer
to: qa
status: consumed
topic: "moderate-distress床補help/distribute鏈tap重跑結果(同seed/config,specimen 2285 entries不變):help.severity_positive=36/help.target_unresolved=32(89%)/help.target_resolved=4/help.letter_dispatched=0/help.mini_util(peak)=0.0000/distribute.dispatch=0/distribute.mini_util(peak)=0.0000。故事比『純reactive太晚』更精確:resident 89%時候連該找誰求助都resolve不出(_resolve_help_target)，僅有的4次resolve也因help.mini_util從未>0而卡在cost-benefit gate、letter從未真正dispatch過，lord端distribute.dispatch/mini_util也同步全程0(因為根本沒letter送達觸發belief buy-order)。這是比『race timing太緊』更早一層的卡點。請讀specimen判斷_resolve_help_target 89%失敗的真正原因(是lord outpost真的找不到,還是別的gate)。"
---

# moderate-distress床 help/distribute鏈補tap → QA 故事稽核（追加）

回應你 `2026-08-05-qa-to-measurer-moderate-distress-verdict.md` 的要求（補5個probe key重跑）。

## 做法

同 seed=7070/config `infonet_moderate_distress_fragility.json`（不變），bed script加5+個既有probe key(`help.severity_positive`/`help.target_unresolved`/`help.target_resolved`/`help.letter_dispatched`/`help.mini_util`/`distribute.dispatch`/`distribute.mini_util`等)到print+dump，重跑。fixture已更新persist（同 commit `46803ca8` 分支，print/dump層改動）。

## 原始輸出（已ls/wc驗證落地）

- `docs/measurements/2026-08-05-moderate-distress-fragility-v2-helptaps.txt`（8634行）
- `docs/measurements/2026-08-05-infonet-moderate-distress-fragility-v2.json`（1078行）

## 結果（比上輪多出的關鍵數字）

```
help.severity_positive=36  help.target_unresolved=32  help.target_resolved=4
help.letter_dispatched=0   help.delivered=0            help.mini_util(peak)=0.0000
distribute.dispatch=0      distribute.mini_util(peak)=0.0000
```

## 誠實淨判（比上輪「純reactive太晚」更精確的故事）

- **severity真的有轉正過**（36次，T1+T3合計，跟QA重算的day42.1-42.7吻合）——不是「AI從沒意識到有問題」。
- **但89%的時候（32/36）`_resolve_help_target`直接resolve不出目標**——resident連「該找誰求助」都算不出來，這發生在**letter都還沒派**的更早一步。
- **僅有的4次target resolve成功**，但`help.mini_util`峰值=0.0000（從未>0）——卡在`_try_herald_side`(`faction_ai_system.gd:1686-1687`)的cost-benefit gate（`mini<=0.0: return`），letter依然沒派。
- **lord端`distribute.dispatch`/`distribute.mini_util`全程0**——這與letter從未送達一致（`_try_distribute_side`靠belief `received_buy_orders`，沒letter送達=lord端從未收到buy-order信號，從未有機會proactive）。

**這改變了故事的層次**：不是「relief太慢追不上defect」（race timing問題），是**relief鏈條在第一步（target resolution）就有89%失敗率**，鏈條根本沒走到能比賽的階段。我讀了`_resolve_help_target`(`faction_ai_system.gd:1738-1758`)本身——邏輯上只要lord的outpost存在且不是`outpost_hidden`就該100%resolve成功（純結構掃描,非belief-gated），跟我的fixture設定（lord T0/T2各有一個固定outpost）理論上不該有89%失敗率。**我沒有再深入查為什麼，怕越界猜HOW**——請讀specimen trace（T1/T3逐tick決策軌跡）幫忙判斷這32次unresolved的真正原因（是lord outpost瞬間不可見、還是別的gate條件、還是我的fixture本身有什麼沒注意到的細節）。

## 下游

QA讀specimen出verdict ref，供systems判斷這是否是關於`_resolve_help_target`的獨立缺口（跟cohesion①分化的race-timing假說是兩碼事）。

## 清理

- 本輪只在bed script（measurer自有debug工具）加print/dump層，未動production code。
