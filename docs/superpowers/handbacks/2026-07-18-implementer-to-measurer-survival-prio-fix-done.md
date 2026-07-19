---
from: implementer
to: measurer
status: consumed
topic: "[survival PRIO fix 交付·S3 regression] restore 80>70>50。(1)_decide_unified survival-class(SURVIVAL_OPTION_SET+survival/FLEE)@PRIO_SURVIVAL 80(preempt threat @70);(2)task_arbiter self-replace 擴認 PRIO_SURVIVAL。branch feat/survival-prio-fix HEAD d286e21a off origin/main@623d3e77。char 綠(survival preempt threat+自我換手+瀕死 覓食@80)+gate 64 removed=0+threat_dissolution ALL PASS+headless 3-baseline。請 organic:no_forage死→FLEE死 恢復+survival preempt threat+threat 黏性仍 OK。"
---
# Hand Back：survival PRIO fix（S3 regression，B 前置）

**branch** `feat/survival-prio-fix`（已 push）**HEAD `d286e21a`**，off origin/main `623d3e77`（S3 merged，baseline 64）。

## 修（restore 80>70>50 階層）
S3 給 threat 反應 @PRIO_THREAT 70，但 survival-class 選項落 `_prio` else 分支 @PRIO_DISPATCH 50（我 S3 handback 已 flag）→ 瀕死隊 survival **無法 preempt threat**（self-limiting starvation 斷）。修：
- **(1) `_decide_unified` _prio**：`opt in SURVIVAL_OPTION_SET or opt == "survival"` → **@PRIO_SURVIVAL 80**；threat(備戰/迎戰/求和) @70；其餘 @50。
- **(2) `task_arbiter:59` self-replace 白名單**：`priority in [PRIO_DISPATCH, PRIO_THREAT, PRIO_SURVIVAL]`（S3 只擴 PRIO_THREAT；不同步擴則 survival 選項間同層換手退化）。

## 自驗（char 綠）
- **task_arbiter 階層**：survival @80 派下 → threat @70 **不能 stomp**（survival preempt threat）→ survival→survival @80 self-replace（換手不卡）。
- **_decide_unified**：瀕死隊(food=0,有 wild_game)→ **覓食(survival option) commit @80**（fix 前 @50）。
- **constitution_gate PASS 64 removed=0**（task_arbiter 條件擴充非 detector-hit；零新 fingerprint）。
- **threat_dissolution_check ALL PASS**（threat 反應/repertoire/live-seam 仍活，threat 黏性未破）。
- **full headless** `=== DONE ===` + 3 pre-existing baseline（無新增）。

## 下一站（★measurer organic）
- **no_forage 死 → TASK_FLEE 死 恢復**（自限 starvation：無糧源隊 survival preempt→FLEE/覓食→死，非卡 threat 反應不死）。
- **survival preempt threat**（瀕死+威脅隊 → survival @80 壓過 threat @70）。
- **survival option 可換**（survival 選項間 self-replace，覓食→買糧不卡）。
- **threat 黏性仍 OK**（threat @70 仍壓經濟 @50；survival @80 只在瀕死時壓 threat）。
- 綠 → to:systems 判 merge。此為 **B(絕境經濟) 前置**（survival 階層正確 → 敗北出路/膽量秤鏈乾淨）。

## 溯源
dispatch `2026-07-18-systems-to-implementer-survival-prio-fix.md`（R² CLEAN）；S3 handback flag（survival FLEE PRIO）；`_decide_unified` _prio / `task_arbiter:59`；PRIO_SURVIVAL 80/PRIO_THREAT 70/PRIO_DISPATCH 50；[[project_desperation_economy]]（敗北出路膽量秤）。
