# 封建財政 / 公庫經濟 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 一般稅自動進公庫 + 建造扣公庫（本地）+ 特別稅改造 + 乞食慷慨光譜 + 兩稅獨立不滿。解 W4（leader 行為性貧窮）+ 製造貧富分化。

**Spec:** `docs/superpowers/specs/2026-06-13-fief-economy-design.md`

**Verified facts:**
- `resource_system.collect_resources`（:34）→ `_collect_from_tile`（:153）直接 mutate `team.resources`；food/material 進私產，ore/mounts/製造成品進 public_storage（:174-185）
- `OUTPOST_STORAGE_CAP`（outpost_system :135 民 200/500/1500、軍 300/800/2500）+ `_get_storage_cap`（:143）— food/material/goods 走 fallback arr，**cap 已涵蓋，不需新增**
- `outpost_system._can_afford`（:594）/`_deduct_cost`（:602）**只讀寫 team.resources**；callers：`start_build`（:312/:325-329）、`start_upgrade_level`（:341/:348-351）、`_begin_facility_construction`（:378）、`start_upgrade_facility`（:363）
- `faction_ai._fund_subteam_cost`（:1481）：owner.resources 補差額給 sub.resources
- `_resolve_tribute`（interaction :407，特別稅）：PRODUCE 居民 tax_rate 轉 food/material/goods/coin 給 collector，已有 unrest（rate>0.5 unrest+1 + stress/loyalty/fear :428-443）；觸發 = `徵收` task 同格
- `徵收` goal 觸發 `_update_faction_goals`（faction_ai :574-579，食物驅動+週期）；派工 :650-665（`DISPATCH_DIST_THRESHOLD`=2）
- `_resolve_aid_request`（interaction :809，乞食）：`give = min(need, surplus × give_score)`；`AID_RESERVE_DAYS`=14（:61）；`give_score = honor + rep − greed×0.5 − annoyance`（:833）
- `TeamData.tax_rate`（:52 預設 0.3）；`unrest_turns` 既有
- 測試：`.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`

---

## Task 1: 一般稅自動進公庫

**Files:**
- Modify: `scripts/simulation/resource_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 失敗測試**

```gdscript
func _test_normal_tax_to_vault() -> void:
	print("--- Fief Task1: 一般稅自動進公庫 ---")
	# 居民團在自家 outpost(owner=自己) 採集 food/material
	# 採集後：tax_rate 比例進 tile.public_storage、私產扣對應量
	# 守恆：私產減量 == 公庫增量
	# ...
	print("Fief Task1a OK")

func _test_normal_tax_owner_vault() -> void:
	# 採集團 != tile owner → 稅進 owner 的 tile 公庫（採集者私產扣稅）
	# ...
	print("Fief Task1b OK")

func _test_normal_tax_vault_cap() -> void:
	# 公庫達 OUTPOST_STORAGE_CAP → 稅金不溢出（多的留採集者私產）
	# ...
	print("Fief Task1c OK")
```

- [ ] **Step 2: 實作**

`_collect_from_tile` 改累積 gained，回傳給 caller；或在 `collect_resources` 內收集後課稅。最小改：`_collect_from_tile` 末尾對 NORMAL_TAX_RES 即時課稅（採集所得部分撥公庫）。

```gdscript
const NORMAL_TAX_RES: Array = ["food", "material", "goods"]

# _collect_from_tile 內，gain 加進 team.resources 後（非 PUBLIC_RESOURCES 分支）：
# 對 food/material/goods 即時課一般稅 → 腳下「team 所在 tile」owner 的公庫
# 注意：src_tile 可能是鄰格（L3 採集），稅一律進「team 站立 tile」(dst) 的公庫
```

實作放 `collect_resources` 尾端最清晰（拿到 team 站立 tile）：

```gdscript
func _apply_normal_tax(state: WorldState, team: TeamData, tile: HexTileData,
		gained: Dictionary) -> void:
	if tile.outpost_level == 0: return
	var owner: TeamData = state.teams.get(tile.outpost_owner)
	var rate: float = float(owner.tax_rate) if owner != null else float(team.tax_rate)
	var os := OutpostSystem.new()
	for res in NORMAL_TAX_RES:
		var g: float = float(gained.get(res, 0))
		if g <= 0.0: continue
		var tax: float = g * rate
		var cap: float = os._get_storage_cap(tile, res)
		var cur: float = float(tile.public_storage.get(res, 0))
		var space: float = maxf(cap - cur, 0.0)
		var actual: float = minf(tax, space)          # cap 滿 → 多的留私產
		team.resources[res] = float(team.resources.get(res, 0)) - actual
		tile.public_storage[res] = cur + actual
