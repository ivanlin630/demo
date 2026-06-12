# 經濟一致性修正 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task.
> L2 批次（root cause 已調查：製造業投入不隨產量縮放 → 每單位成品成本 24-900× 售價，全面虧本）

**Goal:** 製造投入隨產量縮放（配方 in 改 per-unit 語意）+ 配方表重校 + 全資源定價重算（價 ≥ 原料 ×1.2）+ 飢荒不對稱 clamp。

**Verified facts:**
- `manufacturing_system._run_recipe_group`（:121-141）：扣全額 `recipe["in"]`，產 `worker_rate × rate` — **bug 核心**
- `RECIPE_GROUPS`（:41-66）/ `RATES`（:19）/ `TARGET_PER_POP`（:30）
- `interaction_system.BASE_PRICE`（:4-23，18 項，缺 herb/mounts/wagons）/ `TARGET_PER_POP`（:24-43）/ `_local_value`（:517-524，sr clamp [-0.5, 1.0]）
- A/B 期既有測試斷言固定扣帳量（`_test_wagon_recipe` 等）— 需改 per-unit 語意
- 測試：`.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`

---

## Task 1: 投入縮放 + 配方 per-unit 重校

**Files:**
- Modify: `scripts/simulation/manufacturing_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 失敗測試**

```gdscript
func _test_recipe_input_scaling() -> void:
	print("--- Econ Task1: 投入隨產量縮放 ---")
	# Setup: 工坊 tile + team，material 100，worker_rate 已知（pop/skill 固定）
	# 跑一次 tools 配方：q = worker_rate × TOOLS_RATE
	# assert 扣 material ≈ 4.0 × q（非固定 4.0）
	# assert 產出 tools ≈ q
	# 單位經濟：每 1 tools 恰耗 4 mat
	# ...
	print("Econ Task1 OK")
```

- [ ] **Step 2: 改 `_run_recipe_group`**

```gdscript
	for entry in order:
		var recipe: Dictionary = recipes[entry.idx]
		var rate: float = float(RATES[recipe["rate_const"]])
		var q: float = worker_rate * rate          # 本 tick 產量
		if q <= 0.0: continue
		if not _can_consume_scaled(team, recipe["in"], q):
			continue
		for res in recipe["in"]:
			team.resources[res] = float(team.resources.get(res, 0)) \
				- float(recipe["in"][res]) * q     # 投入隨產量縮放（in = 每單位成品原料）
		_add_output(team, tile, recipe["out"], q)
		return recipe["out"]
	return ""

func _can_consume_scaled(team: TeamData, inputs: Dictionary, q: float) -> bool:
	for res in inputs:
		if float(team.resources.get(res, 0)) < float(inputs[res]) * q:
			return false
	return true
```

刪舊 `_can_consume`（或保留給他處 caller，grep 確認）。

- [ ] **Step 3: 配方表 per-unit 重校**

```gdscript
const RECIPE_GROUPS: Dictionary = {
	"manufacturing_level": [
		{ "out": "goods",  "rate_const": "GOODS_RATE",  "in": { "material": 3.0 } },
		{ "out": "tools",  "rate_const": "TOOLS_RATE",  "in": { "material": 4.0 } },
		{ "out": "arrows", "rate_const": "ARROWS_RATE", "in": { "material": 0.8 } },
		{ "out": "goods",  "rate_const": "CRAFT_RATE",  "in": { "gem": 0.25, "material": 1.0 } },  # 工藝品 = gem 觸媒高效路線
		{ "out": "wagons", "rate_const": "WAGON_RATE",  "in": { "horses": 1.0, "material": 6.0, "tools": 1.0 } },
	],
	"apothecary_level": [
		{ "out": "medicine", "rate_const": "MEDICINE_RATE", "in": { "herb": 2.0 } },
	],
	"smelter_level": [
		{ "out": "ore_steel", "rate_const": "SMELT_RATE", "in": { "ore_iron": 2.0, "material": 1.0 } },
	],
	"weaponsmith_level": [
		{ "out": "weapon_melee_low",   "rate_const": "MELEE_LOW_RATE",   "in": { "ore_iron": 2.0, "material": 3.0 } },
		{ "out": "weapon_ranged_low",  "rate_const": "RANGED_LOW_RATE",  "in": { "ore_iron": 2.0, "material": 4.0 } },
		{ "out": "weapon_melee_high",  "rate_const": "MELEE_HIGH_RATE",  "in": { "ore_steel": 2.0, "material": 3.0 } },
		{ "out": "weapon_ranged_high", "rate_const": "RANGED_HIGH_RATE", "in": { "ore_steel": 2.0, "material": 4.0 } },
	],
	"armorsmith_level": [
		{ "out": "armor_low",  "rate_const": "ARMOR_LOW_RATE",  "in": { "ore_iron": 2.0, "material": 2.0 } },
		{ "out": "armor_high", "rate_const": "ARMOR_HIGH_RATE", "in": { "ore_steel": 2.0, "material": 3.0 } },
	],
}
```

（in 值 = 每單位成品原料 — 多數沿用面值，arrows/工藝品 改低）

- [ ] **Step 4: 修 A/B 期既有配方測試**

grep `_test_workshop_recipes / _test_armorsmith_recipes / _test_wagon_recipe / _test_medicine_recipe / _test_recipe_deficit_ordering` — 斷言改 per-unit 語意（扣帳 = in × q）。

- [ ] **Step 5: 跑 + Commit**

```powershell
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
git add scripts/simulation/manufacturing_system.gd scripts/debug/headless_test.gd
git commit -m "fix(manufacturing): 投入隨產量縮放 (per-unit 配方語意) (Task 1)"
```

---

## Task 2: 全表定價重算 + 補 3 價 + 飢荒 clamp

**Files:**
- Modify: `scripts/simulation/interaction_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_price_covers_input_cost() -> void:
	print("--- Econ Task2a: 價 ≥ 原料 ×1.2 ---")
	# 程式化驗證：對每條配方算 input value（Σ in × BASE_PRICE）
	# assert BASE_PRICE[out] >= input_value × 1.2（工藝品路線豁免 — 高效路線本就有利）
	# ...
	print("Econ Task2a OK")

