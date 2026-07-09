# 照妖鏡 #1 Spec — combat 潰退門檻 → 膽量（死常數人格化首刀）

- from: systems
- 工單: `docs/superpowers/handbacks/2026-07-09-blueprint-to-systems-zhaoyaojing-direction.md`（藍圖 WHAT；並行 A2c-2）
- 願景: decision-side 死常數 → 溶進人格；每刀=一個可證湧現（照妖鏡照出個體差異）

## 首刀選定（系統選，符藍圖三準則）
**`COMBAT_ABANDON_THRESHOLD = 0.2`**（`npc_combat_system.gd:8`，readiness ≤ 此 → `_force_retreat`，:197-201）。
- **孤立✓**：純 combat 結算內，不卡未解 arc（≠掠奪門檻卡三閘軍事化死鎖）。
- **湧現清✓**：同戰局勇者血戰到底 vs 怯者早逃 = 不同結局，戲感直觀。
- **可量✓**：潰退率 by 膽量、平均戰鬥回合數、勝負翻盤——full_probe 探針易加。
= 藍圖傾向的首刀，系統確認採納。

## 設計（人格化，非刪常數=換家）
### D1. 膽量導出（連續 term，非新 band 判斷器）
`courage = clampf(0.5 + (好戰 - 慎重) * 0.5, 0.0, 1.0)`——既有 leader values 導出（好戰高/慎重低→勇；反之→怯），**零新 enum/classifier**（守 `01_architect` judge 盤點：淨判斷器數不升）。

### D2. 門檻人格化（spread 非 shift，均值保 0.2）
```gdscript
# npc_combat_system.gd：flat COMBAT_ABANDON_THRESHOLD 0.2 → per-team 膽量調製
const ABANDON_THRESHOLD_BASE: float = 0.2      # 均值（保 aggregate 潰退傾向）
const ABANDON_COURAGE_SPREAD: float = 0.16     # TEST VALUE：膽量調幅（勇 0.12→怯 0.28）
static func _abandon_threshold(state, team) -> float:
    var ldr = state.persons.get(team.leader_id)
    if ldr == null: return ABANDON_THRESHOLD_BASE
    var martial = float(ldr.values.get("好戰", 0.5))
    var caution = float(ldr.values.get("慎重", 0.5))
    var courage = clampf(0.5 + (martial - caution) * 0.5, 0.0, 1.0)
    # 勇(courage→1)→門檻低(晚逃,血戰)；怯(→0)→門檻高(早逃)。均值(courage=0.5)=BASE。
    return ABANDON_THRESHOLD_BASE + (0.5 - courage) * ABANDON_COURAGE_SPREAD
```
- `:197/200` `a.readiness <= COMBAT_ABANDON_THRESHOLD` → `<= _abandon_threshold(state, a)`（各隊自算）。
- **均值守恆**：courage 對稱分布時平均門檻=0.2 → aggregate 潰退傾向不變，只**攤開個體差異**（憲法「同 margin 由人格調非全域壓平」）。

## 觸及檔
| 檔 | 改點 |
|---|---|
| `scripts/simulation/npc_combat_system.gd` | flat `COMBAT_ABANDON_THRESHOLD` → `ABANDON_THRESHOLD_BASE`+`ABANDON_COURAGE_SPREAD`+`_abandon_threshold(state,team)`；:197/200 改各隊自算 |
| `scripts/debug/warring_harness.gd` + npc_combat | 探針：`rout.total`/平均回合數 + **★`rout.readiness_at_retreat_by_courage_bucket`（reviewer 補，更直接）**：`_force_retreat` 命中瞬間（:197/200）記該隊 `readiness`，依 courage 分高/中/低三桶 → 勇者桶應集中低 readiness（撐到快死才退）、怯者桶較高（早退）=直接證驗收線1 因果（比純「誰退了」證據力強） |

**不碰**：`_try_retreat`(:205 機率撤，另刀候選)、MORALE_CASCADE_THRESHOLD、傷亡率、`_force_retreat` 機制、其他常數。

## ★呈報藍圖 sign-off（改玩家可見潰退率分布，鎖 spec 前）
潰退**均值保 0.2**（aggregate 不變），但**個體潰退時機隨膽量攤開**（勇者晚逃/怯者早逃=玩家可見戲感變）。願景=正是要這湧現。**請 blueprint 確認願景對齊**（spread=0.16 量級是否合意，或要更誇張/更收斂）→ 放行往下。

## 驗收線（藍圖判，full_probe 3 seed 1337/42/7）
1. **人格差異出現**（湧現證）：`rout.readiness_at_retreat_by_courage_bucket` 顯勇者桶潰退 readiness < 怯者桶（門檻真攤開，直接因果證）；同戰局不同膽量 leader 結局分化。
2. **aggregate 保（★reviewer：待驗假設非形式保證）**：總潰退率/平均戰鬥回合數跨 seed 不系統性偏移。**★必查 aggregate 潰退率 vs baseline 對照**（好戰/慎重 archetype 分布不對稱 → 均值可能非純守恆而 shift；若真 shift 顯著 → 回 D2 median-center 或報 blueprint 接受小 shift）。不能只看 bucket 內分布漏看 aggregate。
3. 憲法/framework/sanity 綠。
4. 相關≠因果：若某戰局指標變，characterize 是膽量攤開真因 vs seed 噪音。

## 流程（無斷點自動鏈）
spec → **blueprint sign-off（願景對齊,此信）** → reviewer → 下游（可 LG `--from-impl`）→ full_probe 3 seed → blueprint 判。
