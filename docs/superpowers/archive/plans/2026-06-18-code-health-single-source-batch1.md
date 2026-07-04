# 代碼健康 批次1（共用常數單一真值源）Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 把散落重複的共用常數收斂成單一真值源（FOOD_PER_PERSON_PER_DAY、TIER_ORDER、tier 名字串、TRAINING_CAP、VISION_RADIUS），消除「改一處其他 drift」。

**Architecture:** 通用模型/單一真值源原則（非東修西補）。每個值留一個權威定義，其餘改引用、刪副本；dead const 接回邏輯成單一源。零行為變更（值不變，只去重）。

**Tech Stack:** Godot 4.2.2 GDScript。閘 = `headless_test.gd`（`=== DONE ===`）+ `game_sim_multi.gd`（coin_eq=0、全 invariant 0 維持、行為等價）。

> **藍圖**：代碼健康分批。**本 plan = 批次1（常數去重）**。批次2（TASK_* enum 補齊 + ResourceKeys 鍵權威模組 + `resources.get` helper）後續。

**前置（強制，依 `docs/process/03_implementer.md`）：**
```powershell
git worktree add .worktrees/code-health-b1 -b feat/code-health-b1
cd .worktrees/code-health-b1
```

**Baseline：** `headless_test.gd` → `=== DONE ===`；`game_sim_multi.gd` coin_eq=0、全 invariant 0。

---

## File Structure

| 檔案 | 動作 |
|---|---|
| `scripts/simulation/resource_system.gd` | 權威源 | `FOOD_PER_PERSON_PER_DAY`（保留為唯一源）|
| `scripts/simulation/anon_cohort.gd` | 權威源 | tier 名 named const + `TIER_ORDER`（唯一源）|
| `scripts/simulation/vision_system.gd` | 權威源 | `VISION_RADIUS`（唯一源）|
| `scripts/simulation/{player_api_mapper,faction_ai}_system.gd` | Modify | 刪 FOOD 副本 → 引用 ResourceSystem |
| `scripts/simulation/anon_tier_system.gd` | Modify | TIER_ORDER 引用 AnonCohort；`_training_cap` 接回 TRAINING_CAP（單一源）|
| `scripts/simulation/{encounter,player_command,training,beast,population}_system.gd`、`recruit_tutorial.gd`、`game_setup.gd` | Modify | 散落 tier 字串 → AnonCohort named const |
| `scripts/ui/text_map_renderer.gd`、`scripts/simulation/day_night_system.gd` | Modify | VISION_RADIUS 副本 → 引用 VisionSystem |

> **不動**：`anon_tier_system.gd` 的 `TIER_STATS`/`PROMOTION_*` dict **定義**（authority 表，co-located，非散落）；`encounter_view.gd:501 SOUND_RANGE`（語意=聲音範圍，值巧合=3，非 vision 副本）。

---

## Task 1: FOOD_PER_PERSON_PER_DAY 單一源

**Files:** Modify `player_api_mapper.gd:156`、`faction_ai_system.gd:45`

`resource_system.gd:3 FOOD_PER_PERSON_PER_DAY=2.4` 為權威。另兩份副本刪除改引用。

- [ ] **Step 1: 刪副本 + 改引用**

- `player_api_mapper.gd`：刪 `:156 const FOOD_PER_PERSON_PER_DAY: float = 2.4`；該檔內所有 `FOOD_PER_PERSON_PER_DAY` 用法改 `ResourceSystem.FOOD_PER_PERSON_PER_DAY`。
- `faction_ai_system.gd`：刪 `:45 const FOOD_PER_PERSON_PER_DAY_SURVIVAL: float = 2.4`；該檔內所有 `FOOD_PER_PERSON_PER_DAY_SURVIVAL` 用法改 `ResourceSystem.FOOD_PER_PERSON_PER_DAY`。
  > `_SURVIVAL` 後綴僅命名差異、值同 2.4、語意=每人每日食量 → 合併單一源。未來若 survival 門檻需獨立調再另立 const（YAGNI）。

- [ ] **Step 2: 跑 headless**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `=== DONE ===`，無 `SCRIPT ERROR`。

- [ ] **Step 3: Commit**

```bash
git add scripts/simulation/player_api_mapper.gd scripts/simulation/faction_ai_system.gd
git commit -m "refactor(const): FOOD_PER_PERSON_PER_DAY 收斂單一源（刪 2 副本）"
```

