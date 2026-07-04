# 框架驗證套件實作 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans. Steps use checkbox (`- [ ]`).

**Goal:** 補框架驗證套件可做子集：TC2/TC5 headless 行為測 + Part 2 魂觸發場景斷言（framework_validation.gd）。揭 dormant 魂。TC3 卡他域=skip 註明。

**Architecture:** Part 1 = headless DecisionEngine 行為斷言。Part 2 = `framework_validation.gd` 每魂最小場景 setup→跑 tick→斷言 probe fire 或報 dormant。

**Tech Stack:** Godot 4.2.2 GDScript。`headless_test.gd` + 新 `framework_validation.gd` + `world_sim.gd`。

## Global Constraints
- wrapper 跑 Godot（UTF-8）；每次 Godot run 前 `Set-Location` 進 worktree；**新 class_name 檔後跑 `--import`**。
- 不碰守恆/既有行為 → coin_eq/InvariantAudit 0。
- 套件目的=揭 dormant：觸發後仍 0 的魂 → **報 dormant backlog 非 fail**。

---

### Task 1: TC2 + TC5 headless 行為測

**Files:** Modify `scripts/debug/headless_test.gd`（加 `_test_tc2_survival_input`/`_test_tc5_economy_intel` + 註冊；TC3 skip print）

**Interfaces:** Consumes `DecisionEngine.decide/rank`、`DecisionContext.gather`、`_mk_merchant_team`/`_mk_order_msg`、belief（team_known order msg）。

- [ ] **Step 1: 寫測試**

```gdscript
func _test_tc2_survival_input() -> void:
	print("--- TC2 survival=高權重輸入(非latch) ---")
	# 糧近0 隊 → survival-class(覓食/survival/返家補給) util 壓過貿易(survival 是輸入贏,非硬閘)
	var s := WorldState.new(); s.world = WorldData.new()
	var t := _mk_merchant_team(s, {"義氣": 0.8, "貪婪": 0.3}, true, 0.0)  # 糧倉空
	t.resources["food"] = 0.0; t.current_option = ""
	var opt: String = DecisionEngine.decide(s, t)
	assert(opt in ["覓食", "返家補給", "survival"], "TC2:糧0→survival-class(輸入贏),實際=%s" % opt)
	print("TC2 survival-input OK (%s)" % opt)
	# TC3 卡他域(引擎攻擊 option)→skip
	print("TC3 SKIP: feud→脫軌攻擊需引擎攻擊 option(他域,未決)")

func _test_tc5_economy_intel() -> void:
	print("--- TC5 經濟+情報為輸入 ---")
	# 商業隊有貨 + belief 有 arb 單 → 貿易;belief 無單 → 不選貿易(撲空)
	var s1 := WorldState.new(); s1.world = WorldData.new()
	var t1 := _mk_merchant_team(s1, {"貪婪": 0.7}, true, 500.0)  # has_arb=true
	t1.current_option = ""
	assert(DecisionEngine.decide(s1, t1) == "貿易", "TC5:有貨+arb情報→貿易")
	# 無 arb 情報(belief 空) → economic_opp 低 → 非貿易為首(視糧/其他)
	var s2 := WorldState.new(); s2.world = WorldData.new()
	var t2 := _mk_merchant_team(s2, {"貪婪": 0.7}, false, 500.0)  # has_arb=false(無單情報)
	t2.resources["goods"] = 0.0   # 無貨無 arb → 貿易 util≈0
	t2.current_option = ""
	assert(DecisionEngine.decide(s2, t2) != "貿易", "TC5:無貨無arb情報→不撲空式貿易")
	print("TC5 economy-intel OK")
```
> 註：先確認 `_mk_merchant_team(s, vals, has_arb, food)` 簽名（sub-proj1 既有）+ DecisionContext.has_arb 來源（team_known order msg / OrderSystem）。對齊實際。TC2/TC5 斷言若因現 util 不符 → 調 fixture 使驅力明確（非放寬）。

註冊（TC7 後）。

- [ ] **Step 2-4: 跑→實作對齊→過**（TC2/TC5 行為斷言；若 fixture 需調使驅力明確則調，勿放寬語意）。Expected: `TC2 survival-input OK`/`TC5 economy-intel OK` + 既有全綠。

