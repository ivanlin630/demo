# A2b — faction leader 隊納統一引擎 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** faction leader 隊戰術執行從手寫 `_assign_tasks` cascade 改走統一 `_decide_unified` 引擎（拆最後一塊「手不聽腦」），intent 選擇 cadence-gate。

**Architecture:** 純路由重構——leader 隊本已被 `decision_context` 填好全 stakes+intent，只是從沒送進 `rank_scored`。A2b 把 `_assign_tasks` 的 徵收/外交/攻擊/掠奪 手 cascade 換成 `_decide_unified(leader_team)`（同成員），保 player_cmd/立國 lifecycle-gate。intent 選擇（`_select_intent`）加 1 天 cadence gate。**零 target 變、零 term patch、零 ctx 改**——攻擊 target 保 `_nearest_independent`（同現行手 cascade），FA10 撤出範圍。

**Tech Stack:** Godot 4.2.2 GDScript。測試 = headless seeded bed（`hand_obeys_brain_bed.gd`）+ sanity（`game_sim_multi.gd`）+ 憲法閘（`constitution_gate.gd`）。**所有 godot 呼叫用 wrapper `.\tools\godot.ps1`（強制 UTF-8）**。

**Spec:** `docs/superpowers/specs/2026-07-08-A2b-leader-into-engine.md`（02 三輪對抗終審 CLEAN + 00 sign-off 三項 + 2 QA 守衛）。

## Global Constraints

- **wrapper 必用**：`.\tools\godot.ps1 --headless ...`（不裸呼 godot exe，否則 CP950 中文亂碼）。
- **憲法**：「行為=引擎輸出」；「身分=權重非路徑切換」——A2b 不加身分-conditional path/ctx（全隊同 term set，差異只 pre-existing `ctx.intent` 值）。
- **零 target 變**：攻擊/徵收/外交 target 必須同 A2b 前（攻擊=`_nearest_independent`、徵收=`_richest_member` 排自身、外交=`_nearest_independent`）。純路由。
- **成員/solo/子隊零影響**：只碰 leader 隊 dispatch 路（`_assign_tasks`）+ faction-level intent cadence。
- **TEST VALUE**：`INTENT_CADENCE = TimeScale.TICK_PER_DAY * 1`（1 日，鏡射 `THREAT_CADENCE`/`SUBTEAM_CADENCE`）。
- **提交頻繁**：每 Task 一 commit（feat/refactor/chore 前綴）。

---

## 觸及檔總覽

- `scripts/data/faction_data.gd` — +`intent_eval_next_tick` 欄（Task 1）。
- `scripts/simulation/faction_ai_system.gd` — +`INTENT_CADENCE` const + `_update_goals` intent cadence-gate（Task 1）；`_assign_tasks` 拆戰術 cascade→`_decide_unified(leader)`、刪 `note_bypass`（Task 2）。
- `scripts/debug/constitution_baseline.txt` — `_assign_tasks` 註記更新（Task 3）。

**不碰**：`decision_context.gd`、`options.gd`、`terms.gd`、`decision_engine.gd`、成員/solo/子隊路、A1a 拆的閥、`_declare_established`、`_decide_unified` 本體。

---

### Task 1: intent 選擇 cadence-gate（D3）

**Files:**
- Modify: `scripts/data/faction_data.gd`（`intent` 欄旁，≈line 15）
- Modify: `scripts/simulation/faction_ai_system.gd`（+`INTENT_CADENCE` const ≈line 100 `THREAT_CADENCE` 旁；`_update_goals:940` intent 選擇段 ≈line 976-981）
- Test: `scripts/debug/hand_obeys_brain_bed.gd`（determinism 段）+ `scripts/debug/game_sim_multi.gd`（sanity）

**Interfaces:**
- Consumes: `TimeScale.TICK_PER_DAY`（`time_scale.gd:14`）、`state.world.current_tick`、`FactionData.intent`（`{type,target_id,why}`）。
- Produces: `FactionData.intent_eval_next_tick: int`（Task 2 不直接依賴，但 leader 走引擎後讀 `ctx.intent=f.intent.type` 之值受此 cadence 穩定化）。