---

## Task 2: TIER_ORDER 單一源 + tier 名 named const

**Files:** Modify `anon_cohort.gd`、`anon_tier_system.gd`

- [ ] **Step 1: AnonCohort 立 tier named const（唯一源）**

`anon_cohort.gd:6`，把：
```gdscript
const TIER_ORDER: Array   = ["平民", "新兵", "老兵", "菁英"]
```
改成：
```gdscript
const TIER_PLEB: String    = "平民"
const TIER_SOLDIER: String = "新兵"
const TIER_VET: String     = "老兵"
const TIER_ELITE: String   = "菁英"
const TIER_ORDER: Array    = [TIER_PLEB, TIER_SOLDIER, TIER_VET, TIER_ELITE]
```

- [ ] **Step 2: anon_tier_system 引用，刪自己的 TIER_ORDER**

`anon_tier_system.gd:7`，刪 `const TIER_ORDER: Array = [...]`，改：
```gdscript
const TIER_ORDER: Array = AnonCohort.TIER_ORDER
```
> 保留本檔 `TIER_STATS`/`PROMOTION_*` dict 定義（authority 表，dict key 維持字面，co-located 非散落）。

- [ ] **Step 3: 跑 headless**

Expected: `=== DONE ===`，無 `SCRIPT ERROR`，anon tier/cohort 測試綠。

- [ ] **Step 4: Commit**

```bash
git add scripts/simulation/anon_cohort.gd scripts/simulation/anon_tier_system.gd
git commit -m "refactor(const): TIER_ORDER 單一源(AnonCohort) + tier 名 named const"
```

---

## Task 3: 散落 tier 字串 → named const

納管的散落硬編碼 tier 名（非 authority 表、非迴圈 key）改引用 `AnonCohort.TIER_*`。

- [ ] **Step 1: 逐站改**

各站 `"平民"` → `AnonCohort.TIER_PLEB`、`"菁英"` → `AnonCohort.TIER_ELITE`（依實際 tier）：
- `encounter_system.gd:1250`（`STATUS_ORDER`? 確認是 tier 還是 status——**只改 tier 名，status 字串不動**）
- `player_command_system.gd:190,198`
- `training_system.gd:22`
- `beast_system.gd:32`（`AnonCohort.add(t.anon_cohorts, "平民", ...)` → `AnonCohort.TIER_PLEB`）
- `population_system.gd:21`（mature → 平民）
- `recruit_tutorial.gd:22`
- `game_setup.gd:340`（`_setup_anon_tiers` 內 "平民"）

> ⚠ **逐站讀確認是 tier 名**（非同字的 status/其他語意）。`for tier in TIER_ORDER` 迴圈內的 `tier` 變數不動（已是引用）。dict literal key（authority 表）不動。

- [ ] **Step 2: 跑 headless**

Expected: `=== DONE ===`，無 `SCRIPT ERROR`。

- [ ] **Step 3: Commit**

```bash
git add -A
git commit -m "refactor(const): 散落 tier 字串 → AnonCohort.TIER_* named const"
```

---

## Task 4: TRAINING_CAP 接回單一源

**Files:** Modify `anon_tier_system.gd`（`_training_cap` :232 + `TRAINING_CAP_THRESHOLDS` :34）

dead const `TRAINING_CAP_THRESHOLDS`（:34-38）零引用、`_training_cap` 硬編碼同門檻 → 讓 `_training_cap` 讀 const（單一源），消 dead + 去重。

- [ ] **Step 1: _training_cap 讀 const**

`anon_tier_system.gd` `_training_cap`（:232-238）改成從 `TRAINING_CAP_THRESHOLDS` 推導（最高「tact > 門檻」對應 tier，嚴格 `>` 對齊原邊界）：
```gdscript
static func _training_cap(tact: float) -> String:
	var cap: String = AnonCohort.TIER_SOLDIER   # floor=新兵（門檻 0.0）
	var best: float = -1.0
	for threshold in TRAINING_CAP_THRESHOLDS:
		var th: float = float(threshold)
		if tact > th and th > best:
			best = th
			cap = TRAINING_CAP_THRESHOLDS[threshold]
	return cap
```
> 嚴格 `>` 等價原碼（原 `if tact>0.4: 老兵; if tact>0.7: 菁英`）。驗證：tact=0→新兵（無門檻>0 命中，default）、0.4→新兵、0.5→老兵、0.7→老兵、0.8→菁英。`TRAINING_CAP_THRESHOLDS` value 用 tier 名（"新兵"/"老兵"/"菁英"）—— 此 dict 是 authority 表，key 數字、value tier 字面保留（與 TIER_STATS 同類，不改）。

