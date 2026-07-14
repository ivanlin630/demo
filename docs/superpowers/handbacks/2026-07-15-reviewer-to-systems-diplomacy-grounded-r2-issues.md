---
from: reviewer
to: systems
status: consumed
topic: "[R②判決·issues] 求和/外交grounded——seam/cooldown對應/不誤傷皆CLEAN,但handler缺口我已實測確認必發生(非假設),spec未定義該分支的執行期行為(釋放+cooldown),否則新thrash源"
---

# R② 判決：求和/外交 grounded

verdict: **issues**
premise_contradiction: false

## 逐點驗（file:line 全查證）

1. **seam 坐實 CLEAN**：`interaction_system.gd:409-410 _try_diplomacy` 確認硬寫 `"propose_alliance"`，無視呼叫端脈絡；`options.gd:264-268`「求和」`to_task` 確認回傳 `task=TASK_DIPLOMACY, order_target=threat_id, order_task=TaskData.TASK_TRIBUTE_OFFER`——seam bug 診斷屬實。
2. **cooldown 讀對 target CLEAN**：「外交」`to_task`(`options.gd:240`)與 `decision_context.gd:268` gather 填 `faction_diplo_target` 用**同一函式**（`_fa._nearest_independent(state,team)`）、同輸入 → 確定性下必同結果，無 Fix A-2 那種雙來源 host 錯配風險。「求和」的 `threat_id` 同理單一來源（ctx gather 一次填）。cooldown 讀寫的 target 與 dispatch 目標一致。
3. **感知鐵律 CLEAN**：`team.diplomacy_reject_cooldown` 是發起隊自己的欄位（`:413-414 initiator.diplomacy_reject_cooldown[target_id]=...`），讀自己過去的真實拒絕記錄，非猜對方意向，trivial non-god-view。
4. **不誤傷結盟 CLEAN**：「外交」to_task（`:238-242`）不帶 `order_task` 欄；「求和」to_task 帶 `order_task=TASK_TRIBUTE_OFFER`——兩者用 `order_task` 是否存在/值可清楚分流路由，不會互相誤判。

## issue：handler 缺口非假設，我已實測確認必發生——spec 未定義該分支的執行期行為

`diplomatic_ai_system.gd:196-229 handle_diplomacy_message` 的 `match action` 逐一核對：`propose_alliance`/`propose_trade`/`demand_tribute`/`offer_surrender`/`invite_settle`——**確認無「求和/息兵/tribute_offer」對應 case**。spec `:26-28` 把這寫成「implementer 先驗，缺→停下報 systems」的**開發期檢查指令**，但沒有定義**執行期** `_try_diplomacy` 偵測 `order_task==TASK_TRIBUTE_OFFER` 且無對應 handler 時該做什麼——這不是「可能發生」要 implementer 去驗，是我已查證**必然發生**（handler 現在就不存在）。

**具體風險**：若 implementer 對這個分支沒有明確規範可依循，兩種常見誤踩：
(a) 圖省事直接 fallback 呼叫 `propose_alliance`（= 舊 bug 原封不動延續，Fix2 等於沒修）；
(b) 直接 `return` 不釋放 task、不設 cooldown（= 求和 task 卡住不放；即便釋放但沒設 `diplomacy_reject_cooldown`，Fix1 的 look-before-leap 抓不到「這個 target 剛試過」→ 下 cadence 又選求和 → 又進同一死路 → **新的 thrash 源**，恰是這整條 arc 一路在治的病）。

**要求**：spec 明定這個分支的執行期行為——**`_try_diplomacy` 偵測 order_task=TRIBUTE_OFFER 且無 handler 時：`TaskArbiter.release(initiator)` + 比照拒絕路徑設 `initiator.diplomacy_reject_cooldown[target_id] = current_tick + REJECT_COOLDOWN`（視同「此路暫不可行」，非真拒絕但同等 cooldown 效果）、不呼叫 `handle_diplomacy_message`（不誤觸發 propose_alliance）**。這樣 Fix1 的 look-before-leap 才能正確擋住重纏，且不會靜默恢復成求盟。

## 框外審評估
同意——既有 finder/resolver 改（look-before-leap 家族續集），非新框，標準審足夠。

## 結論
seam/cooldown 對應/感知鐵律/不誤傷四點 CLEAN。**issues＝handler 缺口的執行期分支未定義**（我已實測確認會發生，非邊角案例）。**要求 spec 補一段明確的 release+cooldown 執行期規範**，非重新設計，一行 spec 段落即可收斂。
