# wave1 序3：rung_task 溶入引擎 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `ambition_ladder.rung_task` `(archetype,rung)→task` 查表判斷器撕除 → rung/archetype 當 weight 驅動 option；idle-filler（fai:773）走引擎 rank；補唯一真缺的 訓練 option。**溶=融合非刪**。

**Architecture:** rung_task 冗餘部分（TRADE→貿易/SETTLE→生產/建設）既有 option 已覆蓋；唯一真缺=訓練(FORCE 累積階練兵)。序3=補訓練 option + idle-filler 換 rank_scored + 刪 rung_task。詳 `specs/2026-07-05-wave1-rung-task-dissolution.md`。

**Tech Stack:** Godot 4.2.2 GDScript；`tools/godot.ps1`；headless SceneTree。

## Global Constraints

- **融合非刪**：repertoire 沒少——訓練/貿易/生產/建設/讓位-prosperity 各可達；該出現還出現——練兵 dispatch>0、貿易 ambient 率保（`trade.dispatch.ambient` 不歸零）。
- **憲法**：archetype/rung 成 weight term（context），禁 `(archetype,rung)→task` 查表復活。
- seeded 漂移允許（現 52/8/1/380，QA wave 判）；framework PASS=7（S3 scout 不 DORMANT——序2 yield 閘須仍守）；threat/solo 融合驗不得破。
- wrapper 跑測試；`>` 用 `Select-String`；新 class `--import`。

## File Structure
- `scripts/simulation/decision/options.gd`（Modify）— 訓練 REGISTRY + applicable + to_task。
- `scripts/simulation/decision/terms.gd`（Modify）— train_drive eval + train weight。
- `scripts/simulation/decision/decision_context.gd`（Modify）— archetype/rung/has_trainable/ambient_train_drive。
- `scripts/simulation/faction_ai_system.gd`（Modify）— fai:773-786 idle-filler 換 rank_scored。
- `scripts/simulation/ambition_ladder.gd`（Modify）— 刪 rung_task。
- `scripts/debug/rung_dissolution_check.gd`（Create）— 融合驗。

---

### Task 0: baseline
- [ ] **Step 1:** Run seeded + 記錄練兵/貿易 ambient 率（`grep TASK_TRAIN`/`trade.dispatch.ambient` probe）：`.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "seeded warring"` → 52/8/1/380。寫暫時腳本量 rung_task 各 archetype dispatch 率，記錄。
- [ ] **Step 2:** commit `measure(rung): pre-fusion baseline`（刪暫時腳本）。

### Task 1: ctx archetype/rung/train 欄位
**Files:** Modify `decision_context.gd`
- [ ] **Step 1:** 加欄位 + gather 計算：
```gdscript
var archetype: String = ""
var rung: int = 0
var has_trainable: bool = false
var ambient_train_drive: float = 0.0
# gather：
c.archetype = team.ambition_archetype
c.rung = team.ambition_rung
c.has_trainable = _team_has_anon(team)   # 有 anon 可練（既有 anon_cohorts 非空判）
# FORCE 累積/擴張階 → 練兵 base（低 magnitude 讓位緊急決策）
if c.archetype == AmbitionLadder.ARCHETYPE_FORCE and team.ambition_rung in [AmbitionLadder.RUNG_ACCUMULATE, AmbitionLadder.RUNG_EXPAND]:
	c.ambient_train_drive = 0.5
```
- [ ] **Step 2:** import 驗無 SCRIPT ERROR。commit。

### Task 2: 訓練 option + train_drive term/weight
**Files:** Modify `options.gd`, `terms.gd`
- [ ] **Step 1:** options.gd：
```gdscript
# REGISTRY
"訓練":   [["train_drive", "train"]],
# applicable
"訓練":
	if ctx.archetype == AmbitionLadder.ARCHETYPE_FORCE and ctx.has_trainable: out.append(opt)
# to_task
"訓練": return {"task": TeamData.TASK_TRAIN, "target": team.tile_pos}
```
- [ ] **Step 2:** terms.gd：
```gdscript
"train_drive":
	if opt != "訓練": return 0.0
	return ctx.ambient_train_drive
# weight()
"train":
	return 0.3 + float(v.get("好戰", 0.5)) * 0.4 + float(v.get("野心", 0.5)) * 0.2
```
- [ ] **Step 3:** import 驗。commit `feat(decision): 訓練 option + train_drive term (FORCE-archetype 練兵溶入)`。

