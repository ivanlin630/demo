# 經濟 WS-2c：food accessor 單源（破商隊 survival 二階死鎖）Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:test-driven-development + superpowers:executing-plans。Steps 用 checkbox 追蹤。

**Goal:** 破商隊 chronic survival 死鎖（WS-2b 揭：market_arrive=0/merchant_survival=18837）。真因 = **WS-1 回歸**——food 搬進糧倉後，`_evaluate_survival` 等 10+ 決策讀者仍讀 `team.resources["food"]`（定居隊=0）→ 誤判餓 → 永卡 survival/return_home → 永不貿易。修：`effective_food` accessor 單源（team food + 自家糧倉），決策讀者走它。

**Architecture:** WS-1 只改了**消耗**（resolve_consumption 讀合併池），漏改**決策讀者**。引入 `ResourceSystem.effective_food(state, team)` = `team.resources food + _own_granary_tile 糧倉 food`（複用既有 `_own_granary_tile`）。路由「問本隊有多少糧」的決策讀者過它（survival/trade/ambition gate）。純讀取改，**不碰守恆**（消耗扣除路徑 WS-1 已正確，本 WS 只修「AI 以為有多少糧」）。

**Tech Stack:** Godot 4.2.2 GDScript；`resource_system.gd`（accessor）+ `faction_ai_system.gd`/`ambition_ladder.gd`（決策讀者路由）；headless + world_sim 權威量測。

## Global Constraints

- wrapper 跑（UTF-8）：`.\tools\godot.ps1`。Windows PS 5.1 無 `&&`。
- 來源：WS-2b handback 探針（merchant_survival=18837/market_arrive=0）、本 session 診斷（`_evaluate_survival:2070` 讀 team food=0）。
- **守恆**：純決策讀取（AI 以為有多少糧），**不碰 resources/coin 扣除**（消耗 WS-1 已正確）。coin_eq/InvariantAudit 無關（驗 0 形式確認）。
- **無飢荒回歸**：accessor 讓 AI 看到糧倉糧 → 定居隊不再誤判餓 → survival 行為減少。但**真絕境隊**（team+糧倉皆空）仍須正確進 survival（既有飢荒測試守）。
- 回歸閘：headless 全綠、coin_eq=0、InvariantAudit 0。**權威量測 = world_sim**：`g1.market_arrive` 0→正、`g1.merchant_survival` 暴跌、`訂單履約率` 0%→正。
- 全 TEST VALUE 沿用。

## File Structure

- `scripts/simulation/resource_system.gd`（`effective_food` public accessor + `_own_granary_tile` 暴露）。
- `scripts/simulation/faction_ai_system.gd`（survival/trade/salary 決策讀者路由）。
- `scripts/simulation/ambition_ladder.gd`（ambition food gate 路由）。
- `scripts/debug/headless_test.gd`（accessor / survival 不誤判 / 真絕境仍 survival 測試）。

---

### Task 1: effective_food accessor + 破 survival 誤判（核心 unblock）

**Files:** Modify `resource_system.gd`、`faction_ai_system.gd`；Test `headless_test.gd`。

**病**：`_evaluate_survival:2070` `food = team.resources.get("food")` 漏糧倉 → 定居隊 food=0 → days_left=0 → 永 urgent + 釋放檢查(2093 `days_left>=RECOVER`)永不過 → 永卡 survival。

