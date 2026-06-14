# 遭遇戰/互動 UI Bug 批修 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 修 2026-06-14 玩測抓到的 5 個 pre-existing 遭遇戰/互動 UI bug（known_issues U10-U14），讓實際遊玩不卡、有回饋。

**Architecture:** 主在 `scripts/ui/encounter_view.gd` + `scripts/ui/text_ui_main.gd`；U11 命中回饋需小幅 sim→state combat log channel（經 bridge 讀，遵 UI 邊界）。L2 批修（root-cause→plan，無 spec）。

**Tech Stack:** Godot 4.2.2 GDScript；headless + ui_logic_test；`.\tools\godot.ps1`；**GUI 視覺部分需人工 run-verify**。

依據：`docs/known_issues.md` U10-U14。

---

## Task 1: U10 遭遇戰戰後凍結（H，blocker）

**Files:**
- Modify: `scripts/ui/encounter_view.gd`（`_refresh_ui`）

**根因**：`_refresh_ui` line 96-97 無 player_unit 即 early-return；戰畢 encounter_units 清空 → 戰後 `_post_combat`（can_subjugate）的「按鍵離開 / [J]收編」提示從未渲染 → 看似凍結。

- [ ] **Step 1: 改 `_refresh_ui` 戰後分支**

`_refresh_ui` 開頭，player_unit 空的 early-return 前，加戰後處理：

```gdscript
func _refresh_ui() -> void:
	if _bridge == null: return
	var state: WorldState = _bridge.get_state()
	# 戰後 / 無玩家單位：顯戰果 + 離開提示（不可 early-return 成空白凍結畫面）
	if _post_combat or not state.encounter_active:
		var res: Dictionary = state.last_encounter_result
		var hint: String = "戰鬥結束。按任意鍵離開"
		if res.get("can_subjugate", false):
			hint += " / [J]收編敗者"
		_lbl_actions.text = hint
		_lbl_cursor_info.text = "戰果：%s" % str(res.get("summary", res.get("outcome", "結束")))
		return
	var player_unit: Dictionary = _find_player_unit(state)
	if player_unit.is_empty(): return
	# …既有 health/equip/action_hints…
```

- [ ] **Step 2: 驗證**

無法 headless 驗 GUI；**標待 run-verify**：玩家獵獸/打贏後畫面顯「按任意鍵離開 / J 收編」，按鍵能離開（不卡）。
單元可驗的部分：若把提示組字抽 static helper（`_post_combat_hint(res) -> String`）→ 加 ui_logic_test 斷言 can_subjugate→含「J收編」、否則僅「按任意鍵」。建議抽 helper。

- [ ] **Step 3: Commit**

```bash
git add scripts/ui/encounter_view.gd scripts/debug/ui_logic_test.gd
git commit -m "fix(ui): U10 遭遇戰戰後顯離開提示，不再空白凍結"
```

---

## Task 2: U13 物品欄卸裝入口（M）

**Files:**
- Modify: `scripts/ui/text_ui_main.gd`（`_handle_inv_mode` + inv 面板提示）

**根因**：inv 模式有 [E]裝備/[S]存/[G]取，**無卸下鍵**；`PlayerCommandApi.unequip_item` 已存在，只缺 UI 綁定。

- [ ] **Step 1: 加卸下鍵**

`_handle_inv_mode`：選中「已裝備」項時，加 `[U]` 卸下：
```gdscript
	if keycode == KEY_U:
		var slot: String = _selected_equipped_slot()   # 當前選中的已裝備槽
		if slot != "":
			var r: Dictionary = _bridge.command_player("unequip_item", {"slot_id": slot})
			_set_feedback(r.get("ok", false), r.get("message", ""))   # P2 feedback
			_refresh()
		return
```
inv 面板「── 裝備 ──」區列出各槽 → 加可選 + 提示行補 `[U]卸下`（line 749 的提示串）。`_selected_equipped_slot` 依現有 inv 選取邏輯回傳當前裝備槽 id（實作者對齊 inv 選取狀態）。

- [ ] **Step 2: 驗證** — run-verify：inv 開啟 → 選已裝備物 → [U] → 卸下、物品回庫、feedback 顯示。

- [ ] **Step 3: Commit**

```bash
git add scripts/ui/text_ui_main.gd
git commit -m "fix(ui): U13 物品欄加卸下鍵[U]（綁既有 unequip_item）"
```

---

## Task 3: U11 戰鬥命中回饋（M）

**Files:**
- Modify: `scripts/data/world_state.gd`（`encounter_log` 欄位）
- Modify: `scripts/simulation/encounter_system.gd`（resolve_attack 等 append log）
- Modify: `scripts/ui/sim_bridge.gd`（facade）+ `scripts/ui/encounter_view.gd`（顯示）
- Test: `scripts/debug/headless_test.gd`

