---
from: systems
to: implementer
status: consumed
topic: "[dispatch·material means-end need + 買料 action·Gate B trade核心·R² CLEAN(2要求已納)·★off LOCAL main 5cc2aec0·決策模型改measure-sensitive] spec=2026-07-22-material-means-end-buy.md。root chicken-egg(material need gated on已有facility→builder不帶need→want<0→買不到→建不了)。blueprint點頭means-end(憲法=utility耦合合憲)+QA補買料action。reviewer R² 2要求已納:①循環守衛結構化(cost-guard在deficit-call前=只讀cost該res的facility;build-cost res[material/tools]∩facility-output res=∅→結構無遞迴;禁擴到既是build-cost又是output的res,標assert)②cap(CONSTRUCTION_MATERIAL_NEED_CAP防多facility疊爆)。修3部閉環:①need_oracle _construction_facility_need(讀FactionAISystem._facility_deficit×upgrade_cost material,cost-guard前置,cap clamp)②DecisionContext gather加has_material_market(team_market_known有material stock,belief-gate仿has_food_market)+material_shortfall③options.gd新「買料」option(仿買糧:material_shortfall>0+has_material_market+has_specie→TASK_TRADE到有material的最近已知市集)+DecisionTerms buymaterial_drive(讀shortfall標度×商業/貪婪穿秤)。★需_nearest_market_outpost_with(res)找有該res stock的市集(或既有_nearest_market_outpost加res濾)。TDD 5型(spec §驗收)。gate PASS(新option/term過constitution_gate,_facility_deficit非新閘)/headless 0new/determinism 2跑byte-identical無RNG。★★measure帶§④b樣本+specimen→QA(長跑新規則):material buy DEAL(0→?)/post_buy.material/no_want率/weaponsmith START建成/weapon產出/doom-delta/owner-depletion/回歸。tools/coin分開非本刀。task=systems+reviewer。做完→to:measurer(→QA)。"
---

# dispatch：material means-end need + 買料 action（Gate B trade 核心，R² CLEAN）

spec：`docs/superpowers/specs/2026-07-22-material-means-end-buy.md`。reviewer R² 2 要求（結構循環守衛 + cap）**已納入 spec**。blueprint 點頭 means-end（憲法合憲）+ QA 補買料 action。**★決策模型改，measure-sensitive，非盲改。**

## ★★ branch base
- **off LOCAL main `5cc2aec0`**（禁 origin）。pre-push hook 已裝。

## 修 3 部（閉環，缺一不可）
### ① need_oracle `_construction_facility_need`（means-end material need）
- `need_keep(material)` += `_construction_facility_need(state, team, "material", lv)`。
- 遍歷 `FACILITY_DEF`：team 自家 outpost tile 能建（`allowed_outpost`）、未滿級、**`upgrade_cost[material]>0`（★cost-guard 前置）** → 讀 `FactionAISystem.new()._facility_deficit(state, team, facility, tile)`（0-1）；`desire ≥ CONSTRUCTION_DESIRE_MIN` → `total += cost_mat × desire`。
- **★cap**：`total = minf(total, CONSTRUCTION_MATERIAL_NEED_CAP)`（TEST VALUE，建議單一最貴 material-facility cost）。
- **★★結構循環守衛（reviewer）**：cost-guard（`cost[material]<=0: continue`）**必在 `_facility_deficit` 呼叫之前**。**不變量**：material 純 build-cost 非任何 facility output → 讀的 facility deficit 不回呼 need_keep(material) → 結構無遞迴。**code 標 assert/註記**：禁擴 res 到「既是 build-cost 又是 facility-output」者（需 visited-guard）。
- 新 const：`CONSTRUCTION_DESIRE_MIN`（TEST）、`CONSTRUCTION_MATERIAL_NEED_CAP`（TEST）。

### ② DecisionContext（`gather`）
- `has_material_market: bool`——`team_market_known` 有市集 `public_storage.material>0`（belief-gate，仿 `has_food_market` 範式）。
- `material_shortfall: float`——`NeedOracle.need_keep(material)−effective_holding(material)`。

### ③ options.gd 買料 + DecisionTerms
```gdscript
"買料": {
    "terms": [["buymaterial_drive", "buymaterial"]],
    "applicable": func(ctx): return ctx.material_shortfall > 0.0 and ctx.has_material_market and ctx.has_specie,
    "to_task": func(state, team):
        var mp = FactionAISystem.new()._nearest_market_outpost_with(state, team, "material")  # 有material stock的最近已知市集(或既有_nearest_market_outpost加res濾)
        if mp == Vector2i(-1,-1): return {"task": TASK_IDLE, "target": Vector2i(-1,-1)}
        return {"task": TeamData.TASK_TRADE, "target": mp},
}
```
- `DecisionTerms.buymaterial_drive`：讀 `material_shortfall` 標度 × 商業/貪婪穿秤（非 flat）。
- 到市場後 `_market_visitor_buy` 既有 want-driven（①已讓 reserve(material)>0→want>0）→ 買 material 閉環。

## 驗收（spec §驗收 5 型）
- **TDD 5**：①mil 想 weaponsmith→need>0 ②無 outpost/低 desire→0 ③買料 applicable ④循環守衛結構驗（一次完成不遞迴，cost-guard 前置）⑤cap clamp。
- **gate** PASS / **headless** 0 new / **determinism** 2 跑 byte-identical（無 RNG）。
- **★★measure（→measurer，帶 §④b 樣本+specimen；長跑→QA 新規則）**：material buy DEAL（0→?）/ post_buy.material / no_want 率↓ / weaponsmith START·建成 / weapon 產出 / doom-delta（seed1337/42）/ owner-depletion / 8 config 回歸。送 QA 讀 specimen 判故事（mil 想建→買料→建成→產武 motive→action→outcome）。

## ★分開非本刀
tools=0（獨立供給 gap 無隊產）/ mil coin（次要，has_specie gate 已擋無coin）。

## 完成判定 = systems + reviewer。做完 → to:measurer（→QA）。
