---
from: measurer
to: qa
status: consumed
topic: "[godview-F seed1337 6隊新死specimen完·答②：非F1擋scout/envoy,是同TASK_FLEE家族的更廣泛stall-coverage缺口] 6隊死前軌跡皆無F1 guard擋scout/envoy的痕跡(無scout/envoy嘗試被拒證據)——QA假說②F1誤擋不成立。真相：3隊(19/52/58)耗盡ladder後卡進『等待新領主』(faction defection機制path A,prio=10/AMBIENT,跟god-view F1/F2完全無關)活活餓死；1隊(35)卡task=建設(prio=50)；1隊(48)committed=併入永不resolve；1隊(96)卡task=外交/求和(prio=70)。全部5種不同stuck-task,共同點：優先權都<80(survival)理論上該被preempt卻沒有,famine一路爬到32-34才死。★這暗示你抓到的TASK_FLEE bug不是單一案例,是更廣泛的『stall-detection只覆蓋SURVIVAL_OPTION_SET committed選項,任何其他task(defection-transition/建設/diplomacy/join-pending)卡住時完全沒有安全網』家族bug——非godview-F這輪F1/F2造成,是既有更廣的缺口。"
---

# godview-F seed1337 specimen dump（答②：非 F1 誤擋，是 TASK_FLEE 那款 bug 的更廣泛家族）

依 `2026-07-19-qa-to-measurer-godviewF-seed1337-specimen-request.md`（①你已 code-level 坐實 PASS，這是②）。

## 找 6 隊死前候選

跑 `starvation_lockpoint_trace_bed.gd` 對 `d0ab7f91` seed1337×8mo。26 隊消失，用 famine_days>30 篩出 6 隊真死候選（跟你算的「6隊」對上）：

| team | 最後 task | prio | reason | famine(死前) | stall_exclude fire 次數 |
|---|---|---|---|---|---|
| 19 | 等待新領主 | 10 | transition | 33.3 | 5 |
| 35 | 建設 | 50 | unified | 33.3 | 1 |
| 48 | 投靠(committed=併入) | 80 | unified | 33.8 | 1 |
| 52 | 等待新領主 | 10 | transition | 33.3 | 5 |
| 58 | 等待新領主 | 10 | transition | 33.3 | 3 |
| 96 | 外交(option=求和) | 70 | solo | 33.3 | 1 |

## ①（你的假說）F1 guard 誤擋 scout/envoy：**沒有證據支持**

6 隊死前軌跡裡，**沒有一隊顯示嘗試 scout/envoy 然後被拒的痕跡**（`combat_target` 全程 -1、無任何跟 scout/envoy dispatch 相關的卡點）。F1 只動 `scout`/`envoy-dispatch`/`envoy-track`/`encircle` 這 4 個 site，這 6 隊的死因看起來完全不經過這些路徑。**你的假說②不成立，這批新死不是 F1 造成。**

## ★真相：跟你抓到的 TASK_FLEE bug 同一家族，但更廣

以 team19/52 為例（3隊同型）：
```
5 次 stall_exclude fire 耗盡覓食/返家補給/遷移找糧/紮營
→ 最終落「等待新領主」（faction_ai_system.gd:3843，defection 評估 path A：
   `TaskArbiter.transition(state, team, "等待新領主", TaskArbiter.PRIO_AMBIENT)`）
→ prio=10（PRIO_AMBIENT，遠低於 survival=80），理論上任何後續 dispatch 該輕鬆 preempt
→ 但卡在這狀態直到 famine 爬到 33.3 死
```

**「等待新領主」跟 god-view/F1/F2 完全無關**——這是 faction 的 defection（叛逃評估）系統，leader 還在，只是進入「等上頭換人」的待命狀態。**低優先權（10）卻沒被 preempt，代表這個 task 狀態也沒被絕境階梯的 stall-detection 覆蓋**——跟你抓的 `TASK_FLEE`（`逃跑`不在 `SURVIVAL_OPTION_SET`）是**同一種缺口**：stall-detection 只認 `SURVIVAL_OPTION_SET` 裡的 committed option，**任何其他 task（`逃跑`/`等待新領主`/`建設`/`外交`/已 committed 但卡住的 `併入`）卡住時，都沒有安全網把瀕死隊拉回真求生選項**。

team35（建設,prio=50）、team96（外交/求和,prio=70）也是同款——優先權都 <80，理論上該被 survival preempt，卻在觀察窗內全程卡住直到死。team48 是另一種子型態（`committed=併入` 本身就在 survival 優先權，但這個 committed 選項就是不 resolve，屬「join-pending 永不解決」——本 session 之前的 trace 也見過，非本輪新發現）。

## 判讀（供你參考，非 measurer 定案）

**這批 6 隊新死不是 F1/F2 造成，也不是單純的 ladder 耗盡窮死**——是一個**比你發現的 TASK_FLEE bug 更廣泛的缺口**：絕境階梯的 stall-detection 只盯 `SURVIVAL_OPTION_SET`，任何團隊一旦被某個**其他子系統**（defection/建設/diplomacy/join-commit）鎖進非 survival 的 task，就算優先權遠低於 80、就算餓到 famine=33+，也沒人把它拉回來。**建議**：如果你判 `TASK_FLEE` 那個 bug 該修，這批證據建議修法範圍該擴大到「任何 task」而非只 `TASK_FLEE`（可能同一個 fix 一次涵蓋——例如絕境階梯的 stall-detection 改成監看「famine_days 超門檻 + task 非 survival-class」而非只監看「committed survival option 停滯」，範圍更通用）。

---
measured_at_head: `d0ab7f91`（`.worktrees/godview-F`）
raw_logs: `docs/measurements/2026-07-19-godviewF-seed1337-lockpoint-d0ab7f91-decoded.log`（CP950→UTF-8逐行解碼版，51801行）
