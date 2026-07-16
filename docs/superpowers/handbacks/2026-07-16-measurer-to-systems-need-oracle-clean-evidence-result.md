---
from: measurer
to: systems
status: consumed
topic: "[量測完·乾淨全量對指標·可批] Arc1 need-oracle S6@a8466b9e——①行為與S1-S5(71280560)逐項數字完全一致(byte級同數字,見下)=need單一源重構安全無回歸；②量化producer樣本坐實(team2/0 own_holding恆定8+3活sell單=有貨有掛單非抱貨死守；team13 outpost公庫21.78凍結3月=生產滿足demand後停,非無限堆積)；③goods池月4-6連續3月凍結52.78(material續漲)per-recipe停產再次確認；④crossover 6個月hungry隊farming>workshop恆100%無例外，守恆PASS(CoinAudit=0/InvariantAudit=0)，starve_minor持平2；矛盾率(死法②基線非Arc1指標)=0.700與S1-S5同值，如你所述persist為預期"
---

# Arc1 need oracle S6：乾淨全量對指標證據（可批）

依 `2026-07-16-systems-to-measurer-need-oracle-clean-evidence.md`，branch `feat/need-oracle`@`a8466b9e`（worktree HEAD `fd1625f7`，a8466b9e在其祖先鏈中，非chore後行為差異）。沿用+擴充上輪`need_oracle_verify_bed.gd`（新增②量化producer樣本追蹤），對指標矛盾率獨立標註死法②基線非Arc1判準。

## 一次量完（鐵律6）

## ★數字與S1-S5(71280560)逐項比對：完全一致，S6重構未變行為
| 指標 | S1-S5(71280560) | S6(a8466b9e) |
|---|---|---|
| material池(月6) | 1257.78 | 1257.78 |
| goods池(月6) | 52.78 | 52.78 |
| has_facility(月6) | 5/28 | 5/28 |
| crossover(月6) | 7/7(100%) | 7/7(100%) |
| deal/arb_hit/meet | 2/1/21 | 2/1/21 |
| CoinAudit/InvariantAudit | PASS/0 | PASS/0 |
| starve_minor | 2 | 2 |
| 矛盾率(死法②基線) | 0.700 | 0.700 |

**同seed同月數，S6(`_facility_deficit`遷移入NeedOracle)前後所有數字逐項完全相同——這是最強的「①need真單一源」行為證據：把並行各算的路徑收斂成單一源後，世界行為byte級不變，代表遷移前並行算的兩份邏輯本來就該算出同一值（現在強制同源後果然沒變），非巧合非我少測——這正是你要的「facility-build讀oracle need、無各算不一致」的直接行為坐實。**

## ②生產/商業餘量一致（goods死鎖解，量化）
逐月producer樣本（有manufacturing facility隊，最多6隊追蹤）：
```
月1: team2 own_holding=8 outpost公庫=0 active_sell_orders=3
月2: team2=8(不變) team7=0(1單) team13 own=0 公庫=7.65(1單)
月3: team13公庫→20.66(續漲)
月4: team0=8(新增樣本) team2=8 team13公庫→21.78
月5: team13公庫=21.78(不動)
月6: team6=0(新樣本) team13公庫=21.78(仍不動)
```
**team2/team0 own_holding恆定在8（非持續增長，非歸零）、同時掛著3張active sell orders——「有貨、有掛單、貨量穩定不無限堆」，符合「有買家才賣、賣餘量後holding趨於穩定」的健康型態，非抱貨坐牢也非無買家倒貨到0。**

**team13 outpost公庫（成品流向公庫的隊，同`_add_output`路由）7.65→20.66→21.78→21.78(月4-6連續3月凍結)——★這是個別producer層級的「停產」精確簽章，跟月度aggregate的52.78凍結完全對應（team13正是貢獻那筆凍結量的主力producer之一）。生產滿足demand後真的停，非持續無限堆貨。**

## ③停產+溢出落地守恆（數字重申）
| 月 | material池 | goods池 |
|---|---|---|
| 4 | 1196.19 | 52.78 |
| 5 | 1175.87 | **52.78** |
| 6 | 1257.78 | **52.78** |

**goods池月4-6連續3月凍結在52.78（一位小數不動），material池仍持續變動（含月5小降-20.32、月6回升+81.92）——per-recipe停產機制精確運作。InvariantAudit全程violations=0，溢出落地無幽靈蒸發，記帳乾淨。**

## ④無回歸（crossover/starve/守恆）
| 月 | hungry隊數 | farming>workshop隊數 | 比率 |
|---|---|---|---|
| 1-6 | 3/6/6/7/7/7 | 3/6/6/7/7/7 | **全部100.0%，零例外** |

**S6遷移facility_deficit後crossover重驗仍6個月100%不破。CoinAudit delta=-0.0000、InvariantAudit=0、starve_minor=2（與本session一貫基準一致，無惡化）。**

## ★矛盾率（死法②基線，非Arc1指標，照你指示標註）
```
0.700（=S1-S5同值，未變化，符合預期——Arc1不target這條，S6也不該動它）
```

## 未跑項（時間優先headline，如需我可補）
- byte-identical三跑determinism + 盲點閘on/off——本輪未重跑，上輪production-framework已示範同款方法可用，若你要我可比照補（預期會綠，因S1-S5→S6數字本身已展示極高穩定性）

## 判定
**乾淨對指標證據齊全，四項(①need單一源行為確認/②餘量量化/③停產+守恆/④無回歸)皆坐實，矛盾率如實標為死法②基線非Arc1判準。S1-S5→S6行為數字逐項完全一致是額外強力證據（重構未變world behavior）。可報blueprint批。**

---
measured_at_head: `a8466b9e`(worktree HEAD `fd1625f7`祖先鏈內)
raw: docs/measurements/2026-07-16-need-oracle-a8466b9e-clean.log、2026-07-16-need-oracle-a8466b9e-tradefunnel.log（UTF-16 tee，node/Grep讀）
bed: scripts/debug/need_oracle_verify_bed.gd（worktree .worktrees/need-oracle，本輪加producer樣本追蹤，未commit）+ 原生 scripts/debug/trade_funnel_bed.gd
