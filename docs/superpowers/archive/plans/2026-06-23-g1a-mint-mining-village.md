# G1a 礦村（山村特化）Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 讓金/銀礦在山地真被開採→鑄幣→出 coin，靠「礦村」（蓋在含礦山、不自給、外部供糧的 civilian outpost）。

**Architecture:** 最大複用既有機制（自格採 ore / mint facility + `_pick_facility` / food 買單 / 糧倉 / subteam 建造）。新增 4 塊：S1 world-gen 礦脈保證、S2 含礦山條件解禁建址（utility 加權，非硬腳本）、S3 外部供糧（bootstrap 起始糧 + market food buy）、S4 開採派工（走既有 build-new-outpost）。鑄幣死鎖一旦解（隊能住含礦山→自動採→vault ore>10→`_pick_facility` 自建 mint），mint 既有 code 自動 fire。

**Tech Stack:** Godot 4.2.2 GDScript。測試 = `scripts/debug/headless_test.gd`（單檔，跑 `=== DONE ===` 無 `SCRIPT ERROR`）。

## Global Constraints

- **UTF-8 wrapper**：所有 Godot 呼叫走 `.\tools\godot.ps1`（PowerShell），避免 CP950 中文亂碼。
- **新 class_name 後跑** `.\tools\godot.ps1 --headless --import`（重建 class 快取）。本 plan 不預期新 class_name，但若加則必跑。
- **守恆鐵則**：coin 只經 mint 創造（既有 CoinAudit 認 mint 合法源）。任何改動後 `coin_eq delta=0` + `InvariantAudit 0`。本 plan 不碰守恆面（只改世界生成 + 決策/建址 + 派工）。
- **TEST VALUE**：所有新常數標 `# TEST VALUE` 註解，正式平衡期調。
- **山地解禁僅限含礦山 + 僅富裕擴張路徑**：survival/紮營 picker `_find_unowned_farmable_tile`（`faction_ai_system.gd:2173`）的山地 ban **不得動**（餓荒隊不上山）。
- baseline 確認：開工前跑 `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`，確認既有全綠再動。

---

### Task 1: world-gen 礦脈保證（小圖修，S1）

**Files:**
- Modify: `scripts/simulation/world_generator.gd`（`generate()` 結尾，`_apply_resources` 之後）
- Test: `scripts/debug/headless_test.gd`（新測函數 + 註冊）

**Interfaces:**
- Consumes: `state.world.tiles`（Dictionary tile_id→HexTileData）、`HexTileData.terrain` / `.resources` / `.resource_cap`、`ORE_GOLD_MIN/MAX` 既有常數、`config.resource_multiplier`。
- Produces: 生成後保證 `count(tiles with resources.ore_gold>0) >= 1`（若全圖有山地）。

- [ ] **Step 1: 讀現有 world_generator.gd 結構**

讀 `generate()`（~L33-52）+ `_apply_resources()`（~L54-112）+ ore 常數（L15-31）。確認 ore_gold 注入點（mountain 分支 L62-70）+ `resource_cap` 設法（L80）。

- [ ] **Step 2: 寫 failing test**

在 `headless_test.gd` 加（找既有 world-gen 測區塊附近插入，仿既有測風格）：

```gdscript
func _test_g1a_ore_guarantee() -> void:
	# 小圖多次生成，每次至少 1 金礦 tile（消 RNG 槓龜）
	for seed_i in range(20):
		var state := WorldState.new()
		var cfg := {"map": {"radius": 4, "resource_richness": 5}, "teams": []}
		GameSetup.setup(state, cfg)
		var gold := 0
		var has_mountain := false
		for tid in state.world.tiles:
			var t = state.world.tiles[tid]
			if t.terrain == "mountain": has_mountain = true
			if float(t.resources.get("ore_gold", 0)) > 0.0: gold += 1
		if has_mountain:
			assert(gold >= 1, "[g1a] 小圖無金礦 tile (seed_i=%d)" % seed_i)
	print("[g1a] ore guarantee OK")
```

