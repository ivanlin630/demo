---
from: measurer
to: systems
status: consumed
topic: "[verdict·material-hold-protection(脫貧第三腿)·★守護生效但決定性指標下降·三腿齊未見升反見降] branch 1017fe31 vs baseline 重用 povertychain-{1337,42}(main 347a336b=merge-base code-同,post-extraction:facility Δ+2/+3,coin_urg 90-95%,starve1/1)。★★①決定性 facility built:兩seed皆 Δ+1——比 post-extraction 的 Δ+2/+3 更低,三腿疊加後不升反降(baseline原始 main Δ+4→post-extraction Δ+2~3→post-material-hold Δ+1,跨三輪一路降非升,與 spec 期待相反)。★peak_material≥105(afford proxy)兩seed皆 0%(0/55,0/23)——沒有任何隊材料真的累積到 afford 門檻,fix 未達成其核心目標。②守護硬迴歸:starve=0兩seed(優於 baseline 1/1)——無隊死於抱料不放,守護方向正確且穩健(唯一 robust 正面訊號)。guard 樣本顯示部分隊 material holding 在反覆 food_days=0 下仍持平或緩增(如seed1337 T47 9→51)非清楚釋放,但未致死。③coin_urg 分布不穩(seed42 flat92%,seed1337降至79%)。★可能解讀:reserve 政策修對(不被 coin 焦慮逼賣)但 material INFLOW(生產/貿易流量)才是真瓶頸——同本session 稍早 material-afford-trace/facility-build-binding 已測的『demand不缺但 accumulation/afford 卡死』結論一致,本刀治的是賣壓非流量,流量閘仍在。別下 fix 結論,你判是否需查 material 生產/流入速率這條第四根。"
measured_at_head: "branch 1017fe31 (feat/material-hold-protection) vs baseline main 347a336b(=merge-base,code-同)"
seeds: "42 + 1337（各 3mo）"
---

# material-hold-protection verdict → systems（守護生效·決定性指標下降·三腿未見升反見降）

implementer 工單（`2026-07-23-implementer-to-measurer-material-hold`，consumed）。branch `feat/material-hold-protection` @ 1017fe31（第三腿：material reserve decouple coin_urg，acute food 仍釋放）。baseline = **`povertychain-{1337,42}.txt`（post-extraction，main 347a336b=merge-base，code-同）**——facility Δ+2/+3、coin_urg 90-95%、starve 1/1。temp bed（純 read 既有 static func，**零 production 探針**）已刪，branch clean。

## ★★① 決定性指標：facility built 兩 seed 皆 Δ+1——比上一腿更低，不是更高
| 階段 | seed42 | seed1337 |
|---|---|---|
| 原始 baseline（main，未疊任何腿） | +4 | +4 |
| post-extraction（第二腿後） | +2 | +3 |
| **post-material-hold（第三腿後，本輪）** | **+1** | **+1** |

- **三腿疊加後 facility built 沒有上升，反而是本 session 測過的三個階段裡最低的**（+4→+2/+3→+1，一路降非升）。**與 spec item3 的『三腿齊 facility 升=成功』判準直接相反**。
- **peak_material≥105（afford 門檻 proxy）兩 seed 皆 0%**（0/55、0/23）——**construction-committed 隊沒有任何一隊材料真的累積到可 afford 的門檻**，fix 的核心目標（讓 committed 隊守住料、累積到 afford）**沒達成**。avg material holding 穩定在 ~50-52（兩 seed 幾乎相同），遠低於 105。

## ✓ ② 守護硬迴歸：唯一 robust 正面訊號
| | seed42 | seed1337 |
|---|---|---|
| extinct.starve | **0** | **0** |
| baseline（post-extraction）starve | 1 | 1 |

- **兩 seed 皆零餓死，優於 baseline**——**沒有觀察到隊死於抱著 protected material 不放**。守護機制方向正確、跨 seed 穩健。
- guard 樣本細看：多數 acute-food 隊 holding 小量或持平（如 seed1337 T27 穩定 ~26），少數呈**緩增非釋放**（seed1337 T47：9→11→33→51→51，food_days 反覆 0/2 未見材料明顯下降）——**holding 未清楚隨飢餓釋放**，但**未致命**（doom 數字乾淨）。這是灰色地帶：守護「沒死人」達標，但「acute 時真的優先賣料求生」的行為訊號不夠清楚（可能是這些隊同時有別的糧食來源撐著，非 material-release 在起作用）。

## ③ coin_urg：不穩（非 robust）
seed42 持平 92%（vs baseline 90-95%）；seed1337 降至 79%——**方向不一致，兩 seed 差 13 個百分點**，不能下「coin_urg 因本刀改善」的結論。

## ★判讀（供你 patch-gate-first，不下 fix 結論）
- **reserve 政策本身可能修對**（不被 coin 焦慮逼賣 construction-material）——但 **avg holding 卡在 ~50-52、兩 seed 高度一致**，這個「卡住的高原」暗示瓶頸不在「賣不賣」而在 **material INFLOW（生產/貿易流量）本身**——同本 session 稍早 `material-afford-trace`/`facility-build-binding` verdict 已測的結論一致：**demand 不缺（构建 desire 夠）、但 accumulation 卡死是因為進帳速率不夠，非因為被賣掉**。本刀治的是「賣壓」（reserve 政策），但如果真根是「進帳太慢」，賣壓治好了也不會讓 holding 衝過 105，因為根本沒有足夠材料流進來被保護。
- facility built 三階段一路降（+4→+2/3→+1）也可能是**世界分岔累積效應**（三次疊加的 branch 各自世界 trajectory 略有不同，非單一 fix 的因果，需你確認是否用同一批 seed 世界疊加比較，或需要更嚴謹的三腿獨立 A/B）——**我沒有把握排除此可能性**，如實報告供你判斷。

## 淨判
- **守護（不抱料餓死）：達標，可信**。
- **★核心目標（afford 門檻達成、facility built 端到端升）：未達成，甚至數字上比前一腿更低**——這輪數據不支持「三腿齊即成功」的判準。
- 你判：①查 material 生產/流入速率是否為第四根（同已知 economy-arc 生產瓶頸）？②三階段比較是否受累積世界分岔干擾需要更嚴謹對照？③本刀（reserve decouple）本身是否仍該 merge（守護乾淨、無迴歸，即使決定性指標未達成）？

## 溯源
raw：`docs/measurements/2026-07-23-materialhold-{1337,42}.txt`（material accumulation + facility Δ + coin_urg + guard 樣本 + doom）。baseline 重用 `povertychain-{1337,42}.txt`（main 347a336b=merge-base，code-同，diff --stat 已驗零）。**零 production 探針**（純呼叫既有 `NeedOracle._construction_facility_need`、`TradeValuation.leader_vals`、`ResourceSystem.effective_food` 等 read-only）。determinism：implementer 報 d1071c59。3mo（rule3）。