- [ ] **Step 1: 加 FactionData 欄位**

`scripts/data/faction_data.gd`，在 `var intent: Dictionary = {}`（line 15）**下方**加：
```gdscript
var intent_eval_next_tick: int = 0   # 下次 intent 重選 tick（cadence，A2b #3；鏡射 team threat/subteam_eval_next_tick）
```

- [ ] **Step 2: 加 INTENT_CADENCE const**

`scripts/simulation/faction_ai_system.gd`，在 `const THREAT_CADENCE: int = TimeScale.TICK_PER_DAY * 1`（≈line 100）**旁**加：
```gdscript
# A2b intent 重選 cadence（藍圖 #3：戰略每 tick 重秤=雜訊；1 日重評，cadence 內沿用 f.intent）。TEST VALUE。
const INTENT_CADENCE: int = TimeScale.TICK_PER_DAY * 1   # 1 日
```

- [ ] **Step 3: cadence-gate `_select_intent` 呼叫**

`scripts/simulation/faction_ai_system.gd`，`_update_goals` 內「步驟 2：意圖選擇」段。現況（≈line 976-979）：
```gdscript
	# ── 步驟 2：意圖選擇（resource-aware + 人格 + belief + hysteresis）──
	var intent: Dictionary = _select_intent(state, f)
	f.intent = intent
	f.strategy = intent["type"]
```
改為（**只 gate `_select_intent`；cadence 內沿用 `f.intent`**）：
```gdscript
	# ── 步驟 2：意圖選擇（cadence-gate，藍圖 #3：1 日重選，cadence 內沿用 f.intent）──
	if state.world.current_tick >= f.intent_eval_next_tick:
		f.intent = _select_intent(state, f)
		f.intent_eval_next_tick = state.world.current_tick + INTENT_CADENCE
	# else：沿用上次 f.intent（committed hysteresis 已在 _select_intent，cadence 再加穩定層）
	var intent: Dictionary = f.intent if f.intent is Dictionary and not f.intent.is_empty() \
		else {"type": "守成", "target_id": -1, "why": ""}
	f.strategy = intent["type"]
```
- **why**：survival override（缺糧→徵收，line 962-965）+ 立國 gate（968-974）在此**之前**、每 tick reactive（不 gate，缺糧不能等 1 天）。goal emission（match itype，step 3+4，line 993+）在**之後**、每 tick 從 committed `f.intent` 冪等重 emit（clear→re-emit 同結果）。**只戰略意圖重選走 cadence**。

- [ ] **Step 4: 重建 class 快取（新增欄位/const 後必跑）**

Run:
```powershell
.\tools\godot.ps1 --headless --import
```
Expected: 無 GDScript 錯誤（綠）。

- [ ] **Step 5: sanity — 無崩 + leader 仍選意圖**

Run:
```powershell
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd
```
Expected: ≥1000 tick 無崩潰；`[FactionAI]` / intent 相關 print 仍出現（leader 仍運作，cadence 未凍死意圖）。

- [ ] **Step 6: determinism 未破**

Run:
```powershell
.\tools\godot.ps1 --headless --script scripts/debug/hand_obeys_brain_bed.gd
```
Expected: 末段 `determinism` 段 PASS（同 seed 兩跑逐事件相同）——cadence 是確定性 gate，不引入 RNG。

- [ ] **Step 7: Commit**

```bash
git add scripts/data/faction_data.gd scripts/simulation/faction_ai_system.gd
git commit -m "feat(A2b): intent 選擇 cadence-gate（1 日重選，cadence 內沿用 f.intent）"
```

---

