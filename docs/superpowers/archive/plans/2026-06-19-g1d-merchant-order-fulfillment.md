# G1d 商隊訂單履約/套利 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 讓 G1b 訂單 infra **活起來**：商業 archetype 隊讀**殘缺收到的訂單**（賣盤=哪便宜買、買單=哪缺貨賣）→ 套利驅動 TASK_TRADE 趕赴訂單發起地；補短缺發買單；撲空（stale/失真訂單）= emergent（既有 local_value 壞 deal）。

**Architecture:** 商隊目標**改由訂單驅動**（讀 `team_known` 的 order message = 殘缺情報），**取代 `_find_trade_target` 的 `team_discovered` 上帝視角**（符「目標決策讀殘缺情報」invariant）。到場履約復用既有 `interaction_system` 同格 trade（`resolve_trade_direct`/`_attempt_trade_direction`）。撲空無新機制：訂單過期/失真 → 到場供需已變 → 既有 local_value glut 給壞 deal。短缺發買單補進 `OrderSystem`。

**Tech Stack:** Godot 4.2.2 GDScript；headless harness。依賴 G1b（OrderSystem，已 merged）+ G2b（ambition_archetype，已 merged）。

## Global Constraints

- wrapper 跑；新 `_test_*` 註冊。
- 復用：`OrderSystem`、`TradeValuation.local_value`、既有 interaction 同格 trade、TaskArbiter。**不新做�they/失真/glut**。
- 行為變：商隊改追訂單（非上帝視角 coincidence）。回歸閘 `=== DONE ===` + 0 assert fail + coin_eq=0 + InvariantAudit 0 + 1000 Tick。
- 來源：藍圖 G1 spec §3-4/§9；HOW `g1-supply-chain-how-design` §6。
- **OUT**：信用幣/異地折價(藍圖移出 ③G3)、訂單部分履約的精細記帳（先整單/盡量履約）、distort 改 order params 的深究（先假設 distort 只動 description/strength，res/qty 不失真 → 撲空主要靠「過期」；若 distort 動 params 另議）。

## File Structure

- `scripts/simulation/order_system.gd`（`received_sell_orders` + 短缺發買單 + 套利挑單）。
- `scripts/simulation/faction_ai_system.gd`（商隊 targeting 改訂單驅動）。
- `scripts/debug/headless_test.gd`（測試）。

---

### Task 1: OrderSystem — received_sell_orders + 短缺發買單 + 套利挑單

**Files:**
- Modify: `scripts/simulation/order_system.gd`
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- `received_sell_orders(state, team) -> Array`（鏡像 received_buy_orders，掃 order_sell）。
- `tick_team_orders` 擴：**短缺發買單**——`_ORDER_ELIGIBLE_RES` 中 `資源 < SHORTAGE_QTY` 且 team 有對應需求（武力缺武器/生產缺料，TEST VALUE proxy）→ post_order("buy")。
- `best_arbitrage_order(state, merchant) -> Dictionary`：掃 received sell+buy 訂單，算套利分（sell盤：`local_value(merchant,res) - 訂單暗示價`；buy單：`訂單付價 - local_value`），回最高分 `{kind, res, qty, pos, origin_team, order_id}`（無回 {}）。距離 `MERCHANT_MAX_RANGE` 內。

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_received_sell_and_arbitrage() -> void:
	print("--- G1d：賣盤讀取 + 套利挑單 ---")
	var os := OrderSystem.new()
	var s := WorldState.new(); s.world = WorldData.new()
	var merchant := TeamData.new(); merchant.team_id = 1; merchant.tile_pos = Vector2i(0,0)
	var seller := TeamData.new(); seller.team_id = 2; seller.tile_pos = Vector2i(2,0)
	s.teams[1] = merchant; s.teams[2] = seller
	# seller 發賣盤 goods，傳到 merchant known
	var oid: int = os.post_order(s, seller, "sell", "goods", 10)
	for m in s.team_known.get(2, []):
		if m.type == "order_sell": s.team_known[1] = s.team_known.get(1, []) + [m]
	var sells: Array = os.received_sell_orders(s, merchant)
	assert(sells.size() >= 1 and sells[0]["res"] == "goods", "讀到賣盤")
	var best: Dictionary = os.best_arbitrage_order(s, merchant)
	assert(not best.is_empty() and best["origin_team"] == 2, "挑出套利單→seller")
	print("received_sell + arbitrage OK")
