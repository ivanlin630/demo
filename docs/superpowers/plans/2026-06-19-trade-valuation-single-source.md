# Trade 估值單一真值源（TradeValuation）Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 把 trade 估值收斂成單一真值源 `TradeValuation`：消除 `BASE_PRICE`/`TARGET_PER_POP` 兩份已 drift 的副本、兩份分歧的 `_local_value` 公式、以及 DTO 天平（給/要值用 interaction 5×）與接受判定（evaluate_offer 用 player_trade 2×）對 survival goods 的不一致。

**Architecture:** 通用模型/單一真值源（接續代碼健康）。新 `TradeValuation` 持 canonical 常數表 + 唯一 `local_value(team, res)`（含 survival 不對稱 + coin guard，合併兩檔最佳）。`interaction_system` / `player_trade_system` / `player_api_mapper` DTO 全 delegate → 天平與接受用同一公式，單一真相恢復。

**Tech Stack:** Godot 4.2.2 GDScript。閘 = `headless_test.gd` + `ui_flow_test.gd`（trade）+ `game_sim_multi.gd`（**coin_eq=0 必守**——trade 守恆與價格無關）。

> **注意**：canonical 表用 `interaction_system` 版（NPC market，含「# in」調過值；player_trade 副本是 drift 出的 stale）。統一後 **player 交易價格會變**（goods/weapon 等回 canonical）→ 屬修 drift 非破壞，coin_eq 守恆不受影響（trade 雙向守恆與單價無關）。

**前置（強制）：** `git worktree add .worktrees/trade-valuation -b feat/trade-valuation && cd .worktrees/trade-valuation`
**Baseline：** `headless_test.gd` `=== DONE ===`、`game_sim_multi.gd` coin_eq=0。

---

## 現況（研究確認）
- `interaction_system._local_value`(:541)：有 `SURVIVAL_GOODS`(food/medicine) shortage>0.5→5× 不對稱;**無** coin guard。BASE_PRICE/TARGET_PER_POP 在此檔（canonical，goods 15/weapon_melee_low 34…）。
- `player_trade_system._local_value`(:51)：**無** survival 不對稱（一律 2× cap）;**有** `if res=="coin": return 1.0`。BASE_PRICE/TARGET_PER_POP **另一份副本**（goods 5/weapon_melee_low 8…，與 interaction **已 drift**;檔頭 :3-4 註解明寫「須同步」）。
- DTO（`player_api_mapper:845-891`）：give/want_value 用 `InteractionSystem.local_value`(5×)、`npc_would_accept` 用 `PlayerTradeSystem.evaluate_offer`→`player_trade._local_value`(2×) → survival goods 天平≠接受。

---

## File Structure

| 檔案 | 動作 |
|---|---|
| `scripts/simulation/trade_valuation.gd` | **Create** | `class_name TradeValuation`：canonical `BASE_PRICE`/`TARGET_PER_POP`/`SURVIVAL_GOODS` const + `static local_value(team,res)->float` |
| `scripts/simulation/interaction_system.gd` | Modify | 刪自己的 BASE_PRICE/TARGET/SURVIVAL/_local_value;`_local_value`/`local_value` 呼叫點 → `TradeValuation.local_value` |
| `scripts/simulation/player_trade_system.gd` | Modify | 刪自己的 BASE_PRICE/TARGET 副本 + `_local_value`;呼叫點 → `TradeValuation.local_value` |
| `scripts/simulation/player_api_mapper.gd` | Modify | DTO give/want_value → `TradeValuation.local_value`（與 evaluate_offer 同源） |
| `scripts/debug/headless_test.gd` | Modify | `_test_trade_valuation_single_source`（天平 give/want 用的單價 == evaluate_offer 內用的單價,逐 survival good 比對） |

> **不動**：`_sellable_qty`/`_calc_reserve`（留底邏輯，各自語意，非估值）;`MAX_COIN_PER_TRADE`/`FOOD_RESERVE_TICKS` 等非估值 const。

