# 經濟 WS-1：食物糧倉 route + 硬上限 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:test-driven-development（每 Task 先寫失敗測試再實作）+ superpowers:executing-plans。Steps 用 checkbox 追蹤。

**Goal:** 殺食物幽靈囤（`resource_system:213` uncapped）→ 定居隊食物進 capped 糧倉、消耗從糧倉提領、糧倉滿觸發「該賣」決策。囤糧峰值 4-5萬 → 受 cap 封頂。

**Architecture:** 三修：①`_collect_from_tile` food route 進 outpost public_storage capped（像礦），over-cap drop（硬上限，food sink 無守恆問題）②`resolve_consumption` 從「team.resources + 糧倉」合併池吃（不論 food 在哪都不餓死，守恆 sink）③food 變 order-eligible + 糧倉滿 → sell 決策 fire（鐵則：cap 須改變某 NPC 決策）。食物專屬 cap array（staple 比通用大）。複用既有 storage cap/absorb 模式，**非造新系統**。

**Tech Stack:** Godot 4.2.2 GDScript；`resource_system.gd`（food route + 消耗）+ `outpost_system.gd`（food cap array）+ `order_system.gd`（food eligible + 糧倉 sell 信號）；headless harness。

## Global Constraints

- wrapper 跑（UTF-8）：`.\tools\godot.ps1`。Windows PS 5.1 無 `&&`。
- 來源：spec `2026-06-20-economy-marketplace-caps-design`（WS-1）、ruling `economy-direction`。
- **守恆**：food 是 sink、無守恆不變量（只 coin_eq 守恆）。food route = tile→糧倉（生產，cap 溢出 drop = sink）；消耗 = 池→吃（sink）。**不碰 coin/其他守恆 res**。回歸驗 coin_eq=0/InvariantAudit 0 為形式確認。
- **無飢荒回歸**：消耗改合併池後，定居隊**不可**因 food 移進糧倉而餓死（核心風險）。回歸必含「定居隊吃糧倉糧存活」測試。
- 回歸閘：headless 全綠、coin_eq=0、InvariantAudit 0。world_sim 僅煙霧（[[reference_multi_sanity_unseeded]]）。
- 全 cap/門檻 = TEST VALUE。
- **與 WS-2 並行無衝突**：WS-1 改 resource_system/outpost_system + order_system 的 `tick_team_orders`/`_ORDER_ELIGIBLE_RES`；WS-2 改 order_system 的 `post_order`/faction_ai dispatch。同檔 order_system 但不同函式 → naive merge 風險低，**merge 序：先進者先**，後者 rebase 驗。

## File Structure

- `scripts/simulation/outpost_system.gd`（food 專屬 cap）。
- `scripts/simulation/resource_system.gd`（food route 糧倉 + 消耗合併池）。
- `scripts/simulation/order_system.gd`（food order-eligible + 糧倉 sell 信號）。
- `scripts/debug/headless_test.gd`（cap/消耗/sell 信號 測試）。

---

### Task 1: 食物 route 進 capped 糧倉 + 食物專屬 cap

**Files:** Modify `outpost_system.gd`、`resource_system.gd`；Test `headless_test.gd`。

**病**：`resource_system:213` food 不在 PUBLIC_RESOURCES → else uncapped 塞 team.resources（4-5萬 幽靈囤）。

- [ ] **Step 1: 寫失敗測試** `_test_food_granary_cap()`（註冊）
```gdscript
func _test_food_granary_cap() -> void:
	print("--- WS-1 食物糧倉硬上限 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var t := TeamData.new(); t.team_id = 0; t.tile_pos = Vector2i(2,2)
	var tile := HexTileData.new(); tile.tile_pos = Vector2i(2,2)
	tile.outpost_owner = 0; tile.outpost_level = 1; tile.outpost_type = "civilian"
	tile.resources = {"food": 99999.0}; tile.productivity = 1.0; tile.harvest_factor = 1.0
	state.world.tiles[2*1000+2] = tile
	state.teams[0] = t
	var rs := ResourceSystem.new()
	# 大量採集多次
	for i in 50:
		rs._collect_from_tile(state, t, tile, 1.0, 1.0, 0.0, 0.0)
	var cap: float = OutpostSystem.new()._get_storage_cap(tile, "food")
	# 食物進糧倉 capped，team.resources food 不該爆量囤積
	assert(float(tile.public_storage.get("food", 0)) <= cap + 0.01, "糧倉 food 應 ≤ cap(%.0f)，實際=%.0f" % [cap, tile.public_storage.get("food",0)])
	assert(float(t.resources.get("food", 0)) < cap, "food 不應 uncapped 囤 team.resources，實際=%.0f" % t.resources.get("food",0))
	print("food granary cap OK (糧倉=%.0f/cap=%.0f)" % [tile.public_storage.get("food",0), cap])
```

- [ ] **Step 2: --import + 跑驗證失敗**（現 food 全進 team.resources uncapped）

