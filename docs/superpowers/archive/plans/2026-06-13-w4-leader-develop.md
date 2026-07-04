# W4 收尾：Leader 駐家發展 + 派工公庫提領 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task.
> L2 批次。W4 最後一哩 — fief 公庫機制已就位，補 A（leader 駐家攢公庫）+ B（派工從腳下公庫提領 caravan-load）。

**Goal:** leader idle 加「治理」駐家選項（一般稅自動積自家公庫）+ `_dispatch_builder` gate/funding 吃腳下公庫（caravan-load）。emergent 解 W4。

**Spec:** `docs/superpowers/specs/2026-06-13-w4-leader-develop-design.md`

**Verified facts:**
- `_evaluate_solo`（faction_ai :893）：leader idle 決策。scores dict（:906）含 攻擊/掠奪/外交/逃跑/製造/貿易 + idle 0.1；best_task match（:927）設 solo_target；`TaskArbiter.try_set(... PRIO_DISPATCH "solo")`（:942）
- `_find_own_outpost`（:1953）回自家 outpost pos 或 (-1,-1)
- `collect_resources`（resource_system :34）對任何站在 outpost tile 的 team 自動採集（非 task 驅動）；fief 一般稅 `_apply_normal_tax` 已接在採集後（撥腳下 tile owner 公庫）
- `_dispatch_builder`（faction_ai :1373）：gate :1376-1381 只查 `leader_team.resources`；advisor gate :1382-1385；pop gate :1386-1390；`SubteamSystem.dispatch` :1391；其後（fief）呼叫 `_fund_subteam_cost`
- `_fund_subteam_cost`（:1481，fief 後簽章含 tile）：公庫優先補差額。本 plan 新據點改用 `_fund_subteam_from_vault`（腳下公庫 caravan-load）
- `start_build`（outpost_system :312，fief 後 `_can_afford`/`_deduct_cost` 吃 tile）：新據點目標格無公庫 → fallback 子隊私產
- `_tag_weight`（faction_ai，task tag 權重，無對應 tag fallback 1.0）
- `OUTPOST_COST` civilian L1 material（outpost_system，fief 後純 mat 50）
- 測試：`.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`；2 年驗收 config max_ticks 21600→172800（**Edit 工具改，嚴禁 PowerShell -replace；跑完還原**）

---

## Task 1: B — 派工腳下公庫提領（caravan-load）

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 失敗測試**

```gdscript
func _test_dispatch_builder_uses_vault() -> void:
	print("--- W4 Task1: 派工腳下公庫提領 ---")
	# leader 站自家 outpost、公庫 material 足、私產 0 → _dispatch_builder 通過
	# ...
	print("W4 Task1a OK")

func _test_dispatch_builder_local_only() -> void:
	# leader 不在自家 outpost（腳下無公庫 or 他人 outpost）→ 只算私產 → 私產不足則失敗
	# ...
	print("W4 Task1b OK")

func _test_caravan_load_conserves() -> void:
	# 派工後子隊背包含 cost、公庫扣對應量（守恆：公庫減 == 子隊增）
	# ...
	print("W4 Task1c OK")
```

- [ ] **Step 2: 改 `_dispatch_builder` gate + 新 funding**

gate（:1376-1381）改吃腳下公庫合併池：

```gdscript
	var cost: Dictionary = OutpostSystem.OUTPOST_COST[outpost_type][level - 1]
	var home_tile: HexTileData = state.world.tiles.get(
		leader_team.tile_pos.x * 1000 + leader_team.tile_pos.y)
	var vault: Dictionary = {}
	if home_tile != null and home_tile.outpost_owner == leader_team.team_id:
		vault = home_tile.public_storage
	for k in cost:
		if k == "ticks": continue
		var avail: float = float(vault.get(k, 0)) + float(leader_team.resources.get(k, 0))
		if avail < float(cost[k]) * 1.5:
			_log_dispatch_fail(leader_team.faction_id,
				"資源不足 1.5x: %s 有 %.0f(公庫%.0f+私%.0f)" % [k, avail,
				float(vault.get(k, 0)), float(leader_team.resources.get(k, 0))], cost)
			return false
```

dispatch 成功後，把既有 `_fund_subteam_cost` 呼叫換成 `_fund_subteam_from_vault`：

