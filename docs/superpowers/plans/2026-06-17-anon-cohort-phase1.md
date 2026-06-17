# Anon Cohort Phase 1（純模組 + 單元測試）Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 建立 `AnonCohort` 純函數模組（複合鍵 cohort 容器的編解碼 / 增減 / 投影），附完整單元測試，零 team 整合、零行為變更。

**Architecture:** `AnonCohort` 操作一個傳入的 cohort `Dictionary`（鍵 `"tier|health"` → count，稀疏），全 static 純函數。tier 戰鬥/速度/薪資數值沿用既有 `AnonTierSystem.TIER_STATS`（單一來源，不複製）。本 phase **不碰** team_data / 任何系統 —— 只新增模組與測試，後續 phase 才把 storage flip 到此容器。

**Tech Stack:** Godot 4.2.2 GDScript。測試 = `scripts/debug/headless_test.gd` 內 `assert` 函數，註冊於 `_initialize()`，用 `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd` 跑（全綠輸出 `=== DONE ===`，失敗噴 `SCRIPT ERROR` / assertion）。

> **整體藍圖（4 phase，本 plan 只做 Phase 1）**：
> 1. **本 plan** — AnonCohort 純模組 + 單元測試（零整合）。
> 2. team_data storage flip：`anon_cohorts` 變真 storage、`wounded` 轉 getter、所有 `anon_tiers[]=` / `wounded+=` 寫入點改走 cohort 入口、修漏水。
> 3. population getter（無 +wounded）+ combat 解耦（`pop-wounded-named` → `healthy_pop`）+ invariant_audit 公式同步。
> 4. InvariantAudit cohort 自洽網 + invariants.md 規則 + world_generator/存檔遷移。
> 每 phase 各自獨立 plan + 子 session + merge。

**前置（子 session 第一步，強制）：** 依 `docs/process/03_implementer.md`，先建隔離 worktree：
```powershell
git worktree add .worktrees/anon-cohort-phase1 -b feat/anon-cohort-phase1
cd .worktrees/anon-cohort-phase1
```
確認 `git rev-parse --show-toplevel` 指向 `.worktrees/anon-cohort-phase1/` 再開工。

**Baseline 確認：**
```powershell
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
```
Expected: 結尾 `=== DONE ===`，無 `SCRIPT ERROR`。

---

## File Structure

- **Create** `scripts/simulation/anon_cohort.gd` — `class_name AnonCohort`，全 static 純函數模組。唯一職責：cohort dict 的編解碼 / 增減 / 投影。
- **Modify** `scripts/debug/headless_test.gd` — 加 5 個 `_test_anon_cohort_*()` 測試函數 + 在 `_initialize()` 註冊。

`AnonCohort` 介面（本 phase 全部產出）：
```
常數: TIER_ORDER, HEALTH_ORDER
編碼: _key(tier, health) -> String / _parse(key) -> Array
增減: add(cohorts, tier, health, n) / remove(cohorts, tier, health, n) -> int / move(cohorts, ft, fh, tt, th, n) -> int
投影: total(cohorts) -> int / by_health(cohorts, health) -> int / by_tier(cohorts, tier) -> int
數值: avg_combat(cohorts) -> float / avg_speed(cohorts) -> float / total_wage(cohorts) -> float
```

不變量（每個 mutation 維持）：稀疏（count==0 的鍵從 dict 刪除）；count 永不為負；鍵恆為合法 `"tier|health"`。

---

## Task 1: 模組骨架 + 鍵編解碼

**Files:**
- Create: `scripts/simulation/anon_cohort.gd`
- Test: `scripts/debug/headless_test.gd`（加 `_test_anon_cohort_key()` + 註冊）

- [ ] **Step 1: 建模組骨架**

