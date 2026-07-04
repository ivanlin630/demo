# Anon Cohort Phase 2a（storage flip：anon_tiers → anon_cohorts）Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 把 `team.anon_tiers`（`{tier: count}`）的儲存換成 `team.anon_cohorts`（`{"tier|health": count}`，本 phase 全部 health=`"healthy"`），AnonTierSystem 內部改走 `AnonCohort`，public API 與行為**位元不變**。

**Architecture:** 大 big-bang 但**零行為變更**：2a 不啟用 wounded 維度（`wounded` int 欄位原樣保留），所有 anon 存進 `"tier|healthy"` 桶 = 與舊 `anon_tiers[tier]` 一對一。`anon_tiers` 改成 team_data 的**唯讀 computed getter**（回 4-tier breakdown），所有「讀」零改、只改「寫」入點。AnonTierSystem 變成 cohort 的 team-facing facade。

**Tech Stack:** Godot 4.2.2 GDScript。回歸網 = 既有 `scripts/debug/headless_test.gd` 全套（含 ~14 個 anon_tiers 斷言）+ multi sanity `scripts/debug/game_sim_multi.gd`。跑：`.\tools\godot.ps1 --headless --script <path>`，綠 = `=== DONE ===` 無 `SCRIPT ERROR`。

> **整體藍圖**：Phase 1 ✅（AnonCohort 純模組已 merge）。**本 plan = Phase 2a**（storage flip）。後續 2b（wounded 折入 health 維度）、2c（population getter）、Phase 4（audit 網 + docs + 存檔）各自獨立 plan。

**前置（子 session 第一步，強制）：** 依 `docs/process/03_implementer.md`：
```powershell
git worktree add .worktrees/anon-cohort-phase2a -b feat/anon-cohort-phase2a
cd .worktrees/anon-cohort-phase2a
```
確認 `git rev-parse --show-toplevel` 指向該 worktree 再開工。

**Baseline 確認：**
```powershell
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
```
Expected: 結尾 `=== DONE ===`，無 `SCRIPT ERROR`，含 4 個 `[OK] _test_anon_cohort_*`（Phase 1 已 merge）。

> **⚠ 此 phase 是原子型別替換**：移除 `anon_tiers` 儲存後，所有舊寫入點同時失效。Task 1–3 必須全落地後 headless 才會綠（中途不可執行屬正常）。Task 4 才是回歸驗證點。子 session 照此順序做完再驗。

---

## File Structure

| 檔案 | 動作 | 職責 |
|---|---|---|
| `scripts/data/team_data.gd` | Modify | 移除 `anon_tiers` 儲存欄位；加 `anon_cohorts` 儲存；加唯讀 `anon_tiers` getter（4-tier breakdown 回相容） |
| `scripts/simulation/anon_tier_system.gd` | Modify | 全函數內部改走 `AnonCohort`（操作 `team.anon_cohorts` 的 `"healthy"` 桶）；public API 簽名/語意不變 |
| `scripts/simulation/game_setup.gd` | Modify | `_setup_anon_tiers` 寫入改 `AnonCohort.add(..., "healthy", n)` |
| `scripts/simulation/beast_system.gd` | Modify | `t.anon_tiers = {}` → `t.anon_cohorts = {}` |
| `scripts/debug/qa_probe.gd` | Modify | debug 清零改 `t.anon_cohorts = {}` |
| `scripts/debug/headless_test.gd` | Modify | 加 `_seed_anon` 測試 helper；所有 `*.anon_tiers = {...}` / `*.anon_tiers[t] = n` **寫入**改走 helper / `AnonCohort.add`（讀取斷言不動） |

**不變量**：2a 後 `team.anon_cohorts` 只含 `health="healthy"` 桶；`AnonCohort.total(team.anon_cohorts) == 舊 anon_tiers 總和`；`wounded` int 欄位與其所有讀寫**原樣不動**。

---

## Task 1: team_data 欄位替換 + 唯讀 anon_tiers getter

**Files:**
- Modify: `scripts/data/team_data.gd:88-90`（`anon_tiers` 欄位定義）

- [ ] **Step 1: 換儲存欄位 + 加相容 getter**

`scripts/data/team_data.gd`，把：
```gdscript
var anon_tiers: Dictionary = {
	"平民": 0, "新兵": 0, "老兵": 0, "菁英": 0,
}
```
改成：
```gdscript
# Anon Cohort 統一容器（取代舊 anon_tiers）：鍵 "tier|health" → count，稀疏。
# Phase 2a：只用 health="healthy" 桶；wounded 維度 Phase 2b 啟用。
var anon_cohorts: Dictionary = {}
# 向後相容唯讀 getter：回 4-tier breakdown（{tier: 該 tier 跨 health 總數}）。
# 舊「讀」零改；舊「寫」（= / []=）會因無 setter 報錯 → 強迫改走 AnonCohort 入口。
var anon_tiers: Dictionary:
	get:
		var d: Dictionary = {}
		for tier in AnonCohort.TIER_ORDER:
			d[tier] = AnonCohort.by_tier(anon_cohorts, tier)
		return d
	set(_value):
		pass
```