```gdscript
func _fund_subteam_from_vault(state: WorldState, owner: TeamData, sub: TeamData,
		home_tile: HexTileData, cost: Dictionary) -> void:
	var vault: Dictionary = home_tile.public_storage if (home_tile != null \
		and home_tile.outpost_owner == owner.team_id) else {}
	for k in cost:
		if k == "ticks": continue
		var need: float = maxf(float(cost[k]) - float(sub.resources.get(k, 0)), 0.0)
		if need <= 0.0: continue
		var from_vault: float = minf(need, float(vault.get(k, 0)))
		if from_vault > 0.0:
			vault[k] = float(vault.get(k, 0)) - from_vault
			sub.resources[k] = float(sub.resources.get(k, 0)) + from_vault
			need -= from_vault
		if need > 0.0:
			var t: float = minf(need, float(owner.resources.get(k, 0)))
			owner.resources[k] = float(owner.resources.get(k, 0)) - t
			sub.resources[k] = float(sub.resources.get(k, 0)) + t
```

（`_dispatch_builder` 內 dispatch 後傳 home_tile + cost 呼叫此函數）

- [ ] **Step 3: 跑 + Commit**

```powershell
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(w4): 派工腳下公庫提領 caravan-load (_dispatch_builder gate+funding) (Task 1)"
```

---

## Task 2: A — Leader 駐家發展傾向（治理）

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_govern_option_cautious() -> void:
	print("--- W4 Task2: 治理駐家 ---")
	# 慎重高 leader + 自家公庫 material 不足 → _evaluate_solo 選「治理」、target=自家 outpost
	# ...
	print("W4 Task2a OK")

func _test_govern_warmonger_roams() -> void:
	# 好戰/野心高 leader → 攻擊/掠奪分 > 治理 → 不選治理
	# ...
	print("W4 Task2b OK")

func _test_govern_enough_stops() -> void:
	# 公庫 material ≥ GOVERN_MATERIAL_TARGET → 治理分降（need_develop false）→ 不優先治理
	# ...
	print("W4 Task2c OK")
```

- [ ] **Step 2: 改 `_evaluate_solo`**

const（faction_ai 頂）：
```gdscript
const GOVERN_MATERIAL_TARGET: float = 75.0   # TEST VALUE — 公庫建材達標就放手擴張
```

scores（:916 後加）：
```gdscript
	var own_pos: Vector2i = _find_own_outpost(state, team)
	if own_pos != Vector2i(-1, -1):
		var caution: float = float(leader_p.values.get("慎重", 0.5))
		var amb_dev: float = float(leader_p.values.get("野心", 0.5))
		var home_tile: HexTileData = state.world.tiles.get(own_pos.x * 1000 + own_pos.y)
		var vault_mat: float = float(home_tile.public_storage.get("material", 0)) if home_tile else 0.0
		if vault_mat < GOVERN_MATERIAL_TARGET:
			scores["治理"] = (caution * 0.4 + amb_dev * 0.2 + 0.15) * _tag_weight(team, "治理")
```

best_task match（:927）加：
```gdscript
		"治理":
			solo_target = own_pos
```

（治理抵達後 task 完成回 idle → idle-on-home 自動採集 + 一般稅積公庫 → 下個 idle 評估若公庫夠則 `_evaluate_infrastructure` 派工[Task1]，不夠續評治理）

- [ ] **Step 3: 跑 + Commit**

```powershell
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(w4): leader 駐家發展傾向 治理 (個性分流, 公庫達標放手) (Task 2)"
```

---

## Task 3: 整合驗證 + handback

**Files:**
- Create: `docs/superpowers/handbacks/2026-06-13-w4-leader-develop.md`

- [ ] **Step 1: 全測試 + multi + 2 年**

```powershell
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_test.gd > godot_test.log 2>&1
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd > godot_multi.log 2>&1
Get-Content godot_multi.log | Select-String "設施完工|FacilityStats|SoloAI.*治理|CoinAudit|PopSample" | Select-Object -First 30
```

2 年：config max_ticks 21600→172800（**Edit 工具改，嚴禁 -replace**），跑完還原。

驗收：
- **新據點/設施建造 > baseline（fief 為 1/0/1/0）** — W4 真解的核心指標
- `[SoloAI] 治理` 出現（慎重型 leader 駐家）；好戰型仍漫遊
- 公庫累積 → 派工提領 → caravan-load 建造鏈跑通（log 可見公庫扣→子隊→完工）
- coin 守恆 delta 0；material 總量守恆；ALL INVARIANTS PASSED
- 若仍 0 建造 → 回報卡點（治理優先序被壓？GOVERN_TARGET 太高攢不到？dispatch 其他 gate？）

- [ ] **Step 2: handback + Commit**

```markdown
# Hand Back: W4 收尾 (leader 駐家 + 公庫派工)
## 實作摘要 / 行為變化（治理觸發次數、建造數 before/after、建設型 vs 好戰型勢力分化）/ 守恆驗證 / W4 是否真解結論 / 待確認（GOVERN_TARGET 參數、治理被動性觀察）
```

```powershell
git add docs/superpowers/handbacks/2026-06-13-w4-leader-develop.md
git commit -m "docs: w4 leader develop handback (Task 3)"
```
