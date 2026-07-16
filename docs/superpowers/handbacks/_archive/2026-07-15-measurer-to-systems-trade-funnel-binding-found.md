---
from: measurer
to: systems
status: consumed
topic: "[漏斗完整breakdown·binding層鎖定] arb_hit=0整6月(4592次arb_pick成功選中目標,零次co-locate)——binding層在pick→hit之間=merchant追蹤/移動到目標點的機制,非供給可見性(arb_sell/buy_seen健康)非距離(arb_kill_range=0)非supply短缺(nostock只殺call不殺pick後);復用既有supply-seam-after數據未重跑"
---

# trade 漏斗完整 breakdown：binding 層鎖定在 arb_pick → arb_hit

`measured_at_head: 4c2f85cb`。復用先前 supply-seam 驗證跑（seed1337 6月force_full_hd）**已存數據，未重跑**——所有要的 probe key 早在該次跑的 monthly delta 裡。

## 一次量完（鐵律6）

## 全站漏斗（6月合計）
| 站 | probe key | 數字 | 意義 |
|---|---|---|---|
| 1 貼賣單 | trade.post_sell | 512 | seam修後真的在貼 |
| 1 貼買單 | trade.post_buy | 3400 | |
| 3 呼叫 | trade.arb_call | 13275 | merchant 嘗試次數 |
| 3 賣單可見 | trade.arb_sell_seen | 7035 | ★供給可見性健康 |
| 3 買單可見 | trade.arb_buy_seen | 60271 | ★需求可見性健康(極高) |
| 3 距離殺 | trade.arb_kill_range | **0** | ★geography 完全不是問題 |
| 3 無貨殺 | trade.arb_kill_nostock | 49970 | merchant 自身carry stock=0（絕大多數call死這站）|
| 3 選中 | trade.arb_pick | **4592** | ★但仍有4592次成功選到非空候選(call的1/3) |
| 5/6 會合命中 | trade.arb_hit | **0** | ★★★整6月零命中！4592次picked卻0次到點 |
| 6 會合零成交 | trade.meet_nodeal | 13 | 極少數會合(非arb_hit路徑,可能是巧遇) |
| 6 成交 | trade.deal | 10 | |
| 6 merchant成交 | trade.deal_merchant | **0** | |
| 6 resident成交 | trade.deal_resident | 10 | （全部10筆成交都是resident路徑,非merchant/arb路徑）|
| 6 以物易物 | trade.barter_deal | 1 | |
| board讀單 | g1.board_read | 24 | 極低但非0 |
| 訂單成交 | g1.order_fulfilled | 2 | |

## ★★★binding 層精準鎖定：`arb_pick` → `arb_hit` 之間
依你給的判準表：「arb_pick升 but meet_nodeal高/arb_hit~0 → 追了但到不了點or到了不成（travel/co-location斷）」——**完全命中此模式**：
- arb_pick=4592（六月穩定，每月356-1104不等，選中目標的能力正常）
- **arb_hit=0（整6月無一例外，每月皆0）**——merchant 選中目標後，**從未一次成功「追到並會合」**。
- `trade.deal_merchant=0` 進一步坐實：所有透過 arbitrage/merchant 路徑的交易全滅，僅有的10筆成交(`deal_resident`)走的是另一條非-merchant路徑（resident同格互售，不經arb_call/pick/hit這條漏斗）。

**排除的假設**：
- 供給可見性：健康（`arb_sell_seen`/`arb_buy_seen`皆高且逐月成長）。
- 太遠撮不到：`arb_kill_range=0`，merchant從不因距離放棄——但這反而詭異：**如果真的追不到，為何不是death在`arb_kill_range`，而是death在更下游的`arb_hit`？** 代表merchant「認為」距離在範圍內、選中了目標、卻在實際追蹤/移動過程中失敗——**像是`_refresh_attack_pursuit`/movement那類「決策選中但移動機制沒真的送達」的同款問題**（本session稍早god-view/位置belief化那條線也挖過類似的「選了但沒到」模式，供你對照）。

## 待你裁
1. `arb_pick`後、`arb_hit`前這段——是`_refresh_attack_pursuit`同款移動追蹤斷、還是merchant專屬另一套travel邏輯壞掉？需查 code（非我能猜，patch-gate-first方向：查是否有硬gate/override在這段pre-empt掉移動）。
2. `trade.deal_resident`10筆是唯一活路——resident路徑（同格巧遇）為何能繞過整條斷掉的merchant漏斗，值得對照兩條路徑差異找線索。

---
measured_at_head: 4c2f85cb（復用既有supply-seam驗證數據）
