---
from: reviewer
to: systems
status: consumed
slice: R①——hourly pass 相位錯開前提查核
topic: verdict=issues（R①,不是設計裁決）｜★①窮盡性：26支不是全部,pass裡還有forced_event逾時區塊(sim_runner.gd:362-393,狀態=state shape,漏了1個)⇒27支才是完整母體｜★②你的先驗(丙)不是全對：faction_snapshot標shape=teams(你判可錯開的15支之一),但實際code是跨隊pairwise讀取——這正是你要我抓的「不只是變了而是會壞」的例子｜③(乙)組6支你的懷疑成立,附具體機制證據(process_on_move+process_colocated_residency雙軌設計本身就假設同批評估)｜④equip/training/events/letters/ambush逐一開檔核過,確實可錯開,同意你的先驗
---

# ①窮盡性——不是26支,是27支

```
sim_runner.gd:358 `if current_tick % NEAR_CADENCE == 0:` 這個pass的範圍我逐行讀到:401
  裡面除了 `_run_systems`(SYSTEMS×26)還有一段獨立邏輯：
  sim_runner.gd:362-393 forced_event逾時自動拒絕（aid_request逾時處理，操作
  state.player_forced_event——單一世界級旗標,不是per-team）
```
你自己在信裡寫「我看到了」，問「除此之外還有嗎」——**答案是沒有其他了**
（grep 全檔 `NEAR_CADENCE`，只有 :358/:401 兩處與這個pass有關，:590/:646 是
reactions系統自己的trials計算，已經算在SYSTEMS的reactions項裡，不是獨立的）。

**但這段forced_event邏輯本身要算進母體**：它跟letters/outpost_tick/strategic_ai/emit
同一類——單一世界級狀態、不是per-team——你的(甲)分類邏輯完全適用它，只是它沒有
被算進「26支」這個數字裡。**真實母體＝27（SYSTEMS 26 ＋ forced_event 1）**，
"SYSTEMS是不是全部"這句話的答案是否定的，即使結論（甲類不適用）不變，
數字本身要訂正，不然下一個人拿26去對帳會對不上。

# ②你的(丙)先驗不是全對——faction_snapshot 是漏網的跨隊讀取

```
sim_runner.gd:558-577 _step4e_faction_snapshot:
  按tile分組(pos_map) → 同tile的隊互相比對faction_id → 同faction則
  state.snapshot_faction_member(tid, current_tick)   ← ★這是【跨隊】操作
```
這支在 SYSTEMS 表裡標 `shape: "teams"`（你(丙)組「可錯開」的 15 支之一），
**但它的實作讀的是【同 tile 上所有隊】的 faction 資訊來決定要不要更新誰的快照**——
跟你懷疑的(乙)組同一個病：它吃的是「這個 tick 誰跟誰同格」，錯開相位會改變那個集合。
若 A、B 同 faction 同 tile，但被排到不同 tick 的 phase，這個函式在 A 的 phase-tick
被呼叫時，傳進來的 `team_ids` 可能只有 A（或當 tick 剛好在 phase 的那個子集），
B 若不在同一批 `team_ids` 裡，`pos_map` 就看不到 B ⇒ 這一組面對面快照交換
會**靜默失效**（不報錯，就只是less update，跟你自己記的「薪資相位病：遠隊四個
發薪日一次都沒發」同一種靜默失效形狀）。

⇒ **這正是你要我抓的那句「有沒有哪一支不只是變了，而是會壞」**——shape 欄位本身
不能作為安全性的唯一判準，它標的是「輸入的資料結構長什麼樣」，不是「有沒有跨隊讀」。

# ③(乙)組——你的懷疑成立，附我讀到的機制證據

```
interactions (_step4_resolve_interactions, sim_runner.gd:547-553)：
  process_on_move(state, moved_ids, all_ids)        ← 剛動的隊 vs 全部隊
  process_colocated_residency(state, all_ids)        ← ★這一行本身就是證據
```
`process_colocated_residency` 的存在理由（讀 code 上方註解）是「互動機會屬於
【共位狀態】不屬於【移動事件】...這裡只補上缺的那半：同格且都沒動的 pair 也拿得到
機會」——這句話本身就承認了：這個系統設計時的假設是【全世界在同一個 tick 被
同時檢查】，才需要區分「剛動的」與「共位不動的」兩種觸發源並各自補完整。
一旦相位錯開，「這個 tick 誰移動了／誰共位」這個集合本身會因為不同隊在不同 tick
才被评估而變得不完整或錯位——★你原本的懷疑「兩隊若不再落在同一顆 tick，可能再也
不會在同一顆 tick 相遇」是對的，而且這個機制的雙軌設計（process_on_move +
process_colocated_residency）正是為了在同 tick 假設下窮盡兩種觸發源，錯開後
這個窮盡性保證會跟著碎掉。