### Task 3: 融合驗 harness（TDD）
**Files:** Create `rung_dissolution_check.gd`
- [ ] **Step 1:** 寫 repertoire 驗：FORCE-累積隊(有兵)→`rank_scored` 含「訓練」可達且 idle 情境浮現；TRADE-archetype→貿易；SETTLE-累積→生產；SETTLE-擴張→建設；FORCE-擴張→不搶 prosperity（訓練 magnitude 低於攻擊/prosperity 讓位）。
- [ ] **Step 2:** Run，此時「訓練」option 已在（Task 2）→ 應 PASS repertoire。commit。

### Task 4: idle-filler 換引擎 rank + 刪 rung_task
**Files:** Modify `faction_ai_system.gd`, `ambition_ladder.gd`
- [ ] **Step 1:** fai:773-786 換：
```gdscript
	if team.current_task == TeamData.TASK_IDLE:
		var ctx := DecisionContext.gather(state, team)
		for opt in DecisionEngine.rank_scored(ctx):
			var td: Dictionary = DecisionOptions.to_task(state, team, opt)
			if int(td.get("task", TeamData.TASK_IDLE)) == TeamData.TASK_IDLE: continue
			if TaskArbiter.try_set(state, team, td["task"], td.get("target", Vector2i(-1,-1)), TaskArbiter.PRIO_AMBIENT, "ambition"):
				if td["task"] == TeamData.TASK_TRADE: Probe.bump("trade.dispatch.ambient")
				break
```
- [ ] **Step 2:** 刪 `ambition_ladder.gd` 的 `rung_task`（105-111 整函數）。grep 確認無其他 caller。
- [ ] **Step 3:** import + seeded 冒煙（無 SCRIPT ERROR、seeded 跑完、`TASK_TRAIN` 仍出現）。
- [ ] **Step 4:** commit `refactor: dissolve rung_task lookup into engine rank (idle-filler) + del 查表`。

### Task 5: 全回歸 + 憲法閘 + handback
- [ ] **Step 1:** 全驗：
```
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "seeded warring|SCRIPT ERROR|DONE"
.\tools\godot.ps1 --headless --script scripts/debug/framework_validation.gd 2>&1 | Select-String "PASS=|DORMANT="
.\tools\godot.ps1 --headless --script scripts/debug/rung_dissolution_check.gd 2>&1 | Select-String "PASS|FAIL"
.\tools\godot.ps1 --headless --script scripts/debug/threat_dissolution_check.gd 2>&1 | Select-String "ALL PASS|FAIL"
.\tools\godot.ps1 --headless --script scripts/debug/solo_dissolution_check.gd 2>&1 | Select-String "ALL PASS|FAIL"
.\tools\godot.ps1 --headless --script scripts/debug/constitution_gate.gd 2>&1 | Select-String "CONSTITUTION-GATE"
```
Expected: framework PASS=7 DORMANT=0（★S3 scout 不 DORMANT，序2 yield 仍守）、rung/threat/solo 融合驗綠、閘 PASS、seeded 跑完。
- [ ] **Step 2:** 記錄 seeded 漂移 + 練兵/貿易 ambient 率（對照 Task 0）。
- [ ] **Step 3:** handback `2026-07-05-wave1-rung-task-dissolution.md`：融合驗結果、seeded 漂移、練兵率、連動風險（idle-filler 走 rank 是否與序2 solo dispatch 重疊/衝突、faction member idle 隊行為）。

## Self-Review
- Spec coverage：4a 訓練 option(Task2)✓、4b term(Task2)✓、4c ctx(Task1)✓、4d idle-filler rank(Task4)✓、4e 刪 rung_task(Task4)✓、§5 融合驗(Task3/5)✓。
- 憲法：archetype/rung→weight（train_drive/ambient_train_drive），非查表塞 task。
- 冗餘識別：TRADE/SETTLE mapping 既有 option 覆蓋，只補訓練=最小改動。
- 風險：idle-filler rank 與序2 solo 重疊（solo 已派→loop3 不 idle→不重複；faction member idle→此填，序6 前橋）；has_trainable/ambient_train_drive magnitude TEST VALUE；S3 scout DORMANT 迴歸守（序2 yield）。
- 無 placeholder：option/term/ctx/rank 迴圈全實碼。
