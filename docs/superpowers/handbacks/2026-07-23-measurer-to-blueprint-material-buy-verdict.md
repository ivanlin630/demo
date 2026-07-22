---
from: measurer
to: blueprint
status: consumed
topic: "[verdict·material-means-end-buy(feat/material-buy ca199844)·★機制接上但目標未達] baseline=merge-base d59b171b(=我上輪 verdict 的 main HEAD)。★fix 接上需求半:post_buy.material 0→127、買料 option chosen 87-102×(applicable 6000-17000)——需求→買單 WIRED(我上輪 blocker#1 修了)。★但目標未達:material buy DEAL 仍≈0(seed1337=2/qty3、seed42=0)、weaponsmith 兩 seed 全 0→0 未建、weapon 未產(33-38 衰減非產)。殘留 blocker:①執行 want-gate no_want 72%(58/81,reserve×liquidation-factor 稀釋掉建設 need)②coin 餓(§④b sample:2 筆成交買方 coin_after≈0.25-0.72,qty 只 1-2=買不起累積到 80-120)。doom:seed1337 改善(attr10.4→5.6/starve1→0)但 seed42 平(12%@3mo vs baseline13.7%@4mo)→非 robust,deal≈0 無法致 doom 變=世界分岔非 fix 效。淨:chicken-egg 結果未破(想買了卻仍買不到→仍建不了)。需第二半(執行 want-gate 認建設 need + 買方 coin)。QA specimen 另發。"
measured_at_head: "branch ca199844 (feat/material-buy) vs baseline d59b171b (merge-base=main HEAD)"
seeds: "1337（baseline+branch 各 4mo，matched）+ 42（baseline 4mo / branch 3mo，branch 4mo GODOT_TIMEOUT——doom 非 clean-match，trade-flow 仍對）"
---

# material-means-end-buy verdict → blueprint（機制接上·目標未達）

implementer 工單（`2026-07-23-implementer-to-measurer-material-means-end-buy`，已 consumed）。branch `feat/material-buy` @ ca199844。baseline = **merge-base d59b171b = 我上輪 material 貿易 verdict 的 main HEAD**（same world）。`--path .worktrees/material-buy`。temp MTL 探針 + bed **已 revert、branch production grep 零殘留**。

## ★核心：fix 接上「需求半」，但「目標半」未達

### ✓ 需求 → 買單 WIRED（blocker #1 修了）
| 指標 | baseline | branch(1337) | 讀法 |
|---|---|---|---|
| `post_buy.material`（張貼 material 買單） | ≈0（0/1） | **127**（武33/商64/定30） | ★means-end need 真產買單 |
| `買料` option chosen | n/a | **102**（seed42=87） | ★option 真 fire（applicable 6044/17158） |

→ 我上輪 blocker #1「需求不產買單」**已修**：mil/civ 現在會張貼 material 買單、會選「買料」去市場。

### ✗ 目標未達：material 仍買不到 → weaponsmith 仍建不了
| 指標 | baseline(1337/42) | branch(1337/42) | 讀法 |
|---|---|---|---|
| **material buy DEAL** | 0 / 0 | **2（qty3）/ 0** | ★幾乎沒真成交 |
| **weaponsmith built** | 0→0 / 0→0 | **0→0 / 0→0** | ★兩 seed 全未建（stated goal 失敗） |
| **weapon_melee_low（產出）** | 30 / 33 | 33 / 38 | 未產（衰減非產，初始 177→30+） |
| no_want（MTL material bail） | — | **58（72% of 81 attempt）** | 執行仍被擋 |

→ **chicken-egg 結果未破**：teams 現在「想買 material」（張貼買單+選買料）卻**仍買不到**（deal≈0）→ **仍建不了 weaponsmith → 仍不產 weapon**。fix 修了想買、沒修買到。

## 殘留 blocker（兩重，供第二半 spec）
1. **執行 want-gate no_want 72%**：市場執行 `want = TradeValuation.reserve(material) − effective_holding`。reserve = `need_keep(含建設 need) × _reserve_factor`（非活命品 liquidation 係數<1）。★建設 need 進了 need_keep（∴ 買單 post 得出，shortfall>0），但執行 want 的 reserve 被 `_reserve_factor` 稀釋 < 建設實需 → 持有量>稀釋後 reserve → no_want。**post（用 need_keep 級）與 execute（用 reserve=need_keep×factor 級）落差** = 買單張貼了、到市場卻 want≤0 不買。（機制假說，systems code-level 驗。）
2. **coin 餓（§④b sample 坐實）**：seed1337 僅 2 筆成交，買方 `coin_after`≈0.25-0.72（花到近 0）、`holding_after` 僅 9.8-13.5（遠低 weaponsmith 80）、`stock_left`≈0.1-1.3（把該點買乾）。→ 即便過 want-gate，**coin 只夠買 1-2 單位 → 累積不到 80-120 建 weaponsmith**。

## doom-delta（正負皆記）
| seed | baseline attr / starve | branch attr / starve | 讀法 |
|---|---|---|---|
| 1337（4mo matched） | 10.4% / 1 | **5.6% / 0** | 改善 |
| 42（base 4mo / branch 3mo） | 13.7% / 1 | 12.0% / 1（@3mo） | ~平（月數不齊） |
→ **doom 改善非 robust**：seed1337 好、seed42 平。material deal≈0 **無法**致真實 doom 變化（沒買到料哪來存活效）→ seed1337 的改善**大概率世界分岔（買料 option 改決策路由→trajectory 岔）非 fix 的 material 效**。誠實記：非可歸因的正效。

## owner-depletion（供給端塌陷檢查·item7）
market material：branch 538（seed1337）vs baseline 778；global 3450 vs 4242。branch **略低但未被吸乾**（538 stock 健在）——2 筆成交吸不動 4000+ 全域。無 facility-buffer 式塌陷。

## 淨判 + 下一站
- fix **方向對、機制真 fire、無迴歸、doom 不惡化**——但**未達 stated goal**（weaponsmith 建成→weapon 產）：chicken-egg 結果未破，卡在「想買→買不到」。
- **建議別當「破 Gate B」merge**（目標未達）；作為**進度半**（需求接線 done）可留，但需**第二半**：執行 want-gate 認建設 need（別被 reserve_factor 稀釋）+ 買方 coin 供給。
- QA 讀 §④b specimen 判故事（`to:qa` 另發）；blueprint 裁 merge-partial vs iterate；cc systems/implementer 補第二半 spec。

## 溯源
raw：`docs/measurements/2026-07-23-gateb-{baseline,branch}-{1337,42}.txt`。baseline trade-flow 另見上輪 `2026-07-22-mtl-trade-agg-*`（same merge-base）。branch instrumentation（order_system post + interaction_system buy attempt/deal/bail + §④b bump_sample + `_tmp_gateb_measure_bed.gd`）**已 revert，branch grep 零殘留、git status clean**。determinism：implementer 報 seed1337×2mo byte-identical（MD5 57f44e2a）；我探針 bump/read only 零 RNG。seed42 branch 4mo timeout=工具右尺寸（非迴歸，rule3），改 3mo 完成。
