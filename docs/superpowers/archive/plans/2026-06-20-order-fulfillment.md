# #1 經濟閉環 — Plan 1：訂單履約 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:test-driven-development（每 Task 先寫失敗測試再實作）+ superpowers:executing-plans。Steps 用 checkbox 追蹤。

**Goal:** 訂單流接最後一步——`interaction._resolve_market` 交易後，按各隊 res 淨變沖銷 `active_orders`，履約率 0%→真。`Probe` 已有 `g1.order_fulfilled`/`g1.arb_hit`（ProbeSummary 已用），只缺 bump。

**Architecture:** 純記帳——`OrderSystem.settle_orders(team, before, tick)` 按窗內 res 淨變扣 `qty_remaining`、填滿移除 + bump。`_resolve_market` 在 absorb/spillback 窗內（team.resources=完整持有）快照前後並呼 settle。**不碰交易機制 / resources / coin → 守恆完全無關**。

**Tech Stack:** Godot 4.2.2 GDScript；`order_system.gd`（settle）+ `interaction_system.gd`（結算點）；headless harness。

## Global Constraints

- wrapper 跑（UTF-8）：`.\tools\godot.ps1`。
- **只動 `active_orders` 記帳 + 2 probe bump，不碰 resources/coin/交易機制**。coin_eq/物資守恆無關。
- 來源：`specs/2026-06-20-order-fulfillment-design`、ruling `2026-06-20-blueprint-to-systems-feud-scenarios-ruling`（§3 #1）。
- 回歸閘：headless 全綠、coin_eq=0、InvariantAudit 0。不用 multi/world_sim drift 當閘（[[reference_multi_sanity_unseeded]]，非確定）。
- order 權威在發起隊 `active_orders`（單一所有者）；商隊 received = 唯讀情報，不持單，沖銷只動發起隊自己的單。

## File Structure

- `scripts/simulation/order_system.gd`（新 `settle_orders`）。
- `scripts/simulation/interaction_system.gd`（`_resolve_market` 結算點）。
- `scripts/debug/headless_test.gd`（履約 / 部分 / 撲空 測試）。

---

### Task 1: OrderSystem.settle_orders + 結算點接線

**Files:**
- Modify: `scripts/simulation/order_system.gd`、`scripts/simulation/interaction_system.gd`
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- `settle_orders(team: TeamData, before: Dictionary, tick: int) -> bool`：按 `team.resources[res] - before[res]` 淨變沖 `team.active_orders`；回 `progressed`（任一單 qty 有減）。
- `_resolve_market` 在交易窗（absorb 後 / spillback 前）快照 + 呼 settle 雙方。

- [ ] **Step 1: 寫失敗測試**（`_initialize()` 註冊 `_test_order_fulfillment()`）

```gdscript
func _test_order_fulfillment() -> void:
	print("--- #1 訂單履約結算 ---")
	var os := OrderSystem.new()
	# buy 單：隊想進貨 material，窗內持有 +5 → 沖 5
	var t := TeamData.new(); t.team_id = 0
	t.active_orders = [{"order_id": 1, "kind": "buy", "res": "material", "qty_remaining": 8, "expire_tick": 9999}]
	var before := {"material": 10.0}
	t.resources["material"] = 15.0   # 窗後 = 15，淨 +5
	var prog: bool = os.settle_orders(t, before, 100)
	assert(prog == true, "有進貨應 progressed")
	assert(int(t.active_orders[0]["qty_remaining"]) == 3, "8-5=3，實際=%d" % t.active_orders[0]["qty_remaining"])
	# 填滿 → 移除
	var before2 := {"material": 15.0}
	t.resources["material"] = 20.0   # 再 +5 ≥ 剩 3
	os.settle_orders(t, before2, 101)
	assert(t.active_orders.is_empty(), "填滿應移除 order")
	# sell 單：持有減才算；撲空（無變）不沖
	var t2 := TeamData.new(); t2.team_id = 1
	t2.active_orders = [{"order_id": 2, "kind": "sell", "res": "goods", "qty_remaining": 6, "expire_tick": 9999}]
	var b3 := {"goods": 10.0}; t2.resources["goods"] = 10.0   # 無變
	assert(os.settle_orders(t2, b3, 102) == false, "撲空不 progressed")
	assert(int(t2.active_orders[0]["qty_remaining"]) == 6, "撲空 qty 不變")
	var b4 := {"goods": 10.0}; t2.resources["goods"] = 6.0    # 賣出 4
	os.settle_orders(t2, b4, 103)
	assert(int(t2.active_orders[0]["qty_remaining"]) == 2, "6-4=2 sell 沖銷")
	print("order fulfillment OK")
```

