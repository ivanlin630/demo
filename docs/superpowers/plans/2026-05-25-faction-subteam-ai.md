# FactionAI 個人值整合 + 子團自主 AI Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 補完 FactionAI 義氣/貪婪效果，並為子團加入偏離掠奪與 idle 自主決策兩種自主行為。

**Architecture:** 所有改動集中於 `faction_ai_system.gd`。FactionAI 新增兩個常數和兩段邏輯（義氣影響徵收、貪婪觸發掠奪 goal）；子團 AI 新增兩個 helper（`_check_deviation`、`_evaluate_idle_subteam`）並接入現有 `_evaluate_subteam` 分支。`headless_test.gd` 加入 Person1 高貪婪設定以驗證 idle 自主行為。

**Tech Stack:** Godot 4.2.2 GDScript，無外部依賴。

---

## 背景知識（給零 context 工程師）

這是 Godot 4.2.2 headless 模擬器。GDScript，無測試框架。「測試」= 跑 headless script，看 print 輸出。

**兩個執行指令：**
```powershell
# 重建 class 快取（改 class_name 檔後必跑；只改函數內容不需要）
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import

# 跑模擬測試
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

**當前行為（改之前）：**
- `faction_ai_system.gd:_update_goals`：leader `義氣` 只壓低 attack_score（`-honor × 0.4`），不影響徵收頻率
- 勢力 AI 沒有「掠奪」goal，只有 solo team AI 有
- `_evaluate_subteam`：子團 idle 時只會往 parent 走，沒有自主決策
- `_check_discipline`：只判定完全脫離，無偏離行為

**目標 log 關鍵字：**
- `[FactionAI] TeamX 主動掠奪 TeamY` — 新貪婪 goal 觸發
- `[SubAI] TeamX idle→掠奪/攻擊 (TeamY)` — idle mini-loop 觸發
- `[SubAI] TeamX 偏離掠奪 TeamY` — deviation 觸發

---

## 檔案結構

| 檔案 | 動作 |
|---|---|
| `scripts/simulation/faction_ai_system.gd` | 主改動：常數 × 5；`_update_goals` 義氣徵收 + 貪婪 goal；`_assign_tasks` 掠奪分支；`_evaluate_subteam` 接入兩個新 helper；新增 `_check_deviation`、`_evaluate_idle_subteam` |
| `scripts/debug/headless_test.gd` | Person1 加高貪婪值，讓 idle 子團有機會觸發 mini-loop |
| `docs/progress.md` | 兩項從 memory/future 移入已完成 |

---

## Task 1：FactionAI 義氣低徵收 + 貪婪掠奪 Goal

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`

### 步驟

- [ ] **Step 1：加常數**

在 `faction_ai_system.gd` 頂部現有常數區（第 3–13 行）末尾，`TRADEABLE_RES` 宣告**之前**，插入：

```gdscript
const HONOR_INTERVAL_MULT: float  = 0.5   # honor=1.0 → 徵收週期 ×1.5（義氣高 → 少收稅）
const HONOR_EMERGENCY_DISC: float = 0.3   # honor=1.0 → emergency 門檻 ×0.7（義氣高 → 緊急門檻降低）
const LOOT_SCORE_THRESHOLD: float = 0.35  # TEST VALUE — 掠奪 goal 分數門檻
const LOOT_READINESS_MIN: float   = 0.6   # TEST VALUE — 掠奪需要的最低 readiness
const DEVIATION_RATE: float       = 0.05  # TEST VALUE — 子團偏離基礎概率
```

- [ ] **Step 2：修改 `_update_goals` — 義氣影響徵收**

找到 `_update_goals` 中這兩行（約第 96–97 行）：
```gdscript
	var effective_emergency: float = FOOD_EMERGENCY * (0.7 + survival * 0.6)
	var effective_interval:  int   = maxi(int(COLLECT_INTERVAL * (1.5 - greed)), 10)
```

替換為：
```gdscript
	var effective_emergency: float = FOOD_EMERGENCY * (0.7 + survival * 0.6) \
		* clampf(1.0 - honor * HONOR_EMERGENCY_DISC, 0.5, 1.0)
	var effective_interval:  int   = maxi(
		int(COLLECT_INTERVAL * (1.5 - greed) * (1.0 + honor * HONOR_INTERVAL_MULT)), 10)
```

