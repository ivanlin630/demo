# 物物交換 offer-builder 交易介面 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 建互動交易介面（出價/買/賣）：暴露 `get_trade_session` DTO（雙方清單+估值+公平度）+ text_ui offer-builder（選給/要+數量+天平+送出）。後端 `evaluate_offer`/`execute_offer`/`_local_value` 已存在，本 plan 只做 DTO 暴露 + UI。

**Architecture:** API/sim 層 = DTO 暴露（reuse 既有 `PlayerTradeSystem.evaluate_offer` + `InteractionSystem._local_value`，零新交易邏輯）；UI 層 = offer-builder（建 `player_state.trade_offer` + 渲染 DTO + 送 `submit_trade_offer`）。守 UI 邊界（UI 零邏輯）。

**Tech Stack:** Godot 4.2.2 GDScript；headless + ui_flow；`.\tools\godot.ps1`。

依據 spec：`docs/superpowers/specs/2026-06-15-trade-offer-builder-design.md`。

**既有可用（不重寫）**：`PlayerTradeSystem.evaluate_offer(state, pt_id, tgt_id, {player_gives, player_wants}) -> {accepted, reason}`、`PlayerTradeSystem.execute_offer`（submit_trade_offer 用）、`InteractionSystem._local_value(team, res)`（私有，需公開存取）、`InteractionSystem.BASE_PRICE`、text_ui `_trade_mode`/`_handle_trade_mode`/`_build_trade_str`。

---

## 檔案結構

- `scripts/simulation/interaction_system.gd`（改）：`_local_value` 加公開 wrapper `local_value(team, res)`（或設為 public）供 DTO 估值。
- `scripts/simulation/player_query_api.gd` + `player_api_mapper.gd`（改）：`get_trade_session(target)` DTO。
- `scripts/ui/sim_bridge.gd`（改）：`query_trade_session(target)` facade。
- `scripts/ui/text_ui_main.gd`（改）：`_handle_trade_mode` offer-builder（建 offer + 送）；`_build_trade_str` 渲染 DTO（兩欄+天平+接受預估）。
- `scripts/debug/headless_test.gd` / `ui_flow_test.gd`（改）：測試。

---

## Task 1: get_trade_session DTO（API 層）

