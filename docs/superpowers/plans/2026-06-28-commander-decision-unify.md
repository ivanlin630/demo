# 統一統領決策 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:subagent-driven-development or executing-plans. Steps use checkbox (`- [ ]`).

**Goal:** refactor `_update_goals`（faction_ai）從多閾值並行 append → **單一連貫戰略姿態 argmax**（persona-weighted + belief + 承諾 hysteresis）。統領下單令 → 成員照 P3/P4 混合協調響應，無打+談矛盾。移除 war-priority OK繃。= 統一決策 arc 另一半（統領層）。

**Architecture:** measure 證統領同發 ≤4 矛盾令（每 persona ≥2）。重構為姿態集 `{守成(default),攻擊,徵收,外交}` argmax（掠奪移除=team-level P1 覆蓋、立國=分離成長 gate、緊急徵收=survival override）。f.goals 消費端（leader dispatch/member/unified faction_stakes）讀單令照樣 work。

**Tech Stack:** Godot 4.2.2 GDScript。測試 `scripts/debug/headless_test.gd`（`=== DONE ===` 無 `SCRIPT ERROR`）。

## Global Constraints
- **UTF-8 wrapper**：`.\tools\godot.ps1`（PowerShell）。worktree：每 Godot/git 前 `Set-Location` 進 worktree。
- **守恆**：徵收/外交/攻擊走既有 interaction 守恆，不碰守恆數學。coin_eq 0 + InvariantAudit 0。
- **scope guard**：**只 `_update_goals` 重構 + faction_data 一欄 + terms war-priority revert + 測**。不碰成員側 P3/P4 option、不碰 `strategic_ai`、不做並行軌、不新 TASK_*。掠奪從統領移除（team P1 覆蓋）。立國保分離 gate。緊急徵收保 survival override。
- **believability（ruling 5 規格）**：單姿態 argmax / 承諾 hysteresis（統領最該硬）/ 姿態吃人格 / 吃 belief（攻擊 gate 保留）/ 並行軌=未來不做。
- **P3/P4 不回歸（最高風險）**：統領單令攻擊→成員響應→跟戰 3/4 by construction。`p3_war_scenario` 跟戰 3/4 必驗。
- 新常數 `# TEST VALUE`。baseline：開工前 headless 全綠 + `commander_directive_measure`（記 4/2 同發）+ `p3_war_scenario`（記 3/4）。

---

### Task 1: `_update_goals` 單姿態 argmax 重構 + 緊急徵收 override + 立國分離 + 承諾 hysteresis

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`（`_update_goals` 重構 + `_score_posture` helper）
- Modify: `scripts/data/faction_data.gd`（`f.posture` 欄 或複用 `f.strategy`）
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- Consumes: leader values（野心/好戰/貪婪/義氣/計謀/慎重）、`f.is_established`、`leader_team.readiness`、`_nearest_independent`/`_richest_member`、`BeliefSystem.best_estimate`（攻擊 belief gate）、既有 attack_score/loot_score/diplo gate 條件。
- Produces: `f.goals = [單一姿態]`（攻擊/徵收/外交/守成-or-空）；`f.posture` 承諾追蹤。

- [ ] **Step 1: 讀 `_update_goals`(632-712 全段，含 徵收 3 子case/立國/外交/攻擊/掠奪 各 gate)+ 消費端(leader dispatch 739-771 / member 802-827 / unified faction_stakes gather)。確認單令仍被消費（`X in f.goals` 不變）。**

- [ ] **Step 2: 寫 failing test**
```gdscript
func _test_commander_single_posture() -> void:
	# 好戰霸主 → 單一 [攻擊]（非 [徵收,外交,攻擊,掠奪]）
	var goals_war: Array = _run_update_goals({"野心":0.9,"好戰":0.9,"義氣":0.1,"貪婪":0.5}, true)  # helper
	assert(goals_war.size() <= 1, "[cmd] 好戰霸主仍多令 %s" % str(goals_war))
	assert("攻擊" in goals_war, "[cmd] 好戰霸主未選攻擊姿態 %s" % str(goals_war))
	assert("外交" not in goals_war and "掠奪" not in goals_war, "[cmd] 攻擊姿態竟並發外交/掠奪")
	# 商業/義氣 leader → 外交 或 守成（非攻擊）
	var goals_dip: Array = _run_update_goals({"野心":0.4,"好戰":0.1,"義氣":0.8,"計謀":0.6,"貪婪":0.3}, true)
	assert("攻擊" not in goals_dip, "[cmd] 溫和 leader 竟攻擊姿態")
	assert(goals_dip.size() <= 1, "[cmd] 溫和 leader 多令 %s" % str(goals_dip))
	print("[cmd] single posture OK war=%s dip=%s" % [str(goals_war), str(goals_dip)])
