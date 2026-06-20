# 經濟 WS-2：市集節點 + 解角色卡死（主角）Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:test-driven-development（每 Task 先寫失敗測試再實作）+ superpowers:executing-plans。Steps 用 checkbox 追蹤。

**Goal:** 讓 NPC 經濟決策真 fire——商業隊真被派去貿易（解角色卡死）+ 去固定市集（outpost）成交（解 co-location）。`[Market]成交` 2 年 5 次 → 常態；履約率 >> 0。

**Architecture:** market = **既有 outpost tile**。三病三修：①order pos route 到下單隊最近 outpost（固定會合點，非隨隊移動的舊 snapshot）②member 派工鏈：商隊-tag member 貿易意圖不被徵收/外交無條件 preempt ③solo：商隊 surplus 時 trade 可勝過 CAMP/FLEE。複用 `_can_trade`/`_merchant_trade_target`/`best_arbitrage_order`/既有派工，**非造新系統/新 tile 類型**。路上順路交易（`_resolve_market` co-location）原樣保留。

**Tech Stack:** Godot 4.2.2 GDScript；`order_system.gd`（market pos routing）+ `faction_ai_system.gd`（派工卡死）；headless + 確定性貿易場景 + world_sim 煙霧。

## Global Constraints

- wrapper 跑（UTF-8）：`.\tools\godot.ps1`。Windows PS 5.1 無 `&&`。
- 來源：spec `2026-06-20-economy-marketplace-caps-design`（WS-2）、ruling `2026-06-20-blueprint-to-systems-economy-direction`。
- **守恆**：本 WS 純決策/派工/order pos routing，**不碰 resources/coin 數值**（成交仍走既有 `_resolve_market` 守恆交易）→ coin_eq/InvariantAudit 無關（回歸驗 0 為形式確認）。
- 回歸閘：headless 全綠、coin_eq=0、InvariantAudit 0；**新增確定性貿易場景**（不靠 world_sim drift）；world_sim 僅煙霧（[[reference_multi_sanity_unseeded]]）。
- **AI 穩定守則**：改派工 scoring 須保守可逆 + 不凍結其他 AI（攻擊/覓食/防禦仍發生）。over-trade（隊全去貿易棄守）= 回報，別放任。
- 全 TEST VALUE。

## File Structure

- `scripts/simulation/order_system.gd`（`post_order` market pos routing + helper）。
- `scripts/simulation/faction_ai_system.gd`（member 鏈 + solo trade 卡死）。
- `scripts/debug/headless_test.gd`（market routing / 角色卡死 / 確定性貿易整鏈 測試）。

---

### Task 1: 訂單 route 到固定市集（outpost）→ 解 co-location

**Files:** Modify `order_system.gd`；Test `headless_test.gd`。

**病**：`post_order:27` order `origin_pos = team.tile_pos`（靜態 snapshot）→ 下單隊移走後商隊撲空。

**修**：order pos = 下單隊**最近自家 outpost tile**（固定會合點；定居隊住 outpost → 商隊去得到、人在那）。無 outpost（純漫遊隊）→ fallback team.tile_pos（罕見，原行為）。

- [ ] **Step 1: 寫失敗測試** `_test_order_market_routing()`（註冊）
```gdscript
func _test_order_market_routing() -> void:
	print("--- WS-2 訂單 route 到市集 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	# 下單隊有自家 outpost 在 (3,3)，但隊本身移到 (9,9)
	var t := TeamData.new(); t.team_id = 0; t.tile_pos = Vector2i(9,9)
	var tile := HexTileData.new(); tile.tile_pos = Vector2i(3,3); tile.outpost_owner = 0; tile.outpost_level = 1
	state.world.tiles[3*1000+3] = tile
	state.teams[0] = t
	var os := OrderSystem.new()
	os.post_order(state, t, "sell", "goods", 10)
	var o: Dictionary = t.active_orders[-1]
	# message 的 origin_pos 應 = outpost (3,3) 非隊位 (9,9)
	var msg = state.global_messages[-1]
	assert(msg.params["origin_pos"] == Vector2i(3,3), "order pos 應 route 到 outpost(3,3)，實際=%s" % str(msg.params["origin_pos"]))
	# 無 outpost 隊 → fallback 隊位
	var t2 := TeamData.new(); t2.team_id = 1; t2.tile_pos = Vector2i(5,5)
	state.teams[1] = t2
	os.post_order(state, t2, "buy", "material", 6)
	assert(state.global_messages[-1].params["origin_pos"] == Vector2i(5,5), "無 outpost → fallback 隊位")
	print("order market routing OK")
```

- [ ] **Step 2: --import + 跑驗證失敗**（現 origin_pos=隊位 9,9）

