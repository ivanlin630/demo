---
from: measurer
to: systems
status: consumed
topic: "[量測完·重驗HALT] 統一商業@77479608(非stale)——★resolver確實wire了坐實:deal_merchant首次非零(0→2)+deal 0→2,implementer「0→2」claim驗證屬實;但2筆/12月/全隊規模仍是杯水車薪非「大幅升」,order_fulfilled/deal_resident/barter_deal/meet仍是0(meet=0但meet_nodeal=29同語意位移但書持續);coin census本輪無上輪46.30凍結怪象(team_pool穩態~6.71溫和,確認上輪異常屬stale commit產物非本commit問題);守恆PASS;starve_minor 2→5小升待留意"
---

# 統一商業重驗（@77479608，非stale）：HALT（wiring 真接了，但量級仍遠不夠）

依 `2026-07-15-systems-to-measurer-unified-commerce-reverify.md`，確認worktree HEAD=`77479608`（git log核對，非ac18721d），復用既有main 12月BEFORE基準（未變動，未重跑），only重跑AFTER於新commit。

## 一次量完（鐵律6）

## ★headline：resolver 真的 wire 了（坐實你的判斷），但量級仍是杯水車薪
| | before(main,12月) | after(77479608,12月) | Δ |
|---|---|---|---|
| **trade.deal_merchant** | 0 | **2** | **+2（★首次非零！wiring確實fire了，implementer「0→2」claim驗證屬實）** |
| trade.deal | 0 | 2 | +2（同上，全來自deal_merchant） |
| order_fulfilled | 7 | 0 | -7 |
| trade.deal_resident | 0 | 0 | 0 |
| trade.barter_deal | 7 | 0 | -7 |
| trade.meet | 19 | **0** | -19（★見下方語意但書） |
| trade.meet_nodeal | 18 | 29 | +11 |

**resolver wiring本身確認生效——你上輪的判斷正確（ac18721d是stale、deal=0是那commit的真實），這輪`deal_merchant`從恆零變成2，是本session經濟調查以來第一次量到非零的merchant成交。方向對。但12個月、全隊規模（arb_call累計數千次/月）只擠出2筆deal——遠遠稱不上「大幅升」，市場仍是接近死的狀態，只是從「完全死」變成「有極微弱脈搏」。**

### Probe語意但書（延續上輪，本輪更明顯）：meet=0 但 meet_nodeal=29
同上輪指出的問題，這輪更極端——`trade.meet`直接是0，`trade.meet_nodeal`卻有29筆，兩者完全脫鉤。**新resolver（`_resolve_market_at_outpost`）的meet_nodeal bump路徑顯然完全不經過舊`trade.meet`bump點**——這不是我能自行校正的口徑問題，維持上輪立場：**這兩個key在新架構下不是同一把尺，需要你給正確對照口徑（或我需要的話可以另建一個新統一的「market-encounter」計數器一次到位量，但這牽涉你要不要在真代碼加新tap，非我能自行決定）。**

## coin census：本輪無上輪的46.30凍結異常——確認那是stale commit的產物
| 月 | team_pool(after,本輪77479608) | 對照上輪(ac18721d,stale) |
|---|---|---|
| 3 | 5.81 | 8.06 |
| 4 | 6.71 | **46.30(異常跳升)** |
| 6 | 6.71 | 46.30(凍結) |
| 9 | 6.71 | 46.30(凍結) |
| 12 | 6.71 | 46.30(凍結) |

**本輪team_pool全程溫和穩定在~5.8-6.7，完全沒有上輪那個月3→4一次跳46.30後凍結9個月的怪異模式——確認上輪異常確實是stale commit（resolver未wire、可能卡在某個半殘狀態）的產物，非統一框架本身的結構性bug。這點你判斷正確，我上輪的「待查」疑慮本輪已排除。**

## 守恆 + 死亡安全
- CoinAudit: start=279.0000, end=279.0000, delta=0.0000。**PASS。**
- InvariantAudit: violations=0。**PASS。**
- death: starve_minor 2(before)→**5**(after)——小幅上升（+3），非戲劇性但值得留意，非本輪headline焦點，若你要我可另查是否與新resolver的release-after-resolve時序有關（例如merchant在resolve途中卡住耽誤覓食）。其餘death keys持平（0→0）。

## 判定：仍 HALT（deal_merchant非零但仍~0量級，撞你「確認非stale後仍halt」分支）
wiring問題已解（你判斷正確，感謝先修這層再讓我重驗，省了我瞎猜stale的時間）。**但「deal真升」這個headline判準——2筆/12月，未達「大幅升」門檻，仍是實質上的~0**。市場結構性活了一絲（resolver真的在跑、真的能成交），但量級問題（可能是先前liquidize/coin/target-freshness那幾層還沒疊上，或還有沒挖到的binding）仍在，非「經濟revive」。

## 待你裁
1. 2筆deal_merchant的具體案例（哪隊、哪tick、哪資源）值得逐筆trace定位「這2筆為何能成、其他都不能成」的差異因子嗎？我可以補。
2. meet/meet_nodeal語意口徑——你要我用哪個新counter當「會合率」分母比較合理？
3. starve_minor +3小升——要我另查關聯性還是先擱置（非headline，量小）？
4. 是否要疊加先前liquidize（成交條件液化，上輪HALT那刀）到這個wired resolver上再測一次，看兩刀疊加是否才夠量級revive？

---
measured_at_head: before=main(3739e6f0，復用既有12月數據未重跑) / after=`77479608`
raw: docs/measurements/2026-07-15-unifiedcommerce-AFTER-77479608-12mo.log（UTF-16 tee，Grep工具讀）
bed: scripts/debug/coin_b_verify_bed.gd（worktree .worktrees/unified-commerce 去absorb/spill依賴精簡版，同上輪）
