> ⛔ **SUPERSEDED（2026-06-21，根因錯誤作廢，未實作）**。上游 spec 根因算術錯（food weight=0.1 → carry latch 不存在），本 plan carry-aware 釋放為 no-op、測試案A 不可滿足。子 session BLOCKER 抓出停工。實測真根見 spec SUPERSEDED banner + `handbacks/2026-06-21-caravan-survival-carry-aware-release.md`。重修走新 brainstorm。

# 商隊 survival latch 修 — carry-aware 釋放 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 修 `_evaluate_survival` 釋放條件結構 bug——讓旅途隊（離家、攜糧受 carry cap 限）能脫離 survival task，使商隊回貿易、world_sim 履約脫 0。

**Architecture:** survival 釋放分支加一條「forage 已盡力」OR 條件：food 攜滿（`carry_space_for_res(team,"food") <= 0`）且非瀕餓（`days_left >= WARNING_DAYS`）→ 釋放。不動進入閾值/優先序（守藍圖 believability 護欄：真餓仍卡 survival）。survival 仍由舊 `_evaluate_survival` 擁有（不遷引擎=非本塊）。

**Tech Stack:** Godot 4.2.2 GDScript。測試 `scripts/debug/headless_test.gd`（行為 assert）+ `scripts/debug/world_sim.gd`（履約量測，`Probe.summary()`）。

## Global Constraints

- 用 wrapper 跑 Godot（UTF-8）：`.\tools\godot.ps1 --headless --script <path>`。
- **只改釋放側**：進入閾值 `URGENCY_DAYS(1)`/`WARNING_DAYS(3)`、`_trigger_survival` 不動。
- **believability 護欄（藍圖）**：`days_left < WARNING(3)` 或受威脅 → 仍卡 survival（真餓/真危險不放去巡市集）。新分支要 `days_left >= WARNING_DAYS`。
- 不碰守恆（只改 task 釋放決策，不碰 resources/coin/state 池）→ coin_eq/InvariantAudit 回歸 0。
- 保留 `proactive_camp` 例外（SoloAI 主動 CAMP 不被糧足釋放）。
- 全數值 TEST VALUE。

關鍵常數（驗算根因）：`SURVIVAL_RECOVER_DAYS=7.0`、`WARNING_DAYS=3.0`、`FOOD_PER_PERSON_PER_DAY=2.4`、`BASE_CARRY=10.0` → carry-cap-in-days=10/2.4≈4.17 < 7 = 旅途隊永到不了釋放閾（本 bug）。

---

### Task 1: carry-aware survival 釋放分支 + 單測

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd:2114-2119`（`_evaluate_survival` 釋放分支）
- Test: `scripts/debug/headless_test.gd`（加 `_test_survival_carry_aware_release`，註冊進 dispatch）

**Interfaces:**
- Consumes: `FactionAISystem._evaluate_survival(state, team)`、`MovementSystem.carry_space_for_res(team, res)->int`（WS-3，instance method，food 還能裝幾個；攜滿=0）、`TaskArbiter.release(team)`、常數 `SURVIVAL_RECOVER_DAYS`/`WARNING_DAYS`、`ResourceSystem.effective_food`、`SURVIVAL_TASKS`、`_seed_pop`。
- Produces: survival 釋放新行為——旅途攜滿隊（food 空間≤0 且 days_left∈[WARNING,RECOVER)）脫離 survival 回 IDLE。

- [ ] **Step 1: 寫失敗測試**

在 `scripts/debug/headless_test.gd` 加測試函式（放在 `_test_true_desperation_still_survival` 後，約 line 4273 之後）：

```gdscript
func _test_survival_carry_aware_release() -> void:
	print("--- 商隊 survival carry-aware 釋放 ---")
	# 旅途隊(無自家 outpost @tile_pos → effective_food=carried only)、5 人、無馬車
	# carry cap = 5*BASE_CARRY(10) = 50；food/day = 5*2.4 = 12
	# 案A：food=50(攜滿,空間=0)、days_left=50/12≈4.17 ∈[3,7) → forage 已盡力 → 釋放
	var sA := WorldState.new(); sA.world = WorldData.new()
	var tA := TeamData.new(); tA.team_id = 0; tA.tile_pos = Vector2i(5,5); tA.leader_id = 100
	_seed_pop(tA, 5); tA.resources = {"food": 50.0}
	tA.current_task = TeamData.TASK_FORAGE; tA.task_priority = TaskArbiter.PRIO_FACTION
	var lA := PersonData.new(); lA.id = 100; lA.team_id = 0; sA.persons[100] = lA; sA.teams[0] = tA
	var ms := MovementSystem.new()
	assert(ms.carry_space_for_res(tA, "food") <= 0, "案A 前置:food 應攜滿(空間≤0)，實際=%d" % ms.carry_space_for_res(tA, "food"))
	var fai := FactionAISystem.new()
	fai._evaluate_survival(sA, tA)
	assert(not (tA.current_task in fai.SURVIVAL_TASKS), \
		"案A：旅途攜滿+非瀕餓(days≈4.17) → 應脫 survival，實際=%s" % tA.current_task)

	# 案B(反例,守護欄)：food=24、days_left=2(<WARNING 3) 瀕餓 → 不釋放(仍 forage)
	var sB := WorldState.new(); sB.world = WorldData.new()
	var tB := TeamData.new(); tB.team_id = 0; tB.tile_pos = Vector2i(5,5); tB.leader_id = 100
	_seed_pop(tB, 5); tB.resources = {"food": 24.0}
	tB.current_task = TeamData.TASK_FORAGE; tB.task_priority = TaskArbiter.PRIO_FACTION
	var lB := PersonData.new(); lB.id = 100; lB.team_id = 0; sB.persons[100] = lB; sB.teams[0] = tB
	fai._evaluate_survival(sB, tB)
	assert(tB.current_task == TeamData.TASK_FORAGE, \
		"案B 反例：瀕餓(days=2<3) → 不該釋放(survival 仍贏)，實際=%s" % tB.current_task)
	print("survival carry-aware release OK")
