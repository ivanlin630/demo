# wave1 序1：threat 子系統溶入引擎 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 把 `faction_ai_system.gd` 的 threat 手算 argmax（`_dispatch_threat_response`）溶進統一決策引擎——4 威脅反應成 REGISTRY option 由 term/weight 秤，刪手算，鏡射既有 survival 雙路（unified 主 rank / non-unified `rank_threat` slice）。**溶=融合非刪**：repertoire 沒少 + 該出現還出現。

**Architecture:** trigger/release scaffolding（idle-gated/cadence/FLEE_TIMEOUT/release）= 世界機制，保留。決策部分（scores dict + argmax + match-dispatch）= 撕除，換 `DecisionEngine.rank_threat` over `THREAT_OPTION_SET`。unified 隊 threat option 進主 REGISTRY 自然競爭；non-unified 隊 loop3 保 trigger、內部換引擎 rank。詳 `specs/2026-07-05-wave1-threat-dissolution.md`。

**Tech Stack:** Godot 4.2.2 GDScript；`tools/godot.ps1` wrapper；headless SceneTree 驗證腳本。

## Global Constraints

- **融合非刪鐵律（藍圖硬驗收）**：①repertoire 沒少——4 反應（FLEE/PREPARE/求和/DEFEND）每個仍可由對應人格達成（`threat_dissolution_check.gd` 5a 斷言）②該出現還出現——威脅存在時防守 dispatch 率 > 0，不被新權衡默默吃（5b 率表）。任一破 = 融合失敗，退回。
- **此 arc 張允許 seeded 漂移**：threat 融合改行為分佈，seeded 46/8/1/380 **可能變**。**不機械守恆**——先量測融合前後差（Task 0 baseline vs Task 9），漂移須可解釋（QA 判「新分佈合理非退化」）。**非漂移=可疑**（threat 融合理應有分佈影響）。
- **憲法閘同 commit 更新**：刪 `_dispatch_threat_response` → 指紋消失；dispatch 移入 `_evaluate_threat` → 新指紋。同 commit 更新 `constitution_baseline.txt`（pre-commit 閘會擋，須同落）。
- **跑測試用 wrapper**：`.\tools\godot.ps1 --headless ...`；新 class 後先 `--import`；`>` 重導向=UTF-16 用 `Select-String`。
- **weight 不可負**：GDScript weight 端負值會反轉語意；求和的 `−好戰` 項用 `maxf(0.3−好戰×0.3, 0)` clamp。

---

## File Structure

- `scripts/simulation/decision/decision_context.gd`（Modify）— Task 1：加 threat_react/threat_id/threat_pos/threat_threshold/is_resident 欄位 + gather 計算。
- `scripts/simulation/decision/terms.gd`（Modify）— Task 2：3 eval term + 3 weight key。
- `scripts/simulation/decision/options.gd`（Modify）— Task 3：3 REGISTRY option + applicable gate + to_task。
- `scripts/simulation/decision/decision_engine.gd`（Modify）— Task 4：`rank_threat` + `THREAT_OPTION_SET`。
- `scripts/simulation/faction_ai_system.gd`（Modify）— Task 5：`_evaluate_threat` 改寫 + 刪 `_dispatch_threat_response` + unified early-return + `_wire_threat_task`。
- `scripts/debug/threat_dissolution_check.gd`（Create）— Task 6：融合驗（repertoire + 率表）。
- `scripts/debug/constitution_baseline.txt`（Modify）— Task 8：指紋更新。

---

### Task 0: 量測融合前 baseline（融合驗基準錨）

**Files:** Create（暫時）: `scripts/debug/threat_rate_baseline.gd`
**Interfaces:** Consumes: `ThreatAssessment`, seeded warring bed。Produces: 融合前 threat-response 發生率 + seeded 分佈數字（記錄進 commit message + 本 plan 註記，供 Task 9 對照）。