- [ ] **Step 5: Commit** — `feat(test): 框架驗證 TC2/TC5 headless 行為測(TC3他域skip)`

---

### Task 2: Part 2 魂觸發場景 harness（framework_validation.gd）

**Files:** Create `scripts/debug/framework_validation.gd`（SceneTree 腳本,仿 world_sim.gd 結構）

**Interfaces:** Consumes `GameSetup.setup`、`SimRunner.advance_tick`、`Probe`、`WorldState`/config。

- [ ] **Step 1: 建 harness 骨架**

`framework_validation.gd`（extends SceneTree）：每魂一個 `_scenario_Sx()`——min config（程式建 state 或載 config 變體）→ 跑 N tick → 讀 `Probe.counts` 斷言 probe > 0 或 print `[DORMANT] Sx <probe>=0`。彙整 PASS/DORMANT 報表。
- **S1 立國**：野心 tail leader 隊 + 資源 + 弱鄰 → 跑 ~10000 tick → `g2.faction_found > 0`。
- **S2 feud+vendetta**：預置殘忍 raider + 受害隊（留餘部）/ 或預置 feud 邊 → `g2.feud_formed > 0`（+ vendetta_trigger）。
- **S3 scout**：矛盾/不確定情報 + 慎重 leader → `g3.scout_dispatch > 0`。
- **S4 ambush**：偽弱餌（假低報 armed intel）+ 莽攻擊者 → ambush probe（**grep 確認 ambush probe 名;無則於 ambush_system 加 `Probe.bump("g3.ambush")` 並斷言**）。
- **S5 mint**：faction 控金礦 tile + 鑄幣廠設施 + 觸發挖礦 → `g1.mint > 0`（W8 dormant:若觸發鏈後仍 0→`[DORMANT] S5 mint chain`報 backlog,非 fail）。
- **S6 經濟閉環**：商業隊 + 生產隊(掛單) co-located → `g1.order_fulfilled > 0`。

> 每場景用最小 config（可程式直建 teams/tiles 或載 `config/world_sim.json` 加場景隊）。HOW 自定（仿 world_sim setup）。場景觸發後仍 0 → 報 [DORMANT]，不 crash。

- [ ] **Step 2: 跑 harness**

Run: `.\tools\godot.ps1 --headless --import`（新 class_name 後）then `.\tools\godot.ps1 --headless --script scripts/debug/framework_validation.gd`
記錄各 S 場景 PASS（probe>0）vs DORMANT（觸發後仍 0）。

- [ ] **Step 3: 處理 DORMANT**

觸發後仍 dormant 的魂 → 不在本塊修系統，**記 known_issues backlog**（魂 + 為何 dormant 的初判）。已 fire 的 → 斷言守住（harness 內 assert）。

- [ ] **Step 4: Commit** — `feat(test): 框架驗證 Part2 魂觸發場景 harness(S1-6 fire/dormant)`

---

### Task 3: 2 年 world_sim + 全回歸

- [ ] **Step 1: 2 年 world_sim** — `.\tools\godot.ps1 --headless --script scripts/debug/world_sim.gd`：魂 fire 數對照（faction_found/feud/scout/order_fulfilled…）、`=== DONE ===`、InvariantAudit 0。
- [ ] **Step 2: 全回歸** — headless 全綠、coin_eq/InvariantAudit 0。
- [ ] **Step 3: handback** — TC2/TC5 結果、Part2 各魂 PASS/DORMANT 表、dormant backlog、TC3 他域標記、回歸。

---

## 完成後
子 session handback：TC2/TC5、Part2 魂 fire/dormant 表、dormant backlog（記 known_issues）、TC3 他域未決、2 年 world_sim、回歸。

## Self-Review
- Spec coverage：TC2/TC5=Task1；S1-6 場景=Task2；dormant 處理=Task2 Step3；2yr=Task3。TC3 他域=skip 註明。全覆蓋（可做子集）。
- Placeholder：無（場景 HOW=subagent 仿 world_sim 自定 + grep probe 名=方法）。
- Type consistency：Probe.bump 名對齊既有（feud_formed/vendetta_trigger/scout_dispatch/faction_found/mint/order_fulfilled）；ambush probe 確認/補。
