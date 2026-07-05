# wave1 序7：ReactionSystem 行為選擇溶入 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** ReactionSystem 唯一行為選擇（聚合 panic-flee bridge，`reaction_system.gd:48-60` 手算 try_set TASK_FLEE）撕除 → 集體潰散成引擎決策輸入（team_panic → survival option）。**保 9 反應為 consequence scaffolding**（情緒/loyalty/unrest/離隊/生育/memory 後果不動）。**溶=融合非刪**。

**Architecture:** ★reframe：9 反應 apply 幾乎全 state-effect，唯一改 task=bridge panic-flee。序7=拆 bridge（team_panic→ctx→survival option 自然 FLEE）+ 保反應。ctx.team_panic 讀 person stress 聚合=決策模型情緒腳首接線。FLEE 三源序保 survival(80)>panic(70)。詳 `specs/2026-07-06-wave1-reaction-dissolution.md`。

**Tech Stack:** Godot 4.2.2 GDScript；`tools/godot.ps1`；headless SceneTree。

## Global Constraints
- **融合非刪**：①行為溶入——高 team_panic+威脅→引擎出 FLEE（潰散→逃）②個體反應後果全保（comply/riot/defect/breed/extort/shirk apply 不變）③反向——低 panic 無威脅→不逃。
- **★FLEE 三源序保**：survival(80)>threat/panic(70)。panic-only 觸發不喧賓奪主（不抬過真 survival 絕境）。PANIC_WEIGHT 校此。
- **決策模型情緒腳起步**：ctx 首讀 person stress 聚合（team_panic）=情緒→決策接線。memory 腳完整接=未來（backlog）。
- **B 照妖鏡**：PANIC_WEIGHT/PANIC_RATIO——team-state 驅（非全域行為常數）尚可，殘全域標 B 債。
- seeded 漂移允許（QA wave）；framework PASS=7（S1-S6 不含 reaction，不破）；threat/solo/rung/vendetta/preempt/prosperity/faction-dispatch 融合驗+live-seam 不破；憲法閘（evaluate_all 指紋 removed）。
- ★序7 無現存 probe/framework S7 → **自建 harness**。
- wrapper 跑測試；`>` Select-String；`--import` 新 class。

## File Structure
- `scripts/simulation/decision/decision_context.gd`（Modify）— `team_panic`（person stress 聚合）。
- `scripts/simulation/decision/terms.gd`（Modify）— `threat_pressure` eval 疊 team_panic。
- `scripts/simulation/reaction_system.gd`（Modify）— 撤 bridge panic-flee try_set，保個體反應。
- `scripts/debug/reaction_dissolution_check.gd`（Create）— 自建融合驗。
- `scripts/debug/constitution_baseline.txt`（Modify）— evaluate_all 指紋 removed。

---

### Task 0: baseline
- [ ] **Step 1:** seeded + 現 bridge panic-flee 率：跑暫時 bed 量 `[ReactionBridge]` panic-flee 觸發次數（seed 1337/長窗）+ 個體反應分布（comply/riot/defect/breed 計數）。seeded 記錄。commit `measure(reaction): baseline bridge panic-flee + 個體反應分布`。

### Task 1: 自建融合驗 harness（TDD-first）
**Files:** Create `reaction_dissolution_check.gd`
- [ ] **Step 1:** 寫（先失敗，team_panic 未接）：
  - **行為溶入**：構隊多兵卒高 stress 低 loyalty（team_panic 高）+ 威脅在場 → `rank_scored`/rank_threat 出 survival(FLEE)（潰散→逃）。
  - **★FLEE 三源序**：真絕境（food≈0）→ survival 主；panic-only（食足無威脅但兵卒恐慌）→ FLEE 但 util 不抬過真絕境。
  - **反向守**：兵卒穩（低 stress）無威脅 → 不逃。
  - **★個體反應後果保**：跑 ReactionSystem，assert comply→loyalty+/riot→unrest+/defect→離隊 spawn/breed→minor+/extort→coin轉/shirk→food− 各 apply 仍執行（consequence 不動）。
- [ ] **Step 2:** Run，行為溶入 FAIL（team_panic 未接）、個體後果 PASS（未動）。commit。