---

## Task 1: 建 TradeValuation（canonical 單一源）

**Files:** Create `scripts/simulation/trade_valuation.gd`

- [ ] **Step 1: 建模組**

把 `interaction_system` 的 `BASE_PRICE`/`TARGET_PER_POP`/`SURVIVAL_GOODS`（canonical）搬進新檔 + 合併公式（survival 不對稱 + coin guard）：
```gdscript
class_name TradeValuation

# trade 估值唯一真值源：消 interaction_system / player_trade_system 兩份漂移副本。
const BASE_PRICE: Dictionary = { ... }       # 從 interaction_system 搬（canonical，含「# in」調值）
const TARGET_PER_POP: Dictionary = { ... }   # 從 interaction_system 搬
const SURVIVAL_GOODS: Array = ["food", "medicine"]

# 單一 local_value：survival 不對稱(食物/醫療 shortage>0.5→最高 5×) + coin 恆 face value。
static func local_value(team: TeamData, res: String) -> float:
	if res == "coin":
		return 1.0
	if not BASE_PRICE.has(res):
		return 0.0
	var pop: float    = maxf(float(team.population), 1.0)
	var stock: float  = float(team.resources.get(res, 0))
	var target: float = pop * float(TARGET_PER_POP.get(res, 1.0))
	var shortage: float = (target - stock) / maxf(target, 1.0)
	if res in SURVIVAL_GOODS and shortage > 0.5:
		shortage = 1.0 + (shortage - 0.5) * 6.0
	var sr: float = clampf(shortage, -0.5, 4.0 if res in SURVIVAL_GOODS else 1.0)
	return float(BASE_PRICE[res]) * (1.0 + sr)
```
> **逐鍵核對**：BASE_PRICE/TARGET_PER_POP 從 `interaction_system` 現值原樣搬（含 coin:1.0 若有）。合併公式 = interaction 的 survival 不對稱 + player_trade 的 coin guard，兩者語意不衝突。

- [ ] **Step 2: import 快取 + headless** Expected: `=== DONE ===`，無 SCRIPT ERROR（新 class_name 後須先 `--import`）。
- [ ] **Step 3: Commit** `git commit -am "feat(trade): TradeValuation canonical 估值單一源（survival 不對稱 + coin guard）"`

---

## Task 2: interaction_system delegate

**Files:** Modify `scripts/simulation/interaction_system.gd`

- [ ] **Step 1: 刪副本 + delegate**

- 刪 `interaction_system` 的 `BASE_PRICE` / `TARGET_PER_POP` / `SURVIVAL_GOODS` const + `_local_value`(:541) 函數體。
- `local_value(team,res)`(:555 公開存取) → `return TradeValuation.local_value(team, res)`。
- 該檔內所有 `_local_value(...)` 呼叫（:556/643/660/661 等）→ `TradeValuation.local_value(...)`。
> 若 BASE_PRICE/TARGET 在該檔還被**估值以外**用途引用（grep 確認），那些也改 `TradeValuation.X`。

- [ ] **Step 2: import + headless** Expected: `=== DONE ===`、trade 相關測試綠。
- [ ] **Step 3: Commit** `git commit -am "refactor(trade): interaction_system 估值 delegate TradeValuation"`

---

## Task 3: player_trade_system + DTO delegate

**Files:** Modify `scripts/simulation/player_trade_system.gd`、`scripts/simulation/player_api_mapper.gd`

- [ ] **Step 1: player_trade delegate**

- 刪 `player_trade_system` 的 `BASE_PRICE`/`TARGET_PER_POP` 副本（:5-42）+ `_local_value`(:51)。
- 所有 `_local_value(tgt,res)` 呼叫（:93/132/135/184/186 等）→ `TradeValuation.local_value(tgt, res)`。
> `FOOD_RESERVE_TICKS`/`MAX_COIN_PER_TRADE`/`WEAPON_RESERVE_RATIO` 保留（非估值）。`_sellable_qty` 保留。