**根因**：`resolve_attack` 命中只 `print("[Hit] part dmg")` 到 console，未走 state/UI → 玩家無回饋。

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_encounter_log() -> void:
	print("--- encounter combat log ---")
	var state := WorldState.new(); state.world = WorldData.new()
	assert("encounter_log" in state, "WorldState 需 encounter_log 欄位")
	# resolve_attack 命中應 append 一條
	# （最小：直接驗 append helper / 欄位存在 + 一次模擬攻擊後非空）
	print("encounter log OK")
```

- [ ] **Step 2: 跑確認失敗**

- [ ] **Step 3: 實作**

`world_state.gd`：`var encounter_log: Array = []`（遭遇戰命中/事件流；init_encounter 清空、resolve_encounter_end 後保留供戰後讀或清）。

`encounter_system.resolve_attack`：命中/miss/block/閃避 各 append 簡訊到 `state.encounter_log`（如 `"%s 擊中 %s %s -%.0f" % [...]`）。`init_encounter` 開頭 `state.encounter_log.clear()`。

`sim_bridge.gd`：`func query_encounter_log(n) -> Array`（回最新 n 條）。

`encounter_view._refresh_ui` / `_advance_until_player_or_end`：每 tick 後把 `_bridge.query_encounter_log(5)` 顯於既有 `_lbl_log` / `_log`。

- [ ] **Step 4: 驗證** — headless：模擬一場 encounter，`state.encounter_log` 非空、含命中條。run-verify：戰鬥中畫面滾動顯命中/傷害。

- [ ] **Step 5: Commit**

```bash
git add scripts/data/world_state.gd scripts/simulation/encounter_system.gd scripts/ui/sim_bridge.gd scripts/ui/encounter_view.gd scripts/debug/headless_test.gd
git commit -m "fix(ui): U11 戰鬥命中回饋（encounter_log channel → UI）"
```

---

## Task 4: U12 互動交易「無資源」（M，先查根因）

**Files:**
- Modify: 依調查結果（`scripts/ui/text_ui_main.gd` trade 模式 / `scripts/simulation/player_command_system.gd` trade 路徑）

- [ ] **Step 1: 調查根因**

讀 text_ui trade 流（`_handle_trade_mode` / `_build_trade_str`）+ `submit_trade_offer` / `confirm_trade` / `_resolve_market` / `get_trade_preview`。確認「無資源/不足」訊息實際從哪冒（候選：trade_offer 未帶 gives/wants、preview 取雙方資源錯、_resolve_market 條件）。**記錄重現條件**（雙方各有何資源時觸發）。

- [ ] **Step 2: 寫重現測試**（依根因）

針對找到的條件寫 headless 測試重現「有貨卻判無資源」。

- [ ] **Step 3: 修 + 測試通過**

依根因最小修（如 preview 資源來源、offer 組裝、market 條件）。

- [ ] **Step 4: Commit**

```bash
git commit -m "fix: U12 互動交易誤判無資源（根因：<填>）"
```

---

## Task 5: U14 遭遇戰進場人數（L，先確認真假）

- [ ] **Step 1: 對照**

讀 `encounter_system._spawn_team_units`（`armed_anon_ratio × pop`、`ANON_UNIT_CAP`、named+1）+ `init_encounter` spawn 數，對照 UI 顯示。判斷：是真 bug（spawn 數錯）還是 UI 沒標總數（觀感）。

- [ ] **Step 2: 依判斷**

- 真 bug → 修 spawn 數 + 測試。
- 僅 UI 沒標 → encounter_view 顯雙方總數（小 UI 補）。
- 正常 → 記 known_issues 標「已確認正常，關閉」。

- [ ] **Step 3: Commit / 記錄**

---

## Task 6: 註冊 + 驗證 + handback

- [ ] **Step 1: 註冊新測試**（`_test_encounter_log` + U10 helper 測 + U12 重現測）於對應 test 檔。
- [ ] **Step 2: 全測試** — headless_test / ui_logic_test / team_ui_test 無新增 SCRIPT ERROR、無回歸。
- [ ] **Step 3: handback** — `docs/superpowers/handbacks/2026-06-14-encounter-ui-bugfix-batch.md`，逐 bug 列根因+修法+驗證狀態（GUI 部分標待 run-verify）。

---

## 注意事項（給實作者）

- **U10 是 blocker，最優先**。
- **GUI 視覺修（U10/U13/U11 顯示）headless 測不到** → 顯示邏輯盡量抽 static helper 單元測；其餘標「待人工 run-verify」於 handback。
- **UI 邊界**：encounter_view 經 `_bridge`（U11 combat log 走 bridge facade，勿直存）。
- **U11 動 sim**（encounter_log 欄位 + resolve_attack append）→ 確認不破守恆/不改戰鬥結果（只加 log）；跑既有 encounter 測試無回歸。
- **U12/U14 先查再修**：根因不明者勿瞎改，記重現條件。
- baseline `food 應進公庫`（Bug8）非本批，勿動。