- [ ] **Step 3: 實作** `order_system.gd`：
  - 加 helper `_market_pos(state, team) -> Vector2i`：掃 `state.world.tiles` 找 `outpost_owner==team.team_id && outpost_level>0` 最近者；無 → `team.tile_pos`。（god-view scan = 下單隊自家 outpost，自知資訊，可接受。）
  - `post_order` 的 emit params `origin_pos` 改用 `_market_pos(state, team)`。（`active_orders` 內部記帳不變；只改傳播副本的會合 pos。）

- [ ] **Step 4: --import + 跑驗證通過**（`order market routing OK`、`=== DONE ===`、coin_eq=0、InvariantAudit 0）

- [ ] **Step 5: Commit** `feat(economy): 訂單 route 到固定市集 outpost(解 co-location)`

---

### Task 2: 解角色卡死 — 商隊真被派去貿易

**Files:** Modify `faction_ai_system.gd`；Test `headless_test.gd`。

**病**（investigator 定位）：
- **member 鏈**（`_assign_member_tasks:807-830`）：`if 徵收 / elif 外交 / elif 攻擊 / elif manufacture / elif trade`——徵收 cadence 常駐、商隊-tag 又中外交 → trade（最後）幾乎不到。
- **solo**（`_evaluate_solo:990-991`）：TASK_TRADE=(greed·0.5+0.3)·tag_weight ≤0.8；CAMP(尋家,無 tag_weight)≤0.9、FLEE 壓過。

**修（保守，商隊-tag 專屬，不動非商隊隊行為）**：
- **member**：商隊-tag member 若 `_can_trade` 且有強 arb 單（`best_arbitrage_order` 非空）→ 貿易意圖優先於徵收/外交 preempt（hoist：在 elif 鏈前先判商隊 trade）。**僅商隊 tag**（軍隊/生產不變）。
- **solo**：商隊-tag 隊 TASK_TRADE 分數加 `MERCHANT_TRADE_BONUS`（TEST VALUE），使有 surplus+arb 時能勝 CAMP（但 FLEE 生存仍應贏——絕境不貿易，保留 food_pc<2.0 FLEE 優先）。

- [ ] **Step 1: 寫失敗測試** `_test_merchant_trade_dispatch()`（註冊）
```gdscript
func _test_merchant_trade_dispatch() -> void:
	print("--- WS-2 商隊解卡死 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var fai := FactionAISystem.new()
	# 獨立商隊：有貨(goods 50>min)、有 arb 單可挑、非絕境(food 充足) → 應派 TASK_TRADE
	var m := TeamData.new(); m.team_id = 0; m.tags = ["商隊"]; m.tile_pos = Vector2i(5,5)
	m.faction_id = -1; m.ambition_archetype = AmbitionLadder.ARCHETYPE_TRADE
	m.resources = {"goods": 50.0, "food": 100.0, "coin": 200.0}
	var ml := PersonData.new(); ml.id = 10; ml.values["貪婪"] = 0.7
	state.persons[10] = ml; m.leader_id = 10
	# 另一隊在 outpost 掛 sell 單(arb 來源) — 簡化：直接塞 m 的 team_known 一張 sell order message
	state.teams[0] = m
	# 注入一張 received sell order（goods 便宜可搬）在 (5,5) 近處
	state.team_known[0] = [_mk_order_msg("order_sell", "material", 20, 1, Vector2i(5,6))]
	fai._evaluate_solo(state, m)
	assert(m.current_task == TeamData.TASK_TRADE, "商隊有 surplus+arb+非絕境 應派貿易，實際=%s" % m.current_task)
	print("merchant trade dispatch OK")

# helper：造 order message（若既有 helper 可複用則用既有）
func _mk_order_msg(type: String, res: String, qty: int, origin: int, pos: Vector2i) -> MessageData:
	var md := MessageData.new()
	md.type = type
	md.params = {"res": res, "qty": qty, "origin_team": origin, "origin_pos": pos, "order_id": 1}
	return md
```
> 註：實作者依 MessageData 真實欄位調整 helper（is_distorted 等預設）。若 `_evaluate_solo` 需更多 state（tile/世界），補最小 setup 使其不早 return。目標斷言 = 商隊被派 TASK_TRADE。

- [ ] **Step 2: --import + 跑驗證失敗**（現 CAMP/IDLE 勝出，非 TASK_TRADE）