> 註：getter 恆回 size 4（含 0 的 tier）→ 滿足 `_test_team_anon_tiers_default` 的 `size()==4` 斷言。`set` no-op（不是強迫報錯路線，改採「寫入點主動遷移」；殘留未遷移的 `= {...}` 寫入會 silently no-op → Task 4 全套回歸會抓出資料不符的斷言失敗）。

- [ ] **Step 2: 不單獨跑**（原子重構，待 Task 2/3 完成）。進 Task 2。

---

## Task 2: AnonTierSystem 內部改走 AnonCohort

**Files:**
- Modify: `scripts/simulation/anon_tier_system.gd`（全檔函數體；常數 + `anon_exp` 相關不動）

保留 `TIER_ORDER` / `TIER_STATS` / `PROMOTION_*` / `ELITE_WEAPON_REQ` / `TRAINING_CAP_THRESHOLDS` / `_training_cap` / `add_exp`（操作 `anon_exp`，不動）。其餘查詢/變動/升等函數體換成下列（操作 `team.anon_cohorts` 的 `"healthy"` 桶）：

- [ ] **Step 1: 換查詢函數**

把 `total_pop` / `total_wage` / `avg_speed` / `avg_combat_skill` / `tier_count` / `tier_breakdown` 改成：
```gdscript
static func total_pop(team: TeamData) -> int:
	return AnonCohort.total(team.anon_cohorts)

static func total_wage(team: TeamData) -> float:
	return AnonCohort.total_wage(team.anon_cohorts)

static func avg_speed(team: TeamData) -> float:
	return AnonCohort.avg_speed(team.anon_cohorts)

static func avg_combat_skill(team: TeamData) -> float:
	return AnonCohort.avg_combat(team.anon_cohorts)

static func tier_count(team: TeamData, tier: String) -> int:
	return AnonCohort.by_tier(team.anon_cohorts, tier)

static func tier_breakdown(team: TeamData) -> Dictionary:
	var d: Dictionary = {}
	for tier in TIER_ORDER:
		d[tier] = AnonCohort.by_tier(team.anon_cohorts, tier)
	return d
```

- [ ] **Step 2: 換 add_anon / remove_anon**

```gdscript
static func add_anon(team: TeamData, tier: String, count: int) -> void:
	if count <= 0 or tier not in TIER_ORDER:
		return
	AnonCohort.add(team.anon_cohorts, tier, "healthy", count)

static func remove_anon(team: TeamData, tier: String, count: int) -> int:
	if count <= 0 or tier not in TIER_ORDER:
		return 0
	return AnonCohort.remove(team.anon_cohorts, tier, "healthy", count)
```

- [ ] **Step 3: 換 kill_random（weighted over healthy 桶，回 {tier: 死亡數}）**

```gdscript
static func kill_random(team: TeamData, count: int, _source: String) -> Dictionary:
	var killed: Dictionary = {}
	for tier in TIER_ORDER:
		killed[tier] = 0
	for _i in range(count):
		var total: int = AnonCohort.total(team.anon_cohorts)
		if total <= 0:
			break
		var roll: int = randi() % total
		var acc: int = 0
		for tier in TIER_ORDER:
			acc += AnonCohort.by_tier(team.anon_cohorts, tier)
			if roll < acc:
				AnonCohort.remove(team.anon_cohorts, tier, "healthy", 1)
				killed[tier] += 1
				break
	return killed
```
> 2a 全桶 healthy，`by_tier == healthy 數`；遍歷 TIER_ORDER 對齊舊 weighted 分布。

- [ ] **Step 4: 換 transfer_proportional（保 tier，over healthy 桶）**

```gdscript
static func transfer_proportional(from: TeamData, to: TeamData, count: int) -> Dictionary:
	var moved: Dictionary = {}
	for tier in TIER_ORDER:
		moved[tier] = 0
	var total: int = AnonCohort.total(from.anon_cohorts)
	if total <= 0 or count <= 0:
		return moved
	var actual: int = mini(count, total)
	var remaining: int = actual
	for tier in TIER_ORDER:
		if remaining <= 0:
			break
		var avail: int = AnonCohort.by_tier(from.anon_cohorts, tier)
		var n: int = mini(mini(int(round(float(avail) / float(total) * float(actual))), avail), remaining)
		var real: int = AnonCohort.remove(from.anon_cohorts, tier, "healthy", n)
		AnonCohort.add(to.anon_cohorts, tier, "healthy", real)
		moved[tier] = real
		remaining -= real
	if remaining > 0:
		for tier in TIER_ORDER:
			if remaining <= 0:
				break
			var avail2: int = AnonCohort.by_tier(from.anon_cohorts, tier)
			if avail2 > 0:
				var take: int = mini(avail2, remaining)
				var real2: int = AnonCohort.remove(from.anon_cohorts, tier, "healthy", take)
				AnonCohort.add(to.anon_cohorts, tier, "healthy", real2)
				moved[tier] += real2
				remaining -= real2
	return moved
```

