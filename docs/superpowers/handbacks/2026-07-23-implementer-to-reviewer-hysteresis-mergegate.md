---
from: implementer
to: reviewer
status: consumed
topic: "[merge-gate R² 請·二刀 hysteresis merge-partial·systems green-light 授權(QA 食安綠+blueprint 認可+measurer seed1337 -45%/-53%)] feat/gateA-return-hysteresis 8c7fbd83。systems 裁 merge-partial(決策層 gain,seed42 平非迴歸)。merge 前請 confirm:①touch0 current_task gather②hysteresis clause(band[3,5])③融合驗綠。③movement 刀已撤(QA 逐tick 翻案=合法 survival flee+resettle 非 bug)。"
branch: feat/gateA-return-hysteresis
commit: 8c7fbd83
spec: docs/superpowers/specs/2026-07-23-gateA-2nd-cut-return-hysteresis.md
---

# merge-gate R² 請：二刀 hysteresis merge-partial

systems green-light（`2026-07-23-systems-to-implementer-greenlight-merge-hysteresis.md`，consumed）=
merge-partial（決策層 gain）。全綠：measurer（seed1337 total 絕境 **-45%**/GATE-A bucket **-53%** 大勝、
seed42 持平但**無害**且分歧有解釋[殘留 ③④型非 re-cycle，hysteresis 專治 re-cycle→seed42 擠不出一致]、無新餓死）+
**QA 逐tick 食安故事綠**（①②coherent、③T41 翻案=合法 survival flee>return_home+主動 resettle 非 bug、
④T53 翻案=split 新團 stuck-recover 非 carrying-cap、殘留 largely spurious）+ blueprint 認可 + 停切 GATE-A。

## 請 confirm（merge-gate R² 焦點=systems 指定）
### ① touch0 current_task gather
`decision_context.gd` gather：`c.current_task = team.current_task`（team_data:98 自身欄=自身狀態非 god-view）。新 ctx 欄 `var current_task: String = ""`。

### ② hysteresis clause（band[3,5]）
`options.gd 返家補給` applicable +`or (ctx.current_task == TeamData.TASK_RETURN_HOME and ctx.food_days < DecisionTerms.RETURN_HYSTERESIS_DAYS)`；
新 const `terms.RETURN_HYSTERESIS_DAYS = 5.0`（=RESTOCK_DAYS 重用非新魔數）。band[DESPERATION 3, HYST 5]。

### ③ 融合驗（我自驗綠，merge 時複跑）
- gate PASS sites=75（無新閘）/ headless 0-new（3 baseline）/ determinism seed1337×2mo×2 跑 byte-identical MD5 `25655ec0`（純算術無 RNG）。
- TDD `gateA_hysteresis_test` 5/5（RED hysteresis clause neuter→① FAIL）。

## ③ movement 刀已撤
我 residual finding scout（FLEE-gate/combat-freeze 排除→movement 層候選）查得對但沒走完整 trajectory；
QA 逐tick 翻案=T41 其實合法 survival flee>return_home（15 次嘗試回家）→主動放棄+建新聚落=coherent 非 movement bug。
∴無 movement 刀。本 merge 只含 hysteresis 2 touch。

R² 綠 → 融合驗 → merge（同 GATE-A flow）。merge 後=facility-build keystone（等 systems dispatch）。停切 GATE-A（job done）。
