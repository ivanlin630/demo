# unrest_turns banker Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans. Steps use checkbox (`- [ ]`).

**Goal:** unrest_turns 設單一 owner（UnrestBank），全 13 production 寫者路由進 bank，禁裸絕對 set（清 Pattern B 第一池）。

**Architecture:** 新 static `UnrestBank`（add/reduce/reset），同 AnonCohort/RelationGraph 單一 owner 模式。純路由（行為不變）。

**Tech Stack:** Godot 4.2.2 GDScript。測試 `headless_test.gd` + `world_sim.gd`。

## Global Constraints
- wrapper 跑 Godot（UTF-8）。
- **行為保留**（同 delta/reset 數學）→ 既有 unrest 測不變、2yr world_sim 近基準。
- 純路由不碰守恆 → coin_eq/InvariantAudit 0。

---

### Task 1: UnrestBank + 路由全寫者

**Files:**
- Create: `scripts/simulation/unrest_bank.gd`
- Modify: 13 寫者（見下）
- Test: `scripts/debug/headless_test.gd`（加 `_test_unrest_bank`，註冊）

**Interfaces:**
- Produces: `UnrestBank.add(team,n,reason)`、`UnrestBank.reduce(team,n,reason)`、`UnrestBank.reset(team,reason)`（static）。

- [ ] **Step 1: 寫失敗測試**

`headless_test.gd` 加：
```gdscript
func _test_unrest_bank() -> void:
	print("--- UnrestBank 單一 owner ---")
	var t := TeamData.new(); t.unrest_turns = 0
	UnrestBank.add(t, 3, "test")
	assert(t.unrest_turns == 3, "add 3 →3，實際=%d" % t.unrest_turns)
	UnrestBank.reduce(t, 1, "test")
	assert(t.unrest_turns == 2, "reduce 1 →2，實際=%d" % t.unrest_turns)
	UnrestBank.reduce(t, 10, "test")
	assert(t.unrest_turns == 0, "reduce 超量 →clamp 0，實際=%d" % t.unrest_turns)
	UnrestBank.add(t, 5, "test"); UnrestBank.reset(t, "split")
	assert(t.unrest_turns == 0, "reset →0，實際=%d" % t.unrest_turns)
	print("unrest bank OK")
```
註冊進 `_run_sim_test`。

- [ ] **Step 2: 跑測試確認失敗**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: FAIL — `UnrestBank` 不存在（Parse/identifier error）。

- [ ] **Step 3: 建 UnrestBank**

`scripts/simulation/unrest_bank.gd`：
```gdscript
class_name UnrestBank

# Pattern B 所有權 banker：unrest_turns 單一 owner。所有 unrest 寫經此(禁裸 team.unrest_turns =)。
# reason 供審計(誰改民怨);reset 為唯一蓄意歸零路徑(split-resolution 類)。
static func add(team: TeamData, n: int, reason: String = "") -> void:
	team.unrest_turns = maxi(team.unrest_turns + n, 0)

static func reduce(team: TeamData, n: int, reason: String = "") -> void:
	team.unrest_turns = maxi(team.unrest_turns - n, 0)

static func reset(team: TeamData, reason: String = "") -> void:
	team.unrest_turns = 0
	Probe.bump("g1.unrest_reset")
```

- [ ] **Step 4: 跑測試確認通過**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: PASS — `unrest bank OK`。

- [ ] **Step 5: 路由全 production 寫者**