註冊到 test runner（仿既有 `_test_*` 註冊處）。

- [ ] **Step 3: 跑測確認 FAIL**

```
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
```
Expected: `[g1a] 小圖無金礦` assert 觸發（RNG 某 seed_i 槓龜）。若 20 次剛好都中（運氣），改 radius 3 或加迴圈次數逼出。

- [ ] **Step 4: 實作礦脈保證**

在 `generate()` 全 tile `_apply_resources` 迴圈**之後**加 guard：

```gdscript
	# S1 礦脈保證：全圖無金礦 tile 時，挑一座山地注入（消小圖 RNG 槓龜，保 mint 魂有燃料）
	_ensure_min_ore(rng, "ore_gold", ORE_GOLD_MIN, ORE_GOLD_MAX, mult)
```

加 helper：

```gdscript
func _ensure_min_ore(rng: RandomNumberGenerator, res: String, lo: int, hi: int, mult: float) -> void:
	var mountains: Array = []
	for tid in tiles_ref:   # tiles_ref = generate() 內 state.world.tiles，依現有變數名調整
		var t = tiles_ref[tid]
		if t.terrain == "mountain": mountains.append(t)
		if float(t.resources.get(res, 0)) > 0.0: return   # 已有，不動
	if mountains.is_empty(): return   # 無山地（極端小圖）→ 無解，跳過
	var pick = mountains[rng.randi() % mountains.size()]
	var amt: float = float(rng.randi_range(lo, hi)) * mult
	pick.resources[res] = amt
	pick.resource_cap[res] = amt
```

> 注意：`generate()` 內 tile 容器的實際變數名（state.world.tiles 或 local）依現有 code 調整；`mult` 取自 `config.get("resource_multiplier", 1.0)`。helper 簽名對齊。

- [ ] **Step 5: 跑測確認 PASS + 既有全綠**

```
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
```
Expected: `[g1a] ore guarantee OK` + `=== DONE ===` 無 `SCRIPT ERROR`。既有 world-gen 測不破（大圖本有金礦→guard 早 return 零影響）。

- [ ] **Step 6: Commit**

```
git add scripts/simulation/world_generator.gd scripts/debug/headless_test.gd
git commit -m "feat(world_gen): 礦脈保證 guard — 小圖至少 1 金礦 tile (G1a S1)"
```

---

### Task 2: 含礦山地條件解禁建址（S2）

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`（`_evaluate_new_outpost_location` ~L1752、`_site_resource_bonus` ~L1789、`SITE_RES_BONUS`/`TERRAIN_BUILD_BONUS` 常數區 ~L1740）
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- Consumes: `_evaluate_new_outpost_location(state, leader_team)` 回 `{pos, score, tile}`；`leader_team` 的 leader `PersonData.values["貪婪"]`；`HexTileData.terrain`/`.resources`；`TERRAIN_BUILD_BONUS`（mountain=-10）；`SITE_RES_BONUS`（ore_gold/silver=35）。
- Produces: 含礦山地（mountain + 本格/鄰格 ore_gold|silver>0）成合法候選；貪婪 leader 對含礦山 ore bonus 加權放大；普通 leader 仍不選山。礦村候選回傳時 `tile.terrain=="mountain"`。

- [ ] **Step 1: 讀建址 code**

讀 `_evaluate_new_outpost_location`（L1752-1787）完整評分鏈 + `_site_resource_bonus`（L1789-1798）。確認現候選排除山地的真因 = `productivity×100`（山地低）+ `TERRAIN_BUILD_BONUS -10`，**非硬 ban**（無 `terrain=="mountain": continue`）→ 只需加權讓含礦山勝出。

- [ ] **Step 2: 寫 failing test**

```gdscript
func _test_g1a_mining_site() -> void:
	# 貪婪 leader 旁有含金礦山 → 選址回該山地（礦村）
	var state := WorldState.new()
	var cfg := {"map": {"radius": 4, "resource_richness": 5}, "teams": []}
	GameSetup.setup(state, cfg)
	# 造一座金礦山在已知位置 + 貪婪 leader 隊在 dist 2-5
	var fa := FactionAISystem.new()
	var leader_team := _mk_team_with_greedy_leader(state, Vector2i(0, 0))   # helper：建貪婪 leader 隊
	var gold_mt := _force_gold_mountain(state, Vector2i(3, 0))               # helper：強設含金礦山
	var best: Dictionary = fa._evaluate_new_outpost_location(state, leader_team)
	assert(not best.is_empty(), "[g1a] 貪婪 leader 無選址")
	assert(best.tile.terrain == "mountain", "[g1a] 貪婪 leader 未選含礦山, 選了 %s" % best.tile.terrain)
	# 對照：普通(低貪婪) leader 不選山
	var meek_team := _mk_team_with_meek_leader(state, Vector2i(0, 0))
	var best2: Dictionary = fa._evaluate_new_outpost_location(state, meek_team)
	if not best2.is_empty():
		assert(best2.tile.terrain != "mountain", "[g1a] 普通 leader 竟選含礦山(破稀有)")
	print("[g1a] mining site OK")
