# wave1 序2：solo 溶入引擎 + capability-grounded attack Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `_evaluate_solo` 手算 argmax 溶進引擎 `rank_scored`（鏡射 `_decide_unified`）；去 `_tag_weight` hard-gate（tag 不硬鎖）；attack/loot eval capability-grounded（吃 self 戰力，無牙商隊自然不攻=送死非被禁）。**溶=融合非刪** + 藍圖 tag-soft-ruling。

**Architecture:** solo 非 unified 分支的 scores-dict-argmax 撕除 → `DecisionEngine.rank_scored`；idle-gate/stuck/承諾/征服 Probe scaffolding 保留。capability-grounding = 新 `self_armed_ratio` 因子進 prey-weakness 判定（改比 self ARMED 非 POP）+ attack/loot eval capability_factor 閘。詳 `specs/2026-07-05-wave1-solo-dissolution.md`。

**Tech Stack:** Godot 4.2.2 GDScript；`tools/godot.ps1`；headless SceneTree。

## Global Constraints

- **融合非刪 + 反向（藍圖硬驗收）**：①repertoire 沒少——9 反應（攻擊/掠奪/外交/survival/生產/貿易/駐守/紮營/投靠）各可達 ②該出現還出現含**反向**——無牙商隊**不**劫匪化（攻擊/掠奪≈0）、重甲商隊絕境可揮刀、軍隊不變雜貨商。率表證。任一破=融合失敗。
- **capability-grounding 非 tag-label**：只加 self-戰力**事實**進 eval，**禁**加「商隊 tag→禁攻」label 判斷（那違憲）。tag 完全不進 gate。
- **seeded 漂移允許**：solo 融合改分佈，seeded（現 48/8/1/382）可能再漂 → QA wave 級判，非機械守恆。先量測前後差記錄。
- **unified 側行為守恆**：capability-grounding 進共用 eval → unified 隊也受影響（無牙 unified 商隊也趨不攻=更對），但 unified 有牙隊行為不應退化。驗 unified 路徑 threat/attack 仍正常。
- **憲法閘同 commit**：`_evaluate_solo` 指紋若變同 commit 更新 baseline。
- wrapper 跑測試；新 class `--import`；`>` 用 `Select-String`。

---

## File Structure

- `scripts/simulation/decision/decision_context.gd`（Modify）— Task 2：`self_armed_ratio` + capability grounding 進 prey-weakness / has_weak_prey。
- `scripts/simulation/decision/terms.gd`（Modify）— Task 2：loot_drive / _intent_fit 攻擊 疊 capability_factor。
- `scripts/simulation/faction_ai_system.gd`（Modify）— Task 3：`_evaluate_solo` 非 unified 分支 argmax→rank_scored + 去 `_tag_weight` + 保 scaffolding；prey-weakness self-ARMED 修。
- `scripts/debug/solo_dissolution_check.gd`（Create）— Task 4：融合驗 + 反向驗。
- `scripts/debug/constitution_baseline.txt`（Modify）— Task 5。

---

### Task 0: 量測融合前 baseline

**Files:** Create（暫時）: `scripts/debug/solo_rate_baseline.gd`
**Interfaces:** Produces: 融合前 solo 隊 task 分佈（尤其商隊 vs 軍隊隊的攻擊/掠奪率）+ seeded 分佈，記錄供 Task 6 對照。

