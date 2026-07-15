---
from: systems
to: measurer
status: open
topic: "[量測·兩死法量級+真根] blueprint要先證再spec:死法①387半路掉逐merchant追真因(specimen trace看什麼取代TASK_TRADE)②meet_nodeal12/14控制co-loc床看哪條件bail;systems給code候選map,你量化坐實哪個"
---

# 量測：貿易兩死法量級 + 真根（先證再 spec，blueprint 令）

> **[worker 守則] 卡住/量不到 → handback `to:systems`,禁 `AskUserQuestion` 中斷用戶（用戶明言再犯上 hook 強制擋）。**

blueprint 要**兩死法量級+真根都坐實才 spec**（別修錯層第 6 次；systems churn 假設已被你 trace 推翻一次）。systems code 挖到候選 map，**你量化坐實哪個**。

## 死法①：387 半路掉（dispatch 404→arrive 17）真因逐 merchant 追
候選（TASK_TRADE PRIO_DISPATCH 50 可被搶/釋放的路）：
- **threat-preempt**：`_evaluate_threat` 派 FLEE/DEFEND @PRIO_THREAT 70 override（★flee 剛修好→merchant 真逃→中斷 trade，疑主因）。
- **survival-preempt**：缺糧 `_trigger_survival` @PRIO_SURVIVAL 80 override。
- **TRADE_TIMEOUT**：`faction_ai:775` 6日+12h/hex 逾時 release。
- **order 過期/消失**：目標訂單 expire（`ORDER_LIFETIME`）→ 下 cadence 撲空重評。
- **量法**：merchant specimen trace（tracer 已修，全生命+全路徑）——每次 TASK_TRADE 結束，**看下一個 decision entry 的 winner**（threat FLEE/DEFEND？survival？或 release→IDLE→別的？）+ task_start_tick 距離判 timeout。**逐 merchant 統計 387 掉裡各因佔比**（threat X%/survival Y%/timeout Z%/expire W%）。

## 死法②：meet_nodeal 12/14 到場為何不成交（控制 co-loc 床）
候選（`_attempt_trade_direction` bail 點）：
- **買方無 coin**（`buyer_coin<=0` 早退）。
- **無 surplus**（`surplus = stock - reserve <= 0`；註：`_absorb_public_storage` 已把糧倉貨吸進 resources，故 stock 含糧倉——surplus=0 表真沒餘或 reserve 太高）。
- **ask >= bid 價差不成**（ask=賣方 local_value×(1-commerce·0.1)、bid=買方 local_value；理論上 producer 有 surplus→abundant→ask 低、merchant 空手→bid 高→該成，**若實測 ask>=bid 表估值出乎意料**）。
- **carry 滿**（`carry_space_for_res<=0`）。
- **★對手不對**：merchant 到 order pos（`_market_pos`=producer 固定 outpost）但**co-located 的隊不是 order origin team**（producer 不在該 tile？或 co-loc 的是路過第三隊）？
- **量法**：手構控制 co-loc 床（merchant 買方[有 coin、空手] + producer 賣方[surplus>reserve] 同 tile）→ 呼 `_attempt_trade_direction` → **看哪條件 bail**（逐候選印）。或既有 organic 的 12 筆 meet_nodeal 各是哪隊配哪隊、哪條件掉。

## 判定 → 下游
**兩死法各因量級 breakdown 一封信 `to:systems`**（死法①各 preempt 因佔比、死法②各 bail 因佔比）→ systems 挖確認的主因真根 → spec（threat 韌性 or price or 對手不對…按真因）。**別讓 systems 再猜——數字定主因。**

## 溯源
raw + measured_at_head（分支 head or main）。log/jsonl UTF-8。specimen trace 用商隊 archetype 隊。
