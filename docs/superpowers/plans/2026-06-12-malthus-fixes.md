# 馬爾薩斯陷阱修正 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task.
> L2 批次。背景：C 期 2 年驗證（godot_2yr_utf8.log）— 選址評估 ×4137 同址不建、復工 ping-pong ×704、全世界 days_left 0.8-3.0 常駐 → 窮到蓋不起解決窮的東西。

**Goal:** 選址 diff print + 派工失敗原因 log；復工門檻 + 工地 timeout；糧收支儀器 + 量測驅動貧窮線 tune（目標：居民村緩衝 7-14 天）。

**Verified facts:**
- `[Site]` print 在 `faction_ai_system._evaluate_new_outpost_location`（每次評估都印）
- `_dispatch_builder`（faction_ai ~:1596 呼叫）失敗目前無 log（黑箱）
- `_try_resume_construction`（faction_ai，infra cadence）強制復工，無糧食門檻
- `tile.construction_team_id / construction_ticks_left / construction_target`（tile_data）；無 started_tick 欄位（需加）
- `_tick_construction`（outpost_system）person-ticks 扣減
- 糧流：收入 = `resource_system.collect_resources`（outpost 限定，`productivity × tile.food × 0.01 × outpost_mult × pop_mult × work_morale`，farming 加成）+ tile regen `REGEN_RATE`（plains food 8/day × harvest_factor）；支出 = `pop × FOOD_PER_PERSON_PER_DAY(2.4) + (mounts+horses) × 0.5`
- 測試：`.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`；2 年驗證 = config max_ticks 21600→172800 暫改（**用 Edit 工具，嚴禁 PowerShell -replace 重寫 config — 會毀中文編碼**），跑完還原

---

## Task 1: 選址 diff print + 派工失敗原因 log

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 改 [Site] 為 diff print**

```gdscript
var _last_site_sig: Dictionary = {}   # { faction_id: "x_y" }

# _evaluate_new_outpost_location 回傳前：
var sig: String = "%d_%d" % [best.pos.x, best.pos.y]
if _last_site_sig.get(leader_team.faction_id, "") != sig:
	_last_site_sig[leader_team.faction_id] = sig
	print("[Site] 選址 (%d, %d) score=%.0f 周邊資源=%s" % [...])
```

- [ ] **Step 2: _dispatch_builder 失敗原因 log（diff-only）**

dispatch 鏈各失敗點回傳/print 原因（資源不足 1.5×、無 advisor 可派可升、pop 不足）。同一 faction 同原因連續不重印（`_last_dispatch_fail: Dictionary`）。

```gdscript
print("[Site] Faction%d 派工失敗: %s (需 %s)" % [fid, reason, str(cost)])
```

- [ ] **Step 3: 測試 + Commit**

```gdscript
func _test_site_diff_print() -> void:
	# 同 faction 同址連評 → print 一次（用 _last_site_sig 驗證）
	# ...
	print("Malthus Task1 OK")
```

```powershell
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "fix(site): 選址 diff print + 派工失敗原因 log (Task 1)"
```

---

## Task 2: 復工門檻 + 工地 timeout

**Files:**
- Modify: `scripts/data/tile_data.gd`（construction_started_tick）
- Modify: `scripts/simulation/faction_ai_system.gd`（復工門檻）
- Modify: `scripts/simulation/outpost_system.gd`（timeout + 退料）
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_resume_requires_food() -> void:
	# team 糧 < 3 天 → _try_resume_construction 不拉回
	# 糧 ≥ 3 天 → 復工
	# ...
	print("Malthus Task2a OK")

func _test_construction_timeout() -> void:
	# 工地 30 天無進度 → 取消、退 50% material 給 construction_team、tile 釋放
	# ...
	print("Malthus Task2b OK")
```

- [ ] **Step 2: 實作**

`tile_data.gd`：
```gdscript
var construction_started_tick: int = -1   # 施工開始 tick（timeout 判定）
var construction_last_progress_tick: int = -1   # 最後實際進度 tick
```

開工點（`_begin_facility_construction` / `start_build`）設 started；`_tick_construction` 每次實扣進度時更新 last_progress。

復工門檻（`_try_resume_construction`）：
```gdscript
var days_left: float = float(team.resources.get("food", 0)) \
	/ maxf(float(team.population) * 2.4, 0.001)
if days_left < 3.0: continue   # 餓肚子不搬磚
```

timeout（infra cadence 掃描，與復工同處）：
```gdscript
const CONSTRUCTION_TIMEOUT: int = 30 * WorldState.TICKS_PER_DAY