```

`_initialize()` 加。

- [ ] **Step 2: 跑 harness 驗證失敗**

Expected: `received_sell_orders`/`best_arbitrage_order` 不存在 → fail。

- [ ] **Step 3: 實作**

`scripts/simulation/order_system.gd` 加 const + 三函數：

```gdscript
const SHORTAGE_QTY: float = 3.0   # TEST VALUE：低於此視為短缺,發買單
const MERCHANT_MAX_RANGE: int = 20

func received_sell_orders(state: WorldState, team: TeamData) -> Array:
	var out: Array = []
	for m in state.team_known.get(team.team_id, []):
		if m.type != "order_sell": continue
		out.append({
			"res": m.params.get("res", ""), "qty": m.params.get("qty", 0),
			"origin_team": m.params.get("origin_team", -1),
			"pos": m.params.get("origin_pos", Vector2i.ZERO),
			"order_id": m.params.get("order_id", -1), "distorted": m.is_distorted,
		})
	return out

# 套利挑單：sell盤(便宜買)/buy單(高價賣) 取 local_value 差最大者（殘缺情報，讀 received）。
func best_arbitrage_order(state: WorldState, merchant: TeamData) -> Dictionary:
	var best: Dictionary = {}
	var best_score: float = 0.0   # 僅正套利
	for o in received_sell_orders(state, merchant):
		if o["origin_team"] == merchant.team_id: continue
		if _hex_dist(merchant.tile_pos, o["pos"]) > MERCHANT_MAX_RANGE: continue
		var gain: float = TradeValuation.local_value(merchant, o["res"]) * float(o["qty"]) * 0.1   # proxy：自評值高→值得搬回
		if gain > best_score:
			best_score = gain; best = {"kind": "sell", "res": o["res"], "qty": o["qty"], "pos": o["pos"], "origin_team": o["origin_team"], "order_id": o["order_id"]}
	for o in received_buy_orders(state, merchant):
		if o["origin_team"] == merchant.team_id: continue
		if _hex_dist(merchant.tile_pos, o["pos"]) > MERCHANT_MAX_RANGE: continue
		var stock: float = float(merchant.resources.get(o["res"], 0))
		if stock <= 0.0: continue   # 沒貨可賣給買單
		var gain2: float = TradeValuation.local_value(merchant, o["res"]) * minf(stock, float(o["qty"])) * 0.1
		if gain2 > best_score:
			best_score = gain2; best = {"kind": "buy", "res": o["res"], "qty": o["qty"], "pos": o["pos"], "origin_team": o["origin_team"], "order_id": o["order_id"]}
	return best

func _hex_dist(a: Vector2i, b: Vector2i) -> int:
	return int((abs(a.x - b.x) + abs(a.y - b.y) + abs(a.x + a.y - b.x - b.y)) / 2)
```

`tick_team_orders` 末加短缺發買單：

```gdscript
	# 3. 短缺發買單（缺料/缺武器 → 徵）
	for res in _ORDER_ELIGIBLE_RES:
		if float(team.resources.get(res, 0)) >= SHORTAGE_QTY:
			continue
		if _has_active(team, "buy", res):
			continue
		# 僅對 team「該有」的資源發買單（proxy：武力隊徵武器/料；避免亂徵）TEST VALUE
		if res in ["weapon_melee_low", "weapon_ranged_low", "material", "ore_iron", "ore_steel"]:
			post_order(state, team, "buy", res, int(SHORTAGE_QTY * 2))
