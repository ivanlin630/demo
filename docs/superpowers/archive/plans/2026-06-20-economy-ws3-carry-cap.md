# 經濟 WS-3：移動隊硬 carry cap + 救活馬車 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:test-driven-development + superpowers:executing-plans。Steps 用 checkbox 追蹤。

**Goal:** carry cap 從「只軟速度懲罰」→ 硬上限（超額存不下，intake 受限）。馬車/獸進 cap 公式但現無作用 → 硬 enforce 後 = 「商隊一趟能搬多少貨去市集」= 馬車終於有正經工作 + 解 WS-2 flag 的履約 throughput 限。

**Architecture:** intake-cap at source（conservation-safe，貨留 tile/seller 不憑空消滅）。新 `remaining_carry_space` helper；enforce 兩處 intake：①trade buy（買方 qty 受 carry 空間限 = throughput + 馬車 load-bearing）②forage/collect（移動無 outpost 隊採集受限）。`get_carry_capacity`（含馬車/獸 BONUS）已存在 → 本 WS 讓它真生效。既有軟速度懲罰保留（次級摩擦）。

**Tech Stack:** Godot 4.2.2 GDScript；`movement_system.gd`（helper）+ `interaction_system.gd`（trade buy cap）+ `resource_system.gd`（forage intake cap）；headless harness。

## Global Constraints

- wrapper 跑（UTF-8）：`.\tools\godot.ps1`。Windows PS 5.1 無 `&&`。
- 來源：spec `2026-06-20-economy-marketplace-caps-design`（WS-3）、ruling `economy-direction`。
- **守恆**：intake-cap = 貨留來源（tile/seller），**零 drop、零 coin 觸碰**（買方少買 → coin 少付，seller 少收 → 對稱守恆）。回歸驗 coin_eq=0/InvariantAudit 0。
- **無凍結**：carry cap 不可卡死移動/貿易（cap=0 隊仍能少量帶；helper floor 防除零）。
- 回歸閘：headless 全綠、coin_eq=0、InvariantAudit 0。world_sim 僅煙霧。
- 全 carry 常數（BASE_CARRY=10/MOUNT_BONUS=15/WAGON_BONUS=40）= 既有 TEST VALUE，本 WS 不調（除非回歸需要）。

## File Structure

- `scripts/simulation/movement_system.gd`（`remaining_carry_space` + per-res 空間 helper）。
- `scripts/simulation/interaction_system.gd`（trade buy qty 受 carry 空間限）。
- `scripts/simulation/resource_system.gd`（`_collect_from_tile` 移動無 outpost 隊 intake 受限）。
- `scripts/debug/headless_test.gd`（carry space / trade throughput / forage cap 測試）。

---

### Task 1: remaining_carry_space helper + trade buy 受 carry 限（馬車 load-bearing）

**Files:** Modify `movement_system.gd`、`interaction_system.gd`；Test `headless_test.gd`。

**病**：trade buy（`interaction:600,619`）buyer qty 只受 `buyer_coin` 限，不受 carry → 商隊無限囤貨、馬車對載量零作用。

- [ ] **Step 1: 寫失敗測試** `_test_carry_cap_trade()`（註冊）
```gdscript
func _test_carry_cap_trade() -> void:
	print("--- WS-3 trade 受 carry 限 + 馬車 ---")
	var ms := MovementSystem.new()
	# 小隊(pop 2)無馬車：carry = 2×BASE_CARRY=20；裝滿 goods(weight 1.0) → 空間 ~20
	var t := TeamData.new(); t.team_id = 0
	AnonCohort.add(t.anon_cohorts, "平民", "healthy", 2)
	t.resources = {"goods": 0.0}
	var space0: float = ms.remaining_carry_space(t)
	assert(space0 >= 19.0 and space0 <= 21.0, "pop2 carry 空間應~20，實際=%.1f" % space0)
	# 加馬車 → 空間大增（WAGON_BONUS=40）
	t.resources["wagons"] = 1.0
	var space1: float = ms.remaining_carry_space(t)
	assert(space1 > space0 + 30.0, "馬車應增載量，前=%.1f 後=%.1f" % [space0, space1])
	# 裝貨後空間縮
	t.resources["goods"] = 15.0
	var space2: float = ms.remaining_carry_space(t)
	assert(space2 < space1 - 14.0, "裝 15 goods 後空間應縮，實際=%.1f" % space2)
	print("carry cap trade OK (空間 pop2=%.1f +馬車=%.1f 裝貨後=%.1f)" % [space0, space1, space2])
```
> 整合（trade throughput）測試在 Task3 確定性場景（買方滿載即止買）。