**Files:**
- Modify: `scripts/simulation/interaction_system.gd`（公開 `local_value`）
- Modify: `scripts/simulation/player_api_mapper.gd`（`map_trade_session`）
- Modify: `scripts/simulation/player_query_api.gd`（`get_trade_session`）
- Modify: `scripts/ui/sim_bridge.gd`（facade）
- Test: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_trade_session_dto() -> void:
	print("--- get_trade_session DTO ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var leader := PersonData.new(); leader.id = 0; leader.team_id = 0
	state.persons[0] = leader; state.player_id = 0
	var pt := TeamData.new(); pt.team_id = 0; pt.leader_id = 0; pt.population = 5
	pt.tile_pos = Vector2i(4,4); pt.resources = {"food": 50.0, "coin": 20}
	state.teams[0] = pt
	var npc := TeamData.new(); npc.team_id = 1; npc.population = 5
	npc.tile_pos = Vector2i(4,4); npc.resources = {"material": 30, "coin": 100}
	state.teams[1] = npc
	# 建構中 offer：玩家給 food 10、要 coin 10
	state.player_state["trade_offer"] = {"player_gives": {"food": 10}, "player_wants": {"coin": 10}}
	state.player_state["pending_trade_target"] = 1
	var qa := PlayerQueryApi.new()
	var d: Dictionary = qa.get_trade_session(state, 1).get("data", {})
	assert(d.get("feasible", false), "同格應 feasible")
	assert(d.get("player_items", []).size() > 0, "玩家清單非空")
	assert(d.get("target_items", []).size() > 0, "NPC 清單非空")
	assert(d.has("give_value") and d.has("want_value"), "天平兩端")
	assert(d.has("npc_would_accept"), "接受預估")
	print("trade_session DTO OK")
```

註：確認 `PlayerQueryApi.get_trade_session` 回傳結構（envelope `{data:{...}}`）；對齊既有 query 風格。

- [ ] **Step 2: 跑確認失敗** — `get_trade_session` 未定義。

- [ ] **Step 3: 實作**

`interaction_system.gd`：加公開存取（_local_value 私有）：
```gdscript
func local_value(team: TeamData, res: String) -> float:
	return _local_value(team, res)
```

`player_api_mapper.gd` 新 `map_trade_session`：
```gdscript
static func map_trade_session(state: WorldState, target_id: int) -> Dictionary:
	var pid: int = state.player_id
	var p: PersonData = state.persons.get(pid) if pid != -1 else null
	var pt: TeamData = state.teams.get(p.team_id) if p != null else null
	var tgt: TeamData = state.teams.get(target_id)
	if pt == null or tgt == null:
		return { "feasible": false }
	var feasible: bool = pt.tile_pos == tgt.tile_pos
	var inter = load("res://scripts/simulation/interaction_system.gd").new()
	var p_items: Array = []
	var t_items: Array = []
	for res in InteractionSystem.BASE_PRICE:
		if float(pt.resources.get(res, 0)) > 0:
			p_items.append({ "grade": res, "qty": int(pt.resources[res]), "unit_value": inter.local_value(pt, res) })
		if float(tgt.resources.get(res, 0)) > 0:
			t_items.append({ "grade": res, "qty": int(tgt.resources[res]), "unit_value": inter.local_value(tgt, res) })
	# coin 另列（BASE_PRICE 可能不含 coin）
	if int(pt.resources.get("coin", 0)) > 0:
		p_items.append({ "grade": "coin", "qty": int(pt.resources["coin"]), "unit_value": 1.0 })
	if int(tgt.resources.get("coin", 0)) > 0:
		t_items.append({ "grade": "coin", "qty": int(tgt.resources["coin"]), "unit_value": 1.0 })
	var offer: Dictionary = state.player_state.get("trade_offer", {})
	var gives: Dictionary = offer.get("player_gives", {})
	var wants: Dictionary = offer.get("player_wants", {})
	var give_v: float = 0.0
	for r in gives: give_v += inter.local_value(tgt, r) * float(gives[r])   # NPC 視角(收 player 給)
	var want_v: float = 0.0
	for r in wants: want_v += inter.local_value(tgt, r) * float(wants[r])   # NPC 視角(給出)
	var accept: bool = false
	if not gives.is_empty() or not wants.is_empty():
		var ev := PlayerTradeSystem.new().evaluate_offer(state, pt.team_id, target_id,
			{ "player_gives": gives, "player_wants": wants })
		accept = ev.get("accepted", false)
	return {
		"feasible": feasible,
		"player_items": p_items, "target_items": t_items,
		"offer": { "gives": gives, "wants": wants },
		"give_value": give_v, "want_value": want_v,
		"npc_would_accept": accept,
	}
```
（whose-value 依 spec：天平用 NPC `_local_value` 判公平/接受；player_items unit_value 用玩家視角供參考。`PlayerTradeSystem.evaluate_offer` 為單一真相，npc_would_accept 與 submit 一致。）

`player_query_api.gd`：
```gdscript
func get_trade_session(state: WorldState, target_id: int) -> Dictionary:
	var check := _check_player_with_team(state)
	if check["code"] != "ok":
		return PlayerApiMapper.map_query_envelope(false, check["code"], check["msg"], {})
	return PlayerApiMapper.map_query_envelope(true, "ok", "",
		PlayerApiMapper.map_trade_session(state, target_id))
```

`sim_bridge.gd`：`func query_trade_session(tid): return _query.get_trade_session(_state, tid)`（對齊既有 facade 模式）。

- [ ] **Step 4: 跑確認通過** — `trade_session DTO OK`
- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/interaction_system.gd scripts/simulation/player_api_mapper.gd scripts/simulation/player_query_api.gd scripts/ui/sim_bridge.gd scripts/debug/headless_test.gd
git commit -m "feat(api): get_trade_session DTO（雙方清單+估值+公平度，reuse evaluate_offer/_local_value）"
```

---

## Task 2: offer-builder UI（UI 層）

**Files:**
- Modify: `scripts/ui/text_ui_main.gd`（`_handle_trade_mode` + `_build_trade_str`）
- Test: `scripts/debug/ui_flow_test.gd`

- [ ] **Step 1: 寫失敗測試（flow）**

```gdscript
func _test_trade_offer_builder() -> void:
	print("\n── 交易 offer-builder ──")
	var node = await _make_ui()
	var st = node._bridge.get_state()
	var ptid: int = st.persons[st.player_id].team_id
	var ppos = st.teams[ptid].tile_pos
	st.teams[ptid].resources["food"] = 50.0
	var npc := TeamData.new(); npc.team_id = 7777; npc.tile_pos = ppos; npc.population = 5
	npc.resources = {"coin": 100}
	st.teams[7777] = npc
	node._trade_mode = true; node._trade_target_id = 7777
	st.player_state["pending_trade_target"] = 7777
	st.player_state["trade_offer"] = {"player_gives": {"food": 10}, "player_wants": {"coin": 10}}
	var s: String = node._build_trade_str()
	_check("交易字串顯天平(給/要值)", s.contains("給") and s.contains("要"))
	_check("非舊『無可交換』", not s.contains("無可交換"))
	await _free_ui(node)
```

- [ ] **Step 2: 跑確認失敗**

- [ ] **Step 3: 實作**

`_build_trade_str` 改讀 `_bridge.query_trade_session(_trade_target_id).data`：
- 兩欄渲染：「我給」(player_items + 當前 gives) / 「我要」(target_items + 當前 wants)，各 `[n] grade ×qty (值V)`，分頁（沿用 `_interact_page` 模式或新 `_trade_page`）。
- 底部天平：`給 ΣV ⇄ 要 ΣV   NPC:✓接受/✗拒絕`。
- 提示：`[數字]選項 [Enter]送出 [C]清 [Esc]離開`。

`_handle_trade_mode`：
- 數字鍵 → 選清單某項 → 進數字輸入收 qty → 加進 `player_state.trade_offer.gives`/`wants`（依該項在我給欄或我要欄）→ `_refresh`。
- `[Enter]` → `_bridge.command_player("execute_action", {action_id:"submit_trade_offer", target:{kind:"team", team_id:_trade_target_id}})` → `_set_feedback(r.ok, r.msg)` → 成功則離開交易模式。
- `[C]` → 清 `trade_offer` → refresh。`[Esc]` → 離開（清 trade_offer）。

（依現行 `_handle_trade_mode` 結構對齊；用既有 `_input_mode` 收數字 qty；確認 submit_trade_offer 讀 `player_state.trade_offer`/`pending_trade_target`。）

- [ ] **Step 4: 跑確認通過** — `交易 offer-builder` PASS
- [ ] **Step 5: Commit**

```bash
git add scripts/ui/text_ui_main.gd scripts/debug/ui_flow_test.gd
git commit -m "feat(ui): 交易 offer-builder（給/要欄+數量+天平+送出，讀 trade_session DTO）"
```

---

## Task 3: 註冊 + 整合（守恆）

- [ ] **Step 1: 註冊** `_test_trade_session_dto`（headless）+ `_test_trade_offer_builder`（ui_flow）。
- [ ] **Step 2: 全跑** — headless / ui_logic / ui_flow 無新增 SCRIPT ERROR、新測綠。
- [ ] **Step 3: 守恆整合測**：headless 建一筆 offer → submit_trade_offer 成交 → 斷言雙方資源雙向轉移、coin_eq 不變（`_execute_transfer`/execute_offer 既有，驗無漏）。可加 `_test_trade_conservation`：成交前後 coin_eq 相等。
- [ ] **Step 4: handback** — `docs/superpowers/handbacks/2026-06-15-trade-offer-builder.md`。真視覺（兩欄版面）標待人工 run-verify（DTO/flow/守恆已自動測）。

---

## 注意事項（給實作者）

- **零新交易邏輯**：估值用既有 `_local_value`、接受用既有 `evaluate_offer`、轉移用既有 `execute_offer`。本 plan 只暴露 DTO + UI。
- **whose-value**（spec）：天平/接受用 **NPC** `_local_value`（NPC 判收不收）；玩家物 unit_value 玩家視角供參考。
- **單一真相**：`npc_would_accept` 必呼 `PlayerTradeSystem.evaluate_offer`（與 submit 同函數），不另寫判定 → 預估不騙人。
- **UI 邊界**：offer-builder 經 `query_trade_session` DTO + `submit_trade_offer` command，零直存 state。
- **守恆**：交易雙向轉移既有；Task 3 驗 coin_eq=0。
- **可交易白名單**：限 `BASE_PRICE` 項 + coin（無價資源不列，避免估值 0）。
- **分頁**：清單 >9 用既有分頁模式。
- counter-offer 不做（YAGNI）。baseline Bug8 勿動。
