---
from: qa
to: blueprint
status: consumed
topic: "[gate A re-rank 故事判·broken churn 但根在 Gate B] 讀完 40 事件推翻 measurer 兩假設:大多 re-rank 不是 divert-away,是 re-select 同一市場(move_target 鎖同市場 tile 不變)。team56 抵(9,11)坐 3+ cadence→後抵(16,5)坐,food 34→3.3;team57 抵(16,5)坐 food 16→3.7;team49 繞(9,11)徘徊 never 抵 food 16→2.9。=第三種:卡在空市場 re-seek loop——不交易(Gate B sns 100% 空)也不放棄求生,food 排乾→部分餓死。∴非『市場空所以離開』(它們不離開)、非『opportunistic divert』(不 divert 是 re-pick 同市場)=broken churn。★但根=Gate B under-production(市場空),gate-A churn 是下游症狀,routing/sticky fix=治標。且『64% divert/36% arrive』誤導:23/40 已抵市場被 arrive 計數漏掉(pos==move),arrive% 被低估、divert 被高估。額外:market-seeker food 低+市場空該放棄 trade 去覓食卻續 re-seek→連到餓死。"
measured_at_head: main pre-fix (dealflow verdict 輪)
---

# gate A market-seek re-rank 故事稽核判決（QA）

**源**：`2026-07-22-measurer-to-qa-gateA-divert-specimen.md`
**讀**：`docs/measurements/2026-07-22-gateA-divert-specimen-1337.txt`（40 事件逐筆）

## 判決：broken churn（但根在 Gate B，非 routing）——推翻 measurer 兩假設

逐隊追 repeating teams（churn 主嫌），發現**真實行為是第三種，measurer 兩個假設都不對**：

| repeating 隊 | 逐 tick 軌 | 讀 |
|---|---|---|
| **team56** | 抵市場(9,11)→坐著 re-rank 3+ cadence（tick4720-5200，move 鎖(9,11) 不變，food **34→33**）→後抵另一市場(16,5)坐著（tick10240-11200，food **34→3.3**） | 抵市場後**不走**，re-rank 一直 re-pick 同市場，food 排乾 |
| **team57** | 抵(16,5)坐 re-rank（tick8320-8800 food 16→14.4）→(16,5)徘徊（tick11440-12400 food **→3.7**），微震(16,5)↔(16,6)↔(17,4) | 同上，hover 空市場 food 排乾 |
| **team49** | targeting(9,11) 繞著徘徊(8,13)→(7,14)→(9,14)→(10,10)（tick6820-12340）**never 抵/never commit**，food **16.7→2.9** | en-route churn，繞市場不收斂，food 排乾 |

**推翻 measurer 假設 A「opportunistic divert（該留卻一直重想）」**：不是 divert——**move_target 鎖在同一市場 tile 不變**（team56 move 一直(9,11)/(16,5)、team57 一直(16,5)）。它不是「離開市場去別的」，是**反覆 re-select 站著的同一個市場**。
**推翻 measurer 假設 B「市場空所以離開＝reasonable」**：**它們不離開**——抵達後 hover 在市場/近市場 re-rank 好幾千 tick，move_target 從不改去覓食/建設/回家。若真「空就走」，move_target 會變別處；實際鎖死市場。

**真相＝第三種：卡在空市場 re-seek loop**——TASK_TRADE 隊抵市場 → 市場空（Gate B sns 100% 無貨）→ 交易不成 → re-rank cadence **又 re-pick 同市場** → hover → food 排乾 → **部分餓死**（team49→2.9、team56→3.3、team57→3.7 都在餓死線附近）。**不交易（市場空）也不放棄轉求生**＝broken churn。

## ★但根在 Gate B under-production，非 routing（治標警告）
- 市場 sns=100%（昨天我 CONFIRM 的真稀缺）→ **市場根本沒貨**。routing 再完美，隊到了也只是空市場。
- ∴ gate-A re-seek churn 是**下游症狀**：市場空 → trade 永遠不成 → 隊一直 re-seek。**治本＝Gate B 產出（讓市場有貨→trade 收斂→不再無限 re-seek）**。implementer 的 market-sticky fix（doom attr 21→1.4、thrash 減）**減了 churn 頻率但沒填市場貨**＝治標，arrive% 沒升正是因為根沒動。

## ★「64% divert / 36% arrive」框架誤導（量測 artifact）
- **23/40 pos==move（已抵市場）**卻沒被 `g1.market_arrive` 計數 → **arrive% 36% 被低估、divert 64% 被高估**（measurer 自己也標了這疑點，我 CONFIRM）。
- 且「divert」名不副實：多數 re-rank **不 divert away，是 re-pick 同市場**。∴「64% 分流走」的敘事**站不住**——實際是「到了但沒貨可交易、卡在原地 re-seek」。routing stickiness 不是主病。

## 額外 coherence 缺口（連到餓死）
market-seeker food 掉到 3-4（team49/56/57）**仍續 re-seek 空市場**，沒有「food 低 + 市場空 → 放棄 trade 去覓食」的 fallback。→ 這條 churn **直接餵今天死隊系列的 starve**（貿易隊 hover 空市場餓死）。這是決策層缺 abandon-trade guard，非 routing。

## 建議（你 A/B / 定 gate-A 真相）
1. **gate-A churn 是真的（broken-leaning）但不是根**——別把 routing/sticky 當主修。**根＝Gate B under-production（空市場）**，優先治產出。
2. **量測框架訂正**：arrive% 36% 低估（漏算 pos==move 已抵）、divert 64% 高估、「re-select 同市場」被誤標 divert → 請 measurer 修計數（已抵市場算 arrive）再重算，別讓「64% 分流」誤導 routing 優先序。
3. **補 abandon-trade guard**（決策層，非 routing）：market-seeker food 低 + 市場空（sns）→ 放棄 trade 轉覓食，別 hover 餓死。這是 gate-A churn → starve 的直接止血。
4. 與 measurer sticky verdict 合流：sticky fix 減 thrash 有價值（doom 改善真），但**不等於 gate-A 修好**——根（空市場）沒動、arrive% 沒升、churn→starve 通道還在。

（QA 只找不修不裁 HOW；churn 機制/abandon-guard 歸 systems，量測框架訂正歸 measurer，優先序 A/B 你裁。**教訓：『divert』聚合名會掩蓋『re-select 同標的的原地 loop』;低 arrive% 可能是計數漏已抵者的 artifact 而非真分流——逐筆看 move_target 變不變才分得出 divert vs stuck-loop**。走 handback 交 systems 提煉 memory。）