- [ ] **Step 1: 錨 seeded + solo 分佈**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "seeded warring"`
記錄 `48/8/1/382`。寫 `solo_rate_baseline.gd`：seeded 1200t，計 solo dispatch（`[SoloAI]` print or Probe）分 tag 統計商隊/軍隊隊各 task 次數。記錄「商隊攻擊/掠奪率」「軍隊攻擊率」baseline（Task 6 反向驗對照）。

- [ ] **Step 2: 記錄 + commit**

數字寫 commit message，刪暫時腳本。
```bash
git add -A && git commit -m "measure(solo): pre-fusion baseline — seeded 48/8/1/382, solo task dist by tag recorded"
```

---

### Task 1: 融合驗 harness 骨架（TDD-first，先寫驗再實作）

**Files:** Create: `scripts/debug/solo_dissolution_check.gd`
**Interfaces:** Consumes: `DecisionContext`, `DecisionEngine.rank_scored`, `ResourceSystem`。Produces: repertoire + 反向 斷言（先失敗，驅動 Task 2-3）。

- [ ] **Step 1: 寫 repertoire + 反向驗（會失敗，因 capability grounding 未實作）**

Create `scripts/debug/solo_dissolution_check.gd`（`extends SceneTree`，鏡射 threat_dissolution_check 風格）：
- **6a repertoire**：人格×情境原型，assert `rank_scored(ctx)[0]` 對應——好戰野心+有戰兵+弱prey→攻擊；貪婪+弱prey+有戰兵→掠奪；貪婪+市場→貿易；慎重+own outpost(vault<target)→駐守；求生欲+無own+farmable→紮營；義氣+strong neighbor→投靠；絕境→survival。
- **6b 反向（capability）**：
  - 無牙商隊（好戰0.2、**無 weapon 無戰兵 anon**）+ 弱prey → assert 攻擊/掠奪 **不**在 `rank_scored(ctx)[0]`（capability≈0 壓平）。
  - 重甲商隊（好戰0.3、**有戰兵/weapon**）+ 絕境 + 弱prey → assert 掠奪可進前列。
  - 軍隊（好戰0.9、有戰兵）→ assert 攻擊/patrol 傾向在，非誤貿易。
印 `[FAIL]`/計數，末 `[solo-dissolution] PASS/FAIL`。

- [ ] **Step 2: 跑（預期部分 FAIL——反向驗因 grounding 未實作）**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/solo_dissolution_check.gd 2>&1 | Select-String "FAIL|PASS"`
Expected: 反向驗「無牙商隊不攻」**FAIL**（現引擎無 self-armed grounding，無牙商隊仍可能選攻擊/掠奪）。此 FAIL = Task 2 要修的目標。

- [ ] **Step 3: Commit（驗先行）**

```bash
git add scripts/debug/solo_dissolution_check.gd
git commit -m "test(solo): fusion + reverse verification harness (capability grounding target = reverse FAIL)"
```

---

### Task 2: capability-grounding（self-armed 進 attack/loot eval）

**Files:** Modify: `scripts/simulation/decision/decision_context.gd`、`scripts/simulation/decision/terms.gd`
**Interfaces:** Produces: `ctx.self_armed_ratio`；prey-weakness 改比 self ARMED；loot_drive/_intent_fit 攻擊 疊 capability_factor。

- [ ] **Step 1: 定位 self 戰力估既有 helper**

grep 既有 self combat strength 估（threat_assessment self_power=pop×avg_combat_skill、armed_anon、effective_armed）：
Run: `.\tools\godot.ps1` 前先 grep：`grep -rn "avg_combat_skill\|armed_anon\|effective_armed\|self_power\|combat_strength" scripts/simulation/`
選最貼「有效武裝力」的（優先既有 armed anon + weapon 裝備和）。記其 API。

- [ ] **Step 2: ctx.self_armed_ratio**

於 `DecisionContext.gather`（ctx.gd）加：
```gdscript
	# capability grounding（藍圖 tag-soft-ruling）：self 有效武裝比 → attack/loot「打得動嗎」
	var _armed: float = <既有 self armed 估，Step 1 選定>   # 例 ThreatAssessment.self_power or armed_anon 和
	c.self_armed_ratio = _armed / maxf(float(team.population), 1.0)
```
加欄位宣告 `var self_armed_ratio: float = 0.0`。

- [ ] **Step 3: prey-weakness 改比 self ARMED（fai.gd:186-187）**

`find_prosperity_prey` weakness 現 `1 − armed_est / team.population` → 改比 self armed：
```gdscript
		var self_armed_f: float = <self armed 估，同 Step 1 API>
		var weakness: float = clampf(
			1.0 - armed_est / maxf(self_armed_f, 1.0),
			0.0, 1.0)
```
→ 無牙商隊 self_armed≈0 → weakness→0（prey 不再相對弱）→ `_find_weakest_prey` 不選 → has_weak_prey=false。

- [ ] **Step 4: loot_drive / _intent_fit 攻擊 疊 capability_factor**

於 `terms.gd`：
```gdscript
# loot_drive（opt=掠奪）
		"loot_drive":
			if opt != "掠奪": return 0.0
			var cap: float = clampf(ctx.self_armed_ratio / VIABLE_ARMED_RATIO, 0.0, 1.0)
			return (LOOT_DRIVE_BASE if ctx.has_weak_prey else 0.0) * cap
```
`_intent_fit` 的 `攻擊`/`掠奪` boost 分支同乘 `clampf(ctx.self_armed_ratio / VIABLE_ARMED_RATIO, 0, 1)`。
加常數 `const VIABLE_ARMED_RATIO := 0.3   # TEST VALUE：有效武裝比達此→capability 足`（待平衡校）。

