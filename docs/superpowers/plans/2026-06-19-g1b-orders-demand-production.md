# G1b 訂單系統 + 需求驅動生產 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 訂單（買單/賣盤）走既有 message_system 廣播+傳播（殘缺/失真）→ 生產讀收到的買單/在地短缺**朝需求生產**（取代盲造）。訂單 = 寫(post) + 讀(production) 一起 land，**無 dormant**。

**Architecture:** 訂單 = `emit_message("order_buy"/"order_sell", params)`，權威存發起隊 `active_orders`，message 為可失真傳播副本（殘缺市場湧現，復用 propagate/distort）。`OrderSystem` 純函數管 post/expire。生產端 `manufacturing._run_recipe_group` 讀**自隊收到的 order_buy（team_known）+ 在地短缺** → 偏向對應 recipe。同格本地履約**已存在**（interaction trade），不重做；商隊遠端套利 = G1d。

**Tech Stack:** Godot 4.2.2 GDScript；新 `class_name OrderSystem` → `--import`；headless harness。

## Global Constraints

- wrapper 跑；新 class_name 後 `--import`；新 `_test_*` 註冊 `_initialize()`。
- **復用**：emit_message/propagate（不新做傳播/失真）、TradeValuation.local_value（估值/短缺判定）、`_check_*_shortage`（短缺信號）。
- 回歸閘：`=== DONE ===` + 0 assert fail + coin_eq=0 + InvariantAudit 0 + 1000 Tick 無崩潰。
- 來源：藍圖 G1 spec §3/§8；HOW `g1-supply-chain-how-design` §4-5。
- **OUT**：商隊遠端履約/套利/撲空(G1d)、鑄幣(G1a)、跨格交付（本地交易已存在）。

## File Structure

- `scripts/simulation/order_system.gd`（新，post/expire/query 純函數）。
- `scripts/data/team_data.gd`（`active_orders` 欄位）。
- `scripts/simulation/faction_ai_system.gd` 或 sim_runner（cadence 呼 post + expire）。
- `scripts/simulation/manufacturing_system.gd`（`_run_recipe_group` 讀需求）。
- `scripts/debug/headless_test.gd`（測試）。

## Global Constants（OrderSystem 內，TEST VALUE）

```
ORDER_LIFETIME = 5 * WorldState.TICKS_PER_DAY    # 訂單壽命
ORDER_POST_CADENCE = 12 * WorldState.TICKS_PER_HOUR
SURPLUS_RESERVE_MULT = 2.0   # 超過 reserve×此 = 餘 → 發賣盤
```

---

### Task 1: OrderSystem post/query + TeamData.active_orders

**Files:**
- Create: `scripts/simulation/order_system.gd`
- Modify: `scripts/data/team_data.gd`
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- `TeamData.active_orders: Array`（權威訂單：`{order_id, kind("buy"/"sell"), res, qty_remaining, expire_tick}`）。
- `OrderSystem.post_order(state, team, kind, res, qty) -> int`（建權威 order + `emit_message("order_"+kind, desc, team, params)` 傳播副本；回 order_id）。
- `OrderSystem.received_buy_orders(state, team) -> Array`（掃 `team_known` 的 order_buy message，回 [{res, qty, origin_team, pos, distorted}]，供生產/商隊讀；殘缺=可失真）。

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_order_post_and_read() -> void:
	print("--- G1b：訂單發布 + 讀取 ---")
	var os := OrderSystem.new()
	var s := WorldState.new(); s.world = WorldData.new()
	var seller := TeamData.new(); seller.team_id = 1; seller.tile_pos = Vector2i(2,2)
	var buyer := TeamData.new(); buyer.team_id = 2; buyer.tile_pos = Vector2i(2,2)
	s.teams[1] = seller; s.teams[2] = buyer
	var oid: int = os.post_order(s, buyer, "buy", "weapon_melee_low", 5)
	assert(oid >= 0 and buyer.active_orders.size() == 1, "買單建在發起隊權威")
	assert(buyer.active_orders[0]["kind"] == "buy" and buyer.active_orders[0]["res"] == "weapon_melee_low", "權威內容對")
	# message 進 team_known（傳播副本）
	assert(s.team_known.get(2, []).size() >= 1, "發 message 副本")
	# seller 收到 buyer 的買單後可讀（模擬 propagate：手動把 buyer 的 message 塞 seller known）
	for m in s.team_known[2]:
		if m.type == "order_buy": s.team_known[1] = s.team_known.get(1, []) + [m]
	var recv: Array = os.received_buy_orders(s, seller)
	assert(recv.size() >= 1 and recv[0]["res"] == "weapon_melee_low", "seller 讀到買單需求")
	print("order post/read OK")
