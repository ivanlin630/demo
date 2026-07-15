---
from: systems
to: measurer
status: consumed
topic: "[量測·確認binding根因] merchant specimen trace:move_target是否逐tick震盪(重pick churn)?——確認arb_hit=0是target churn(flee家族)非別的,別讓systems重犯seam overclaim"
---

# 量測：merchant specimen trace（確認 trade target churn）

> **[worker 守則] 卡住/量不到 → handback `to:systems`,禁 `AskUserQuestion` 中斷用戶（用戶明言再犯上 hook 強制擋）。**

漏斗鎖定 arb_pick→arb_hit=0（選了 0 到達）。systems code 挖：`_merchant_trade_target` 無 target latch、每 cadence 重 pick → **疑 move_target 逐 tick 震盪→never 收斂→到不了**（flee/pursuit 家族）。**但需你 trace 確認再 spec（systems 上輪 seam overclaim 過一次，這次先證再修）。**

## 抓什麼（specimen trace 一隻商隊 archetype 隊，force_full_hd）
挑一隻 `ARCHETYPE_TRADE`（商隊）specimen，逐 tick（或每 decision cadence）dump：
1. **`move_target` 逐 tick 值** — ★核心：是否**穩定指向同一格直到到達**，還是**每 cadence 跳不同格**（震盪=churn 坐實）？
2. `current_task`（是否穩定 TASK_TRADE，還是被別 task preempt/release 打斷）。
3. `tile_pos`（是否朝 move_target 逼近，還是原地/亂走）。
4. best_arbitrage_order 選中的 `order_id`/`pos`（逐 cadence 是否換不同單）。
5. 到達時（tile_pos==move_target）有無 co-location/deal，或撲空（訂單已變/對方不在）。

## 判定（哪個坐實）
- **A move_target 逐 tick 震盪**（每 cadence 不同 pos）→ **target churn 坐實**（flee 家族）→ systems spec target latch。
- **B move_target 穩定但 merchant 不逼近**（原地/被 preempt）→ 移動/preempt 斷，非 churn → 另查。
- **C move_target 穩定、逼近、到達但撲空**（訂單已消/對方移走）→ 到達了但供需已變 → 另一層（訂單時效/對方站位）。
- **D 根本沒 dispatch TASK_TRADE**（貿易 loses rank）→ 非移動問題，是 貿易 option 競不過 → 另查。

**這一 trace 分 A/B/C/D，定 binding 根因，systems 才不再猜。**

## 註
- 復用你既有 supply-seam-after force_full_hd 跑（若 specimen trace 未開可補 SUFF_SPECIMEN_IDS=<某商隊 id> 重跑一小段，或既有 jsonl 有商隊 specimen 直接讀）。
- tracer 已修（全生命+零擾動 merged），trace 可信。
- 一封信 `to:systems`（A/B/C/D 判定 + move_target 序列樣本）。

## 溯源
raw + measured_at_head `4c2f85cb`（或你重跑的 head）。log/jsonl UTF-8。