```

`_collect_from_tile` 需回報本次 gain（改回傳 Dictionary 或傳入累加 dict）；`collect_resources` 聚合本格+鄰格 gain 後呼叫 `_apply_normal_tax`（稅進站立 tile）。

- [ ] **Step 3: 跑 + Commit**

```powershell
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
git add scripts/simulation/resource_system.gd scripts/debug/headless_test.gd
git commit -m "feat(fief): 一般稅自動進公庫 (採集 tax_rate 撥 owner 公庫) (Task 1)"
```

---

## Task 2: 建造扣公庫（本地優先）

**Files:**
- Modify: `scripts/simulation/outpost_system.gd`, `scripts/simulation/faction_ai_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_build_from_vault() -> void:
	# tile 公庫 material 足、施工團私產 0 → start_build 成功、扣公庫
	# ...
	print("Fief Task2a OK")

func _test_build_vault_then_pocket() -> void:
	# 公庫不足、私產補足 → 公庫扣光 + 私產補差額
	# ...
	print("Fief Task2b OK")

func _test_build_local_only() -> void:
	# 他格公庫不被扣（只動施工團腳下 tile）
	# ...
	print("Fief Task2c OK")
```

- [ ] **Step 2: 改 `_can_afford`/`_deduct_cost` 簽章吃 tile**

```gdscript
func _can_afford(team: TeamData, tile: HexTileData, cost: Dictionary) -> bool:
	for res in cost:
		if res == "ticks": continue
		var avail: float = float(tile.public_storage.get(res, 0)) \
			+ float(team.resources.get(res, 0))
		if avail < float(cost.get(res, 0)): return false
	return true

func _deduct_cost(team: TeamData, tile: HexTileData, cost: Dictionary) -> void:
	for res in cost:
		if res == "ticks": continue
		var need: float = float(cost.get(res, 0))
		if need <= 0.0: continue
		var from_vault: float = minf(need, float(tile.public_storage.get(res, 0)))
		tile.public_storage[res] = float(tile.public_storage.get(res, 0)) - from_vault
		var rem: float = need - from_vault
		if rem > 0.0:
			team.resources[res] = maxf(float(team.resources.get(res, 0)) - rem, 0.0)
```

所有 caller 傳 tile：`start_build`（:325-329）、`start_upgrade_level`（:348-351）、`_begin_facility_construction`（:378 內 cost 檢查/扣款）、`start_upgrade_facility`。各處已有 `tile` 區域變數。

- [ ] **Step 3: `_fund_subteam_cost` 改公庫優先**

```gdscript
# owner 公庫足 → 子隊不需補（子隊到 tile 後 _deduct_cost 自會扣公庫）
# 僅當「公庫 + 子隊私產」不足時，owner 私產補差額
func _fund_subteam_cost(owner_team: TeamData, sub: TeamData, tile: HexTileData,
		cost: Dictionary) -> void:
	for k in cost:
		if k == "ticks": continue
		var have: float = float(tile.public_storage.get(k, 0)) + float(sub.resources.get(k, 0))
		var need: float = maxf(float(cost[k]) - have, 0.0)
		if need <= 0.0: continue
		var transfer: float = minf(need, float(owner_team.resources.get(k, 0)))
		sub.resources[k] = float(sub.resources.get(k, 0)) + transfer
		owner_team.resources[k] = float(owner_team.resources.get(k, 0)) - transfer
