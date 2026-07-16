# 序8：灰項 dispatch 溶入（strategic trade_net）Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 憲法溶入 arc **最後一張**。灰項唯一剩餘引擎外 task-dispatch = `strategic_ai_system::_dispatch_trade_net`（:239 try_set TASK_TRADE 繞引擎）撕除。序6 後致富 faction 成員走 `_decide_unified`→貿易 option=冗餘（同序3 rung 冗餘識別）。**溶=融合非刪**。

**Architecture:** strategic_ai=空間 affordance 層（讀 f.intent→空間 goal=合憲 ctx；encirclement/breakout/defend 只設 move_target=合憲）。唯一違憲=`_dispatch_trade_net` try_set。刪之，引擎 貿易/買糧/囤貨 option 承接致富 faction 交易（序6 成員走引擎已備）。詳 `specs` audit + baseline。

**Tech Stack:** Godot 4.2.2 GDScript；`tools/godot.ps1`；headless。

## Global Constraints
- **融合非刪**：致富 faction idle 商隊交易 repertoire 保——刪 _dispatch_trade_net 後，致富成員仍經引擎（貿易/買糧/囤貨 option）交易。驗貿易不歸零。
- **★憲法閘完成**：`_dispatch_trade_net` 指紋 removed → baseline 31→30，**8 known 違憲全溶完**（序1-8）。此後 arc 尾轉全掃常駐+撤 pre-commit（另 slice）。
- seeded 漂移允許（QA wave）；framework PASS=7（尤 S6 order/貿易魂不 DORMANT）；threat/solo/rung/vendetta/prosperity/faction-dispatch/reaction 融合驗不破；憲法閘 PASS。
- wrapper 跑測試；`>` Select-String。

## File Structure
- `scripts/simulation/strategic_ai_system.gd`（Modify）— 刪 `_dispatch_trade_net` + tick match trade_net 分支。
- `scripts/debug/greylist_dissolution_check.gd`（Create）— 融合驗（致富交易保）。
- `scripts/debug/constitution_baseline.txt`（Modify）— _dispatch_trade_net 指紋 removed。

---

### Task 0: baseline
- [ ] **Step 1:** seeded + 致富 faction 交易率：跑 framework S6（order_fulfilled）+ 量 `trade.dispatch.trade_net`（現值）+ `trade.dispatch.unified_貿易`（序6 引擎路）+ trade.deal。記錄致富 faction 成員現交易分布。seeded 記錄。commit `measure(greylist): baseline trade_net vs 引擎貿易率`。

### Task 1: 融合驗 harness（TDD-first）
**Files:** Create `greylist_dissolution_check.gd`
- [ ] **Step 1:** 寫（先確認現況）：
  - **repertoire**：致富 intent faction 的商隊成員（有 goods/coin + 市場/outpost 在）→ `rank_scored` 出貿易/買糧/囤貨（交易可達，非靠 _dispatch_trade_net）。
  - **★冗餘證**：同情境，成員經 `_decide_unified` 已選貿易 → _dispatch_trade_net 派的 TASK_TRADE 與引擎路重複（刪不損 repertoire）。
  - **gap 檢**：純買家（coin 無 goods 無 arb）致富商隊→引擎有無 option 承接（買糧/囤貨/貿易 applicable）？若 gap（idle 買家不交易）→ 記錄，可能需引擎 option applicable 微調。
- [ ] **Step 2:** Run 記錄現況。commit。

### Task 2: 刪 _dispatch_trade_net
**Files:** Modify `strategic_ai_system.gd`
- [ ] **Step 1:** 刪 `tick` 內 `"trade_net": _dispatch_trade_net(...)` match 分支（:34-35）+ `_dispatch_trade_net` 整函數（:230-243）。`_update_faction_goals` 的 `致富→trade_net goal append`（:71-74）：**保留 or 刪**？——goal 若他用（observer/其他消費）保；若只 _dispatch_trade_net 用則一併刪。實作 grep `trade_net` 確認無其他消費 → 一併清（含 goal append）。
- [ ] **Step 2:** `trade.dispatch.trade_net` probe（:242）隨函數刪。致富交易改由引擎 `trade.dispatch.unified_貿易`（序6 已有）覆蓋。
- [ ] **Step 3:** import + Run harness：致富商隊交易仍達（引擎路）。**若 Task1 揭純買家 gap** → 引擎 貿易/買糧 applicable 微調承接（記錄；或確認買糧 option 已覆蓋買家）。commit（含 Task3 baseline）`refactor(strategic_ai): dissolve _dispatch_trade_net 灰項(冗餘,引擎貿易承接) + gate baseline`。

### Task 3: 憲法閘 + 全回歸（★8 違憲全溶完）
- [ ] **Step 1:** 閘：`strategic_ai_system::_dispatch_trade_net` 指紋 removed → 更新 baseline（移除該行 + `# 序8` 標，或 header 記「8 違憲全溶完」）。sites 31→30。
- [ ] **Step 2:** 全回歸：
```
.\tools\godot.ps1 --headless --script scripts/debug/greylist_dissolution_check.gd 2>&1 | Select-String "PASS|FAIL"
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "seeded warring|SCRIPT ERROR|DONE"
.\tools\godot.ps1 --headless --script scripts/debug/framework_validation.gd 2>&1 | Select-String "PASS=|DORMANT=|S6"
# + threat/solo/rung/vendetta/prosperity/faction-dispatch/reaction 融合驗全綠
.\tools\godot.ps1 --headless --script scripts/debug/constitution_gate.gd 2>&1 | Select-String "removed|CONSTITUTION-GATE"
```
Expected: 灰項融合驗 PASS、framework PASS=7（★S6 order/貿易不 DORMANT）、全融合驗綠、閘 PASS sites=30。
- [ ] **Step 3:** 致富交易率 before/after（對照 Task 0，貿易不歸零）+ seeded 漂移。
- [ ] **Step 4:** handback `2026-07-06-wave3-greylist-dissolution.md`：融合驗、致富交易保證、gap 檢結果、seeded 漂移、**★憲法 8 違憲全溶完宣告**、arc 尾待辦（全掃常駐+撤 pre-commit）。

## Self-Review
- Spec coverage：刪 _dispatch_trade_net(Task2)✓、融合驗致富交易保(Task1/3)✓、閘 baseline(Task3)✓。
- 冗餘識別：序6 後成員走引擎貿易=_dispatch_trade_net 冗餘（同序3 rung）。
- gap 檢：純買家 case(Task1)——若引擎未承接需微調（記錄）。
- ★憲法完成：序8=最後違憲，溶完 arc 尾轉常駐撤 pre-commit。
- 風險：致富 goal append 去留(Task2 grep 確認消費)、純買家 gap、S6 魂保。
- 無 placeholder：刪除點 file:line + 驗證明確。
