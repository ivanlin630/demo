# 受控人力統一系統 Phase 1（anon 吸收解 (a)）Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:subagent-driven-development or executing-plans. Steps use checkbox (`- [ ]`).

**Goal:** 征服勝方**吸收敗方 anon pop** 成 captive（隔離持有、低忠）→ 待遇 means-end 決策 → **厚待同化併主團 free pop（pop 累積=解 (a)）/ 苛待→暴動/逃**。征服只有「消化」才 pay → means-end 選征服 → 攀爬 pop 通。**純 anon、零跨域**（Phase 2/3 後續）。

**Architecture:** captive 持有 = holder team 上新 `captive_groups`（**非 subteam**——subteam dispatch 強制 named leader、cohort 鍵固化不可擴，純 anon captive 走 holder 上獨立結構）。複用 npc_combat 敗方結算插入 + AnonTierSystem 轉移（守恆）+ loyalty/unrest 概念 + means-end option。**(a) 解 = 同化把 captive 轉成 holder free pop（population getter 漲）。**

**Tech Stack:** Godot 4.2.2 GDScript。測試 `scripts/debug/headless_test.gd`。

## Global Constraints
- **UTF-8 wrapper**：`.\tools\godot.ps1`。worktree：每 Godot/git 前 `Set-Location`。
- **★ 守恆（最重）**：吸收=pop **轉移非憑空增**（loser anon −= 擄走、holder captive += 同量）。**全程經 AnonCohort/AnonTierSystem API**（cohort 自洽 + InvariantAudit）。captive pop **不**入 holder.anon_cohorts（非戰力）直到同化。coin_eq 0、InvariantAudit 0、pop 守恆。
- **scope guard**：**Phase 1 純 anon、零跨域**。不做 named 俘虜戲/其他 entry 通道/拷問奴役人質/guard-cap·救援 stakes（Phase 2/3）。不碰 rung2→3（獨立另案）。只 強迫類「吸收(征服)」一個 entry。
- **driver-complete 不變量**：captive batch 忠誠/狀態追得回 entry(吸收) + 待遇史（provenance）。
- **affordance 真實性**：同化/暴動/逃要真模擬（真轉 pop / 真分裂 / 真離開），非 flag。
- baseline：開工前 headless 全綠 + `climb_diagnose`（記能人 pop 崩 rung0-2）+ `warring_states_seed`（記 CONQUER=0）。

---

### Task 1: captive 資料模型 + 守恆吸收 API + npc_combat 吸收插入

**Files:**
- Modify: `scripts/data/team_data.gd`（`captive_groups` 欄）
- Modify: `scripts/simulation/anon_tier_system.gd`（`absorb_as_captive` / `assimilate_captives` 守恆轉移 API）
- Modify: `scripts/simulation/npc_combat_system.gd`（`_end_combat` 敗方結算後吸收）
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- Consumes: 敗方 team anon_cohorts、勝方 team、`AnonCohort`/`AnonTierSystem.transfer_proportional`、`CAPTURE_RATE`(TEST VALUE)。
- Produces: `team.captive_groups: Array`（每元素 = {cohorts:Dict("tier|health"→count), morale:float, origin_faction:int, entry:String}）；`AnonTierSystem.absorb_as_captive(state, holder, loser, rate)`（守恆：loser anon→holder captive_group）；`assimilate_captives(holder, group)`（captive_group cohorts→holder.anon_cohorts free pop，守恆）。

- [ ] **Step 1: 讀 team_data.gd(anon_cohorts/parent_team_id 欄、population getter) + anon_tier_system.gd(transfer_proportional 162-197、add/remove_anon) + AnonCohort(_key/add/move) + npc_combat `_end_combat`(207-290，敗方陣亡 281-285、`_try_subjugate` 290) + InvariantAudit cohort check。**

- [ ] **Step 2: 寫 failing test**
```gdscript
func _test_mp1_absorb_conserves() -> void:
	# 勝方吸收敗方 anon → captive_group；pop 守恆（loser↓ = holder captive↑）；captive 不入 holder 戰力 pop
	var state := WorldState.new()
	var winner := _mk_team(state, 10)   # helper: pop10
	var loser := _mk_team(state, 20)    # pop20
	var loser_pop0: int = loser.population
	var winner_pop0: int = winner.population
	AnonTierSystem.absorb_as_captive(state, winner, loser, 0.5)   # 擄 50% loser anon
	assert(winner.population == winner_pop0, "[mp1] captive 竟入勝方戰力 pop(該隔離)")
	assert(loser.population < loser_pop0, "[mp1] 敗方 pop 未掉(吸收非轉移)")
	var captured: int = winner.captive_groups[0].get("cohorts", {}).values().reduce(func(a,b):return a+b, 0)
	assert(loser_pop0 - loser.population == captured, "[mp1] pop 不守恆 loser掉%d != captured%d" % [loser_pop0 - loser.population, captured])
	# 同化 → captive 轉 holder free pop
	AnonTierSystem.assimilate_captives(winner, winner.captive_groups[0])
	assert(winner.population == winner_pop0 + captured, "[mp1] 同化後戰力 pop 未漲(=解 (a))")
	assert(winner.captive_groups.is_empty(), "[mp1] 同化後 captive_group 未清")
	print("[mp1] absorb conserves OK captured=%d" % captured)
```