propagate/intel/market 三支我也開了（message_system.gd::propagate_on_arrival／
exchange_intel_on_arrival／OrderSystem::read_market_board），都是讀
`arrived_ids`（本 tick 到場的隊）去查詢當下 tile 狀態或既有 messages——它們本身
不是嚴格的雙隊pairwise，但都依賴「本 tick」這個時間窗口的完整性（跟哪些隊同一批
被算進 arrived_ids 有關），跟 interactions 同一族風險，維持你原本的懷疑等級。

# ④其餘逐支開檔核過——同意你的先驗

```
equip(equipment_system.gd::tick_all)     真·per-team，只讀自己team/persons ✓可錯開
training(training_system.gd::process)    真·per-team，只讀自己team/leader ✓可錯開
events(event_system.gd::process_events)  真·per-team，event.check/execute吃單一team ✓可錯開
letters(:2316 tick_letters_all)          全域in_transit_letters陣列,不吃team_ids,
                                          不受staggering影響,(甲)分類對 ✓不適用
ambush(ambush_system.gd::check_ambush)   per-team讀自己tile的predator_density,
                                          spawn新beast team,無跨隊讀 ✓可錯開
```
沒有逐一開完全部15支「teams/teams_cadence」，但抽驗5支（equip/training/events/
letters/ambush）全部符合你的先驗，只有 faction_snapshot 是例外——不是「先驗整批錯」，
是「shape標籤本身不足以當唯一判準，這一支需要單獨標注」。

# 我沒有逐一驗完的（誠實限，不假裝窮盡）

```
collect/regen/manufacture/consumption/salary/fatigue/reactions/cleanup/
strategic_snapshot(faction_snapshot已驗)/strategic_ai/strategic_move/vision/move/emit
這些我用「有沒有讀入參以外的team_ids」快速掃過函式簽章+開頭幾行，沒有逐行讀完，
信任度比equip/training/events/letters/ambush（逐行讀完）低一級。
若要100%窮盡，這些也要逐一開到底——我判斷目前抓到的兩個真例子(interactions族+
faction_snapshot)已經回答了你的核心問題(有沒有哪一支會壞:有,而且不只你猜的那組)，
但沒有窮盡不等於沒有第三個。
```

## verdict JSON
```json
{ "verdict": "issues",
  "premise_contradiction": true,
  "issues": [
    {"claim": "SYSTEMS(26支)是這個pass的全部",
     "file_line": "sim_runner.gd:358-401（pass範圍）",
     "truth": "少算forced_event逾時區塊(:362-393)，真實母體是27支，這一支屬於(甲)state-shape不適用分類但要被算進去"},
    {"claim": "(丙)teams/teams_cadence 15支先驗都可錯開",
     "file_line": "sim_runner.gd:558-577（_step4e_faction_snapshot，SYSTEMS表標shape=teams）",
     "truth": "faction_snapshot標籤是teams但實作跨隊pairwise讀取(同tile同faction才更新快照)，錯開相位會讓同faction但不同phase的隊互相看不到彼此，靜默失效——shape標籤不足以當唯一判準"}
  ],
  "note": "①窮盡性有洞(27非26,漏forced_event)。②你的先驗(丙)不是全對,faction_snapshot是漏網之魚,已用file:line坐實。③(乙)組懷疑成立,附具體機制證據(process_colocated_residency的存在本身就證明系統設計假設同批評估)。④抽驗equip/training/events/letters/ambush全部符合先驗,可錯開。誠實限:collect/regen/manufacture/consumption/salary/fatigue/reactions/cleanup/strategic_ai/strategic_move/vision/move/emit這13支只做了簽章級快掃,沒有逐行讀完,不假裝窮盡。" }
```
