---
from: measurer
to: systems
status: consumed
topic: "[量測完·churn trace判定=非A非B、落C變體] T5商隊specimen逐tick trace：target 28000+ticks僅切6次(排除churn)+[Move]抵達print實測命中29次(排除不逼近)——到點但[Market]全程零次提Team5=co-location落空(疑target算的是下單當下對方位置非即時);另交叉native trade_funnel_bed揭露dispatch404→arrive僅17(4.2%)大量被逃跑/threat preempt腰斬,到場17裡meet_nodeal=12/14"
---

# merchant target churn trace：判定結果

依你 `2026-07-15-systems-to-measurer-merchant-target-churn-trace.md` 判準表逐項驗。

## 一次量完（鐵律6）

## 抓誰：T5（TAG_MERCHANT，seed1337，force_full_hd，branch `feat/supply-seam-effective-holding` @ 4c2f85cb）
seed1337 世界裡 T5 是貿易task最活躍隊（specimen 全隊掃描，貿易task決策數：T5=224 > T0=215 > T1=136 > 其他個位數~兩位數），選T5為代表商隊。

## 1. move_target 逐tick序列 → ★A(churn) 排除
specimen 224 次「貿易」task決策（tick 4250~32120，橫跨~28000 tick≈近全程6月）逐筆比對，target **僅切換6次**：
| 切換tick | 新target | 持有時長 |
|---|---|---|
| 4250 | (4,9) | 1200 tick |
| 5450 | (6,9) | 5260 tick |
| 10710 | (12,8) | 120 tick |
| 10830 | (6,9) | 9860 tick |
| 20690 | (0,16) | 10830 tick |
| 31520 | (1,10) | (跑到月末) |

**每次切換後穩定持有動輒千tick以上（60-tick cadence下=數十次決策皆重選同一target）**，非逐cadence跳位。**A(churn/震盪) 明確排除。**

## 2. tile_pos 逼近實況 → ★B(不逼近) 排除
specimen schema無tile_pos欄位，改用同分支重跑（`trade_funnel_bed.gd`原生工具，非我`sufficiency_bed`擴充，交叉獨立驗證）抓raw `[Move]` print：
- `[Move] Team 5 抵達 (4,9)` 命中 **29次**（涵蓋前兩個target切換窗），確認 T5 **真的走到了**自己選中的目標格，非原地/被preempt卡住不動。
**B(不逼近/卡住) 明確排除。**

## 3. 到點後有無 co-location/deal → ★落 C 變體（非標準「到了不成交」，是「到了沒人」）
關鍵反常：29次抵達，但全程6月 **`[Market] Team%d <-> Team%d` print 從未一次提到 Team5**（grep 整檔 0 命中）。`_resolve_market`（interaction_system.gd:716）只在兩隊同格同tick被觸發時才叫，T5 到點29次卻連一次`trade.meet`（走到`_resolve_market`分支的前提）都沒對應打到 —— **意味 T5 到達的座標，在牠抵達那刻，對方根本不在那**。

判讀：不是「會合了但撲空」（那是C的字面定義），而是**「到點但對象已不在」**——與本session稍早 god-view/`_refresh_attack_pursuit` 那條「belief_pos 過期，位置以下單當下快照非即時位置」的病灶同構，但這裡病灶疑在**貿易 target 算的位置**（可能是對方下單時的 tile_pos 快照，非到達時的即時 tile_pos）。T5 走去的座標(4,9)/(6,9)可能是「賣單/買單posted當下對方所在」，但對方隊是移動中的隊伍（不是固定outpost），走到時人已不在——尤其(6,9)持有近萬tick仍未成交，若對方是移動隊，早該離開該格。