- [ ] **Step 1: 錨 seeded 分佈**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "seeded warring"`
記錄：`teams=46 factions=8 established=1 pop=380`（融合前）。

- [ ] **Step 2: 量融合前 threat-response 率**

寫 `threat_rate_baseline.gd`：跑 seeded warring 1200 tick，計數 `_dispatch_threat_response` 每次觸發（插臨時計數 or 讀既有 `[ThreatResponse]` print），印 `THREAT_BASELINE: flee=N prepare=N pacify=N defend=N total=N`。
Run 並記錄 4 反應各自發生次數（Task 9 融合後每個必 > 0）。

- [ ] **Step 3: 記錄 + 刪暫時腳本**

把數字寫進 commit message。刪 `threat_rate_baseline.gd`（或留 debug/，但不進回歸鏈）。
```bash
git add -A && git commit -m "measure(threat): pre-fusion baseline — seeded 46/8/1/380, threat-response rates recorded"
```

---

### Task 1: DecisionContext 加 threat 欄位

**Files:** Modify: `scripts/simulation/decision/decision_context.gd`
**Interfaces:** Produces: `ctx.threat_react: float`、`ctx.threat_id: int`、`ctx.threat_pos: Vector2i`、`ctx.threat_threshold: float`、`ctx.is_resident: bool`。Consumes: `ThreatAssessment.score`、`ThreatAssessment.THREAT_BASE_THRESHOLD`、`state.team_discovered`、`team.leader_id`→慎重。

- [ ] **Step 1: 加欄位宣告**

於 DecisionContext 加 member：
```gdscript
var threat_react: float = 0.0     # 融合 threat 訊號（raw score over discovered，鏡射舊 _evaluate_threat）
var threat_id: int = -1
var threat_pos: Vector2i = Vector2i(-1, -1)
var threat_threshold: float = 0.0
var is_resident: bool = false
```

- [ ] **Step 2: gather 內計算（鏡射舊掃描）**

於 `DecisionContext.gather`（ctx.gd:63 附近，leader_values 已 duplicate 後）加：
```gdscript
	# 融合 threat：鏡射舊 _evaluate_threat 掃描（raw score over ALL discovered，含 approach/power 非純 hostility）
	var _caution: float = float(ctx.leader_values.get("慎重", 0.5))
	ctx.threat_threshold = ThreatAssessment.THREAT_BASE_THRESHOLD + _caution * 0.3
	var _best_t: float = 0.0
	var _best_id: int = -1
	for tid in state.team_discovered.get(team.team_id, []):
		if tid == team.team_id: continue
		var _other: TeamData = state.teams.get(tid)
		if _other == null: continue
		var _t: float = ThreatAssessment.score(state, team, _other)
		if _t > _best_t:
			_best_t = _t; _best_id = tid
	ctx.threat_react = _best_t
	ctx.threat_id = _best_id
	if _best_id != -1:
		var _ot: TeamData = state.teams.get(_best_id)
		if _ot != null: ctx.threat_pos = _ot.tile_pos
	ctx.is_resident = FactionAISystem.is_resident_static(state, team)   # 見 Step 3
```

- [ ] **Step 3: is_resident 靜態化（避免 ctx 依賴實例）**

`_is_resident_team`（fai.gd:477）現為實例 method。加 static wrapper（或改 static）供 ctx 呼叫：
```gdscript
static func is_resident_static(state: WorldState, team: TeamData) -> bool:
	if not team.tags.has(TeamData.TAG_PRODUCE): return false
	# ...複製 _is_resident_team 現有邏輯本體...
```
（實作者讀 fai.gd:477-490 現有 `_is_resident_team` 本體照搬進 static；原實例 method 改呼 static 避免雙寫。）

- [ ] **Step 4: 語法驗（import 無錯）**

Run: `.\tools\godot.ps1 --headless --import 2>&1 | Select-String "SCRIPT ERROR|error"`
Expected: 無 threat 相關 error（`_is_resident_team`/ctx 欄位可解析）。

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/decision/decision_context.gd scripts/simulation/faction_ai_system.gd
git commit -m "feat(decision): add threat_react/id/pos/threshold/is_resident to DecisionContext (mirror old threat scan)"
```