**邏輯說明：**
- `effective_emergency` 乘上 `(1 - honor × 0.3)`。honor=1.0 → × 0.7 → 門檻降低 → 更難觸發緊急徵收。
- `effective_interval` 乘上 `(1 + honor × 0.5)`。honor=1.0 → 週期變 1.5× → 定期徵收更少。

- [ ] **Step 3：修改 `_update_goals` — 新增貪婪掠奪 Goal**

找到 `_update_goals` 中的攻擊 goal 程式碼區塊（約第 123–128 行）：
```gdscript
	var attack_score: float = ambition * 0.4 + martial * 0.4 - honor * 0.4
	if f.is_established and attack_score > 0.3 \
			and leader_team.readiness >= 0.75 \
			and _has_independent(state, f.leader_team_id) \
			and _tag_weight(leader_team, "攻擊") > 0.0:
		f.goals.append("攻擊")
```

在這個 block **之後**（函數結尾前）插入：
```gdscript
	var loot_score: float = greed * 0.5 + martial * 0.3 - honor * 0.3
	if f.is_established and loot_score > LOOT_SCORE_THRESHOLD \
			and leader_team.readiness >= LOOT_READINESS_MIN \
			and _has_independent(state, f.leader_team_id) \
			and _tag_weight(leader_team, "掠奪") > 0.0:
		f.goals.append("掠奪")
```

- [ ] **Step 4：修改 `_assign_tasks` — 處理掠奪 Goal**

找到 `_assign_tasks` 中攻擊分支（約第 157–162 行）：
```gdscript
	if "攻擊" in f.goals and leader_team.current_task not in ["徵收", "外交", "攻擊"]:
		var target_id: int = _nearest_independent(state, leader_team)
		if target_id != -1:
			leader_team.current_task = "攻擊"
			leader_team.move_target  = state.teams[target_id].tile_pos
			print("[FactionAI] Team%d 主動攻擊 Team%d" % [f.leader_team_id, target_id])
```

在這個 block **之後**（`_assign_member_tasks(state, f)` 之前）插入：
```gdscript
	if "掠奪" in f.goals and leader_team.current_task not in ["徵收", "外交", "攻擊", "掠奪"]:
		var target_id: int = _nearest_independent(state, leader_team)
		if target_id != -1:
			leader_team.current_task = "掠奪"
			leader_team.move_target  = state.teams[target_id].tile_pos
			print("[FactionAI] Team%d 主動掠奪 Team%d" % [f.leader_team_id, target_id])
```

- [ ] **Step 5：跑模擬確認無錯誤**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：無 `SCRIPT ERROR`，出現 `=== DONE ===`。若 Team0 leader 貪婪 0.8 + 好戰 0.8，應出現 `[FactionAI] Team0 主動掠奪 TeamX`。

- [ ] **Step 6：Commit**

```powershell
git add scripts/simulation/faction_ai_system.gd
git commit -m "feat(faction-ai): honor lowers tribute frequency; greed adds loot goal"
```

---

## Task 2：子團偏離掠奪 + Idle Mini-Loop

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`

### 步驟

- [ ] **Step 1：新增 `_check_deviation` helper**

在 `faction_ai_system.gd` 的 `_check_discipline` 函數（約第 226–250 行）**之後**插入新函數：

```gdscript
func _check_deviation(state: WorldState, sub: TeamData) -> bool:
	var leader = state.persons.get(sub.leader_id)
	if leader == null:
		return false
	var greed: float   = float(leader.values.get("貪婪", 0.5))
	var loyalty: float = leader.loyalty
	var deviation_chance: float = greed * (1.0 - loyalty) * DEVIATION_RATE
	if randf() < deviation_chance:
		var loot_target: int = _nearest_independent(state, sub)
		if loot_target != -1:
			sub.current_task = TeamData.TASK_LOOT
			sub.move_target  = state.teams[loot_target].tile_pos
			print("[SubAI] Team%d 偏離掠奪 Team%d" % [sub.team_id, loot_target])
			return true
	return false
