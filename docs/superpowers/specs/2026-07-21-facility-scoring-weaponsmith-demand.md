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
- **`_weapon_market_deficit`**：weaponsmith outputs=`[weapon_melee_low, weapon_ranged_low]` 的 demand-driven deficit。**★★DRY（reviewer R² ③要求）：抽 shared helper `_generic_res_deficit(state, team, outputs, use_demand, agg_mode, lv) -> float`，從 `_facility_deficit` 的 A 類分支（min_per_res/pooled_sum + need_keep + demand + output_scale）抽出。A 類 dispatch **和** weaponsmith market 都呼此 helper，禁平行重寫**（收斂為一，避 seam#1「各算」）。weaponsmith market = `_generic_res_deficit(state, team, [weapon_melee_low, weapon_ranged_low], true, "min_per_res", lv)`。
- **`_commercial_inclination`**：`clampf(貪婪×W1 + 商業技能×W2, 0, 1)`（TEST VALUE 權重；貪婪/商業高→軍火商動機強）。**人格化非 flat**（blueprint「穿人格秤非硬寫繞過」，同域專判斷器邊界）。
- **max 語意**：自衛急（armed 低）OR 市場好賣（demand 高 × 商業人格）任一 → weaponsmith 值得建。兩動機都合理，reviewer R² 判無 double-count。

## ② workshop demand 封頂→連續 = **拆獨立 follow-up slice（reviewer R² ④）**
**本 slice 不含 ②**。reviewer R² 判：② workshop cliff→連續 = **獨立 goods 建造行為改**，綁一起 conflate ① 的 measure（① 是核心解武器產業起不來，② 是 goods 公式品質）。→ **②拆獨立 follow-up slice**（`workshop demand pop-relative 連續正規化`，記 known_issues backlog）。①單獨解主病、單獨 measure（乾淨對照）。blueprint 認可「兩個都做、①優先」——②不砍只延後獨立做。

## ★★無 RNG / 人格穿秤
- 純算術（demand/holding 比 + 人格權重），**零 randf**。
- 人格化 = 決策穿人格秤（貪婪/商業/militancy），非硬寫繞過引擎。

## 驗收
- **TDD**：weaponsmith：①高武器 demand + 商業人格 → deficit 高（market 路徑）②武裝不足 + militaristic → deficit 由 self_defense ③demand=0 且武裝足 + 低商業 → deficit 0 ④max 語意（兩路徑取高、無 double-count）。
- **★DRY 檢查（reviewer ③）**：`_generic_res_deficit` helper 抽出後，`_facility_deficit` A 類分支 **和** weaponsmith market 都呼此 helper（非平行實作）；A 類既有 facility（workshop/apothecary/armorsmith/smeltery/stable）行為 **byte-identical**（純重構，helper 抽出不改語意）。
- **gate** PASS / **headless** 0 new / **determinism** 2 跑 byte-identical（無 RNG + helper 抽出純重構）。
- **★measure（→measurer，behavior-sensitive，帶 §④b 樣本/可用 Probe.bump_sample）**：facility-build-by-type（weaponsmith 建數 0→?）+ weapon 產出（weapon_melee_low 池 0→?）+ weaponsmith vs workshop score 分布（不再 systematically 輸）+ doom-delta（seed1337/42）+ 8 config sanity。**不需 QA**（blueprint：formula 事實非故事）。

## 排序
本 slice = **①單獨**（weaponsmith 納武器 demand + DRY helper 抽出）。R² CLEAN（reviewer 2 要求已納：DRY helper + 拆 ②）→ dispatch。②workshop 連續 = 獨立 follow-up（known_issues backlog）。