```

> arbitrage 分數公式為 proxy（TEST VALUE）；精細「買價 vs 賣價」套利 = 平衡 pass 細調。`_hex_dist` 若 OrderSystem 無則加（或復用既有 hex_dist util）。

- [ ] **Step 4: 跑 harness 驗證通過**

Expected: `received_sell + arbitrage OK`、`=== DONE ===`、coin_eq 守恆。

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/order_system.gd scripts/debug/headless_test.gd
git commit -m "feat(g1d): received_sell_orders + 短缺發買單 + 套利挑單"
```

---

### Task 2: 商隊 targeting 改訂單驅動（取代上帝視角）

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`（商隊 trade targeting）
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- Consumes: `best_arbitrage_order`（Task1）、`ambition_archetype`（G2b）。
- Produces: 商業 archetype 隊 idle/可貿易時，取 `best_arbitrage_order` → 非空則 `TaskArbiter.try_set(TASK_TRADE, order.pos, PRIO_DISPATCH/FACTION, "merchant_order")` + 記目標（追擊/到場）。**取代 `_find_trade_target` 的 team_discovered 上帝視角**（該函數降級/停用於商隊主路徑；保留為 fallback 或刪，見 Step3）。

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_merchant_order_targeting() -> void:
	print("--- G1d：商隊追訂單(殘缺情報非上帝視角) ---")
	var fai := FactionAISystem.new()
	var s := WorldState.new(); s.world = WorldData.new()
	var m := TeamData.new(); m.team_id = 1; m.tile_pos = Vector2i(0,0)
	var ml := PersonData.new(); ml.id = 1; ml.team_id = 1; ml.values = {"貪婪": 0.9}
	s.persons[1] = ml; m.leader_id = 1
	m.ambition_archetype = AmbitionLadder.ARCHETYPE_TRADE
	m.resources = {"goods": 50.0}   # 有貨可賣
	m.current_task = TeamData.TASK_IDLE
	var buyer := TeamData.new(); buyer.team_id = 2; buyer.tile_pos = Vector2i(5,0)
	s.teams[1] = m; s.teams[2] = buyer
	# buyer 發買單 goods → 傳到 merchant known
	var os := OrderSystem.new()
	os.post_order(s, buyer, "buy", "goods", 10)
	for msg in s.team_known.get(2, []):
		if msg.type == "order_buy": s.team_known[1] = s.team_known.get(1, []) + [msg]
	# 直呼商隊 targeting 等價邏輯
	var best: Dictionary = os.best_arbitrage_order(s, m)
	assert(not best.is_empty() and best["pos"] == Vector2i(5,0), "套利目標=買單發起地(殘缺情報)")
	var ok: bool = TaskArbiter.try_set(s, m, TeamData.TASK_TRADE, best["pos"], TaskArbiter.PRIO_DISPATCH, "merchant_order")
	assert(ok and m.current_task == TeamData.TASK_TRADE and m.move_target == Vector2i(5,0), "趕赴訂單地")
	print("merchant order targeting OK")
```

`_initialize()` 加。

- [ ] **Step 2: 跑 harness 驗證失敗**

Expected: 商隊 targeting 未接訂單 → 行為不符（或既有 _find_trade_target 不看訂單）→ fail。

- [ ] **Step 3: 實作商隊訂單 targeting**

`scripts/simulation/faction_ai_system.gd`：找商隊設 TASK_TRADE 目標的接點（`_find_trade_target` 的 caller）。改為**先試訂單驅動**：

```gdscript
		# G1d：商業 archetype 隊優先追「收到的訂單」(殘缺情報)，非上帝視角 team_discovered
		if team.ambition_archetype == AmbitionLadder.ARCHETYPE_TRADE \
				and (team.current_task == TeamData.TASK_IDLE or team.current_task == TeamData.TASK_TRADE):
			var ord: Dictionary = OrderSystem.new().best_arbitrage_order(state, team)
			if not ord.is_empty():
				TaskArbiter.try_set(state, team, TeamData.TASK_TRADE, ord["pos"], TaskArbiter.PRIO_DISPATCH, "merchant_order")
				team.order_target_id = int(ord["origin_team"])   # 履約/追擊用（若欄位存在；否則復用既有 trade target 欄位）
```