```
> helper `_run_update_goals(values, established)`：建 faction（established）+ leader（values）+ 富 member + 弱獨立鄰 + leader belief 敵弱 + readiness 1.0 → 跑 `_update_goals` → 回 f.goals。仿 `commander_directive_measure` 構造。

- [ ] **Step 3: 跑測確認 FAIL**（現多令）

- [ ] **Step 4: 實作**

`faction_data.gd`：加 `var posture: String = ""`（承諾追蹤；或複用 strategy，plan 擇一——傾向新 posture 欄語意清）。

`faction_ai_system.gd` `_update_goals` 重構：
```
func _update_goals(state, f):
    f.goals.clear()
    leader_team / leader_p 取得（既有）
    # 1. player override（保留）
    if not f.player_goal_override.is_empty(): f.goals.append(override); return
    # 2. 立國分離 gate（未 established + 統領/野心/readiness）→ _declare_established（不入姿態）
    #    （搬既有 672-679 邏輯；established 後才姿態競爭）
    # 3. 緊急徵收 override（food < effective_emergency）→ f.goals=["徵收"]; f.strategy="緊急徵收"; return
    #    （搬既有 660-662 survival 級）
    # 4. 姿態 argmax（established 才跑）：
    var postures := {}   # 姿態→score
    postures["守成"] = SETTLE_BASE   # default base（知足，TEST VALUE）
    postures["攻擊"] = _score_attack(...)   # 既有 attack_score + belief/readiness gate 過才 >0
    postures["徵收"] = _score_levy(...)     # war_chest_need + 貪婪
    postures["外交"] = _score_diplo(...)    # 義氣/計謀 + has_independent + readiness
    # 承諾 hysteresis：對 == f.posture 加 COMMANDER_COMMITMENT_BONUS
    if f.posture in postures: postures[f.posture] += COMMANDER_COMMITMENT_BONUS
    var best := argmax(postures)
    f.posture = best
    if best != "守成": f.goals.append(best)   # 守成 = 無 stakes 令
```
`_score_attack/levy/diplo` = 既有 gate 條件（過 gate 才 score>0，否則 0/極低）+ 人格權重。複用既有 attack_score(野心.4+好戰.4-義氣.4)/loot_score(貪婪.5+好戰.3-義氣.3→徵收用)/diplo readiness。**攻擊 belief gate 保留**（own_armed≥敵×0.8 過才 score>0=吃 belief）。
加常數：`COMMANDER_COMMITMENT_BONUS`(> 0.3 隊層，TEST VALUE)、`SETTLE_BASE`(守成 default base，TEST VALUE)。

> **掠奪移除**：刪 707-712 掠奪 append（team P1 覆蓋）。

- [ ] **Step 5: 跑測 PASS + 既有全綠**

- [ ] **Step 6: Commit**
```
git add scripts/simulation/faction_ai_system.gd scripts/data/faction_data.gd scripts/debug/headless_test.gd
git commit -m "feat(faction_ai): _update_goals 單姿態 argmax(統領統一) + 承諾 hysteresis + 立國分離 + 緊急徵收 override (commander-unify)"
```

---

### Task 2: war-priority revert + 承諾 hysteresis 驗 + measure/P3/P4 回歸 + world_sim

**Files:**
- Modify: `scripts/simulation/decision/terms.gd`（revert `FACTION_DUTY_DRIVE_LESSER`）
- Modify: `docs/invariants.md`（統領單姿態）
- Test: `scripts/debug/headless_test.gd`
- 量測: measure 重跑 + p3_war_scenario + world_sim + framework + game_sim_multi

**Interfaces:** Consumes 全鏈。Produces 信心：單令、姿態穩定、war-priority moot、P3/P4 不回歸。

- [ ] **Step 1: war-priority revert** — `terms.gd` faction_duty eval：徵收/外交 `FACTION_DUTY_DRIVE_LESSER` → `FACTION_DUTY_DRIVE`（全 stakes 1.5；單令後 moot，不留死 OK繃）。刪 `FACTION_DUTY_DRIVE_LESSER` const。

- [ ] **Step 2: 寫承諾 hysteresis 測**
```gdscript
func _test_commander_hysteresis() -> void:
	# committed 開戰 leader 連續 cadence 不翻外交（承諾硬）
	var f = _setup_warlike_faction(...)   # helper
	var fai := FactionAISystem.new()
	fai._update_goals(state, f)
	var first: Array = f.goals.duplicate()
	assert("攻擊" in first, "[cmd] 未先committed攻擊")
	for i in 5: fai._update_goals(state, f)   # 情勢不變
	assert("攻擊" in f.goals, "[cmd] committed攻擊隊翻姿態(hysteresis失效)")
	print("[cmd] hysteresis OK 連續%d cadence 守攻擊" % 5)