- [ ] **Step 2: --import + 跑驗證失敗**（`remaining_carry_space` 未定義）

- [ ] **Step 3: 實作**
  - `movement_system.gd` 加：
    ```gdscript
    # 剩餘載重空間（weight 單位）= carry_cap − 當前總重，floor 0。
    func remaining_carry_space(team: TeamData) -> float:
        return maxf(get_carry_capacity(team) - calc_total_weight(team), 0.0)
    # 某 res 還能裝幾個（依 _resource_weight；重量 0 的工具→大數不設限）。
    func carry_space_for_res(team: TeamData, res: String) -> int:
        var w: float = _resource_weight(res)
        if w <= 0.0: return 1 << 30
        return int(remaining_carry_space(team) / w)
    ```
  - `interaction_system.gd._attempt_trade_direction` buyer intake 兩處受限（與 buyer_coin 取 min）：
    - inventory 買（:600）：`inv_qty = mini(inv_qty, ms.carry_space_for_res(buyer, item["grade"]))`。
    - surplus 買（:619 `qty`）：`qty = mini(qty, ms.carry_space_for_res(buyer, res))`。
    - 需 `var ms := MovementSystem.new()`（函式頭）。`qty<=0` 既有守衛續跳（買方滿載即不買）。
  > 守恆：買方少買 → `_execute_transfer`/coin 對稱少動（seller 留貨），零破壞。

- [ ] **Step 4: --import + 跑驗證通過**（`carry cap trade OK`、`=== DONE ===`、coin_eq=0、InvariantAudit 0）。既有 trade 測試若依賴無限買 → 對齊（買方 carry 足則行為不變）。

- [ ] **Step 5: Commit** `feat(economy): trade buy 受 carry 空間限(馬車 load-bearing throughput)`

---

### Task 2: forage/collect intake 受 carry 限（移動隊硬上限）

**Files:** Modify `resource_system.gd`；Test `headless_test.gd`。

**病**：`_collect_from_tile` 無 outpost 隊 food/material 走 else → team.resources **無限**累積（移動隊版幽靈囤）。

**修**：移動無 outpost 隊 intake gain 受 carry 空間限（capped intake，超額留 tile = conservation-safe）。定居隊（有 outpost → 進糧倉，WS-1）不受此限（cap 在糧倉）。

- [ ] **Step 1: 寫失敗測試** `_test_carry_cap_forage()`（註冊）
```gdscript
func _test_carry_cap_forage() -> void:
	print("--- WS-3 forage intake 受 carry 限 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var t := TeamData.new(); t.team_id = 0; t.tile_pos = Vector2i(2,2)
	AnonCohort.add(t.anon_cohorts, "平民", "healthy", 2)   # carry≈20，無 outpost
	t.resources = {"material": 0.0}
	var tile := HexTileData.new(); tile.tile_pos = Vector2i(2,2)
	tile.resources = {"material": 99999.0}; tile.productivity = 1.0   # 無 outpost_level
	state.world.tiles[2*1000+2] = tile
	state.teams[0] = t
	var rs := ResourceSystem.new()
	for i in 50:
		rs._collect_from_tile(state, t, tile, 1.0, 1.0, 0.0, 0.0)
	var ms := MovementSystem.new()
	# material(weight 1.0) 不該超 carry cap 太多（硬上限，非無限囤）
	assert(ms.calc_total_weight(t) <= ms.get_carry_capacity(t) + 1.0, "移動隊總重應≤carry cap，實際 weight=%.1f cap=%.1f" % [ms.calc_total_weight(t), ms.get_carry_capacity(t)])
	# tile 的 material 留著（intake 留來源，守恆）
	assert(float(tile.resources["material"]) > 90000.0, "超額應留 tile")
	print("carry cap forage OK (weight=%.1f/cap=%.1f)" % [ms.calc_total_weight(t), ms.get_carry_capacity(t)])
```