```

**邏輯：** `deviation_chance = 貪婪 × (1 - 忠誠) × 0.05`。貪婪=0.8、忠誠=0.3 → 2% / tick。

- [ ] **Step 2：新增 `_evaluate_idle_subteam` helper**

在 Step 1 新增的 `_check_deviation` **之後**插入：

```gdscript
func _evaluate_idle_subteam(state: WorldState, sub: TeamData, merge_queue: Array) -> void:
	var parent: TeamData = state.teams.get(sub.parent_team_id)
	if parent == null:
		return
	if parent.tile_pos == sub.tile_pos:
		merge_queue.append(sub.team_id)
		return
	var leader_p = state.persons.get(sub.leader_id)
	if leader_p == null:
		sub.move_target = parent.tile_pos
		return
	var greed:   float = float(leader_p.values.get("貪婪", 0.5))
	var martial: float = float(leader_p.values.get("好戰", 0.5))
	var scores: Dictionary = { "回歸": 0.3 }
	scores["掠奪"] = (greed * 0.5 + martial * 0.2) * _tag_weight(sub, "掠奪")
	scores["攻擊"] = (martial * 0.4 + greed * 0.2) * _tag_weight(sub, "攻擊")
	var best_task := "回歸"
	var best_score: float = 0.0
	for t in scores:
		if float(scores[t]) > best_score:
			best_score = float(scores[t])
			best_task  = t
	if best_task == "回歸":
		sub.move_target = parent.tile_pos
	else:
		var tid: int = _nearest_independent(state, sub)
		if tid != -1:
			sub.current_task = best_task
			sub.move_target  = state.teams[tid].tile_pos
			print("[SubAI] Team%d idle→%s (Team%d)" % [sub.team_id, best_task, tid])
		else:
			sub.move_target = parent.tile_pos
```

**邏輯：** 基準分 `回歸=0.3`，貪婪+好戰可讓掠奪/攻擊超越。子團 tag 過濾仍有效（商隊不會 掠奪）。

- [ ] **Step 3：修改 `_evaluate_subteam` — 接入兩個 helper**

找到 `_evaluate_subteam` 函數（約第 196–213 行）：

```gdscript
func _evaluate_subteam(state: WorldState, sub: TeamData, merge_queue: Array) -> void:
	if sub.current_task == TeamData.TASK_ESCORT:
		_update_escort(state, sub)
		_check_discipline(state, sub)
		return
	if _check_discipline(state, sub):
		return
	# movement_system 到達時清 move_target；無目標且非 idle = 任務完成
	if sub.move_target == Vector2i(-1, -1) and sub.current_task != TeamData.TASK_IDLE:
		merge_queue.append(sub.team_id)
	elif sub.current_task == TeamData.TASK_IDLE:
		var parent: TeamData = state.teams.get(sub.parent_team_id)
		if parent == null:
			return
		if parent.tile_pos == sub.tile_pos:
			merge_queue.append(sub.team_id)
		else:
			sub.move_target = parent.tile_pos
```

替換為：

```gdscript
func _evaluate_subteam(state: WorldState, sub: TeamData, merge_queue: Array) -> void:
	if sub.current_task == TeamData.TASK_ESCORT:
		_update_escort(state, sub)
		_check_discipline(state, sub)
		return
	if _check_discipline(state, sub):
		return
	if sub.current_task != TeamData.TASK_IDLE and sub.move_target != Vector2i(-1, -1):
		if _check_deviation(state, sub):
			return
	if sub.move_target == Vector2i(-1, -1) and sub.current_task != TeamData.TASK_IDLE:
		merge_queue.append(sub.team_id)
	elif sub.current_task == TeamData.TASK_IDLE:
		_evaluate_idle_subteam(state, sub, merge_queue)
```

**改動說明：**
1. 偏離檢查加在 discipline 之後、任務完成判定之前，且只在有進行中任務（非 idle、有目標）時觸發。
2. `TASK_IDLE` 分支從 inline 邏輯換為呼叫 `_evaluate_idle_subteam`。

- [ ] **Step 4：跑模擬確認無錯誤**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：無 `SCRIPT ERROR`，出現 `=== DONE ===`。

- [ ] **Step 5：Commit**

```powershell
git add scripts/simulation/faction_ai_system.gd
git commit -m "feat(subteam-ai): add deviation-to-loot and idle autonomous decision loop"
```

---

## Task 3：headless_test 驗證 + 文件

**Files:**
- Modify: `scripts/debug/headless_test.gd`
- Modify: `docs/progress.md`

### 步驟

- [ ] **Step 1：headless_test 加高貪婪 Person1**

在 `headless_test.gd` 約第 133–137 行（`state.persons[1].skills["偵查"] = 0.4` 附近）找到 Person1 設定：

```gdscript
	state.persons[1].skills["統領"] = 0.2   # sub_cap = clamp(round(49×0.25)+1,1,50) = 14
	state.persons[1].skills["偵查"] = 0.4   # 高偵查：子隊視野更廣
