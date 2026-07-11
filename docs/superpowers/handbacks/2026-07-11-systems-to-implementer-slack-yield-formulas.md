---
from: systems
to: implementer
status: consumed
topic: [§HOW-8 補細節] resource_slack/absorb_yield 確切可算公式——別猜,我 spec 只給 f() 是我漏
---

# 補：resource_slack / absorb_yield 確切公式（§HOW-8 context 欄）

我 §HOW-8 只寫 `f(...)` 沒給 context 欄的確切算法=**我 spec 漏**。這裡給可算版（TEST VALUE，measurer 校準）。**別猜、別空等——照這算，卡再寫 to:systems。**

## `resource_slack`（自身「養得起更多嘴」餘裕，★語意≠food_days）
= **空 pop 容量 × 舒適度**（空額能收人 × 收了不會拖垮自己）：
```gdscript
var cap: int = TeamData.pop_cap_from_leadership(統領 skill)   # leader.skills.get("統領",0)
var spare: float = clampf(float(cap - team.population) / maxf(float(cap), 1.0), 0.0, 1.0)  # 空額比
var comfort: float = clampf(ctx.food_days / SLACK_COMFORT_DAYS, 0.0, 1.0)  # food_days≥舒適門檻→1
c.resource_slack = spare * comfort
```
- `SLACK_COMFORT_DAYS = 7.0`（TEST VALUE，= SURVIVAL_RECOVER_DAYS；food_days 讀 ctx 已有）。
- **≠food_days**：food_days=會不會餓死（單軸餘命）；resource_slack=空容量×舒適（收得起人嗎）。spare 是主軸、comfort 只是「自己得先過得去」的 gate 因子。餓（food_days 低）→comfort→0→slack→0（自己都難不收人），對。

## `absorb_yield`（吸 target 淨收益 = 產能 − pop 負擔，★別抄 richness）
= target **自養能力**（產得比吃得多=淨貢獻、少=純負擔）：
```gdscript
var tgt: TeamData = state.teams.get(target_id)
var tgt_prod: float = ResourceSystem.effective_food(state, tgt)   # target 食物產出/存量(:391)
var tgt_burden: float = float(tgt.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY
var net: float = tgt_prod - tgt_burden
var land_bonus: float = YIELD_LAND_BONUS if tgt.has_own_outpost_or_granary else 0.0  # 帶據點/地=加分
c.absorb_yield = clampf((net / YIELD_NORM) + land_bonus, -1.0, 1.0)
```
- `YIELD_NORM = 20.0`、`YIELD_LAND_BONUS = 0.3`（TEST VALUE）。target 有 granary/outpost 用 `ResourceSystem.own_granary_tile(state,tgt)!=null`。
- **≠richness**（reviewer 點）：richness=值不值得搶（貪婪視角，掠奪用）；yield=養不養得起（淨產能視角）。**別直接拿 `_belief_richness` 抄**——這裡算 target 自身產能−負擔。
- >0=划算吸（target 自養有餘、帶地）；<0=純負擔（餓 target 吸來一起垮=gate#1 非搬餓天然由此壓）。

## 接進 utility（§HOW-8）
- `absorb_drive` 的「資源可負擔」= `ctx.resource_slack`、「期待收益」= `clampf(ctx.absorb_yield, 0, 1)`（負 yield→0=不吸純負擔）。
- gather 時算（target_id 從 absorb finder / consolidate target）。

卡哪、覺得公式不對、原料對不上 → **寫 to:systems**，我 ~20s 接。別在終端問 user、別猜。
