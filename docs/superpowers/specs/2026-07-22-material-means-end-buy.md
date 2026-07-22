# spec：material means-end need + 買料 action（Gate B trade-primary 核心）

> 層級：L1-ish（決策模型改：means-end 需求傳導 + 新 buy action，跨 need_oracle/DecisionContext/options，measure-sensitive）。off LOCAL main。
> 來源：material 貿易 DEAL=0 三重 blocker（measurer verdict + QA specimen）。root=chicken-egg（material need gated on 已有 facility→builder 不帶 need→want<0→不買→不建）。blueprint 點頭 means-end（facility 慾望→material need，連軍閥追武/2026-07-19 長程計劃 means-end 依賴圖，憲法 OK=engine utility 耦合非 scripted）。QA 補：need 接了還需**新增買 material action**（現有買糧 fire 305×、買 material 0=結構缺口）。

## root（code-confirmed + QA specimen）
- `need_keep(material)=_self_use(PURE_INTERMEDIATE→0)+_supply_chain(gated on _team_has_facility)` → 想建 weaponsmith 的 builder material need=0 → reserve=0 → `want=reserve−holding<0` → 82-85% no_want → material DEAL=0（供給 OK：civ 賣 1155+/全域 4100+）。
- QA：候選集有「買糧」無「買 material」→ 就算 need 接了也無 action 可選。

## 修 3 部（都做才閉環）

### ① means-end material need（need_oracle）
`need_keep(state, team, res, lv)`：build-input res（`material`，可擴 ore_iron/ore_steel）加 `_construction_facility_need`：
```gdscript
# means-end：團隊想建的 facility → 其 build-cost 的 material need（前瞻買料建設）。
# 讀既有 _facility_deficit 慾望信號（blueprint 認可耦合；憲法=utility 餵 utility）。
static func _construction_facility_need(state, team, res, lv) -> float:
    if res != "material": return 0.0   # scope：material（tools 另軌供給 gap；ore 待需）
    var tile = <team 自家 outpost tile>   # 無 outpost → 0
    if tile == null or tile.outpost_level == 0: return 0.0
    var total = 0.0
    for facility in OutpostSystem.FACILITY_DEF:
        var def = FACILITY_DEF[facility]
        if not (tile.outpost_type in def["allowed_outpost"]): continue   # 該格能建
        var cur = int(tile.get(def["current_level_key"]))
        if cur >= 3: continue
        var cost_mat = float(OutpostSystem.upgrade_cost(facility, cur+1).get("material", 0))
        if cost_mat <= 0: continue
        var desire = FactionAISystem.new()._facility_deficit(state, team, facility, tile)   # 0-1 既有信號
        if desire < CONSTRUCTION_DESIRE_MIN: continue   # TEST VALUE：夠想才前瞻買料
        total += cost_mat * desire   # 想得越強、料需越高
    return total
```
- **★循環守衛**：`_facility_deficit(weaponsmith/armorsmith)`=C 類 `_militancy`（不呼 need_keep）；A 類（workshop）呼 `need_keep(goods/tools/arrows)` ≠ material → 不遞迴回 material need。**depth-1 不遞迴**（只算團隊直接想的 facility 的料，不算那 facility 的供應鏈）→ 有界、無無限遞迴。R² 驗此。
- **cap**：`total` 建議 clamp（如 ≤ 最貴 facility material，避多 facility 疊爆）——R² 判。

### ② DecisionContext 信號（仿 has_food_market）
`DecisionContext.gather` 加：
- `has_material_market: bool`——team_market_known 中有市場**有 material stock**（`public_storage.material>0`；belief-gate 同 has_food_market 範式）。
- `material_shortfall: float`——`need_keep(material)−effective_holding(material)`（>0=缺料想買）。

### ③ 買料 action（options.gd，仿買糧）
```gdscript
"買料": {
    "terms": [["buymaterial_drive", "buymaterial"]],   # weight=material 缺口驅力（缺越多越想買）
    "applicable": func(ctx) -> bool:
        return ctx.material_shortfall > 0.0 and ctx.has_material_market and ctx.has_specie,
    "to_task": func(state, team) -> Dictionary:
        var mp = FactionAISystem.new()._nearest_market_outpost_with(state, team, "material")  # 有 material stock 的最近已知市集
        if mp == Vector2i(-1,-1): return {"task": TASK_IDLE, ...}
        return {"task": TeamData.TASK_TRADE, "target": mp},
}
```
- 到市場後 `_market_visitor_buy` 既有 want-driven（want=reserve−holding，①已讓 reserve>0）→ **買 material** 閉環。
- **DecisionTerms**：加 `buymaterial_drive`（讀 material_shortfall 標度化，人格微調如商業/貪婪，穿人格秤非 flat）。

## ★分開（非本刀）
- **tools=0 全域**（無隊產 tools）=獨立供給 gap（連 workshop production）→ 另議。**買料本刀先 material**（4100+ 存在可買）。
- **mil coin≈0**=次要（has_specie gate 已擋無coin；coin 流通另軌）。

## 驗收
- **TDD**：①想建 weaponsmith 的 mil 隊 → need_keep(material)>0（means-end fire）②無 outpost/低 desire → 0（不亂囤）③買料 applicable=缺料+市場+coin ④循環守衛（need_keep(material) 不無限遞迴，depth-1）。
- **gate** PASS（★新 option/term 過 constitution_gate；`_facility_deficit` 呼叫非新閘）/ **headless** 0 new / **determinism** 2 跑 byte-identical（無 RNG，純 utility）。
- **★★measure（→measurer，behavior-sensitive，帶 §④b 樣本 + specimen；長跑→QA 新規則）**：material buy DEAL（0→?）+ post_buy.material（0→?）+ no_want 率↓ + weaponsmith START/建成（afford 解→建得成?）+ weapon 產出 + doom-delta + owner-depletion/回歸。**送 QA 讀 specimen 判故事 coherent**（mil 隊想建→買料→建成→產武器 motive→action→outcome 鏈）。

## 排序
Gate B trade-primary 核心（3 部閉環）。R²（★循環守衛/cap/耦合憲法/買料 term 人格化/與既有貿易 option 不重疊）→ dispatch。憲法：utility 餵 utility 非 scripted（blueprint 已判合憲）。