```

> helper（`_mk_team_with_greedy_leader` 等）：仿 headless_test 既有造隊 helper。貪婪 leader = `values["貪婪"]=0.9`；普通 = `0.2`。`_force_gold_mountain`：設 tile.terrain="mountain"、resources["ore_gold"]=50、清掉其他高分平原干擾（或確保該山 dist 2-5 且分數可勝出）。

- [ ] **Step 3: 跑測確認 FAIL**

Expected: `未選含礦山`（現行山地 -10 + 低 productivity 輸給平原）。

- [ ] **Step 4: 實作貪婪加權 ore bonus**

改 `_site_resource_bonus` 簽名加 leader 貪婪，或在 `_evaluate_new_outpost_location` 評分處對含礦山加權。建議後者（不破其他 caller）：

在 `_evaluate_new_outpost_location` 評分迴圈，`score += _site_resource_bonus(...)` 之後加：

```gdscript
		# S2 礦村：含礦山地對貪婪/野心 leader 加權 ore bonus（壓過山地懲罰=蓄意富裕擴張；普通 leader 不選=稀有擬真）
		if tile.terrain == "mountain":
			var ore_here: float = _site_resource_bonus_ore_only(state, tile.tile_pos)  # 只計 ore_gold/silver
			if ore_here > 0.0:
				var ldr = state.persons.get(leader_team.leader_id)
				var greed: float = float(ldr.values.get("貪婪", 0.5)) if ldr != null else 0.5
				var ambition: float = float(ldr.values.get("野心", 0.5)) if ldr != null else 0.5
				score += ore_here * (greed + ambition) * MINING_GREED_WEIGHT   # TEST VALUE
```

加常數（`TERRAIN_BUILD_BONUS` 附近）：

```gdscript
const MINING_GREED_WEIGHT: float = 1.5   # TEST VALUE — 礦村建址貪婪加權；過頻調低/魂不 fire 調高
```

加 helper（只計 ore，避免 herb/horse 干擾礦村判定）：

```gdscript
func _site_resource_bonus_ore_only(state: WorldState, pos: Vector2i) -> float:
	var bonus: float = 0.0
	for d in ([Vector2i.ZERO] as Array) + PathSystem.HEX_DIRS:
		var npos: Vector2i = pos + d
		var ntile: HexTileData = state.world.tiles.get(npos.x * 1000 + npos.y)
		if ntile == null: continue
		for res in ["ore_gold", "ore_silver"]:
			if float(ntile.resources.get(res, 0)) > 0:
				bonus += float(SITE_RES_BONUS.get(res, 0))
	return bonus
