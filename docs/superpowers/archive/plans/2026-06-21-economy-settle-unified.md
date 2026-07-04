# 經濟生產隊納統一引擎（履約脫 0）Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 把經濟「生產/定居」隊接上既有 `DecisionEngine`（商隊已接），讓生產隊原地駐守掛單賣貨、商隊來找它 co-located → 訂單履約脫 0。

**Architecture:** 不新增決策層。沿用 sub-project 1 的 `DecisionEngine` / `DecisionOptions` / `DecisionTerms` / `DecisionContext`。三步：(1) 角色守衛正確化（`applicable()` 用 `is_merchant` 區分 roam-trade vs 原地賣 + 建設 bootstrap）；(2) `uses_unified` 加 `TAG_PRODUCE`；(3) world_sim 驗履約脫 0。下單（`OrderSystem.tick_team_orders` 自動 cadence）不動。

**Tech Stack:** Godot 4.2.2 GDScript。測試 = `scripts/debug/headless_test.gd`（行為 assert）+ `scripts/debug/world_sim.gd`（長跑量測，`Probe.summary()` 印履約 count）。

## Global Constraints

- 用 wrapper 跑 Godot（強制 UTF-8）：`.\tools\godot.ps1 --headless --script <path>`。直呼 exe → CP950 中文亂碼。
- 不碰守恆：本塊只改決策面（task 選擇 + applicable 守衛），不碰 resources/coin/state 池 → coin_eq/InvariantAudit 無關但仍須回歸驗 0。
- bar #2「加行為=加 row」：本塊**不加新 option**，只調 `applicable` 守衛 + context 欄位。
- 全數值 TEST VALUE。
- **修正 spec 之點**：spec §改動2 原寫「貿易守衛 = `not has_own_outpost`」。測試中商隊 `_mk_merchant_team` **有 outpost**（`outpost_owner=0`）→ 該守衛會誤殺商隊貿易、爆 TC1/TC7。正確判別子 = **角色 tag（`is_merchant`）非據點**。本 plan 採 `is_merchant`。

---

### Task 1: 角色守衛正確化（`is_merchant` context + `applicable()` 貿易/建設）

讓生產隊（非商隊）不被列入 roam-trade 候選（原地賣），無據點隊有建設 bootstrap 候選。商隊行為不變。

**Files:**
- Modify: `scripts/simulation/decision/decision_context.gd`（加 `is_merchant` 欄位 + gather）
- Modify: `scripts/simulation/decision/options.gd:14-24`（`applicable()` 貿易/生產/駐守/建設 守衛）
- Test: `scripts/debug/headless_test.gd`（加 `_mk_produce_team` helper + `_test_role_applicable`，註冊進 dispatch）

**Interfaces:**
- Consumes: `DecisionContext`（既有欄位 `has_goods`/`has_arb`/`has_own_outpost`）、`DecisionOptions.applicable(ctx)->Array`、`TeamData.TAG_MERCHANT`/`TAG_PRODUCE`、測試既有 `_mk_merchant_team`/`_seed_pop`。
- Produces: `DecisionContext.is_merchant: bool`（後續 task / 域遷入可讀）；`applicable()` 新候選矩陣：商隊→貿易；有據點生產隊→生產/駐守/建設；無據點隊→建設。

- [ ] **Step 1: 寫失敗測試**

在 `scripts/debug/headless_test.gd` 加 helper（放在 `_mk_merchant_team` 函式後面，約 line 12534 之後）：

```gdscript
# ── 共用：建一支生產隊（TAG_PRODUCE + 可選自家 outpost）──
func _mk_produce_team(state: WorldState, leader_vals: Dictionary, food: float, with_outpost: bool) -> TeamData:
	var t := TeamData.new(); t.team_id = 0; t.tags = [TeamData.TAG_PRODUCE]; t.tile_pos = Vector2i(2,2); t.leader_id = 100
	_seed_pop(t, 5); t.resources = {"food": 100.0}
	if with_outpost:
		var tile := HexTileData.new(); tile.tile_pos = Vector2i(2,2); tile.outpost_owner = 0
		tile.outpost_level = 1; tile.outpost_type = "civilian"; tile.public_storage = {"food": food}
		state.world.tiles[2*1000+2] = tile
	var ldr := PersonData.new(); ldr.id = 100
	for k in leader_vals: ldr.values[k] = leader_vals[k]
	state.persons[100] = ldr; state.teams[0] = t
	return t
```