> 接點：找現有商隊 TASK_TRADE 指派處（`_find_trade_target` caller）插入或取代。`_find_trade_target`（team_discovered 上帝視角）降為**無收到訂單時的 fallback**，或標 deprecated（違殘缺情報 invariant，最終應刪——本 plan 至少讓訂單路徑優先）。確認 `order_target_id` 欄位存在（grep；無則用既有 trade 目標欄位）。到場履約走既有 interaction 同格 trade（無需本 plan 改）。

- [ ] **Step 4: 跑 harness 驗證通過 + 1000 Tick 觀測**

Expected: `merchant order targeting OK`；`=== DONE ===`、coin_eq 守恆、InvariantAudit 0、1000 Tick；sim 中商隊朝 `[Order]` 發起地移動 + 既有 trade 履約（觀測分工鏈貨流）。

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(g1d): 商隊 targeting 改訂單驅動(殘缺情報,取代上帝視角 _find_trade_target)"
```

---

### Task 3: invariant + 撲空觀測 + 回歸

**Files:**
- Modify: `docs/invariants.md`、`docs/known_issues.md`

- [ ] **Step 1: invariant**

`docs/invariants.md`「訂單系統」段補：

```markdown
- 商隊（商業 archetype）目標**讀收到的訂單**（`team_known` order message = 殘缺/可失真），**禁讀 `team_discovered` 上帝視角**挑貿易對象（接「目標決策讀殘缺情報」總則）。
- 撲空 = 訂單過期/失真 → 到場供需已變 → 既有 local_value glut 給壞 deal（無新機制）。準情報值錢，為 ③G3 鋪路。
```

- [ ] **Step 2: known_issues / progress**

G1 進度：G1d ✅ 商隊訂單驅動 + 短缺買單 → G1b infra 閉環（賣盤有 reader、生產買單有來源）。撲空 emergent。`_find_trade_target` 上帝視角降 fallback/標 deprecated。剩 refinement：部分履約記帳、distort 對 order params、信用幣(③G3)。

- [ ] **Step 3: 全回歸 + 分工鏈觀測**

```
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
```
Expected: `=== DONE ===`、coin_eq=0、InvariantAudit 0、1000 Tick。log 觀測訂單發→傳→商隊趕赴→履約鏈（藍圖 §12 驗收）。

- [ ] **Step 4: Commit**

```bash
git add docs/invariants.md docs/known_issues.md docs/progress.md
git commit -m "docs(g1d): 商隊訂單驅動 invariant(殘缺情報)+G1 閉環進度"
```

---

## Self-Review 註記

- **閉環 G1b**：賣盤 → 商隊讀+追(Task2)；買單 → 短缺發(Task1)+商隊服務 → G1b 半 inert 解除。
- **殘缺情報合規**：商隊讀 team_known 訂單，非 team_discovered 上帝視角（修既有 `_find_trade_target` 的 invariant 違反）。
- **撲空無新機制**：訂單 stale → 既有 local_value glut（藍圖 §4）。emergent，靠觀測非硬閘。
- **守恆**：訂單只信號 + 履約走既有 trade（守恆已驗）→ coin_eq 不破。
- **執行確認**：`_find_trade_target` caller 接點（商隊 TASK_TRADE 指派處）；`order_target_id` 欄位是否存在；arbitrage 公式 proxy 待平衡；distort 是否動 order params（影響撲空語意，OUT 標假設不動 params）。
- **OUT**：部分履約記帳、distort×params、信用幣(③G3)、_find_trade_target 完全刪除（先降 fallback）。