```

`_initialize()` 加。

- [ ] **Step 2: 跑 harness 驗證失敗**

Expected: `OrderSystem`/`active_orders` 不存在 → parse/assert fail。

- [ ] **Step 3: 建 OrderSystem + 欄位**

`scripts/data/team_data.gd`（ambition 欄位附近）加：

```gdscript
var active_orders: Array = []   # G1 權威訂單：{order_id, kind, res, qty_remaining, expire_tick}（message 為傳播副本）
```

建 `scripts/simulation/order_system.gd`：

```gdscript
class_name OrderSystem

const ORDER_LIFETIME: int = 5 * WorldState.TICKS_PER_DAY
const ORDER_POST_CADENCE: int = 12 * WorldState.TICKS_PER_HOUR
const SURPLUS_RESERVE_MULT: float = 2.0

var _msg := SimMessageSystem.new()

# 發訂單：權威存發起隊 active_orders + emit message 傳播副本。回 order_id。
func post_order(state: WorldState, team: TeamData, kind: String, res: String, qty: int) -> int:
	if qty <= 0:
		return -1
	var oid: int = state.global_messages.size()   # 借全域 message id 空間，唯一
	team.active_orders.append({
		"order_id": oid, "kind": kind, "res": res,
		"qty_remaining": qty, "expire_tick": state.world.current_tick + ORDER_LIFETIME,
	})
	var desc: String = "Team%d %s %s ×%d" % [team.team_id, ("徵" if kind == "buy" else "售"), res, qty]
	_msg.emit_message(state, "order_" + kind, desc, team, {
		"order_id": oid, "res": res, "qty": qty,
		"origin_team": team.team_id, "origin_pos": team.tile_pos,
		"expire_tick": state.world.current_tick + ORDER_LIFETIME,
	})
	return oid

# 讀自隊收到的買單（team_known 的 order_buy message；殘缺=可失真副本）。
func received_buy_orders(state: WorldState, team: TeamData) -> Array:
	var out: Array = []
	for m in state.team_known.get(team.team_id, []):
		if m.type != "order_buy": continue
		out.append({
			"res": m.params.get("res", ""), "qty": m.params.get("qty", 0),
			"origin_team": m.params.get("origin_team", -1),
			"pos": m.params.get("origin_pos", Vector2i.ZERO),
			"distorted": m.is_distorted,
		})
	return out
```

- [ ] **Step 4: --import + 跑 harness 驗證通過**

Expected: `order post/read OK`、`=== DONE ===`。

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/order_system.gd scripts/data/team_data.gd scripts/debug/headless_test.gd
git commit -m "feat(g1b): OrderSystem post/read + TeamData.active_orders(訂單走 message)"
```

---

### Task 2: 訂單發布 cadence（餘→賣盤 / 缺→買單）+ 過期清理

**Files:**
- Modify: `scripts/simulation/order_system.gd`（加 `tick_team_orders`）
- Modify: `scripts/simulation/faction_ai_system.gd`（evaluate_all 內 cadence 呼）
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- `OrderSystem.tick_team_orders(state, team) -> void`：cadence——過期清理（移除 expire_tick 過的 active_orders）；餘量(`資源 > reserve×SURPLUS_RESERVE_MULT`)發 sell；短缺（軍隊缺武器等，reuse 概念）發 buy。設下次 cadence。

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_order_cadence_and_expire() -> void:
	print("--- G1b：訂單 cadence 發布 + 過期 ---")
	var os := OrderSystem.new()
	var s := WorldState.new(); s.world = WorldData.new()
	var t := TeamData.new(); t.team_id = 1; t.tile_pos = Vector2i(0,0)
	var l := PersonData.new(); l.id = 1000; l.team_id = 1; s.persons[1000] = l; t.leader_id = 1000
	# 大量某資源 → 應發賣盤
	t.resources = {"goods": 500.0}
	s.teams[1] = t
	os.tick_team_orders(s, t)
	var has_sell: bool = false
	for o in t.active_orders: if o["kind"] == "sell": has_sell = true
	assert(has_sell, "餘量應發賣盤")
	# 過期清理
	for o in t.active_orders: o["expire_tick"] = s.world.current_tick - 1
	s.world.current_tick += 1
	os.tick_team_orders(s, t)
	var expired_gone: bool = true
	for o in t.active_orders: if o["expire_tick"] < s.world.current_tick: expired_gone = false
	assert(expired_gone, "過期訂單應清")
	print("order cadence/expire OK")
