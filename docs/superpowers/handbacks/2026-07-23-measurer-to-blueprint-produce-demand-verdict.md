---
from: measurer
to: blueprint
status: consumed
topic: "[verdict·produce-demand-responsive(50337300)·修有效但剩閘鎖定=workshop-BUILD] 疊 tools-demand。★produce_need responsiveness 修有效:TASK_MANUFACTURE 隊數 0→1(兩 seed)、生產 option coeff_pressed 23-281、chosen 10(1337)——produce_pull 真隨市場(原死常數→0 選製造)。★★但 tools/goods 仍全 0、weaponsmith 仍 0→0、workshop 仍 0→1。DOMINANT 剩閘鎖定=produce.appl_kill_nofacility 9136(1337)/7479(42):想產卻因『無 workshop』被 applicable-kill——即 implementer 預測的子根①=workshop-BUILD 是終閘。workshop 3mo 才 0→1→幾乎沒隊能產→tools=0→weaponsmith 0。arc 全鏈已通(material 需求/累積/afford cost70/tools 需求/produce responsiveness)只差最上游=workshop 少建。建議下 thread=workshop-BUILD(civ 為何 3mo 才建 1 座 workshop)。doom 同 tools-demand(1337 9.2%/starve2、42 7.9%/starve0,無新惡化)。goods 無亂產(produce_pull=0 when 無需求/facility)。QA §④b 另發。cc systems/implementer。"
measured_at_head: "branch 50337300 (feat/produce-demand-responsive，疊 tools-demand bdbcfd22) vs tools-demand baseline"
seeds: "1337 + 42（各 3mo，GODOT_TIMEOUT=2400）"
---

# produce-demand-responsive verdict → blueprint（修有效·剩閘=workshop-BUILD）

implementer produce-demand 工單（`2026-07-23-implementer-to-measurer-produce-demand-responsive`，consumed）。branch `feat/produce-demand-responsive` @ 50337300（疊 tools-demand：produce_need 死常數 → demand-responsive produce_pull）。baseline = tools-demand（bdbcfd22）。`--path`。temp 探針 **已 revert、branch clean、grep 零殘留**。

## ✓ produce_need responsiveness 修有效
| 指標 | tools-demand baseline | produce-demand | 讀法 |
|---|---|---|---|
| **TASK_MANUFACTURE 隊數 peak** | **0** | **1**（兩 seed） | ★製造任務終於被選（原死常數→從沒選） |
| `decision.opt_coeff_pressed.生產` | （死常數） | 281（42）/ 23（1337） | produce_pull 隨市場動 |
| `decision.opt_chosen.生產` | — | 10（1337） | 真選了製造 |
| `produce.wanted_not_chosen` | — | 473（42）/ 13（1337） | 想產但輸 task-competition（少數） |

→ produce_need 死常數（0.3/0.6）→ **demand-responsive** 生效：有 workshop 的隊終於會選製造。

## ✗ 但 tools/goods 仍 0、weaponsmith 仍 0——DOMINANT 剩閘 = workshop-BUILD
| 指標 | seed1337 | seed42 |
|---|---|---|
| global tools / goods | **0 / 0** | **0 / 0** |
| weaponsmith built | 0→0 | 0→0 |
| workshop | 0→1 | 0→1 |
| **`produce.appl_kill_nofacility`** | **9136** | **7479** |

- **★produce.appl_kill_nofacility 7479-9136**：想產（produce_pull>0）卻因**無 manufacturing facility**被 applicable-kill。teams 想產但**沒 workshop 可產**。
- workshop **3mo 才 0→1** → 幾乎沒隊有 workshop → 能產的隊≈1 → tools/goods≈0 → weaponsmith 恆缺 tools。
- ∴ 即 implementer 預測的**子根① = workshop-BUILD 是終閘**（②responsiveness 修對，①workshop-建 才是剩牆）。

## 淨判：arc 全鏈已通，只差最上游 workshop-BUILD
material 需求(v1)→累積(v2a)→afford cost70(tools-demand)→tools 需求(tools-demand)→**produce responsiveness(本 slice)** 全綠。**唯一剩閘 = workshop 少建**（appl_kill_nofacility 7-9k）：
- workshop 是 civ 設施（`leader_pref 貪婪 0.2`），3mo 才建 1 座 → 製造業無基座。
- 下 thread 建議：**workshop-BUILD**——civ 為何極少建 workshop？（civ 設施 argmax：apothecary/farming/stable 勝出？workshop desire 低？slot？）。

## 回歸（正負皆記）
- doom：seed1337 9.2%/starve2、seed42 7.9%/starve0——**同 tools-demand**（本 slice 行為變極小=workshops 仍≈0），無新惡化。seed1337 starve 2 續追蹤（tools-demand 起）。
- **goods 無亂產**：produce_pull=0 when 無需求/無 facility → 無 workshop 空產（§④b：建成全 tools-free 設施，無 spurious 製造）。determinism digest a2835d99（=tools-demand，2mo 場景行為未變，符 implementer 預期）。

## 感知鐵律（item7）
produce_pull 走 `_trade_demand` 讀 `team_known`（親聞單，非 global order book）——implementer god-view fixture 測 ⑤ 通過（他隊有 tools 單但本隊沒聽到→produce_pull=0）。runtime：製造只在 facility-holder fire（appl_kill_nofacility gate）。親聞 vs global 的 runtime 分離無反例。

## 下一站
- produce-demand **本身正確**（responsiveness 修對）——可作**增量**（blueprint 裁）。
- **weaponsmith 目標仍未達**，剩**單一終閘 = workshop-BUILD**（civ 少建 workshop）。QA 讀 §④b（`to:qa` 另發）；cc systems/implementer（下 thread = workshop-build dispatch）。

## 溯源
raw：`docs/measurements/2026-07-23-produce-{1337,42}.txt`（progress tools/goods=0 逐月 + manufacture/produce probe + appl_kill_nofacility + FACBUILT）。branch instrumentation（order/interaction MTL + outpost FACBUILT + bed）**已 revert、clean**。determinism implementer a2835d99；我探針 bump/read only 零 RNG。3mo 需 timeout=2400（非迴歸，rule3）。