```

在這兩行**之後**插入：

```gdscript
	state.persons[1].values["貪婪"] = 0.8   # 高貪婪 → idle 子團有機會觸發 mini-loop（掠奪/攻擊）
	state.persons[1].values["好戰"] = 0.7
	state.persons[1].loyalty       = 0.4    # 低忠誠 → deviation_chance 更高
```

- [ ] **Step 2：跑完整測試**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1
```

確認：
- 無 `SCRIPT ERROR`
- 出現 `=== DONE ===`
- 若子團完成偵查並進入 idle，應出現 `[SubAI] TeamX idle→掠奪/攻擊 (TeamY)` 或 `[SubAI] TeamX 偏離掠奪 TeamY`
- 若 Team0 leader 條件滿足（貪婪=0.8，好戰=0.8），應出現 `[FactionAI] Team0 主動掠奪 TeamX`

- [ ] **Step 3：更新 `docs/progress.md`**

在 `docs/progress.md` 的待完成「中優先」表格找到最後一個已劃線項目：
```markdown
| ~~**武器/戰鬥強化**~~ | ...
```

在其**之後**新增：
```markdown
| ~~**FactionAI 義氣/貪婪效果**~~ | ~~義氣高 → 徵收週期延長/緊急門檻降低；貪婪高 → 勢力 AI 加入掠奪 goal~~ | ~~✅ 武器/戰鬥強化完成~~ |
| ~~**子團自主 AI 強化**~~ | ~~偏離掠奪（貪婪×低忠誠→DEVIATION_RATE）；idle mini-loop（貪婪/好戰 weighted 決策）~~ | ~~✅ FactionAI 完成~~ |
```

同時更新 `docs/progress.md` 的模擬系統表中 `faction_ai_system.gd` 那行，在說明末尾補上：
```
；義氣→低徵收頻率；貪婪→掠奪 goal；子團偏離 + idle mini-loop
```

- [ ] **Step 4：更新 memory**

更新 `C:\Users\I12\.claude\projects\A--GDS-demo\memory\project_future_improvements.md`，移除「FactionAI 個人值整合」和「子團自主 AI」兩節（已完成，移入 progress.md）。

- [ ] **Step 5：Commit**

```powershell
git add scripts/debug/headless_test.gd docs/progress.md
git commit -m "test(headless): add high-greed person1 to exercise subteam idle AI; update progress docs"
```

---

## 驗證清單

| 項目 | 預期 |
|---|---|
| 無 SCRIPT ERROR | `=== DONE ===` 出現 |
| FactionAI 掠奪 | `[FactionAI] Team0 主動掠奪 TeamX` 出現（貪婪=0.8 + 好戰=0.8） |
| 子團 idle mini-loop | `[SubAI] TeamX idle→掠奪 (TeamY)` 出現（Person1 貪婪=0.8） |
| 子團偏離（機率性） | `[SubAI] TeamX 偏離掠奪 TeamY`（低忠誠=0.4，200 tick 可能觸發） |
| 既有功能不迴歸 | `[Faction]`、`[Trade]`、`[Equip]`、`=== DONE ===` 均正常出現 |

---

## ⚠️ 測試值（平衡期可調整）

| 常數 | 值 | 備註 |
|---|---|---|
| `HONOR_INTERVAL_MULT` | 0.5 | honor=1.0 → 週期 ×1.5 |
| `HONOR_EMERGENCY_DISC` | 0.3 | honor=1.0 → emergency ×0.7 |
| `LOOT_SCORE_THRESHOLD` | 0.35 | 掠奪 goal 分數門檻 |
| `LOOT_READINESS_MIN` | 0.6 | 掠奪最低 readiness |
| `DEVIATION_RATE` | 0.05 | 子團偏離基礎概率 / tick |
| idle 回歸基準分 | 0.3 | 需高於此才觸發自主行動 |