- [ ] **Step 5: 反向驗轉綠**

Run: `.\tools\godot.ps1 --headless --import 2>&1 | Select-String "SCRIPT ERROR"`
Run: `.\tools\godot.ps1 --headless --script scripts/debug/solo_dissolution_check.gd 2>&1 | Select-String "FAIL|PASS"`
Expected: 反向驗「無牙商隊不攻」轉 **PASS**；「重甲商隊絕境可揮刀」PASS；repertoire 仍 PASS。若無牙商隊仍攻→查 grounding 未接上；若重甲商隊也不攻→VIABLE_ARMED_RATIO 太高調低。

- [ ] **Step 6: Commit**

```bash
git add scripts/simulation/decision/decision_context.gd scripts/simulation/decision/terms.gd scripts/simulation/faction_ai_system.gd
git commit -m "feat(decision): capability-grounded attack/loot eval (self-armed ratio; unarmed→no suicide-attack, 憲法世界事實非label)"
```

---

### Task 3: _evaluate_solo argmax → rank_scored + 去 tag hard-gate

**Files:** Modify: `scripts/simulation/faction_ai_system.gd`
**Interfaces:** Consumes: `DecisionEngine.rank_scored`, `DecisionOptions.to_task`, `_wire_threat_task`（序1）。Produces: solo 非 unified 走引擎；scores dict + argmax + `_tag_weight` 乘數刪。

- [ ] **Step 1: 換非 unified 分支**

`_evaluate_solo`（fai.gd:1719 idle-gate 後）的 `var martial...` 到 argmax（1722-1770）換：
```gdscript
	var ctx := DecisionContext.gather(state, team)
	for opt in DecisionEngine.rank_scored(ctx):
		var td: Dictionary = DecisionOptions.to_task(state, team, opt)
		if int(td.get("task", TeamData.TASK_IDLE)) == TeamData.TASK_IDLE: continue
		if not TaskArbiter.try_set(state, team, td["task"],
				td.get("target", Vector2i(-1,-1)), TaskArbiter.PRIO_DISPATCH, "solo"): continue
		_wire_threat_task(team, td)
		team.solo_task_last = td["task"]
		# 征服名實 probe（保留）
		if Probe.enabled and _solo_type(team) == "征服":
			Probe.bump("conq.intent")
			match opt:
				"攻擊": Probe.bump("conq.winner_prosperity")
				"掠奪": Probe.bump("conq.winner_loot")
				_: Probe.bump("conq.winner_other")
		team.current_option = opt   # 承諾（引擎 COMMITMENT_BONUS 讀）
		break
```
（idle-gate `if team.current_task != IDLE and not _is_stuck: return`、玩家隊排除、combat_target 排除、unified early-return 全**保留**在此前。）

- [ ] **Step 2: 刪 scores dict + argmax + 舊 helper caller**

刪 fai.gd:1722-1770 舊 scores 建構 + argmax。`_tag_weight` 乘數消失。**grep `_tag_weight` 其他 caller**（subteam idle 1690 仍用）：
Run 前 grep：`grep -n "_tag_weight" scripts/simulation/faction_ai_system.gd`
- 若只剩 subteam(1690) → `_tag_weight` 保留（subteam 另軌，F-D5 scope）。
- solo 分支不再呼 `_tag_weight`。

- [ ] **Step 3: import + seeded 冒煙**

Run: `.\tools\godot.ps1 --headless --import 2>&1 | Select-String "SCRIPT ERROR"`
Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "seeded warring|SCRIPT ERROR|SoloAI" | Select-Object -First 5`
Expected: 無 SCRIPT ERROR；seeded 跑完（分佈可能漂，記錄）；solo dispatch 仍發生。

- [ ] **Step 4: Commit（含 Task 5 baseline 同批）**

見 Task 5——`_evaluate_solo` 指紋若變 pre-commit 閘擋，須同 commit。
```bash
git add scripts/simulation/faction_ai_system.gd scripts/debug/constitution_baseline.txt
git commit -m "refactor(faction_ai): dissolve _evaluate_solo argmax into rank_scored + drop _tag_weight hard-gate (融合非刪) + gate baseline"
```

---

### Task 4: 融合驗全綠 + unified 守恆驗

**Files:** Modify: `scripts/debug/solo_dissolution_check.gd`
**Interfaces:** 驗 repertoire + 反向 + unified 側不退化。

- [ ] **Step 1: 補 unified 守恆驗**

於 harness 加：有牙 unified 商隊（TAG_MERCHANT + 戰兵）遇弱prey/威脅 → assert 行為合理（貿易為主、有本錢時可防/攻，非因 capability grounding 誤癱瘓）。無牙 unified 商隊 → 趨不攻（同 solo，一致）。

- [ ] **Step 2: 跑全驗**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/solo_dissolution_check.gd 2>&1 | Select-String "PASS|FAIL"`
Expected: repertoire PASS + 反向 PASS + unified 守恆 PASS = `[solo-dissolution] ALL PASS`。

