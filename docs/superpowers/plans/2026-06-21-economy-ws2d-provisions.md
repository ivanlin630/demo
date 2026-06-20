# 經濟 WS-2d：旅途乾糧（解糧倉拴住商隊）Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:test-driven-development + superpowers:executing-plans。Steps 用 checkbox 追蹤。

**Goal:** 解「糧倉拴住商隊」——WS-2c 後 market_arrive 0→100+ 但履約仍 0%。診斷：`effective_food` 的糧倉只在「隊站自家 outpost」才計（`own_granary_tile` 查 team.tile_pos）→ 商隊一離家找市集 → effective_food=私糧(低) → 誤判餓 → survival 拽回家 → 永出不了門做完整貿易。修：定居隊在自家 outpost 時補 carried food 旅途 buffer（N天份），出門帶著走。

**Architecture:** 「乾糧 buffer」——`resolve_consumption` 消耗後，隊在自家 outpost 且糧倉有糧 → 補 `team.resources["food"]` 到 `PROVISION_DAYS × pop × FOOD_PER_DAY`（從糧倉提）。出門後 effective_food=carried buffer（旅途夠活）+ 消耗吃 carried（既有合併池）→ survival/消耗一致，不誤餓。守恆安全（糧倉→team 同隊轉移）；buffer 小（N天份 << 囤糧 cap，不破 WS-1 殺囤）。

**Tech Stack:** Godot 4.2.2 GDScript；`resource_system.gd`（乾糧補給）；headless + world_sim 權威量測（履約脫 0!）。

## Global Constraints

- wrapper 跑（UTF-8）：`.\tools\godot.ps1`。Windows PS 5.1 無 `&&`。
- 來源：本 session 診斷（world_sim board 探針：T1 離家 effective_food↓→return_home 拴住；T6 無 outpost 真窮 forage）。
- **守恆**：乾糧補給 = 糧倉 food → team food（**同隊轉移，守恆**，非生成）。消耗扣除走既有合併池。coin_eq/InvariantAudit 無關（驗 0 形式確認）。
- **不破 WS-1 殺囤**：buffer = N天份（小，~pop×2.4×10）<< 糧倉 cap（2000-18000）→ 囤糧峰值仍封頂。
- **無飢荒回歸**：真絕境（糧倉空）→ 無糧可補 → buffer=現有 → 仍正確進 survival（既有飢荒測試守）。
- 回歸閘：headless 全綠、coin_eq=0、InvariantAudit 0。**權威量測 = world_sim 履約率 0%→正、[Market]成交 0→>0**（經濟 arc 總驗收）。
- 全 TEST VALUE。

## File Structure

- `scripts/simulation/resource_system.gd`（乾糧補給 block + PROVISION_DAYS const）。
- `scripts/debug/headless_test.gd`（乾糧補給 / 離家不誤餓 / 真絕境仍 survival 測試）。

---

### Task 1: 乾糧補給（自家 outpost 補 carried buffer）

**Files:** Modify `resource_system.gd`；Test `headless_test.gd`。

- [ ] **Step 1: 寫失敗測試** `_test_travel_provisions()`（註冊）
```gdscript
func _test_travel_provisions() -> void:
	print("--- WS-2d 旅途乾糧補給 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var t := TeamData.new(); t.team_id = 0; t.tile_pos = Vector2i(2,2); t.leader_id = 100
	_seed_pop(t, 5)
	t.resources = {"food": 0.0}    # 無 carried
	var tile := HexTileData.new(); tile.tile_pos = Vector2i(2,2)
	tile.outpost_owner = 0; tile.outpost_level = 1; tile.outpost_type = "civilian"
	tile.public_storage = {"food": 1000.0}
	state.world.tiles[2*1000+2] = tile
	var ldr := PersonData.new(); ldr.id = 100; state.persons[100] = ldr
	state.teams[0] = t
	var rs := ResourceSystem.new()
	var granary_before: float = 1000.0
	rs.resolve_consumption(state, [0], WorldState.TICKS_PER_DAY)
	# 消耗後應補 carried buffer（5人×2.4×PROVISION_DAYS）
	var buffer: float = 5.0 * ResourceSystem.FOOD_PER_PERSON_PER_DAY * ResourceSystem.PROVISION_DAYS
	assert(float(t.resources["food"]) >= buffer * 0.9, "應補 carried 乾糧 buffer，實際=%.1f 期望~%.1f" % [t.resources["food"], buffer])
	# 守恆：糧倉 + carried 總量 = 原 - 當日消耗（無生成）
	var total_after: float = float(t.resources["food"]) + float(tile.public_storage["food"])
	var consumed: float = 5.0 * ResourceSystem.FOOD_PER_PERSON_PER_DAY
	assert(abs(total_after - (granary_before - consumed)) < 1.0, "守恆：糧倉+carried = 原-消耗，實際 total=%.1f" % total_after)
	print("travel provisions OK (carried=%.1f 糧倉剩=%.1f)" % [t.resources["food"], tile.public_storage["food"]])
```

- [ ] **Step 2: --import + 跑驗證失敗**（現無乾糧補給，carried 消耗後仍 0）