- [ ] **Step 2: DTO give/want_value delegate**

`player_api_mapper.gd:845-891` 的天平 give/want_value（原用 `InteractionSystem.local_value`）→ `TradeValuation.local_value`。`evaluate_offer`（player_trade）內部已改 delegate（Task 3 Step 1）→ 天平與接受**同源**。

- [ ] **Step 3: import + headless + ui_flow** Expected: `=== DONE ===`、ui_flow trade 綠、無 SCRIPT ERROR。
- [ ] **Step 4: Commit** `git commit -am "refactor(trade): player_trade + DTO 天平 delegate TradeValuation（天平==接受同源）"`

---

## Task 4: 單一源測試 + 回歸 + hand-back

**Files:** Modify `scripts/debug/headless_test.gd`

- [ ] **Step 1: 單一源一致性測試**

```gdscript
func _test_trade_valuation_single_source() -> void:
	# 建缺 food/medicine 的隊（survival shortage>0.5 → 5× 區）
	# 驗：天平估值用的單價 == evaluate_offer 接受判定用的單價（同 TradeValuation.local_value）
	# 對 food/medicine/一般物各取一,assert 三方（interaction.local_value / player_trade 路徑 / TradeValuation）回同值
	var st := WorldState.new()
	var t := TeamData.new(); t.team_id = 1; st.teams[1] = t
	_seed_pop(t, 10); t.resources["food"] = 1.0   # 嚴重缺糧 → survival 不對稱觸發
	var v_direct: float = TradeValuation.local_value(t, "food")
	var v_inter: float = InteractionSystem.new().local_value(t, "food")
	assert(abs(v_direct - v_inter) < 0.001, "interaction.local_value 須 == TradeValuation（survival 5× 一致）")
	assert(v_direct > TradeValuation.BASE_PRICE["food"] * 2.0, "缺糧 survival 不對稱應 >2× base（驗 5× 區生效）")
	print("[OK] _test_trade_valuation_single_source")
```
> 若有 player_trade 對外估值入口亦比對。註冊 `_initialize()`。

- [ ] **Step 2: 全回歸**

```powershell
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
.\tools\godot.ps1 --headless --script scripts/debug/ui_flow_test.gd
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd
```
Expected: 全 `=== DONE ===`、ui_flow errors:0、**coin_eq=0**（trade 守恆不受價格統一影響）、全 invariant 0、無 SCRIPT ERROR。
> 註：trade 數字（成交價/量）可能變（drift 修正回 canonical），屬預期;coin_eq 守恆是硬閘。

- [ ] **Step 3: hand-back** `docs/superpowers/handbacks/2026-06-19-trade-valuation.md`（單一源化、canonical 取 interaction、天平==接受一致、價格變動說明、coin_eq=0 守恆、與 plan 差異）。
- [ ] **Step 4: Commit + push + 回報** `git push -u origin feat/trade-valuation`，回報 branch + 結果 + canonical 表是否與舊 interaction 完全一致。

---

## Self-Review

**Spec coverage：** 修 trade-economy-review 問題 3（_local_value 漂移 + DTO 內部不一致）+ 順修 BASE_PRICE/TARGET 雙副本 drift。其餘問題（barter/saturation/offer-board）獨立後續。

**Placeholder scan：** Task 1「BASE_PRICE/TARGET 從 interaction 原樣搬」附逐鍵核對指引;Task 4 測試體附建構+斷言目標,非 placeholder。

**Type consistency：** `TradeValuation.local_value(team,res)->float` static,單一公式;`interaction_system.local_value`/`player_trade._local_value`/DTO 全 delegate 同源。canonical 表取 interaction 現值（含「# in」調值）。coin_eq 守恆不變。
