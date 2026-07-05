# wave1 序3.5：threat preempt Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 忙碌目標對壓境攻擊者盲（idle-gate seam 斷）→ 強威脅 preempt 非緊急進行中 task → defensive 反應。門檻鎖「真能傷你」（threat_react 訊號=相對戰力+逼近+敵意），非「見武裝就恐慌」。接 approach→感知→反應因果脊椎，非新機制。

**Architecture:** 改 `_evaluate_threat` idle-gate（序1 scaffolding）：idle→原路；busy-preemptible + threat_react≥高 preempt 門檻→評估+PRIO_THREAT(70>DISPATCH 50)打斷 task；busy-urgent→不評（原行為）。詳 `specs/2026-07-05-wave1-threat-preempt.md`。

**Tech Stack:** Godot 4.2.2 GDScript；`tools/godot.ps1`；headless SceneTree。

## Global Constraints
- **WHAT bar（藍圖，雙關驗）**：①該出現——忙碌+壓境能殺攻擊者→放 task 反應 ②反向守——忙碌+路過弱/中立/帶刀商隊→**續 task 不抖動**。兩關綠。禁「見武裝就 preempt」。
- **preempt 門檻鎖「能傷你」由 threat_react 訊號滿足**（power_ratio+approach+hostility），禁另加 tag/label 判斷。
- **★感知鐵律（藍圖 encounter-north-star）**：preempt/反向守禁讀逼近者 `tags`/意圖。反向守（弱/中立/帶刀商隊不 preempt）由 threat_react 低分**自然**滿足（弱=power_ratio<1、中立=hostility≈0、路過=approach≤0），Task 1 反向 case 用 belief 表象+rep+非逼近設定，**禁設 tag 打折**。
- 不 preempt 已緊急（戰鬥/FLEE/DEFEND/PREPARE/survival）。
- seeded 漂移允許（現 48/8/1/380，defensive 反應升→漂移，QA wave 判）；framework PASS=7；threat/solo/rung 融合驗+live-seam 不破；憲法閘 PASS。
- wrapper 跑測試；`>` 用 Select-String；`--import` 新 class。

## File Structure
- `scripts/simulation/faction_ai_system.gd`（Modify）— `_evaluate_threat` gate + `PREEMPTIBLE_TASKS` + `_preempt_threshold` + `PREEMPT_MARGIN`。
- `scripts/debug/threat_preempt_check.gd`（Create）— 融合驗雙關。

---

### Task 0: baseline
- [ ] **Step 1:** seeded + 現 defensive threat dispatch 率：`.\tools\godot.ps1 --headless --script scripts/debug/threat_dissolution_check.gd 2>&1 | Select-String "rate\]|live\]"` 記錄（現 defensive≈0）。seeded 48/8/1/380。commit `measure(preempt): baseline`。

### Task 1: 融合驗 harness（TDD-first，反向守優先）
**Files:** Create `threat_preempt_check.gd`（承 scratchpad diagnostic 正式化）
- [ ] **Step 1:** 寫雙關驗（先失敗，因 preempt 未實作）：
  - **該出現**：忙碌目標（current_task=TASK_MANUFACTURE、好戰 leader、非居民、10 pop）+ 壓境攻擊者（40 武裝、敵意 rep、逼近、discovered）→ assert `_evaluate_threat` 後 current_task ∈ [FLEE/DEFEND/PREPARE/DIPLOMACY]（放下製造）。
  - **反向守 3**：忙碌目標 + (a)弱攻擊者（3 武裝，power_ratio<1）→ assert 續 TASK_MANUFACTURE；(b)中立帶刀商隊（rep=1.0 友好、有武器、非逼近）→ 續製造；(c)逼近但弱→續製造。
- [ ] **Step 2:** Run，該出現 **FAIL**（preempt 未實作，忙碌隊不反應）、反向守 **PASS**（本就不反應）。此 FAIL=Task 2 目標。commit。

