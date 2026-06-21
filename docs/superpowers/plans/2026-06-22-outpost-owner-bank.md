# outpost_owner banker Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans. Steps use checkbox (`- [ ]`).

**Goal:** outpost_owner 設單一 owner（OutpostOwnerBank.set_owner），16 寫者路由，禁裸 set（清 Pattern B 第四池）。行為零變（保 last-writer-wins）。

**Architecture:** 承 banker 模式。最小集中化 set_owner（同值 no-op + probe）。race-policy 留 refinement。

**Tech Stack:** Godot 4.2.2 GDScript。測試 `headless_test.gd` + `world_sim.gd`。

## Global Constraints
- wrapper 跑 Godot（UTF-8）；子 session 每次 Godot run 前 `Set-Location` 進 worktree。
- **行為零變**（保 last-writer-wins，不改 race）→ 既有測不變。
- 不碰守恆 → coin_eq/InvariantAudit 0。

---

### Task 1: OutpostOwnerBank + 路由全寫者

**Files:**
- Create: `scripts/simulation/outpost_owner_bank.gd`
- Modify: 16 寫者（grep,6 檔）
- Test: `scripts/debug/headless_test.gd`（加 `_test_outpost_owner_bank`，註冊）

**Interfaces:**
- Produces: `OutpostOwnerBank.set_owner(tile, owner: int, reason)`（static）。

- [ ] **Step 1: 寫失敗測試**

`headless_test.gd` 加：
```gdscript
func _test_outpost_owner_bank() -> void:
	print("--- OutpostOwnerBank 單一 owner ---")
	var tile := HexTileData.new(); tile.outpost_owner = -1
	OutpostOwnerBank.set_owner(tile, 5, "capture")
	assert(tile.outpost_owner == 5, "set_owner →5，實際=%d" % tile.outpost_owner)
	OutpostOwnerBank.set_owner(tile, -1, "abandon")
	assert(tile.outpost_owner == -1, "set_owner -1(棄守) →-1")
	print("outpost owner bank OK")
```
註冊。

- [ ] **Step 2: 跑測試確認失敗**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: FAIL — `OutpostOwnerBank` 不存在。

- [ ] **Step 3: 建 OutpostOwnerBank**

`scripts/simulation/outpost_owner_bank.gd`：
```gdscript
class_name OutpostOwnerBank

# Pattern B 所有權 banker：tile.outpost_owner 單一 owner(集中化+審計)。
# 本塊保 last-writer-wins(不改 race);race-policy 解析=後續 refinement(有 chokepoint 才好掛)。
static func set_owner(tile: HexTileData, owner: int, reason: String = "") -> void:
	if tile.outpost_owner == owner:
		return
	tile.outpost_owner = owner
	Probe.bump("g1.outpost_change")
```

- [ ] **Step 4: 跑測試確認通過**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: PASS — `outpost owner bank OK`。

- [ ] **Step 5: 路由全寫者（grep `outpost_owner\s*=` over scripts/simulation/**, 排除 `==`/`!=`/headless_test fixture）**

每處 `tile.outpost_owner = X` → `OutpostOwnerBank.set_owner(tile, X, "<reason>")`：
- `diplomatic_ai_system.gd:167`（結盟接管）→ reason "alliance"
- `encounter_system.gd:1349,1416,1441,1458`（戰鬥佔領）→ "capture"
- `faction_ai_system.gd:2190,2450,2492`（紮營/AI 接管）→ "camp"/"takeover"
- `game_setup.gd:175,332,470`（init）→ "init"
- `outpost_system.gd:271,301`（建造完成）→ "construct"；`316`(=-1 拆除)→ "demolish"；`592`(winner_id 佔領)→ "capture"
- `player_command_system.gd:535`(=-1 棄守)→ "abandon"

> 註：行號漂 → grep 重定位。變數名可能非 `tile`（如 cap_tile/occupied_tile/state.world.tiles[key]）→ 對齊實際 tile 變數。排除 `==`/`!=` 比較 + headless_test fixture。

- [ ] **Step 6: 跑回歸（行為不變）**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: PASS — `outpost owner bank OK` + 既有佔領/接管/建造/棄守/起義/結盟 測全綠；`=== DONE ===`、coin_eq/InvariantAudit 0。

- [ ] **Step 7: Commit**

```bash
git add scripts/simulation/outpost_owner_bank.gd scripts/simulation/ scripts/debug/headless_test.gd
git commit -m "feat(state): OutpostOwnerBank 單一owner — outpost_owner 集中化(Pattern B 第四池)"
```

---

### Task 2: 2 年 world_sim + grep + 回歸

**Files:** Verify only

- [ ] **Step 1: 跑 2 年 world_sim**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/world_sim.gd`
觀察佔領/易主正常、`g1.outpost_change` 出現、`=== DONE ===`、InvariantAudit 0。

- [ ] **Step 2: grep 驗無裸寫**

scripts/simulation/** 無殘留裸 `outpost_owner =`（除 outpost_owner_bank.gd；排除 `==`/`!=`）。

- [ ] **Step 3: 全回歸閘**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: 全綠、coin_eq/InvariantAudit 0。

- [ ] **Step 4: handback**

寫 handback：OutpostOwnerBank、16 路由清單、grep 驗、2 年 world_sim 易主、回歸。標 Pattern B 剩 resources(110 寫)；race-policy/pending_owner_change_tick 退役 = refinement。

---

## 完成後
子 session handback：OutpostOwnerBank、路由、2 年 world_sim、回歸。

## Self-Review
- Spec coverage：set_owner=Task1 Step3；16 路由=Step5；grep=Task2；2yr=Task2。全覆蓋。
- Placeholder：無（行號 grep 重定位；tile 變數名對齊實際）。
- Type consistency：`set_owner(tile, owner:int, reason)`；同值 no-op；probe。