Create `scripts/simulation/anon_cohort.gd`:
```gdscript
class_name AnonCohort

# 匿名人口統一容器：cohorts: Dictionary，鍵 "tier|health" → count（稀疏，只存非零桶）。
# tier 數值沿用 AnonTierSystem.TIER_STATS（單一來源）。全 static 純函數，不持有狀態。

const TIER_ORDER: Array   = ["平民", "新兵", "老兵", "菁英"]
const HEALTH_ORDER: Array = ["healthy", "wounded"]

# ───── 鍵編解碼 ─────

static func _key(tier: String, health: String) -> String:
	return "%s|%s" % [tier, health]

static func _parse(key: String) -> Array:
	return key.split("|")   # [tier, health]
```

- [ ] **Step 2: 寫 failing test**

In `scripts/debug/headless_test.gd`, add function (place near other anon tests, e.g. after `_test_anon_tier_const`):
```gdscript
func _test_anon_cohort_key() -> void:
	assert(AnonCohort._key("老兵", "wounded") == "老兵|wounded", "key 編碼錯")
	var parsed: Array = AnonCohort._parse("老兵|wounded")
	assert(parsed[0] == "老兵" and parsed[1] == "wounded", "key 解析錯: %s" % str(parsed))
	# round-trip 全組合
	for tier in AnonCohort.TIER_ORDER:
		for health in AnonCohort.HEALTH_ORDER:
			var k: String = AnonCohort._key(tier, health)
			var p: Array = AnonCohort._parse(k)
			assert(p[0] == tier and p[1] == health, "round-trip 失敗: %s" % k)
	print("[OK] _test_anon_cohort_key")
```

Register in `_initialize()` (after line `_test_anon_tier_const()`):
```gdscript
	_test_anon_cohort_key()
```

- [ ] **Step 3: 跑測試確認通過**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: 看到 `[OK] _test_anon_cohort_key`，結尾 `=== DONE ===`，無 `SCRIPT ERROR`。
（註：此 task 實作與測試同步，無獨立 red 階段——若 `AnonCohort` 未建會編譯錯，即 red 證明。）

- [ ] **Step 4: Commit**

```bash
git add scripts/simulation/anon_cohort.gd scripts/debug/headless_test.gd
git commit -m "feat(anon): AnonCohort 模組骨架 + 鍵編解碼"
```

---

## Task 2: add / remove / move（稀疏不變量）

**Files:**
- Modify: `scripts/simulation/anon_cohort.gd`
- Test: `scripts/debug/headless_test.gd`（加 `_test_anon_cohort_mutate()` + 註冊）

- [ ] **Step 1: 寫 failing test**

Add to `scripts/debug/headless_test.gd`:
```gdscript
func _test_anon_cohort_mutate() -> void:
	var c: Dictionary = {}
	# add 建鍵
	AnonCohort.add(c, "平民", "healthy", 3)
	assert(c.get("平民|healthy", 0) == 3, "add 後應 3")
	# add 累加同鍵
	AnonCohort.add(c, "平民", "healthy", 2)
	assert(c.get("平民|healthy", 0) == 5, "add 累加應 5")
	# add n<=0 noop
	AnonCohort.add(c, "平民", "healthy", 0)
	AnonCohort.add(c, "平民", "healthy", -4)
	assert(c.get("平民|healthy", 0) == 5, "add 非正數應 noop")
	# remove 回實際移除數，clamp 到現有
	var r1: int = AnonCohort.remove(c, "平民", "healthy", 2)
	assert(r1 == 2 and c.get("平民|healthy", 0) == 3, "remove 2 後應 3")
	var r2: int = AnonCohort.remove(c, "平民", "healthy", 99)
	assert(r2 == 3, "remove 超量應只移除現有 3，實際 %d" % r2)
	# 稀疏：歸零鍵刪除
	assert(not c.has("平民|healthy"), "count 0 鍵應刪除")
	# remove 不存在鍵回 0
	assert(AnonCohort.remove(c, "菁英", "wounded", 5) == 0, "remove 空桶應回 0")
	# move：healthy→wounded
	AnonCohort.add(c, "老兵", "healthy", 4)
	var m: int = AnonCohort.move(c, "老兵", "healthy", "老兵", "wounded", 1)
	assert(m == 1, "move 應移 1")
	assert(c.get("老兵|healthy", 0) == 3 and c.get("老兵|wounded", 0) == 1, "move 後 healthy3 wounded1")
	# move clamp 到來源現有，不夠只移現有
	var m2: int = AnonCohort.move(c, "老兵", "healthy", "老兵", "wounded", 99)
	assert(m2 == 3, "move 超量應只移現有 3，實際 %d" % m2)
	assert(not c.has("老兵|healthy") and c.get("老兵|wounded", 0) == 4, "move 後 healthy 桶空、wounded4")
	print("[OK] _test_anon_cohort_mutate")
```