- [ ] **Step 3: 實作**
  - `faction_ai_system.gd` 加 const `MERCHANT_TRADE_BONUS := 0.5`（TEST VALUE）。
  - **solo**（`_evaluate_solo` TASK_TRADE 分數）：`if team.tags.has("商隊"): scores[TASK_TRADE] += MERCHANT_TRADE_BONUS`（在 `_can_trade` 分支內）。保留 FLEE 生存優先（food_pc<2.0 不動）。
  - **member**（`_assign_member_tasks`）：在徵收/外交/攻擊 elif 鏈**之前**加：
    ```gdscript
    if mt.tags.has("商隊") and _can_trade(state, mt) \
            and not OrderSystem.new().best_arbitrage_order(state, mt).is_empty():
        var tt: Vector2i = _merchant_trade_target(state, mt)
        if tt != Vector2i(-1,-1) and TaskArbiter.try_set(state, mt, TeamData.TASK_TRADE, tt, TaskArbiter.PRIO_DISPATCH, "member_trade"):
            mt.trade_task_start_tick = state.world.current_tick
            continue
    ```
    （商隊有真 arb 單才搶先；無單 → 落回原鏈做徵收/外交，不浪費。**僅商隊 tag**。）

- [ ] **Step 4: --import + 跑驗證通過**（`merchant trade dispatch OK`、`=== DONE ===`、coin_eq=0、InvariantAudit 0）。既有 faction/solo 測試若依賴商隊原派工 → 對齊。

- [ ] **Step 5: Commit** `feat(economy): 解商隊角色卡死(member 鏈 hoist + solo trade bonus)`

---

### Task 3: 確定性貿易整鏈場景 + 回歸 + world_sim 煙霧 + 回報

**Files:** Test `headless_test.gd`（整鏈場景）；無產品 code 改。

- [ ] **Step 1: 確定性貿易整鏈測試** `_test_trade_chain_end_to_end()`
  - 建 2 隊：定居賣家（有 outpost 在固定 tile、surplus goods、發 sell 單 route 到 outpost）+ 商隊買家（缺 goods、有 coin、archetype TRADE）。
  - 跑數 tick：商隊讀單 → 派 TASK_TRADE → move 到市集 outpost → 與賣家 co-locate → `_resolve_market` 成交 → `settle_orders` 沖 sell 單 → `g1.order_fulfilled` bump。
  - 斷言：`Probe.counts["g1.order_fulfilled"] > 0` + 賣家 goods 減 + 商隊 goods 增（守恆）。
  - **確定性**（固定位置/資源，不靠 RNG drift）→ 穩定回歸閘。

- [ ] **Step 2: headless 回歸**：`=== DONE ===`、全測 OK、coin_eq=0、InvariantAudit 0。

- [ ] **Step 3: world_sim 煙霧（非閘）**：`[Market]成交` / `訂單履約率` 對照前次（2 年 5 次/0% → 期望暴增；world_sim 非確定僅趨勢）。觀察 over-trade（隊棄守全貿易？）。

- [ ] **Step 4: 回報 handback** `2026-06-20-implementer-to-systems-economy-ws2.md`（`from: implementer / to: systems / status: open`）：整鏈測試結果、world_sim Market/履約率對照、商隊是否真被派貿易、有無 over-trade/AI 失衡、異常。

- [ ] **Step 5: Commit handback** `docs(economy): WS-2 市集+角色卡死 回報`

---

## Self-Review 註記

- **三病三修對應**：Task1 解 co-location（固定市集 pos）、Task2 解角色卡死（member hoist + solo bonus）、Task3 證整鏈（確定性場景）。缺一則貿易不 fire（market 無 dispatch=空跑 / dispatch 無 market=撲空）→ 三 Task 同 plan。
- **守恆安全**：純決策/派工/order pos，成交走既有 `_resolve_market`（守恆）→ 不碰 resources 數值。
- **保守 + 商隊專屬**：role-unstick 只動商隊-tag 隊（軍隊/生產/定居派工不變）→ 限制 blast radius。member hoist 須「有真 arb 單」才搶先（無單不浪費 faction goal）。solo 保留 FLEE 生存優先（絕境不貿易）。
- **市集模型**：market=既有 outpost（零新 tile）。定居隊住 outpost→商隊去 outpost 找得到人 co-locate。漫遊買賣家仍難（fallback 隊位）但主體訂單來自定居 outpost 隊（surplus/shortage 都在據點）。
- **路上順路保留**：`_resolve_market` 任意兩隊 co-locate 照成交，未被市集取代（藍圖要的疊加戲）。
- **確定性驗收**：world_sim 非確定 → 機制正確靠 Task3 確定性整鏈場景，非 world_sim 數字。
- **AI 穩定**：world_sim 煙霧看 over-trade（隊棄守）；MERCHANT_TRADE_BONUS/hoist 條件 = TEST VALUE，過度則回報調。
- **後續 WS**：WS-1 食物糧倉 route+硬上限（滿信號）、WS-3 carry cap+馬車、WS-4 糧倉設施。本 plan 先證主角（貿易 fire），僕人後補。
- **與已 merge 無衝突**：改 order_system/faction_ai，與 #0b/feud/履約 不同關注點（履約改 _resolve_market 結算，本改 dispatch+order pos，同檔 order_system 但不同函式 post_order vs settle_orders）。