### Task 2: leader 隊戰術執行 → `_decide_unified`（拆 `_assign_tasks` 手 cascade，D1）★核心

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`（`_assign_tasks:1340-1402`）
- Test: `scripts/debug/hand_obeys_brain_bed.gd`（`leader_bypass` 計數）+ `scripts/debug/game_sim_multi.gd`（sanity）

**Interfaces:**
- Consumes: `_decide_unified(state, team)`（`faction_ai_system.gd:1470`，既有；leader `faction_id!=-1` → conquest scaffolding `faction_id==-1` 天然不觸，走 generic to_task）、`_assign_member_tasks(state, f)`（1404，既有）、`_declare_established(state, f, leader_team)`（既有 lifecycle）、`SURVIVAL_TASKS`、`TaskArbiter.try_set(...PRIO_PLAYER..."player_command")`。
- Produces: leader 隊 task 現全經 `_decide_unified`（reason `"unified"`）→ `HandBrainProbe.capture(src="unified")`；`leader_bypass` 計數不再累增（→ 0）。

- [ ] **Step 1: 建立 baseline（TDD「失敗測試」= 現況 leader_bypass > 0）**

改 code 前先跑 bed 記 baseline：
```powershell
.\tools\godot.ps1 --headless --script scripts/debug/hand_obeys_brain_bed.gd
```
Expected（改前）：輸出含 `leader_bypass` 計數 **> 0**（leader 手 cascade 每 tick `note_bypass`）。**記下此數**（Task 2 目標 = 降到 0）。

- [ ] **Step 2: 拆 `_assign_tasks` 戰術 cascade → `_decide_unified(leader)`**

`scripts/simulation/faction_ai_system.gd`，`_assign_tasks`。**保留** header（1341-1349：leader_team null/combat/survival-sticky）+ player_commanded_task 迴圈（1352-1364）。**刪除** 徵收/外交/攻擊/掠奪 戰術 cascade + note_bypass。

現況（1366-1402）：
```gdscript
	if "徵收" in f.goals and leader_team.current_task != TeamData.TASK_TRIBUTE:
		var best_tid: int = _richest_member(state, f)
		if best_tid != -1:
			var target_pos: Vector2i = state.teams[best_tid].tile_pos
			var dist: int = _hex_dist(leader_team.tile_pos, target_pos)
			if dist > DISPATCH_DIST_THRESHOLD and leader_team.population >= 3 \
					and leader_team.named_members.size() > 0:
				var _sub_sys_pick := SubteamSystem.new()
				var sub_leader_id: int = _sub_sys_pick._pick_subteam_leader(state, leader_team, TeamData.TASK_TRIBUTE)
				if sub_leader_id == -1: sub_leader_id = leader_team.named_members[0]
				var pop_count: int = maxi(leader_team.population / 4, 2)
				_sub_sys_pick.dispatch(state, f.leader_team_id, sub_leader_id,
					pop_count, TeamData.TASK_TRIBUTE, target_pos)
			else:
				TaskArbiter.try_set(state, leader_team, TeamData.TASK_TRIBUTE, target_pos,
					TaskArbiter.PRIO_DISPATCH, "faction_tribute")
	if "立國" in f.goals:
		_declare_established(state, f, leader_team)
	if "外交" in f.goals and leader_team.current_task not in [TeamData.TASK_TRIBUTE, TeamData.TASK_DIPLOMACY, TeamData.TASK_ATTACK]:
		var target_id: int = _nearest_independent(state, leader_team)
		if target_id != -1:
			TaskArbiter.try_set(state, leader_team, TeamData.TASK_DIPLOMACY,
				state.teams[target_id].tile_pos, TaskArbiter.PRIO_DISPATCH, "faction_diplomacy")
	if "攻擊" in f.goals and leader_team.current_task not in [TeamData.TASK_TRIBUTE, TeamData.TASK_DIPLOMACY, TeamData.TASK_ATTACK]:
		var target_id: int = _nearest_independent(state, leader_team)
		if target_id != -1 and TaskArbiter.try_set(state, leader_team, TeamData.TASK_ATTACK,
				state.teams[target_id].tile_pos, TaskArbiter.PRIO_FACTION, "faction_goal"):
			print("[FactionAI] Team%d 主動攻擊 Team%d" % [f.leader_team_id, target_id])
	if "掠奪" in f.goals and leader_team.current_task not in [TeamData.TASK_TRIBUTE, TeamData.TASK_DIPLOMACY, TeamData.TASK_ATTACK, TeamData.TASK_LOOT]:
		var target_id: int = _nearest_independent(state, leader_team)
		if target_id != -1 and TaskArbiter.try_set(state, leader_team, TeamData.TASK_LOOT,
				state.teams[target_id].tile_pos, TaskArbiter.PRIO_FACTION, "faction_goal"):
			print("[FactionAI] Team%d 主動掠奪 Team%d" % [f.leader_team_id, target_id])
	if SimRunner.phase_timing: _ta = _fai_pht("assign.leader_goals", _ta)
	HandBrainProbe.note_bypass(state, leader_team, "leader")   # 手聽腦：leader 手寫 cascade 繞引擎計數（A2）
	_assign_member_tasks(state, f)
	if SimRunner.phase_timing: _fai_pht("assign.members", _ta)