- [ ] **Step 1: 寫失敗測試** `_test_survival_reads_granary()`（註冊）
```gdscript
func _test_survival_reads_granary() -> void:
	print("--- WS-2c survival 讀糧倉不誤判 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var t := TeamData.new(); t.team_id = 0; t.tile_pos = Vector2i(2,2); t.leader_id = 100
	_seed_pop(t, 5)
	t.resources = {"food": 0.0}    # team 無糧
	var tile := HexTileData.new(); tile.tile_pos = Vector2i(2,2)
	tile.outpost_owner = 0; tile.outpost_level = 1; tile.outpost_type = "civilian"
	tile.public_storage = {"food": 1000.0}   # 糧在糧倉(充足)
	state.world.tiles[2*1000+2] = tile
	var ldr := PersonData.new(); ldr.id = 100; state.persons[100] = ldr
	state.teams[0] = t
	# accessor 應回合併池 = 1000
	assert(ResourceSystem.effective_food(state, t) >= 999.0, "effective_food 應含糧倉，實際=%.1f" % ResourceSystem.effective_food(state, t))
	# survival 不該因 team food=0 誤觸（糧倉充足 → 非絕境）
	var fai := FactionAISystem.new()
	t.current_task = TeamData.TASK_IDLE
	fai._evaluate_survival(state, t)
	assert(t.current_task != TeamData.TASK_RETURN_HOME, "糧倉充足不該誤觸 survival/return_home，實際=%s" % t.current_task)
	print("survival reads granary OK")
```

- [ ] **Step 2: --import + 跑驗證失敗**（現 _evaluate_survival 讀 team food=0 → 觸 return_home）

- [ ] **Step 3: 實作**
  - `resource_system.gd`：`_own_granary_tile` 改 public（去底線或加 public wrapper）；加：
    ```gdscript
    # 本隊「有效糧」= 私產 food + 自家糧倉 food（決策讀者單源；消耗扣除走 resolve_consumption）。
    static func effective_food(state: WorldState, team: TeamData) -> float:
        var g: HexTileData = own_granary_tile(state, team)
        var gf: float = float(g.public_storage.get("food", 0)) if g != null else 0.0
        return float(team.resources.get("food", 0)) + gf
    ```
    （`_own_granary_tile` 現是 instance method → 改 static `own_granary_tile` 或加 static wrapper；實作者定，確認既有 caller 對齊。）
  - `faction_ai_system._evaluate_survival`（:2070）：`var food: float = ResourceSystem.effective_food(state, team)`。釋放檢查（2093 同 `days_left`）自動受惠（同一 food 變數）。

- [ ] **Step 4: --import + 跑驗證通過**（`survival reads granary OK`、`=== DONE ===`、coin_eq=0、InvariantAudit 0）

- [ ] **Step 5: 真絕境回歸測試** `_test_true_desperation_still_survival()`：team+糧倉**皆空** → `_evaluate_survival` 仍正確進 survival（accessor 不掩蓋真飢荒）。+ 既有飢荒測試全綠。

- [ ] **Step 6: Commit** `feat(economy): effective_food accessor + survival 讀糧倉(破商隊 survival 誤判)`

---

### Task 2: 路由其餘決策讀者過 accessor

**Files:** Modify `faction_ai_system.gd`、`ambition_ladder.gd`；Test `headless_test.gd`。

**病**：其餘決策讀者（WS-1 後同誤判 0）：
- `:92 food_days`、`:649 food_per_cap`、`:1001 food_pc`（**solo trade gate！商隊覓食分數**）、`:1610 days_left`、`:1906 hungry`、`:2509`、`ambition_ladder:48`。

**修**：逐一改用 `ResourceSystem.effective_food(state, team)`（語意 = 「本隊有多少糧」的決策）。
- **`:1001 food_pc`** 特別關鍵——solo `_evaluate_solo` 的覓食/survival 分數讀它；定居商隊 food=0 → 覓食分數爆高 → 蓋過 trade（商隊永覓食不貿易的直接元兇之一）。

> **per-site 判斷**：路由「問本隊持糧多寡做決策」的讀者。**聚合/特殊語意讀者**（如 `:1327 total_food` 跨隊加總、`:1979` 目標缺口、`:2377` reserve 門檻——這些可能本就指私產 or 已有自己語意）由實作者逐一判：屬「本隊有效糧」→ 路由；屬「私產特定」→ 保留 + 註明。**保守：不確定的標註留待後續，先確保 survival/trade/ambition gate 路由（unblock 主路徑）**。

