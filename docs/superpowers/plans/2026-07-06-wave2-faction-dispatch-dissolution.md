# wave2 序6：faction member dispatch 溶入引擎 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `_assign_member_tasks` goal→task if/elif 判斷器（含 V2-cmd 徵收 shadow 攻擊）撕除 → faction 成員走 `_decide_unified`（引擎 rank_scored 競秤）。**溶=融合非刪**。副產物：V2-cmd 自消 + 成員打草穀 raid 接回（序5 待項）+ 框架債縫#3 結清。

**Architecture:** ★只改**成員 dispatch gate**（`_assign_member_tasks:1394` 從 `uses_unified` 改 `parent_team_id==-1`），**不動全域 `uses_unified`**（保 threat/preempt/survival loop3 scaffolding，不破序3.5）。faction goal→engine 橋已建（faction_stakes→faction_duty term）。leader dispatch=序6b defer。詳 `specs/2026-07-06-wave2-faction-dispatch-dissolution.md`。

**Tech Stack:** Godot 4.2.2 GDScript；`tools/godot.ps1`；headless SceneTree。

## Global Constraints
- **融合非刪**：repertoire——成員各 goal→對應 option（徵收/外交/攻擊/生產/貿易/**掠奪=raid**）；V2-cmd 解（徵收+攻擊雙 goal→好戰成員攻擊可勝，非恆被徵收支配）；成員 raid 接回（弱 prey→掠奪）。
- **★序3.5 preempt 不破（最高盯點）**：不動全域 uses_unified → 成員仍走 loop3 `_evaluate_threat` 非-unified 路 → 忙碌成員遇壓境仍 preempt。反龜縮 seam 保。
- **感知鐵律**：成員決策讀 belief 表象+known relations+faction goal（ctx.faction_stakes），禁讀對方 tag。
- seeded 漂移允許（QA wave；成員 raid+V2-cmd→分佈變，gen 重校=序6 後完整圖）；framework PASS=7（S1-S6，尤 S1/S2/S3 不 DORMANT）；threat/solo/rung/vendetta/preempt/prosperity 融合驗+live-seam 不破；憲法閘 PASS。
- wrapper 跑測試；`>` Select-String；`--import` 新 class。

## File Structure
- `scripts/simulation/faction_ai_system.gd`（Modify）— 成員 dispatch gate + 刪 cascade + probe 遷移。
- `scripts/debug/faction_dispatch_dissolution_check.gd`（Create）— 融合驗（repertoire + V2-cmd + raid + preempt-preserved）。

---

### Task 0: baseline（★V2-cmd shadow + 成員 raid 錨）
- [ ] **Step 1:** seeded + framework S1-S3 + V2-cmd 探針：跑 headless + framework，記 seeded 52/8/1/380、S1/S2/S3 PASS。跑暫時 bed 量 `conq.member_atk_eligible`/`conq.member_atk_dispatch`（V2-cmd 斷點：eligible>0 但 dispatch≈0=shadow 確證）+ 成員掠奪率（現≈0=raid 缺）。記錄。commit `measure(faction-dispatch): baseline V2-cmd shadow + 成員 raid 缺`。

### Task 1: 融合驗 harness（TDD-first）
**Files:** Create `faction_dispatch_dissolution_check.gd`
- [ ] **Step 1:** 寫（先失敗）：
  - **repertoire**：faction 成員（各 goal+人格）→ `rank_scored` 出對應：徵收 goal+貪婪→徵收；攻擊 goal+好戰→攻擊；外交 goal→外交；生產/貿易 tag→本業。
  - **★V2-cmd 解**：faction {徵收,攻擊} 雙 goal + 好戰成員 → `rank_scored[0]` 可為攻擊（非恆徵收）。
  - **★成員 raid**：faction 成員 + 弱 prey → rank 含掠奪可達。
  - **★preempt 保**：忙碌成員（TASK_MANUFACTURE，軍隊 tag=非 MERCHANT/PRODUCE）+ 壓境攻擊 → `_evaluate_threat` 仍 preempt（沿用 threat_preempt_check 邏輯，證成員非-unified 路 preempt 活）。
- [ ] **Step 2:** Run，repertoire/raid/V2-cmd 部分 FAIL（成員仍走 hand-dispatch）、preempt PASS（未動）。commit。

### Task 2: 成員 dispatch gate + 刪 cascade
**Files:** Modify `faction_ai_system.gd`
- [ ] **Step 1:** `_assign_member_tasks:1394` gate 改：
```gdscript
# 原 if uses_unified(mt): _decide_unified(state, mt); continue
if mt.parent_team_id == -1:   # 全非-subteam 成員走引擎 macro（subteam 走 loop2）
    _decide_unified(state, mt)
    continue
```
- [ ] **Step 2:** 刪成員 non-unified cascade（1405-1465 的 if/elif goal dispatch）。**MERGE consolidate（1410-1433）**：保留評估——`_find_absorber`/近 leader 攻擊 goal MERGE=faction 整併機制（非個體決策）→ 保為 dispatch 前置 scaffolding（gate 前跑，命中則 pre-empt engine）or 移 engine option。實作裁：**保 scaffolding**（MERGE 前置於 gate，鏡射 survival-sticky），記錄。
- [ ] **Step 3:** import + Run harness：repertoire/V2-cmd/raid 轉 PASS、preempt 仍 PASS。commit `feat(faction_ai): faction 成員走引擎_decide_unified (V2-cmd自消+raid接回,不動全域uses_unified保preempt)`。

### Task 3: probe 遷移 + framework/harness 更新
**Files:** Modify `faction_ai_system.gd`, `framework_validation.gd`, `headless_test.gd`
- [ ] **Step 1:** probe 遷移：`conq.member_atk_eligible/dispatch`（1449/1454，hand-dispatch 已刪）→ 引擎 dispatch 路（`_decide_unified` 攻擊 winner bump）；`trade.dispatch.member_trade`（1465）→ `trade.dispatch.unified_貿易` 已有則移除舊；徵收 tribute 補 probe（`_decide_unified` 徵收 dispatch bump，供驗魂）。
- [ ] **Step 2:** framework S1-S3 確認不破（用 leader/獨立 fixture，不依賴成員 hand-dispatch）。若某 souls 依賴已刪 probe → 遷移 assertion。headless 成員 dispatch 單元測遷移/退役（依賴 hand-dispatch cascade 者）。
- [ ] **Step 3:** import + framework PASS=7。commit `test: probe 遷移引擎路 + framework/headless 成員dispatch測遷移`。

### Task 4: 全回歸 + 序3.5 preempt 驗 + 憲法閘
- [ ] **Step 1:** 全驗：
```
.\tools\godot.ps1 --headless --script scripts/debug/faction_dispatch_dissolution_check.gd 2>&1 | Select-String "PASS|FAIL"
.\tools\godot.ps1 --headless --script scripts/debug/threat_preempt_check.gd 2>&1 | Select-String "ALL PASS|FAIL"
.\tools\godot.ps1 --headless --script scripts/debug/framework_validation.gd 2>&1 | Select-String "PASS=|DORMANT="
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "seeded warring|SCRIPT ERROR|DONE"
# + threat/solo/rung/vendetta/prosperity 融合驗全綠
.\tools\godot.ps1 --headless --script scripts/debug/constitution_gate.gd 2>&1 | Select-String "removed|新增|CONSTITUTION-GATE"
```
Expected: 成員 dispatch 融合驗 PASS（含 V2-cmd/raid/preempt）、**threat_preempt ALL PASS（序3.5 未破）**、framework PASS=7、全融合驗綠、閘處理。
- [ ] **Step 2:** 憲法閘 baseline：`_assign_member_tasks` try_set 全刪 → 指紋 removed（arc 進度）；`_decide_unified` 已在 baseline。同 commit 更新 baseline 標 `# 序6 dispatch`。
- [ ] **Step 3:** ★征服/掠奪率 before/after：對照 Task 0，記 V2-cmd 解後攻擊率、成員 raid 率、seeded 漂移。**框架債縫#3 結清確認**（成員不再 loop3-idle-gate 依賴）。commit（含 baseline）。

### Task 5: handback
- [ ] **Step 1:** handback `2026-07-06-wave2-faction-dispatch-dissolution.md`：融合驗結果、V2-cmd 解證、成員 raid 接回率、序3.5 preempt 保證、seeded 漂移、縫#3 結清、連動風險（MERGE scaffolding 去留、probe 遷移覆蓋、leader dispatch 序6b 待、gen 重校 follow-up 觸發=完整征服圖）。

## Self-Review
- Spec coverage：3a 成員 gate(Task2)✓、3b 刪 cascade(Task2)✓、3c V2-cmd 自消(Task1/4 驗)✓、3d raid 接回(Task1/4)✓、3e probe 遷移(Task3)✓、§4 融合驗(Task1/4)✓、§5 閘(Task4)✓。
- ★不破序3.5：不動全域 uses_unified，成員 loop3 threat/preempt 保（Task1/4 preempt 驗）。
- subteam guard：`parent_team_id==-1`（Task2）。
- 感知鐵律：成員讀 faction_stakes/belief，禁 tag。
- 風險：MERGE scaffolding 去留(Task2 保)、probe 遷移漏 souls(Task3)、成員 macro vs loop3 冗餘(Task4 驗無衝突)、leader dispatch 序6b、gen 重校 follow-up。
- 無 placeholder：gate 改/cascade 刪/probe 遷移全實碼或明確 file:line。