- [ ] **Step 3: 跑測 FAIL**

- [ ] **Step 4: 實作**
`team_data.gd`：`var captive_groups: Array = []`（元素 Dict）。population getter **不**計 captive_groups（隔離；確認 getter 只投影 anon_cohorts+named）。
`anon_tier_system.gd`：
- `absorb_as_captive(state, holder, loser, rate)`：按 rate 從 loser.anon_cohorts **remove**（`AnonCohort.remove`/remove_anon，守恆）→ 組成 captive cohorts dict → `holder.captive_groups.append({cohorts, morale: CAPTIVE_INIT_MORALE, origin_faction: loser.faction_id, entry: "吸收"})`。保留來源 tier（cohorts 帶 tier|health 鍵）。
- `assimilate_captives(holder, group)`：group.cohorts 各 `AnonCohort.add(holder.anon_cohorts, tier, health, n)`（守恆，captive→free pop）→ holder.captive_groups.erase(group)。
常數：`CAPTURE_RATE`/`CAPTIVE_INIT_MORALE`(低，TEST VALUE)。
`npc_combat_system.gd` `_end_combat`：敗方陣亡結算後（~285）、erase 前，勝方 `absorb_as_captive(state, winner, loser, CAPTURE_RATE)`（勝方對敗方殘餘 anon）。encounter_system 對稱插入（敗方=攻方時，見既有 prisoner_population 處 1287-1295，對齊但走 captive_groups）。

- [ ] **Step 5: 跑測 PASS + 既有全綠 + InvariantAudit pop 守恆**

- [ ] **Step 6: Commit**
```
git add scripts/data/team_data.gd scripts/simulation/anon_tier_system.gd scripts/simulation/npc_combat_system.gd scripts/debug/headless_test.gd
git commit -m "feat(manpower): captive_groups + 守恆吸收/同化 API + npc_combat 征服吸收敗方 anon (P1)"
```

---

### Task 2: 待遇 means-end option + 同化/暴動/逃 軌跡轉換

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd` 或 decision（待遇 option：持 captive 時 leader 決厚待/苛待/釋放）
- Modify: `scripts/simulation/anon_tier_system.gd` 或新 tick（captive 軌跡：morale 閾→同化/暴動/逃）
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- Consumes: holder.captive_groups、leader values（仁慈/貪婪/殘忍→待遇傾向）、morale 閾值。
- Produces: 待遇決策（每 cadence 對 captive batch 設待遇 → morale delta，driver 連回意圖）；captive tick：morale≥ASSIM_T→assimilate（同化）、morale≤REVOLT_T→暴動（複用 unrest 分裂效果，captive 脫離+可能反咬）、機會+低 morale→逃（部分離開）。

- [ ] **Step 1: 讀 means-end `_update_goals`/option 框架（commander-v2）+ event_unrest_split(`_split_team` 效果) + loyalty/unrest_bank。**

- [ ] **Step 2: 寫 failing test**
```gdscript
func _test_mp1_treatment_trajectory() -> void:
	# 厚待 → morale 升 → 同化（captive→free pop）；苛待 → morale 崩 → 暴動/逃（captive 離開，pop 不白增）
	# (a) 厚待路徑
	var s1 := WorldState.new(); var h1 := _mk_holder_with_captive(s1, 8)  # helper: holder + 1 captive group pop8
	for i in 20: ManpowerSystem.tick_captives(s1, h1, "厚待")   # 厚待 cadence
	assert(h1.captive_groups.is_empty() and h1.population includes assimilated, "[mp1] 厚待未同化")
	# (b) 苛待路徑 → 暴動/逃（captive 離開、不併入）
	var s2 := WorldState.new(); var h2 := _mk_holder_with_captive(s2, 8)
	var h2_pop0 := h2.population
	for i in 20: ManpowerSystem.tick_captives(s2, h2, "苛待")
	assert(h2.population == h2_pop0, "[mp1] 苛待竟白增 pop(該暴動/逃非同化)")
	print("[mp1] treatment trajectory OK")
