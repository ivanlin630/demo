---
from: reviewer
to: systems
status: consumed
topic: "[R② 判決=LOD紅線修 ISSUES非CLEAN(★核心換算比例親算錯了一個數量級:reactions是shape=teams非teams_cadence,near每tick裸跑非每NEAR_CADENCE=10跑一次,真實ratio應=100非10——這條錯世界修不對,紅線只會少犯10倍非真正等效)+4問全答覆(`2026-08-20-reviewer-to-systems-R2-lod-redline-ISSUES.md`)]"
---

# R② 判決：LOD 紅線修（個體反應層不再綁玩家位置）

**判決 = ISSUES（非 CLEAN、非 halt——premise 方向全對，唯一數字算錯，但這個數字是本 slice「靈魂」，必須訂正才能 dispatch）**。你自己在 §5 gate①寫「這條綠才叫降解析度不降真實」——我親算下去，**這條現在的算法綠不了，因為換算比例本身少算了一個數量級**。

## citation 親驗（除比例本身，其餘全坐實）
- `sim_runner.gd:156-157` reactions/cleanup 的 `lod=LOD_NEAR`+`shape="teams"` 逐字對得上。
- `_get_near_teams:508` 距離判定、headless `(-1,-1)`→全隊 far，坐實。
- `_run_systems:171` skip 邏輯坐實。
- `outpost_tick`(shape=state)/`regen`(shape=regen) 不碰 teams 陣列——親讀 `_step4b_outpost_tick`/`_step5a_regenerate_tiles` 呼叫簽名確認不吃 team_ids，你的自糾正確。
- `GOAL_CHECK_INTERVAL=100=FAR_ZONE_INTERVAL` 巧合對齊——親算 `10*TICKS_PER_HOUR=100` 對 `10*TICKS_PER_HOUR=100`，對得上；且親讀 `evaluate_all:25` 確認 goal-check 用的是 **`current_tick % GOAL_CHECK_INTERVAL`絕對值比對**（非「呼叫次數」比對）——這條**不受下面那個 bug 影響**，你這條驗證仍然正確、不用改。
- `ReactionSystem` 全檔 grep `randf()` 確認**只有一處**（:204 breed chance）——flee/riot/defect/shirk/extort/produce/expand 全走 `_score_*` 決定性算分 + argmax（:102-114 附近），**零 RNG**。這對你 Q2 是好消息，見下。
- `cleanup_goals`(npc_ai_system.gd:181-196) 親讀確認純狀態改寫、零 RNG。

## ★必查項（唯一、但是命門）：`ratio` 算錯——reactions 是 shape=`teams` 不是 `teams_cadence`，near 端根本沒有「每 NEAR_CADENCE 跑一次」這件事
spec §3：「far pass 頻率是 near 的 1/10（`FAR_ZONE_INTERVAL=100` vs `NEAR_CADENCE=10`）」——**這個「near 端頻率=NEAR_CADENCE=10」的前提親驗是錯的**。

親讀 `sim_runner.gd:_run_systems`(:164-203) 的 shape dispatch：
```
"teams":         call(fn, state, teams)              # ← reactions 用這款,不吃 cadence
"teams_cadence": call(fn, state, teams, cadence)      # ← 只有這款真的拿到 cadence 參數
```
`reactions` entry 的 `shape="teams"`（:156）——`_step7_person_reactions(state, team_ids)`（sim_runner.gd:477-478）**簽名只兩個參數，沒有 `cadence`，函式內也沒有任何 `% NEAR_CADENCE` 判斷**。而 near-pass 本身（`_run_systems(state, near_teams, ...)`）在 `_advance_tick_body` 裡是**每 tick 無條件呼叫**（:274，這條我在別輪審 loop1 雙跑那題時已經親驗過一次同一件事——near pass 本來就沒有 outer throttle）。

**結論：near 端的 breed chance 是每 tick 抽一次，不是每 10 tick 抽一次**。`NEAR_CADENCE=10` 這個常數真正的作用對象是 `shape="teams_cadence"` 那批（collect/consumption/fatigue 資源類系統，這幾個 fn 才真的吃了 `cadence` 參數自己內部節流），跟 reactions **完全無關**——你把「這個常數的名字聽起來像是全域近區更新頻率」跟「reactions 實際遵守哪個頻率」兩件事併在一起了。

**後果**：真實 `ratio` 應該是 **far 頻率(每 100 tick 一次) ÷ near 頻率(每 1 tick 一次) = 100**，不是你算的 10。現在的 `p_eff = 1-(1-p)^10`（p=0.15 時 ≈ 0.803）**遠低於**應該要的 `1-(1-p)^100`（≈ 0.99999997，實務上幾乎必中）——照你現在的公式，遠隊生育期望率仍然只有近隊的一小部分（少了一個數量級的補償），**紅線只是被少犯十倍，不是被真正修平**。gate①（rate-equivalence）親算下去大概率會亮紅燈——與其等 dispatch→build→跑 gate 才發現，這輪先訂正。

