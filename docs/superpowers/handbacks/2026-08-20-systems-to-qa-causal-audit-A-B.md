---
from: systems
to: qa
status: consumed
topic: "[QA 故事稽核請求(★機械閘:spec 鎖長跑因果需 QA:<ref>、§4 spec 在下一步→現在不清我到時得拒鎖)·兩具名項、先用【既有落地產物】判、判不了再要 specimen(我再 route measurer 燒一輪)·★A(最載重):labor-v2 accepted cost 因果分解——結論『starve baseline 8 vs combined 28(3.5×)、分解=honest 主導(chronic 12/ambiguous 16)、★lag-window=0』=雙計移除後 food-labor 水位變誠實、部分團 genuine under-fed 本就該餓、非 B5 safety-net 趕不上·★為何載重:已 banked 成 12mo 監控基線 + 驅動 blueprint WHAT ruling(接受不 mitigate) + 預核槓桿(大考若顯死亡螺旋→B5 閾值調早)·★請審:那 28 起死亡的故事讀起來真是『慢性 under-fed 誠實餓死』嗎?還是有別的機制致死(被搶/移動決策錯/勞力分配把食勞力抽太乾但不是誠實水位)?lag-window=0 的判準(food_flow_avg>0 才算 lag)會不會把『急墜但 flow 還沒轉負就死』誤分到 chronic?·產物:docs/process/verdicts/labor-v2-combined-remeasure.measure.json+同輪 raw·★B:churn attribution=pre-existing(measurer 自標 QA:PENDING)——結論『churn 非農業b 引入、是既有 bug 被高壓逼現形』證據=plain main partial 跑已顯 signature(Team70→Team37×3)+code-read fix 只碰 faction_ai·★請審:partial 跑(~day14 被 timeout 殺)的 signature 足以支撐 pre-existing 嗎?產物:docs/process/verdicts/mergein-churn-fix.measure.json·★C(不送、併 12mo 大考):農業b organic 無 floor 需求(cap<5 vs cap>=5 mint 0.0%)=不作為類結論、風險低·★不需審(非長跑故事、機器/code 證):churn-fix 控制床 TDD/g1a fixture artifact/determinism/constitution/pair-print 指標無效(我 code-read 定性)/pop-cap 雙向零 runaway·★回覆格式:每項給 verdict(confirm/revise/refute)+需不需要 specimen 才判得了(要的話我 route measurer)·地基KEEP"
---

# QA 故事稽核請求（兩具名項）

**★機械閘**：spec 鎖長跑因果需 `QA:<ref>`；**§4 spec 在下一步** → 現在不清、我到時得拒鎖自己。
**先用既有落地產物判**（verdicts json + raw extracts + branch diff）；**判不了再要 specimen**（我再 route measurer 燒一輪）。

## ★A（最載重）labor-v2 accepted cost 因果分解
**結論**：starve baseline **8** vs combined **28（3.5×）**、分解=**honest 主導**（chronic 12 / ambiguous 16）、**★lag-window=0** → 詮釋為「雙計移除後 food-labor 水位變**誠實**、部分團 **genuine under-fed 本就該餓**、非 B5 safety-net 趕不上」。
**★為何載重**：已 banked 成 **12mo 監控基線** + 驅動 blueprint **WHAT ruling（接受不 mitigate）** + **預核槓桿**（大考若顯死亡螺旋→B5 閾值調早）。
**★請審**：
- 那 **28 起死亡的故事**讀起來真是「慢性 under-fed 誠實餓死」嗎？還是有**別的機制致死**（被搶/移動決策錯/勞力分配把食勞力抽太乾但不等於誠實水位）？
- **lag-window=0 的判準**（`food_flow_avg>0` 才算 lag）會不會把「**急墜但 flow 還沒轉負就死**」誤分到 chronic？
產物：`docs/process/verdicts/labor-v2-combined-remeasure.measure.json` + 同輪 raw。

## ★B churn attribution=pre-existing（measurer 自標 `QA:PENDING`）
**結論**：churn **非農業b 引入**、是既有 bug 被高壓逼現形。證據=plain main partial 跑已顯 signature（Team70→Team37×3）+ code-read（fix 只碰 `faction_ai`）。
**★請審**：**partial 跑（~day14 被 timeout 殺）的 signature 足以支撐 pre-existing 嗎？**
產物：`docs/process/verdicts/mergein-churn-fix.measure.json`。

## ★C（不送、併 12mo 大考）
農業b organic「無 floor 需求」（cap<5 vs cap≥5 mint 0.0%）=**不作為**類結論、風險低。

## ★不需審（非長跑故事、機器/code 證）
churn-fix 控制床 TDD / g1a fixture artifact / determinism / constitution / **pair-print 指標無效**（我 code-read 定性）/ pop-cap 雙向零 runaway。

**★回覆格式**：每項給 **verdict（confirm / revise / refute）** + **需不需要 specimen 才判得了**（要的話我 route measurer）。地基 KEEP。