---

### Task 2: eval term + weight key（3+3）

**Files:** Modify: `scripts/simulation/decision/terms.gd`
**Interfaces:** Consumes: `ctx.threat_react`、`ctx.leader_values`（慎重/好戰/貪婪/信義）。Produces: eval `prepare_drive`/`defend_drive`/`pacify_drive`；weight `prepare`/`defend`/`pacify`。

- [ ] **Step 1: 加 eval term（opt-gated + threat-scaled）**

於 `terms.gd` eval() dispatch（trm.gd:34-119 區）加三 case：
```gdscript
		"prepare_drive":
			return ctx.threat_react if opt == "備戰" else 0.0
		"defend_drive":
			return maxf(1.0 - ctx.threat_react * 0.5, 0.3) if opt == "迎戰" else 0.0
		"pacify_drive":
			return ctx.threat_react if opt == "求和" else 0.0
```

- [ ] **Step 2: 加 weight key（人格 crosswalk，clamp≥0）**

於 `terms.gd` weight()（trm.gd:149-174 區）加三 case：
```gdscript
		"prepare":
			return 0.3 + float(v.get("慎重", 0.5)) * 0.6 + float(v.get("好戰", 0.5)) * 0.3
		"defend":
			return 0.2 + float(v.get("好戰", 0.5)) * 0.7
		"pacify":
			return 0.2 + float(v.get("貪婪", 0.5)) * 0.5 + float(v.get("信義", 0.5)) * 0.3 \
				+ maxf(0.3 - float(v.get("好戰", 0.5)) * 0.3, 0.0)
```
（`v` = weight() 內 leader_values 參數名，實作者對齊現有 case 的變數名。）

- [ ] **Step 3: import 驗**

Run: `.\tools\godot.ps1 --headless --import 2>&1 | Select-String "SCRIPT ERROR"`
Expected: 無 error。

- [ ] **Step 4: Commit**

```bash
git add scripts/simulation/decision/terms.gd
git commit -m "feat(decision): add prepare/defend/pacify eval terms + weight keys (threat repertoire personality crosswalk)"
```

---

### Task 3: REGISTRY option + applicable + to_task

**Files:** Modify: `scripts/simulation/decision/options.gd`
**Interfaces:** Consumes: Task 2 terms/weights、`ctx.threat_react`/`threat_threshold`/`is_resident`/`threat_pos`/`threat_id`。Produces: option 備戰/迎戰/求和 可 rank + to_task 映射。

- [ ] **Step 1: REGISTRY 加 3 option**

於 `REGISTRY`（opt.gd:5）加：
```gdscript
	"備戰":   [["prepare_drive", "prepare"]],
	"迎戰":   [["defend_drive", "defend"]],
	"求和":   [["pacify_drive", "pacify"]],
```

- [ ] **Step 2: applicable gate（threat-gated）**

於 `applicable()`（opt.gd:31-102）加三 case：
```gdscript
			"備戰":
				if ctx.threat_react >= ctx.threat_threshold: out.append(opt)
			"迎戰":
				if ctx.threat_react >= ctx.threat_threshold and not ctx.is_resident: out.append(opt)
			"求和":
				if ctx.threat_react >= ctx.threat_threshold: out.append(opt)
```

- [ ] **Step 3: to_task 加 3**

於 `to_task()`（opt.gd:108-170）加：
```gdscript
		"備戰": return {"task": TeamData.TASK_PREPARE, "target": Vector2i(-1, -1)}
		"迎戰": return {"task": TeamData.TASK_DEFEND, "target": ctx.threat_pos,
				"prosperity_target": ctx.threat_id}
		"求和": return {"task": TeamData.TASK_DIPLOMACY, "target": ctx.threat_pos,
				"order_target": ctx.threat_id, "order_task": TeamData.TASK_TRIBUTE_OFFER}
```
（注意：`to_task` 現簽名若不帶 ctx，需確認能取 threat_pos/id——實作者查 to_task 現簽名 `to_task(state, team, opt)`，threat_pos/id 需從 `DecisionContext.gather(state, team)` 取或改簽名帶 ctx。**改簽名風險大**（17 caller）→ 改為 to_task 內 `var ctx := DecisionContext.gather(state, team)` 局部取 threat 欄位。）