- [ ] **Step 3: 實作**
  - `outpost_system.gd._get_storage_cap`：food 專屬 array（staple，比通用大）：
    ```gdscript
    const FOOD_STORAGE_CAP: Dictionary = {   # TEST VALUE：主糧 staple 容量(比通用大)
        "civilian": [2000.0, 6000.0, 18000.0],
        "military": [1500.0, 4500.0, 12000.0],
    }
    ```
    `_get_storage_cap` 開頭加：`if res == "food": return FOOD_STORAGE_CAP.get(tile.outpost_type, [2000.0,6000.0,18000.0])[clampi(tile.outpost_level-1,0,2)]`
  - `resource_system.gd._collect_from_tile`：food 走糧倉 capped 路徑（像礦）。把 `"food"` 從 else 分支移到「進 outpost public_storage capped」（與 PUBLIC_RESOURCES 同邏輯，over-cap drop）。無 outpost fallback 進 team（小隊）。
    > 守恆：tile.resources 已按 gain 扣；糧倉 minf cap → over-cap gain drop = food sink（無不變量，OK）。**注意**：稅基 `gained` 只記私產所得；food 進糧倉 → 不入 `gained`（與礦一致，礦也不課一般稅 NORMAL_TAX_RES=food/material/goods... 確認：food 在 NORMAL_TAX_RES！礦不在）。**坑**：food 原走 else 入 `gained` → 課一般稅；改進糧倉後跳過 gained → 一般稅行為變。實作者確認：定居隊 food 進村庫即「自己存自己村」（_apply_normal_tax:221 註「採集者即 owner→自己存自己村庫」）→ 直接進糧倉等義於課稅入村庫，**不重複**。保留無 outpost fallback 的 `gained` 記帳。

- [ ] **Step 4: --import + 跑驗證通過**（`food granary cap OK`、`=== DONE ===`、coin_eq=0、InvariantAudit 0）

- [ ] **Step 5: Commit** `feat(economy): 食物進 capped 糧倉(殺幽靈囤)+食物專屬 cap`

---

### Task 2: 消耗從合併池提領（無飢荒回歸）

**Files:** Modify `resource_system.gd`；Test `headless_test.gd`。

**病**：`resolve_consumption:106` 只讀 `team.resources["food"]`。food 移糧倉後定居隊 team.resources food≈0 → 會餓死。

**修**：消耗從「team.resources + 自家糧倉」合併池吃（先 team 後糧倉），food 在哪都不餓死。

- [ ] **Step 1: 寫失敗測試** `_test_consume_from_granary()`（註冊）
```gdscript
func _test_consume_from_granary() -> void:
	print("--- WS-1 消耗從糧倉提領 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var t := TeamData.new(); t.team_id = 0; t.tile_pos = Vector2i(2,2)
	_seed_pop(t, 10)   # 10 人
	t.resources = {"food": 0.0}   # team 無糧
	var tile := HexTileData.new(); tile.tile_pos = Vector2i(2,2)
	tile.outpost_owner = 0; tile.outpost_level = 1; tile.outpost_type = "civilian"
	tile.public_storage = {"food": 500.0}   # 糧在糧倉
	state.world.tiles[2*1000+2] = tile
	state.teams[0] = t
	var rs := ResourceSystem.new()
	rs.resolve_consumption(state, [0], WorldState.TICKS_PER_DAY)
	# 消耗應從糧倉扣(10人×2.4=24)，非餓死
	assert(float(tile.public_storage["food"]) < 500.0, "應從糧倉提領消耗，實際糧倉=%.1f" % tile.public_storage["food"])
	assert(t.famine_days == 0.0, "有糧倉糧不該記飢荒，實際 famine_days=%.1f" % t.famine_days)
	print("consume from granary OK (糧倉剩=%.1f)" % tile.public_storage["food"])
```

- [ ] **Step 2: --import + 跑驗證失敗**（現只讀 team.resources=0 → 飢荒）

- [ ] **Step 3: 實作** `resolve_consumption`：
  - `food_available` 改 = `team.resources["food"] + 自家糧倉 food`（team 在自家 outpost tile 時）。
  - 消耗扣除：先扣 team.resources，不足再扣糧倉（守恆 sink）。mount/horse 草料同理（或維持只扣 team，依現行 — 草料量小，實作者定，標 TEST VALUE）。
  - 飢荒判定（famine_days/satisfaction）用合併池 available，邏輯不變。
  > 守恆：消耗是 sink，從哪扣都不破不變量。

- [ ] **Step 4: --import + 跑驗證通過**（`consume from granary OK`；**關鍵**：既有飢荒/絕境測試仍綠——定居隊不因 food 進糧倉而誤餓）

- [ ] **Step 5: Commit** `feat(economy): 消耗從 team+糧倉合併池提領(無飢荒回歸)`

---

### Task 3: food order-eligible + 糧倉滿 → sell 決策 fire（鐵則）

**Files:** Modify `order_system.gd`；Test `headless_test.gd`。

**病**：food 不在 `_ORDER_ELIGIBLE_RES` → 從不發 food sell 單。糧倉滿了也無「該賣」決策（違鐵則：cap 須改變決策）。

**修**：food 加入 eligible；`tick_team_orders` 餘量 sell 判定：定居隊讀**糧倉 food**（非 team.resources），糧倉 > sell 門檻（如 cap×ratio 或 > N 天需求）→ 發 food sell 單。

