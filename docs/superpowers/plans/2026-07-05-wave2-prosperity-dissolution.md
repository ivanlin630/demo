# wave2 序5：prosperity-attack 溶入引擎 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `_evaluate_prosperity_attack` gate cascade 決策溶進引擎 攻擊 option（readiness/attack_score→weight、富 prey→target finder、scout-verify→scaffolding）；刪 cascade + 序2 yield 閘 + unified reroute。**溶=融合非刪**，征服鏈 parity 必保。

**Architecture:** ★de-risk 兩階——**Phase1 加**（engine 攻擊補 readiness/富prey/scout-verify 到 cascade parity，cascade 仍在雙路對照）→ 驗 parity → **Phase2 拆**（刪 cascade/yield/reroute，FORCE 隊改主 rank）。gen 重校=序5 綠後 follow-up。詳 `specs/2026-07-05-wave2-prosperity-dissolution.md`。

**Tech Stack:** Godot 4.2.2 GDScript；`tools/godot.ps1`；headless SceneTree。

## Global Constraints
- **融合非刪 + 征服鏈 parity**：repertoire——FORCE 好戰野心隊 ready+富弱prey+情報夠→攻擊；readiness 閘（沒本錢不出征）；scout-verify（慎重不足→斥候/莽者→照衝 S4 誘殺）；富 prey 選；hunger_relief。該出現——seeded `conq.prosperity_reached` 不歸零、framework S3 scout/S4 ambush 不 DORMANT。
- **★征服率尺（藍圖 seq5-greenlight 重框）**：**雪球/一統/暴衝≠fail**（軍事易得非結局）；唯一 fail=龜縮凍死。**parity 哨只驗征服鏈不歸零**（repertoire 沒少），**不需保 rate、暴衝 OK**。記 before/after `conq.prosperity_reached` 率供 gen churn 重校 follow-up 參考（非守恆目標）。
- **★B 照妖鏡（決策模型驗收）**：征服行為須真穿過人格(野心/好戰/慎重)/現況(readiness/capability)的秤，非全域 gate/margin 直達。新閾（readiness_thr_eff 已含慎重✓/FEUD_ATTACK_MIN/VIABLE_ARMED_RATIO）殘全域者標 B-債（不擋序5，arc 尾收）。
- **感知鐵律**：prey 選/readiness/scout 只讀 belief 表象+known relations+self state，禁讀對方 tag。
- seeded 漂移允許（現 52/9/1/381，QA wave 判）；framework PASS=7；threat/solo/rung/vendetta/preempt 融合驗+live-seam 不破；憲法閘 PASS。
- wrapper 跑測試；`>` Select-String；`--import` 新 class。

## File Structure
- `scripts/simulation/decision/decision_context.gd`（Modify）— `readiness`/`readiness_thr_eff`/`prosperity_prey_id`。
- `scripts/simulation/decision/terms.gd`（Modify）— intent_fit 征服 × readiness factor。
- `scripts/simulation/decision/options.gd`（Modify）— 攻擊 to_task 征服 target=富 prey；scout-verify wrapper。
- `scripts/simulation/faction_ai_system.gd`（Modify）— Phase2：刪 cascade/yield/reroute；prey/scout helper 保留為 engine-called。
- `scripts/debug/prosperity_dissolution_check.gd`（Create）— 融合驗（征服鏈 parity 6 錨）。

---

## Phase 1：engine 攻擊 upgrade 到 cascade parity（加，cascade 仍在）

### Task 0: baseline（★征服率錨）
- [ ] **Step 1:** seeded + 征服率：跑 headless + framework，記錄 seeded 52/9/1/381、`conq.prosperity_reached` seeded 率、S3 `g3.scout_dispatch`/S4 `g3.ambush` PASS。寫暫時腳本量征服 funnel（prosp.entered/gate_*/conq.prosperity_reached）分佈。commit `measure(prosperity): baseline 征服率 + funnel`。