- [ ] **Step 4: import 驗**

Run: `.\tools\godot.ps1 --headless --import 2>&1 | Select-String "SCRIPT ERROR"`
Expected: 無 error。

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/decision/options.gd
git commit -m "feat(decision): register 備戰/迎戰/求和 options + threat-gated applicable + to_task"
```

---

### Task 4: DecisionEngine.rank_threat slice

**Files:** Modify: `scripts/simulation/decision/decision_engine.gd`
**Interfaces:** Consumes: `DecisionOptions.applicable`、`Terms.eval/weight`、`DecisionOptions.REGISTRY`。Produces: `rank_threat(ctx) -> Array`（threat option 降序）、`THREAT_OPTION_SET`。

- [ ] **Step 1: 加 THREAT_OPTION_SET + rank_threat（鏡射 rank_survival）**

讀 `rank_survival`（eng.gd:38-57）本體，鏡射寫 `rank_threat`：
```gdscript
const THREAT_OPTION_SET := ["survival", "備戰", "迎戰", "求和"]   # survival=FLEE

static func rank_threat(ctx) -> Array:
	# 鏡射 rank_survival：applicable ∩ THREAT_OPTION_SET，util 秤，降序。
	var scored: Array = []
	for opt in applicable(ctx):
		if not (opt in THREAT_OPTION_SET): continue
		var u: float = 0.0
		for tw in DecisionOptions.terms_of(opt):
			u += Terms.weight(tw[1], ctx.leader_values) * Terms.eval(tw[0], ctx, opt)
		scored.append({"opt": opt, "u": u})
	scored.sort_custom(func(a, b): return a.u > b.u)
	var out: Array = []
	for s in scored: out.append(s.opt)
	return out
```
（實作者對齊 rank_survival 的實際 helper 名——`Terms.weight/eval` or `_weight/_eval`，commitment 處理若 rank_survival 有則鏡射。）

- [ ] **Step 2: import + 單元驗（rank_threat 回非空）**

臨時 headless 斷言：造一隊高 threat_react + 好戰 leader，`rank_threat(ctx)[0]` == "迎戰"。可併進 Task 6 harness 提前寫。此步先確認 rank_threat 可呼叫不崩：
Run: `.\tools\godot.ps1 --headless --import 2>&1 | Select-String "SCRIPT ERROR"`
Expected: 無 error。

- [ ] **Step 3: Commit**

```bash
git add scripts/simulation/decision/decision_engine.gd
git commit -m "feat(decision): rank_threat slice + THREAT_OPTION_SET (mirror rank_survival)"
```

---

### Task 5: _evaluate_threat 改寫 + 刪 _dispatch_threat_response

**Files:** Modify: `scripts/simulation/faction_ai_system.gd`
**Interfaces:** Consumes: `DecisionEngine.rank_threat`、`DecisionOptions.to_task`、`DecisionContext.gather`。Produces: threat dispatch 走引擎；`_dispatch_threat_response` 刪除；unified 隊 loop3 threat early-return。

- [ ] **Step 1: unified 隊 early-return（鏡射 _trigger_survival）**

於 `_evaluate_threat`（fai.gd:358）開頭 cadence gate 後加（unified 隊 threat 由主 rank 處理，同 survival）：
```gdscript
	if team.tags.has(TeamData.TAG_MERCHANT) or team.tags.has(TeamData.TAG_PRODUCE):
		return   # unified 隊 threat 反應由 _decide_unified 主 rank 處理（鏡射 survival unified 排除）