**必查項**：`ratio` 改為 `FAR_ZONE_INTERVAL / 1`（即單純 `FAR_ZONE_INTERVAL=100`，因為 near 端 reactions 逐 tick 跑、沒有分母可言），或等價地重寫成「近隊這 100 tick 內會被呼叫 100 次、遠隊只呼叫 1 次」的 n=100 換算。

## ★連帶必查項：ratio=100 下，「單抽一次=至少發生一次」的低估會變得不可忽視——建議改成真·多次試驗
你自己在 topic 問題①已經預見了這個疑慮方向，但當時是在**假設 ratio=10** 的前提下問；**ratio 訂正成 100 後，這個疑慮從「值得討論」變成「大概率會實際發生」**：
- 親算 `p=0.15, n=100` 情境：單人在 100 tick 內「期望成功次數」≈ 15 次（真實 near-cadence 逐 tick 累積的結果），但你的 `p_eff` 公式無論 ratio 多大，**每人每次 far-pass 呼叫最多只貢獻 1 次 `P5_breed`**（`if randf()<p_eff: append`，一次性判斷非計數）——這不是「系統性低估」，是**結構性封頂**：near 端一個人 100 tick 內可能生好幾胎（受 `minor_population<cap` 這個團級上限制約，但團級上限跟「這個人自己貢獻幾次」是兩件事，团里有多个育龄人时尤其明显），far 端同一人同一窗口**物理上不可能超過一次**。
- 團級 `cap`（population×0.25）也許能部分吸收這個差異（近隊很快撞團級 cap、遠隊靠多個不同人各自成功湊到同一 cap）——但這是**運氣假設**非**保證**，population 小、育龄人數少的團，near/far 總生育數可能真的對不上。

**建議**：breed 這一項改成**真·多次試驗**（`for i in range(ratio): if randf() < p: 累加/嘗試一次，直到撞 cap 或 ratio 耗盡`），非單抽 `p_eff` 比大小。多抽 randf **不違反 determinism**（同 seed 同序列一樣可重現，「單抽省 RNG 消耗筆數」是你自己加的**額外**優化目標，不是正確性要求）——你 §3 講「只抽一次 randf（determinism 友善）」這句話把「單抽」跟「determinism」錯誤地綁在一起了，這兩者其實無關,多抽一樣 deterministic。若你有效能理由堅持單抽,那至少要求 gate①用**校正過 ratio=100 的**真實數字重新算過一輪再判斷夠不夠準,不能沿用 spec 現在這版的推導。

## systems 4 問答覆
1. **at least once vs 期望值型**：見上,ratio 訂正後這條從「可以接受的近似」變成「應該改」，除非你的 gate①拿正確 ratio 實測後發現團級 cap 真的把差距吸收掉——那也可以,但要**先拿對的 ratio 測過才知道**,現在的判斷基礎（ratio=10）本身是錯的,不能用它來評估要不要簡化。
2. **哪些換算要不要 spec 硬指定**：跟 EWMA 那輪不同——這次好消息是**分類任務極小**，全 `reaction_system.gd` 只有**一處** `randf()`（breed），其餘全是決定性 `_score_*`+argmax，**不是機率、不需要換算、也沒有誤判空間**。這條你不需要留給 implementer 判、也不需要我事後審表——**範圍只有 breed 一項**，spec 可以直接把公式寫死（含上面訂正的 ratio），零判斷空間可交。
3. **rate-equivalence gate 夠不夠格**：概念上是對的驗收方式（比累積次數非只比「有沒有 fire」），**但前提是拿對的 ratio 測**——用錯的 ratio=10 去測,大概率測出「far 隊明顯低於 near 隊」然後你們會誤以為要繼續加大 ratio 去湊,而不是發現分母本身算錯。訂正 ratio 後這條驗收法我認可。
4. **我漏了什麼**：這條漏洞本身就是我這輪補上的（ratio 分母錯用 shape 不對的常數）。額外一條**低成本提醒**：這是本 session 第二次抓到「假設某系統遵守 `NEAR_CADENCE`/某常數節流、但沒查該系統的 `shape` 是不是真的吃那個 cadence 參數」這類錯（loop1 雙跑那輪抓到 `FACTION_UPDATE_INTERVAL`/`INFRA_INTERVAL` 是 `FAR_ZONE_INTERVAL` 整數倍的巧合、這輪抓到 reactions 根本沒吃 cadence）——建議這類「頻率換算」型 spec 以後起手式先查 `SYSTEMS` registry 裡該 entry 的 `shape` 欄位，非直接假設某常數適用。可以記一筆到 `01_architect`/`invariants.md`（你 owner）當通用檢查項，非阻塞這輪但省下未來重複踩雷。

## 結論
**ISSUES → 訂正 ratio（100 非 10）+ 據此重新評估 breed 是否要改真·多次試驗（若你 gate①拿對的 ratio 測出來團級 cap 確實吸收差距，維持單抽也可以，但要用對的數字測過）→ 重送 R②，不需要重跑 R①**。其餘（citation/範圍自糾/GOAL_CHECK_INTERVAL 對齊/only-one-randf 分類）全部坐實,不用動。這不是推翻方向,是同一個修法用對的分母算一次。

地基 KEEP。
