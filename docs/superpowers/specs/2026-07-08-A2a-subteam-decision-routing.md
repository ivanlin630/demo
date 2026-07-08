# A2a Spec（revised v2）— 子隊決策納統一框架（母團 directive + faction_duty，零子隊補丁）

- from: systems
- slice: A2a
- 工單: `docs/superpowers/handbacks/2026-07-08-blueprint-to-systems-A2a-工單.md`
- ★裁定: `docs/superpowers/handbacks/2026-07-08-blueprint-to-systems-A2a-revise.md`（藍圖對 review 的裁定，優先於 review 字面）
- 依賴: A1a（引擎內閥 source-gate + 成員縫已清）
- 憲法連動: 「行為=引擎輸出」；「身分=權重非路徑切換」（子隊=權威關係=term，非分支）

## 問題（現況，已 grep 重驗 2026-07-08）

子隊（`parent_team_id != -1`）task 決策**手寫 argmax + randf 繞引擎**（`HandBrainProbe.note_bypass(sub,"subteam")` 自標），A1a 後剩最大宗手不聽腦。兩落點：

1. **`faction_ai_system.gd:1688 _evaluate_idle_subteam`**：`scores={回歸:0.3, LOOT:(greed·0.5+martial·0.2)·_tag_weight, ATTACK:(martial·0.4+greed·0.2)·_tag_weight}` → 手 argmax → `try_set(...,"subteam_idle")`。
2. **`faction_ai_system.gd:1669 _check_deviation`**：`greed·(1-loyalty)·DEVIATION_RATE` randf → 手選 `_nearest_independent` → `try_set(TASK_LOOT,...,"deviation")`。

對照乾淨縫：成員 `_assign_member_tasks:1428→_decide_unified→rank_scored`；solo `_evaluate_solo:1749`。

## ★裁定方向（藍圖 revise，取代 v1 子集 narrowing）

v1 用 `SUBTEAM_OPTION_SET={掠奪,攻擊}` 子集——**藍圖否決**：那是換一組更窄的觸發前提（悄砍攻擊 repertoire）非「行為忠實」，且逐 tick 全量 gather 無效能檢查。改為：

- **A2a = 拆補丁不是加補丁**：子隊決策移進統一 `DecisionEngine`（REGISTRY Σ term×weight argmax），**走全框架 row/term/gate，零 bypass 補丁**。
- **攻擊窄化＝對的（修 bug，明示接受）**：無紀律軍隊不會沒命令亂打敵人。子隊=紀律執行者，不自宣戰。攻擊只經 **faction 攻擊令**（inherited faction_stakes）**或血仇**（feud_pull），**不由裸 martial 分驅動**。`intent==征服` 結構性走不到子隊（只 faction leader 決定開戰）=設計正確。
- **★紅線：紀律=通用維度，複用既有 loyalty/duty，禁子隊專屬 term/分支。** 母團命令建模成 **directive（結構鏡射 faction_stakes）→ 被命令 option 拿 `faction_duty` weight**；`faction_duty` 已 key 在 `_loyalty`（`terms.gd:202` `_duty_factor(loy,野心)`）→ 忠誠子隊聽令、不忠→掠奪贏。一套 duty/loyalty 管 faction 成員 + 子隊，**子隊零特例分支**。

## 設計決定（HOW，全框架 row/term/gate）

### D1. 母團 directive 進 ctx（結構鏡射 faction_stakes）

`decision_context.gd` 加欄（≈ line 64 faction_* 欄後）：
```
var has_parent_directive: bool = false   # 有母團 → 服從母團命令（= 歸建 directive）
var parent_team_pos: Vector2i = Vector2i(-1, -1)
```
`gather()` 填（鏡射 faction_stakes block ≈ 195-213，`team.parent_team_id != -1` 時）：
```
if team.parent_team_id != -1:
	var _pt: TeamData = state.teams.get(team.parent_team_id)
	if _pt != null:
		c.has_parent_directive = true
		c.parent_team_pos = _pt.tile_pos
```
- 子隊**同時 inherit faction_id → faction_stakes 照常填**（195-213）：warring faction 子隊自動拿 攻擊 directive（faction_duty）——攻擊紀律化免額外碼。
- 非子隊 `has_parent_directive=false` → 下述 歸建 option / gate 對其無效（零成員/solo 行為變）。

### D2. 「歸建」= 服從母團 option（faction_duty 驅，通用 row）

`options.gd`：
- REGISTRY 加 row（`歸建`＝服從權威/回母團集結，duty 驅）：
  ```
  "歸建": [["faction_duty", "faction_duty"]],
  ```