- [ ] **Step 1: 寫失敗測試** `_test_food_surplus_sell()`（註冊）
```gdscript
func _test_food_surplus_sell() -> void:
	print("--- WS-1 糧倉滿→賣決策 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var t := TeamData.new(); t.team_id = 0; t.tile_pos = Vector2i(2,2)
	_seed_pop(t, 5)
	var tile := HexTileData.new(); tile.tile_pos = Vector2i(2,2)
	tile.outpost_owner = 0; tile.outpost_level = 1; tile.outpost_type = "civilian"
	tile.public_storage = {"food": 1800.0}   # 近 cap(2000) 巨量糧
	state.world.tiles[2*1000+2] = tile
	state.teams[0] = t
	var os := OrderSystem.new()
	os.tick_team_orders(state, t)
	# 糧倉滿 → 應發 food sell 單
	var has_food_sell := false
	for o in t.active_orders:
		if o["kind"] == "sell" and o["res"] == "food": has_food_sell = true
	assert(has_food_sell, "糧倉滿應發 food sell 單(滿了→賣決策)")
	print("food surplus sell OK")
```

- [ ] **Step 2: --import + 跑驗證失敗**（food 非 eligible → 無 food sell）

- [ ] **Step 3: 實作** `order_system.gd`：
  - `_ORDER_ELIGIBLE_RES` 加 `"food"`。
  - `tick_team_orders` 餘量 sell 段：對 food，定居隊（自家 outpost）讀**糧倉 food**；> sell 門檻（`FOOD_SELL_THRESHOLD` TEST VALUE，如 cap×0.7 或 > pop×2.4×N天）→ post_order sell。非 food res 維持讀 team.resources。
  > 注意：賣量/門檻 TEST VALUE。賣 food 給絕境買家 = 缺→買 對側（買家飢荒已可發買單；food 加 eligible 後買單也成立）。實際成交走 WS-2 市集（本 Task 只證 sell 決策 fire，不需 WS-2 完成交易）。

- [ ] **Step 4: --import + 跑驗證通過**（`food surplus sell OK`、`=== DONE ===`、coin_eq=0、InvariantAudit 0）

- [ ] **Step 5: Commit** `feat(economy): food order-eligible + 糧倉滿發 sell 單(滿了→賣決策 fire)`

---

### Task 4: 回歸 + world_sim 煙霧（囤糧崩）+ 回報

**Files:** 無 code 改（跑 + 回報）。

- [ ] **Step 1: headless 回歸**：`=== DONE ===`、三新測 OK、**既有飢荒/絕境測試全綠**（無飢荒回歸）、coin_eq=0、InvariantAudit 0。

- [ ] **Step 2: world_sim 煙霧（非閘）**：跑通無 SCRIPT ERROR；**囤糧峰值對照前次**（4-5萬 → 受 cap 封頂，期望大降）；**世界沒過餓**（存活隊數無暴跌 vs 前次——food 進糧倉不該餓死定居隊）；food sell 單出現。

- [ ] **Step 3: 回報 handback** `2026-06-20-implementer-to-systems-economy-ws1.md`（`from: implementer / to: systems / status: open`）：三測結果、world_sim 囤糧峰值對照 + 存活隊對照（有無過餓）、food sell 單是否 fire、一般稅行為是否變（Task1 坑）、異常。

- [ ] **Step 4: Commit handback** `docs(economy): WS-1 食物糧倉 回報(囤糧崩?)`

---

## Self-Review 註記

- **守恆安全**：food=sink 無不變量；route(tile→糧倉 capped,over-cap drop)/消耗(池→吃) 皆 sink。不碰 coin/守恆 res。coin_eq 形式確認。
- **無飢荒回歸 = 最大風險**：Task2 合併池消耗 + Task4 既有飢荒測試全綠 + world_sim 存活隊對照守住。food 移糧倉**不可**誤餓定居隊。
- **鐵則達標**：Task3 = cap 改變 NPC 決策（糧倉滿→發 food sell 單）。否則 cap 是死概念。實際成交靠 WS-2 市集（本 WS 證 sell 決策 fire，獨立可測）。
- **一般稅坑**（Task1 Step3）：food 原走 else 入 `gained` 課一般稅入村庫；改進糧倉 = 等義「自己存自己村庫」→ 不重複課，但實作者須確認既有稅測試不破（定居隊 food 稅行為）。
- **食物 cap = staple 放大**（civilian L1=2000 ≈ 5人×2.4×166天；非通用 1500 那種會餓死）。全 TEST VALUE，平衡調。WS-4 糧倉設施再拉高 cap（容量=據點戰略）。
- **與 WS-2 並行**：同檔 order_system 不同函式（WS-1 改 tick_team_orders/_ORDER_ELIGIBLE_RES；WS-2 改 post_order/dispatch）→ merge 序先進先，後者 rebase 跑回歸驗。
- **後續**：food 買單側（飢荒隊買 food，shortage_buy 加 food）= 若 Task3 sell 側通且有需求，買側可同步或後補；WS-4 糧倉設施拉 cap。