```

caller 傳目標 tile。

- [ ] **Step 4: 跑 + Commit**

```powershell
git add scripts/simulation/outpost_system.gd scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(fief): 建造扣公庫優先 (本地) + _fund_subteam_cost 改公庫 (Task 2)"
```

---

## Task 3: 特別稅改造（徵收 + E 子團門檻）

**Files:**
- Modify: `scripts/simulation/interaction_system.gd`, `scripts/simulation/faction_ai_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_special_tax_heavier() -> void:
	# _resolve_tribute 抽量 = tax_rate × SPECIAL_TAX_MULT（>一般稅率）
	# 進 collector(leader) 口袋
	# ...
	print("Fief Task3a OK")

func _test_special_tax_war_trigger() -> void:
	# 野心/好戰高 leader → 非缺糧也觸發 徵收 goal（戰爭基金）
	# ...
	print("Fief Task3b OK")
```

- [ ] **Step 2: 實作**

`_resolve_tribute`：rate 改 `payer.tax_rate × SPECIAL_TAX_MULT`（const 1.5 TEST VALUE）。抽對象沿用（PRODUCE 居民），目標進 collector.resources（leader 口袋，應急/戰爭）。

`_update_faction_goals`（:574-581）加戰爭基金觸發：

```gdscript
# 既有缺糧 + 週期之外，加：野心/好戰高 + coin/material 低 → 戰爭基金特別稅
var war_chest_need: bool = (ambition > 0.6 or martial > 0.6) \
	and float(leader_team.resources.get("material", 0)) < WAR_CHEST_MIN
if food_per_cap < effective_emergency or war_chest_need:
	f.goals.append("徵收")
	...
```

E 子團門檻：`DISPATCH_DIST_THRESHOLD` 徵收路徑（:655）pop 門檻 `>= 4` 放寬至 `>= 3` 或 dist 門檻降，讓 leader 更常派子隊代徵（不必親跑）。

- [ ] **Step 3: 跑 + Commit**

```powershell
git add scripts/simulation/interaction_system.gd scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(fief): 特別稅改造 (徵收 rate×1.5 + 戰爭基金觸發 + 子團門檻放寬) (Task 3)"
```

---

## Task 4: 乞食慷慨光譜（D）

**Files:**
- Modify: `scripts/simulation/interaction_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_aid_hoarder() -> void:
	# 守財奴(貪0.9 義0.1) → reserve≈全部、give≈0
	# ...
	print("Fief Task4a OK")

func _test_aid_saint() -> void:
	# 聖人(義0.9 貪0.1) → give 高、可動 reserve（give_fraction>1）
	# ...
	print("Fief Task4b OK")

func _test_aid_mercy_floor() -> void:
	# 守財奴(honor>0.1) 遇將餓死乞丐 → 給 MIN_MERCY_FOOD
	# honor≈0 真禽獸 → 不給
	# ...
	print("Fief Task4c OK")
```

- [ ] **Step 2: 實作**

`_resolve_aid_request`（:846-851 計算 give 段）改：

```gdscript
const MIN_MERCY_FOOD: float = 0.0   # 由 pop 算，見下；常數佔位
# 留存：個性決定（取代 flat AID_RESERVE_DAYS）
var hoard: float = greed - honor
var reserve_days: float = lerpf(2.0, 60.0, (hoard + 1.0) / 2.0)
var reserve: float = float(target.population) * reserve_days * 2.4
var give_fraction: float = clampf(honor - greed * 0.5 + rep * 0.3 - annoyance, 0.0, 1.2)
var surplus: float = maxf(target_food - reserve, 0.0)
var give: float = minf(need, surplus * give_fraction)
# 人性底線：乞丐將餓死（food < pop×2.4）+ 施主非真禽獸(honor>0.1) → 給最低 1 天份
var beggar_starving: bool = float(beggar.resources.get("food", 0)) \
	< float(beggar.population) * 2.4
if give <= 0.0 and beggar_starving and honor > 0.1:
	give = minf(need, float(beggar.population) * 2.4)   # 1 天份