```

> tile_id 換算 `npos.x*1000+npos.y` 對齊 `_site_resource_bonus` 既有寫法（確認一致；若既有用別法照抄）。

- [ ] **Step 5: 跑測確認 PASS + 既有全綠**

Expected: `[g1a] mining site OK` + `=== DONE ===`。既有建址/拓殖測不破（普通 leader 行為不變、平原仍優先；只多了貪婪 leader 含礦山選項）。

- [ ] **Step 6: Commit**

```
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(faction_ai): 含礦山地建址解禁 — 貪婪 leader 加權選礦村 (G1a S2)"
```

---

### Task 3: 礦村採礦 + 建 mint 端到端驗證（確認既有機制，S4 + mint）

**Files:**
- Modify（多半零改，驗證為主）: `scripts/simulation/resource_system.gd`（自格採 ore）、`scripts/simulation/outpost_system.gd`（mint 在礦村 civilian 可建）
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- Consumes: 隊駐含礦山 civilian outpost → `ResourceSystem._collect_from_tile` 自格採 ore_gold 進 `tile.public_storage`；`_pick_facility` mint deficit gate（vault ore>10）；`OutpostSystem._tick_mint` ore→coin。
- Produces: 端到端「隊駐含礦山→採 ore 進 vault→ore>10→建 mint→mint 出 coin」鏈通。

- [ ] **Step 1: 寫端到端 test**

```gdscript
func _test_g1a_mining_to_coin() -> void:
	var state := WorldState.new()
	var cfg := {"map": {"radius": 4, "resource_richness": 5}, "teams": []}
	GameSetup.setup(state, cfg)
	# 含金礦山 + civilian outpost L1 + PRODUCE 隊駐留 + 起始糧
	var pos := Vector2i(2, 0)
	var tile := _force_gold_mountain(state, pos)         # ore_gold=200
	tile.outpost_type = "civilian"; tile.outpost_level = 1
	var team := _mk_produce_team_on(state, pos)          # PRODUCE tag 隊駐 pos
	tile.outpost_owner = team.team_id
	team.resources["food"] = 500.0                        # bootstrap 糧（撐採礦期）
	var runner := SimRunner.new()
	var coin0: float = _team_coin_total(state)
	for i in range(3000):
		runner.advance_tick(state, Vector2i(-1, -1))
	var vault_ore: float = float(tile.public_storage.get("ore_gold", 0))
	assert(tile.mint_level > 0 or _team_coin_total(state) > coin0, \
		"[g1a] 礦村未鑄幣: mint_level=%d coin Δ=%.0f vault_ore=%.0f" % \
		[tile.mint_level, _team_coin_total(state) - coin0, vault_ore])
	print("[g1a] mining→coin OK mint_level=%d coinΔ=%.0f" % [tile.mint_level, _team_coin_total(state) - coin0])
