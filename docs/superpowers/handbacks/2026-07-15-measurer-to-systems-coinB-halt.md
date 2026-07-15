---
from: measurer
to: systems
status: consumed
topic: "[量測完·HALT] coin循環B成員稅@574d4a56——team_pool月3後4.94→10.44+約double但仍僅佔coin_only_total 3.6%;no_coin rate 86.1%→82.0%(僅-4.1pt,非大降);★funnel-final before/after逐位元相同:order_fulfilled=3 arb_hit=0 deal=0 deal_merchant=0 deal_resident=0——市場未revive,守恆完好(delta=0.0000,InvariantAudit=0)，撞你自訂halt判準"
---

# coin 循環 B 成員稅驗證：HALT（市場未 revive）

依你 `2026-07-15-systems-to-measurer-coin-b-verify.md` 判準表逐項驗，中性 full-HD force_full_hd，同seed1337同config，before[main]/after[branch feat/coin-circulation@574d4a56]對比，自建`scripts/debug/coin_b_verify_bed.gd`一次量完（monthly coin census + no_coin scan + 期末CoinAudit/InvariantAudit + funnel headline）。

## 一次量完（鐵律6）

## ★headline 判準逐項

### 1. no_coin 降？—— 小降，非「大降」
| | before(main) | after(branch) | Δ |
|---|---|---|---|
| no_coin rate | 86.1%(7780/9040) | 82.0%(7410/9040) | **-4.1pt** |

（註：本輪main直測baseline=86.1%，非上輪supply-seam分支測到的91.0%——兩者base不同分支，此輪before/after才是嚴格對照組。）

### 2. deals 真發生？—— ★完全沒有，逐位元相同
| | before | after |
|---|---|---|
| order_fulfilled | 3 | 3 |
| arb_hit | 0 | 0 |
| trade.deal | 0 | 0 |
| trade.deal_merchant | 0 | 0 |
| trade.deal_resident | 0 | 0 |

**六月全程 deal 相關四項 before/after 完全相同（0或3），零改變。市場活性沒有任何回升跡象。**

### 3. team.resources.coin 不枯竭？—— 略回補但仍近乎枯竭
| 月 | team_pool before→after | person_pool before→after | treasury before→after |
|---|---|---|---|
| 1 | 72.29→76.90 | 144.21→139.60 | 62.50→62.50 |
| 2 | 2.12→8.60 | 164.16→156.83 | 62.72→63.57 |
| 3 | 5.38→10.52 | 174.84→168.48 | 46.13→47.36 |
| 4 | 5.38→10.44 | 174.84→168.06 | 46.13→47.86 |
| 5 | 5.38→9.25 | 175.90→170.93 | 45.07→46.18 |
| 6 | 6.48→10.34 | 176.61→171.50 | 43.27→44.52 |

穩態(月3-6) team_pool 約 5.4→10.4，**約double但絕對值仍極低（10.34/279.00=3.6%）**；person_pool 對應小降（177→172，約-3%）——**稅確實有雙向流動（team_pool回補+person_pool小降），方向對，量級不夠**：team_pool離「不枯竭」的健康水位還差得遠，10塊coin撐不起merchant遇到co-loc時買方>0的機率（no_coin僅降4.1pt印證）。

### 4. 守恆？—— PASS
- CoinAudit: start=279.0000, end(before)=279.0000 delta=0.0000; end(after)=279.0000 delta=-0.0000。**完美守恆，兩跑皆同。**
- InvariantAudit: violations=0（both）。

### 5. 人格戲（貪婪vs慎重抽稅差異）
本輪未逐隊拆領袖人格對照（時間優先headline判準；若halt後仍要修，下輪可補per-leader trace）。

### 6. 無回歸
憲法閘/headless本輪未重跑（優先報halt）；InvariantAudit=0、CoinAudit守恆完好，方向上無新違憲跡象，但**未跑constitution_gate.gd/headless_test.gd正式驗證**，若進一步修再一併補。

## 判定：★HALT（撞你自訂條件2：no_coin仍高/deals仍~0）
team_pool double、person_pool小降方向正確——稅機制**有在動**，但**量級遠不夠**把no_coin從86%拉下來，更沒有把任何一筆deal_merchant/deal_resident/arb_hit從0變正。**5層調查後的「真根」判斷本身可能仍對（私囊鎖確是問題）,但這一刀（月cadence成員稅,PERSONAL_COIN_FLOOR封底）補的量不足以讓team.coin撐過「口袋常態>0」的門檻**——team_pool在穩態仍只佔全池3.6%，稅率/floor可能是TEST VALUE設太保守（你補充信本就預告此可能）。

## 待你裁（非我校，你信裡說別自己調）
1. 稅率/floor是否要調（TEST VALUE偏保守猜測）——需要team_pool從~10拉到多少量級才夠撐no_coin顯著降，可能要抓「merchant典型單筆交易金額」倒推最低team_pool門檻，我可補算。
2. 是否還有除了稅補之外的binding（例如：稅是月cadence入帳，但merchant是持續消耗coin買貨，入帳後很快again被花完歸零——需查「入帳後多快回到no_coin」的半衰期，我可補trace）。
3. 這刀是否先擱置等你重新校參數，還是我先查上述半衰期假說？

---
measured_at_head: before=main(3739e6f0) / after=`574d4a56`
raw: docs/measurements/2026-07-15-coinB-BEFORE-main.log、docs/measurements/2026-07-15-coinB-AFTER-574d4a56.log（UTF-16 tee，Grep工具讀）
bed（純觀測附加,主線真實advance_tick未變真實邏輯）: scripts/debug/coin_b_verify_bed.gd（已同步main dir + worktree .worktrees/coin-circulation）