```

（`greed`/`honor` 取 target_leader.values，:829-830 已有 honor/greed）

- [ ] **Step 3: 跑 + Commit**

```powershell
git add scripts/simulation/interaction_system.gd scripts/debug/headless_test.gd
git commit -m "feat(fief): 乞食慷慨光譜 (守財奴/聖人兩極 + 人性底線) (Task 4)"
```

---

## Task 5: 兩稅獨立不滿

**Files:**
- Modify: `scripts/simulation/resource_system.gd`（一般稅慢性）, `scripts/simulation/interaction_system.gd`（特別稅尖峰強化）
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_normal_tax_chronic_unrest() -> void:
	# tax_rate > tolerance → 課稅 cadence 居民 stress 緩增；< tolerance → 無
	# tolerance = 0.3 + 順從×0.2 + 義氣×0.1 − 野心×0.2
	# ...
	print("Fief Task5a OK")

func _test_special_tax_spike() -> void:
	# 特別稅搜刮比例越大 → stress 尖刺越高；連續特別稅 annoyance 疊加
	# ...
	print("Fief Task5b OK")
```

- [ ] **Step 2: 實作**

一般稅慢性（`_apply_normal_tax` 內，課稅後對居民 leader+named）：

```gdscript
var lp: PersonData = state.persons.get(team.leader_id)
if lp != null:
	var submit: float = float(lp.values.get("順從", 0.5))
	var honor_v: float = float(lp.values.get("義氣", 0.5))
	var amb: float = float(lp.values.get("野心", 0.5))
	var tolerance: float = 0.3 + submit * 0.2 + honor_v * 0.1 - amb * 0.2
	if rate > tolerance:
		var p_stress: float = (rate - tolerance) * 0.02
		# 對 team 全 named 施加（含 leader），超久 unrest_turns 緩增
		# ...
```

特別稅尖峰（`_resolve_tribute` 既有 unrest 段 :428-443 強化）：加 `taken_ratio`（本次搜刮 / 居民庫存）→ `stress += taken_ratio × 0.3`；`annoyance`（近期特別稅次數，仿 `_count_recent_begs` 記 memory）疊加。

- [ ] **Step 3: 跑 + Commit**

```powershell
git add scripts/simulation/resource_system.gd scripts/simulation/interaction_system.gd scripts/debug/headless_test.gd
git commit -m "feat(fief): 兩稅獨立不滿 (一般慢性 / 特別尖峰) (Task 5)"
```

---

## Task 6: 整合驗證 + handback

**Files:**
- Create: `docs/superpowers/handbacks/2026-06-13-fief-economy.md`

- [ ] **Step 1: 全測試 + multi + 2 年**

```powershell
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_test.gd > godot_test.log 2>&1
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd > godot_multi.log 2>&1
Get-Content godot_multi.log | Select-String "FacilityStats|CoinAudit|PopSample|公庫|設施完工" | Select-Object -First 30
```

2 年：config max_ticks 21600→172800（**Edit 工具逐檔改，嚴禁 PowerShell -replace 毀中文**），跑完還原。

驗收：
- 公庫累積出現（food/material 公庫存量 > 0）
- **設施建造 > 2 年 baseline（原 ~2 件）** — W4 解
- 貧富分化：各村公庫/私產存量 variance 上升（守財奴村囤、聖人村窮）
- 過度課稅村出現居民 famine（拉弗曲線湧現，非 bug）
- 守恆：coin 等值 delta 0；food/material 總量（私產+公庫+地面）課稅前後守恆
- ALL INVARIANTS PASSED

- [ ] **Step 2: handback + Commit**

```markdown
# Hand Back: 封建財政/公庫經濟
## 實作摘要 / 行為變化（公庫累積、設施建造數 before/after、貧富 variance、課稅自毀案例）/ 守恆驗證 / 待確認（tax_rate/MULT/reserve 參數、W4 是否真解、拉弗曲線觀察）
```

```powershell
git add docs/superpowers/handbacks/2026-06-13-fief-economy.md
git commit -m "docs: fief economy handback (Task 6)"
```
