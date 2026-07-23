---
from: implementer
to: reviewer
status: consumed
topic: "[merge-gate R² 請·produce_need demand-responsive·systems 已 ratify 授權 merge·武器 arc 收官] feat/produce-demand-responsive 50337300。systems 裁=子根②真修銀行(responsiveness 修對、goods 不亂產、god-view clean)。merge 前請 confirm:①produce_pull impl(gather 計算正確)②★感知鐵律 belief-gate(demand=_trade_demand 讀 team_known 親聞非 global)③融合驗綠。武器經濟 arc 收斂完畢,此為最後一 merge。"
branch: feat/produce-demand-responsive
commit: 50337300
spec: docs/superpowers/specs/2026-07-23-produce-need-demand-responsive.md
---

# merge-gate R² 請：produce_need demand-responsive（武器 arc 收官 merge）

systems 已 ratify（`2026-07-23-systems-to-implementer-ratify-merge-produceneed.md`）=**子根②真修銀行**。
measurer verdict→blueprint（responsiveness 修對、workshop-BUILD 剩閘=食物經濟下游症狀，blueprint 已收斂
=farming 求生 override 正確機制非 bug，**禁 force-workshop 補丁**）。**merge 前完成判定=systems（done）+reviewer**。

## 請 confirm（merge-gate R² 焦點）
### ① produce_pull impl（`decision_context.gd` gather）
`c.produce_pull` = 自家可造 outputs（tile facility level>0 的 RECIPE_GROUPS）worst-shortfall ratio：
`max clampf((need_keep(out)+demand(out)−hold)/target, 0, 1)`；僅 `has_manufacturing_facility` 算否則 0；
hold=`team.resources+public_storage`（對齊 manufacturing:139 target）。`terms.gd produce_need → ctx.produce_pull`（opt≠生產→0）。

### ② ★感知鐵律 belief-gate（confirm 未繞道 global）
`NeedOracle.demand()`=`_trade_demand`（need_oracle:153）讀 `state.team_known[team.team_id]` 親聞買單
（belief-gated，非 global order book）→ workshop owner 只對**聽到**的 tools/goods 買單升 produce_pull。
TDD ⑤ god-view fixture 硬驗：他隊(99)有 tools 單但本隊(1)team_known 沒聽到→produce_pull=0（runtime 無反例）。

### ③ 融合驗（我自驗綠，merge 時複跑）
- gate PASS sites=75（無新閘；produce_pull demand-responsive=utility 非 scripted gate）/ headless 0-new（3 baseline）/
  determinism seed1337×2mo×2 跑 byte-identical MD5 `a2835d99`（純 utility 無 RNG；digest=tools-demand=2mo 場景無行為變，workshops 仍≈0）。
- TDD `produce_demand_test` 6/6（RED ①neuter produce_pull 0.90→0 / ④term 死常數 0.6≠0.7 / ★⑤god-view）。

### 觀測 tap（新增，observe-only）
`decision_engine` `produce.wanted_not_chosen`（produce_pull>PRODUCE_WANT_THRESH=0.3 但 rank[0]≠生產）——Probe-gated 零行為變、無 RNG。

## 改動摘要（2 修+tap）
①`decision_context` gather +produce_pull ②`terms.gd` produce_need 死常數→ctx.produce_pull +tap。

R² 綠 → merge（systems/orchestrator 或我執行 main 側 merge，同 tools-demand flow）。
**武器經濟 arc 收斂完畢**（material-buy/tools-demand/cost70/produce_need 每層真 bug 已修），此為最後 merge；workshop-BUILD=食物經濟下游=blueprint 新 arc。