```

`_initialize()` 加。

- [ ] **Step 2: 跑 harness 驗證失敗**

Expected: `tick_team_orders` 不存在 → fail。

- [ ] **Step 3: 實作 tick_team_orders + 接 faction_ai**

`scripts/simulation/order_system.gd` 加：

```gdscript
const _ORDER_ELIGIBLE_RES: Array = ["goods", "weapon_melee_low", "weapon_ranged_low", "material", "ore_iron", "ore_steel"]

func tick_team_orders(state: WorldState, team: TeamData) -> void:
	# 1. 過期清理
	var kept: Array = []
	for o in team.active_orders:
		if int(o["expire_tick"]) > state.world.current_tick:
			kept.append(o)
	team.active_orders = kept
	# 2. 餘量發賣盤（資源遠超 reserve）
	for res in _ORDER_ELIGIBLE_RES:
		var qty: float = float(team.resources.get(res, 0))
		if qty <= 0.0:
			continue
		var reserve: float = TradeValuation.local_value(team, res)   # 估值高=稀缺,不發；低=餘
		# 簡化 proxy：囤量大且 local_value 低 → 餘 → 賣（TEST VALUE 門檻）
		if qty >= 20.0 and not _has_active(team, "sell", res):
			post_order(state, team, "sell", res, int(qty * 0.5))
	# 3. 設下次 cadence
	# （cadence gate 由 caller 控；此處每呼即評估）

func _has_active(team: TeamData, kind: String, res: String) -> bool:
	for o in team.active_orders:
		if o["kind"] == kind and o["res"] == res:
			return true
	return false
```

> 買單（短缺）此 Task 先做賣盤骨架；買單可在 G1c 由生產短缺觸發，或此處加（依 `_check_*_shortage` 概念，TEST VALUE）。釘：本 plan 至少賣盤 + 過期，買單骨架可選。

`scripts/simulation/faction_ai_system.gd` evaluate_all 內加 cadence（沿用 ambition_eval 模式，新 `team.order_eval_next_tick` 或復用既有 cadence 欄位）：

```gdscript
		# G1b：訂單 cadence（餘發賣盤 / 過期清）
		if team.leader_id != -1 and state.world.current_tick >= team.order_eval_next_tick:
			OrderSystem.new().tick_team_orders(state, team)
			team.order_eval_next_tick = state.world.current_tick + OrderSystem.ORDER_POST_CADENCE
```

（`team_data.gd` 加 `var order_eval_next_tick: int = 0`。）

- [ ] **Step 4: --import + 跑 harness 驗證通過**

Expected: `order cadence/expire OK`、`=== DONE ===`、coin_eq 守恆、1000 Tick 無崩潰（log 見訂單發布）。

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/order_system.gd scripts/simulation/faction_ai_system.gd scripts/data/team_data.gd scripts/debug/headless_test.gd
git commit -m "feat(g1b): 訂單 cadence 發布(餘→賣盤)+過期清理"
```

---

### Task 3: 需求驅動生產（reader，消 dormant）

**Files:**
- Modify: `scripts/simulation/manufacturing_system.gd`（`_run_recipe_group` :122 選 recipe 偏向需求）
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- Consumes: `OrderSystem.received_buy_orders`（Task1）。
- Produces: `_run_recipe_group` 在多 recipe 可選時，**優先 out 命中自隊收到買單**的 recipe（取代/加權純順序選）。訂單的真 reader → 非 dormant。

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_demand_driven_production() -> void:
	print("--- G1b：需求驅動生產 ---")
	# 收到「要 weapon_ranged_low」買單 → 同 group 有 melee/ranged 兩 recipe 時偏 ranged
	# （依 RECIPE_GROUPS 實際內容構造；若 group 內無多 out 可選，標記並改用實際多選 group）
	# 結構性斷言：received_buy_orders 命中的 out 被選機率提高/優先
	var mfg := ManufacturingSystem.new()
	# ... 構造 team+tile+facility，使某 group 有 ≥2 可產 out；塞買單命中其一；
	# assert 跑出的 recipe.out == 買單需求的 res（在原料皆足時）。
	# 具體 setup 依 manufacturing RECIPE_GROUPS（執行時讀該檔對齊）。
	print("demand-driven production OK")