- [ ] **Step 5: 換 try_promote 的計數讀 + 桶搬移**

`try_promote` 邏輯不變，只把 3 處 `team.anon_tiers` 讀寫換掉：
- count 足檢查（原 :171）：
```gdscript
	if AnonCohort.by_tier(team.anon_cohorts, from_tier) < count:
		return 0
```
- 菁英武器需求（原 :191）：
```gdscript
		var future_elite: int = AnonCohort.by_tier(team.anon_cohorts, "菁英") + count
```
- 執行搬移（原 :200-201）：
```gdscript
	AnonCohort.move(team.anon_cohorts, from_tier, "healthy", to_tier, "healthy", count)
```
其餘（exp/物資/cap 檢查、`anon_exp` 扣減 :202）原樣不動。

- [ ] **Step 6: 不單獨跑**（待 Task 3）。進 Task 3。

---

## Task 3: production 寫入點遷移

**Files:**
- Modify: `scripts/simulation/game_setup.gd:338-346`
- Modify: `scripts/simulation/beast_system.gd:32`
- Modify: `scripts/debug/qa_probe.gd:27`

- [ ] **Step 1: game_setup `_setup_anon_tiers`**

把 `scripts/simulation/game_setup.gd` 的 `_setup_anon_tiers`（:338-346）寫入改 cohort：
```gdscript
static func _setup_anon_tiers(team: TeamData, cfg: Dictionary) -> void:
	var at: Dictionary = cfg.get("anon_tiers", {})
	if at.is_empty():
		var named_in: int = team.named_members.size() + (1 if team.leader_id != -1 else 0)
		var anon_total: int = maxi(team.population - named_in - team.wounded, 0)
		AnonCohort.add(team.anon_cohorts, "平民", "healthy", anon_total)
	else:
		for tier in AnonTierSystem.TIER_ORDER:
			AnonCohort.add(team.anon_cohorts, tier, "healthy", int(at.get(tier, 0)))
```
> named/wounded 計算與原 :341-342 一致，只把 `team.anon_tiers["平民"] = anon_total` / `team.anon_tiers[tier] = ...` 兩處改成 `AnonCohort.add(..., "healthy", ...)`。`anon_cohorts` 預設空 dict，add 即建桶。

- [ ] **Step 2: beast_system**

`scripts/simulation/beast_system.gd:32`：`t.anon_tiers = {}` → `t.anon_cohorts = {}`（野獸無 tier 編制，清空容器）。

- [ ] **Step 3: qa_probe（debug 工具）**

`scripts/debug/qa_probe.gd:27`：`for t in pt.anon_tiers: pt.anon_tiers[t] = 0` → `pt.anon_cohorts = {}`（清零 anon）。

- [ ] **Step 4: 不單獨跑**（待 Task 4 測試遷移後一起驗）。進 Task 4。

---

## Task 4: 測試寫入點遷移 + 全套回歸綠

**Files:**
- Modify: `scripts/debug/headless_test.gd`（加 helper + 遷移所有 anon_tiers **寫入**；**讀取斷言不動**）

- [ ] **Step 1: 加測試 helper**

在 `scripts/debug/headless_test.gd` 任意 helper 區加：
```gdscript
# 測試用：依 {tier: count} 把 anon 全設為 healthy 桶（取代舊 team.anon_tiers = {...}）
func _seed_anon(t: TeamData, d: Dictionary) -> void:
	t.anon_cohorts = {}
	for tier in d:
		AnonCohort.add(t.anon_cohorts, tier, "healthy", int(d[tier]))
```

- [ ] **Step 2: 遷移所有 anon_tiers 寫入點**

規則（**只改寫入，讀取/斷言不動**）：
- `X.anon_tiers = { ... }` → `_seed_anon(X, { ... })`
- `X.anon_tiers["T"] = n` → `AnonCohort.add(X.anon_cohorts, "T", "healthy", n)`

需改的寫入行（grep 基準，行號會隨改動位移 —— 逐一搜 `.anon_tiers =` 與 `.anon_tiers[` 寫法定位）：
- 整 dict 指派：`headless_test.gd` 5087, 6300, 6332, 6341, 6362, 6378, 6390, 6402, 6417, 6449, 6453, 7568, 8408, 8436
- 單 tier 指派：5348, 5870, 5898, 5921, 5944, 6007, 6430, 8053（如 `team.anon_tiers["新兵"] = 8` → `AnonCohort.add(team.anon_cohorts, "新兵", "healthy", 8)`）

