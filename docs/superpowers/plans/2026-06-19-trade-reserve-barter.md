# Trade 問題1+2（reserve 單一源 + NPC barter）Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 修 trade-economy-review 問題1（玩家路徑可刷光 NPC——reserve 留底不全）+ 問題2（NPC 無 barter——缺幣不能換，破對稱）。

**Architecture:** 接續 TradeValuation 單一源。問題1：reserve 邏輯收進 `TradeValuation.reserve()` 單一源，NPC + 玩家路徑同用（玩家不再刷光）。問題2：NPC market 加 barter pass——缺幣時互補 surplus 等值互換（coin_eq 中性，不鑄幣）。

**Tech Stack:** Godot 4.2.2 GDScript。閘 = `headless_test.gd` + `ui_flow_test.gd` + `game_sim_multi.gd`（**coin_eq=0 硬閘**——barter 換貨不碰 coin/ore_eq 守恆）。

**前置（強制）：** `git worktree add .worktrees/trade-rb -b feat/trade-rb && cd .worktrees/trade-rb`
**Baseline：** `headless_test.gd` `=== DONE ===`、`game_sim_multi.gd` coin_eq=0。

---

## 現況（研究確認）
- `interaction_system._calc_reserve`(:501)：food=`pop*0.1*FOOD_RESERVE_TICKS`、coin=`coin*0.5`、其他=`pop*TARGET_PER_POP[res]`（全資源留底）。NPC market(:598) 用它。
- `player_trade_system._sellable_qty`(:60)：food=同 food reserve、weapon=`pop*armed*WEAPON_RESERVE_RATIO`、**其他=`stock`（0 留底）** → 玩家買 NPC 的 material/ore/gem/tools/armor 可掃到 0。
- `interaction_system._attempt_trade_direction`(:574)：`:576 buyer_coin<=0 return` + 各腿 coin 結算 → 缺幣團即使 surplus 完美互補也換不了。
- `FOOD_RESERVE_TICKS` 在 player_trade(:43)。

---

## Task 1: reserve 單一源（修問題1 玩家刷光）

**Files:** Modify `scripts/simulation/trade_valuation.gd`、`interaction_system.gd`、`player_trade_system.gd`

- [ ] **Step 1: TradeValuation 加 reserve（canonical）**

`trade_valuation.gd` 加（搬 `_calc_reserve` 邏輯 + FOOD_RESERVE_TICKS const）：
```gdscript
const FOOD_RESERVE_TICKS: float = 20.0   # 從 player_trade 搬

# 留底（不賣掉自己需要的）：food 按存糧 tick、coin 半留、其他按 target 需求。單一源。
static func reserve(team: TeamData, res: String) -> float:
	if res == "food":
		return float(team.population) * 0.1 * FOOD_RESERVE_TICKS
	if res == "coin":
		return float(team.resources.get("coin", 0)) * 0.5
	return float(team.population) * float(TARGET_PER_POP.get(res, 0.0))
```
> 武器留底：統一用 target-based（`TARGET_PER_POP[weapon]`，原 NPC 路徑作法）；玩家路徑原 armed-based weapon reserve 改為 target-based（單一源，drift 收斂）。

- [ ] **Step 2: interaction + player_trade delegate**

- `interaction_system._calc_reserve`(:501) → `return TradeValuation.reserve(team, res)`（或刪函數,呼叫點 :598 直接 `TradeValuation.reserve`）。
- `player_trade_system._sellable_qty`(:60) 改：
```gdscript
func _sellable_qty(team: TeamData, res: String) -> float:
	return maxf(float(team.resources.get(res, 0)) - TradeValuation.reserve(team, res), 0.0)
```
刪 player_trade 的 `FOOD_RESERVE_TICKS`/`WEAPON_RESERVE_RATIO`（移至 TradeValuation 或不再用）。

- [ ] **Step 3: import + headless** Expected: `=== DONE ===`，trade 測試綠。玩家買 NPC 非 food/weapon 資源現受 target reserve 限制（不可掃 0）。
- [ ] **Step 4: Commit** `git commit -am "fix(trade): reserve 單一源(TradeValuation.reserve),玩家路徑全資源留底(修刷光)"`

---

## Task 2: NPC barter（修問題2 缺幣不能換）

**Files:** Modify `scripts/simulation/interaction_system.gd`（`_resolve_market` + 新 `_attempt_barter`）

- [ ] **Step 1: 加 barter pass**

`_resolve_market`（:561）在兩個 `_attempt_trade_direction` 之後加 barter pass（coin 換完後，互補 surplus 等值互換）：
```gdscript
	_attempt_trade_direction(state, a, b)
	_attempt_trade_direction(state, b, a)
	_attempt_barter(state, a, b)   # 缺幣互補：以物易物
```