```

> helper `_mk_produce_team_on` / `_team_coin_total`：仿既有。若 `_pick_facility` 不在 advance_tick 自然觸發（需 faction context），測可直接驗「採 ore 進 vault」+ 手動 call `_pick_facility` 驗 mint 被選，分兩段斷言。

- [ ] **Step 2: 跑測，觀察斷在哪段**

Expected FAIL 或診斷：可能 (a) ore 沒進 vault（採礦 gate）、(b) mint 沒被 `_pick_facility` 選（deficit/context）、(c) mint 沒轉 coin。逐段 print 定位。

- [ ] **Step 3: 按診斷補最小改**

- 若 (a) 自格採 ore 對礦村 OK → 無需改。若採 ore 需 outpost-level gate 擋住 → 確認 L1 civilian 採自格 ore（`_collect_from_tile` L1 multiplier 1.0 應採自格）。
- 若 (b) `_pick_facility` 需 faction context 或 deficit 卡 → 確認 mint deficit（vault ore>10）+ terrain_fit（含礦山本格 ore→`_nearby_resource>0`→×3）成立。可能需確保礦村隊有走 `_evaluate_infrastructure` facility 評分路徑（PRODUCE 隊駐 outpost 應走）。
- 若 (c) `_tick_mint` 需 PRODUCE 居民在 tile（`_has_resident_on_tile`）→ 測已駐 PRODUCE 隊，應 OK。
- **僅補必要最小改**，每改重跑。不擴範圍。

- [ ] **Step 4: 跑測確認 PASS + 既有全綠**

Expected: `[g1a] mining→coin OK` + `=== DONE ===`。

- [ ] **Step 5: Commit**

```
git add -A
git commit -m "test(g1a): 礦村採礦→鑄幣端到端驗 + 必要最小修 (G1a S4/mint)"
```

---

### Task 4: 礦村外部供糧驗證（S3）

**Files:**
- Modify（多半零改，驗證 + 可能微調觸發）: `scripts/simulation/order_system.gd` / 既有 food buy 路徑（merge `a4c4cf8`）
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- Consumes: 礦村 `effective_food` 低 → 既有缺糧發 food buy 單（`a4c4cf8`）；mint coin 付帳。
- Produces: 礦村 food 透過 buy 單回補，不因山地 0.5 再生餓死即廢。

- [ ] **Step 1: 寫 test**

```gdscript
func _test_g1a_mining_food_supply() -> void:
	var state := WorldState.new()
	var cfg := {"map": {"radius": 4, "resource_richness": 5}, "teams": []}
	GameSetup.setup(state, cfg)
	var pos := Vector2i(2, 0)
	var tile := _force_gold_mountain(state, pos)
	tile.outpost_type = "civilian"; tile.outpost_level = 1
	var team := _mk_produce_team_on(state, pos)
	tile.outpost_owner = team.team_id
	team.resources["food"] = 30.0   # 低糧 → 應觸發 food buy
	team.resources["coin"] = 200.0  # 有 coin 可買
	var os := OrderSystem.new()
	# tick orders cadence
	os.tick_team_orders(state, team)   # 簽名依現有調整
	var has_food_buy := false
	for oid in state.active_orders:    # 容器名依現有調整
		var o = state.active_orders[oid]
		if o.team_id == team.team_id and o.res == "food" and o.is_buy:   # 欄位名依現有
			has_food_buy = true
	assert(has_food_buy, "[g1a] 礦村低糧未發 food buy 單")
	print("[g1a] mining food supply OK")