Register in `_initialize()`:
```gdscript
	_test_anon_cohort_mutate()
```

- [ ] **Step 2: 跑測試確認 fail**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `SCRIPT ERROR`（`add`/`remove`/`move` 尚未定義）。

- [ ] **Step 3: 實作 add/remove/move**

Append to `scripts/simulation/anon_cohort.gd`:
```gdscript
# ───── 增減（維持稀疏 + 非負）─────

static func add(cohorts: Dictionary, tier: String, health: String, n: int) -> void:
	if n <= 0:
		return
	var k: String = _key(tier, health)
	cohorts[k] = int(cohorts.get(k, 0)) + n

static func remove(cohorts: Dictionary, tier: String, health: String, n: int) -> int:
	if n <= 0:
		return 0
	var k: String = _key(tier, health)
	var cur: int = int(cohorts.get(k, 0))
	var removed: int = mini(cur, n)
	var left: int = cur - removed
	if left <= 0:
		cohorts.erase(k)
	else:
		cohorts[k] = left
	return removed

static func move(cohorts: Dictionary, from_tier: String, from_health: String,
		to_tier: String, to_health: String, n: int) -> int:
	var moved: int = remove(cohorts, from_tier, from_health, n)
	add(cohorts, to_tier, to_health, moved)
	return moved
```

- [ ] **Step 4: 跑測試確認通過**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `[OK] _test_anon_cohort_mutate`，結尾 `=== DONE ===`。

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/anon_cohort.gd scripts/debug/headless_test.gd
git commit -m "feat(anon): AnonCohort add/remove/move（稀疏+非負不變量）"
```

---

## Task 3: 計數投影（total / by_health / by_tier）

**Files:**
- Modify: `scripts/simulation/anon_cohort.gd`
- Test: `scripts/debug/headless_test.gd`（加 `_test_anon_cohort_counts()` + 註冊）

- [ ] **Step 1: 寫 failing test**

Add to `scripts/debug/headless_test.gd`:
```gdscript
func _test_anon_cohort_counts() -> void:
	var c: Dictionary = {
		"平民|healthy": 3, "新兵|healthy": 2, "老兵|wounded": 1, "老兵|healthy": 4,
	}
	assert(AnonCohort.total(c) == 10, "total 應 10，實際 %d" % AnonCohort.total(c))
	assert(AnonCohort.by_health(c, "healthy") == 9, "healthy 應 9")
	assert(AnonCohort.by_health(c, "wounded") == 1, "wounded 應 1")
	assert(AnonCohort.by_tier(c, "老兵") == 5, "老兵 跨 health 應 5")
	assert(AnonCohort.by_tier(c, "菁英") == 0, "空 tier 應 0")
	# total == healthy + wounded（投影自洽）
	assert(AnonCohort.total(c) == AnonCohort.by_health(c, "healthy") + AnonCohort.by_health(c, "wounded"),
		"total 應 == healthy + wounded")
	# 空容器
	assert(AnonCohort.total({}) == 0, "空容器 total 0")
	print("[OK] _test_anon_cohort_counts")
```

Register in `_initialize()`:
```gdscript
	_test_anon_cohort_counts()