- [ ] **Step 3: Commit**

```bash
git add scripts/debug/solo_dissolution_check.gd
git commit -m "test(solo): unified conservation check + full fusion/reverse green"
```

---

### Task 5: 憲法閘 baseline

**Files:** Modify: `scripts/debug/constitution_baseline.txt`
**Interfaces:** `_evaluate_solo` 指紋確認。

- [ ] **Step 1: 跑閘看差異**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/constitution_gate.gd 2>&1 | Select-String "removed|新增|CONSTITUTION-GATE"`
`_evaluate_solo` 仍有 `TaskArbiter.try_set`（trigger 保留、dispatch 仍此 func）→ 指紋 `faction_ai_system.gd::_evaluate_solo` 應**不變**（solo dispatch 一直在此 func）。若 gate 報變 → 更新 baseline 標 `# 序2 solo 溶入`。與 Task 3 同 commit。

- [ ] **Step 2: 閘 PASS**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/constitution_gate.gd 2>&1 | Select-String "CONSTITUTION-GATE"`
Expected: `[CONSTITUTION-GATE] PASS`。

---

### Task 6: 回歸 + seeded 漂移 + handback

**Files:**（驗證 + handback）

- [ ] **Step 1: 全回歸**

```
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "seeded warring|SCRIPT ERROR|DONE"
.\tools\godot.ps1 --headless --script scripts/debug/framework_validation.gd 2>&1 | Select-String "PASS=|DORMANT="
.\tools\godot.ps1 --headless --script scripts/debug/solo_dissolution_check.gd 2>&1 | Select-String "PASS|FAIL"
.\tools\godot.ps1 --headless --script scripts/debug/threat_dissolution_check.gd 2>&1 | Select-String "ALL PASS|FAIL"
.\tools\godot.ps1 --headless --script scripts/debug/constitution_gate.gd 2>&1 | Select-String "CONSTITUTION-GATE"
```
Expected: framework PASS=7、solo/threat 融合驗 ALL PASS、閘 PASS、headless DONE、無 SCRIPT ERROR。（threat 驗必須仍綠——solo 改動 capability grounding 進共用 eval，勿破 threat。）

- [ ] **Step 2: seeded 漂移 + 商隊率**

記錄融合後 seeded vs 48/8/1/382；記錄商隊隊攻擊率（對照 Task 0，應≈0 除絕境有本錢）、軍隊攻擊率（保持）。

- [ ] **Step 3: handback**

寫 `docs/superpowers/handbacks/2026-07-05-wave1-solo-dissolution.md`：融合+反向驗結果、capability-grounding 效果（商隊率≈0 證）、VIABLE_ARMED_RATIO 選值、seeded 漂移、unified 守恆、連動風險（_tag_weight subteam 殘留、self-armed helper 選擇、tag 軟 context 是否足）。

---

## Self-Review

- **Spec coverage**：§3 capability-grounding(Task2)✓、§4 tag hard-gate 移除(Task3)✓、§5 argmax→rank_scored(Task3)✓、§6 融合+反向驗(Task1/4)✓、§7 閘(Task5)✓。
- **TDD-first 反向驗**：Task 1 先寫反向驗（預期 FAIL）→ Task 2 grounding 轉綠 = capability-grounding 是被驗驅動，非事後。
- **憲法守則**：capability = self-戰力事實進 eval（Task2），非 tag-label 判斷；tag 完全不進 gate（Task3 去 _tag_weight）。
- **unified 守恆**：Task4 Step1 驗 capability grounding 不癱瘓有牙 unified 隊 + threat 驗仍綠(Task6)。
- **允許漂移**：Task6 seeded 交 QA wave 級，非機械守恆。
- **風險標註**：self-armed helper 選擇(Task2 Step1 grep)、_tag_weight subteam 殘留(Task3 Step2)、VIABLE_ARMED_RATIO TEST VALUE、征服 probe 映射保 conq.* 語意。
- **無 placeholder**：ctx 計算、weakness 修、capability_factor、rank_scored 迴圈全實碼。