### Task 2: preempt gate + 門檻 + task 集
**Files:** Modify `faction_ai_system.gd`
- [ ] **Step 1:** 加常數 + helper（近 THREAT_CADENCE 常數區 + _evaluate_threat 附近）：
```gdscript
const PREEMPT_MARGIN: float = 0.5   # TEST VALUE：preempt 門檻 = threat_threshold + 此（只壓境級打斷工作）
const PREEMPTIBLE_TASKS: Array = [
	TeamData.TASK_MANUFACTURE, TeamData.TASK_BUILD, TeamData.TASK_TRADE,
	TeamData.TASK_GOVERN, TeamData.TASK_TRAIN, TeamData.TASK_FORAGE,
	TeamData.TASK_MOVE, TeamData.TASK_CAMP,
]
```
- [ ] **Step 2:** 改 `_evaluate_threat` gate（現 fai:375 `if team.current_task != TASK_IDLE: return` + 其後 unified skip + ctx gather + threshold）。換：
```gdscript
	var _busy_preemptible: bool = team.current_task in PREEMPTIBLE_TASKS
	if team.current_task != TeamData.TASK_IDLE and not _busy_preemptible:
		return   # 忙且不可 preempt（戰鬥/social/緊急）→ 原行為
	var ctx: DecisionContext = DecisionContext.gather(state, team)
	if team.current_task == TeamData.TASK_IDLE:
		if uses_unified(team): return                       # idle unified 由主 rank
		if ctx.threat_react < ctx.threat_threshold: return  # 一般門檻
	else:
		# busy-preemptible：高門檻，只壓境能傷你才打斷工作（unified 亦走此，忙碌時主 rank 不重跑）
		if ctx.threat_react < ctx.threat_threshold + PREEMPT_MARGIN: return
	# 既有序1 rank_threat dispatch 迴圈（不變）...
	for opt in DecisionEngine.rank_threat(ctx): ...
```
（保留原 REVOLT + DEFEND/PREPARE/FLEE/HOLD release 檢查在此前。實作對齊現 _evaluate_threat 結構，只換 idle-gate 那段。）
- [ ] **Step 3:** import 驗無 SCRIPT ERROR。
- [ ] **Step 4:** Run harness：該出現轉 **PASS**（忙碌目標遇壓境→反應）+ 反向守仍 **PASS**（弱/中立/帶刀商隊不 preempt）。任一破→調 PREEMPT_MARGIN（該出現不觸→降；反向誤觸→升）。commit `feat(faction_ai): threat preempt — 強威脅打斷非緊急task(接approach→感知→反應,門檻鎖能傷你)`。

### Task 3: 回歸 + 反龜縮驗 + handback
- [ ] **Step 1:** 全驗：
```
.\tools\godot.ps1 --headless --script scripts/debug/threat_preempt_check.gd 2>&1 | Select-String "PASS|FAIL"
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "seeded warring|SCRIPT ERROR|DONE"
.\tools\godot.ps1 --headless --script scripts/debug/framework_validation.gd 2>&1 | Select-String "PASS=|DORMANT="
.\tools\godot.ps1 --headless --script scripts/debug/threat_dissolution_check.gd 2>&1 | Select-String "ALL PASS|FAIL|rate\]"
.\tools\godot.ps1 --headless --script scripts/debug/solo_dissolution_check.gd 2>&1 | Select-String "ALL PASS|FAIL"
.\tools\godot.ps1 --headless --script scripts/debug/rung_dissolution_check.gd 2>&1 | Select-String "ALL PASS|FAIL"
.\tools\godot.ps1 --headless --script scripts/debug/constitution_gate.gd 2>&1 | Select-String "CONSTITUTION-GATE"
```
Expected: preempt 雙關 PASS、framework PASS=7、threat/solo/rung 融合驗綠、閘 PASS、seeded 跑完。
- [ ] **Step 2:** ★反龜縮驗：記錄 seeded defensive threat dispatch 率（`threat.dispatch.*` 或 rate 表）——preempt 後應從 ≈0 **回升**（忙碌目標現反應壓境攻擊，offensive 22.5% 下游顯化）。記錄前後 + seeded 漂移。
- [ ] **Step 3:** handback `2026-07-05-wave1-threat-preempt.md`：雙關驗結果、反龜縮 defensive 率回升數字、PREEMPT_MARGIN 值、seeded 漂移、連動風險（preempt 是否過抖動/task churn、unified preempt 行為）。

## Self-Review
- Spec coverage：4 gate(Task2)✓、4a PREEMPTIBLE_TASKS(Task2)✓、4b _preempt_threshold(Task2 inline)✓、4c PRIO(已驗 70>50)✓、4d unified(Task2 gate)✓、§5 雙關驗(Task1/3)✓。
- WHAT bar：門檻由 threat_react 訊號（power/approach/hostility）滿足「能傷你」，無 tag/label；反向守 3 case 驗防抖動。
- TDD-first：Task1 反向守先綠（本就不反應）、該出現先 FAIL→Task2 轉綠。
- 風險：PREEMPT_MARGIN TEST VALUE（抖動 vs 靈敏）、unified preempt 走 rank_threat（idle 走主 rank 的語意差異，序2 已有同型註釋）、preempt task churn 頻率（PRIO_THREAT 打斷後 release 回原 task？—release 檢查回 idle 非原 task，實作記錄行為）。
- 無 placeholder：gate/門檻/task 集/harness 全實碼。
