# wave1 序4：vendetta 溶入引擎 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 強血仇 hand dispatch（`faction_ai:733-741` 直塞 TASK_ATTACK@PRIO_VENDETTA）撕除 → `feud_pull` term 掛進 攻擊 option（血仇成攻擊的 weight 驅力）。優先序（威脅>血仇>致富攻擊）翻成 rank 權重 + 既有 PRIO。**溶=融合非刪**。

**Architecture:** feud_pull term（已存在，未掛）+ feud weight（已存在）掛進 攻擊 option；加 feud-based applicable + ctx.feud_target_id + to_task 血仇 target 路由；刪 hand dispatch，probe 移引擎。詳 `specs/2026-07-05-wave1-vendetta-dissolution.md`。

**Tech Stack:** Godot 4.2.2 GDScript；`tools/godot.ps1`；headless SceneTree。

## Global Constraints
- **融合非刪**：①repertoire——強血仇+衝動 leader+可見仇敵→攻擊仇敵可達；無血仇/溫和→不攻 ②優先序保——威脅>血仇（threat slice PRIO_THREAT 70 覆蓋）、血仇>致富攻擊（feud_pull weight 贏 rank）。
- **感知鐵律（北極星）**：feud=已知關係（known_reputations/feud memory），合鐵律；仇敵經 belief 可見判。禁讀 tag。
- **framework S2b `g2.vendetta_trigger` 不 DORMANT**（probe 移引擎 dispatch）。
- seeded 漂移允許（QA wave 判）；framework PASS=7；threat/solo/rung 融合驗+live-seam 不破；憲法閘 PASS。
- wrapper 跑測試；`>` Select-String；`--import` 新 class。

## File Structure
- `scripts/simulation/decision/options.gd`（Modify）— feud_pull 掛 攻擊 terms + feud applicable + to_task 血仇 target + FEUD_ATTACK_MIN。
- `scripts/simulation/decision/decision_context.gd`（Modify）— feud_target_id。
- `scripts/simulation/faction_ai_system.gd`（Modify）— 刪 hand vendetta dispatch，probe 移。
- `scripts/debug/vendetta_dissolution_check.gd`（Create）— 融合驗。

---

### Task 0: baseline
- [ ] **Step 1:** seeded + `g2.vendetta_trigger` 現況：`.\tools\godot.ps1 --headless --script scripts/debug/framework_validation.gd 2>&1 | Select-String "S2b|vendetta"` 應 PASS。seeded 記錄。commit `measure(vendetta): baseline`。

### Task 1: ctx.feud_target_id
**Files:** Modify `decision_context.gd`
- [ ] **Step 1:** 加欄位 + gather（鏡射 `NpcAiSystem.vendetta_target` 掃描）：
```gdscript
var feud_target_id: int = -1
# gather（近 strongest_feud 計算處，ctx.gd:94 附近）：
var _vfoe: int = NpcAiSystem.new().vendetta_target(state, leader) if leader != null else -1
c.feud_target_id = _vfoe if (_vfoe != -1 and state.teams.has(_vfoe)) else -1
```
（`strongest_feud` 已有；feud_target_id 補仇敵 id + 存在守衛。vendetta_target 內含可見判。）
- [ ] **Step 2:** import 驗。commit。

### Task 2: 融合驗 harness（TDD-first）
**Files:** Create `vendetta_dissolution_check.gd`
- [ ] **Step 1:** 寫（先失敗，feud_pull 未掛）：
  - repertoire：強血仇 leader（好戰0.9/慎重0.2、feud intensity 高、可見仇敵）→ `rank_scored[0]=="攻擊"` 且 to_task target=仇敵；無血仇/溫和→攻擊非首選。
  - 優先序：①同隊血仇+壓境威脅→threat slice 覆蓋（rank_threat 先/PRIO_THREAT）②血仇隊 攻擊 util > 同隊 prosperity option。
- [ ] **Step 2:** Run，repertoire「攻擊」**FAIL**（feud_pull 未掛+applicable 不過）。commit。

### Task 3: feud_pull 掛攻擊 + applicable + to_task
**Files:** Modify `options.gd`
- [ ] **Step 1:** REGISTRY 攻擊加 feud_pull term：
```gdscript
"攻擊": [["faction_duty", "faction_duty"], ["attack_drive", "attack"], ["intent_fit", "intent_fit"], ["feud_pull", "feud"]],
```
- [ ] **Step 2:** applicable 加血仇路（opt.gd:87-91）：
```gdscript
"攻擊":
    if ("攻擊" in ctx.faction_stakes and ctx.faction_attack_target != -1) \
            or (ctx.intent == "征服" and ctx.intent_target != -1) \
            or (ctx.strongest_feud >= FEUD_ATTACK_MIN and ctx.feud_target_id != -1):
        out.append(opt)
```
加 `const FEUD_ATTACK_MIN := 0.5   # TEST VALUE：血仇開打門檻（防輕微不快即戰）`。
- [ ] **Step 3:** to_task 攻擊 target 多源（opt.gd:160，血仇 fallback）：
```gdscript
"攻擊":
    var _at: int = ctx.faction_attack_target if ctx.faction_attack_target != -1 \
        else (ctx.intent_target if ctx.intent_target != -1 else ctx.feud_target_id)
    # 對齊現 to_task 攻擊：target=state.teams[_at].tile_pos、combat_target=_at；_at==-1→IDLE fallback
```
- [ ] **Step 4:** import + Run harness：repertoire「攻擊」轉 **PASS**（血仇隊攻擊仇敵）+ 無血仇不攻。優先序驗 PASS。commit `feat(decision): wire feud_pull into 攻擊 option + feud applicable/target (vendetta 溶入)`。

