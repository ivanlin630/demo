# world_sim 長期世界量測台 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 純 NPC 世界長跑量測 harness，量因果脊椎長期 emergent（立國/vendetta/誘殺/scout/鑄幣），擺脫 game_sim_test 玩家死→game_over 凍世界的腰斬。

**Architecture:** 新 config `world_sim.json`（複用 game_sim_test 8 隊 archetype，**去 `player` 區塊 + `command_schedule`**，max_ticks 2 年）→ `GameSetup._setup_player` 早退(pcfg empty)→ `player_id=-1` → 不觸發絕後 game_over → 世界跑滿。新 harness `world_sim.gd`（複用 game_sim_test 迴圈去玩家，Probe + SpineTrace 月取樣 + summary）。零遊戲 code 改。

**Tech Stack:** Godot 4.2.2 GDScript；複用 `GameSetup`/`SimRunner`/`Probe`/`SpineTrace`/`TeamTrace`；headless harness。

## Global Constraints

- wrapper 跑（UTF-8）。
- **零遊戲 code 改**：只新增 debug harness + config。`Probe.enabled` 本 harness 開、結尾還原 false。
- 來源：`specs/2026-06-20-world-sim-measurement-design`。
- 驗收：world_sim 跑滿 max_ticks（無玩家 game_over 凍結）、無 SCRIPT ERROR、不變量/coin_eq 維持；`[ProbeSummary]` 印；長期 emergent 至少數項（立國/vendetta/feud/scout/誘殺）>0。不影響既有 game_sim_test/headless_test。

## File Structure

- `config/world_sim.json`（新，explicit NPC 隊、無 player/schedule、長 max_ticks）。
- `scripts/debug/world_sim.gd`（新，`extends SceneTree`，長跑量測迴圈）。

---

### Task 1: world_sim.json config（純 NPC 世界）

**Files:**
- Create: `config/world_sim.json`

- [ ] **Step 1: 建 config**

複用 `config/game_sim_test.json` 的 `teams`（8 隊 id 0-7，archetype 齊：統領/商隊/敵軍/生產村/流亡/狼軍/獨立商隊/武裝部落，2 faction），但：
- **刪 `"player"` 區塊**（game_sim_test.json:148）→ `_setup_player` 早退 → `player_id=-1`。
- **刪 `"command_schedule"`**（無玩家指令）。
- `"max_ticks": 172800`（2 年 = 720 天）。
- `"seed": 77`（固定可重現）。
- Team0 `"name"` `"玩家"` → `"統領城"`（NPC 化命名，無功能影響；仍 faction 0 leader）。

完整 config（複製 game_sim_test.json 的 map + teams 0-7 區塊，套上述改動，無 player/schedule 結尾）：
```json
{
  "seed": 77,
  "mode": "explicit",
  "max_ticks": 172800,
  "map": { "radius": 4, "resource_richness": 5 },
  "teams": [ <複製 game_sim_test.json teams 0-7，Team0 name 改 "統領城"> ]
}
```
> teams 內容逐字複製 game_sim_test.json（含 anon_tiers/resources/leader/named_members/outpost/faction_id/is_faction_leader），不增刪欄位。**結尾無 `player`/`command_schedule`**。

- [ ] **Step 2: 驗 config 合法（載入不崩）**

```
.\tools\godot.ps1 --headless --import
```
（config 純資料，import 不報錯即可；實跑在 Task2。）

- [ ] **Step 3: Commit**
```bash
git add config/world_sim.json
git commit -m "feat(world-sim): world_sim.json 純 NPC 世界 config(無 player,2 年)"
```

---

### Task 2: world_sim.gd 長跑量測 harness

**Files:**
- Create: `scripts/debug/world_sim.gd`

**Interfaces:**
- Consumes: `GameSetup.setup`、`SimRunner.advance_tick`、`Probe`、`SpineTrace.dump`、`TeamTrace.dump`。

- [ ] **Step 1: 建 harness**