- [ ] **Step 3: 實作** `resource_system.gd`：
  - 加 `const PROVISION_DAYS: float = 10.0`（TEST VALUE：旅途乾糧天數）。
  - `resolve_consumption` 消耗 block **後**，加乾糧補給：
    ```gdscript
    # WS-2d 旅途乾糧：隊在自家 outpost → 從糧倉補 carried food 到 buffer（出門帶著走，
    # 不被糧倉拴住）。糧倉→team 同隊轉移(守恆)。buffer 小(N天份)不破囤糧 cap。
    var gtile: HexTileData = own_granary_tile(state, team)
    if gtile != null:
        var buffer: float = float(team.population + team.minor_population) \
            * FOOD_PER_PERSON_PER_DAY * PROVISION_DAYS
        var carried: float = float(team.resources.get("food", 0))
        var need: float = buffer - carried
        if need > 0.0:
            var avail: float = float(gtile.public_storage.get("food", 0))
            var move: float = minf(need, avail)
            team.resources["food"] = carried + move
            gtile.public_storage["food"] = avail - move
    ```
  > 守恆：糧倉→carried 同隊轉移（總糧不變）。在自家 outpost 才補（own_granary_tile 非 null）。

- [ ] **Step 4: --import + 跑驗證通過**（`travel provisions OK`、`=== DONE ===`、coin_eq=0、InvariantAudit 0）

- [ ] **Step 5: 回歸測試**
  - `_test_provisioned_merchant_not_tethered()`：商隊帶 buffer 離開 outpost（移到非自家格）→ `effective_food` ≥ buffer → `_evaluate_survival` 不誤觸 return_home。
  - 真絕境（糧倉空）→ 無糧可補 → 仍正確 survival（既有飢荒測試 + 新測）。
  - **不破囤糧**：WS-1 `food granary cap` 測仍綠（buffer 小，糧倉仍封頂）。

- [ ] **Step 6: Commit** `feat(economy): 旅途乾糧補給(解糧倉拴住商隊;糧倉→carried buffer)`

---

### Task 2: 回歸 + **world_sim 權威量測（履約脫 0!）** + 回報

**Files:** Test `headless_test.gd`；無產品 code 改。

- [ ] **Step 1: headless 回歸**：`=== DONE ===`、新測 OK、**既有飢荒/糧倉/trade 全綠**、coin_eq=0、InvariantAudit 0。

- [ ] **Step 2: world_sim 權威量測（2-3 跑，經濟 arc 總驗收）**：
  - `訂單履約率` 0% → **正**、`[Market]成交` 0 → **>0**（商隊帶乾糧出門→到市集→讀板→與居民成交）。
  - `g1.market_arrive` 維持高、`g1.board_read` 0→**正**（商隊以 trade 意圖到市集讀板）。
  - `g1.merchant_survival` 維持低（商隊不再被糧倉拴回家）。
  - 世界無過餓（buffer 小、糧倉仍封頂；存活隊穩）。

- [ ] **Step 3: 回報 handback** `2026-06-21-implementer-to-systems-economy-ws2d.md`（`from: implementer / to: systems / status: open`）：新測結果、**world_sim 履約率/[Market]成交/board_read 對照前次(0%/0/≈0)**、商隊是否終於完成貿易、世界是否過餓/囤糧是否回升、異常。**若履約仍 0**：measure-first 報哪環卡（商隊到市集但不成交？board_read 升但 arb 仍空？），別硬調。

- [ ] **Step 4: Commit handback** `docs(economy): WS-2d 乾糧 world_sim 量測(履約 0→?)`

---

## Self-Review 註記

- **診斷鏈**：WS-2c 破 survival 鎖(market_arrive 0→100+) → 揭糧倉拴住（離家 effective_food↓→return_home）→ 本 WS 乾糧解拴。經濟 arc 逐層 measure-first 剝洋蔥。
- **守恆安全**：乾糧=糧倉→carried 同隊轉移（總糧不變，非生成）；消耗走既有合併池。coin_eq 形式確認。
- **不破 WS-1 殺囤**：buffer=N天份（~pop×2.4×10，小）<< 糧倉 cap → 囤糧峰值仍封頂。回歸驗 WS-1 granary cap 測綠。
- **無飢荒回歸**：真絕境（糧倉空）無糧可補 → 仍 survival（既有飢荒測試 + Task1 Step5 守）。
- **權威量測 = world_sim 履約脫 0**：本 WS 是經濟 arc 總驗收的最後一哩（機制全鋪好+survival 解+乾糧解拴→商隊應能完成貿易）。
- **獨立商隊 T6（無 outpost 真窮 forage）**：本 WS 不解（無糧倉可補乾糧）→ 若 world_sim 履約靠定居 outpost 隊間貿易已脫 0 即達標；T6 類純漫遊窮商隊的貿易=後續（需先有 coin/goods 換糧的 forage→trade 轉換，另議）。
- **若仍 0**：market_arrive 高 + board_read 升但不成交 → co-location/_resolve_market trade 條件（再 measure-first）。別硬調。
- **TEST VALUE**：PROVISION_DAYS=10。