- [ ] **Step 2: --import + 跑驗證失敗**（現無限囤）

- [ ] **Step 3: 實作** `resource_system.gd._collect_from_tile` 的 else 分支（非 PUBLIC_RESOURCES、非進糧倉的移動隊 res）：
  - gain 前算空間：`var space_qty: int = MovementSystem.new().carry_space_for_res(team, res)`；`gain = minf(gain, float(space_qty))`。
  - gain<=0 → 不採（continue，tile 不扣）。tile.resources 只扣實際 gain（既有 :217 `current - gain` 自然對齊）。
  > 守恆：超額不採 → 留 tile（regen 資源無妨）。只動移動無 outpost 隊；定居隊 food 走糧倉路徑（WS-1，不經此 else）。
  > 注意：weight 0 的 res（mounts/wagons）→ carry_space_for_res 回大數 → 不誤限。

- [ ] **Step 4: --import + 跑驗證通過**（`carry cap forage OK`、既有覓食/絕境測試綠——小隊覓食仍夠吃、不被 carry 卡死絕境）

- [ ] **Step 5: Commit** `feat(economy): forage/collect intake 受 carry 限(移動隊硬上限,超額留 tile)`

---

### Task 3: 確定性 throughput 場景 + 回歸 + world_sim 煙霧 + 回報

**Files:** Test `headless_test.gd`；無產品 code 改。

- [ ] **Step 1: 確定性 throughput 測試** `_test_trade_throughput_wagon()`
  - 賣家滿貨 + 買方有大量 coin：跑 trade，斷言買方進貨量 ≈ carry 空間（非 coin 上限）。
  - 同場景買方加馬車 → 進貨量顯著增（馬車 = 更多 throughput）。
  - 守恆：seller 出貨=buyer 進貨、coin 對稱。

- [ ] **Step 2: headless 回歸**：`=== DONE ===`、四新測 OK、既有覓食/trade/飢荒測試綠、coin_eq=0、InvariantAudit 0。

- [ ] **Step 3: world_sim 煙霧（非閘）**：跑通無 SCRIPT ERROR；觀察 `訂單履約率`/`[Market]成交` 對照 WS-2 後（throughput 上限後一趟搬更多 → 履約量是否升）；移動隊不再無限囤（總重≤cap）；無凍結（貿易/覓食仍發生）。

- [ ] **Step 4: 回報 handback** `2026-06-20-implementer-to-systems-economy-ws3.md`（`from: implementer / to: systems / status: open`）：四測結果、world_sim 履約/成交對照 + 移動隊總重對照、馬車對載量實效、有無凍結/AI 失衡、異常。

- [ ] **Step 5: Commit handback** `docs(economy): WS-3 carry cap+馬車 回報`

---

## Self-Review 註記

- **守恆安全**：全 intake-cap at source（trade 買方少買→seller 留貨+coin 對稱；forage 超額留 tile）→ 零 drop、零 coin 觸碰。coin_eq 形式確認。
- **鐵則達標**：carry cap + 馬車改變 NPC 決策**結果**（商隊一趟搬多少貨 = trade throughput；移動隊何時滿→該卸/賣）。馬車從裝飾→load-bearing。
- **無凍結**：helper floor 0 + 既有 qty<=0 守衛；cap 不卡死移動（速度懲罰仍軟）。小隊覓食仍夠維生（既有絕境測試守）。
- **定居 vs 移動**：定居隊 food 走糧倉 cap（WS-1）；移動無 outpost 隊走本 WS carry cap。兩路徑互補，不重複限。
- **loot 不在本 WS**：戰利品超 carry = 後續（屠城搬不完 = 另議）；本 WS 限 trade + forage 經濟迴路。
- **與已 merge 無衝突**：改 movement/interaction/resource，與 WS-1(resource food 糧倉段)/WS-2(order/faction dispatch) 不同函式區（resource_system 的 _collect else 分支 WS-1 已把 food 移走→本 WS 只剩 material 等非糧；確認不撞 WS-1 food 路徑）。
- **後續**：BASE_CARRY/MOUNT/WAGON 平衡（throughput 太鬆/太緊）、loot carry、WS-4 糧倉設施。
- **TEST VALUE**：carry 常數沿用既有；FOOD 等 weight 沿用 `_resource_weight`。
