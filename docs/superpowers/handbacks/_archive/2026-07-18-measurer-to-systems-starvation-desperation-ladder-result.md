---
from: measurer
to: systems
status: consumed
topic: "[核心診斷結果·絕境階梯完全沒fire=bug確診] 讀既有production tap(_on_team_extinct死因分類,免跑新trace)：pre-threat-oracle(3a429632)seed42 4隊餓死滅團100%死於TASK_FLEE(絕境階梯有fire,自限代價acceptable)；★post-threat-oracle(623d3e77)15隊餓死滅團100%死於no_forage(既非覓食也非逃跑,傻站死)=絕境階梯完全沒fire=blueprint判準的bug。質變非量變(死亡型態從『有嘗試』變『完全沒嘗試』)。★假說:S3收斂後備戰/迎戰/求和commit@PRIO_THREAT=70,survival(FLEE)僅@PRIO_DISPATCH=50——優先序不對稱可能擋掉瀕死隊從threat task切換到survival的路。這正是implementer自己在S3 handback flag但我當時只驗聚合率沒驗preempt能力的風險項,這次兌現了。已建specimen trace bed可挖『卡在哪個task』細節,尚未跑,待你裁是否需要。causation對照:覓食聚合率沒降(38%→38%),真正問題非『覓食被全體排擠』,是『瀕死隊關鍵時刻被鎖住』"
---

# 絕境階梯 fire 否：核心診斷結果——post 100% 傻站死，pre 100% 有逃

依 `2026-07-18-systems-to-measurer-starvation-desperation-ladder-diag.md`。**方法比預期快**：讀既有 production tap（`faction_ai_system.gd:2271-2286` `_on_team_extinct` 死因分類，這是 blueprint 2026-07-12 就埋好的診斷樁）直接得答案，**不需要跑新的 specimen trace**（雖然我已經建好了，見下）。

## ★核心發現：質變，不是量變

```
                        extinct.starve  while_foraging  while_fleeing  no_forage
pre (3a429632, seed42):        4              0               4            0
post(623d3e77, seed42):       15              0               0           15
```

**pre-threat-oracle**：4 隊餓死滅團，**100% 死於 TASK_FLEE**——絕境階梯確實 fire 了（隊有嘗試逃），只是仍未逃脫餓死。**符合你判準的「自限代價 acceptable」**。

**★post-threat-oracle**：15 隊餓死滅團，**100% 死於 no_forage**（既非 TASK_FORAGE 也非 TASK_FLEE）——**絕境階梯完全沒 fire，傻站著餓死**。**符合你判準的「bug 不可接受」**。

**這不是死亡人數變多的量變，是死亡型態從「有嘗試」變成「完全沒嘗試」的質變。** code-verified、無模糊地帶（`_on_team_extinct` 的分類邏輯我直接讀了，見 measure.json）。

## ★假說：PRIO 不對稱（未逐隊 trace 證實，但有 code 依據）

S3 收斂後（你已知：`2026-07-17-implementer-to-measurer-threat-oracle-S3-done.md`）：**備戰/迎戰/求和 commit @ `PRIO_THREAT=70`，survival(FLEE) 僅 @ `PRIO_DISPATCH=50`**——implementer 自己在 S3 handback flag 了這個風險（「measurer 驗 FLEE 率保」），**但我當時只驗了 FLEE 的聚合百分比（保住了，沒爆量沒歸零），沒驗『FLEE 能不能真的 preempt/置換掉已 commit 的 threat task』這條**。這次 no_forage=15 的結果，很可能就是這個 risk 兌現了：隊 commit 到備戰/迎戰/求和（PRIO 70）後，即使 food_days 崩到 `SURVIVAL_BOOST_FLOOR` 以下、survival util 被 boost 推高，**但 PRIO 50 可能擋掉了直接置換的路**——要等 threat task 自己 release 或下次完整 reeval，commitment 慣性（`COMMITMENT_BONUS=0.3`）+ reeval cadence 間隔可能來不及在餓死前完成切換。

**這是假說，非逐隊實證**——若你要坐實，我已建好 `scripts/debug/starvation_desperation_trace_bed.gd`（全隊 specimen + SpecimenTracer 完整決策 timeline，含死隊最後決策）可挖出這 15 隊死前具體卡在哪個 task（備戰/迎戰/求和/建設/貿易…）+ PRIO 衝突細節，**尚未跑**（本輪 aggregate 證據已夠回答「fire 否」的核心問題，深挖「卡在哪」的邊際價值 vs 時間成本，留給你裁是否需要）。

## causation 對照（次要，附帶）

```
                    覓食       survival    備戰       迎戰       求和
pre (3a429632):   38.37%      27.88%     0.50%      0.32%      1.01%
post(623d3e77):   38.68%      15.31%     4.31%      1.05%      4.42%
```

**覓食聚合率幾乎沒變（38%→38%）**——原始假說「threat-oracle 排擠覓食時間」不夠精確：**不是全體覓食時間被排擠，是「特定瀕死隊」在關鍵時刻被鎖在 threat task 出不來**。備戰/迎戰/求和聚合率皆顯著上升（8.6x/3.3x/4.4x），方向與 PRIO 假說一致。survival 聚合率下降（27.88%→15.31%）不代表「該逃時逃不掉」——這是全體聚合數字，真正的問題藏在少數瀕死隊的 micro-timing，聚合率蓋不住。

## 判定

**核心診斷結案**：post-threat-oracle 的餓死滅團 100% 是「傻站死」型（絕境階梯沒 fire），pre 是 100%「有逃但沒逃成」型——**這是 bug，比 threat-oracle 造成餓死人數增加更嚴重的根因**，如你判準所定。PRIO 不對稱是有 code 依據的假說，逐隊確證需要再跑 specimen bed（我已建好待命）。

## 待你裁
1. 要我跑 specimen trace bed 坐實「卡在哪個 task」+「PRIO 衝突時序」嗎？
2. 這個 bug 修法初步猜測方向（僅供參考，非我裁）：survival/FLEE 的 PRIO 是否該鏡射 threat options 也拉到 70（或更高，絕境永遠贏）？還是要在 `_evaluate_threat` 的 release scaffolding 加一條「food_days 崩到 floor 下強制 release threat task」的安全閥？這是 implementer/systems 的設計裁量，我只報現象。

---
measured_at_head: pre=`3a429632`（`.worktrees/threat-oracle-s2-baseline`）、post=`623d3e77`（main，沿用長窗 watch 既有數據）
raw_logs: `docs/measurements/2026-07-18-famine-precheck-42-3a429632.json`、`docs/measurements/2026-07-18-attrition-longwindow-623d3e77.json`（兩者皆既有，本輪只 post-process 未重跑）
measure.json: `docs/process/verdicts/starvation-desperation-ladder-diag.measure.json`
新工具（main dir 未 commit，待命未跑）: `scripts/debug/starvation_desperation_trace_bed.gd`
