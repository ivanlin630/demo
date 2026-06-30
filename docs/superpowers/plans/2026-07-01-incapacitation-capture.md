# 失能-capture 統一（戰不決勝 fix）Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:subagent-driven-development or executing-plans. Steps use checkbox (`- [ ]`).

**Goal:** 修 (a) 上游真因「戰鬥不決勝」——NPC 戰**潰逃時勝方控地俘敗方 wounded 一比例**（非等近全滅）。→ P1 captive 吸收終於 fire（從 `_end_combat`[never fire] 改 `_force_retreat`[常見退出]）→ 同化壯大 → **征服 pay** → 征服者湧現。承藍圖 spec §3b（失能者被俘=控地權，確定性非 RNG）。

**Architecture:** measure 證 NPC 戰 0 擊潰（撤退先於殲滅），P1 吸收掛 `_end_combat` 故 dormant。fix=**`_force_retreat`（潰逃路徑）勝方俘 retreater wounded 一比例 → captive_groups（P1 結構複用）**。俘虜比例=`wounded × 潰逃嚴重度 × guard 餘力`（確定性）。**「決勝在潰逃非對撞」**。複用 P1 captive_groups/待遇/同化（已 merge）。存儲統一 prisoner_population（encounter）→ 同 captive 表示。

**Tech Stack:** Godot 4.2.2 GDScript。測試 `scripts/debug/headless_test.gd`。

## Global Constraints
- **UTF-8 wrapper**：`.\tools\godot.ps1`。worktree：每 Godot/git 前 `Set-Location`。重型 `GODOT_TIMEOUT=NNNN`(bash prefix)。
- **★ 守恆（命脈，碰 pop）**：俘 wounded = **轉移非憑空**（retreater wounded cohort remove == winner captive add，全經 `AnonCohort`/`AnonTierSystem`）。captive 不入 winner population（隔離，P1 既有）。coin_eq 0、InvariantViolation 0、pop 守恆。
- **★ 確定性非 RNG**（driver-complete：俘因=敵控地+guard 餘力）。
- **scope guard**：只 `npc_combat _force_retreat` 俘 wounded + 複用 P1 captive_groups + 存儲統一 + 測。**不碰** `_end_combat` 既有 absorb（P1 留，雙路徑皆吸收）、不碰戰鬥決勝門檻（否 #2 放寬殲滅）、不碰 REGEN/食物/G3。**不做** named 俘虜戲/guard-cap/救援 stakes（Phase 2）。E-2 投降=後續。
- baseline：開工前 headless 全綠 + `warring_states_seed`（記 P1Absorb=0/p1.assimilate=0）。

---

### Task 1: `_force_retreat` 俘 wounded 比例 → captive_groups

**Files:**
- Modify: `scripts/simulation/anon_tier_system.gd`（`capture_wounded_as_captive` 守恆 API，俘 wounded 子集）
- Modify: `scripts/simulation/npc_combat_system.gd`（`_force_retreat` 插入俘虜）
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- Consumes: retreater.wounded（wounded health cohorts）、retreater.readiness（潰逃嚴重度）、winner pop_cap 餘力、`AnonCohort`（remove wounded / add captive）。
- Produces: `AnonTierSystem.capture_wounded_as_captive(state, winner, retreater) -> int`（守恆：retreater wounded cohort remove → winner.captive_groups entry="失能-capture"）；`_force_retreat` 呼叫之。

- [ ] **Step 1: 讀 npc_combat `_force_retreat`(296-318, 現 _apply_pursuit+_try_subjugate) + P1 `absorb_as_captive`(anon_tier，captive_group 結構/守恆 pattern) + AnonCohort wounded 鍵("tier|wounded") + readiness/pop_cap。**

- [ ] **Step 2: 寫 failing test**
```gdscript
func _test_cap_retreat_captures_wounded() -> void:
	var state := WorldState.new()
	var winner := _mk_team(state, 20)   # guard 餘力足
	var loser := _mk_team_with_wounded(state, 15, 8)  # pop15, wounded8
	loser.readiness = 0.1   # 潰逃(低 readiness=嚴重)
	var w_pop0 := winner.population
	var loser_wnd0 := loser.wounded
	var captured := AnonTierSystem.capture_wounded_as_captive(state, winner, loser)
	assert(captured > 0, "[cap] 潰逃未俘 wounded")
	assert(winner.population == w_pop0, "[cap] 俘虜竟入勝方戰力(該隔離)")
	assert(loser.wounded == loser_wnd0 - captured, "[cap] wounded 不守恆 loser掉%d != captured%d" % [loser_wnd0-loser.wounded, captured])
	# 入 captive_groups + entry 標記
	assert(winner.captive_groups.size() > 0 and winner.captive_groups[-1].get("entry") == "失能-capture", "[cap] 俘虜未入 captive_group")
	# 確定性:同輸入同俘虜數
	var s2 := WorldState.new(); var w2 := _mk_team(s2,20); var l2 := _mk_team_with_wounded(s2,15,8); l2.readiness=0.1
	assert(AnonTierSystem.capture_wounded_as_captive(s2,w2,l2) == captured, "[cap] 非確定性(RNG?)")
	# guard 滿 → 俘不下
	var winner_full := _mk_team(state, 1)  # 無餘力
	assert(AnonTierSystem.capture_wounded_as_captive(state, winner_full, _mk_team_with_wounded(state,15,8)) == 0, "[cap] guard 滿仍俘")
	print("[cap] retreat captures wounded OK captured=%d" % captured)
```