```
改為（**保 立國 lifecycle-gate；戰術走引擎；刪 note_bypass**）：
```gdscript
	# A2b：立國=結構性 lifecycle gate（非戰術 option，不入引擎；同 A2a 戰略足跡=leader/faction 決定）。
	if "立國" in f.goals:
		_declare_established(state, f, leader_team)
	if SimRunner.phase_timing: _ta = _fai_pht("assign.leader_lifecycle", _ta)
	# A2b：leader 隊戰術執行走統一引擎（取代 徵收/外交/攻擊/掠奪 手 cascade + note_bypass）。
	# 徵收/外交(faction_duty)+攻擊(faction_duty+intent_fit 加成)+貿易/囤貨/生產/駐守/survival/threat 全 rank_scored 競秤。
	# 立國(上)已 pre-empt；player_cmd(上)PRIO_PLAYER 已蓋。conquest scaffolding faction_id==-1 leader 不觸。
	_decide_unified(state, leader_team)
	if SimRunner.phase_timing: _ta = _fai_pht("assign.leader_unified", _ta)
	_assign_member_tasks(state, f)
	if SimRunner.phase_timing: _fai_pht("assign.members", _ta)
```
- **注意**：`_declare_established` 從原 1382 位置**上移**到 player_cmd 之後、`_decide_unified` 之前（lifecycle 先於戰術，pre-empt）。刪掉的 `DISPATCH_DIST_THRESHOLD`/`SubteamSystem` tribute-detachment 分支＝00 sign-off 移除項（un-patch）。`_richest_member`/`_nearest_independent`/`DISPATCH_DIST_THRESHOLD` 若他處仍用則保留 const（grep 確認：`_richest_member` 在 `options.gd to_task 徵收`/`_conquest_viable` 仍用；`_nearest_independent` 在 `decision_context`/`options.gd` 仍用；**不刪這些 helper/const**）。

- [ ] **Step 3: 重建 class 快取**

Run:
```powershell
.\tools\godot.ps1 --headless --import
```
Expected: 無 GDScript 錯誤（綠）。

- [ ] **Step 4: TDD 驗證 — leader_bypass → 0**

Run:
```powershell
.\tools\godot.ps1 --headless --script scripts/debug/hand_obeys_brain_bed.gd
```
Expected（改後）：`leader_bypass` 計數 **→ 0**（手 cascade 消失，leader 現走 `unified` src）；`unified` src `decisions > 0`、obey 率高、背離率低；`determinism` 段 PASS。

- [ ] **Step 5: sanity — leader 仍 dispatch 三行為（保真）**

Run:
```powershell
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd
```
Expected: ≥1000 tick 無崩；引擎路 leader 徵收/外交/攻擊 仍發生（TASK_TRIBUTE/DIPLOMACY/ATTACK 出現於 sim；`[SubAI]`/`[FactionAI]` 或引擎 dispatch print）。**征服不消失、貢賦不塌**（守衛 A/B 的 sanity 前哨；硬驗在 QA 階段）。

- [ ] **Step 6: Commit**

```bash
git add scripts/simulation/faction_ai_system.gd
git commit -m "refactor(A2b): leader 隊戰術執行納統一引擎（拆 _assign_tasks 手 cascade + note_bypass，leader_bypass→0）"
```

---

### Task 3: 憲法閘 baseline 註記更新（D4）

**Files:**
- Modify: `scripts/debug/constitution_baseline.txt`（`_assign_tasks` 條 ≈line 15-16）
- Test: `scripts/debug/constitution_gate.gd`

**Interfaces:**
- Consumes: constitution_gate 讀 baseline（current ⊆ baseline，新 try_set 落點=FAIL）。
- Produces: baseline 反映 A2b（leader tactical→engine；`_assign_tasks` 本體只留 lifecycle/player_cmd dispatch）。

- [ ] **Step 1: 更新 `_assign_tasks` 註記**

`scripts/debug/constitution_baseline.txt`，現況（line 15-16）：
```
# 序6b dispatch（leader _assign_tasks 立國/subteam-tribute 特殊語意，defer 序6b）
scripts/simulation/faction_ai_system.gd::_assign_tasks
```
改為：
```
# A2b: leader 戰術→_decide_unified（引擎競秤）；_assign_tasks 本體只留 player_cmd(PRIO_PLAYER)+立國 lifecycle-gate（tactical cascade 已拆，note_bypass 移除）
scripts/simulation/faction_ai_system.gd::_assign_tasks
```
- `_assign_tasks` **保留在 baseline**（仍是合法 dispatch 協調點：player_cmd try_set + 立國 gate + 調度 `_decide_unified`/`_assign_member_tasks`）。A2b 未新增引擎外 task 落點（leader 戰術 try_set 現全經 `_decide_unified`，baseline 既有 `_decide_unified` 條涵蓋）。

- [ ] **Step 2: 憲法閘綠**

Run:
```powershell
.\tools\godot.ps1 --headless --script scripts/debug/constitution_gate.gd
```
Expected: PASS（current ⊆ baseline；無新增違憲 try_set 落點）。

- [ ] **Step 3: Commit**

```bash
git add scripts/debug/constitution_baseline.txt
git commit -m "chore(A2b): constitution baseline _assign_tasks 註記更新（leader tactical→engine）"
```

---

## QA 階段（implementer 後，量測員/QA 跑；非本 plan 的 TDD 步）

以下 spec 驗收硬項由 QA/量測員產（systems/implementer 不判）：
- **手聽腦 bed**：`leader_bypass→0`、`unified` obey 率、determinism PASS（已於 Task 2 Step 4 前哨驗）。
- **★守衛 A（00 硬閘）**：長跑 seeded（≥數千 tick）leader 征服**稀有但非零**（發起征服攻擊 count > 0）。=0 FAIL。
- **★守衛 B（00 硬閘）**：遠距 member（dist > 舊 DISPATCH_DIST_THRESHOLD）**仍有貢賦流入**（TRIBUTE 成交/treasury 增 > 0）。恆 0 FAIL。
- **target 保真**：攻擊=`_nearest_independent`、徵收=`_richest_member`、外交=`_nearest_independent` 同 A2b 前。
- **prio 降 regression**：leader 攻擊(PRIO_DISPATCH 50) 不 preempt threat(70)/survival(80)、無 latch。
- **效能**：per-tick tick-time 不顯著退化（≤5%，同 seed before/after）。
- **抖動檢**：leader intent 1 天內不亂換。

---

## Self-Review

**Spec coverage：**
- D1（leader→引擎）→ Task 2 ✓
- D2（純訊號分析，零 code 改）→ 無 task（by design，觸及檔總覽已註「不碰 decision_context/options/terms」）✓
- D3（intent cadence）→ Task 1 ✓
- D4（baseline 註）→ Task 3 ✓
- 驗收 #1-14 → Task 內 sanity/bed 前哨 + QA 階段段 ✓

**Placeholder scan：** 無 TBD/TODO；每 code step 附完整改前/改後原文；每測試步附 wrapper 指令 + expected。✓

**Type consistency：** `intent_eval_next_tick:int`（Task 1 定義）；`_decide_unified(state, team)`/`_assign_member_tasks(state, f)`/`_declare_established(state, f, leader_team)` 簽名對齊既有 code；`INTENT_CADENCE`/`TICK_PER_DAY` 型別一致。✓

**依賴序：** Task 1（cadence，獨立）→ Task 2（核心 route，依賴 f.intent 已 cadence 穩定但不強耦）→ Task 3（baseline，Task 2 拆完才反映）。每 task 獨立可測。✓
