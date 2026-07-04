# Q7-4 玩家 anon→named 拔擢 command Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 加玩家 `promote_anon` command（拔擢 1 anon → named）+ UI 入口，補對稱性——NPC 缺 named 時自動拔擢（`person_generator.generate_for_team`），玩家無對應 → 全 anon 隊永遠無法派子隊/任命。

**Architecture:** 通用模型——**復用既有 NPC 拔擢路徑** `PersonGenerator.generate_for_team`（已含「從 anon 桶移除 1 + treasury×3 bonus」），玩家 command 走同函數,不另寫平行邏輯。

**Tech Stack:** Godot 4.2.2 GDScript。閘 = `headless_test.gd` + `ui_flow_test.gd` + `game_sim_multi.gd`（coin_eq=0、全 invariant 0）。

> **Q7 系列**：Q7-1/2 ✅、Q7-3/5/6（UI wiring plan）。本 plan=Q7-4。

**前置（強制）：** `git worktree add .worktrees/q7-4 -b feat/q7-4 && cd .worktrees/q7-4`
**Baseline：** `headless_test.gd` `=== DONE ===`、`ui_flow_test.gd` 綠。

---

## 既有契約（研究確認）
- `PersonGenerator.generate_for_team(state, team, role, seed) -> PersonData`（:46）：`anon_pop<=0` 回 null;否則生 named（含 treasury share×3 bonus + `kill_random(team,1,"promote")` 從 anon 桶移除 1）+ 加 `state.persons`。**caller 負責設 leader_id 或 append named_members**。
- NPC 用例：`faction_ai_system.gd:389` 缺 named leader 時呼此 + 設 leader_id。

---

## Task 1: _action_promote_anon command

**Files:** Modify `scripts/simulation/player_command_system.gd`（actions dict :90+ 區 + 新 func）

- [ ] **Step 1: 加 command + 註冊**

actions dict（player_command:90+ 的 registered actions）加 `"promote_anon": _action_promote_anon,`。新 func：
```gdscript
func _action_promote_anon(state: WorldState, _target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	# anon 可拔擢數 = anon 總數（需 >0）
	if AnonTierSystem.total_pop(pt) <= 0:
		return { "ok": false, "msg": "無匿名兵可拔擢" }
	var p: PersonData = PersonGenerator.generate_for_team(state, pt, "member")
	if p == null:
		return { "ok": false, "msg": "拔擢失敗（無可拔擢 anon）" }
	pt.named_members.append(p.id)   # caller 設 named（leader 不變,新增 named 成員）
	return { "ok": true, "msg": "拔擢 %s 為記名成員" % p.person_name }
```
> `generate_for_team` 已從 anon 桶移除 1 + 加 state.persons + treasury bonus。本 command 只 append named_members（population getter 自動：anon-1、named+1,總 pop 不變,守恆）。

- [ ] **Step 2: headless** Expected: `=== DONE ===`,無 SCRIPT ERROR。
- [ ] **Step 3: Commit** `git commit -am "feat(player): promote_anon command 拔擢 anon→named（復用 generate_for_team）"`

---

## Task 2: UI 入口

**Files:** Modify `scripts/ui/text_ui_main.gd`（self-action 或成員面板）

- [ ] **Step 1: 加 UI 入口**

把 `promote_anon` 接進玩家自隊動作 UI（**讀** text_ui_main 的 self-actions / 成員面板顯示處,mirror 既有 self-action 如 train/camp 的接線）。顯示條件：玩家隊有 anon（`AnonTierSystem.total_pop(pt) > 0`）。選後派 command `promote_anon`（無需 target）。

> mirror 既有無 target 的 self-action（train/camp）UI 模式。`_test_action_ui_coverage` 應自動納入（promote_anon 進 registry）。

- [ ] **Step 2: ui_flow + headless** Expected: 綠、`_test_action_ui_coverage` 含 promote_anon。
- [ ] **Step 3: Commit** `git commit -am "feat(ui): promote_anon self-action 入口"`

---

## Task 3: 回歸 + hand-back

- [ ] **Step 1: 全回歸**
```powershell
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
.\tools\godot.ps1 --headless --script scripts/debug/ui_flow_test.gd
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd
```
Expected: 全 `=== DONE ===`、ui_flow errors:0、coin_eq=0、全 invariant 0、無 SCRIPT ERROR。**端到端**：全 anon 隊 promote_anon → named 出現 → 可派子隊（dispatch_candidates 非空）。

- [ ] **Step 2: hand-back** `docs/superpowers/handbacks/2026-06-18-q7-4-promote-anon.md`（command + UI + 端到端「全 anon 隊→拔擢→可派子隊」、守恆驗證、與 plan 差異）。
- [ ] **Step 3: Commit + push + 回報** `git push -u origin feat/q7-4`，回報 branch + 結果。

---

## Self-Review

**Spec coverage：** Q7-4 對稱性——玩家拔擢 anon→named 對齊 NPC（復用 generate_for_team,非平行邏輯）。解全 anon 隊無法派子隊。

**Placeholder scan：** Task 2 UI「讀 X mirror train/camp self-action」明確指引,非 placeholder。

**Type consistency：** `_action_promote_anon(state,_target_id,pt,pt_id)->Dictionary` 對齊既有 action 簽名;復用 `PersonGenerator.generate_for_team`/`AnonTierSystem.total_pop` 既有契約;population getter 守恆（anon-1/named+1）。
