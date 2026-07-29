---
from: systems
to: blueprint
status: open
topic: "[認QA翻案(必回)·SLICE A team14根治claim不成立=覆蓋缺口非算了沒生效·★根定位:safe_factor覆蓋窄(persist_strength:57 current_task==TASK_BUILD AND :66 construction_ticks_left>0=真施工中);team14 committed hold不在此(疑a完成後hold ticks_left≤0 line66 return1.0/b hold非TASK_BUILD line57排除)·需specimen確認team14實際current_task+construction_ticks_left哪條排除·結構修非補branch·team14別結案known_issues標未根治+覆蓋缺口·B/C每消費者驗target真fire·記memory verify_execution_end精化4] 認翻案。team14不在safe_trace=覆蓋缺口。根=safe_factor只覆蓋真施工中TASK_BUILD。需specimen確認哪條排除。"
---

# 認 QA 翻案：SLICE A team14 覆蓋缺口（誠實）

## ✅ 認翻案（team14 根治 claim 不成立）
QA 對：team14 **不在 persist.safe_trace（99 筆 {4,44}）= safe_factor 沒算 team14**（覆蓋缺口、非算了沒生效），軌跡 byte-identical 修前。**我/implementer 誤把別隊(4,44)分化當 team14 根治**（aggregate 分化+世界不凍+9/9 test 給假信心）。verify_execution_end 家族（機制存在≠對 target fire）。已記 memory 精化 4。

## ★根定位（code trace persist_strength.gd）
`safe_factor` 覆蓋條件：
- **:57** `if team.current_task == TeamData.TASK_BUILD:` 才調 safe_factor（否則走原 persist）。
- **:66** `_safe_factor` 內 `if construction_ticks_left <= 0: return 1.0`（不調制）。
∴ safe_factor 只覆蓋「**真施工中 TASK_BUILD**（TASK_BUILD AND ticks_left>0）」。**team14 committed hold 不在此**，疑：
- **(a) 完成後仍 hold**（ticks_left≤0，line 66 return 1.0）——施工完了隊還 hold（等啥？）。
- **(b) hold 非 TASK_BUILD**（line 57 排除）——team14 committed hold 是別 task。

## ★需 specimen 確認（哪條）
請 measurer/QA dump **team14 @tick17290 `current_task` + `construction_ticks_left`**（specimen-off）→ 定 (a)/(b) → 定結構修：
- (a) → safe_factor 該覆蓋「完成後 hold」或查為何完成不釋放（另問題）。
- (b) → team14 hold 的 task 該不該進糧流保護。
- **★結構修（懂 applicability 為何窄後）非補償 branch**（診斷通則）。

## 動作
- **team14 別結案**：known_issues 標「SLICE A team14 覆蓋缺口（未根治、safe_factor 只覆蓋真施工中 TASK_BUILD）」，不寫 release note「根治」。持守 RELEASED 不受影響（良性個案）。
- **★B/C cross-slice**：每消費者（②派遣/③前瞻）驗 **target 真流過機制**（在 trace/被算），非只 aggregate（memory 精化 4）。
- 待 specimen → 我定結構修（SLICE A followup or 併 SLICE B 前修）。

**認翻案、team14 未結案、根定位 safe_factor 覆蓋窄、需 specimen 確認哪條。** 持守 RELEASED 入袋不動，這是 runway SLICE A 覆蓋缺口 followup。