```

- [ ] **Step 2: 跑測試確認 fail**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `SCRIPT ERROR`（`total`/`by_health`/`by_tier` 未定義）。

- [ ] **Step 3: 實作計數投影**

Append to `scripts/simulation/anon_cohort.gd`:
```gdscript
# ───── 計數投影（純衍生）─────

static func total(cohorts: Dictionary) -> int:
	var s: int = 0
	for k in cohorts:
		s += int(cohorts[k])
	return s

static func by_health(cohorts: Dictionary, health: String) -> int:
	var s: int = 0
	for k in cohorts:
		if _parse(k)[1] == health:
			s += int(cohorts[k])
	return s

static func by_tier(cohorts: Dictionary, tier: String) -> int:
	var s: int = 0
	for k in cohorts:
		if _parse(k)[0] == tier:
			s += int(cohorts[k])
	return s
```

- [ ] **Step 4: 跑測試確認通過**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `[OK] _test_anon_cohort_counts`，結尾 `=== DONE ===`。

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/anon_cohort.gd scripts/debug/headless_test.gd
git commit -m "feat(anon): AnonCohort 計數投影 total/by_health/by_tier"
```

---

## Task 4: 數值投影（avg_combat / avg_speed / total_wage）

沿用 `AnonTierSystem.TIER_STATS`（單一數值來源）。空容器預設對齊現有：`avg_combat→0.1`、`avg_speed→1.0`、`total_wage→0.0`。數值跨 health 加總（v1 wounded 不打折，與現行一致）。

**Files:**
- Modify: `scripts/simulation/anon_cohort.gd`
- Test: `scripts/debug/headless_test.gd`（加 `_test_anon_cohort_stats()` + 註冊）

- [ ] **Step 1: 寫 failing test**

Add to `scripts/debug/headless_test.gd`（數值取自 `AnonTierSystem.TIER_STATS`：平民 combat0.1/speed0.7/wage0.5，菁英 combat0.7/speed1.0/wage2.5）:
```gdscript
func _test_anon_cohort_stats() -> void:
	# 全平民 10（含 1 wounded）：avg_combat 跨 health 加總 = 0.1
	var c1: Dictionary = { "平民|healthy": 9, "平民|wounded": 1 }
	assert(abs(AnonCohort.avg_combat(c1) - 0.1) < 0.0001, "全平民 avg_combat 應 0.1，實際 %f" % AnonCohort.avg_combat(c1))
	assert(abs(AnonCohort.avg_speed(c1) - 0.7) < 0.0001, "全平民 avg_speed 應 0.7")
	assert(abs(AnonCohort.total_wage(c1) - 5.0) < 0.0001, "10×0.5 應 5.0")
	# 全菁英 10
	var c2: Dictionary = { "菁英|healthy": 10 }
	assert(abs(AnonCohort.avg_combat(c2) - 0.7) < 0.0001, "全菁英 avg_combat 應 0.7")
	assert(abs(AnonCohort.total_wage(c2) - 25.0) < 0.0001, "10×2.5 應 25.0")
	# 空容器預設
	assert(abs(AnonCohort.avg_combat({}) - 0.1) < 0.0001, "空 avg_combat 預設 0.1")
	assert(abs(AnonCohort.avg_speed({}) - 1.0) < 0.0001, "空 avg_speed 預設 1.0")
	assert(abs(AnonCohort.total_wage({}) - 0.0) < 0.0001, "空 total_wage 0.0")
	print("[OK] _test_anon_cohort_stats")
```

Register in `_initialize()`:
```gdscript
	_test_anon_cohort_stats()
```

- [ ] **Step 2: 跑測試確認 fail**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `SCRIPT ERROR`（`avg_combat`/`avg_speed`/`total_wage` 未定義）。

- [ ] **Step 3: 實作數值投影**