再加測試函式（放在 `_test_tc7_divergence` 後，約 line 12609 之後）：

```gdscript
func _test_role_applicable() -> void:
	print("--- sub-A Task1: 角色守衛 (貿易=商隊/建設=bootstrap) ---")
	# 商隊(有貨+據點) → is_merchant，貿易 候選（行為不變）
	var s1 := WorldState.new(); s1.world = WorldData.new()
	var m := _mk_merchant_team(s1, {"貪婪": 0.7}, true, 500.0)
	var ctx_m: DecisionContext = DecisionContext.gather(s1, m)
	assert(ctx_m.is_merchant, "商隊 is_merchant 應 true")
	assert("貿易" in DecisionOptions.applicable(ctx_m), "商隊有貨/arb → 貿易候選")
	# 生產隊(有貨+據點,非商隊) → 無貿易；有 生產/駐守/建設
	var s2 := WorldState.new(); s2.world = WorldData.new()
	var p := _mk_produce_team(s2, {"義氣": 0.6}, 500.0, true)
	p.resources["goods"] = 50.0
	var ctx_p: DecisionContext = DecisionContext.gather(s2, p)
	assert(not ctx_p.is_merchant, "生產隊 is_merchant 應 false")
	var ap: Array = DecisionOptions.applicable(ctx_p)
	assert("貿易" not in ap, "生產隊不 roam-trade(無貿易候選)，實際=%s" % str(ap))
	assert("駐守" in ap and "生產" in ap and "建設" in ap, "生產隊有 生產/駐守/建設 候選，實際=%s" % str(ap))
	# 生產隊無據點 → 建設(bootstrap) 候選；生產/駐守 不候選
	var s3 := WorldState.new(); s3.world = WorldData.new()
	var p2 := _mk_produce_team(s3, {"義氣": 0.6}, 500.0, false)
	var ctx_p2: DecisionContext = DecisionContext.gather(s3, p2)
	assert(not ctx_p2.has_own_outpost, "p2 應無據點")
	var ap2: Array = DecisionOptions.applicable(ctx_p2)
	assert("建設" in ap2, "無據點生產隊 → 建設 bootstrap 候選，實際=%s" % str(ap2))
	assert("生產" not in ap2 and "駐守" not in ap2, "無據點 → 無 生產/駐守，實際=%s" % str(ap2))
	print("role applicable OK")
```

註冊進 dispatch：在 `scripts/debug/headless_test.gd:3829`（`_test_tc7_divergence()` 那行後）加一行：

```gdscript
	_test_tc7_divergence()
	_test_role_applicable()
```

- [ ] **Step 2: 跑測試確認失敗**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: FAIL — `ctx_m.is_merchant` 是無此 property 報錯（`Invalid get index 'is_merchant'`），或 `生產隊不 roam-trade` assert 失敗（現守衛 `has_goods or has_arb` 對生產隊也給貿易）。

- [ ] **Step 3: 加 `is_merchant` 欄位 + gather**

`scripts/simulation/decision/decision_context.gd`：欄位區（`var has_own_outpost: bool = false` 那行後，約 line 16）加：

```gdscript
var is_merchant: bool = false
```

`gather()` 內（`c.has_own_outpost = ...` 那行後，約 line 33）加：

```gdscript
	c.is_merchant = team.tags.has(TeamData.TAG_MERCHANT)
```

- [ ] **Step 4: 改 `applicable()` 守衛**

`scripts/simulation/decision/options.gd:14-24`，整個 `applicable()` 換成：

```gdscript
static func applicable(ctx: DecisionContext) -> Array:
	var out: Array = []
	for opt in REGISTRY:
		match opt:
			"貿易":
				# roam-trade = 商隊角色（棄不棄據點巡市集）。生產隊原地掛單賣，不列候選。
				if (ctx.has_goods or ctx.has_arb) and ctx.is_merchant: out.append(opt)
			"生產", "駐守":
				if ctx.has_own_outpost: out.append(opt)
			"建設":
				out.append(opt)   # bootstrap(無據點建新) + 升級(有據點) 皆候選 → 無據點生產隊不被困
			"覓食", "survival":
				out.append(opt)   # 恆候選（survival 靠權重，非守衛）
	return out
```

