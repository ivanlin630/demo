# 經濟 WS-2b：市集訂單可見性（破死鎖）Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:test-driven-development + superpowers:executing-plans。Steps 用 checkbox 追蹤。

**Goal:** 破訂單可見性死鎖——world_sim 履約 0%/[Market]0 的真因：訂單只在發起隊自己 team_known，跨隊只靠碰面傳播（`propagate_on_arrival`），商隊只在有 arb 才出門 → 永不碰面 → 永不知別隊訂單 → arb 永空。修：訂單登錄市集 outpost 看板，隊到市集**親讀**看板（firsthand honest）+ 商隊主動巡市集。

**Architecture:** **守 G3 傳播原則**（資訊靠物理在場、relay 可失真）。市集看板 = `tile.market_orders`（outpost tile 上的訂單登錄）；隊**抵達市集 tile** 才讀得到（親見=firsthand honest，非全域瞬移）；轉述他隊仍走既有 `propagate_on_arrival` 失真。商隊無 arb 時巡最近市集（破死鎖=有理由去）。複用既有 order message/team_known/`_resolve_market`/`settle_orders`，新增 1 tile 欄位 + 1 arrival 讀取步 + 商隊巡市集 fallback。

**Tech Stack:** Godot 4.2.2 GDScript；`tile_data.gd`（board 欄位）+ `order_system.gd`（登錄 board + 讀 board）+ `sim_runner.gd`（arrival 讀步）+ `faction_ai_system.gd`（巡市集 fallback）；headless + 確定性場景 + world_sim 量測。

## Global Constraints

- wrapper 跑（UTF-8）：`.\tools\godot.ps1`。Windows PS 5.1 無 `&&`。
- 來源：診斷（本 session world_sim 探針：訂單 100% own→arb 空）、ruling `economy-direction`（B 市集本意含訂單可見）、`economy-marketplace-caps-design`（WS-2）。
- **守 G3 原則**：firsthand 親讀看板=honest（同 vision 親見真值）；**轉述他隊仍失真**（不繞過 `propagate_on_arrival`）。**禁全域/無在場可見**。
- **守恆**：純資訊（team_known/board 登錄）+ 派工，**不碰 resources/coin**（成交走既有 `_resolve_market`）。coin_eq/InvariantAudit 無關（驗 0 形式確認）。
- 回歸閘：headless 全綠、coin_eq=0、InvariantAudit 0、確定性整鏈場景。**權威量測 = world_sim 履約率 0%→正**（本 WS 的真驗收，非別 harness）。
- 全 TEST VALUE。

## File Structure

- `scripts/data/tile_data.gd`（`market_orders` 欄位）。
- `scripts/simulation/order_system.gd`（post 登錄 board + `read_market_board` + 過期清理）。
- `scripts/simulation/sim_runner.gd`（arrival 讀 board 步）。
- `scripts/simulation/faction_ai_system.gd`（商隊無 arb → 巡最近市集 fallback）。
- `scripts/debug/headless_test.gd`（board 登錄/親讀/巡市集/整鏈 測試）。

---

### Task 1: 市集看板 — 訂單登錄 outpost tile

**Files:** Modify `tile_data.gd`、`order_system.gd`；Test `headless_test.gd`。

- [ ] **Step 1: 寫失敗測試** `_test_market_board_register()`（註冊）
```gdscript
func _test_market_board_register() -> void:
	print("--- WS-2b 訂單登錄市集看板 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var t := TeamData.new(); t.team_id = 0; t.tile_pos = Vector2i(3,3)
	var tile := HexTileData.new(); tile.tile_pos = Vector2i(3,3); tile.outpost_owner = 0; tile.outpost_level = 1
	state.world.tiles[3*1000+3] = tile
	state.teams[0] = t
	var os := OrderSystem.new()
	os.post_order(state, t, "sell", "goods", 10)
	# 訂單應登錄到市集 tile 看板
	assert(tile.market_orders.size() == 1, "看板應有 1 單，實際=%d" % tile.market_orders.size())
	assert(tile.market_orders[0]["res"] == "goods", "看板單 res 對")
	print("market board register OK")
```

- [ ] **Step 2: --import + 跑驗證失敗**（`market_orders` 欄位/登錄未做）

- [ ] **Step 3: 實作**
  - `tile_data.gd` 加 `var market_orders: Array = []`（看板：訂單登錄 {order_id,kind,res,qty,origin_team,expire_tick}）。
  - `order_system.post_order`：post 時於 `_market_pos` 對應的市集 tile 登錄一筆 board entry（與 active_orders 同資料）。無市集 tile（fallback 隊位非 outpost）→ 不登錄（漫遊隊無據點看板，回退既有碰面傳播）。
  - `tick_team_orders` 過期清理段：同步清市集 tile board 過期/已滿足單（reuse expire_tick + qty_remaining≤0）。
  > 守恆無關（純資訊登錄）。看板是 active_orders 的「市集面」鏡像，權威仍在發起隊 active_orders（settle 只動 active_orders；board 是可見性副本，過期/滿足同步清）。