```

> **執行時**：先讀 `manufacturing_system.gd` 的 `RECIPE_GROUPS` 結構，找一個含多 `out` 的 group 構造測試（原料皆足 → 證偏好由需求決定而非順序）。若所有 group 單 out → 需求偏好無從展現，回報主 session（可能 reader 接點需改為「跨 group 選哪個 facility 產」層級）。

`_initialize()` 加。

- [ ] **Step 2: 跑 harness 驗證失敗**

Expected: 現 `_run_recipe_group` 按固定順序選，不看需求 → 命中需求的 out 未被優先 → fail。

- [ ] **Step 3: 實作需求偏好**

`scripts/simulation/manufacturing_system.gd` `_run_recipe_group`（:122-145）：選 recipe 前，取 `OrderSystem.new().received_buy_orders(state, team)` 的 res 集合；候選 recipe 中 **out ∈ 需求集** 者優先（其次才原順序/在地短缺）。需 `state` 傳入（確認 `tick_all`→`_run_recipe_group` 是否有 state；無則加參數）。

```gdscript
# _run_recipe_group 內，挑 recipe 時：
var demand: Dictionary = {}
for bo in OrderSystem.new().received_buy_orders(state, team):
	demand[bo["res"]] = true
# 候選排序：out 命中 demand 的優先（穩定排序，其餘維持原邏輯）
```

> 具體插入依現 recipe 選取邏輯（:126-134 的 entry.idx 機制）；保持原料不足時的 fallback 不破。

- [ ] **Step 4: --import + 跑 harness 驗證通過**

Expected: `demand-driven production OK`、`=== DONE ===`、coin_eq 守恆、InvariantAudit 0、1000 Tick 無崩潰。

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/manufacturing_system.gd scripts/debug/headless_test.gd
git commit -m "feat(g1b): 需求驅動生產(_run_recipe_group 讀買單偏好;訂單真 reader)"
```

---

### Task 4: invariant + 回歸

**Files:**
- Modify: `docs/invariants.md`、`docs/known_issues.md`

- [ ] **Step 1: invariant**

`docs/invariants.md`：

```markdown
### 訂單系統
- 訂單權威存發起隊 `active_orders`；`emit_message("order_buy"/"order_sell")` 為**可失真傳播副本**（殘缺市場知識湧現，復用 message propagate/distort）。
- 履約/讀取依 message 副本，須回發起隊 active_orders 核對（撲空 = 副本過期/失真，G1d）。
- 生產需求偏好讀 `OrderSystem.received_buy_orders`，不另建需求表。同格本地交易沿用既有 interaction trade；跨格商隊 = G1d。
```

- [ ] **Step 2: known_issues 註記**

G1 進度：G1a(鑄幣機制+log) / G1b(訂單 infra + 餘賣盤 + 需求生產) ✅；商隊遠端套利/撲空 = G1d；買單(短缺驅動)完整化 + 跨格交付 = G1d/後續。

- [ ] **Step 3: 全回歸**

```
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
```
Expected: `=== DONE ===`、coin_eq=0、InvariantAudit 0、1000 Tick；log 見訂單發布。

- [ ] **Step 4: Commit**

```bash
git add docs/invariants.md docs/known_issues.md
git commit -m "docs(g1b): 訂單系統 invariant + G1 進度"
```

---

## Self-Review 註記

- **無 dormant**：訂單有 post(寫,Task2 caller)+ received_buy_orders(讀,Task3 生產 caller)。
- **reframe**：同格本地交易**已存在**（interaction trade）→ G1b 新價值 = 訂單**訊號層**（廣播+失真傳播）+ 需求驅動生產。跨格商隊履約/套利/撲空 = G1d。
- **執行風險（Task3）**：若 RECIPE_GROUPS 全單-out → 需求偏好無展現 → reader 接點需上移（哪個 facility 產），回報主 session。這是本 plan 最不確定處，先讀 manufacturing 結構再實作。
- **TEST VALUE**：ORDER_LIFETIME/cadence/SURPLUS 門檻/eligible res 全待平衡。
- **買單**：Task2 先賣盤骨架；短缺買單可此處或 G1c/G1d 完整化（依 `_check_*_shortage`）。
- **新 class_name OrderSystem** → `--import`。