- [ ] **Step 5: 跑測試確認通過（含 TC1/4/6/7 回歸不破）**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: PASS — `role applicable OK` 出現；且 `TC1 no-oscillation OK` / `TC4 ambition-drive OK` / `TC6 multi-drive OK` / `TC7 divergence OK` 全在（商隊 `is_merchant=true` → 貿易仍候選，行為不變），`=== DONE ===` 無 assert 失敗。

- [ ] **Step 6: Commit**

```bash
git add scripts/simulation/decision/decision_context.gd scripts/simulation/decision/options.gd scripts/debug/headless_test.gd
git commit -m "feat(decision): 角色守衛 is_merchant — 生產隊原地賣不roam + 建設bootstrap"
```

---

### Task 2: `uses_unified` 加 `TAG_PRODUCE`

把生產隊兩條決策路徑（member + solo）都接到引擎，舊生產者對生產隊全 skip（單一 owner）。

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd:847-848`（`uses_unified`）
- Test: `scripts/debug/headless_test.gd:12511`（擴 `_test_unified_seam`）

**Interfaces:**
- Consumes: `TeamData.TAG_PRODUCE`、`FactionAISystem.uses_unified(team)->bool`、既有 `_mk_team_tag`。
- Produces: 生產隊納切片（`uses_unified` 對生產 tag 回 true）→ `_assign_member_tasks`(line ~793) 與 `_evaluate_solo`(line ~1006) 兩 gate 同時把生產隊導向 `_decide_unified`。

- [ ] **Step 1: 寫失敗測試**

`scripts/debug/headless_test.gd:12511` 的 `_test_unified_seam` 改成：

```gdscript
func _test_unified_seam() -> void:
	print("--- 決策引擎 Task5: 切片 seam ---")
	var fai := FactionAISystem.new()
	assert(fai.uses_unified(_mk_team_tag(TeamData.TAG_MERCHANT)), "商隊-tag → 切片(走新引擎)")
	assert(fai.uses_unified(_mk_team_tag(TeamData.TAG_PRODUCE)), "生產-tag → 切片(走新引擎)")
	assert(not fai.uses_unified(_mk_team_tag(TeamData.TAG_MILITARY)), "軍隊 → 非切片(舊系統)")
	print("unified seam OK")
```

- [ ] **Step 2: 跑測試確認失敗**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: FAIL — `生產-tag → 切片` assert 失敗（現 `uses_unified` 只認 `TAG_MERCHANT`）。

- [ ] **Step 3: 改 `uses_unified`**

`scripts/simulation/faction_ai_system.gd:847-848`：

```gdscript
func uses_unified(team: TeamData) -> bool:
	return team.tags.has(TeamData.TAG_MERCHANT) or team.tags.has(TeamData.TAG_PRODUCE)
```

- [ ] **Step 4: 跑測試確認通過**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: PASS — `unified seam OK` + `=== DONE ===` 無 assert 失敗。生產隊行為相關既有測試（line 4588/5273/… 多處 `TAG_PRODUCE` 測試）若有走 `_assign_member_tasks`/`_evaluate_solo` 派工斷言，需確認仍綠；若某測試斷言「生產隊舊流程派 X task」而現在走引擎，記錄為預期變更（最小切片空窗）並回報 systems，勿硬改測試掩蓋。

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(decision): uses_unified 加 TAG_PRODUCE — 生產隊納統一引擎(單一owner)"
```

---

### Task 3: S6 world_sim 驗履約脫 0 + 全回歸

確認生產隊原地駐守 + 商隊來找 → 訂單履約 count > 0（脫 0 = 過）。跑 world_sim 看 `Probe.summary()`。

**Files:**
- Verify only（不改 production code，除非診斷出缺口）：`scripts/debug/world_sim.gd`、`config/world_sim.json`、`scripts/debug/probe_stats.gd`
- 若 config 無 produce↔merchant 可履約對 → Modify: `config/world_sim.json`（補一組 co-locatable 生產隊 + 商隊；最小調整）

**Interfaces:**
- Consumes: `Probe.summary()` 印 `[ProbeSummary] g1.order_fulfilled = N` 與 `訂單履約率 = …`（`probe_stats.gd:42-47`）；履約計數來源 `OrderSystem` line 259 `Probe.bump("g1.order_fulfilled")`、成交 print `interaction_system.gd:574` `[Market] Team%d <-> Team%d 成交`。
- Produces: S6 收斂證據（履約 count > 0）。