`scripts/debug/world_sim.gd`（複用 game_sim_test 迴圈精神，去玩家專屬：無 command_schedule、無 player encounter 驅動、`player_pos=Vector2i(-1,-1)`、SpineTrace 月取樣）：
```gdscript
extends SceneTree

# 純 NPC 世界長期量測台。無玩家 → 不觸發絕後 game_over → 世界跑滿 max_ticks。
# 量因果脊椎長期 emergent（立國/vendetta/誘殺/scout/鑄幣）。純觀測。

func _initialize() -> void:
	_run()
	quit()

func _run() -> void:
	print("=== world_sim: 純 NPC 長期量測 ===")
	Probe.enabled = true; Probe.reset()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config := GameSetup.load_config("res://config/world_sim.json")
	if config.is_empty():
		print("[FAIL] config/world_sim.json 載入失敗"); Probe.enabled = false; return
	GameSetup.setup(state, config)
	if state.player_id != -1:
		print("[WARN] player_id=%d（預期 -1 無玩家）" % state.player_id)
	var max_ticks: int = int(config.get("max_ticks", 172800))
	print("[world_sim] max_ticks=%d (%.1f 年) teams=%d" % [
		max_ticks, max_ticks / 86400.0, state.teams.size()])

	var no_player := Vector2i(-1, -1)
	var alive_zero_streak := 0
	for tick in range(max_ticks):
		runner.advance_tick(state, no_player)
		# encounter 超時防卡（無玩家驅動 → 逾時強制 draw）
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		# 月取樣（長跑免 log 爆）
		if (tick + 1) % (240 * 30) == 0:
			var month: int = (tick + 1) / (240 * 30)
			print("[world_sim] === 月 %d (tick=%d) 存活隊=%d ===" % [month, tick + 1, state.teams.size()])
			TeamTrace.dump(state, tick + 1)
			SpineTrace.dump(state, tick + 1)
		# 周期不變量
		if (tick + 1) % 240 == 0:
			_check_inv(state, tick + 1)
		# 世界全滅 → 提早收尾（連續 3 取樣存活 0）
		if state.teams.is_empty():
			alive_zero_streak += 1
			if alive_zero_streak >= 3:
				print("[world_sim] 世界全滅 @ tick=%d → 提早收尾" % (tick + 1)); break
		else:
			alive_zero_streak = 0

	Probe.summary()
	Probe.enabled = false
	print("=== world_sim DONE ===")

var _inv_violations := 0
func _check_inv(state: WorldState, tick: int) -> void:
	# 複用既有 InvariantAudit（與 game_sim_test 同來源）
	var v: Array = InvariantAudit.run(state) if InvariantAudit.has_method("run") else []
	if not v.is_empty():
		_inv_violations += v.size()
		print("[InvariantViolation] tick=%d 違反 %d 例:%s" % [tick, v.size(), str(v[0])])
```
> **InvariantAudit 介面確認**：照既有 `game_sim_test._check_invariants_periodic` 實際呼叫法對齊（若非 `InvariantAudit.run` → 用 game_sim_test 同款呼叫）。實作者讀 game_sim_test 的不變量檢查段照搬。
> **`runner._encounter_system` 取用**：確認 SimRunner 暴露 encounter system 欄位（game_sim_test:155 同款用法）。

- [ ] **Step 2: --import + 試跑短版驗證跑通**

先把 world_sim.json `max_ticks` 暫設 `7200`（1 月）試跑，確認無 SCRIPT ERROR、`player_id=-1`、`[ProbeSummary]` 印、不變量無爆：
```
.\tools\godot.ps1 --headless --script scripts/debug/world_sim.gd
```
Expected: `=== world_sim DONE ===`、無 `[WARN] player_id`、`[ProbeSummary]` 出。**確認跑通後改回 172800**。

- [ ] **Step 3: Commit**
```bash
git add scripts/debug/world_sim.gd
git commit -m "feat(world-sim): 純 NPC 長跑量測 harness(player_pos=-1,月取樣,Probe summary)"
```

---

### Task 3: 2 年全跑驗收 + 數字回報

**Files:**
- 無 code 改（跑 + 回報）。

- [ ] **Step 1: 確認 max_ticks=172800（Task1 已設）**

- [ ] **Step 2: 全跑 2 年**

```
.\tools\godot.ps1 --headless --script scripts/debug/world_sim.gd
```
（172800 tick 純 NPC，分鐘級；可 background。）
Expected:
- 跑滿（或世界全滅提早收尾）無 SCRIPT ERROR。
- `player_id=-1`（無玩家 game_over 凍結）。
- `[ProbeSummary]` 印；**長期 emergent 非零**：`g2.faction_found` / `g2.vendetta_trigger` / `g2.feud_formed` / `g3.scout_dispatch` / `g3.ambush` / `g1.mint` 至少數項 >0（90 天測不到的，2 年長出來）。
- 不變量/coin_eq 維持（探針不破、世界守恆）。

- [ ] **Step 3: 回報 handback**

寫 `docs/superpowers/handbacks/2026-06-20-implementer-to-systems-world-sim-numbers.md`（或交接回報）：
- 跑滿 tick 數 / 是否提早全滅。
- `[ProbeSummary]` 全表。
- 對照 90 天首輪：哪些 0→非零（沒跑夠久）、哪些仍 0（真沒條件，需專門場景）。
- 異常（不變量/perf/LOD 退化）。

- [ ] **Step 4: Commit handback**
```bash
git add docs/superpowers/handbacks/2026-06-20-*world-sim*.md
git commit -m "docs(world-sim): 2 年全跑量測回報"
```

---

## Self-Review 註記

- **零遊戲 code 改**：只新 config + harness。`player_id=-1`（config 無 player → _setup_player 早退）→ 世界不凍。
- **spec 覆蓋**：config 無 player(Task1)、harness 月取樣 + summary(Task2)、2 年驗收 + emergent 非零驗證 + 回報(Task3)。
- **風險**：(a) `advance_tick(state, -1,-1)` LOD 無玩家焦點 → Task2 Step2 短跑驗跑通；若 LOD 退化致行為異常記 known_issues（量測台限制非遊戲 bug）。(b) InvariantAudit/encounter system 介面 → 照 game_sim_test 實際呼叫對齊（plan 已標確認點）。(c) 長跑 perf → 月取樣控 log；background 跑。
- **emergent 驗證**：Task3 比對 90 天 vs 2 年 → 分離「沒跑夠久」vs「真沒條件」（首輪量測的核心未決問題）。
- **執行確認**：teams 逐字複製 game_sim_test.json 去 player/schedule；max_ticks 試跑用 7200 再改 172800；InvariantAudit 呼叫對齊既有；Probe 結尾還原 enabled=false。
