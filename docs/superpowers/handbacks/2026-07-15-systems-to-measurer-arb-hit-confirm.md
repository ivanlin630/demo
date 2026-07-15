---
from: systems
to: measurer
status: open
topic: "[量測·arb_hit=0精確根] merchant到stale _market_pos(賣方固定outpost)但賣方到達時不在該格?確認1 datum定精確fix:①29到達點有無對手隊(賣方在不在)②sell-order origin是settled(守outpost)還漫遊(離outpost forage/build)③merchant是commit trade到底還中途preempt漂走"
---

# 量測：arb_hit=0 精確根（merchant 到達但落空 — 賣方在不在?）

> **[worker 守則] 卡住/量不到 → handback `to:systems`,禁 `AskUserQuestion` 中斷用戶（用戶明言再犯上 hook 強制擋）。**

blueprint 接受②先（merchant 完成 trade dominant）。systems code 挖：merchant trade target＝`_merchant_trade_target`→sell order 的 `_market_pos`（**下單隊最近自家 outpost 固定 tile**）。arb_hit=0 + churn trace「到達但 co-location 落空」→ 疑**賣方到達時不在該 outpost 格**。**確認 1 datum 定精確 fix，別讓 systems 第 6 次 overclaim。**

## 確認什麼（復用 merchant specimen trace，或補一小段）
merchant specimen（商隊 archetype）到達 target 那些 tick：
1. **★到達點有無對手隊**：merchant `tile_pos==move_target` 那格，**有沒有站著別的隊**（尤其 sell order 的 origin_team）？——0 對手＝到了空格（賣方不在）；有對手但沒 deal＝co-loc 了但成交條件擋（回②另一半）。
2. **★sell-order origin 是 settled 還漫遊**：發 sell 單的隊，其 `tile_pos` 是否＝自家 outpost（守著）還是離 outpost 去 forage/build（漫遊）？——若漫遊→`_market_pos`(固定 outpost) ≠ 賣方實位→merchant 到 outpost 撲空。
3. **merchant commit vs preempt**：merchant 到達前有無被 normal-rotation（建設/覓食）打斷漂走（死法一 80.6%）？還是完成到達但落空（4.2%）？兩者佔比（定「承諾抗 preempt」vs「target 錯位」哪個主）。

## 判定 → 精確 fix
- **賣方漫遊離 outpost（_market_pos 錯位）** → fix＝merchant target 賣方**實位/belief_pos**（鏡射 `_refresh_attack_pursuit` 追 belief）+ 承諾抗 preempt。
- **賣方 settled 守 outpost 但 merchant 沒真到那格**（off-by-one/preempt）→ fix＝修到達/承諾。
- **merchant 多被 preempt 中途漂走** → fix＝trade 承諾 latch（churn 家族 merchant 版，鏡射 flee 有終點）。
- **到了有對手但成交擋** → 回②另一半（成交條件，但序上先通相遇）。

## 下游
一封信 `to:systems`（3 datum：到達點有無對手 / origin settled-or-漫遊 / preempt-vs-落空 佔比）→ systems 定精確 fix spec merchant 完成 trade。**這 1 confirm 定 fix 形狀，避第 6 次 overclaim。**

## 溯源
承 arb_hit=0（reconcile）+ churn trace（到達但落空）。復用既有 merchant specimen 若夠。measured_at_head 分支 or main。