### Task 4: 刪 hand vendetta dispatch + probe 移引擎
**Files:** Modify `faction_ai_system.gd`
- [ ] **Step 1:** 刪 `_evaluate_vendetta` hand dispatch（fai:733-741 整段）。
- [ ] **Step 2:** `g2.vendetta_trigger` probe 移引擎 dispatch：在 solo/主 rank dispatch 迴圈（`_evaluate_solo`/`_decide_unified` 派攻擊處）判血仇驅動 → bump。位置=`to_task` 攻擊且 `ctx.strongest_feud >= FEUD_ATTACK_MIN` 且非 faction/intent 驅（純血仇）：
```gdscript
if opt == "攻擊" and _ctx.strongest_feud >= DecisionOptions.FEUD_ATTACK_MIN \
        and not ("攻擊" in _ctx.faction_stakes) and _ctx.intent != "征服":
    Probe.bump("g2.vendetta_trigger")
```
（實作找 solo 攻擊 dispatch 點插入；確認 framework S2b 場景走此路。）
- [ ] **Step 3:** import + seeded 冒煙（無 SCRIPT ERROR、`[Vendetta]`/vendetta_trigger 仍現）。
- [ ] **Step 4:** commit（含 Task 5 baseline）：`refactor(faction_ai): dissolve hand vendetta dispatch into engine 攻擊-feud option + probe 移`。

### Task 5: 憲法閘 + 回歸 + handback
- [ ] **Step 1:** 閘：`.\tools\godot.ps1 --headless --script scripts/debug/constitution_gate.gd 2>&1 | Select-String "removed|新增|CONSTITUTION-GATE"`。`_evaluate_all_body` 仍有其他 try_set → 指紋應不變（confirm；變則更新 baseline 標 `# 序4 vendetta`，同 commit）。
- [ ] **Step 2:** 全回歸：
```
.\tools\godot.ps1 --headless --script scripts/debug/vendetta_dissolution_check.gd 2>&1 | Select-String "PASS|FAIL"
.\tools\godot.ps1 --headless --script scripts/debug/framework_validation.gd 2>&1 | Select-String "PASS=|DORMANT=|S2b"
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "seeded warring|SCRIPT ERROR|DONE"
.\tools\godot.ps1 --headless --script scripts/debug/threat_dissolution_check.gd 2>&1 | Select-String "ALL PASS|FAIL"
.\tools\godot.ps1 --headless --script scripts/debug/solo_dissolution_check.gd 2>&1 | Select-String "ALL PASS|FAIL"
.\tools\godot.ps1 --headless --script scripts/debug/rung_dissolution_check.gd 2>&1 | Select-String "ALL PASS|FAIL"
```
Expected: vendetta 融合驗 PASS、framework PASS=7（★S2b vendetta_trigger 不 DORMANT）、threat/solo/rung 綠、閘 PASS、seeded 跑完。
- [ ] **Step 3:** handback `2026-07-05-wave1-vendetta-dissolution.md`：融合驗結果、優先序保（威脅>血仇>致富）證、FEUD_ATTACK_MIN 值、seeded 漂移、連動風險（feud-攻擊與 prosperity-攻擊/征服-攻擊 target 多源競爭、probe 移位是否漏場景）。

## Self-Review
- Spec coverage：4a feud_pull 掛(Task3)✓、4b applicable(Task3)✓、4c ctx feud_target(Task1)✓、4d to_task(Task3)✓、4e 刪 dispatch+probe(Task4)✓、§5 融合驗(Task2/5)✓、§6 閘(Task5)✓。
- 優先序融合：威脅>血仇=PRIO_THREAT 70>DISPATCH 50（既有）；血仇>致富=feud_pull weight 贏 rank（Task2 驗）。
- 感知鐵律：feud=已知關係合法；禁讀 tag。
- 風險：攻擊 target 多源優先序（faction>intent>feud，Task3）、probe 移位漏場景（Task4 確認 S2b 走引擎路）、FEUD_ATTACK_MIN TEST VALUE。
- 無 placeholder：term 掛法/applicable/ctx/to_task/probe 全實碼。
