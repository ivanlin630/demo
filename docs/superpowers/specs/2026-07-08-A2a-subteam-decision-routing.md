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

對照乾淨縫：成員 `_assign_member_tasks:1428→_decide_unified→rank_scored`；solo `_evaluate_solo:1724`。

## ★裁定方向（藍圖 revise，取代 v1 子集 narrowing）

v1 用 `SUBTEAM_OPTION_SET={掠奪,攻擊}` 子集——**藍圖否決**：那是換一組更窄的觸發前提（悄砍攻擊 repertoire）非「行為忠實」，且逐 tick 全量 gather 無效能檢查。改為：

- **A2a = 拆補丁不是加補丁**：子隊決策移進統一 `DecisionEngine`（REGISTRY Σ term×weight argmax），**走全框架 row/term/gate，零 bypass 補丁**。
- **攻擊窄化＝對的（修 bug，明示接受）**：無紀律軍隊不會沒命令亂打敵人。子隊=紀律執行者，不自宣戰。攻擊只經 **faction 攻擊令**（inherited faction_stakes）**或血仇**（feud_pull），**不由裸 martial 分驅動**。`intent==征服` 結構性走不到子隊（只 faction leader 決定開戰）=設計正確。
- **★紅線：紀律=通用維度，複用既有 loyalty/duty，禁子隊專屬 term/分支。** 母團命令建模成 **directive（結構鏡射 faction_stakes）→ 被命令 option 拿 `faction_duty` weight**；`faction_duty` 已 key 在 `_loyalty`（`terms.gd:202` `_duty_factor(loy,野心)`）→ 忠誠子隊聽令、不忠→掠奪贏。一套 duty/loyalty 管 faction 成員 + 子隊，**子隊零特例分支**。

## 設計決定（HOW，全框架 row/term/gate）

### D1. 子隊旗進 ctx（`is_subteam`，一旗兩用：歸建 directive + 戰略-gate）

`decision_context.gd` 加欄（≈ line 64 faction_* 欄後）：
```
var is_subteam: bool = false   # parent_team_id != -1：①服從母團(歸建 directive) ②不自主發起戰略 option(戰略-gate)
```
`gather()` 填：
```
c.is_subteam = team.parent_team_id != -1
```
- round-3 合併：v2 的 `has_parent_directive` + `parent_team_pos` → 單一 `is_subteam` 旗。`parent_team_pos` 無用（`_decide_subteam` 直讀 `parent.tile_pos`）→ 刪。
- 子隊**同時 inherit faction_id → faction_stakes 照常填**（195-213）：warring faction 子隊自動拿 攻擊 directive（faction_duty）——攻擊紀律化免額外碼。
- 非子隊 `is_subteam=false` → 歸建 option / 戰略-gate 對其無效（零成員/solo 行為變）。

### D2. 「歸建」= 服從母團 option（faction_duty 驅，通用 row）

`options.gd`：
- REGISTRY 加 row（`歸建`＝服從權威/回母團集結，duty 驅）：
  ```
  "歸建": [["faction_duty", "faction_duty"]],
  ```
- `applicable`（≈ 44 loop 內）加：
  ```
  "歸建":
  	if ctx.is_subteam: out.append(opt)
  ```
- `to_task`：`歸建` 由 `_decide_subteam` 特判（lifecycle move，見 D4），不進 `to_task` 標準派工；為安全加 fallback `"歸建": return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1,-1)}`。

`terms.gd` `faction_duty` eval（`terms.gd:100-106` match）加 case：
```
"歸建": return FACTION_DUTY_DRIVE if ctx.is_subteam else 0.0
```
- weight 已 `_duty_factor(_loyalty, 野心)`（`terms.gd:202`）→ 歸建 util = `_duty_factor × FACTION_DUTY_DRIVE(1.5)`。忠誠高→歸建 util 高（聽令回母團）；低忠高野→`_duty_factor→0`→歸建塌，掠奪（greed×loot weight）贏。**＝現況 `_check_deviation` greed·(1-loyalty) 語意，搬進框架用同一 duty 機制，零新 term。**

