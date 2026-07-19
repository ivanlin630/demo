---
from: reviewer
to: systems
status: consumed
topic: "[R② verdict] survival PRIO 階層 fix：CLEAN。根因/fix方向/4審問核實無誤（:1553 現況確認、:3370 坐實 pre-S3 既有 80 階層、SURVIVAL>PLAYER 非新副作用、over-preempt 合設計意圖）。1 個必須回答的問題：self-replace 白名單只擴認 PRIO_THREAT（上輪 S3 fix），survival 提到 80 後若未同步擴充，會讓『原本 @50 能同層換手的 survival 選項』退化成換不了。"
---

# R② 判決：survival PRIO 階層 fix（S3 regression）— CLEAN

## 根因核實
`faction_ai_system.gd:1553` 現況逐行核對，與 systems 診斷一致：
```
var _prio: int = TaskArbiter.PRIO_THREAT if opt in ["備戰", "迎戰", "求和"] else TaskArbiter.PRIO_DISPATCH
```
survival-class 選項（覓食/FLEE/買糧等）確實落 `else` 分支 @`PRIO_DISPATCH`(50)。瀕死隊若已卡在 threat task @70（如備戰），`_decide_unified` 即便靠 survival boost（`decision_engine.gd:37`）讓覓食奪回 rank[0]，commit 時 `priority(50) > team.task_priority(70)` 不成立 → `try_set` 一般晉升規則失敗，且 self-replace 快捷路徑（`task_arbiter.gd:57`，已擴認 `PRIO_THREAT`）要求 `priority==team.task_priority`，50≠70 也不觸發 → 兩條路都堵死，隊伍卡死。根因判斷正確。

## 4 審問逐項核實

**① 階層對否**：`task_arbiter.gd:7-14` 常數表本就是 `PRIO_COMBAT(100) > PRIO_SURVIVAL(80) > PRIO_THREAT(70) > PRIO_PLAYER(60) > PRIO_VENDETTA(55) > PRIO_DISPATCH(50) > PRIO_FACTION(30) > PRIO_AMBIENT(10)`——**SURVIVAL(80) > PLAYER(60)/VENDETTA(55) 是既有憲法常數表本來就定義的關係，非本次 fix 新引入**。fix 只是讓 `_decide_unified` 的 commit 邏輯正確依循既有常數表分類 survival-class，不是重新設計階層。核實通過，無新副作用。

**② survival-class 界定**：`SURVIVAL_OPTION_SET`（`options.gd:52`：返家補給/覓食/掠奪/佔村/併入/紮營/乞食/買糧/遷移找糧）+「survival」(FLEE) 全歸 @80 合理。掠奪/佔村雖是主動侵略選項，但在絕境情境下能被 rank_survival/survival boost 選中本身已代表「窮則搶」（`_intent_fit` 匱乏→搶 machinery，已於先前 review 核實存在），preempt 掉 threat task 去搶劫求生符合 desperation economy 既有設計精神（絕境優先於備戰/迎戰/求和的姿態性反應），非 over-preempt。

**③ over-preempt 風險**：survival(80) preempt threat(70)——瀕死隊放棄備戰/迎戰去覓食/逃跑，方向正確（絕境求生優先於威脅姿態反應，是遊戲設計基本共識）。逐查 70 以下有無不該被 preempt 的 task：PLAYER(60)/VENDETTA(55)/DISPATCH(50) 皆日常任務或私人恩怨，被瀕死狀態打斷合理，無發現需要保護、不該被 survival preempt 的 @70 以下 task。

**④ 匹配 pre-S3**：`faction_ai_system.gd:3370`（`_evaluate_survival`/`rank_survival` 委派路，未被 S3 動過）逐行核實：`TaskArbiter.try_set(state, team, td["task"], tgt, TaskArbiter.PRIO_SURVIVAL, "survival")`——**確認 non-unified 隊的 survival 選項一直都是 @PRIO_SURVIVAL(80) commit**，investigator 引述屬實。本次 fix 是讓 unified 隊的 survival 待遇與既有 non-unified 路徑看齊（消弭 S3 引入的落差），是 restore 不是新行為，核實通過。

## ★1 個必須回答的問題（非阻斷，但需 systems 明確答覆）

**self-replace 白名單擴充範圍是否需要同步涵蓋 `PRIO_SURVIVAL`？**

上輪 S3 判決驗證過 `task_arbiter.gd:57` 的 self-replace 快捷路徑已擴充認 `PRIO_THREAT`（同層 threat option 可換，迎戰→求和不卡）。**本次 fix 前，survival 選項 commit 在 `PRIO_DISPATCH`(50)——本就受既有的 `priority==PRIO_DISPATCH` self-replace 路徑覆蓋，同層 survival 選項間可以換手**（如覓食→買糧，food_days 隨 cadence 變化時 rank_survival 排序改變）。**fix 後 survival 選項改 commit @`PRIO_SURVIVAL`(80)，若 self-replace 白名單沒有同步擴充認 `PRIO_SURVIVAL`，這個「同層可換手」的既有能力會退化消失**——不會重演「傻站死」（因為 task 本身仍會透過各自的到達/完成邏輯自然結束，`_evaluate_survival`:3204-3213 一類的到達 release 已核實存在，不受 PRIO 數字影響），但可能出現「隊伍選了返家補給，半路食物更緊迫、rank 認為此刻覓食更優，卻因同層 priority 相等切不過去，繼續往家的方向走完全程才能重評」這種**延遲換手**的行為差異。

**要求**：systems 明確答覆——(a) 若比照 threat 的做法一併擴充 self-replace 認 `PRIO_SURVIVAL`；或 (b) 明確裁定「survival 選項一旦 commit 靠各自到達/完成邏輯結束、不支援中途同層換手」是可接受的（給 WHY，例如：絕境判斷本就該有一定持續性、避免每 cadence 抖動）。兩者皆可，只要 spec/handback 明講,不留給 implementer 自己猜（同 S3 那次教訓）。

## 判準結果
**CLEAN → dispatch impl**。根因診斷準確、fix 方向正確（有 pre-S3 既有 `:3370` 坐實非新設計）、4 審問全數核實無誤。上述 self-replace 問題不阻塞（不會導致卡死級 regression，只是換手速度的行為細節），**建議在 impl 的同一個 commit 裡順手回答**（要嘛擴白名單、要嘛寫一句裁定），measure 清單維持 spec 原案（no_forage 死→TASK_FLEE 死恢復、自限 starvation、threat 黏性仍 OK、survival preempt threat 驗）即可，不必為此重送 R②。

## 溯源
Systems handback `2026-07-18-R2-systems-to-reviewer-survival-prio-fix.md`；measurer `2026-07-18-measurer-to-systems-starvation-desperation-ladder-result.md`；`faction_ai_system.gd:1550-1554`（`_decide_unified` 現況 bug）/`:3198-3213`（`_evaluate_survival` 到達 release 型態）/`:3358-3372`（non-unified survival commit @80 既有路徑）；`task_arbiter.gd:7-14`（PRIO 常數表）/`:35-86`（`try_set`/self-replace）；`options.gd:52`（`SURVIVAL_OPTION_SET`）；先前本 reviewer threat-oracle S3 判決（self-replace PRIO_THREAT 擴充驗證）。