- [ ] **Step 4: --import + 跑驗證通過**（`market board register OK`、`=== DONE ===`、coin_eq=0、InvariantAudit 0）

- [ ] **Step 5: Commit** `feat(economy): 訂單登錄市集 outpost 看板(market_orders)`

---

### Task 2: 親讀看板（firsthand honest）— 抵達市集讀訂單

**Files:** Modify `order_system.gd`、`sim_runner.gd`；Test `headless_test.gd`。

**設計**：隊抵達市集 outpost tile → 把該 tile `market_orders` 讀進自己 team_known（firsthand honest message，**不失真**——親眼讀公開看板，同 vision 親見=真值）。轉述他隊仍走既有 propagate 失真。

- [ ] **Step 1: 寫失敗測試** `_test_market_board_read()`（註冊）
```gdscript
func _test_market_board_read() -> void:
	print("--- WS-2b 抵達市集親讀看板 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	# 賣家 T0 在市集(3,3)掛 sell 單；商隊 T1 抵達(3,3)
	var t0 := TeamData.new(); t0.team_id = 0; t0.tile_pos = Vector2i(3,3)
	var tile := HexTileData.new(); tile.tile_pos = Vector2i(3,3); tile.outpost_owner = 0; tile.outpost_level = 1
	state.world.tiles[3*1000+3] = tile; state.teams[0] = t0
	var t1 := TeamData.new(); t1.team_id = 1; t1.tile_pos = Vector2i(3,3); t1.tags = ["商隊"]
	state.teams[1] = t1; state.team_known[1] = []
	var os := OrderSystem.new()
	os.post_order(state, t0, "sell", "material", 20)
	# T1 抵達市集 → 親讀看板 → team_known 應有該 sell 單(非自己的)
	os.read_market_board(state, t1)
	var rs := os.received_sell_orders(state, t1)
	var got := false
	for o in rs:
		if o["origin_team"] == 0 and o["res"] == "material": got = true
	assert(got, "抵達市集應親讀到 T0 的 sell 單(跨隊可見)")
	# firsthand = 不失真
	for m in state.team_known[1]:
		if m.type == "order_sell": assert(not m.is_distorted, "親讀看板應 honest 不失真")
	print("market board read OK")
```

- [ ] **Step 2: --import + 跑驗證失敗**（`read_market_board` 未做）

- [ ] **Step 3: 實作**
  - `order_system.read_market_board(state, team)`：team 在 outpost tile 上 → 把 tile.market_orders 中**非自己**的單轉成 order_buy/order_sell message 注入 team_known（is_distorted=false、honest、firsthand；去重 by order_id；pos=市集 tile）。
  - `sim_runner`：新增 `_step3c_read_market_board`（在 `_step3b_exchange_intel` 後），對 arrived_ids 中在 outpost tile 的隊呼 `read_market_board`。
  > 守恆無關。firsthand honest = 守 G3（親見真值；轉述才失真，由既有 propagate_on_arrival 處理 = 不改）。

- [ ] **Step 4: --import + 跑驗證通過**（`market board read OK`、`=== DONE ===`、coin_eq=0、InvariantAudit 0）

- [ ] **Step 5: Commit** `feat(economy): 抵達市集親讀看板(firsthand honest,跨隊訂單可見)`

---

### Task 3: 商隊巡市集 fallback（破死鎖）

**Files:** Modify `faction_ai_system.gd`；Test `headless_test.gd`。

**病**：商隊無 arb（沒讀過任何別隊單）→ `_merchant_trade_target` 落 `_find_trade_target`（god-view 移動隊，撲空）或 -1 → 永不去市集 → 永不讀看板 → 永無 arb。死鎖。

**修**：商隊無 arb 時，target = **最近市集 outpost**（非自家、有看板的據點）→ 去那讀看板/與居民成交。有理由出門 → 破死鎖。

- [ ] **Step 1: 寫失敗測試** `_test_merchant_seek_market()`（註冊）
```gdscript
func _test_merchant_seek_market() -> void:
	print("--- WS-2b 商隊無 arb 巡市集 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var fai := FactionAISystem.new()
	# 市集 outpost 在(8,8)；商隊在(5,5)無任何已知單
	var mkt := HexTileData.new(); mkt.tile_pos = Vector2i(8,8); mkt.outpost_owner = 9; mkt.outpost_level = 1
	state.world.tiles[8*1000+8] = mkt
	var m := TeamData.new(); m.team_id = 0; m.tags = ["商隊"]; m.tile_pos = Vector2i(5,5)
	m.faction_id = -1; m.ambition_archetype = AmbitionLadder.ARCHETYPE_TRADE
	m.resources = {"goods": 50.0, "food": 100.0, "coin": 200.0}
	var ml := PersonData.new(); ml.id = 10; ml.values["貪婪"] = 0.7; state.persons[10] = ml; m.leader_id = 10
	state.teams[0] = m; state.team_known[0] = []
	var tgt: Vector2i = fai._merchant_trade_target(state, m)
	assert(tgt == Vector2i(8,8), "無 arb 應巡最近市集(8,8)，實際=%s" % str(tgt))
	print("merchant seek market OK")
```