- [ ] **Step 3: 跑測 FAIL**

- [ ] **Step 4: 實作**
`anon_tier_system.gd` `capture_wounded_as_captive(state, winner, retreater)`：
```
俘虜比例 rate = clamp((1 − retreater.readiness)[潰逃嚴重度] × CAPTURE_GUARD_FACTOR, 0, CAPTURE_RATE_MAX)
guard 餘力 cap = max(0, winner pop_cap − winner.population − total_captives(winner))  # 守衛容量
captured_n = min(round(retreater.wounded × rate), guard 餘力 cap)
從 retreater 的 wounded health cohorts remove captured_n（按 tier 比例，AnonCohort.remove "tier|wounded"，守恆）
→ winner.captive_groups.append({cohorts: 擄走 wounded cohorts, morale: CAPTIVE_INIT_MORALE, origin_faction, entry:"失能-capture", treatment_history:[]})
回 captured_n（確定性：無 randf）
```
常數 `CAPTURE_GUARD_FACTOR`/`CAPTURE_RATE_MAX`（TEST VALUE）。
`npc_combat _force_retreat`：`_apply_pursuit` 後加 `var _cap := AnonTierSystem.capture_wounded_as_captive(state, pursuer_id_team, retreater)`（pursuer=控地勝方）+ print `[Capture]`。
> 註：retreater 被俘的是 wounded（失能者，潰逃丟下）；healthy 隨隊撤走（不俘）。

- [ ] **Step 5: 跑測 PASS + 既有全綠**（既有 _force_retreat/_end_combat/loot/敗損測不破；P1 captive 測不破）

- [ ] **Step 6: Commit**
```
git add scripts/simulation/anon_tier_system.gd scripts/simulation/npc_combat_system.gd scripts/debug/headless_test.gd
git commit -m "feat(combat): 失能-capture — 潰逃勝方俘敗方 wounded 比例→captive(決勝在潰逃,P1 吸收 fire) (incap-capture)"
```

---

### Task 2: 存儲統一（prisoner_population → captive_groups）+ (a) 量測

**Files:**
- Modify: `scripts/simulation/encounter_system.gd`（prisoner_population → captive_groups，存儲統一）— **若耦合大則本 Task 標 Phase 2、只驗 NPC 路徑解 (a)**
- Test + 量測

- [ ] **Step 1: 評估 prisoner_population 統一成本**：encounter `is_prisoner`/`prisoner_population` 路徑改存 captive_groups。**若改動大/碰 player UI → 本塊不做、記 Phase 2**（spec §3b 存儲統一可後續；(a) 靠 NPC retreat capture 已解）。**先驗 NPC 路徑解 (a)，存儲統一視成本決定。**

- [ ] **Step 2: (a) 量測——warring_states + climb 重跑**
```
GODOT_TIMEOUT=3000 ... warring_states_seed.gd  （背景）
GODOT_TIMEOUT=2500 ... climb_diagnose.gd       （背景）
```
驗：戰鬥潰逃 → `[Capture]` fire → **p1.assimilate > 0**（吸收終於活）→ **CONQUER 0→小正**（征服 pay→means-end 選征服）→ 征服隊 pop 累積/能人爬 rung。**不 over-war**（guard-cap 暫缺，靠俘虜消化成本+暴動風險自然壓；過頻記 Phase 2 guard-cap）。

- [ ] **Step 3: 守恆 + framework**
```
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd
.\tools\godot.ps1 --headless --script scripts/debug/framework_validation.gd
```
coin_eq 0、InvariantViolation 0（**wounded 俘虜守恆關鍵**）、S1-S6 PASS。
- [ ] **Step 4: Commit。**

---

## 完成後（子 session）
1. push `feat/incapacitation-capture`。
2. handback：改檔 + **(a) 量測（[Capture] fire 否/p1.assimilate>0 否/CONQUER 0→? /征服 pay 否/over-war 否）** + 守恆（wounded 俘虜 pop 守恆）+ 存儲統一做了否（或標 Phase 2）+ 連動風險（_force_retreat 插入對既有撤退/pursuit、captive 不計 population、guard 餘力公式）+ 待確認（CAPTURE_GUARD_FACTOR/RATE_MAX 量級、guard-cap stakes Phase 2、prisoner_population 統一）。
3. finishing → Option 3，主 session merge。

## Self-Review（主 session）
- **修 (a) 上游** = 潰逃俘虜（決勝在潰逃非對撞）→ P1 吸收 fire（Task 2 p1.assimilate>0）。
- **守恆** = wounded cohort remove==captive add（cohort API）→ Task 1 守恆測 + Task 2 InvariantViolation 0。
- **確定性** = 無 randf（Task 1 確定性測）。
- **複用 P1** = captive_groups/待遇/同化（已 merge），本塊只加 entry 通道（俘虜）。
- 風險：_force_retreat 插入碰既有撤退/pursuit（確認不破敗損對稱）；over-war（無 guard-cap）→ seed 量，過頻 Phase 2 guard-cap；存儲統一成本（prisoner_population）→ 大則 Phase 2。