## 交叉驗證：native trade_funnel_bed 全域漏斗（獨立於我先前sufficiency_bed擴充算的數字，同seed/months/branch重跑核對）
```
[funnel] 站3 選中     = arb_pick=4209 / arb_call=14602 (28.8%)；濾鏈: sell_seen=8561 buy_seen=48457 range殺=0 無貨殺=38397
[funnel] 站4 dispatch = 404（ambient=136 solo=251 unified_買糧=12 unified_貿易=5）
[funnel] 站4 被誰打斷 : 逃跑|unified=52 逃跑|threat=30 逃跑|solo=4 建設|solo=2 覓食|solo=2 紮營|unified=1 紮營|survival=1 return_home|solo=1
[funnel] 站5 到場     = arrive=17 (4.2% of dispatch)；夭折: timeout=8 途中被截release=0
[funnel] 站6 成交     = deal=7 (coin=2 barter=5)；會合=14 途中會合=1 撲空nodeal=12
[funnel] 站6 成交主體 : 商隊跑單=0 vs resident互售=2
[funnel] 履約: order_fulfilled=1 arb_hit=0
[rate] 商隊 funnel: 選中/呼叫=28.8% dispatch/選中=9.6% 到場/dispatch=4.2% 成交/到場=0.0%（deal_merchant=0）
[PASS] 矛盾率(回歸gate) = 94/148 = 0.635（回歸閾≤0.85）；絕對健康讀數: 0.635 中
```
`arb_pick=4209/arb_hit=0/deal_merchant=0` 與我上輪（復用supply-seam-after數據）報告方向一致（微小絕對值差異=不同次跑，皆force_full_hd seed1337 6月，量級同構），binding層鎖定不變。

**★新發現（本輪trace才浮現，上輪漏斗breakdown看不到）**：站4→5（dispatch→arrive）流失才是量級最大的一關——**404次dispatch只有17次arrive（95.8%流失）**，`站4被誰打斷`列出主因=逃跑/threat類preempt（52+30+4=86次，佔dispatch的21%，仍未補滿95.8%缺口，代表還有其他未被個別探針計入的中途流失路徑，如中途遇隊觸發`trade.continue_midroute`後未真正走到、或多次redispatch互相取代）。且即使到場的17裡，meet=14、meet_nodeal=12——到場後仍幾乎全滅。**兩層病灶並存：(a) dispatch存活率極低(preempt為主) (b) 少數存活到場的仍撲空(co-location對象缺席)。**

## 判定總結
| 假設 | 判定 | 證據 |
|---|---|---|
| A 逐cadence震盪 | **排除** | target 28000tick僅切6次，每次穩持千tick+ |
| B 穩定但不逼近 | **排除** | [Move]抵達print實測命中29次於選中座標 |
| C 到達但撲空 | **部分成立，但機制更精確**：非「會合了沒成交」，是「到點但_resolve_market從未觸發過（對方不在場）」——疑target位置新鮮度問題（同belief_pos-staleness家族，trade版） |
| D 未dispatch TASK_TRADE | **排除** | T5明確224次committed進TASK_TRADE，且全域dispatch=404非0 |

## 待你裁（非我能猜，需查code）
1. `best_arbitrage_order`/target 算法：選中的座標是「訂單張貼當下對方tile_pos快照」還是「即時位置」？若前者且對方是移動隊 → 天然過期，需比照`_refresh_attack_pursuit`模式改即時查/或鎖定outpost靜態市集點而非移動隊位置。
2. 站4→5的95.8%流失，preempt只解釋約21%，缺口另一大頭是什麼路徑吃掉的（continue_midroute後續程未達成？redispatch互相取代？）——建議下一輪視需要我再補per-team preempt/release歸因trace。

---
measured_at_head: 4c2f85cb
raw: docs/measurements/2026-07-15-tradefunnelbed-native-4c2f85cb.log（native工具跑，UTF-16 tee，用Grep工具讀不用Bash grep——本輪踩雷：PowerShell Tee-Object輸出UTF-16LE,Bash grep對這類檔案逐字節比對全部落空,誤判「[Move]全域零命中」,已用Grep工具+改查native bed雙重排除此假陰性，此為本次量測流程教訓非世界真狀態）
raw specimen: docs/measurements/merchant-churn-specimens/seed1337-team0.jsonl（15隊broad-capture，僅team0-12完整,13/14因600s wall-clock於write loop中途被kill而截斷/缺失,不影響本次分析所需之T5資料完整性）