- [ ] **Step 2: --import + 跑驗證失敗**（現無 arb → -1 或 god-view 移動隊）

- [ ] **Step 3: 實作** `_merchant_trade_target`（faction_ai:1180）：
  - arb 非空 → 回 arb pos（既有）。
  - arb 空 → 新 fallback：找最近**有看板的市集 outpost**（`outpost_level>0`、非自家、可達）→ 回其 pos。reuse god-view tile scan（市集是公開地標，非偷看他隊內部）。
  - 都無 → 落既有 `_find_trade_target`（最終 fallback）。
  > 確定性：scan tile 找最近 outpost = 確定。商隊抵達後 Task2 親讀看板 → 下輪有 arb → 正常套利。

- [ ] **Step 4: --import + 跑驗證通過**（`merchant seek market OK`、既有 trade 測試對齊）

- [ ] **Step 5: Commit** `feat(economy): 商隊無 arb 巡最近市集(破可見性死鎖)`

---

### Task 4: 確定性整鏈 + 回歸 + **world_sim 權威量測** + 回報

**Files:** Test `headless_test.gd`；無產品 code 改。

- [ ] **Step 1: 確定性整鏈測試** `_test_market_trade_chain()`
  - 賣家定居市集掛 sell 單（登錄看板）+ 商隊遠處無 arb → 巡市集 → 抵達親讀看板 → 取得 arb → 與賣家 co-locate `_resolve_market` 成交 → `settle_orders` 沖單 → `g1.order_fulfilled` bump + board 同步清。
  - 斷言：`g1.order_fulfilled>0` + 守恆（賣家出=買家進、coin 對稱）。

- [ ] **Step 2: headless 回歸**：`=== DONE ===`、四新測 OK、既有全綠、coin_eq=0、InvariantAudit 0。

- [ ] **Step 3: world_sim 權威量測（本 WS 真驗收）**：
  - 跑 world_sim（建議 2-3 次看範圍，非確定）：`訂單履約率` 0%→**正**、`[Market]成交` 0→**>0**、`套利命中` n/a→有值。
  - 觀察商隊是否巡市集 + 親讀後 arb 非空 + 成交。
  - **若仍 0**：回報——可能商隊被 survival(`return_home`) 壓制不出門（次要旗標，本 session 診斷見），或市集 scan/讀步沒接上 → measure-first 再查，別硬調。

- [ ] **Step 4: 回報 handback** `2026-06-21-implementer-to-systems-economy-ws2b.md`（`from: implementer / to: systems / status: open`）：四測結果、**world_sim 履約率/成交對照前次(0%/0)**、商隊巡市集+親讀是否運作、是否仍被 survival 壓制、異常。

- [ ] **Step 5: Commit handback** `docs(economy): WS-2b 市集可見性 world_sim 量測回報(履約 0→?)`

---

## Self-Review 註記

- **守 G3 傳播原則**（用戶關切）：firsthand 親讀看板=honest（同 vision 親見=真值，物理在場才得）；**轉述他隊仍走既有 `propagate_on_arrival` 失真，零改**。**無全域/無在場可見**——必須抵達市集 tile 才讀得到。市集看板 = 公開地標的公開資訊（你站在市集才看得到告示），不破「資訊靠物理在場、可失真」。
- **破死鎖**：商隊巡市集（有理由出門）→ 抵達親讀看板（得跨隊單）→ arb 非空 → 成交。三環缺一仍死（Task1 登錄+Task2 親讀+Task3 巡）。
- **權威量測 = world_sim**：本 WS 專修 world_sim 0 交易；驗收必須 world_sim 履約 0→正（非 game_sim_test，那台隊密集碰面遮蔽了本 bug = WS-2 誤判通過的教訓）。
- **守恆安全**：純資訊（team_known/board）+ 派工，成交走既有 `_resolve_market`/`settle_orders`。board 是 active_orders 可見性鏡像，權威仍在 active_orders（settle 不碰 board，board 過期/滿足同步清）。
- **看板鏡像一致性**：board entry 過期/qty 滿足須與 active_orders 同步清（Task1 Step3），否則商隊讀到已滿足的幽靈單→撲空。實作確認同步。
- **次要旗標（本 WS 範圍外，量測旗）**：全隊卡 `return_home[survival]`（有糧仍 survival）可能壓制商隊出門 → 若 Task4 world_sim 仍 0 交易，這是下一個 measure-first 標的，**別在本 WS 硬修**。
- **與已 merge 關係**：補 WS-2（market pos routing 已做，可見性漏做）。改 tile_data/order_system(read+board,不碰 settle/post 既有邏輯)/sim_runner/faction_ai。
- **TEST VALUE**：市集 scan range（巡最近 outpost 是否設上限）、board 過期沿用 ORDER_LIFETIME。