### Task 1: ctx readiness + 富 prey
**Files:** Modify `decision_context.gd`
- [ ] **Step 1:** 加 `readiness`（`calc_readiness` 移入 ctx：pop/skill/food/weapon mean）+ `readiness_thr_eff`（`calc_readiness_threshold × hunger_relief`，helper 移入或 ctx 算）+ `prosperity_prey_id`（gather 呼 `find_prosperity_prey`，含 has_belief/reachable 守衛）。
```gdscript
var readiness: float = 0.0
var readiness_thr_eff: float = 0.0
var prosperity_prey_id: int = -1
# gather：c.readiness = FactionAISystem.calc_readiness_static(state, team)（calc_readiness 靜態化）
#   c.readiness_thr_eff = thr × hunger_relief；c.prosperity_prey_id = find_prosperity_prey(...)
```
（`calc_readiness`/`calc_readiness_threshold`/`find_prosperity_prey` 靜態化 or static wrapper 供 ctx 呼，鏡射序2 is_resident_static 法。）
- [ ] **Step 2:** import 驗。commit。

### Task 2: intent_fit 征服 × readiness + 富 prey target
**Files:** Modify `terms.gd`, `options.gd`
- [ ] **Step 1:** `_intent_fit` 征服 boost（tm:172-175）× readiness factor：
```gdscript
# intent=="征服" & opt=="攻擊"：× clampf(readiness/readiness_thr_eff, 0, 1)（沒本錢→趨0=readiness閘）
return INTENT_FIT_DRIVE * (0.5 + max(野心,好戰)*0.5) * cap * clampf(ctx.readiness / maxf(ctx.readiness_thr_eff, 0.01), 0.0, 1.0)
```
（信義 penalty：attack weight 或 intent_fit 補 `−信義×k`，對齊 cascade attack_score。實作記錄。）
- [ ] **Step 2:** 攻擊 to_task 征服 target 用富 prey（opt:160）：多源 faction_attack > `ctx.prosperity_prey_id`(征服) > feud。
- [ ] **Step 3:** import + Run 融合驗 harness（Task 3 先寫）parity 部分。commit `feat(decision): 攻擊征服吃readiness閘+富prey targeting (cascade parity)`。

### Task 3: 融合驗 harness（征服鏈 6 錨）
**Files:** Create `prosperity_dissolution_check.gd`
- [ ] **Step 1:** 寫 6 錨（見 spec §5）：①FORCE ready 富弱prey→攻擊 target=富prey ②低 readiness→不攻(util趨0) ③慎重情報不足→斥候 ④莽者情報不足→照衝 ⑤餓→hunger_relief 降門檻 ⑥富 prey 選（richness/border 影響）。
- [ ] **Step 2:** Run，Phase1 後 parity 錨 ①②⑤⑥ 應 PASS（engine 攻擊已補）；③④ scout-verify 待 Task 4。commit。

### Task 4: scout-verify scaffolding
**Files:** Modify `options.gd` or `faction_ai_system.gd`
- [ ] **Step 1:** 攻擊(征服) dispatch 加 scout-verify wrapper（`_commit_conquest_attack` helper 或 to_task 征服路）：`confident_enough(prey, caution)`？→ attack、否 → TASK_SCOUT dispatch（保既有 flow：best_estimate 位、release/converge、timeout、probe g3.scout_dispatch/converge/timeout）。莽者 caution 低→恆 confident→照衝。
- [ ] **Step 2:** Run harness ③④ PASS（慎重→斥候、莽者→照衝）。commit `feat: scout-verify scaffolding on 征服 attack (means-end, S4 誘殺保)`。

### Task 5: Phase1 parity 驗（cascade 仍在，engine 攻擊已 parity）
- [ ] **Step 1:** 全回歸 + parity：融合驗 6 錨 PASS + framework PASS=7（S3/S4 仍靠 cascade）+ threat/solo/rung/vendetta/preempt 綠 + 閘 PASS + seeded 跑完。**此時 cascade 與 engine 攻擊雙路並存**——記錄 engine 攻擊路的征服 dispatch 是否與 cascade 一致（parity check）。commit。

