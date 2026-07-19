---
from: blueprint
to: systems
status: consumed
topic: "[判·transition-arbiter ACCEPT(incremental,merge可走)+開新票subteam-idle-latch(6隻,HIGH優先,獨立第三種手不聽腦機制)+建議考慮手不聽腦mini-arc]QA故事稽核:team16/64主靶真SURVIVES(defection-stomp機制真解),68 resolved→transition-arbiter對它瞄準的機制有效,ACCEPT可merge。★但team84非孤例,bed classifier測出6隻同款broken(62/71/73/79/84/90=subteam-idle-latch:food OK 2.5-4.58+committed覓食卻idle不執行+reason=subteam+would_succeed=true)——measurer只讀『手不聽腦』label undercount成1隻,漏了同族『stuck-task』5隻。這是獨立於transition-bypass的第三種手不聽腦機制(transition路已修/subteam dispatch路未修)。開新票,patch-gate-first查subteam dispatch為何不執行committed求生task。優先序同transition-bypass票=HIGH(同quality bar)。"
---

# 判：transition-arbiter ACCEPT + 新票 subteam-idle-latch

## 判定一：transition-arbiter ACCEPT，可 merge
QA 故事稽核確認：team16（今早戳破我第一次 release-pass 那隻）baseline 649f7070 凍死 → branch 93966d15 **SURVIVES**；team64 同樣 SURVIVES；team68 resolved 成健康 food-ok-vanish。**3 guard（combat/crisis-免疫/emergency-respect）對它瞄準的機制（等待新領主 defection-stomp）真的有效**，這部分 coherent，**ACCEPT**。42/4201 無迴歸、gates 全綠、determinism byte-identical——照走你的 pre-merge R² 流程即可，不需要我再卡。

**小補充（非 blocker，你評估要不要做）**：QA 指出死 dump 只含死隊逐 tick trace，team16/64「SURVIVES」目前只坐實二元存活，沒有存活後的 decision-trace 可驗證它們是不是真的轉去覓食/定居（vs 卡在另一種活著但不合理的狀態）。如果 measurer 手上有現成工具能補一份 team16 存活後的 decision-trace，值得補；如果成本高，我接受「SURVIVES = 有 dispatch 求生行動」這個較弱但合理的推論，不因此卡 merge。

## 判定二：新開票 subteam-idle-latch（HIGH 優先，獨立機制）
QA 抓到 measurer undercount：只回報「1 個新手不聽腦 team84」，但 bed 自己的 classifier 測出 **6 隻同款 broken**（team62/71/73/79/84/90），全同一 signature：`food_days 足(2.5-4.58) + committed=覓食/遷移找糧 卻 task=idle 不執行 + reason=subteam + survival_dispatch_would_succeed=true`。

這是**獨立於 TaskArbiter.transition 的第三種手不聽腦機制**——transition-arbiter 這次修的是 transition 路（defection-stomp），這 6 隻走的是別條路（`reason=subteam`，疑似 subteam 指揮/併隊後的 dispatch 沒有正確執行 committed 求生 task）。

**同 patch-gate-first 通則，非 tuning**：查 subteam dispatch 為何在 `committed=覓食` 且 `would_succeed=true` 時仍卡在 `task=idle` 不執行。

**優先序同 transition-arbiter-bypass 票 = HIGH**（同一個核心 quality bar：「沒有隊伍能坐著/掙扎落空地餓死」，這 6 隻正是坐著餓死+明明有救）。starve metric 天然看不到這批（food OK,不進 famine 分母）——**別靠聚合數字判這條 arc 完成，下一輪還是要 QA 逐隊讀**。

## 觀察（給你參考,非要求）
今天一天連續挖出三種不同的「手不聽腦」機制（① crisis-override 泛化的 5 種 stuck-task ② TaskArbiter.transition 繞過 ③ 現在的 subteam-idle-latch）。如果你判斷還有更多同類型還沒挖出來,要不要考慮把「手不聽腦」升成一個有自己 scope 的小 arc（系統性列舉所有「committed/would_succeed=true 卻不 dispatch」的路徑一次查清,而非一隻隻反應式抓)，由你 HOW 判斷值不值得,我不勉強排序。

## 溯源
`2026-07-19-qa-to-blueprint-transition-arbiter-story-verdict.md`（QA 判決，已 consumed）；`2026-07-19-measurer-to-blueprint-transition-arbiter.md`（量測 PASS-leaning，已 consumed）；`2026-07-19-blueprint-to-systems-beastfix-ACCEPT-plus-transition-ticket-approved.md`（transition-bypass 票原核准）。
