# food 買單側 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans. Steps use checkbox (`- [ ]`).

**Goal:** 缺糧隊發 food 買單 → 商隊可運糧 → food 雙向市集（補 WS-1 只賣不買）。

**Architecture:** `order_system.tick_team_orders` 加 food 買單分支（effective_food days < 門檻 → post buy food）。純 order 層、不碰守恆。

**Tech Stack:** Godot 4.2.2 GDScript。測試 `headless_test.gd` + `world_sim.gd`。

## Global Constraints
- wrapper 跑 Godot（UTF-8）。
- 不碰 resources/coin 池（post_order 只登錄）→ coin_eq/InvariantAudit 0。
- TEST VALUE：`FOOD_BUY_DAYS=4.0`、`FOOD_BUY_TARGET_DAYS=8.0`。

---

### Task 1: food 買單分支 + 單測

**Files:**
- Modify: `scripts/simulation/order_system.gd`（`tick_team_orders` + const）
- Test: `scripts/debug/headless_test.gd`（加 `_test_food_buy_order`，註冊）

**Interfaces:**
- Consumes: `ResourceSystem.effective_food(state,team)`、`ResourceSystem.FOOD_PER_PERSON_PER_DAY`、`OrderSystem.post_order`/`_has_active`、`Probe.bump`。
- Produces: 缺糧隊（effective_food days < FOOD_BUY_DAYS）發 food buy 單。

- [ ] **Step 1: 寫失敗測試**

`scripts/debug/headless_test.gd` 加（放 order 相關測試群，或 `_test_food_granary_sell` 附近；若無則放決策測群後）：

```gdscript
func _test_food_buy_order() -> void:
	print("--- food 買單(缺糧隊) ---")
	var os := OrderSystem.new()
	# 缺糧隊(team food低、無糧倉) → 發 food buy
	var s1 := WorldState.new(); s1.world = WorldData.new()
	var t := TeamData.new(); t.team_id = 0; t.tile_pos = Vector2i(3,3); t.leader_id = 100
	_seed_pop(t, 5); t.resources = {"food": 12.0}   # days=12/(5*2.4)=1.0 < FOOD_BUY_DAYS(4)
	var ldr := PersonData.new(); ldr.id = 100; s1.persons[100] = ldr; s1.teams[0] = t
	os.tick_team_orders(s1, t)
	var has_food_buy := false
	for o in t.active_orders:
		if o["kind"] == "buy" and o["res"] == "food": has_food_buy = true
	assert(has_food_buy, "缺糧隊應發 food buy 單，active=%s" % str(t.active_orders))
	# 飽糧隊 → 不發
	var s2 := WorldState.new(); s2.world = WorldData.new()
	var t2 := TeamData.new(); t2.team_id = 0; t2.tile_pos = Vector2i(3,3); t2.leader_id = 100
	_seed_pop(t2, 5); t2.resources = {"food": 240.0}   # days=20 > 4
	var l2 := PersonData.new(); l2.id = 100; s2.persons[100] = l2; s2.teams[0] = t2
	os.tick_team_orders(s2, t2)
	for o in t2.active_orders:
		assert(not (o["kind"] == "buy" and o["res"] == "food"), "飽糧隊不該發 food buy")
	print("food buy order OK")
```

註冊：headless `_run_sim_test` 內適當處加 `_test_food_buy_order()`（決策/order 測群）。

> 註：確認 order entry 欄位名（`kind`/`res`）對齊 `post_order` 實作（order_system.gd post_order 建的 dict key）。若不同（如 `"type"`），測試與斷言改用實際 key。

- [ ] **Step 2: 跑測試確認失敗**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: FAIL — 缺糧隊無 food buy 單（現 food 不在 shortage-buy）。

- [ ] **Step 3: 加 food 買單分支**

`scripts/simulation/order_system.gd`：const 區加：
```gdscript
const FOOD_BUY_DAYS: float = 4.0          # TEST VALUE：effective_food 低於此天數 → 發 food 買單
const FOOD_BUY_TARGET_DAYS: float = 8.0   # TEST VALUE：買到此 buffer
```
`tick_team_orders` 短缺買單迴圈後（line ~117 之後）加 food 買單：
```gdscript
	# food 買單：缺糧隊表達糧需求(effective_food=私產+自家糧倉,WS-2c 單源)→商隊運糧
	if not _has_active(team, "buy", "food"):
		var burn: float = maxf(float(team.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY, 0.001)
		var fdays: float = ResourceSystem.effective_food(state, team) / burn
		if fdays < FOOD_BUY_DAYS:
			var need: int = int((FOOD_BUY_TARGET_DAYS - fdays) * burn)
			if need > 0:
				post_order(state, team, "buy", "food", need)
				Probe.bump("g1.food_buy")
```

- [ ] **Step 4: 跑測試確認通過（含回歸）**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: PASS — `food buy order OK` + 既有 order/飢荒/survival 測全綠（食物賣單不受影響）；`=== DONE ===`、coin_eq/InvariantAudit 0。

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/order_system.gd scripts/debug/headless_test.gd
git commit -m "feat(order): food 買單側 — 缺糧隊發food buy(食物雙向市集,補WS-1只賣)"
```

---

### Task 2: 2 年 world_sim 驗收 + 回歸

**Files:** Verify only：`world_sim.gd`、`headless_test.gd`

- [ ] **Step 1: 跑 2 年 world_sim**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/world_sim.gd`
記 `[ProbeSummary]`：`g1.food_buy`、`order_placed`、`[Market]成交`。

- [ ] **Step 2: 判定**

- `g1.food_buy > 0`（缺糧隊有發 food 買單）= food 雙向市集成立。
- headless 全綠、coin_eq/InvariantAudit 0。
- 無異常（如全隊狂發 food 買單 = 門檻太高 → 檢查）。

- [ ] **Step 3: 全回歸閘**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: 全綠 `=== DONE ===`、coin_eq/InvariantAudit 0。

- [ ] **Step 4: handback（無 code 改則記量測）**

寫 handback：food_buy 探針數、food 雙向市集證據、回歸結果。

---

## 完成後
子 session handback：food buy 單機制、2 年 world_sim food_buy 數 + 雙向市集、回歸。

## Self-Review
- Spec coverage：food 買單分支=Task1 Step3；單測=Step1；2年sim=Task2。全覆蓋。
- Placeholder：無（order key 名 Step1 註明確認）。
- Type consistency：`FOOD_BUY_DAYS`/`FOOD_BUY_TARGET_DAYS: float`；`effective_food(state,team)->float`；`post_order(state,team,kind,res,qty)`；order dict key（`kind`/`res`）Step1 註明對齊 post_order。
