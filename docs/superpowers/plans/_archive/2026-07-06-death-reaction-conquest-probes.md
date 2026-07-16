# 死因+反應+征服 winner 探針補強 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 補齊 gen 診斷缺的探針——**死因分解**（餓死/戰死/叛離縮編）+ **反應計數**（9 反應 apply）+ **征服 winner funnel**（引擎實選 loot vs 攻擊）。**純 debug/probe，零行為變**（只加 `Probe.bump` + `PROBE_KEYS`，不動任何邏輯）。藍圖 gen-direction 釘死序第①步：補 probe → 重跑 baseline → 才調 readiness。

**Architecture:** Probe.bump 加在死亡/反應/征服點；warring_harness.PROBE_KEYS 擴收。零行為變（`Probe.enabled` gated，不影響 sim）。詳藍圖 `handbacks/2026-07-06-blueprint-to-systems-gen-direction.md`。

**Tech Stack:** Godot 4.2.2 GDScript；`tools/godot.ps1`；headless。

## Global Constraints
- **零行為變鐵律**：只加 `Probe.bump`（觀測，`Probe.enabled` gated）+ PROBE_KEYS entries。**禁動任何 sim 邏輯**。seeded 49/8/1/381 必守恆、全融合驗+framework PASS=7+憲法閘不變。
- 死因分解 = pop-loss by cause（餓死/戰死/叛離 各累 pop 數）→ 給藍圖判「死亡有沒有從餓→征服位移」。
- wrapper 跑測試；`>` Select-String。

## File Structure
- `scripts/simulation/resource_system.gd`（Modify）— 餓死 probe。
- `scripts/simulation/npc_combat_system.gd`（Modify）— 戰死 probe。
- `scripts/simulation/reaction_system.gd`（Modify）— 反應計數 + 叛離縮編 probe。
- `scripts/simulation/faction_ai_system.gd`（Modify）— 滅團死因分類 probe。
- `scripts/debug/warring_harness.gd`（Modify）— PROBE_KEYS 擴收。

---

### Task 1: 死因分解 probe（餓死/戰死/叛離）
**Files:** Modify `resource_system.gd`, `npc_combat_system.gd`, `reaction_system.gd`, `faction_ai_system.gd`
- [ ] **Step 1:** 餓死（`resource_system.gd:210,220` _famine_death minor/anon 死點）：
```gdscript
# minor 死 (210 後)
if Probe.enabled: Probe.bump("death.starve_minor", md)
# anon 死 (220 後)
if Probe.enabled: Probe.bump("death.starve_anon", actually)
```
（`Probe.bump` 若不支援 count 參數則迴圈/加總——確認 Probe.bump 簽名，或用 `Probe.note`/累加。實作對齊既有 probe 用法。）
- [ ] **Step 2:** 戰死（`npc_combat_system.gd:140,177` _apply_casualties）：於 `_apply_casualties` 內 bump `death.combat_pop`（+= loss）+ named 暴斃（:75 death_chance 命中）bump `death.combat_named`。
- [ ] **Step 3:** 叛離縮編（`reaction_system.gd:269,282` N1_flee/N3_defect named remove_member）：bump `death.defect_leave`（+=1 每離隊）。（=團縮編非真死，但列「死因」第三類=人力流失。）
- [ ] **Step 4:** 滅團分類（`faction_ai_system.gd:705` _on_team_extinct）：據 team 狀態分類 bump：
```gdscript
if team.famine_days > 0: Probe.bump("extinct.starve")
elif <近戰標記/wounded>: Probe.bump("extinct.combat")
else: Probe.bump("extinct.other")
```
（famine_days>0=餓死主因；否則查 combat 標記；實作用既有 team state 判，無完美標記則盡力分類 + extinct.other 兜底。）
- [ ] **Step 5:** import 驗無 SCRIPT ERROR。commit `probe(death): 死因分解(餓/戰/叛離縮編/滅團分類) 零行為變`。

