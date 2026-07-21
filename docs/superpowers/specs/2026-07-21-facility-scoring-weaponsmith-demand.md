# spec：facility-scoring 平衡 —— weaponsmith 納武器市場 demand（軍火商路徑）

> 層級：L3（deficit formula 2 處，measure-sensitive）。off LOCAL main。
> 來源：measurer 坐實 facility-argmax 系統性壓過 weaponsmith（60 樣本僅中 1）；blueprint 裁選①（納武器市場 demand，連綜合發展模型「商隊追財」路，軍火商合題材）；code-confirm 根=deficit 語意不對稱（workshop demand-responsive vs weaponsmith armed_ratio-only）。不需 QA（formula 事實）。

## 根因（code-confirmed fact）
`_facility_score = terrain_fit × (1 + deficit) × personality`。
- **workshop**（A 類 `use_demand=true`）：goods demand 3573 巨 + holding~0 → deficit 封頂 **1.0** → score ~4.4。
- **weaponsmith**（`_deficit_weaponsmith` special）：`clampf(0.6 − armed_anon_ratio,0,1) × militancy` = **只讀自隊 armed_ratio**（≤0.6，武裝足則 0），**無視武器市場 demand** → score ~3.9，systematically 輸。
- ∴ 武器 demand 再高不驅 weaponsmith 建 → militaristic/商業隊走不了武力/軍火路（牴觸綜合發展模型）。

## ① 修 weaponsmith deficit：加武器市場 demand 路徑（人格化，armed_ratio 留）
`_deficit_weaponsmith`（`faction_ai_system.gd`）改**兩路徑取 max**（自衛 OR 軍火商，皆可驅建）：
```gdscript
func _deficit_weaponsmith(state, team, _tile, lv) -> float:
    # 路徑1：自衛（現況留）——武裝不足 × militancy
    var self_defense: float = clampf(0.6 - team.armed_anon_ratio, 0.0, 1.0) * _militancy(team, lv)
    # 路徑2：★軍火商——武器市場 demand 驅動 × 商業人格（貪婪/商業技能高→更響應市場）
    var market: float = _weapon_market_deficit(state, team, lv) * _commercial_inclination(team, lv)
    return clampf(maxf(self_defense, market), 0.0, 1.0)
```
- **`_weapon_market_deficit`**：對稱 workshop A 類 min_per_res——weaponsmith outputs=`[weapon_melee_low, weapon_ranged_low]`，每 res `tgt = need_keep + NeedOracle.demand`（demand=belief-gated 武器買單），`worst = min(holding/tgt)`，`deficit = 1 − worst`。（★複用既有 A 類算法邏輯，別重寫——見驗收 note。）
- **`_commercial_inclination`**：`clampf(貪婪×W1 + 商業技能×W2, 0, 1)`（TEST VALUE 權重；貪婪/商業高→軍火商動機強）。**人格化非 flat**（blueprint「穿人格秤非硬寫繞過」，同域專判斷器邊界）。
- **max 語意**：自衛急（armed 低）OR 市場好賣（demand 高 × 商業人格）任一 → weaponsmith 值得建。兩動機都合理。

## ② 修 workshop demand 封頂太粗 → 連續（順手，次要）
workshop A 類 min_per_res：`worst = min(holding/tgt)`，`tgt = need_keep + demand`。demand unbounded → 中度未滿足即 `worst→0` → deficit 恆 1.0（cliff-ish）。
- **改**：demand 貢獻 pop-relative 正規化——`tgt` 內 demand 項 cap 在 `pop × DEMAND_PER_POP_CAP`（TEST VALUE），使 deficit **連續反映 demand 量級**非中度即封頂（同 team73 DESPERATION「連續非 cliff」紀律）。
- **★次要**：①已解 weaponsmith 輸的主病（兩者都 demand-responsive→weaponsmith 憑 terrain_fit near ore_iron 贏）；②是公式品質改善。R² 若判 ② 動 goods 行為風險大→拆獨立 follow-up slice，①先行。

## ★★無 RNG / 人格穿秤
- 純算術（demand/holding 比 + 人格權重），**零 randf**。
- 人格化 = 決策穿人格秤（貪婪/商業/militancy），非硬寫繞過引擎。

## 驗收
- **TDD**：①weaponsmith：高武器 demand + 商業人格 → deficit 高（market 路徑）/ 武裝足 + 低商業 → deficit 由 self_defense（不歸零若仍 militaristic）/ demand=0 且武裝足 → deficit 0。②workshop：中度 demand → deficit 連續（非直接 1.0）。
- **★複用檢查**：`_weapon_market_deficit` 若能複用 A 類 generic evaluator（`FACILITY_DEFICIT_DEF` weaponsmith 改 A 類 + special 融合）更佳；R² 判「複用 vs special 內算」哪個乾淨（別重寫 A 類邏輯=DRY）。
- **gate** PASS / **headless** 0 new / **determinism** 2 跑 byte-identical（無 RNG）。
- **★measure（→measurer，behavior-sensitive，帶 §④b 樣本/可用 Probe.bump_sample）**：facility-build-by-type（weaponsmith 建數 0→?）+ weapon 產出（weapon_melee_low 池 0→?）+ weaponsmith vs workshop score 分布（不再 systematically 輸）+ doom-delta（seed1337/42）+ 8 config sanity。**不需 QA**（blueprint：formula 事實非故事）。

## 排序
①優先（核心，解武器產業起不來）+ ②順手（R² 判是否同 slice or 拆）。R²（人格權重/max 語意/複用 A 類/②風險/無 RNG）→ dispatch。