if tile.construction_team_id != -1 \
		and state.world.current_tick - tile.construction_last_progress_tick > CONSTRUCTION_TIMEOUT:
	# 退 50% material 給施工團（若還在）
	var ct: TeamData = state.teams.get(tile.construction_team_id)
	var cost: Dictionary = _construction_cost_of(tile)   # 依 construction_target 查表
	if ct != null:
		ct.resources["material"] = float(ct.resources.get("material", 0)) \
			+ float(cost.get("material", 0)) * 0.5
	tile.construction_team_id = -1
	tile.construction_ticks_left = 0
	tile.construction_target = {}
	tile.construction_started_tick = -1
	print("[Infra] 工地逾時取消 at (%d,%d) 退料 50%%" % [tile.tile_pos.x, tile.tile_pos.y])
```

（tools 退料同 50%；coin 無 — 建造已無 coin）

- [ ] **Step 3: 跑 + Commit**

```powershell
git add scripts/data/tile_data.gd scripts/simulation/faction_ai_system.gd scripts/simulation/outpost_system.gd scripts/debug/headless_test.gd
git commit -m "fix(infra): 復工糧門檻 3 天 + 工地 30 天 timeout 退料 (Task 2)"
```

---

## Task 3: 糧收支儀器（FoodLedger）

**Files:**
- Modify: `scripts/debug/game_sim_multi.gd`
- Modify: `scripts/debug/headless_test.gd`（如需單元）

- [ ] **Step 1: 實作 FoodLedger**

multi 每月（PopSample 同點）對每 team 估算並輸出：

```gdscript
# [FoodLedger] config team=N pop=P food=F days=D burn/day=B（pop×2.4 + 馬×0.5）
# 收入難直接量 → 用月間 food 變化反推：income/day = (ΔF + burn×30) / 30
```

月初記 snapshot、月底算 delta。輸出格式固定方便 grep 統計。

- [ ] **Step 2: 跑 90 天 multi 出基線收支表 + Commit**

```powershell
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd > godot_ledger_baseline.log 2>&1
# 整理各 config 居民村/流浪團/軍鎮 的 income/day vs burn/day
git add scripts/debug/game_sim_multi.gd
git commit -m "feat(debug): FoodLedger 月度糧收支儀器 (Task 3)"
```

---

## Task 4: 量測驅動 tune 迴圈 + 2 年驗證 + handback

**Files:**
- Modify: `scripts/simulation/resource_system.gd`（REGEN / 採集係數）及/或 `config/*.json`（tile_food_init）
- Create: `docs/superpowers/handbacks/2026-06-12-malthus-fixes.md`

- [ ] **Step 1: 依 Task 3 基線資料調參**

目標：
- **有 outpost 居民村：income > burn，緩衝爬向 7-14 天**（P5 生育門檻 = 7 天盈餘）
- **流浪團：income < burn**（survival 壓力保留 — 不是回到水龍頭時代）
- 軍鎮：微負（靠稅/貿易 — 依賴設計）

Knobs 優先序（最小改動）：
1. `REGEN_RATE` food（tile 池再生）
2. 採集係數 0.01（collect_from_tile）
3. config `tile_food_init` / 初始 food
4. （最後手段）FOOD_PER_PERSON_PER_DAY — 動全局語意，避免

每輪：調 → 90 天 multi → 看 FoodLedger → 不達標再調。**記錄每輪參數與結果**（handback 要列）。

- [ ] **Step 2: 達標後 2 年驗證**

config max_ticks 21600 → 172800（**用 Edit 工具逐檔改，嚴禁 PowerShell -replace**），跑 multi，驗：
- 居民村 days 緩衝穩定 7-14（非無限暴漲 — 那是水龍頭回歸）
- P5 生育 > 0、長大成人 > 0（人口循環活了）
- 設施建造 > 2 年 2 件（建設解鎖）
- 選址/復工 loop 消失（[Site] 失敗原因可見、[Infra] 復工次數正常量級）
- coin 守恆 delta 0、ALL INVARIANTS PASSED
- 跑完 config 還原 21600

- [ ] **Step 3: handback + Commit**

```markdown
# Hand Back: 馬爾薩斯修正
## tune 迴圈記錄（每輪參數 + FoodLedger 結果）
## 2 年驗證數據（生育/建造/貿易/人口曲線）
## 派工失敗原因分布（Task 1 log 揭露的黑箱）
## 待確認
```

```powershell
git add docs/superpowers/handbacks/2026-06-12-malthus-fixes.md
git commit -m "docs: malthus fixes handback (Task 4)"
```