- `applicable`（≈ 44 loop 內）加：
  ```
  "歸建":
  	if ctx.has_parent_directive: out.append(opt)
  ```
- `to_task`：`歸建` 由 `_decide_subteam` 特判（lifecycle move，見 D4），不進 `to_task` 標準派工；為安全加 fallback `"歸建": return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1,-1)}`。

`terms.gd` `faction_duty` eval（`terms.gd:100-106` match）加 case：
```
"歸建": return FACTION_DUTY_DRIVE if ctx.has_parent_directive else 0.0
```
- weight 已 `_duty_factor(_loyalty, 野心)`（`terms.gd:202`）→ 歸建 util = `_duty_factor × FACTION_DUTY_DRIVE(1.5)`。忠誠高→歸建 util 高（聽令回母團）；低忠高野→`_duty_factor→0`→歸建塌，掠奪（greed×loot weight）贏。**＝現況 `_check_deviation` greed·(1-loyalty) 語意，搬進框架用同一 duty 機制，零新 term。**

### D3. 子隊不自立/佔據點（世界規則 gate，非 suppress 分支）

全 `rank_scored` 會讓子隊碰 `建設`（options.gd:55 無條件 applicable）/`佔村`（有 target 即候選）＝自建/奪據點=生命週期突變（工單護欄禁；invariants「立國=leader-level」）。`options.gd` applicable 兩 row 加**世界規則**謂詞（附屬單位無自主權立據，非「if subteam suppress」）：
```
"建設": if not ctx.has_parent_directive: out.append(opt)   # 現為無條件 append
"佔村": ... and not ctx.has_parent_directive:               # 現有 pop/outpost 條件末 AND
```
- 成員/solo `has_parent_directive=false`→`not false=true`→**行為零變**。只子隊被擋自立據。
- `生產/駐守`（`has_own_outpost` gated，子隊無自家 outpost）/`囤貨`（`intent==致富` gated，子隊 intent 空）**已自然排除**，無需加 gate。

### D4. 新 `_decide_subteam`（引擎 dispatch，cadence-gated，鏡射 `_decide_unified` 尾）

`faction_ai_system.gd` 新 func（取代 `_check_deviation` + `_evaluate_idle_subteam`）：
```
func _decide_subteam(state: WorldState, sub: TeamData, merge_queue: Array) -> void:
	# ★D5 cadence gate（效能）：子隊決策非逐 tick，比照 threat cadence
	if state.world.current_tick < sub.subteam_eval_next_tick:
		return
	sub.subteam_eval_next_tick = state.world.current_tick + SUBTEAM_CADENCE
	var parent: TeamData = state.teams.get(sub.parent_team_id)
	if parent == null:
		return
	var leader_p = state.persons.get(sub.leader_id)
	if leader_p == null:
		sub.move_target = parent.tile_pos   # 無腦 → 回家（lifecycle，不 capture）
		return
	var ranked: Array = DecisionEngine.rank_scored(state, sub)   # 全框架 rank（含 faction_stakes/threat/掠奪/歸建）
	for e in ranked:
		var opt: String = e["opt"]
		# ★歸建 = 服從母團 = lifecycle move（回母團集結/歸建），不進 obey/violation 統計（量測特判）
		if opt == "歸建":
			sub.current_option = opt
			sub.move_target = parent.tile_pos
			merge_queue.append(sub.team_id)   # 到家由 loop2b try_merge_back
			return
		var td: Dictionary = DecisionOptions.to_task(state, sub, opt)
		if td.get("task", TeamData.TASK_IDLE) == TeamData.TASK_IDLE:
			continue
		var tgt: Vector2i = td["target"]
		if tgt == Vector2i(-1, -1) and td["task"] != TeamData.TASK_FLEE:
			continue
		if not TaskArbiter.try_set(state, sub, td["task"], tgt, TaskArbiter.PRIO_DISPATCH, "subteam"):
			continue
		if td.has("combat_target"): state.set_combat_target(sub, int(td["combat_target"]))
		if td.has("social_target"): state.set_social_target(sub, int(td["social_target"]))
		_wire_threat_task(sub, td)   # 迎戰/求和 aux target（threat repertoire 保留）
		sub.current_option = opt      # 承諾慣性（COMMITMENT_BONUS 讀，防抖動）
		HandBrainProbe.capture(state, sub, "subteam", String(ranked[0]["opt"]), opt, td["task"], true)
		print("[SubAI] Team%d 引擎→%s (%s)" % [sub.team_id, td["task"], opt])
		return
	# 全不可派 → 回母團（lifecycle，不 capture）
	sub.move_target = parent.tile_pos
```
- **子隊非自主征服者**：`intent` 空 + `faction_id!=-1` → `_decide_unified` 的 conquest 分支（`_solo_type=="征服" and faction_id==-1`）結構性不觸 → `_decide_subteam` 無需鏡射 conquest scaffolding（簡化）。
- **threat repertoire 保留**：full rank 含 `備戰/迎戰/求和`（threat-gated applicable）→ 紀律單位遇襲還手（藍圖要保）。
- **掠奪 loyalty-gated 湧現**：歸建(duty)↔掠奪(greed) 同 rank 競秤；忠誠→歸建、不忠→掠奪，**非 patch 掠奪 term**（掠奪 term 零變，成員/solo 掠奪不受影響）。