### Task 2: 反應計數 probe（9 反應 apply）
**Files:** Modify `reaction_system.gd`
- [ ] **Step 1:** `_evaluate_person` argmax 出 winner reaction 後（apply 前後）bump `reaction.<name>`（comply/produce/expand/flee/riot/defect/shirk/extort/none）。breed（平行層 :216）bump `reaction.breed`。panic bridge 已撤（序7），不補。
```gdscript
if Probe.enabled: Probe.bump("reaction." + reaction)   # reaction ∈ P1_comply/N1_flee/...
```
- [ ] **Step 2:** import + Run headless 確認 `reaction.*` 有 bump（seeded 兵卒穩定或許多為 comply/none，仍應非全 0 or 記錄）。commit `probe(reaction): 9反應apply計數(序7觀測空白補) 零行為變`。

### Task 3: 征服 winner funnel + PROBE_KEYS 擴收
**Files:** Modify `warring_harness.gd`
- [ ] **Step 1:** `PROBE_KEYS`（warring_harness:18）加（這些 bump 點已存在 code，只擴收）：
```gdscript
# 征服 winner funnel（引擎實選：loot vs 攻擊=直接看階梯）
"conq.declared", "conq.winner_loot", "conq.winner_prosperity", "conq.winner_other", "conq.winner_none",
"conq.member_atk_eligible", "conq.member_atk_dispatch",
"conq.combat_entered", "conq.combat_decisive", "conq.win_absorbed", "conq.win_no_absorb",
# 死因分解（Task1）
"death.starve_minor", "death.starve_anon", "death.combat_pop", "death.combat_named", "death.defect_leave",
"extinct.starve", "extinct.combat", "extinct.other",
# 反應計數（Task2）
"reaction.P1_comply", "reaction.P2_produce", "reaction.P4_expand", "reaction.N1_flee",
"reaction.N2_riot", "reaction.N3_defect", "reaction.N4_shirk", "reaction.N5_extort", "reaction.breed",
```
（實作對齊 reaction 名實際格式。）
- [ ] **Step 2:** import + 短跑 bed（1 seed 1 月）確認新 key 出現在 probe dict（非 miss）。commit `probe(bed): PROBE_KEYS 擴收征服winner funnel+死因+反應`。

### Task 4: 零行為變驗 + 重跑 full-probe baseline
- [ ] **Step 1:** 零行為變回歸：
```
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "seeded warring|SCRIPT ERROR"
.\tools\godot.ps1 --headless --script scripts/debug/framework_validation.gd 2>&1 | Select-String "PASS=|DORMANT="
.\tools\godot.ps1 --headless --script scripts/debug/constitution_gate.gd 2>&1 | Select-String "CONSTITUTION-GATE"
# + reaction/threat/prosperity/faction-dispatch 融合驗全綠
```
Expected: seeded **49/8/1/381 零漂移**（純 probe 加）、framework PASS=7、閘 PASS、全融合驗綠。
- [ ] **Step 2:** 重跑 full-probe multi-seed baseline（同 8 seed × 6 月，dump JSON）：
```
$env:WARRING_SEEDS='1337,42,7,100,2024,555,88,314'; $env:WARRING_MONTHS='6'; $env:WARRING_OUT='<scratchpad>/multiseed_fullprobe.json'; $env:GODOT_TIMEOUT='5400'
.\tools\godot.ps1 --headless --script scripts/debug/seeded_warring_bed.gd
```
- [ ] **Step 3:** handback `2026-07-06-death-reaction-probes.md`：零行為變證（seeded 守恆）、full-probe baseline 結果——**死因組成（餓/戰/叛離 各 seed pop 佔比）** + **conq winner 分布（loot vs prosperity）** + 反應分布。★交系統聚合報藍圖判「餓死主導?」「teams 真選 loot?」。

## Self-Review
- 純 debug/probe：只 Probe.bump + PROBE_KEYS，零 sim 邏輯變（Task4 seeded 守恆驗）。
- 死因分解=pop-loss by cause（藍圖要的餓→征服位移歸因基礎）。
- winner funnel=引擎實選（比 prosperity_reached 早一階，直接看階梯）。
- 反應計數=序7 觀測空白補。
- 風險：Probe.bump count 參數簽名(Task1 確認)、滅團分類無完美標記(extinct.other 兜底)、reaction 名格式。
- 無 placeholder：bump 點 file:line + PROBE_KEYS 明列。