```
（放在 `team.threat_eval_next_tick = ...` 設定之後、combat_target 檢查之前，避免 unified 隊仍消耗 cadence。實作者確認位置不破 release 路徑——若 unified 隊在 DEFEND/FLEE 中需 release，release 邏輯移到 early-return 前 or 由主 rank 的 commitment 處理。**保守：early-return 放 release 檢查之後**，只跳 dispatch。）

- [ ] **Step 2: 換 dispatch 呼叫**

`_evaluate_threat` 尾（fai.gd:390-391）現：
```gdscript
	if best_threat < threshold: return
	_dispatch_threat_response(state, team, best_id, best_threat)
```
換：
```gdscript
	if best_threat < threshold: return
	# 手算 argmax 撕除 → 引擎 rank_threat 秤（融合非刪）
	var ctx := DecisionContext.gather(state, team)
	for opt in DecisionEngine.rank_threat(ctx):
		var td: Dictionary = DecisionOptions.to_task(state, team, opt)
		if int(td.get("task", TeamData.TASK_IDLE)) == TeamData.TASK_IDLE: continue
		if not TaskArbiter.try_set(state, team, td["task"], td.get("target", Vector2i(-1,-1)),
				TaskArbiter.PRIO_THREAT, "threat"): continue
		_wire_threat_task(team, td)
		print("[ThreatResponse] Team%d → %s (threat=Team%d, u-rank)" % [team.team_id, opt, best_id])
		break
```

- [ ] **Step 3: 加 _wire_threat_task helper**

```gdscript
func _wire_threat_task(team: TeamData, td: Dictionary) -> void:
	if td.has("prosperity_target"): team.prosperity_target_id = int(td["prosperity_target"])
	if td.has("order_target"): team.order_target_id = int(td["order_target"])
	if td.has("order_task"): team.order_task = td["order_task"]
```

- [ ] **Step 4: 刪 _dispatch_threat_response**

刪除整個 `_dispatch_threat_response`（fai.gd:403-449）。`_flee_target`（fai.gd:451）若已無 caller（FLEE 現走 to_task survival→TASK_FLEE，target 由 mover 算）也刪；若 survival to_task 需 flee target 則保留並接進 to_task。**實作者確認 `_flee_target` caller**：grep，無 caller 則刪。

- [ ] **Step 5: import + seeded 冒煙（不崩、threat 仍 dispatch）**

Run: `.\tools\godot.ps1 --headless --import 2>&1 | Select-String "SCRIPT ERROR"`
Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "seeded warring|SCRIPT ERROR|ThreatResponse" | Select-Object -First 5`
Expected: 無 SCRIPT ERROR；seeded 跑完（分佈可能已漂，記錄新值）；`[ThreatResponse]` 仍出現（threat 沒死）。

- [ ] **Step 6: Commit（含 baseline，見 Task 8 先做或此處連做）**

見 Task 8——刪 `_dispatch_threat_response` 觸發 pre-commit 憲法閘（指紋變）。**Task 8 必須與本 commit 同批**，否則 commit 被閘擋。實作者：先做 Task 8 Step 1（更新 baseline）再 commit 本 Task：
```bash
git add scripts/simulation/faction_ai_system.gd scripts/debug/constitution_baseline.txt
git commit -m "refactor(faction_ai): dissolve _dispatch_threat_response into engine rank_threat (融合非刪) + gate baseline"
```

---

### Task 6: 融合驗 harness（★核心交付）

**Files:** Create: `scripts/debug/threat_dissolution_check.gd`
**Interfaces:** Consumes: `DecisionContext`、`DecisionEngine.rank_threat`、`ThreatAssessment`。Produces: repertoire 斷言（4 原型）+ 居民守衛 + 率表 hook。

- [ ] **Step 1: 寫 repertoire 驗（5a）**

