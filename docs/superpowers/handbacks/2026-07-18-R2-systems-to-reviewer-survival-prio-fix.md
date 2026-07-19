---
from: systems
to: reviewer
status: consumed
topic: "[R²·S3 regression fix·survival PRIO 階層] BUG 確診(measurer):S3 後瀕死隊 100% no_forage 傻站死(pre-S3 是 TASK_FLEE 自限)。根:_decide_unified:1553 threat @PRIO_THREAT 70 但 survival 選項落 else @PRIO_DISPATCH 50→卡 threat task @70 的瀕死隊 survival @50 try_set 失敗無法 preempt。Fix:survival-class(SURVIVAL_OPTION_SET+FLEE)commit @PRIO_SURVIVAL 80(restore 80>70>50,匹配 pre-S3 非統一 survival @80)。審:階層對否/over-preempt 風險/survival-class 界定。B 前置 blocker。"
---

# R²：survival PRIO 階層 fix（S3 regression）

## BUG（measurer 確診，質變非量變）
S3 收斂後 seed42 15 隊餓死 **100% no_forage（傻站死，絕境階梯完全沒 fire）**；pre-S3(3a429632) 4 隊餓死 100% TASK_FLEE（自限 acceptable）。覓食聚合率沒降(38%→38%)=非全體排擠，是**瀕死隊關鍵時刻被鎖**。

## 根（逐 code 驗）
`faction_ai_system.gd:1553`（S3 加）：`_prio = PRIO_THREAT if opt in [備戰,迎戰,求和] else PRIO_DISPATCH`。→ **survival 選項落 else @PRIO_DISPATCH=50**。瀕死隊卡在 threat task @PRIO_THREAT=70：_decide_unified boost 讓 survival 奪 rank，但 try_set survival @50 vs 現 threat @70 → **50<70 try_set 失敗 → 傻站死**。
- pre-S3：非統一 survival @PRIO_SURVIVAL=80（investigator survival-churn scoping 早 flag「PRIO 塌」；我 deferred survival-churn，但 S3 把 threat 抬到 70 引爆——survival @50 現低於 threat）。
- 這正是 implementer S3 handback flag、measurer 當時只驗聚合率沒驗 preempt 能力的風險兌現。

## Fix
`:1553` → **survival-class 選項 commit @PRIO_SURVIVAL=80**：
```
_prio = PRIO_SURVIVAL if opt in SURVIVAL_OPTION_SET(+"survival"/FLEE)
      else PRIO_THREAT if opt in [備戰,迎戰,求和]
      else PRIO_DISPATCH
```
restore 階層 **SURVIVAL 80 > THREAT 70 > DISPATCH 50**（匹配 pre-S3 非統一 survival @80）→ 瀕死隊 survival preempt threat → FLEE/覓食 fire → 自限 starvation 恢復。

## 審（PRIO 階層）
- **階層對否**：SURVIVAL 80 > THREAT 70 > DISPATCH 50，但 < COMBAT 100（survival 不 preempt 進行中 combat=對）+ < ? 其他（PLAYER 60/VENDETTA 55 皆 < 80，survival 該壓過=對）。有無階層副作用？
- **survival-class 界定**：SURVIVAL_OPTION_SET(`options.gd:52`=返家補給/覓食/掠奪/佔村/併入/紮營/乞食/買糧/遷移找糧)+"survival"(FLEE)。全該 @80 嗎？（掠奪/佔村 是 survival-class 但也 aggressive——@80 會不會讓餓隊過度 preempt 去搶？還是餓時搶=對）。
- **over-preempt**：survival @80 preempt threat @70——瀕死隊放棄備戰去覓食=對（絕境優先）。有無不該被 preempt 的 @70-以下 task？
- **匹配 pre-S3**：pre-S3 非統一 survival 真 @PRIO_SURVIVAL 80 否（investigator 說 :3370 @PRIO_SURVIVAL）→ 這是 restore 非新行為。

## 判準
- CLEAN → dispatch impl（measure:no_forage死→TASK_FLEE死 恢復,自限 starvation,threat 黏性仍 OK,survival preempt threat 驗）。
- 階層有副作用 → halt file:line。

## 溯源
measurer 確診（`2026-07-18-measurer-to-systems-starvation-desperation-ladder-result.md`）;investigator survival-churn PRIO 塌 flag;implementer S3 preempt 風險 flag;`faction_ai_system.gd:1553`/`task_arbiter.gd`(PRIO_SURVIVAL 80/THREAT 70/DISPATCH 50);[[project_desperation_economy]];[[feedback_patch_gate_first]]。