> `_test_team_anon_tiers_default`（6290-6293）的 `t.anon_tiers["平民"] == 0` / `size()==4` 是**讀取斷言** → 靠 getter 滿足，不動。所有 `assert(... t.anon_tiers.get/[...] ...)` 讀取斷言不動。
> `7576` `for tier in team.anon_tiers: anon_sum += ...` 是讀取（迭代 getter 回的 4-tier dict）→ 不動。

- [ ] **Step 3: 跑全套 headless 回歸**

```powershell
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
```
Expected: 結尾 `=== DONE ===`，無 `SCRIPT ERROR`，**所有既有 anon 斷言全綠**（`_test_add_remove_anon` / `_test_kill_random_proportional` / `_test_transfer_proportional` / `_test_promote_*` / `_test_anon_speed_tiers` / `_test_team_anon_tiers_default` 等）。任一紅 = 遷移漏點或行為偏移，定位修正。

- [ ] **Step 4: Commit**

```bash
git add scripts/data/team_data.gd scripts/simulation/anon_tier_system.gd scripts/simulation/game_setup.gd scripts/simulation/beast_system.gd scripts/debug/qa_probe.gd scripts/debug/headless_test.gd
git commit -m "refactor(anon): Phase 2a storage flip anon_tiers→anon_cohorts（行為不變，wounded 維度未啟用）"
```

---

## Task 5: multi sanity + hand-back

**Files:**
- Create: `docs/superpowers/handbacks/2026-06-17-anon-cohort-phase2a.md`

- [ ] **Step 1: multi sanity（守恆 + InvariantAudit 不退步）**

```powershell
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd
```
Expected: 各 config 跑完、`coin_eq` delta=0、`[InvariantViolation]` 數量**不高於 baseline**（population drift 清單與 Phase 1 handback 一致即可——2a 不修 drift，只換儲存）、died/pop 合理、無 `SCRIPT ERROR`。

- [ ] **Step 2: 寫 hand-back**

依 `docs/process/03_implementer.md` 寫 `docs/superpowers/handbacks/2026-06-17-anon-cohort-phase2a.md`：
- 實作摘要：每檔一行（team_data 欄位+getter / AnonTierSystem facade / game_setup·beast·qa_probe 寫入 / 測試 helper+遷移）。
- 與 spec 差異：`anon_tiers` 採 set-no-op getter（非唯讀報錯），殘留寫入靠回歸斷言抓 —— 說明理由。
- 連動風險：列 `wounded` int 仍獨立（2b 才折入）；`anon_combat_skill`/`anon_wage` shim 經 AnonTierSystem 自動跟著走 cohort（已驗）；存檔/序列化若有 `anon_tiers` 欄位需 2c/Phase4 處理。
- 待主 session 確認：2b 啟動（wounded → cohort health 維度 + 修漏水 + 公式調）。

- [ ] **Step 3: Commit + push + 回報**

```bash
git add docs/superpowers/handbacks/2026-06-17-anon-cohort-phase2a.md
git commit -m "docs: anon cohort phase2a hand-back"
git push -u origin feat/anon-cohort-phase2a
```
回報分支給主 session（finishing 選 Option 3，主 session merge）。

---

## Self-Review

**Spec coverage（對 `2026-06-17-anon-cohort-model-design.md` 階段 1/2 的 storage 部分）：** 涵蓋「`anon_cohorts` 容器成為儲存」「AnonTierSystem 投影/變動改讀 cohort」「既有 AnonTierSystem 1:1 遷移表」的 storage flip 部分。**刻意不含** wounded→getter（2b）、population→getter（2c）、combat `pop-wounded-named`→`healthy_pop`（2b）、InvariantAudit cohort 自洽網（Phase 4）—— 已在藍圖標明分階段。

**Placeholder scan：** 無 TBD。唯一「先讀原文」提示在 Task 3 Step 1（game_setup named 計算），因原碼 named 來源變數名需現場核對 —— 附了明確核對指示與只改兩行的範圍，非 placeholder。

**Type consistency：** AnonTierSystem public 簽名全部維持（`total_pop(team)->int`、`add_anon(team,tier,count)->void`、`remove_anon(team,tier,count)->int`、`kill_random(team,count,source)->Dictionary`、`transfer_proportional(from,to,count)->Dictionary`、`try_promote(state,team,from,count)->int`）→ 呼叫端零改。`AnonCohort` 介面（`add/remove/move/total/by_tier`）對齊 Phase 1 已 merge 版本。`anon_cohorts` 欄位名跨 team_data / AnonTierSystem / game_setup / beast / qa_probe / 測試一致。
