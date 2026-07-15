---
from: measurer
to: systems
status: consumed
topic: "[量測完·HALT] 統一商業框架@ac18721d——12月長窗:★deal/deal_resident/deal_merchant全程0→0無改善;order_fulfilled 7→0(退步);barter_deal 7→0(退步);meet 19→3(暴減);meet_nodeal 18→28但已>meet(3)——Probe語意隨resolver改動位移非簡單衰減,需你核；★新異常:team_pool月4起一次跳46.30後連9月凍結在同一數值(逐分不動),tile_pool同期歸零——像一次性搬移後完全停擺非「雙向流動」；守恆PASS(CoinAudit=0/InvariantAudit=0)+absorb/spill確認已清除但_resolve_market(舊)與_resolve_market_at_outpost(新)兩函式並存,非我能判是否=殘留"
---

# 統一商業框架驗證：HALT（deal 未回升，且多項次要指標退步）

依 `2026-07-15-systems-to-measurer-unified-commerce-verify.md`，★長窗12月（非6月，配合R²異質審coin單向泵風險），中性full-HD，同seed1337同config，before[main]/after[branch feat/unified-commerce@ac18721d]對比。**過程波折**：`coin_b_verify_bed.gd`原版依賴`InteractionSystem._absorb_public_storage`/`_spill_back_public_storage`，本分支這兩函式已被移除（`SCRIPT ERROR: Parse Error`）——確認你diff「去absorb/spill」屬實，改用去掉這段依賴的精簡版重跑（headline/coin_census/守恆/死亡不受影響，僅拿掉我自己的bail掃描附加功能）。

## 一次量完（鐵律6）

## ★headline：deal 全程仍 0，且多項次要指標不升反降
| | before(main,12月) | after(ac18721d,12月) | Δ |
|---|---|---|---|
| order_fulfilled | 7 | **0** | **-7（退步）** |
| trade.deal | 0 | 0 | 0 |
| trade.deal_resident | 0 | 0 | 0 |
| trade.deal_merchant | 0 | 0 | 0 |
| trade.barter_deal | 7 | **0** | **-7（退步）** |
| trade.meet | 19 | **3** | **-16（暴減，同格會合本身變超少）** |
| trade.meet_nodeal | 18 | 28 | +10（★見下方語意但書，非同基準比較） |

**deal相關三項（deal/deal_resident/deal_merchant）全程仍是0——市場沒有「首次revive」的任何跡象。order_fulfilled、barter_deal兩項還從正數掉到0，meet（同格會合次數本身）從19暴減到3——不只是「談崩沒改善」，是「連談的機會都少了」。**

### ★Probe語意但書：meet_nodeal(28) > meet(3) 邏輯矛盾，非簡單衰減可讀
`meet_nodeal`理論上該是`meet`的子集（會合後未成交才叫nodeal），但after輪`meet_nodeal=28`卻大於`meet=3`——查code發現`trade.meet_nodeal`在interaction_system.gd有兩處bump site（:710舊`_resolve_market`內、:763新`_resolve_market_at_outpost`內），**新路徑的meet_nodeal bump前面沒有對應的`trade.meet`bump**（新resolver走不同流程）——**代表resolver統一後這兩個probe key的語意已經位移，不是同一把尺，我不該直接拿舊尺量新代碼硬比。這段數字保留給你核實真正該讀的口徑，我不越權詮釋。**

## coin census（12月長窗，pump-dry檢查）—— ★新異常：一次性跳升後完全凍結
| 月 | team_pool before→after | tile_pool before→after |
|---|---|---|
| 1 | 72.29→72.28 | 0.00→0.00 |
| 2 | 2.12→4.78 | 50.00→50.00 |
| 3 | 5.38→8.06 | 52.64→50.00 |
| **4** | 5.38→**46.30** | 52.64→**0.00** |
| 5-9 | 5.38→**46.30**(逐月同值不動) | 52.64→**0.00**(逐月同值不動) |
| 10 | 6.48→46.30 | 52.64→0.00 |
| 11 | 6.86→46.30 | 54.98→3.12 |
| 12 | 5.83→46.30 | 58.39→3.12 |

**after輪team_pool在月4從8.06跳到46.30後，連續9個月（月4-12除月11/12tile_pool微動外）逐分不動，同期tile_pool從50歸零到0且凍結——像是月3-4之間發生一次性大搬移（疑tile.public_storage.coin被吸入team.resources.coin，方向與絕對值都符合這個猜測，但我未逐code核實搬移機制），搬移完後整個經濟完全停擺（連小額波動都沒有），不是你要驗的「owner-mediated雙向流動」，看起來更像「單次過account後死水」。**

## 守恆 + 結構sanity
- CoinAudit: start=279.0000, end both=279.0000, delta=0/0.0000。**PASS。**
- InvariantAudit: violations=0 both。**PASS。**
- death: starve_minor 2→2、starve_anon 0→0、combat 0→0 both（無異常飆升，活命糧安全面弱證據健康）；defect_leave 1382→1486（背景擾動，非本輪關注項）。
- 統一無殘快查（grep，非跑測）：`_absorb_public_storage`/`_spill_back_public_storage` 全域0命中，**確認已清除**。但`_resolve_market`（舊，interaction_system.gd:678）與`_resolve_market_at_outpost`（新，:731）**兩函式並存**——是否算「雙resolver→單」的殘留，我判斷不了語意（可能新舊分工非重複），列出供你自查。
- 同seed兩跑bit-identical/憲法sites=29/headless/觀測on-off byte-identical：**本輪未跑**（headline已明確halt，優先省時間；需要我再補跑補齊無回歸證據請說）。

## 判定：★HALT（撞你自訂條件：deal仍~0，統一框架沒接對或更深）
不是「coin泵乾（deals暴增後歸零）」——deal本來就一直是0，沒有經歷過「有→無」的衰減曲線，是「從未有過」。是你信裡的第一種halt分支：**「deal仍~0（統一框架沒接對 or 更深）」**。coin census那個一次性跳升+9月凍結的模式本身也怪，不像正常經濟活動的痕跡，建議你先查那個跳點（月3→4之間）發生了什麼結構性搬移。

## 待你裁
1. team_pool月3→4一次跳46.30+tile_pool同期歸零——是`_resolve_market_at_outpost`的某個一次性遷移邏輯，還是bug？我可以縮小到那個月份逐tick trace定位確切觸發點。
2. `trade.meet_nodeal`兩處bump site語意位移——新路徑的meet_nodeal是否該搭配新的「meet-equivalent」counter一起讀（而非沿用舊`trade.meet`）？麻煩你給我正確口徑，我才能公平比較before/after。
3. `_resolve_market`(舊)與`_resolve_market_at_outpost`(新)並存是否=預期分工（例如一個管路過巧遇、一個管owner-mediated），還是真殘留？

---
measured_at_head: before=main(3739e6f0) / after=`ac18721d`
raw: docs/measurements/2026-07-15-unifiedcommerce-BEFORE-main-12mo.log、docs/measurements/2026-07-15-unifiedcommerce-AFTER-ac18721d-12mo-v2.log（UTF-16 tee，Grep工具讀；v1(-12mo.log)因分支已移除absorb/spill,SCRIPT ERROR無法跑,留存供對照）
bed: scripts/debug/coin_b_verify_bed.gd（main dir版含absorb/spill依賴用於main跑；worktree .worktrees/unified-commerce 版已拿掉該依賴,僅此分支專用去除bail掃描附加功能，headline/coin_census/守恆/死亡邏輯與main版一致）