- [ ] **Step 2: --import + 跑驗證失敗**（`settle_orders` 未定義）

- [ ] **Step 3: 實作 settle_orders**

`order_system.gd` 加：
```gdscript
# 履約結算：按窗內 res 淨持有變化沖 active_orders（純記帳，不碰 resources）。
# before = 交易窗前各 res 持有快照。回 progressed（任一單 qty 有減）。
func settle_orders(team: TeamData, before: Dictionary, tick: int) -> bool:
	var progressed: bool = false
	# 各 res 的 delta 池（一池只沖該 res 同向單，FIFO）
	var pool: Dictionary = {}
	for o in team.active_orders:
		var res: String = o["res"]
		if not pool.has(res):
			pool[res] = float(team.resources.get(res, 0)) - float(before.get(res, 0))
		var avail: float = pool[res]
		var want: int = int(o["qty_remaining"])
		var filled: int = 0
		if o["kind"] == "buy" and avail > 0.0:
			filled = clampi(int(round(avail)), 0, want)
			pool[res] = avail - float(filled)
		elif o["kind"] == "sell" and avail < 0.0:
			filled = clampi(int(round(-avail)), 0, want)
			pool[res] = avail + float(filled)
		if filled > 0:
			o["qty_remaining"] = want - filled
			progressed = true
	# 移除填滿單 + bump
	var kept: Array = []
	for o in team.active_orders:
		if int(o["qty_remaining"]) <= 0:
			Probe.bump("g1.order_fulfilled")
		else:
			kept.append(o)
	team.active_orders = kept
	return progressed
```

> `before` 快照只需含「該隊 active_orders 涉及的 res」（Step 4 接線只快照那些 res）。`pool` 確保同 res 多單共享 delta、FIFO 配。

- [ ] **Step 4: 結算點接線**

`interaction_system.gd._resolve_market`（:558-567）改：
```gdscript
func _resolve_market(state: WorldState, a: TeamData, b: TeamData) -> void:
	var a_original: Dictionary = _absorb_public_storage(state, a)
	var b_original: Dictionary = _absorb_public_storage(state, b)
	var a_coin_before: float = float(a.resources.get("coin", 0))
	# 履約：交易窗前快照各隊 active_order 涉及的 res 持有（窗內 = 私有+吸入公庫 = 完整持有）
	var a_before: Dictionary = _snapshot_order_res(a)
	var b_before: Dictionary = _snapshot_order_res(b)
	_attempt_trade_direction(state, a, b)
	_attempt_trade_direction(state, b, a)
	_attempt_barter(state, a, b)
	# 履約結算（spillback 前，team.resources 仍 = 完整持有）
	var _os := OrderSystem.new()
	var a_prog: bool = _os.settle_orders(a, a_before, state.world.current_tick)
	var b_prog: bool = _os.settle_orders(b, b_before, state.world.current_tick)
	if (a_prog and b.tags.has(TeamData.TAG_MERCHANT)) or (b_prog and a.tags.has(TeamData.TAG_MERCHANT)):
		Probe.bump("g1.arb_hit")
	if absf(float(a.resources.get("coin", 0)) - a_coin_before) > 0.001:
		print("[Market] Team%d <-> Team%d 成交（公庫接入）" % [a.team_id, b.team_id])
	_spill_back_public_storage(state, a, a_original)
	_spill_back_public_storage(state, b, b_original)
	if a.current_task == TeamData.TASK_TRADE: TaskArbiter.release(a)
	if b.current_task == TeamData.TASK_TRADE: TaskArbiter.release(b)

func _snapshot_order_res(team: TeamData) -> Dictionary:
	var snap: Dictionary = {}
	for o in team.active_orders:
		var res: String = o["res"]
		if not snap.has(res):
			snap[res] = float(team.resources.get(res, 0))
	return snap
```