---

## Phase 2：拆 cascade + yield + reroute（結構變）

### Task 6: 刪 cascade + yield + reroute
**Files:** Modify `faction_ai_system.gd`
- [ ] **Step 1:** 刪序2 yield 閘（fai:1755-1763）——FORCE 隊改主 rank 選攻擊。
- [ ] **Step 2:** 刪 unified reroute（fai:1521-1531）——攻擊 winner 直 to_task（含 scout-verify）。
- [ ] **Step 3:** 刪 `_evaluate_prosperity_attack` 決策（fai:259-349）+ loop3 invoke（fai:754-759）。`find_prosperity_prey`/scout helper **保留**（engine-called scaffolding，Task 1/4 已接）。probe `conq.prosperity_reached`/`g3.scout_*` 移引擎 dispatch 路。
- [ ] **Step 4:** import + seeded 冒煙（無 SCRIPT ERROR、征服/scout 仍現）。commit（含 Task 7 baseline）`refactor(faction_ai): dissolve prosperity cascade + del yield閘/reroute (FORCE 主 rank 征服) + gate baseline`。

### Task 7: 憲法閘 + 全回歸 + 征服率 + handback
- [ ] **Step 1:** 閘：`_evaluate_prosperity_attack` 指紋消（removed=arc 進度）；scout dispatch helper 新指紋→同 commit 更新 baseline 標 `# 序5 prosperity`。
- [ ] **Step 2:** 全回歸：
```
.\tools\godot.ps1 --headless --script scripts/debug/prosperity_dissolution_check.gd 2>&1 | Select-String "PASS|FAIL"
.\tools\godot.ps1 --headless --script scripts/debug/framework_validation.gd 2>&1 | Select-String "PASS=|DORMANT=|S3|S4"
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "seeded warring|SCRIPT ERROR|DONE"
# + threat/solo/rung/vendetta/preempt 融合驗全綠 + 憲法閘 PASS
```
Expected: 征服 6 錨 PASS、framework PASS=7（★S3 scout/S4 ambush 不 DORMANT）、全融合驗綠、閘 PASS。
- [ ] **Step 3:** ★征服率 before/after：對照 Task 0，記錄 `conq.prosperity_reached` 率 + seeded 滅團/征服/滅團潮 + seeded 漂移。判征服鏈不歸零/不暴衝。
- [ ] **Step 4:** handback `2026-07-05-wave2-prosperity-dissolution.md`：融合驗 6 錨、征服率 before/after（gen 重校依據）、seeded 漂移、連動風險（框架債縫#3 部分結清狀態、scout-verify scaffolding 位置、readiness weight vs 舊 gate 行為差、S4 誘殺是否保）。**★標記 gen 重校 follow-up 觸發**（據征服率 shift）。

## Self-Review
- Spec coverage：4a readiness weight(Task1/2)✓、4b 富prey(Task1/2)✓、4c scout-verify(Task4)✓、4d 刪cascade/yield/reroute(Task6)✓、§5 融合驗6錨(Task3/5/7)✓、§6 閘(Task7)✓。
- de-risk：Phase1 加到 parity（cascade 對照）→ Phase2 拆，避免一次炸征服鏈。
- 感知鐵律：prey/readiness/scout 讀表象+關係+self，禁 tag。
- 風險：calc_readiness/find_prosperity_prey 靜態化(Task1)、信義 penalty 落點(Task2)、scout-verify wrapper 位置(Task4)、probe 移位漏場景、征服率 shift→gen 重校(follow-up)、框架債縫#3 序5 部分/序6 全清。
- 無 placeholder：ctx/term/target/scout wrapper/刪除點全實碼或明確 file:line。