- [ ] **Step 2: 跑 headless（驗 _training_cap 等價）**

Expected: `=== DONE ===`，無 `SCRIPT ERROR`，promote/training cap 相關測試（`_test_promote_leader_skill_cap` 等）綠。

- [ ] **Step 3: Commit**

```bash
git add scripts/simulation/anon_tier_system.gd
git commit -m "refactor(const): _training_cap 讀 TRAINING_CAP_THRESHOLDS（消 dead const,單一源）"
```

---

## Task 5: VISION_RADIUS 單一源

**Files:** Modify `text_map_renderer.gd:4`、`day_night_system.gd:60`

`vision_system.gd:3 VISION_RADIUS=3` 為權威。

- [ ] **Step 1: 副本改引用**

- `scripts/ui/text_map_renderer.gd:4`：`const VISION_RADIUS: int = 3` → `const VISION_RADIUS: int = VisionSystem.VISION_RADIUS`（UI→sim const 引用，clean）。`VIEW_RADIUS`（:5，獨立語意=視窗半徑）不動。
- `scripts/simulation/day_night_system.gd:60`：`var base: int = 3   # VisionSystem.VISION_RADIUS（避免跨系統依賴）` → `var base: int = VisionSystem.VISION_RADIUS`（const 引用為編譯期，無 runtime 跨系統依賴疑慮；註解移除）。
> `encounter_view.gd:501 SOUND_RANGE`（聲音範圍，非 vision）**不動**。

- [ ] **Step 2: 跑 headless**

Expected: `=== DONE ===`，無 `SCRIPT ERROR`。

- [ ] **Step 3: Commit**

```bash
git add scripts/ui/text_map_renderer.gd scripts/simulation/day_night_system.gd
git commit -m "refactor(const): VISION_RADIUS 單一源(VisionSystem)，刪 2 副本"
```

---

## Task 6: 回歸 + hand-back

- [ ] **Step 1: 全回歸**

```powershell
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd
```
Expected: headless `=== DONE ===`；multi coin_eq=0、全 invariant 0、無 `SCRIPT ERROR`。**行為等價**（純去重，值不變）。

- [ ] **Step 2: hand-back** `docs/superpowers/handbacks/2026-06-18-code-health-single-source-batch1.md`：
- 實作摘要：FOOD/TIER_ORDER/tier-名/TRAINING_CAP/VISION 各收斂單一源（每檔一行）。
- 驗證：headless 綠、coin_eq=0、全 invariant 0、行為等價。
- 與 plan 差異（若 _training_cap 邊界或 tier-站判讀有調整則記）。
- 待主 session：批次2（TASK_* enum 補齊 + ResourceKeys 鍵權威 + resources.get helper）。

- [ ] **Step 3: Commit + push + 回報**

```bash
git add docs/superpowers/handbacks/2026-06-18-code-health-single-source-batch1.md
git commit -m "docs: 代碼健康 批次1 hand-back"
git push -u origin feat/code-health-b1
```
回報分支（finishing 選 Option 3，主 session merge）。

---

## Self-Review

**Spec coverage：** 涵蓋審計「重複值」高/中項（FOOD/TIER_ORDER/tier 字串/VISION）+ dead const（TRAINING_CAP）。TASK_*、ResourceKeys、resources.get helper 屬批次2（已註）。

**Placeholder scan：** 無 TBD。Task 3 tier-站、Task 4 `_training_cap` 邊界附「逐站讀確認/保持 `>` 等價」明確判準，非 placeholder。

**Type consistency：** `AnonCohort.TIER_PLEB/SOLDIER/VET/ELITE/TIER_ORDER`、`ResourceSystem.FOOD_PER_PERSON_PER_DAY`、`VisionSystem.VISION_RADIUS` 為各權威類 const，跨檔引用一致。`_training_cap` 簽名不變（`(tact:float)->String`）。零行為變更（值與邊界等價）。
