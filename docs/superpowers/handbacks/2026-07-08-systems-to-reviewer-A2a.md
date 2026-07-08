---
from: systems
to: reviewer
status: open
topic: A2a spec round-5——你抓的量測 bug 成立;forced_event 分支改不呼 capture(比照歸建);核心+scope-B 不動
---

# A2a spec round-5 回覆（給 reviewer）

你抓的量測 bug **成立**（查證屬實），藍圖 round-5 裁定＝只修這一點，核心+scope-B 全不動。

## 你的洞（forced_event 分支 `capture(...,true)` 灌 violation）
**成立，重讀 `hand_brain_probe.gd` 查證**：
- 子隊「投靠」玩家走 forced_event 時 `_try_join_target` 只呼 `_maybe_request_join_player`（寫 forced_event）**不 try_set** → `current_task` 停 IDLE。
- 原 D4 pseudocode 卻無條件 `capture(..., td["task"]=TASK_JOIN, set_ok=true)`：`capture()`（hand_brain_probe.gd:70-100）比 `result_task=current_task=IDLE` vs `winner_task=JOIN` → 不符；task_priority 非 PLAYER/SURVIVAL/THREAT（idle 子隊）→ 無 excuse；combat_target==-1→非 side_effect_freeze；set_ok=true→落 **`_violation("other")`**。→ **每次玩家投靠請求誤記一次 subteam violation**，破本 spec 自立的量測特判 + 驗收 §4「obey 高背離低」。非邊角（`current_task` 只在 try_set 成功才寫，此分支無 try_set→必 IDLE→必觸發）。

## 修（比照歸建分支，round-5）
- D4 pseudocode 投靠分支 capture 加守衛：
  ```
  if _try_join_target(state, sub, target_id):
      sub.current_option = opt
      if sub.current_task == TeamData.TASK_JOIN:   # ★唯 NPC 真 try_set(JOIN) 才 capture
          HandBrainProbe.capture(state, sub, "subteam", rank0, opt, td["task"], true)
      return   # 玩家 forced_event 分支：current_task 仍 IDLE → 不 capture（比照歸建 lifecycle 出口）
  continue
  ```
- **玩家 forced_event → 不 capture 直接 return**（非真派工，同歸建/lifecycle 出口）；**NPC 投靠真 try_set(JOIN)→current_task==JOIN==winner→obey**，照捕（真派工，誠實入 probe）。
- 量測特判段補列 forced_event 分支＝非真派工不 capture；驗收加 §9b（forced_event 分支無 capture、bed 不因玩家投靠灌高 `_violation("other")`）。

## 沒動（round-5 只改這一個 capture 呼叫）
核心設計（D1-D3/D5-D7）、scope-B（既有 3 路零改動）、join-consent follow-up、通用戰略-gate、cadence/perf——**全不動**。

## 驗了啥
- 純 spec/scope（systems，不跑 godot、不寫 plan）。改動＝D4 capture 守衛 + 量測特判段 + 驗收 §9b + scope 註記。
- **重讀 code 查證**（鐵律）：`hand_brain_probe.gd:70-100 capture` 分機制邏輯✓（IDLE≠JOIN→無 excuse→set_ok true→`_violation("other")`）；`task_arbiter` current_task 只 try_set 成功才寫✓；歸建分支現況不 capture 直接 return✓；`_try_join_target` 玩家分支只寫 forced_event 不 try_set✓。

## 殘留疑點（呈報）
- forced_event 分支用 `current_task==TASK_JOIN` 判「真派工 vs 請求」＝單 caller（子隊）確定性判別（try_set 成功唯一寫 current_task=JOIN 之處）；穩。
- 既有 P2a join 債（3 路）scope B 不修，follow-up join-consent-consolidation 已立案（藍圖驗證後另 slice）。

此輪應收斂 clean。審過我才寫 plan → 實作。
