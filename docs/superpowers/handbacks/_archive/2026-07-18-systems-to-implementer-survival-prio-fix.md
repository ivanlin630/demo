---
from: systems
to: implementer
status: consumed
topic: "[dispatch·survival PRIO fix·S3 regression·B 前置] R² CLEAN。兩部分:(1)_decide_unified:1553 survival-class 選項 commit @PRIO_SURVIVAL 80(現落 else @50)→瀕死隊 survival preempt threat @70;(2)★task_arbiter self-replace 白名單同步擴認 PRIO_SURVIVAL(S3 只擴 PRIO_THREAT,不擴則 survival 選項間同層換手退化)。restore 80>70>50 階層。measure:no_forage死→TASK_FLEE死 恢復(自限 starvation)+survival preempt threat+survival option 可換+threat 黏性仍 OK。worktree feat/survival-prio-fix off origin/main@623d3e77。"
---

# survival PRIO fix：S3 regression（B 前置 blocker）

## BUG（measurer 確診）
S3 後瀕死隊 100% **no_forage 傻站死**（絕境階梯沒 fire）vs pre-S3 100% TASK_FLEE（自限）。根:`faction_ai:1553`(S3 加)threat @PRIO_THREAT 70 但 survival 選項落 else @PRIO_DISPATCH 50→卡 threat task 的瀕死隊 survival @50 try_set 失敗無法 preempt→餓死。

## Fix（兩部分，缺一不可）
1. **`faction_ai_system.gd:1553` survival-class @PRIO_SURVIVAL 80**：
   ```
   var _prio: int = TaskArbiter.PRIO_SURVIVAL if opt in DecisionOptions.SURVIVAL_OPTION_SET or opt == "survival" \
       else (TaskArbiter.PRIO_THREAT if opt in ["備戰","迎戰","求和"] else TaskArbiter.PRIO_DISPATCH)
   ```
   （SURVIVAL_OPTION_SET=`options.gd:52` 返家補給/覓食/掠奪/佔村/併入/紮營/乞食/買糧/遷移找糧 + "survival"=FLEE）。restore SURVIVAL 80 > THREAT 70 > DISPATCH 50 → 瀕死隊 survival preempt threat。
2. **★`task_arbiter.gd` self-replace 白名單擴認 PRIO_SURVIVAL**（R² 必答）：S3 上輪只擴 PRIO_THREAT（`:57` 附近）。survival 提 80 後**不同步擴 = survival 選項間同層換手退化**（原 @50 能換[覓食→買糧]→@80 換不了）。→ self-replace 條件擴 `priority in [PRIO_DISPATCH, PRIO_THREAT, PRIO_SURVIVAL] and task_priority == priority`（engine-sourced）。

## measure（B 前置 blocker，驗根治）
1. **no_forage死 → TASK_FLEE死 恢復**（seed42 8mo,`_on_team_extinct` 死因:餓死隊回到 100% survival-action 死[FLEE/覓食]非 no_forage）=絕境自限 restored。
2. **survival preempt threat**：瀕死隊在 threat task 時能切 survival（specimen or 率）。
3. **survival option 可換**（覓食→買糧 同層 self-replace 不卡）。
4. **threat 黏性仍 OK**（threat @70 vs dispatch @50 不變，S3 finding3 保）。
5. **世界能否 sustain**：seed42 pop 軌跡改善（傻站死消，attrition 回自限型）。

## 完成 → 下一站
done+綠 → to:measurer（中性複核:死因型態 no_forage→FLEE + 階層 + 世界 sustain）→ to:systems 判 merge → blueprint 覆（絕境自限 restored=B 前置解）。

## 溯源
R² CLEAN（`2026-07-18-reviewer-to-systems-survival-prio-fix-r2-clean.md`）;measurer 確診;`faction_ai:1553`/`task_arbiter.gd`;[[project_desperation_economy]] B 前置;[[feedback_patch_gate_first]]。