```

註冊進 dispatch：在 `scripts/debug/headless_test.gd` 找 `_test_true_desperation_still_survival()` 被呼叫處（grep 確認行號），其後加一行：

```gdscript
	_test_true_desperation_still_survival()
	_test_survival_carry_aware_release()
```

> 若 `_test_true_desperation_still_survival()` 未在 dispatch 被呼叫，則加在 `_test_survival_reads_granary()` 呼叫行（headless_test.gd:3787）之後。

- [ ] **Step 2: 跑測試確認失敗**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: FAIL — 案A assert 失敗（現釋放只認 `days_left>=7`，days≈4.17<7 → 不釋放 → 仍 TASK_FORAGE）。案B 應已過（瀕餓本就不釋放）。

- [ ] **Step 3: 改釋放分支**

`scripts/simulation/faction_ai_system.gd:2114-2119`，現有：

```gdscript
	if team.current_task in SURVIVAL_TASKS:
		var proactive_camp: bool = team.current_task == TeamData.TASK_CAMP \
			and team.task_priority == TaskArbiter.PRIO_DISPATCH
		if days_left >= SURVIVAL_RECOVER_DAYS and not proactive_camp:
			TaskArbiter.release(team)
		return
```

換成：

```gdscript
	if team.current_task in SURVIVAL_TASKS:
		var proactive_camp: bool = team.current_task == TeamData.TASK_CAMP \
			and team.task_priority == TaskArbiter.PRIO_DISPATCH
		# 釋放(任一)：①足糧(站糧倉/大儲量達 RECOVER) ②forage 已盡力——food 攜滿(carry 空間≤0)
		# 且非瀕餓(>=WARNING)。後者解旅途隊結構 latch：carry-cap-in-days≈4.17 < RECOVER(7)
		# → 旅途隊永到不了 ① → 永卡 forage。守護欄：瀕餓(<WARNING)仍卡 survival。
		var foraged_full: bool = days_left >= WARNING_DAYS \
			and MovementSystem.new().carry_space_for_res(team, "food") <= 0
		if (days_left >= SURVIVAL_RECOVER_DAYS or foraged_full) and not proactive_camp:
			TaskArbiter.release(team)
		return
```

- [ ] **Step 4: 跑測試確認通過（含飢荒鏈回歸）**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: PASS — `survival carry-aware release OK` 出現；`survival reads granary OK` / `true desperation still survival OK` / 既有 `_test_survival_*`（sticky/trigger/decision_tree/b_branch…）全綠；`=== DONE ===` 無 assert 失敗。**若任何既有飢荒/絕境測試紅 → 停，回報 systems（可能新分支誤放真絕境隊），勿改測試掩蓋。**

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "fix(survival): carry-aware 釋放 — 旅途隊脫 survival latch(carry<RECOVER結構bug)"
```

---

### Task 2: world_sim 履約脫 0 驗收 + believability 反例 + 全回歸

**Files:**
- Verify only：`scripts/debug/world_sim.gd`、`scripts/debug/probe_stats.gd`、`scripts/debug/headless_test.gd`

