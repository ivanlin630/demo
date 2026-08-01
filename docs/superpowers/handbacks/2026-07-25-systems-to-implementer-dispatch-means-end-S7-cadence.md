---
from: systems
to: implementer
status: consumed
topic: "[dispatch·means-end S7 最後 slice 收尾·goal 生成 cadence-gate(perf optimize known_issues A)+goal 掛退 lifecycle(泛化 util-門檻掛/退,免 goal_state 累積)+收尾·★S7 merge=means-end whole-done·★base=LOCAL main HEAD b2a34b4c(含 S6)非 origin·新 branch feat/means-end-s7-cadence off local HEAD] S1-S6 已 merged(means-end 四缺口+委派+折現核心機制收官)。S7=最後 slice 收尾:①perf+②goal lifecycle 掛退+接通。修:①★perf optimize(known_issues A):goal 生成/維護(GoalResolver.ensure_maintain_goals)現每 rank_scored(每隊每 decide)呼掃 5 maintain+8 build_F×_facility_deficit=慢→**cadence-gate**(team.goal_eval_next_tick 鏡射既有 residency_eval_next_tick:每 GOAL_EVAL_CADENCE tick 呼一次非每 decide;goal_state 持久跨 tick 不需每 decide 重算掛)②★goal 掛退 lifecycle 泛化(組件 A 從 S2/S4 最小→完整):掛=desire>threshold(既有)+★退=goal 長期 satisfied(build_F 建成)or desire 掉 below threshold→移除/status abandoned(免 goal_state 無限累積 build_F satisfied goal=memory+perf leak);maintain goal 冪等留(持久維持)③收尾接通(確認 S1-S6 pipeline 完整+determinism)④must-fix① 護欄不動(沿用)。★determinism 注意:cadence-gate goal_eval_next_tick 初始化+cadence 純 tick-based(非 randf);S7 行為變(goal 生成頻率+掛退)→S7!=S6 預期,但 S7 自己 2 跑 byte-identical 必守。TDD:①cadence-gate(goal 生成非每 decide,GOAL_EVAL_CADENCE tick 一次,perf 探針或 call count 驗)②goal 退(desire 掉/satisfied 長期→goal_state 移除,不無限累積;測 build_F 建成後退)③maintain goal 冪等持久(不誤退)④must-fix① range 斷言 regression(護欄仍守)⑤determinism 2 跑 byte-identical(cadence/掛退純狀態+tick,禁 randf)⑥headless 0-new(★perf:cadence-gate 後應不慢於 S6 or 更快)。閘:constitution_gate 74 removed=0+headless 0-new+determinism。★whole-system-first:S7 收尾(perf+lifecycle),不新增機制;known_issues followup(S3 unowned/S4 facility-type/S5 residency 手評)=whole measure 的 watch 非 S7。★★完成=systems+reviewer R²→to:systems 收驗+S7 R²→CLEAN merge=**means-end whole-done**→我喚藍圖+QA measure 整個系統(用戶原則②)。task=systems+reviewer。"
branch: feat/means-end-s7-cadence
---

# dispatch：means-end S7 最後 slice 收尾（cadence-gate + goal 掛退 lifecycle）

S1-S6 已 merged（means-end 四缺口 + 委派 + 折現核心機制收官）。**S7 = 最後 slice 收尾**：perf + goal lifecycle 掛退 + 接通。★**S7 merge = means-end whole-done**。

## ★★base 鐵律
- off **LOCAL main HEAD `b2a34b4c`**（含 S6）非 origin。

## 修（收尾，不新增機制）
1. **★perf optimize**（known_issues (A)）：`GoalResolver.ensure_maintain_goals` 現每 `rank_scored`（每隊每 decide）呼掃 5 maintain + 8 build_F × `_facility_deficit` ＝ 慢 → **cadence-gate**（`team.goal_eval_next_tick` 鏡射既有 `residency_eval_next_tick`：每 `GOAL_EVAL_CADENCE` tick 呼一次非每 decide；goal_state 持久跨 tick，不需每 decide 重算掛）。
2. **★goal 掛退 lifecycle 泛化**（組件 A 從 S2/S4 最小 → 完整）：掛 = desire>threshold（既有）+ ★**退** = goal 長期 satisfied（build_F 建成）or desire 掉 below threshold → 移除/status abandoned（**免 goal_state 無限累積** build_F satisfied goal ＝ memory+perf leak）；maintain goal 冪等留（持久維持）。
3. **收尾接通**（確認 S1-S6 pipeline 完整 + determinism）。
4. **must-fix① 護欄不動**（沿用）。

## ★determinism 注意
cadence-gate `goal_eval_next_tick` 初始化 + cadence 純 tick-based（非 randf）；**S7 行為變**（goal 生成頻率 + 掛退）→ **S7≠S6 預期**，但 **S7 自己 2 跑 byte-identical 必守**。

## TDD
1. cadence-gate（goal 生成非每 decide，`GOAL_EVAL_CADENCE` tick 一次，perf 探針/call count 驗）。
2. goal 退（desire 掉/satisfied 長期 → goal_state 移除，不無限累積；測 build_F 建成後退）。
3. maintain goal 冪等持久（不誤退）。
4. must-fix① range 斷言 regression（護欄仍守）。
5. determinism 2 跑 byte-identical（cadence/掛退純狀態+tick，禁 randf）。
6. headless 0-new（★perf：cadence-gate 後應不慢於 S6 or 更快）。

## 閘 + 完成
- `constitution_gate` 74 removed=0 + headless 0-new + determinism。
- ★**whole-system-first**：S7 收尾（perf+lifecycle），不新增機制；known_issues followup（S3 unowned/S4 facility-type/S5 residency 手評）＝ whole measure 的 watch 非 S7。
- ★★完成 = **systems + reviewer R²** → `to:systems` 收驗 + S7 R² → CLEAN merge ＝ **means-end whole-done** → 我喚藍圖 + QA measure 整個系統（用戶原則②）。