- [ ] **Step 5: --import + 跑驗證通過**（`order fulfillment OK`、`=== DONE ===`、coin_eq=0、InvariantAudit 0）

- [ ] **Step 6: Commit**
```bash
git add scripts/simulation/order_system.gd scripts/simulation/interaction_system.gd scripts/debug/headless_test.gd
git commit -m "feat(economy): 訂單履約結算(_resolve_market 後按 res 淨變沖 active_orders)"
```

---

### Task 2: 回歸 + world_sim 煙霧 + 回報

**Files:** 無 code 改（跑 + 回報）。

- [ ] **Step 1: headless 回歸**
```
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
```
Expected：`order fulfillment OK`、`=== DONE ===`、coin_eq=0、InvariantAudit 0。

- [ ] **Step 2: world_sim 煙霧（非閘）**
```
.\tools\godot.ps1 --headless --script scripts/debug/world_sim.gd
```
Expected：跑通無 SCRIPT ERROR；`[ProbeSummary]` 印；觀察 `訂單履約率` 是否 0%→非零（**僅煙霧**——world_sim 非確定性，數字不可重現、不可當平衡證據，見 [[reference_multi_sanity_unseeded]] / known_issues 量測基建段）。

- [ ] **Step 3: 回報 handback** `docs/superpowers/handbacks/2026-06-20-implementer-to-systems-order-fulfillment.md`（`from: implementer / to: systems / status: open`）：
- 單測結果（履約/部分/撲空/sell 對稱）。
- world_sim ProbeSummary `訂單履約率`/`套利命中率`（標明僅煙霧、非確定）。
- 異常（守恆/order 記帳邊界/撲空率過高暗示供需不align）。
- 觀察：若履約率仍 0 → 商隊根本沒到場 trade（上游 targeting/reachability），非結算 bug，回報。

- [ ] **Step 4: Commit handback**
```bash
git add docs/superpowers/handbacks/2026-06-20-*order-fulfillment*.md
git commit -m "docs(economy): 訂單履約 headless + world_sim 煙霧回報"
```

---

## Self-Review 註記

- **純記帳**：只動 `active_orders.qty_remaining` + 移除 + probe。**零 resources/coin 變動** → 守恆數學上不可能破（回歸驗 coin_eq=0/InvariantAudit 0 為形式確認）。
- **不新建 order-directed 交易**：估值交易（既有）負責搬貨；結算只「認帳」。供需不 align → delta=0 → 撲空留單 = emergent（ruling 要的）。避免 over-engineer + 守恆風險。
- **度量窗正確性**：在 absorb/spillback 之間，team.resources = 私有+公庫完整持有，窗內只有這對 market 在動該隊 res → delta 歸因正確。spillback 後再 release。
- **單一所有者**：沖銷只動發起隊自己的 `active_orders`；商隊 received（message 副本）唯讀不動 → 無雙寫 race。
- **FIFO/delta 池**：同 res 多單共享淨變池依序配，不重複沖。
- **probe 已就緒**：`g1.order_fulfilled`/`g1.arb_hit` 早在 ProbeSummary 履約率/命中率公式（probe_stats:46-47），本 plan 補 bump = 點亮死指標。
- **TEST VALUE**：無新常數（沖銷是精確記帳）；履約「率」高低由既有交易 TEST VALUE（單價/reserve/range）決定，待確定性貿易場景平衡。
- **OUT**：腐壞/儲限（#1 plan-2）、mint（待重量）。
- **與已 merge 無衝突**：改 order_system/interaction，與 #0b(person_generator)/feud(npc_ai/combat) 不同檔。