- [ ] **Step 1: 跑 world_sim 取基準**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/world_sim.gd`
觀察結尾 `========== [ProbeSummary] ==========` 區塊的 `g1.order_fulfilled = N`。
Expected（修前若回退基準）：N == 0（或極低）。記下 N、`g1.order_placed`、`g1.merchant_survival`、`[Market] … 成交` 出現次數。

> 長跑慢可先暫降 `config/world_sim.json` 的 `max_ticks`（如 21600 = 1/8 年）快迭代；最終驗收用原值跑一輪。

- [ ] **Step 2: 判定脫 0**

- 若 `g1.order_fulfilled > 0` 且 `[Market] … 成交` 出現 → S6 脫 0 達成，跳 Step 4。
- 若仍 0 → Step 3 診斷（measure-first，勿憑猜改）。

- [ ] **Step 3: 診斷仍 0 的因（僅當 Step 2 失敗）**

依序查（用 `scripts/debug/team_trace.gd` / `spine_trace.gd` 月取樣輸出 + 加臨時 print）：
1. 生產隊是否真原地駐守？trace 一支 `TAG_PRODUCE` 隊的 `current_task`/`current_option`/`tile_pos` 連續數十 tick — 應穩定在 生產/駐守/建設、tile_pos 不漂。若漂 → 回查 `to_task` target（應 = `team.tile_pos`）或 movement 是否被他系統覆寫。
2. 生產隊是否有自家 outpost 可掛單？`_register_on_board` 要 `tile.outpost_owner == team_id` 且隊在該 tile。無據點隊應走 建設 取得 → 若卡無據點，查建設 `to_task`(TASK_BUILD) 是否真造出 outpost。
3. 商隊是否抵達生產隊 tile co-located？查 `g1.merchant_survival` 是否仍高（商隊卡 survival 永不出門 = 既知壓制因，handback #6 §2）。若商隊卡 survival → 屬商隊切片參數，記錄回報 systems，非本塊強修。
4. 把根因 + 證據寫進 handback 回報 systems；若是本塊 config 缺可履約對 → Step 3b。

- [ ] **Step 3b: （僅當診斷為 config 缺對）補 world_sim config**

`config/world_sim.json` 補一組初始 co-locatable 對：一支 `TAG_PRODUCE` 隊（自家 outpost + 有可賣 goods/food 盈餘）+ 一支 `TAG_MERCHANT` 隊（鄰近、有 coin）。最小調整，勿重寫 config。改完回 Step 1 重跑。

- [ ] **Step 4: 全回歸閘**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: 全綠 `=== DONE ===`，無 assert 失敗；TC1/4/6/7 + role applicable + unified seam 全 OK；coin_eq / InvariantAudit 相關斷言（headless 內既有）為 0。

- [ ] **Step 5: Commit（含 config 若有改）**

```bash
git add config/world_sim.json scripts/debug/headless_test.gd
git commit -m "test(decision): S6 world_sim 履約脫0 驗收 + 回歸閘"
```
（若 Step 3b 未觸發無 config 改，僅 commit 量測結果記錄或跳過此 commit。）

---

## 完成後

- 子 session 回報 handback 給 systems：履約 count 前/後、TC 全過、world_sim 煙霧結果、最小切片空窗（consolidate/faction-duty 掉）實測影響（碎隊數變化）、任何診斷出但屬商隊切片/他域的因（如 `g1.merchant_survival`）。
- systems 收 handback 後更新 `docs/progress.md` + `[[project_economy_arc]]` / `[[project_unified_decision_framework]]` memory，判 sub-project B 序。

## Self-Review

- **Spec coverage**：§改動1(uses_unified+PRODUCE)=Task2；§改動2(applicable 角色)=Task1；§改動3(context 欄位)=Task1 `is_merchant`；§改動4(下單不改僅驗)=Task3 Step1/3 確認 board 掛單；驗收 S6/TC/coin_eq/InvariantAudit=Task3。spec §開放細節(建設守衛形/can_build/config/撲空旗) → 建設守衛 Task1 採「恆候選」定形；can_build 初版不需（YAGNI，無據點靠 TASK_BUILD 造）；config + 撲空診斷 = Task3 Step3。全覆蓋。
- **Placeholder scan**：無 TBD；所有 code step 附完整碼；Step3 診斷是條件分支非 placeholder（給具體查序）。
- **Type consistency**：`is_merchant: bool`（context 定義 / Task1 測試讀 / gather 寫）一致；`applicable()->Array`、`uses_unified()->bool` 與既有簽名一致；`_mk_produce_team` 簽名 Task1 定義、Task1 內用，一致。