Append to `scripts/simulation/anon_cohort.gd`:
```gdscript
# ───── 數值投影（沿用 AnonTierSystem.TIER_STATS）─────

static func avg_combat(cohorts: Dictionary) -> float:
	var tot: int = total(cohorts)
	if tot <= 0:
		return 0.1
	var s: float = 0.0
	for k in cohorts:
		var tier: String = _parse(k)[0]
		s += float(cohorts[k]) * float(AnonTierSystem.TIER_STATS[tier]["combat"])
	return s / float(tot)

static func avg_speed(cohorts: Dictionary) -> float:
	var tot: int = total(cohorts)
	if tot <= 0:
		return 1.0
	var s: float = 0.0
	for k in cohorts:
		var tier: String = _parse(k)[0]
		s += float(cohorts[k]) * float(AnonTierSystem.TIER_STATS[tier]["speed"])
	return s / float(tot)

static func total_wage(cohorts: Dictionary) -> float:
	var w: float = 0.0
	for k in cohorts:
		var tier: String = _parse(k)[0]
		w += float(cohorts[k]) * float(AnonTierSystem.TIER_STATS[tier]["base_wage"])
	return w
```

- [ ] **Step 4: 跑測試確認通過**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `[OK] _test_anon_cohort_stats`，結尾 `=== DONE ===`。

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/anon_cohort.gd scripts/debug/headless_test.gd
git commit -m "feat(anon): AnonCohort 數值投影 avg_combat/avg_speed/total_wage"
```

---

## Task 5: 收尾驗證 + hand-back

**Files:**
- Create: `docs/superpowers/handbacks/2026-06-17-anon-cohort-phase1.md`

- [ ] **Step 1: 全測試綠 + class 快取**

```powershell
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
```
Expected: 4 個 `[OK] _test_anon_cohort_*`，結尾 `=== DONE ===`，無 `SCRIPT ERROR`。

- [ ] **Step 2: 寫 hand-back**

依 `docs/process/03_implementer.md` 格式寫 `docs/superpowers/handbacks/2026-06-17-anon-cohort-phase1.md`：
- 實作摘要：新增 `anon_cohort.gd`（10 介面）+ 4 測試函數。
- 與 spec 差異（若有）。
- 連動風險：本 phase 零整合（無系統呼叫 AnonCohort）→ 無已知連動風險。下一步 Phase 2 才 flip storage。
- 待主 session 確認：Phase 2 storage flip 的切換策略（big-bang flip vs 漸進橋接）。

- [ ] **Step 3: Commit + push + 回報**

```bash
git add docs/superpowers/handbacks/2026-06-17-anon-cohort-phase1.md
git commit -m "docs: anon cohort phase1 hand-back"
git push -u origin feat/anon-cohort-phase1
```
回報分支給主 session。finishing-a-development-branch 選單彈出時選 Option 3（Keep as-is），主 session 負責 merge。

---

## Self-Review

**Spec coverage（對 `2026-06-17-anon-cohort-model-design.md`）：** 本 plan 只涵蓋 spec「階段 1」的純模組部分（容器 + _key/_parse + add/move/remove + 投影 getter）。spec Phase 1 還提「team_data 加 anon_cohorts、wounded 轉 getter、AnonTierSystem 橋接」—— 刻意延後到 Phase 2（storage flip），因 GDScript getter 唯讀會一次 break 所有寫入點，與「零整合零風險」的 Phase 1 目標衝突。Phase 1 純模組先建好被測穩的地基，Phase 2 才整合。此拆分已在 plan 藍圖註明。

**Placeholder scan：** 無 TBD；每步含完整 code 與確切指令、預期輸出。

**Type consistency：** 介面命名跨 task 一致（`add/remove/move/total/by_health/by_tier/avg_combat/avg_speed/total_wage`）；`remove`/`move` 回 int，`add` 回 void，與測試一致。TIER_STATS 取用鍵（combat/speed/base_wage）對齊 `anon_tier_system.gd:9-14`。