### Task 2: ctx.team_panic + survival 吃之
**Files:** Modify `decision_context.gd`, `terms.gd`
- [ ] **Step 1:** ctx 加 `team_panic`（gather：該隊 `state.persons` 屬此 team 者，高 stress 低 loyalty 比例聚合）：
```gdscript
var team_panic: float = 0.0
# gather：迭該 team person，count(stress>PANIC_STRESS & loyalty<PANIC_LOY)/max(pop,1)
c.team_panic = clampf(float(_panic_n) / maxf(float(team.population), 1.0), 0.0, 1.0)
```
（ctx 首讀 person stress——擴 context 讀 person state 聚合。）
- [ ] **Step 2:** `terms.gd` `threat_pressure` eval 疊 team_panic（潰散=感知威脅放大）：
```gdscript
"threat_pressure":
    return ctx.threat + ctx.team_panic * PANIC_WEIGHT   # 潰散抬 survival util；PANIC_WEIGHT 校 ≤ 真絕境
```
加 `const PANIC_WEIGHT := 0.5`（TEST/B 債，team-state 驅）。
- [ ] **Step 3:** import + Run harness 行為溶入 PASS + 三源序保（調 PANIC_WEIGHT 使 panic-only 不抬過真 survival）。commit `feat(decision): ctx.team_panic + survival 吃潰散信號 (bridge flee 溶入,情緒腳起步)`。

### Task 3: 撤 bridge try_set + 保個體反應
**Files:** Modify `reaction_system.gd`
- [ ] **Step 1:** 刪 `evaluate_all` :48-60 bridge panic-flee 段（try_set + `_find_top_threat`/`_flee_target_simple` 若無他用一併，flee_count 計數若他用保留）。**個體反應 apply（:151-293）全不動**。
- [ ] **Step 2:** import + Run harness 全 PASS（行為溶入 + 三源序 + 反向 + 個體後果保）。seeded 冒煙（潰散仍及時→FLEE，`[Reaction]` 個體效果仍現）。commit（含 Task 4 baseline）。

### Task 4: 憲法閘 + 全回歸
- [ ] **Step 1:** 閘：`reaction_system.gd::evaluate_all` 指紋 removed（bridge try_set 撤）→ 更新 baseline（移除該行，標 `# 序7 reaction 行為溶入,個體後果保`）。同 Task 3 commit。
- [ ] **Step 2:** 全回歸：
```
.\tools\godot.ps1 --headless --script scripts/debug/reaction_dissolution_check.gd 2>&1 | Select-String "PASS|FAIL"
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "seeded warring|SCRIPT ERROR|DONE"
.\tools\godot.ps1 --headless --script scripts/debug/framework_validation.gd 2>&1 | Select-String "PASS=|DORMANT="
.\tools\godot.ps1 --headless --script scripts/debug/threat_preempt_check.gd 2>&1 | Select-String "ALL PASS|FAIL"
# + threat/solo/rung/vendetta/prosperity/faction-dispatch 融合驗全綠
.\tools\godot.ps1 --headless --script scripts/debug/constitution_gate.gd 2>&1 | Select-String "removed|CONSTITUTION-GATE"
```
Expected: reaction 融合驗 PASS、framework PASS=7、全融合驗綠（尤 threat/preempt 不破——FLEE 路共用）、閘 removed evaluate_all。
- [ ] **Step 3:** seeded 漂移 + 潰散率 before/after（對照 Task 0，panic→FLEE 仍及時觸發）。

### Task 5: handback
- [ ] **Step 1:** handback `2026-07-06-wave1-reaction-dissolution.md`：reframe 證（唯一行為=bridge flee）、融合驗結果、FLEE 三源序保、個體反應後果保、seeded 漂移、連動風險（team_panic 時序 step7→cadence 差、PANIC_WEIGHT 校、memory 腳仍 dormant=決策模型 gap backlog、反應觀測空白）。

## Self-Review
- Spec coverage：4a team_panic(Task2)✓、4b survival 吃(Task2)✓、4c 撤 bridge+保反應(Task3)✓、§5 自建融合驗(Task1/4)✓、§6 閘(Task4)✓。
- reframe：只拆 bridge flee（唯一行為），保 9 反應=consequence（藍圖 arc-order 情緒/後果保留）。
- FLEE 三源序：survival(80)>panic(70)，PANIC_WEIGHT 校不喧賓奪主（Task2 驗）。
- 決策模型：team_panic=情緒腳首接線；memory 腳 dormant=backlog（Task5 flag）。
- 風險：team_panic 時序差(Task5)、PANIC_WEIGHT B 債、反應零 probe→自建 harness(Task1)、_find_top_threat/_flee_target_simple 去留(Task3 grep)。
- 無 placeholder：ctx/term/刪除點/harness 全實碼或明確 file:line。
