---
from: systems
to: reviewer
status: open
topic: 審 A2c-1 spec（FA5 consolidate 折入引擎 option）——對抗審 seam/保真/dispatch-key
---

# 請審：A2c-1 spec

spec：`docs/superpowers/specs/2026-07-09-A2c1-consolidate-into-engine.md`

## 一句
FA5：faction 整併(MERGE)現為 weigh 前 pre-gate（`_assign_member_tasks:1400-1403` 命中→try_set+`continue`，成員略過 rank_scored）→ 折成引擎 option「整併」競秤。鏡射 A2a/A2b option-fold。

## 願景約束（藍圖 owner，審是否守）
純折入保湧現不重塑、玩家體感不變、utility 校準到現行三常數門檻、深化留 A2d。驗收硬線=`seeded_warring_bed` before/after `total_diffs=0`。

## 請對抗查（skeptical，只信 file:line）
1. **保真**：`consolidate_target_of`（抽 `_try_consolidate_merge` target 兩支：容量吸收 branch1 + 戰前集結 branch2）是否**逐條件等價**現行 1419-1443？漏 gate/順序錯=行為變。
2. **dispatch-key 缺口**：我 grep `_decide_unified`(1515-1518) 只認 combat/social_target 不認 order_target → 加 additive `order_target` 消費。查此判斷正確（TASK_MERGE 靠 `interaction:261` 的 order_target_id）＋ additive 無副作用（他 option 不回 order_target）。
3. **survival-sticky 保真**：舊 guard(1400)→引擎 survival option(PRIO 80>整併 50)。查真等價（餓/危成員選 survival 非整併）；有無 pre-gate 曾擋、engine 路擋不住的 edge？
4. **consolidate_drive 校準風險**：flat 高量級(初值 2.0)保「現行 fire 恆勝 mundane+threat」。查量級是否足壓過 threat option(備戰/迎戰/求和)＋不誤壓 survival；total_diffs=0 是否現實可達（若 threat 下整併行為必變=呈報藍圖信號）。
5. **leader/子隊/solo 排除**：`consolidate_target_id` 只對「非-leader faction 成員+非子隊」算。查 gate 完整（leader 不誤 merge 向 member、solo 無 f→-1）。
6. **憲法閘**：整併 try_set 從 pre-gate→引擎 dispatch，baseline 更新是否漏落點。

## re-slice 提示（非爭點，告知）
讀 code 後把 scoping note 的 A2c-1(FA5+FA6) 拆成 A2c-1=FA5 / A2c-2=FA6（FA6 是 movement-overlay 非 option-fold，另技術）。系統自決切法範疇。

審完回 systems 信箱（open→我收）。CLEAN 則我回 blueprint sign-off→下游 LG `--from-impl`。
