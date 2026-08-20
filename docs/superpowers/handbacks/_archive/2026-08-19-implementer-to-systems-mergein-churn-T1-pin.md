---
from: implementer
to: systems
status: consumed
topic: "[T1 PIN done·mergein churn (b)arrival-never 根定案·branch feat/mergein-churn-fix @e1d0c00a·base main b223a862·★根=(iii)移動host+belief lag/失聯 → joiner 卡 ghost tile 或永遠追不上；★★關鍵補充(spec 三候選外):TASK_JOIN 全域零 release/timeout 出路(TRADE/STATION 都有、JOIN 沒有)=committed JOIN 不朽 → 每 cadence 重 commit=698 churn·(i)movement 執行正常排除、(ii)重委派單獨不致命排除·控制床六場景決定性·T2 提案待你確認(我照 no-斷點續做、你可 redirect)]"
branch: feat/mergein-churn-fix
commit: e1d0c00a
---

# T1 PIN：(b)arrival-never 的真 sub-cause

## 結論（一句）
**(iii) 移動 host + belief lag/失聯** 是 arrival-never 的觸發面，但**真正讓它變成 698 次 churn 的結構根是：committed `TASK_JOIN` 沒有任何 release / timeout / 撲空 abort 出路**——腦承諾了，手沒有完成契約，也沒有放棄契約。

## 證據 A：控制床（決定性，真 production 路徑）
`scripts/debug/mergein_arrival_control_bed.gd`：`FactionAISystem._try_join_target` → `MovementSystem.process` → `InteractionSystem.process_on_move` → `_resolve_join`（含 `rebuild_team_tile_index` 鏡射 sim_runner:188）。

| 場景 | host | belief | 結果 |
|---|---|---|---|
| A | 靜止 | 每 tick 新 | ★到達+resolve @tick430 |
| B | 同速逃離 | 每 tick 新 | ★到達+resolve @tick1360 |
| C | 同速逃離 + **每 cadence 重委派** | 每 tick 新 | ★到達+resolve @tick1360 |
| **D** | **移動** | **只在委派當下（之後失聯）** | **✗20 日零到達**（stale=408、at_target_host_absent=40、卡 ghost tile） |
| E | 移動 | 每 3 日刷新（lag） | ★到達+resolve @tick1820（追得比較慢） |
| F | 靜止 | 只在委派當下 | ★到達+resolve @tick430 |

→ **(i) movement 執行正常**（A/B/C/E/F 全部真行軍真到達）；**(ii) 每 cadence 重委派單獨不致命**（C 照樣 resolve、`try_set` 同 task 只更新 move_target、不重蓋 `task_start_tick`，task_arbiter.gd:91-93）；**(iii) 才是致命面**——host 會動 + belief 追不上（失聯→`belief_pos`=(-1,-1)→movement 保持凍結的舊 move_target；joiner 走到 ghost tile、`_step_team` 清 move_target、然後**永遠站在空格上**）。

## 證據 B：長局溫度計
`scripts/debug/mergein_churn_trace_bed.gd`（warring seed1337，sidecar 每 5 日落檔）day25：`in_transit=100%`、`colocated=0`、`host_mobile=68%`、`belief_lag=40%`、`belief_stale=16%`——JOIN 隊永遠在路上、從沒到 host。

## 證據 C：結構事實（窮盡搜索）
`grep -rn "TASK_JOIN" scripts/simulation/*.gd | grep -iE "release|timeout|clear"` → **零命中**。
對照：`TASK_TRADE` 有 `TRADE_TIMEOUT`+殘距額度→`TaskArbiter.release`（faction_ai_system.gd:829-835）；`STATION_TASKS` 有 `STATION_TIMEOUT`→release（:837-841）。**JOIN 兩者皆無**。
→ committed JOIN 不會過期、不會因撲空放棄 → 隊卡在 JOIN；下個 cadence survival 再 rank，`併入` 又贏（`to_task` 讀 `BeliefSystem.belief_pos`，belief 一恢復就再派）→ `[SurvivalMergeIn]` 同對隊反覆刷 = 698 行。

## 我的 T2 提案（待你確認；spec 的 (iii) 分支 + 一個 spec 沒列到的必需件）
1. **JOIN 到達生命週期（單一源、鏡射既有 timeout 塊，非新 dispatch 站）**：committed JOIN 超過 `JOIN_TIMEOUT + 殘距×PER_HEX` 未 resolve → `TaskArbiter.release` → 下 cadence 重 rank（可能改 target/改 option）。**這是 churn 止血的關鍵**：沒有它，任何「到不了」的情境都會無限重 commit。
2. **撲空 abort（感知鐵律 own-state）**：committed JOIN + 已站上 move_target（或 move_target 已清）+ `BeliefSystem.belief_pos(self, social_target)` = (-1,-1) → belief 死 → release（＝belief 系統既有「撲空逃脫」語意，不是 god-view 查 host 真位）。
3. **（可選、spec 的 (iii) 選項）proximity-resolve**：E 場景顯示 lag 追擊仍能 resolve，所以 **proximity 不是必需**；若你要降低移動 host 的追擊成本可另裁。我傾向先不加（最小根修、不動 resolve 語意）。

★三者都**不在 resolve 端疊繞過補丁**，是補上 JOIN 缺的完成/放棄契約（hand-obeys-brain 家族的標準修法，與 TRADE/STATION 同一單源塊）。

## 進度與請求
- T1 trace tap（TEMP、T2 移）+ 兩床已 commit/push：`e1e1940f`、`e1d0c00a`。constitution **PASS 77**（probe 分類分支標 `# gate-ok`，同 merge_appl:2523 慣例）。
- 我照無斷點自動鏈**繼續做 T2**（spec 允許「鏈清直接 T2」）。若你對第 1 點（timeout release，spec 三選項沒列）有不同裁定 → 回信我改。