### D3. 通用戰略-gate：一條規則管全部（round-3 真 un-patch，併原 D3 建設/佔村 + 涵蓋訓練）

全 `rank_scored` 會讓子隊憑空拿到**自主戰略級行為**——`建設`（自建據點，options.gd:55 無條件 applicable）/`佔村`（奪據點，有 target 即候選）/**`訓練`**（練兵，options.gd:125-126 `archetype==FORCE and has_trainable`；子隊 leader_id!=-1 → loop2b `AmbitionLadder.update` 照算 archetype/rung，`708-722` 無 parent 排除 → 子隊 idle 可自選練兵）。三者皆「子隊原本不會做、框架化後憑空長出」＝生命週期突變（工單護欄禁）。

**正當性＝既有 leader-dispatch settle 機制**（藍圖 round-2/3 裁定）：grep 證實子隊建造/安頓現行**皆由母團/leader 主動派遣既有 subteam 帶 pre-set task 發起**（`faction_ai_system.gd:525 _dispatch_subteam_settle → :540 try_set TASK_SETTLE`、`:2292 dispatch TASK_CONSTRUCT`），**從未子隊 idle 自選**。戰略足跡擴張（立據/奪據/練兵）屬 leader/faction 決定。（**非借 invariants「立國=leader-level」**——那是 faction 建國，文不對題。）

**★round-3：立一條通用規則取代逐 option gate（別補丁苗頭）：**
- `options.gd` 加 `const STRATEGIC_SELFINIT_SET: Array = ["建設", "佔村", "訓練"]`（自主發起=擴張自身戰略足跡的活動）。
- `applicable()` loop 頭**一個 guard**（44 loop 內，match 前）：
  ```
  # 子隊不自主發起戰略級 option（立據/奪據/練兵＝leader/faction 決定；母團命令走 pre-set lifecycle task）
  if ctx.is_subteam and opt in STRATEGIC_SELFINIT_SET:
  	continue
  ```
- **一條件管全部**：新增戰略 option 只需入 SET，自動涵蓋（無逐 option gate）。**併掉 round-2 的 建設/佔村 獨立 gate**（別留兩套）。
- **「除非母團 directive」逃生口**：母團要子隊做戰略活動＝派 pre-set lifecycle task（TASK_SETTLE/CONSTRUCT，`_evaluate_subteam` lifecycle guard 早退，不進 engine applicable）→ 引擎決策點子隊**結構上無 strategic 母團 directive** → guard 對子隊無條件成立。若日後建模「母團經引擎下戰略令」，於此 guard 加 per-opt directive 檢查（hook 預留）。
- 成員/solo `is_subteam=false`→ guard 不觸→**行為零變**。`生產/駐守`（`has_own_outpost`）/`囤貨`（`intent==致富`）子隊本已自然排除，非戰略-gate 對象。
- **不 gate（子隊該能做）**：survival/投機（掠奪/覓食/返家補給/買糧/乞食/紮營/投靠）、被動防禦（迎戰/備戰/求和）、攻擊（已 faction directive/血仇 gated）。

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
		# ★投靠走共用 helper（見 D4b）：玩家 target→forced_event 請求(不自動併，防 P2a W2 坑)；NPC→try_set JOIN
		if opt == "投靠":
			if _try_join_target(state, sub, int(td.get("social_target", -1)), TaskArbiter.PRIO_DISPATCH, "subteam"):
				sub.current_option = opt
				HandBrainProbe.capture(state, sub, "subteam", String(ranked[0]["opt"]), opt, td["task"], true)
				return
			continue   # 投靠不可派 → 次佳
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

### D4b. 共用 join-helper（round-3 真 un-patch：抽一份，既有 2 處改呼，別複製第 3 份）

**★問題**：子隊納全 rank 拿到 `投靠` option → `_find_strong_neighbor`（`faction_ai_system.gd:3232`，只排同 faction **不排玩家隊**）可回玩家隊 → `options.gd:152-156 to_task「投靠」` 對玩家一樣設 `social_target` → 同格觸發 `interaction_system.gd:1035 _resolve_join` **無條件 `SubteamSystem.merge_teams`**（自動併，非詢問）＝重引入 **P2a W2 已修的「NPC 投靠玩家誤自動併」坑**。

**現況既有 guard = 2 處**（非 review 說的 3；`_decide_unified:1512-1516` + `_trigger_survival:3082-3086`；review 引的「prosperity :3085」即 `_trigger_survival` 內同一處，3085 ∈ 3055-3104）。各自 inline：
```
if opt == "投靠" and td.has("social_target"):
	var pp = persons.get(player_id) ...
	if pp != null and int(td["social_target"]) == pp.team_id:
		if _maybe_request_join_player(state, team): return
```

**★抽共用 helper（`faction_ai_system.gd`，near `_maybe_request_join_player:3220`）**，**別複製第 3 份**：
```
# 投靠派工單一 seam：玩家 target → forced_event 請求(玩家決定收留，不自動併)；NPC → try_set TASK_JOIN + social_target。
# 回 true = 已處理(caller return/停止試次佳)；false = 不可派(caller continue 試次佳)。
func _try_join_target(state: WorldState, team: TeamData, target_id: int, prio: int, reason: String) -> bool:
	if target_id == -1 or not state.teams.has(target_id):
		return false
	var pp: PersonData = state.persons.get(state.player_id) if state.player_id != -1 else null
	if pp != null and target_id == pp.team_id:
		return _maybe_request_join_player(state, team)   # 寫 forced_event，不 try_set（防自動併）
	if not TaskArbiter.try_set(state, team, TeamData.TASK_JOIN, state.teams[target_id].tile_pos, prio, reason):
		return false
	state.set_social_target(team, target_id)
	return true
```

**四條派工路徑全走它（既有 3 改呼 + A2a 子隊新路）**——★藍圖裁定「別靠 finder 排除玩家，集中 helper 一處攔」：
| 路徑 | 現況 | 改 |
|---|---|---|
| `_decide_unified:1512-1516`(+1534 generic social_target) | inline guard + generic try_set | 投靠 branch 改呼 `_try_join_target(...,PRIO_DISPATCH,"unified")`（成功 return，否則 continue） |
| `_trigger_survival:3082-3086`(+3087 try_set/3091 social_target) | inline guard + generic try_set | 同上，`(...,PRIO_SURVIVAL,"survival")` |
| `_decide_subteam`（A2a 新，見 D4） | — | `(...,PRIO_DISPATCH,"subteam")` |

- **helper 非塞進 `merge_teams` choke**（藍圖裁定）：choke 會變「到場才問」＝改 ask-before-travel 語意；helper 保現行語意（派工時決定走請求 or JOIN）。
- **玩家排除集中 helper 一處**：`_find_strong_neighbor` 不動（不加 finder 排除）；即使它對子隊回玩家隊，helper 攔成 forced_event。
- 減既有債：2 份 inline guard → 1 份 helper（round-3 un-patch 收益）。

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

**★藍圖明示接受：移除「mid-mission 投機叛逃」（round-2 D6 裁定，比照 review#1 攻擊窄化標準）。**
現況 `_check_deviation` 是**執行任務中**（`current_task≠IDLE` 且移動中，`1629-1631` 逐 tick）判「半路轉去搶劫但不脫離」。v2 改成 active-transit sticky（只 idle 才 `_decide_subteam`）＝此行為分支**移除**。**藍圖裁定接受移除**，理由：
1. **脫離出口保留**：`_check_discipline`（discipline_fail）不動 → 中途嚴重不紀律仍 desert→獨立→自由搶。
2. **投機出口保留**：idle 掠奪搬進 duty↔greed 框架（loyalty-gated）→ 貪婪不忠子隊 idle 仍投機。
3. **執行中 sticky = 任務承諾 + 省效能 + 更紀律**，合「紀律至上」願景（紀律單位執行命令中不半路溜去搶）。
- **future work（deferred，非遺漏）**：完整「**抗命**」行為（mid-mission 動態抗命/違令，非只脫離/idle 掠奪）延後，日後另 slice 補。此處明記為 deferred。
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
| `scripts/simulation/decision/decision_context.gd` | +`is_subteam` 欄（一旗兩用）+ gather 填 `= parent_team_id != -1`（D1；v2 的 has_parent_directive/parent_team_pos 合併掉） |
| `scripts/simulation/decision/options.gd` | +`歸建` REGISTRY row + applicable(`is_subteam`) + to_task fallback（D2）；+`STRATEGIC_SELFINIT_SET` const + applicable loop 頭一個**通用戰略-gate** guard（D3，併建設/佔村+涵蓋訓練） |
| `scripts/simulation/decision/terms.gd` | `faction_duty` eval +`歸建` case（`is_subteam`）（D2） |
| `scripts/data/team_data.gd` | +`subteam_eval_next_tick` 欄（≈line 123，鏡射 `threat_eval_next_tick`）（D5） |
| `scripts/simulation/faction_ai_system.gd` | +`_decide_subteam` + `SUBTEAM_CADENCE`；+`_try_join_target` 共用 helper + **既有 2 處 join guard（`1512-1516`/`3082-3086`）改呼**（D4b）；改 `_evaluate_subteam` tail；刪 `_check_deviation`/`_evaluate_idle_subteam`/`DEVIATION_RATE`（D4/D5/D6） |
| `scripts/debug/constitution_baseline.txt` | -2 site +`_decide_subteam`（D7） |

**不碰**：`_tag_weight`（904/1893 仍用）、`_find_strong_neighbor`（不加玩家排除，靠 helper 集中攔，D4b）、`_maybe_request_join_player`/`_resolve_join`/`merge_teams`（helper 復用，不動 choke 語意）、`hand_brain_probe.gd`（`SUBTEAM_BYPASS_REASONS` 變不可達，無害留）、子隊 lifecycle（detach/merge/settle/construct/escort/herald/discipline）、leader（A2b）、member/solo（A1a 已好，`is_subteam=false` 保零變）、A1a 拆的閥、掠奪 term（零 patch）。

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
9. **★投靠玩家走 forced_event 非自動併**（round-3 D4b，P2a W2 回歸檢）：子隊（及既有 unified/survival 路）投靠 target=玩家隊 → 寫 forced_event 請求（`_maybe_request_join_player`），**不 `try_set` 不 `merge_teams` 自動併**。回歸測：構造子隊投靠玩家 → 斷言無自動 merge、有 forced_event。
10. **★通用戰略-gate 生效**（round-3 D3）：子隊 idle 無母團 directive → `建設/佔村/訓練` 三者**皆不候選**（`applicable` 不含）；非子隊（member/solo）同場景 → 照候選（零影響）。

## 殘留疑點（呈報 reviewer，見 handback）

- **通用戰略-gate（round-3 D3）取代逐 option gate**：一條 `is_subteam and opt in STRATEGIC_SELFINIT_SET` 管建設/佔村/訓練，新增戰略 option 入 SET 自動涵蓋（併掉 round-2 兩獨立 gate）。正當性=既有 leader-dispatch settle 現況（非借「立國」）。「除非母團 directive」逃生口＝母團戰略令走 pre-set lifecycle task，引擎點結構無 → hook 預留。
- **join-helper（round-3 D4b）真 un-patch**：抽 `_try_join_target`，既有 2 處 inline guard（非 review 說 3 處）改呼，減既有債；玩家排除集中 helper（防 P2a W2 自動併坑）。
- **mid-mission 投機叛逃移除＝藍圖明示接受**（round-2 D6，見 D6 段明示接受段）：非「系統自認超範圍」。完整「抗命」行為 deferred 另 slice（D6 future work 明記）。
- 子隊離家 starve 走 survival option（full rank 自帶覓食/投靠/買糧）＝**比 v1 多拿到的 believable 行為**（紀律單位也會求生），符藍圖「納框架自動拿到」意圖。
- `SUBTEAM_CADENCE=1 日` / `FACTION_DUTY_DRIVE` 對子隊量級＝TEST VALUE，平衡 pass 調。