Create `scripts/debug/threat_dissolution_check.gd`（`extends SceneTree`）：造 4 人格原型隊 + 同一逼近威脅（高 power 逼近敵，`team_discovered` 含之，belief 設好使 `ThreatAssessment.score ≥ threshold`），各跑 `DecisionEngine.rank_threat(ctx)`，斷言 `ranked[0]` == 預期：
```gdscript
# 原型表（leader values → 預期首選）
# 求生欲0.9/好戰0.1/慎重0.5 → survival(FLEE)
# 好戰0.9/慎重0.2/求生欲0.3 非居民 → 迎戰(DEFEND)
# 慎重0.9/好戰0.4/求生欲0.4 → 備戰(PREPARE)
# 貪婪0.8/信義0.7/好戰0.1 → 求和(pacify)
```
每 miss 印 `[FAIL] 原型X 預期 Y 得 Z`，計 fails。
+ 居民守衛：好戰居民隊 assert "迎戰" **不**在 `applicable(ctx)`。

- [ ] **Step 2: 跑 repertoire 驗**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/threat_dissolution_check.gd 2>&1 | Select-String "FAIL|PASS|repertoire"`
Expected: `[repertoire] PASS (4/4 + 居民守衛)`。任一 FAIL → 回 Task 2/3 調 weight/eval（融合驗是設計正確性閘，非事後）。

- [ ] **Step 3: 率表 hook（5b）**

於 harness 加 seeded warring 段（或獨立 func）：跑 seeded 1200 tick，計 `[ThreatResponse]` 各類發生數，assert **每類 > 0**（threat 存在時 4 反應都還會出現，對照 Task 0 baseline）。印 `[rate] flee=N prepare=N pacify=N defend=N`。
Run 並確認無類歸零（該出現還出現）。

- [ ] **Step 4: Commit**

```bash
git add scripts/debug/threat_dissolution_check.gd
git commit -m "test(threat): fusion verification — repertoire (4 archetypes) + rate table (該出現還出現)"
```

---

### Task 7: unified 隊 threat 路徑驗（主 rank 吃 threat option）

**Files:** （驗證，可能微調 Task 3 gating）
**Interfaces:** 驗 unified 隊（TAG_MERCHANT/PRODUCE）遇威脅在 `_decide_unified` 主 rank 選 threat option。

- [ ] **Step 1: 驗 unified 隊威脅反應**

於 `threat_dissolution_check.gd` 加：造 TAG_MERCHANT 好戰隊 + 逼近威脅，跑 `DecisionEngine.rank_scored(ctx)`（主 rank，非 rank_threat），assert 威脅存在時 "迎戰"/"求和"/"survival" 之一排進前列（不被貿易/掠奪完全壓過當威脅高）。
Run: `.\tools\godot.ps1 --headless --script scripts/debug/threat_dissolution_check.gd 2>&1 | Select-String "unified|FAIL"`
Expected: unified 隊威脅反應可達（threat option 在主 rank 競爭得動）。

- [ ] **Step 2: 若 unified 隊 threat 被日常決策完全壓過 → 調 threat term magnitude**

若 Step 1 顯示高威脅下 unified 隊仍選貿易（該出現沒出現）→ 提高 prepare/defend/pacify eval 的 threat_react 係數，或加 threat_react 到主 rank 的優先 tiebreak。記錄調整。Commit 若有調：
```bash
git add scripts/simulation/decision/terms.gd scripts/debug/threat_dissolution_check.gd
git commit -m "fix(decision): tune threat option magnitude so high-threat surfaces in unified main rank"
```

---

### Task 8: 憲法閘 baseline 更新

**Files:** Modify: `scripts/debug/constitution_baseline.txt`
**Interfaces:** 反映 `_dispatch_threat_response` 指紋消失 + `_evaluate_threat` 新 try_set 指紋。

- [ ] **Step 1: 更新 baseline（與 Task 5 commit 同批）**

跑閘看差異：
Run: `.\tools\godot.ps1 --headless --script scripts/debug/constitution_gate.gd 2>&1 | Select-String "removed|新增|CONSTITUTION-GATE"`
Expected（Task 5 改後）：`removed: faction_ai_system.gd::_dispatch_threat_response`（arc 進度 ✅）+ `新增: faction_ai_system.gd::_evaluate_threat`（dispatch 移入保留的 trigger func）。
更新 `constitution_baseline.txt`：移除 `_dispatch_threat_response` 行，加 `faction_ai_system.gd::_evaluate_threat`，標註：
```
# 序1 threat 溶入後 dispatch 落點（trigger 保留=世界機制，argmax 已撕→引擎 rank_threat）
scripts/simulation/faction_ai_system.gd::_evaluate_threat
```

- [ ] **Step 2: 驗閘 PASS**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/constitution_gate.gd 2>&1 | Select-String "CONSTITUTION-GATE"`
Expected: `[CONSTITUTION-GATE] PASS`（sites 數 = 32 − 0 或 ±，removed 1 add 1）。
（此 Task 的 baseline 改必須與 Task 5 的 code 改同 commit，見 Task 5 Step 6。本 Task 為說明拆出，實務合併。）

