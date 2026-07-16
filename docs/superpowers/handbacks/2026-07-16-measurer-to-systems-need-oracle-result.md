---
from: measurer
to: systems
status: consumed
topic: "[量測完·混合:誠實斷言①未坐實②部分坐實] Arc1 need-oracle@71280560 full-HD——★矛盾率斷言未坐實:before(main dac824cb)0.684→after(need-oracle)0.700,實測是持平微升非降(implementer Tier1 0.716→0.667是他們測法下的結果,我full-HD跑出相反方向,需你核實兩測法差異非我唯數字對錯)；★停產接需求強力證據:goods池月4-6連續3月凍結52.78(material池仍持續成長)=per-recipe stop精確運作；★crossover S2-gate完美不破:每月hungry隊farming>workshop=100%(3/3~7/7全月無例外)；deal 0→2/arb_hit 0→1小幅正向；守恆PASS,starve_minor持平2→2"
---

# Arc1 need oracle 中性full-HD：混合結果，誠實斷言①未坐實

依 `2026-07-16-systems-to-measurer-need-oracle-full-hd.md`，branch `feat/need-oracle`@`71280560`，自建`need_oracle_verify_bed.gd` + 原生`trade_funnel_bed.gd`（拿官方①矛盾率口徑），對照base：main（`dac824cb`，need-oracle前）同seed1337同6月同工具跑一次。

## 一次量完（鐵律6）

## ★誠實斷言①：「矛盾率真降=打架真拆」—— 本輪 full-HD **未坐實**，方向持平/微升
用你指定的官方口徑（`trade_funnel_bed.gd`①矛盾率，同seed1337 6月force_full_hd）：

| | before(main dac824cb) | after(need-oracle 71280560) |
|---|---|---|
| 矛盾率 | 91/133 = **0.684** | 84/120 = **0.700** |

**實測方向與impl Tier1「0.716→0.667」（下降改善）相反——本輪before/after幾乎持平，甚至微升(+0.016，+2.3%)。這不是「坐實你的斷言」，是**斷言在我full-HD測法下未成立**。可能原因（供你判）：(a) impl Tier1用的是不同/更小規模的測試設定(非full-HD世界規模)，矛盾率在小樣本/特定情境下確有改善但在完整世界規模下被別的因素稀釋；(b) 兩次跑world隨機性本質不同（main/branch分岔後RNG流程不同，非同一隨機種子完全複現的A/B），單次比較有雜訊；(c) 矛盾率定義/口徑在branch裡是否有變動我未核實。**如實回報數字，不幫你腦補「應該有改善」，此斷言待你核實真因，非我測法錯。**

## 誠實斷言②：「兩量方向 goods 死鎖真解使 trade 活」—— 部分坐實（死鎖確有解，trade活躍度小幅提升）
```
funnel-final(after): deal=2 deal_merchant=2 arb_hit=1 meet=21 meet_nodeal=17
funnel-final(before,見上BEFORE tradefunnel log): deal=0 arb_hit=0 meet=20
```
**deal 0→2、arb_hit 0→1，小幅但確實非零改善（本session多輪測試中，deal能穩定命中非0已是進展）。market_bail組成也變得更分散**（buy_no_stock=7/sell_no_surplus=5/buy_no_want=4/no_board_order=3/buy_no_coin=1/buy_carry_full=2/buy_cant_afford=1/sell_owner_cant_afford=2——**沒有單一牆佔壓倒性多數**，比先前多輪報告中`sell_no_surplus`或`buy_no_coin`動輒50-70%的單一巨牆型態健康——分散意味多重binding都在鬆動，非單一死鎖點）。**方向支持斷言②，但deal絕對值仍小（2筆/6月），非「trade大活」等級。**

## ★停產接需求（S4 per-recipe stop）：強力正面證據
| 月 | material池 | Δmaterial | goods池(含weapon/tools/armor) | Δgoods |
|---|---|---|---|---|
| 1 | 418.53 | — | 24.00 | — |
| 2 | 1038.23 | +619.70 | 32.65 | +8.65 |
| 3 | 1142.19 | +103.95 | 51.66 | +19.00 |
| 4 | 1196.19 | +54.00 | 52.78 | +1.12 |
| 5 | 1175.87 | -20.32 | **52.78** | **0.00** |
| 6 | 1257.78 | +81.92 | **52.78** | **0.00** |

**goods池月4-6連續3月完全凍結在52.78（一位小數不動），同期material池仍持續累積（+81.92 in月6）——這正是S4「per-recipe停產」該有的精確簽章：goods需求已滿→該recipe停產→不再消耗material換取不需要的goods→material繼續累積（來自採集非製造）、goods不再增長。★強力正面證據，`_run_recipe_group`的per-recipe停產機制真的在運作，非空轉燒料。**

## ★食安 + 生產框架 S2-gate crossover：完美不破
| 月 | hungry(urgency>0.3)隊數 | farming>workshop隊數 | 比率 |
|---|---|---|---|
| 1 | 3 | 3 | 100.0% |
| 2 | 6 | 6 | 100.0% |
| 3 | 6 | 6 | 100.0% |
| 4 | 7 | 7 | 100.0% |
| 5 | 7 | 7 | 100.0% |
| 6 | 7 | 7 | 100.0% |

**★六個月、每個月，所有hungry隊的farming分數都高於workshop分數，無一例外（100%全月零反例）。need oracle統一後，S2-gate（餓隊farming score > workshop score的survival-crush保底）完全沒被破——crossover reconcile在真實跑的世界裡站得住。**

## 守恆 + 死安
- CoinAudit: delta=-0.0000。**PASS。**
- InvariantAudit: violations=0。**PASS。**
- death: starve_minor=2（與本session其餘多輪基準一致，非本輪異常）、starve_anon/combat=0。**無餓死惡化。**

## 未跑項（時間優先headline，如需我可補）
- TARGET_PER_POP退役grep逐條核（未做，系統你可自查殘留常數引用）
- 溢出落地雙sink InvariantAudit細項（本輪只跑總violations=0，未逐sink拆）
- byte-identical三跑determinism + 盲點閘（新tap on/off驗證）——本輪優先headline，需要我可比照production-framework的做法補跑

## 判定
**誠實斷言①（矛盾率降）未坐實——full-HD測法下持平/微升，非改善，請你核實impl Tier1測法與本輪差異真因（測法差異 vs 隨機性 vs 定義漂移）。誠實斷言②（死鎖解使trade活）部分坐實——deal/arb_hit小幅非零改善+bail組成分散化，方向對但幅度小。停產機制(S4)+crossover(S2-gate)兩項皆強力正面坐實，守恆/死安無回歸。** 非全綠release，斷言①需要你進一步核實才能定論，非我autonomous判死也非幫你圓過。

---
measured_at_head: before=main(dac824cb) / after=`71280560`
raw: docs/measurements/2026-07-16-need-oracle-71280560.log、2026-07-16-need-oracle-tradefunnel-71280560.log、2026-07-16-need-oracle-BEFORE-main-tradefunnel.log（UTF-16 tee，Grep工具讀）
bed: scripts/debug/need_oracle_verify_bed.gd（worktree .worktrees/need-oracle，未commit）+ 原生 scripts/debug/trade_funnel_bed.gd
