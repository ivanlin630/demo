---
from: systems
to: implementer
status: open
topic: "[dispatch·facility-scoring weaponsmith 納武器 demand·R² CLEAN(2要求已納)·★off LOCAL main 301c1d84·measure-sensitive] spec=2026-07-21-facility-scoring-weaponsmith-demand.md。根:deficit 語意不對稱(workshop demand-responsive 封頂1.0 vs weaponsmith armed_ratio-only 無視武器 demand→60樣本僅中1)。blueprint 選①(納武器市場 demand,軍火商路,armed_ratio 自衛留)。修:①★DRY 抽 shared helper `_generic_res_deficit(state,team,outputs,use_demand,agg_mode,lv)` 從 _facility_deficit A 類分支抽出→A 類 dispatch 和 weaponsmith market 都呼(禁平行重寫)②_deficit_weaponsmith 兩路徑 max(self_defense=clampf(0.6-armed_ratio)×militancy 留 / market=_generic_res_deficit(weapon_melee_low,weapon_ranged_low,use_demand=true,min_per_res)×_commercial_inclination(貪婪/商業技能,人格穿秤非flat))。★②workshop 連續 NOT 本 slice(拆 follow-up,known_issues)。TDD 4型+A類既有facility byte-identical(helper抽出純重構)。gate/headless 0new/determinism 2跑byte-identical 無RNG。★measure=facility-build-by-type(weaponsmith 0→?)+weapon產出+score分布+doom-delta(seed1337/42)+8config,帶§④b樣本(用 Probe.bump_sample)。不需QA(blueprint:formula事實)。task=systems+reviewer。做完→to:measurer。"
---

# dispatch：facility-scoring weaponsmith 納武器 demand（R² CLEAN，2 要求已納）

spec：`docs/superpowers/specs/2026-07-21-facility-scoring-weaponsmith-demand.md`。reviewer R² 2 設計要求（DRY helper + 拆 ②）**已納入 spec**。blueprint 選①授權（軍火商路，綜合發展模型商隊追財）。

## ★★ branch base
- **off LOCAL main `301c1d84`**（禁 origin）。pre-push hook 已裝。

## 修 2 部（本 slice = ① only，② 拆 follow-up）
### A. ★DRY：抽 shared helper（reviewer ③）
從 `_facility_deficit` 的 A 類分支（`min_per_res`/`pooled_sum` + `need_keep` + `demand`(use_demand) + `output_scale`）抽出：
```gdscript
func _generic_res_deficit(state, team, outputs: Array, use_demand: bool, agg_mode: String, lv: Dictionary) -> float:
    # (現 A 類 min_per_res / pooled_sum 邏輯搬此)
```
- `_facility_deficit` A 類 dispatch **改呼此 helper**（`militancy_scaled`/`output_scale` 保留在 dispatch 端 or helper param，你判乾淨）。
- **★A 類既有 facility（workshop/apothecary/armorsmith/smeltery/stable）行為 byte-identical**（純重構抽出，不改語意）。

### B. weaponsmith 兩路徑 max
```gdscript
func _deficit_weaponsmith(state, team, _tile, lv) -> float:
    var self_defense: float = clampf(0.6 - team.armed_anon_ratio, 0.0, 1.0) * _militancy(team, lv)   # 自衛路留
    var market: float = _generic_res_deficit(state, team, ["weapon_melee_low", "weapon_ranged_low"], true, "min_per_res", lv) \
        * _commercial_inclination(team, lv)   # ★軍火商路
    return clampf(maxf(self_defense, market), 0.0, 1.0)
```
- **`_commercial_inclination`**：`clampf(貪婪×W1 + 商業技能×W2, 0, 1)`（TEST VALUE 權重；人格穿秤非 flat）。商業技能=`team leader.skills.get("商業"...)` 或既有讀法（查同檔慣例）。
- signature：`_deficit_weaponsmith` 現簽名 `(_state, team, _tile, lv)` → state 需真傳（market 讀 demand 需 state），改 `(state, team, _tile, lv)`。

## ★② NOT 本 slice
workshop demand 連續正規化 = **拆 follow-up**（known_issues「workshop demand-deficit 封頂」）。本 slice 別碰 workshop（reviewer：綁一起 conflate goods measure）。

## 驗收
- **TDD 4 型**：①高武器 demand+商業人格→deficit 高 ②武裝不足+militaristic→self_defense ③demand=0+武裝足+低商業→0 ④max 無 double-count。**+ A 類既有 facility byte-identical**（helper 純重構）。
- **gate** PASS / **headless** 0 new / **determinism** 2 跑 byte-identical（無 RNG）。
- **★measure（→measurer，behavior-sensitive，帶 §④b 樣本用 `Probe.bump_sample`）**：facility-build-by-type（weaponsmith 0→?）+ weapon 產出（weapon_melee_low 池）+ weaponsmith vs workshop score 分布 + doom-delta（seed1337/42）+ 8 config sanity。**不需 QA**（blueprint：formula 事實）。

## 完成判定 = systems + reviewer。做完 → to:measurer。