---

### Task 9: 回歸 + seeded 漂移評估（QA 交接）

**Files:** （驗證）
**Interfaces:** seeded、framework、憲法閘、融合驗。

- [ ] **Step 1: 全回歸**

Run 並記錄：
```
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "seeded warring|SCRIPT ERROR|DONE"
.\tools\godot.ps1 --headless --script scripts/debug/framework_validation.gd 2>&1 | Select-String "PASS=|DORMANT="
.\tools\godot.ps1 --headless --script scripts/debug/threat_dissolution_check.gd 2>&1 | Select-String "repertoire|rate|unified|FAIL"
.\tools\godot.ps1 --headless --script scripts/debug/constitution_gate.gd 2>&1 | Select-String "CONSTITUTION-GATE"
```
Expected: framework PASS=7、融合驗全 PASS、憲法閘 PASS、無 SCRIPT ERROR、headless DONE。

- [ ] **Step 2: seeded 漂移評估（不機械守恆）**

對照 Task 0 baseline：記錄融合後 seeded `teams/factions/established/pop`。**若漂移**：寫進 handback 給 QA 判「新分佈合理非退化」（threat 反應改由權重秤，分佈變預期；退化=某類反應歸零/世界崩壞）。**若零漂移**：可疑（threat 融合理應有影響），查 threat option 是否真的被選（率表 Task 6 Step 3 佐證）。

- [ ] **Step 3: handback 給系統（回報 + 融合驗結果 + seeded 差）**

寫 `docs/superpowers/handbacks/2026-07-05-wave1-threat-dissolution.md`：融合驗雙關結果、seeded 漂移數字、憲法閘 removed/add、連動風險（unified 隊 threat 時序、_flee_target 去留、訊號 reconcile 是否需藍圖回覆後改）。

---

## Self-Review

- **Spec coverage**：4a REGISTRY(Task3)✓、4b term(Task2)✓、4c weight(Task2)✓、4d applicable(Task3)✓、4e to_task(Task3)✓、4f ctx+訊號(Task1)✓、4g rank_threat(Task4)✓、4h _evaluate_threat 改寫+刪(Task5)✓、§5 融合驗(Task6/7)✓、§6 閘 baseline(Task8)✓。
- **融合驗 TDD-first**：Task 6 repertoire 驗是設計正確性閘（miss → 回調 term/weight），非事後裝飾。
- **憲法閘同 commit**：Task 5+8 合併 commit，pre-commit 閘不擋自己。
- **允許漂移非機械守恆**：Task 9 明列 seeded 漂移交 QA 判，非 assert 46/8/1/380。
- **風險標註**：to_task 簽名（Task3 Step3 用局部 gather 避改 17 caller）、unified early-return 位置（Task5 Step1 保守放 release 後）、_flee_target 去留（Task5 Step4 grep 定）、訊號 reconcile（待藍圖 threat-signal handback，預設可 merge）。
- **無 placeholder**：term/weight 公式、ctx 計算、rank_threat 本體、dispatch 迴圈全實碼。