```

> 欄位/簽名（`tick_team_orders`、`active_orders`、order `is_buy`/`res`/`team_id`）依現有 `order_system.gd` 調整對齊。

- [ ] **Step 2: 跑測**

Expected: 若既有 food buy（`a4c4cf8`）對缺糧隊通用 → 可能直接 PASS（礦村就是缺糧隊）。若 food buy 有 tag/角色 gate 擋礦村 → FAIL。

- [ ] **Step 3: 按結果處理**

- PASS：既有路徑覆蓋礦村，無需改。記錄「礦村供糧靠既有 food buy」。
- FAIL：確認 food buy 觸發條件，若被 gate 擋（如限商隊）→ 放寬讓含 outpost 的缺糧隊也發（最小改，對齊「角色=權重非 gate」原則）。

- [ ] **Step 4: 跑測確認 PASS + 既有全綠**

- [ ] **Step 5: Commit**

```
git add -A
git commit -m "test(g1a): 礦村外部供糧(food buy) 驗證 (G1a S3)"
```

---

### Task 5: 探針 + framework_validation S5 改真迴路 + world_sim 量測

**Files:**
- Modify: `scripts/debug/probe_stats.gd`（加 `g1.mine_founded`）、`scripts/simulation/faction_ai_system.gd`（礦村建成打點）、`scripts/debug/framework_validation.gd`（S5 mint 改真迴路）
- Test: world_sim 2yr 量測

**Interfaces:**
- Consumes: `Probe.bump("g1.mine_founded")`；`Probe.counts`。
- Produces: `g1.mine_founded` 探針；S5 證端到端礦村迴路；world_sim mint 魂活的量測數據。

- [ ] **Step 1: 加 `g1.mine_founded` 探針**

在 probe taxonomy（`probe_stats.gd`）註冊 `g1.mine_founded`。在 `faction_ai_system.gd` 礦村建成處（`_complete_construction` 礦村 civilian outpost on mountain 完成時，或建址 dispatch 時）加 1 行 `Probe.bump("g1.mine_founded")`。打點位置擇一致處。

- [ ] **Step 2: framework_validation S5 改真迴路**

現 `_scenario_S5_mint`（`framework_validation.gd:197`）強塞 `mint_level=1`+`ore_gold=100`。改為走真迴路：建含礦山 civilian outpost + PRODUCE 隊 + bootstrap 糧 → 跑 tick → 斷言 `g1.mint>0`（採→建廠→鑄 端到端）。保留舊強塞為註解備查或刪。

- [ ] **Step 3: 跑 framework_validation**

```
.\tools\godot.ps1 --headless --script scripts/debug/framework_validation.gd
```
Expected: S5 PASS（真迴路 mint 觸發）+ S1-4/S6 不破。

- [ ] **Step 4: world_sim 2yr 量測**

```
$env:GODOT_TIMEOUT="900"; .\tools\godot.ps1 --headless --script scripts/debug/world_sim.gd
```
觀察 Probe summary：`g1.mine_founded > 0`、`g1.mint > 0`、coin 總量增（非零和）、InvariantViolation 累計=0。記錄數值到 handback。

> world_sim unseeded（[[reference_multi_sanity_unseeded]]）→ 看機制 fire（mine_founded/mint>0）為準，絕對數變異正常。若 mint 仍 0：診斷礦村是否建成（mine_founded）、建成是否採礦、採礦是否建廠——逐層定位，調 `MINING_GREED_WEIGHT` 或 bootstrap 糧。

- [ ] **Step 5: 守恆閘**

```
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd
```
確認 `[CoinAudit] ... delta` ≈ 0（mint 守恆）+ headless_test 全綠。

- [ ] **Step 6: Commit**

```
git add -A
git commit -m "feat(probe): g1.mine_founded + framework_validation S5 改真礦村迴路 + world_sim 量測 (G1a)"
```

---

## 完成後（子 session）

1. push：`git push -u origin feat/g1a-mint-mining-village`
2. 寫 handback `docs/superpowers/handbacks/2026-06-23-g1a-mint-mining-village.md`：實作摘要（每檔一行）+ 與 spec 差異 + 連動風險（經濟 plumbing/守恆/建址）+ **world_sim 量測數據**（mine_founded/mint/coinΔ）+ 待主 session 確認（礦村 fire 率是否需 push 供糧 enrichment / pricing 雙重計值查證結果）。
3. finishing-a-development-branch 選單 → Option 3（Keep as-is），主 session 負責 merge。

## Self-Review 註記（主 session）

- spec S1-S4 全有對應 Task（S1→T1、S2→T2、S3→T4、S4/mint→T3、驗證/探針→T5）。
- pricing 雙重計值查證（spec 驗收）：併入 T3/T5 守恆閘 + handback 待確認項。
- 風險「供糧脆」：T4 驗證 + T5 world_sim 量 fire 率，不穩走 push 供糧 backlog（handback 呈報）。
- helper 簽名（`_force_gold_mountain`/`_mk_produce_team_on`/`_team_coin_total`/`_mk_team_with_greedy_leader`）= 子 session 仿既有 headless_test helper 實作，名稱跨 Task 一致。
