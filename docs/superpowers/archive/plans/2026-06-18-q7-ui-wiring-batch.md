# Q7 UI Wiring（Q7-3 戰利品 / Q7-5 子隊任務 / Q7-6 faction gate）Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 補三個 UI↔command 落差：Q7-3 文字 UI 戰勝可拿戰利品（take_loot/leave_loot）、Q7-5 子隊派遣可選任務（非寫死 IDLE）、Q7-6 faction 設定鈕只對 leader 顯示（消顯示/可執行不一致）。

**Architecture:** 通用模型——UI 暴露既有 registered command，非新增邏輯。Q7-3 mirror 既有 `[J]收編` post-combat wiring；Q7-5 用既有 sub_task 選擇模式；Q7-6 gate 顯示對齊 command 權限。零 sim 行為變更。

**Tech Stack:** Godot 4.2.2 GDScript。閘 = `ui_flow_test.gd`（驅動驗）+ `headless_test.gd`（`=== DONE ===`）+ `game_sim_multi.gd`（coin_eq=0）。

> **Q7 系列**：Q7-1/Q7-2 ✅。本 plan=Q7-3/5/6。Q7-4（anon→named promote）獨立 plan。

**前置（強制）：** `git worktree add .worktrees/q7-ui -b feat/q7-ui && cd .worktrees/q7-ui`
**Baseline：** `ui_flow_test.gd` 綠、`headless_test.gd` `=== DONE ===`。

---

## Task 1: Q7-3 戰利品文字 UI（take_loot/leave_loot）

**Files:** Modify `scripts/ui/encounter_view.gd`（`_post_combat_hint:569` + post-combat 鍵處理）

`take_loot`/`leave_loot` 是 registered action（player_command:94-95，`_action_take_loot:366` 讀 `last_encounter_result.loot_pool`）。文字 UI 戰後只列 `[J]收編`，無 loot 路徑。

- [ ] **Step 1: hint 加 loot 提示**

`_post_combat_hint(res)`（:569）：若 `res.get("loot_pool", {})` 非空 → 加 `[K]拿戰利品 [L]留下`：
```gdscript
static func _post_combat_hint(res: Dictionary) -> String:
	var hint: String = "戰鬥結束。按任意鍵離開"
	if res.get("can_subjugate", false):
		hint += " / [J]收編敗者"
	if not res.get("loot_pool", {}).is_empty():
		hint += " / [K]拿戰利品 [L]留下"
	return hint
```

- [ ] **Step 2: 接鍵**

**讀 encounter_view 的 post-combat 輸入處理**（grep `can_subjugate`/`KEY_J`/`subjugate_enemy` 找 [J] 接線處，:157/376/479 附近）。mirror [J] 的派發,加 `KEY_K`→command `take_loot`、`KEY_L`→`leave_loot`（透過既有 command 派發機制,如 `_bridge.command_player`/`execute`）。loot 是 last_encounter_result 內,command 自取,無需傳參。

> 確認戰後 state（`encounter_active=false`）下這些鍵的處理位置與 [J] 一致。take_loot 後 `_action_take_loot` 清 `last_encounter_result`。

- [ ] **Step 3: ui_flow + headless** Expected: `=== DONE ===`、ui_flow 綠。
- [ ] **Step 4: Commit** `git commit -am "feat(ui): Q7-3 文字 UI 戰後 take_loot/leave_loot 接線"`

---

## Task 2: Q7-5 子隊派遣可選任務

**Files:** Modify `scripts/ui/text_ui_main.gd`（:1534 區，dispatch_subteam 流程）

`dispatch_subteam` command 支援任意 `sub_task`，但 UI（:1534）寫死 `set_player_input("sub_task", TASK_IDLE)`。

- [ ] **Step 1: 讓玩家選 task**

**讀 :1500-1560 dispatch 流程**。把寫死的 `TASK_IDLE` 改為玩家可選的子隊任務（合理子集：IDLE/採集(FORAGE)/安頓(SETTLE)/巡邏(PATROL)/建設(BUILD) 等——確認哪些 sub_task 對子隊有效）。用既有選單/輸入模式（mirror 其他多選 UI，如 task picker）。MVP：若全任務選單過大，至少加 IDLE + 採集 + 安頓幾個常用，經選擇後 `set_player_input("sub_task", 選定)`。

> 保持 command 介面不變（已支援任意 sub_task）；僅 UI 開放選擇。order_subteam 若同樣寫死可一併（讀確認）。

- [ ] **Step 2: ui_flow + headless** Expected: 綠。
- [ ] **Step 3: Commit** `git commit -am "feat(ui): Q7-5 子隊派遣開放任務選擇（非寫死 IDLE）"`

---

## Task 3: Q7-6 faction 設定鈕 gate leader

**Files:** Modify `scripts/ui/text_ui_main.gd`（`_build_faction_str` + KEY_A/KEY_B :1147/1162）

faction 面板對所有成員顯示 `[A]目標 [B]徵收率`,但 `set_faction_goal`/`set_tribute_rate` 要 leader → 非 leader 按了 reject（誤導）。

- [ ] **Step 1: gate 顯示 + 鍵**

判玩家隊是否為 faction leader（`state.factions[fid].leader_team_id == player_team_id`）。非 leader → faction 面板**不顯示** `[A]目標 [B]徵收率`（hint string 條件組裝）+ KEY_A/KEY_B handler 非 leader 時 no-op/不觸發。**讀 `_build_faction_str`（:1282 附近）+ :588 hint + :1147/1162 handler**,加 is_faction_leader 條件。

> 用既有取玩家 faction/leader 判定;無 helper 則 inline。display 與 command 權限一致。

- [ ] **Step 2: ui_flow + headless** Expected: 綠。
- [ ] **Step 3: Commit** `git commit -am "fix(ui): Q7-6 faction 設定鈕只對 leader 顯示（消顯示/可執行不一致）"`

---

## Task 4: 回歸 + hand-back

- [ ] **Step 1: 全回歸**
```powershell
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
.\tools\godot.ps1 --headless --script scripts/debug/ui_flow_test.gd
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd
```
Expected: 全 `=== DONE ===`、ui_flow errors:0、coin_eq=0、全 invariant 0、無 SCRIPT ERROR。

- [ ] **Step 2: hand-back** `docs/superpowers/handbacks/2026-06-18-q7-ui-wiring.md`（Q7-3/5/6 接線摘要、驗證、與 plan 差異）。
- [ ] **Step 3: Commit + push + 回報** `git push -u origin feat/q7-ui`，回報 branch + 各 Q7 結果。

---

## Self-Review

**Spec coverage：** Q7-3/5/6 三 UI 落差,皆暴露既有 registered command,非新邏輯。Q7-4 獨立。

**Placeholder scan：** Task 1/2/3 附「讀 X 處 mirror 既有 wiring」明確指引（[J]subjugate / sub_task 模式 / leader 判定）,site 明確,非 placeholder。MVP 範圍（Q7-5 task 子集）明示。

**Type consistency：** 用既有 command id（take_loot/leave_loot/dispatch_subteam/set_faction_goal/set_tribute_rate）+ 既有 set_player_input/command 派發,介面不變。零 sim 行為變更。