```

- [ ] **Step 3: measure 重跑（核心驗）**
```
.\tools\godot.ps1 --headless --script scripts/debug/commander_directive_measure.gd
```
確認各 persona 同發 stakes 數 **4/2 → ≤1**（好戰→[攻擊]、貪婪→[徵收]、義氣→[外交]、溫和→[守成/空]）。

- [ ] **Step 4: P3/P4 回歸 — war_scenario + 既有測**
```
.\tools\godot.ps1 --headless --script scripts/debug/p3_war_scenario.gd
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
```
- `p3_war_scenario` 跟戰 **3/4**（統領單令攻擊→成員響應；war-priority 移除後靠單令）。**若 war_scenario 因統領現只下單令而 leader 不下攻擊** → 調 scenario（leader 好戰→攻擊姿態，弱敵 belief）使其下攻擊單令，再驗成員 3/4。
- P3/P4 headless 測全綠（攻擊/徵收/外交 option 在單令下仍響應）。

- [ ] **Step 5: world_sim + framework + 守恆**
```
$env:GODOT_TIMEOUT="900"; .\tools\godot.ps1 --headless --script scripts/debug/world_sim.gd
.\tools\godot.ps1 --headless --script scripts/debug/framework_validation.gd
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd
```
記：2yr 不崩、派系下單令（無同發矛盾）、**戰略姿態穩定**（無 攻擊↔外交 反覆）、攻擊稀有（多數守成/外交/徵收）、S1 立國/S2 feud 仍 fire（framework PASS）、coin_eq 0、InvariantViolation 0。**既有 + P2/P3/P4 測全綠**。

- [ ] **Step 6: invariants 更新 + Commit**
`docs/invariants.md`「隊目標單一 owner」後加/改：統領 `_update_goals` 下**單一連貫戰略姿態**（姿態集 守成/攻擊/徵收/外交 argmax + 承諾 hysteresis，非並行閾值 append）；掠奪=日常個體（team option，非統領令）；立國=分離成長 gate；緊急徵收=survival override。
```
git add scripts/simulation/decision/terms.gd docs/invariants.md scripts/debug/headless_test.gd
git commit -m "refactor(decision): revert war-priority OK繃(統領單令後 moot) + invariants 統領單姿態 (commander-unify)"
```

---

## 完成後（子 session）
1. push `git push -u origin feat/commander-decision-unify`
2. handback `docs/superpowers/handbacks/2026-06-28-commander-decision-unify.md`：改檔 + 與 plan 差異 + **measure 重跑（4/2→≤1）** + **P3 跟戰 3/4（統領單令版）** + 姿態穩定度（hysteresis）+ world_sim（攻擊稀有否/姿態反覆否）+ 連動風險（掠奪移除、立國分離、緊急徵收 override 邊界、war-priority 移除）+ 待確認（COMMANDER_COMMITMENT_BONUS/SETTLE_BASE 量級、守成空令消費端）。
3. finishing-a-development-branch → Option 3，主 session merge。

## Self-Review（主 session）
- spec 範圍（只統領 _update_goals、不碰成員 option/strategic_ai/並行軌、掠奪移除、立國分離、緊急徵收 override）→ 全 Task 對齊。
- **單姿態 argmax**（核心）= measure 4/2→≤1（Task 2 Step 3）。
- **承諾 hysteresis**（統領最該硬）= Task 2 (hysteresis 測)。
- **姿態吃人格** = Task 1（好戰→攻擊/義氣→外交分歧）。
- **吃 belief** = 攻擊 gate 保留（既有 belief 強度 check）。
- **P3/P4 不回歸 + war-priority 移除** = 統領單令→成員響應 by construction（Task 2 Step 4 war_scenario 3/4）。
- 風險：war_scenario 需確認統領單令模式下構造出攻擊姿態（leader 好戰→攻擊）→ Task 2 Step 4 調 scenario。
- 風險：hysteresis 過硬（情勢變不調）→ gate fail 釋放（敵消失/belief 變）；world_sim 量穩定 vs 適應。