**Interfaces:**
- Consumes: `Probe.summary()` 印 `[ProbeSummary] g1.order_fulfilled = N`、`g1.merchant_survival`、`g1.seek_market`、`g1.market_arrive`、`訂單履約率`；`[Market] … 成交` print（`interaction_system.gd:574`）。
- Produces: 履約脫 0 證據（`order_fulfilled > 0`）+ believability 護欄反例證據。

- [ ] **Step 1: 跑 world_sim 取修後數據**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/world_sim.gd`
觀察結尾 `[ProbeSummary]` 區塊。記下：`g1.order_fulfilled`、`g1.merchant_survival`、`g1.seek_market`、`g1.market_arrive`、`訂單履約率`、`[Market] … 成交` 出現次數。

> 對照基準（修前，sub-project A handback）：`merchant_survival≈164`、`seek_market=1`、`order_fulfilled≈0`、成交=0。
> 長跑慢可先暫降 `config/world_sim.json` `max_ticks`（如 21600）快看，最終用原值跑一輪。

- [ ] **Step 2: 判定履約脫 0**

- **過**：`g1.order_fulfilled > 0` 且 `merchant_survival` 明顯降（商隊不再永卡）且 `seek_market`/`market_arrive` 升（商隊出門了）且 `[Market] … 成交` 常態出現。
- **未脫 0** → Step 3 診斷。

- [ ] **Step 3: 診斷仍 0（僅當 Step 2 失敗，measure-first 勿憑猜）**

trace（`team_trace.gd` 月取樣 + 臨時 print）一支 `TAG_MERCHANT` 隊連續數十 tick：
1. 商隊是否仍卡 survival？看 `current_task`/`days_left`/`carry_space_for_res(food)`。若 days_left 長期 <3（真餓）→ 非本修範疇（商隊糧供給問題，屬乾糧/carry 平衡，記錄回報 systems）。
2. 釋放後是否立刻重進 survival（thrash）？看 task 是否高頻 forage↔trade 跳。若 thrash → WARNING/RECOVER band 或承諾 cadence 問題，記錄回報。
3. 商隊脫 survival 後是否真去 seek_market 並與生產隊 co-located？若脫了卻不貿易 → 引擎貿易 option 守衛問題，回報。
4. 根因 + 證據寫進 handback 回報 systems。

- [ ] **Step 4: 全回歸閘**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: 全綠 `=== DONE ===`；survival carry-aware release + 既有 survival/飢荒/絕境測試 + TC1/4/6/7 + role applicable + unified seam 全 OK；coin_eq / InvariantAudit 0。

- [ ] **Step 5: Commit 量測記錄（若無 code 改則記在 handback，跳過 commit）**

```bash
git add scripts/debug/headless_test.gd
git commit -m "test(survival): world_sim 履約脫0 驗收 + believability 反例"
```
（若 Step 1-4 未動任何檔，跳過此 commit，量測結果寫進完成 handback。）

---

## 完成後

子 session 回報 handback 給 systems：
- 履約 count 前/後（`order_fulfilled`/`merchant_survival`/`seek_market`/`market_arrive`/成交數）。
- **believability 護欄反例**：`days_left<3` 商隊不釋放（單測案B + world_sim 抽樣）= 沒洗平（藍圖驗收項）。
- 全回歸結果、任何診斷出但出範疇的因（如商隊糧供給/thrash）。
- 履約是否**真端到端脫 0**（經濟閉環首次活）。

systems 收後更新 `progress.md` + `[[project_economy_arc]]`/`[[project_unified_decision_framework]]`，並回 handback 知會藍圖（履約脫 0 達成 + believability 護欄守住）。

## Self-Review

- **Spec coverage**：spec §修（carry-aware OR 條件）=Task1 Step3；§守護欄（>=WARNING/優先序不動/proactive_camp 保留）=Task1 Step3 程式碼 + 案B 反例測；§驗收(履約脫0/反例/不破飢荒/coin_eq/InvariantAudit)=Task1 Step4 + Task2；§開放細節(carry accessor 签名/EPSILON)=用 `carry_space_for_res<=0`（int，攜滿=0，無需 float EPSILON）；§開放(own_granary 守衛收窄)=未加（站 outpost 隊 case① 多已釋放，新分支對它無害=YAGNI，spec 已述）。全覆蓋。
- **Placeholder scan**：無 TBD；code step 附完整碼；Step3 診斷為條件分支（給具體查序）非 placeholder。
- **Type consistency**：`carry_space_for_res(team, "food")->int`（`<=0` 判攜滿）一致；`foraged_full: bool`、`MovementSystem.new()` instance、`SURVIVAL_TASKS`/`WARNING_DAYS`/`SURVIVAL_RECOVER_DAYS` 與 faction_ai 既有一致；測試 `_evaluate_survival(state,team)` 簽名一致。