### D5. cadence gate（效能，藍圖 review #2）

- `TeamData` 加欄 `subteam_eval_next_tick: int = 0`（鏡射 `threat_eval_next_tick`）。
- `faction_ai_system.gd` 加 `const SUBTEAM_CADENCE: int = TimeScale.TICK_PER_DAY * 1`（1 日，鏡射 `THREAT_CADENCE`）。
- gate 在 `_decide_subteam` 頭（見 D4）——**只 gate 重量級 gather+rank**；`_evaluate_subteam` 的 O(1) lifecycle guard（envoy/build/settle/escort/discipline/merge-on-arrival）仍逐 tick（責任性）。
- 效果：`DecisionContext.gather`（掃全 tiles/finders）從逐-tick-per-subteam → 每 subteam 1 日一次，攤平 per-tick 成本。

### D6. `_evaluate_subteam` tail 改寫（1627-1635）

```
	if _check_discipline(state, sub):
		return
	# 抵達目標格 → 歸建（lifecycle，不進引擎/probe）
	if sub.move_target == Vector2i(-1, -1) and sub.current_task != TeamData.TASK_IDLE:
		merge_queue.append(sub.team_id)
		return
	# idle → 引擎決策（cadence-gated；取代 _evaluate_idle_subteam 手 argmax + _check_deviation randf）
	if sub.current_task == TeamData.TASK_IDLE:
		_decide_subteam(state, sub, merge_queue)
	# active-transit 已派 task → sticky（執行命令中 duty 壓制投機＝任務優先；到達自歸建 / discipline 自 detach）
```
- 刪 `_check_deviation`(1669-1686)：randf 中途叛離 = 手寫門檻，語意搬進 歸建(duty)↔掠奪(greed) 框架競秤（idle 時）。「執行命令中→duty 壓制投機」＝ active-transit task sticky（不 re-eval 去 loot）。
- 刪 `_evaluate_idle_subteam`(1688-1720)。
- 刪 const `DEVIATION_RATE`(line 23，僅 `_check_deviation` 用，grep 驗)。`DISCIPLINE_FAIL_BASE`/`_check_discipline` 保留。
- `_tag_weight` **保留**（line 904/1893 仍用）；子隊路不再呼。
- 註解 `faction_ai_system.gd:1332`（提 `_evaluate_idle_subteam`）→ 改指 `_decide_subteam`。

### D7. 憲法閘 baseline（必做，否則 gate FAIL）

`scripts/debug/constitution_baseline.txt`（current ⊆ baseline，新 try_set=FAIL）：
- **移除** line 17 `...::_check_deviation`、line 21 `...::_evaluate_idle_subteam`（arc 溶解，gate 印 removed=進度）。
- **新增** `scripts/simulation/faction_ai_system.gd::_decide_subteam`（引擎 dispatch 落點，正當性同 baseline 既有 `_decide_unified`/`_evaluate_solo`），附註 `# 序A2a subteam 溶入引擎（rank_scored 全框架）`。
- 淨：-2 手 argmax、+1 引擎落點。**系統權限內**（gate 明示「呈報系統更新 baseline」）。

## 觸及檔（詳 `docs/process/verdicts/A2a.scope.json`）