func _test_famine_price_spike() -> void:
	# food stock 0 → local_value = base × 5（生存品不對稱）
	# material stock 0 → base × 2（一般品不變）
	# 過剩下限 0.5× 兩者皆同
	# ...
	print("Econ Task2b OK")
```

- [ ] **Step 2: BASE_PRICE 重算**

```gdscript
const BASE_PRICE: Dictionary = {
	"food":               2.0,
	"material":           4.0,
	"herb":               3.0,   # 新
	"goods":             15.0,   # 12 原料 + 利
	"gem":               20.0,
	"ore_gold":          10.0,
	"ore_silver":         5.0,
	"ore_iron":           8.0,
	"ore_steel":         24.0,   # in 20
	"weapon_melee_low":  34.0,   # in 28
	"weapon_melee_high": 72.0,   # in 60
	"weapon_ranged_low": 38.0,   # in 32
	"weapon_ranged_high": 76.0,  # in 64
	"tools":             20.0,   # in 16
	"arrows":             4.0,   # in 3.2
	"armor_low":         30.0,   # in 24
	"armor_high":        72.0,   # in 60
	"horses":            15.0,
	"mounts":            45.0,   # 新：horses + 草料 + 軍設施 margin
	"wagons":            70.0,   # 新：in 59
	"medicine":          12.0,   # in 6
}
```

`TARGET_PER_POP` 加：`"herb": 1.0, "mounts": 0.2, "wagons": 0.2`（interaction 與 manufacturing 兩份 dict 同步——或抽共用 const，sub 判斷最小改法）。

- [ ] **Step 3: 飢荒不對稱 clamp**

```gdscript
const SURVIVAL_GOODS: Array = ["food", "medicine"]

func _local_value(team: TeamData, res: String) -> float:
	if not BASE_PRICE.has(res):
		return 0.0
	var pop: float    = maxf(float(team.population), 1.0)
	var stock: float  = float(team.resources.get(res, 0))
	var target: float = pop * float(TARGET_PER_POP.get(res, 1.0))
	var sr_max: float = 4.0 if res in SURVIVAL_GOODS else 1.0   # 生存品饑荒價最高 5×
	var sr: float     = clampf((target - stock) / maxf(target, 1.0), -0.5, sr_max)
	return float(BASE_PRICE[res]) * (1.0 + sr)
```

注意：sr 公式 `(target-stock)/target` 上限自然 ≤ 1（stock ≥ 0），生存品要破 1 需改分子 — 改用 `(target - stock) / maxf(stock, target * 0.1)`？**不對 — 保持簡單**：sr 公式改為短缺比例放大版：

```gdscript
	var shortage: float = (target - stock) / maxf(target, 1.0)   # ≤ 1.0
	if res in SURVIVAL_GOODS and shortage > 0.5:
		# 短缺過半 → 急速攀升：0.5→1.0 區間映射 sr 1.0→4.0
		shortage = 1.0 + (shortage - 0.5) * 6.0
	var sr: float = clampf(shortage, -0.5, 4.0 if res in SURVIVAL_GOODS else 1.0)
```

（stock=0 → shortage 1.0 → 映射 4.0 → 價 5×；stock=半 target → 1.0 → 2×；一般品維持舊行為）

- [ ] **Step 4: 跑 + Commit**

```powershell
git add scripts/simulation/interaction_system.gd scripts/debug/headless_test.gd
git commit -m "feat(econ): 全表定價重算 + herb/mounts/wagons 補價 + 飢荒不對稱 clamp (Task 2)"
```

---

## Task 3: 整合驗證 + handback

**Files:**
- Create: `docs/superpowers/handbacks/2026-06-12-econ-coherence.md`

- [ ] **Step 1: 跑全測試 + multi**

```powershell
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_test.gd > godot_test.log 2>&1
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd > godot_multi.log 2>&1
Get-Content godot_multi.log | Select-String "Manufacture|Market|MaterialStats" | Group-Object | Select-Object Count, Name | Sort-Object Count -Descending | Select-Object -First 12
```

驗收：
- 製造仍發生（投入縮放後原料門檻變低 — q 小時扣量小，**預期製造次數上升**）
- 單位經濟正：抽查 log 任一配方 — 原料價值 < 產出價值
- coin 等值守恆 delta 0（價格不影響守恆，但驗證沒破）
- ALL INVARIANTS PASSED

- [ ] **Step 2: handback + Commit**

```markdown
# Hand Back: 經濟一致性
## 實作摘要 / 行為變化（製造次數對比、單位經濟抽查）/ 驗證 / 待確認（價格表 tune、武器漲價對 AI 行為影響觀察）
```

```powershell
git add docs/superpowers/handbacks/2026-06-12-econ-coherence.md
git commit -m "docs: econ coherence handback (Task 3)"
```