```
> ManpowerSystem 命名/位置 plan 定（新檔 `scripts/simulation/manpower_system.gd` vs 併 anon_tier）。待遇 driver=means-end（征服意圖→厚待壯大）。

- [ ] **Step 3: 跑測 FAIL**

- [ ] **Step 4: 實作**
- **待遇 means-end option**：holder 持 captive 時，leader 決策加「待遇」面——厚待(仁慈/野心欲壯大)/苛待(殘忍/急用)/釋放(無力養)。driver=服務意圖（征服→厚待同化壯兵）。LOD：anon batch default（Phase 1 不個別）。**接 commander-v2 means-end**（option 集擴，driver tagging）。
- **captive tick 軌跡**（morale 閾，守恆）：
  - morale ≥ `ASSIM_T` → `assimilate_captives`（同化併 free pop）。
  - morale ≤ `REVOLT_T` → 暴動：captive cohorts 脫離 holder（`AnonCohort.remove`），部分成獨立隊/部分戰損（複用 `_split_team` 效果概念，守恆——脫離非消失）；觸 holder unrest。
  - 機會（holder 弱/無看管）+ 低 morale → 逃（部分 captive remove → 流民隊或消，守恆路由）。
- 待遇逐 tick 改 morale（厚待+、苛待−但 Phase 3 才接勞動產出）。

- [ ] **Step 5: 跑測 PASS + 既有全綠（守恆：暴動/逃 = pop 轉移非憑空消）**

- [ ] **Step 6: Commit**
```
git add scripts/simulation/*.gd scripts/debug/headless_test.gd
git commit -m "feat(manpower): 待遇 means-end option + 同化/暴動/逃 軌跡(morale 閾,守恆) (P1)"
```

---

### Task 3: believability + 戰國 seed (a) 量測 + 守恆/framework

**Files:** Test + 量測（climb_diagnose/warring_states_seed 重跑）

- [ ] **Step 1: 寫 believability 測**（苛待→暴動非白吃、厚待→同化壯大、吸收守恆、captive 不算戰力直到同化）。
- [ ] **Step 2: 跑測 PASS。**
- [ ] **Step 3: (a) 量測——climb_diagnose + warring_states_seed 重跑**
```
.\tools\godot.ps1 --headless --script scripts/debug/climb_diagnose.gd
GODOT_TIMEOUT=3000 ... warring_states_seed.gd   （背景）
```
驗：**征服 pay**（吸收同化→能人 pop 不再只崩、累積）、**CONQUER 0→小正**（means-end 選征服變划算）、**不 over-war**（苛待暴動/guard 成本壓過頻征服——Phase 1 暫靠暴動風險）、pop 守恆。記數據（能人最高 rung 是否突破 rung2 受益於 pop 累積；CONQUER 次數）。
- [ ] **Step 4: framework + 守恆**
```
.\tools\godot.ps1 --headless --script scripts/debug/framework_validation.gd
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd
```
S1-S6 PASS、coin_eq 0、InvariantViolation 0（**pop 守恆關鍵**）。
- [ ] **Step 5: Commit。**

---

## 完成後（子 session）
1. push `feat/controlled-manpower-phase1`。
2. handback：改檔 + 與 spec/plan 差異 + **(a) 量測（征服 pay 否/CONQUER 0→?/能人 pop 累積否/不 over-war 否）** + 守恆驗證（吸收/同化/暴動 pop 守恆）+ HOW 差異說明（captive_groups 非 subteam，因 anon-only + cohort 鍵約束）+ 連動風險（npc_combat 插入對既有戰鬥測、population getter 不計 captive、暴動複用）+ 待確認（CAPTURE_RATE/morale 閾、Phase 2 named 俘虜起點、rung2→3 另案）。
3. finishing → Option 3，主 session merge。

## Self-Review（主 session）
- spec 範圍（Phase 1 純 anon/零跨域、只吸收 entry、不碰 rung2→3）→ 全 Task 對齊。
- **守恆**（最重）= 吸收/同化/暴動/逃全經 cohort API、pop 轉移非憑空 → Task 1/2 守恆測 + Task 3 InvariantAudit。
- **(a) 解** = 同化→holder free pop 漲（population getter）→ 征服 pay → Task 3 戰國 seed CONQUER 0→小正 + 能人 pop 累積。
- **HOW 差異**（captive_groups 非 subteam）= anon-only + cohort 鍵約束的 HOW 實現；Phase 2 named 俘虜可引 captive subteam。handback 報藍圖知會。
- **driver-complete** = 待遇 driver 連回意圖 + captive morale 追得回 entry+待遇史。
- 風險：npc_combat 插入碰既有戰鬥/loot 測（吸收在陣亡後、erase 前，確認不破 loot/feud/敗損對稱）；population getter 改（確認 captive 不計戰力不破既有 pop 讀者）。