- [ ] **Step 1: 寫失敗測試** `_test_solo_trade_not_starved()`：定居商隊（team food=0、糧倉足、有貨+arb）→ `_evaluate_solo` 不因 food_pc=0 誤判覓食壓過 trade → 派 TASK_TRADE（或至少不卡 FORAGE/survival）。

- [ ] **Step 2: --import + 跑驗證失敗**

- [ ] **Step 3: 實作**：逐一路由上列讀者（survival/trade/ambition gate 必改；聚合/特殊語意逐一判，保守處理）。

- [ ] **Step 4: --import + 跑驗證通過**（`solo trade not starved OK`、既有 trade/ambition/salary 測試對齊）

- [ ] **Step 5: Commit** `feat(economy): 路由決策讀者過 effective_food(survival/trade/ambition gate)`

---

### Task 3: 回歸 + **world_sim 權威量測（履約脫 0!）** + 回報

**Files:** Test `headless_test.gd`；無產品 code 改。

- [ ] **Step 1: headless 回歸**：`=== DONE ===`、新測 OK、**既有飢荒/絕境/trade/ambition 全綠**、coin_eq=0、InvariantAudit 0。

- [ ] **Step 2: world_sim 權威量測（2-3 跑，本 arc 成敗總驗收）**：
  - `g1.merchant_survival` 18837 → **暴跌**（商隊不再永卡 survival）。
  - `g1.market_arrive` 0 → **正**（商隊真抵達市集）。
  - `g1.seek_market`/`board_read` → 商隊讀到看板。
  - `訂單履約率` 0% → **正**、`[Market]成交` 0 → **>0**。
  - 世界無過餓（accessor 不掩真飢荒；存活隊數穩）。

- [ ] **Step 3: 回報 handback** `2026-06-21-implementer-to-systems-economy-ws2c.md`（`from: implementer / to: systems / status: open`）：新測結果、**world_sim 全探針對照（merchant_survival/market_arrive/履約率/成交）**、商隊是否終於貿易、世界是否過餓、哪些決策讀者路由了/保留了（per-site）、異常。

- [ ] **Step 4: Commit handback** `docs(economy): WS-2c food accessor world_sim 量測(履約 0→?)`

---

## Self-Review 註記

- **根因 = WS-1 半套**：WS-1 改消耗讀合併池，漏改**決策讀者** → 定居隊 AI 自以為餓（team food=0）→ 永 survival。本 WS 補齊（accessor 單源）。**框架教訓**：搬資源位置（food→糧倉）= 所有讀者都要跟著走，不只消耗 [[project_framework_seams]]。
- **守恆安全**：純讀取改（AI 以為有多少糧），消耗扣除 WS-1 已正確 → 不碰守恆。
- **無飢荒回歸 = 風險**：accessor 讓 AI 看到糧倉 → 定居隊不誤觸 survival；但真絕境（team+糧倉空）仍須進 survival（Task1 Step5 + 既有飢荒測試守）。
- **權威量測 = world_sim**（不信密集 harness，WS-2 教訓）：market_arrive 0→正 + 履約 0→正 = 經濟 arc 真正活起來的證據。**這是整條經濟 arc 的總驗收**。
- **per-site 保守**：聚合/特殊語意讀者（total_food/reserve/target gap）逐一判，不確定者保留標註，先確保 survival/trade/ambition gate 路由（unblock 主路徑），避免過度改動牽連。
- **若 world_sim 仍 0**：market_arrive 升但履約仍 0 → co-location/settle 問題（再查）；market_arrive 仍 0 → survival 外還有別的鎖（measure-first 再挖）。別硬調。
- **與已 merge 關係**：補 WS-1（food 搬家的讀者側）+ 解鎖 WS-2b（商隊出得了門，看板機制才被 exercise）。改 resource_system(accessor)/faction_ai(讀者)/ambition_ladder(讀者)。
- **TEST VALUE**：無新常數（純讀取路由）。