新 `_attempt_barter`（互補 surplus 等值互換；coin_eq 中性）：
```gdscript
# 以物易物：a 的 surplus(b 想要) ↔ b 的 surplus(a 想要)，按 local_value 等值互換。
# 處理缺幣團互補 surplus（coin 路徑換不了）。不碰 coin，coin_eq 守恆。
func _attempt_barter(state: WorldState, a: TeamData, b: TeamData) -> void:
	# a 可給的（a surplus 且 b 缺=b 想要）
	for give_res in TradeValuation.BASE_PRICE.keys():
		if give_res == "coin": continue
		var a_surplus: float = maxf(float(a.resources.get(give_res, 0)) - TradeValuation.reserve(a, give_res), 0.0)
		if a_surplus <= 0.0: continue
		# b 是否想要（b 對該 res 估值 > a 對該 res 估值,即 b 較缺）
		if TradeValuation.local_value(b, give_res) <= TradeValuation.local_value(a, give_res): continue
		# 找 b 能回付的（b surplus 且 a 想要）
		for pay_res in TradeValuation.BASE_PRICE.keys():
			if pay_res == "coin" or pay_res == give_res: continue
			var b_surplus: float = maxf(float(b.resources.get(pay_res, 0)) - TradeValuation.reserve(b, pay_res), 0.0)
			if b_surplus <= 0.0: continue
			if TradeValuation.local_value(a, pay_res) <= TradeValuation.local_value(b, pay_res): continue
			# 等值互換：以雙方各自估值算可換量,取較小值的一筆
			var give_val: float = TradeValuation.local_value(b, give_res)   # b 願付的單價
			var pay_val: float  = TradeValuation.local_value(a, pay_res)    # a 願收的單價
			var give_qty: int = int(minf(a_surplus, b_surplus * pay_val / maxf(give_val, 0.001)))
			if give_qty <= 0: continue
			var pay_qty: int = int(round(give_qty * give_val / maxf(pay_val, 0.001)))
			if pay_qty <= 0 or pay_qty > int(b_surplus): continue
			# 執行互換（不碰 coin）
			a.resources[give_res] = float(a.resources.get(give_res, 0)) - give_qty
			b.resources[give_res] = float(b.resources.get(give_res, 0)) + give_qty
			b.resources[pay_res]  = float(b.resources.get(pay_res, 0)) - pay_qty
			a.resources[pay_res]  = float(a.resources.get(pay_res, 0)) + pay_qty
			print("[Barter] Team%d %dx%s ↔ Team%d %dx%s" % [a.team_id, give_qty, give_res, b.team_id, pay_qty, pay_res])
			break   # 一個 give_res 換一筆即可,下個 give_res
```
> MVP：每個 give_res 至多換一筆（避免巢狀爆量）。等值用雙方各自 local_value（缺方願付高、surplus 方願收低，價差內成交）。`break` 後續 give_res。**coin_eq 中性**（換 food/material/weapon 不碰 coin/ore_eq；若換 ore_gold/silver 會動 ore_eq——但雙向等量移轉,ore_eq 總量守恆）。

- [ ] **Step 2: import + headless** Expected: `=== DONE ===`，無 SCRIPT ERROR。
- [ ] **Step 3: Commit** `git commit -am "feat(trade): NPC barter pass,缺幣互補 surplus 等值互換(修對稱+缺幣換不了)"`

---

## Task 3: 測試 + 回歸 + hand-back

**Files:** Modify `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_trade_reserve_no_drain() -> void:
	# 玩家買 NPC material：NPC sellable 受 target reserve 限,不可掃 0
	# 建 NPC 隊 material 剛好 target 量 → _sellable_qty 應 ≈ 0（全留底）
	var pts := PlayerTradeSystem.new()
	var t := TeamData.new(); _seed_pop(t, 10)
	t.resources["material"] = 10 * TradeValuation.TARGET_PER_POP["material"]   # = reserve
	assert(pts._sellable_qty(t, "material") < 1.0, "material 在 reserve 量 → 不可賣（修刷光）")
	t.resources["material"] += 50
	assert(pts._sellable_qty(t, "material") > 40.0, "超 reserve 部分可賣")
	print("[OK] _test_trade_reserve_no_drain")

func _test_npc_barter_coinless() -> void:
	# 兩缺幣團互補 surplus（a 多 food 缺 material,b 多 material 缺 food,coin=0）→ barter 成交
	# 建 state,a/b coin=0,a food surplus+material 缺,b 反之 → _resolve_market 後雙方各得所需
	# assert a.material 增 + b.food 增 + 雙方 coin 仍 0（barter 不碰 coin）
	print("[OK] _test_npc_barter_coinless")
```
> 實作填入具體 state 建構 + assert（參考既有 trade 測試）。註冊 `_initialize()`。

- [ ] **Step 2: 全回歸**

```powershell
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
.\tools\godot.ps1 --headless --script scripts/debug/ui_flow_test.gd
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd
```
Expected: 全 `=== DONE ===`、ui_flow errors:0、**coin_eq=0**、全 invariant 0、無 SCRIPT ERROR。multi 可能多 `[Barter]` 成交（缺幣團現能換）= 預期改善。

- [ ] **Step 3: hand-back** `docs/superpowers/handbacks/2026-06-19-trade-reserve-barter.md`（問題1 reserve 單一源 + 問題2 barter、coin_eq=0 守恆、barter 成交量觀察、與 plan 差異）。
- [ ] **Step 4: Commit + push + 回報** `git push -u origin feat/trade-rb`，回報 branch + 結果 + coin_eq + barter 是否觸發。

---

## Self-Review

**Spec coverage：** trade-review 問題1（reserve 單一源,玩家全留底）+ 問題2（NPC barter 缺幣互補）。問題5(需求飽和)/offer-board 獨立後續。

**Placeholder scan：** Task 3 測試體標「實作填入 state+assert」附建構指引+斷言目標,非 placeholder。barter MVP（每 give_res 一筆 + break）範圍明示。

**Type consistency：** `TradeValuation.reserve(team,res)->float` static 單一源,interaction/player_trade delegate;`_attempt_barter(state,a,b)` 互換不碰 coin（coin_eq 中性）。local_value/reserve 同 TradeValuation 源。