逐檔改（**先讀每處上下文確認 n 值/語意對齊**）：
- `faction_ai_system.gd:736` `t_cmd.unrest_turns += 1` → `UnrestBank.add(t_cmd, 1, "faction")`
- `faction_ai_system.gd:1401` `team.unrest_turns += 1` → `UnrestBank.add(team, 1, "faction")`
- `event_unrest_split.gd:22` `team.unrest_turns = 0` → `UnrestBank.reset(team, "split")`
- `event_unrest_split.gd:117` `parent.unrest_turns = 0` → `UnrestBank.reset(parent, "split")`
- `event_unrest_replace.gd:16` `team.unrest_turns = maxi(team.unrest_turns - UNREST_REPLACE_THRESHOLD, 0)` → `UnrestBank.reduce(team, UNREST_REPLACE_THRESHOLD, "replace")`
- `interaction_system.gd:413` `payer.unrest_turns += 1` → `UnrestBank.add(payer, 1, "tax")`
- `interaction_system.gd:983` `village.unrest_turns = maxi(village.unrest_turns - 1, 0)` → `UnrestBank.reduce(village, 1, "pacify")`
- `task_arbiter.gd:45` `team.unrest_turns += 1` → `UnrestBank.add(team, 1, "task")`
- `salary_system.gd:78` `team.unrest_turns += 1` → `UnrestBank.add(team, 1, "salary")`
- `resource_system.gd:309` `team.unrest_turns += 1` → `UnrestBank.add(team, 1, "famine")`
- `reaction_system.gd:258` `team.unrest_turns = maxi(team.unrest_turns - 1, 0)` → `UnrestBank.reduce(team, 1, "recover")`
- `reaction_system.gd:272` `team.unrest_turns += 1` → `UnrestBank.add(team, 1, "reaction")`
- `player_command_system.gd:313` `tgt.unrest_turns += 2` → `UnrestBank.add(tgt, 2, "player")`
- `player_command_system.gd:341` `tgt2.unrest_turns += 1` → `UnrestBank.add(tgt2, 1, "player")`

> 註：每處行號可能因近期改動漂移 → 用 grep `unrest_turns` 定位每個 production 寫（排除 headless_test.gd 的 fixture 設定 `unrest_turns = N`，那是測試初始化，**不路由**）。確認語意（add/reduce/reset）對齊原運算。

- [ ] **Step 6: 跑回歸（行為不變）**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: PASS — `unrest bank OK` + 既有 unrest/叛亂/替換/分裂/減薪測全綠（行為同數學不變）；`=== DONE ===`、coin_eq/InvariantAudit 0。**若既有 unrest 測紅 → 某處路由語意錯（add/reduce/reset 對錯）→ 修對，勿改測試。**

- [ ] **Step 7: Commit**

```bash
git add scripts/simulation/unrest_bank.gd scripts/simulation/ scripts/debug/headless_test.gd
git commit -m "feat(state): UnrestBank 單一owner — unrest_turns 全寫者路由(Pattern B 第一池)"
```

---

### Task 2: 2 年 world_sim 驗收 + 回歸

**Files:** Verify only：`world_sim.gd`、`headless_test.gd`

- [ ] **Step 1: 跑 2 年 world_sim**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/world_sim.gd`
觀察 unrest/叛亂/分裂事件近基準、`g1.unrest_reset` 出現（reset 走 bank）、`=== DONE ===`、無異常。

- [ ] **Step 2: 全回歸閘**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: 全綠、coin_eq/InvariantAudit 0。

- [ ] **Step 3: grep 驗無漏網裸寫**

確認 production code（排除 unrest_bank.gd + headless_test fixture）無殘留裸 `unrest_turns =`/`+=`/`-=`：grep `unrest_turns` over scripts/simulation，所有寫經 UnrestBank。漏網 → 補路由。

- [ ] **Step 4: handback**

寫 handback：UnrestBank + 13 路由清單、grep 驗無裸寫、2 年 world_sim unrest 行為、回歸。

---

## 完成後
子 session handback：UnrestBank、路由完整性（grep 證）、2 年 world_sim、回歸。**標**：Pattern B 剩 loyalty/resources/anon_treasury/outpost_owner banker（resources/anon_treasury 守恆敏感需嚴審）。

## Self-Review
- Spec coverage：UnrestBank=Task1 Step3；13 路由=Step5；grep 驗=Task2 Step3；2yr sim=Task2。全覆蓋。
- Placeholder：無（行號 Step5 註明 grep 重定位）。
- Type consistency：`UnrestBank.add/reduce/reset(team,n,reason)` static；reset bump probe；路由對齊原 add/reduce/reset 語意。