| 檔 | 改點 |
|---|---|
| `scripts/simulation/decision/decision_context.gd` | +`has_parent_directive`/`parent_team_pos` 欄 + gather 填（D1） |
| `scripts/simulation/decision/options.gd` | +`歸建` REGISTRY row + applicable + to_task fallback（D2）；建設/佔村 applicable +`not has_parent_directive` gate（D3） |
| `scripts/simulation/decision/terms.gd` | `faction_duty` eval +`歸建` case（D2） |
| `scripts/data/team_data.gd` | +`subteam_eval_next_tick` 欄（≈line 123，鏡射 `threat_eval_next_tick`）（D5） |
| `scripts/simulation/faction_ai_system.gd` | +`_decide_subteam` + `SUBTEAM_CADENCE`；改 `_evaluate_subteam` tail；刪 `_check_deviation`/`_evaluate_idle_subteam`/`DEVIATION_RATE`（D4/D5/D6） |
| `scripts/debug/constitution_baseline.txt` | -2 site +`_decide_subteam`（D7） |

**不碰**：`_tag_weight`（904/1893 仍用）、`hand_brain_probe.gd`（`SUBTEAM_BYPASS_REASONS` 變不可達，無害留）、子隊 lifecycle（detach/merge/settle/construct/escort/herald/discipline）、leader（A2b）、member/solo（A1a 已好，`has_parent_directive=false` 保零變）、A1a 拆的閥、掠奪 term（零 patch）。

## ★量測特判（工單硬守）

**回歸/歸建/解散/detach = lifecycle，禁進 obey/violation 統計。** by construction：
- `歸建` winner → `_decide_subteam` 特判（set move_target + merge_queue + `return`）**在呼 `capture` 前**，永不進單點統計。無 `winner_task=="回歸"` 恆-false 灌違規坑。
- 所有 lifecycle 出口（parent null / 無 leader / 全不可派 / merge-on-arrival / discipline detach）皆不呼 capture。
- 只有真 task-dispatch（掠奪/攻擊/迎戰/備戰/求和/survival）try_set 成功才 `capture(src="subteam")`。

## 驗收法（QA/量測員跑；systems 不跑 godot）

1. **無 GDScript 錯誤**；`.\tools\godot.ps1 --headless --import` 綠。
2. **constitution_gate 綠**：current ⊆ baseline（印 removed 兩 site + `_decide_subteam` 已收編）。
3. **sanity**：`game_sim_multi` headless ≥1000 tick 無崩、`[SubAI]` print 出現。
4. **★單點 bed**（`hand_obeys_brain_bed.gd`，seed 1337, 1 月）對照 A2a 前 baseline：
   - `subteam_bypass` 計數 **→ ~0**（手寫 dispatch 消失）。
   - `subteam` src `decisions>0` 且 **obey 率高**、背離率（`src_viol/src_dec`）低。
   - determinism 段 PASS（逐事件確定性）；非擾動段 MATCH。
5. **抖動檢**（TeamTrace / bed events）：子隊 task 走引擎後穩定，不每 cadence 亂換（`current_option`+COMMITMENT_BONUS + cadence gate 三重防震）。
6. **★效能回歸（藍圖 review #2，新增驗收項）**：before/after headless **per-tick 平均 tick-time 不顯著退化**（子隊 gather 已 cadence-gated 攤平）。手段：`SimRunner.phase_timing` 開，比 `loop1.factions`/gather.* bucket before(A2a 前)vs after；或 headless N-tick wall-time before/after（同 seed）差 <閾（量測員定，建議 ≤5%）。**驗「cadence gate 真攤平了 gather 成本」，非只功能對。**
7. **非退化**：member/solo/leader category 背離不暴增；`arbiter_latch` 維持 A1a 後低檔；seeded final 漂移允許但 QA 判合理非退化。
8. **效果發生**（subteam 背離真降 + bypass→0）非只「改了 code」。

## 殘留疑點（呈報 reviewer，見 handback）

- **D3 世界規則 gate 味道**：`建設/佔村 applicable +not has_parent_directive` 是「附屬單位不立據」世界規則謂詞（非 suppress 分支，成員零變），但技術上是 has_parent_directive 條件 → 若 reviewer 判太像子隊特例，備案=`_decide_subteam` dispatch loop 內 skip 該兩 opt（同 lifecycle 護欄語意，不動全域 options）。傾向前者（applicable 是 gate 的正位）。
- **active-transit 不 re-eval**：忠實現況「執行命令中 task sticky」；mid-mission duty 動態翻轉（忠誠度中途變→回頭）不建模（超範圍）。
- 子隊離家 starve 走 survival option（full rank 自帶覓食/投靠/買糧）＝**比 v1 多拿到的 believable 行為**（紀律單位也會求生），符藍圖「納框架自動拿到」意圖。
- `SUBTEAM_CADENCE=1 日` / `FACTION_DUTY_DRIVE` 對子隊量級＝TEST VALUE，平衡 pass 調。
