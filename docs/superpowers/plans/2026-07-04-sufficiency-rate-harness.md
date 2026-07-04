# 全系統充足性率表 harness Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 建 `sufficiency_bed.gd` 純機器 harness：default 自然世界（seed 1337+2674，各 6 月）自跑，輸出全系統充足性率表——每列率＋月切面＋想要/可行/發生三元組＋JSON 區塊＋事件流 dump；補各鏈缺失 counters（零行為變）。

**Architecture:** 復用既有 `Probe`（class_name Probe，`scripts/debug/probe_stats.gd`）靜態計數器——已 `enabled`-gated（default false → 一般跑 no-op）、RNG-free（bump/note/add_amount 不碰 randf）、可 `reset()`。各鏈缺失 counter 以純加行 `Probe.bump`/`Probe.note` 掛在 chokepoint（emit/accessor/single-writer 入口）。bed 開 `Probe.enabled=true` 跑世界、讀 `Probe.counts`/`peaks` 排率表。counters 不動 RNG 流 → 行為完全不變，seeded warring 逐點 diff=0 為證。既有漏斗（capture/assimilate/occupy/founding/envoy/scout）counter 已在 → 本 harness 只收編其輸出格式，不重做。

**Tech Stack:** Godot 4.2.2 GDScript，SceneTree headless script，`tools\godot.ps1` wrapper（強制 UTF-8）。

## Global Constraints

- **counters 零行為變**：純計數/append，不動 RNG 流。濾鏈含 `randf`/`randi` 勿重排（cadence 教訓）。所有新增 = 純 `Probe.bump`/`Probe.note` 加行，不移動既有碼、不插在 randf 之間改變求值順序。
- **Probe.enabled 守衛**：任何在 counter 前需計算的中間值（字串組裝、額外求值）必須包在 `if Probe.enabled:` 內 → 一般跑（Probe 關）零成本、零求值。
- **不修病**：判決歸 QA、修序歸藍圖、修=後續軌。本軌純機器：只加計數與輸出，不改任何被量出來的行為。
- **檔案 scope 紀律（與貿易軌撞檔規避）**：**勿碰** `order_system.gd`、`interaction_system.gd` 的 trade resolve 段、`scripts/simulation/decision/options.gd`、observer UI（`scripts/ui/*`、ObserverMain）。`faction_ai_system.gd` **勿碰** caravan/trade 區：行 `1470–1477`（member trade option & try_set TASK_TRADE）、`1949–1964`（`_merchant_trade_target` 訂單/市場查找）、`1487–1540`（`_decide_unified` 統一引擎內部，只讀不加 dispatch 邏輯）。本軌在 faction_ai 只掛 intent 讀側 counter（`_update_goals`/`_set_solo`/`tribute_accept`）。
- **貿易列 = 佔位**：率表貿易列只印引用貿易軌六站漏斗的佔位字串，不自建 counter。
- **輸出格式強制（R3+三元組）**：每列 `分子/分母=率`＋月切面＋想要/可行/發生三元組（可行=條件滿足計數，各鏈自定義並在輸出**註明定義**）。裸計數=違規。表尾 machine-readable JSON 區塊（一行/列）。
- **不判決**：harness 只印率與三元組，**不印判決**（合理 0 vs 斷鏈 0 由 QA 判）。

---

## File Structure

- **Create `scripts/debug/sufficiency_bed.gd`** — SceneTree harness。跑 default.json × 2 seed × 6 月，開 Probe，月切面快照，排率表＋JSON＋事件流 dump。唯一新檔。
- **Modify（僅 +counter，純加行）**：
  - `scripts/simulation/message_system.gd` — 訊息傳播 counter（sent/propagate/delivered/distorted/lie_claim/reconcile 機會）。
  - `scripts/simulation/belief_system.gd` — belief accessor counter（best_estimate call/hit、has_belief call/true、claim 新鮮度桶、reconcile 機會/比對）。
  - `scripts/simulation/diplomatic_ai_system.gd` — 外交提案 counter（proposal sent/handled/accept）＋ RelationGraph tribute 邊效應 counter。
  - `scripts/simulation/faction_ai_system.gd` — intent 選擇 counter（讀側，`_update_goals`/`_set_solo`）。
  - `scripts/simulation/event_system.gd` — 各 event 型 eligible/fire counter（loop chokepoint）。
- **不新增測試檔**：本 harness 的驗收 = seeded warring 逐點 diff=0（中立性）＋ headless/framework/coin_eq 綠＋ bed 印出完整率表（見「測試標準」）。此為專案 implementer 流程的測試標準，取代 unit-test TDD。

## 測試標準（每 task 完成後跑）

```powershell
# headless 綠（無 SCRIPT ERROR、見 === DONE ===）
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd

# 中立性：seeded warring 逐點 diff=0（見 Task 1 baseline / Task 12 對照）
```

每個 counter task 的「測試」= 上述 headless 綠 + 該 counter 在 bed 輸出中出現（Task 9 後可驗）。中立性總驗在 Task 12。

---

### Task 1: Baseline capture（seeded warring 中立性基準）

**目的**：在加任何 counter 前，於乾淨 HEAD（=origin/main）dump seeded warring metric JSON，作 Task 12 逐點對照基準。

**Files:**
- 無檔案改動（只跑既有 bed + 寫 JSON 到 scratchpad）。

- [ ] **Step 1: 確認 worktree 乾淨且 class 快取已建**

Run:
```powershell
git status
.\tools\godot.ps1 --headless --import
```
Expected: `git status` 顯示 working tree clean（Task 0 已建 worktree + 重建快取）。

- [ ] **Step 2: dump seeded warring baseline（3 seed × 3 月，快）**

Run:
```powershell
$env:WARRING_OUT="C:\Users\I12\AppData\Local\Temp\claude\A--GDS-demo\0b135767-0a07-4116-9b28-7037a8748fc8\scratchpad\warring_baseline.json"; .\tools\godot.ps1 --headless --script scripts/debug/seeded_warring_bed.gd
```
Expected: 印 `[bed] baseline metric 已寫 → ...warring_baseline.json`、`=== seeded_warring_bed DONE ===`，無 SCRIPT ERROR。

- [ ] **Step 3: 確認 baseline 檔存在且 parse 得動**

Run:
```powershell
Get-Content "C:\Users\I12\AppData\Local\Temp\claude\A--GDS-demo\0b135767-0a07-4116-9b28-7037a8748fc8\scratchpad\warring_baseline.json" | Select-Object -First 3
```
Expected: JSON 開頭（`{` + seed key）。此檔為 Task 12 對照基準，**勿刪**。

- [ ] **Step 4: Commit（無碼改，記 baseline 程序）**

```powershell
git commit --allow-empty -m "test: seeded warring baseline captured (pre-counter neutrality ref)"
```

---

### Task 2: 訊息傳播 counters（message_system.gd）

**Files:**
- Modify: `scripts/simulation/message_system.gd`

**Interfaces:**
- Consumes: `Probe.bump(event, n)`（`scripts/debug/probe_stats.gd:12`，enabled-gated no-op）。
- Produces: counts keys `msg.sent`、`msg.prop_candidate`、`msg.prop_done`、`msg.delivered`、`msg.distorted`、`msg.lie_claim`。供 Task 9 bed 讀。

三元組定義（bed 輸出註明）：
- **送達率** happened=`msg.delivered`（copy 實 append 到 receiver team_known）/ feasible=`msg.prop_candidate`（同格鄰隊有未知訊息＝可傳的機會）/ want=`msg.sent`（emit_message 發出＝想散佈）。
- **失真率** happened=`msg.distorted` / feasible=`msg.prop_done`（實傳的 copy 總數）。
- **消費率**：consumed 走 `g1.board_read`（既有，訂單看板讀＝唯一有決策消費者的 msg 類）/ feasible=`msg.delivered`。bed 註明：非 order 類訊息今無決策消費 chokepoint → 結構性缺（QA 素材）。

- [ ] **Step 1: `emit_message` 掛 sent counter**

在 `scripts/simulation/message_system.gd` `emit_message`，`state.global_messages.append(msg)` 之後、`return msg` 之前加行。改 `func emit_message`（約 :41-45）：

```gdscript
	state.global_messages.append(msg)
	if not state.team_known.has(team.team_id):
		state.team_known[team.team_id] = []
	state.team_known[team.team_id].append(msg)
	Probe.bump("msg.sent")
	return msg
```

- [ ] **Step 2: `_exchange_one_way` 掛 propagation counters**

在 `_exchange_one_way`（約 :95-118）loop 內。`for msg in state.team_known[from_id]:` 內，`if known_ids.has(msg.id): continue` 之後（＝此訊息對 receiver 未知＝一個傳播候選）加 `msg.prop_candidate`；`match _decide_propagation_mode(carrier):` 的各 append 分支加 `msg.prop_done`+`msg.delivered`，distort 分支加 `msg.distorted`。改：

```gdscript
	for msg in state.team_known[from_id]:
		if known_ids.has(msg.id):
			continue
		Probe.bump("msg.prop_candidate")
		var age: int = state.world.current_tick - msg.origin_tick
		var time_factor: float = maxf(1.0 - float(age) * TIME_DECAY_PER_TICK, 0.1)
		var copy := _copy_message(msg)
		copy.strength = msg.strength * (1.0 - HOP_DECAY) * time_factor
		if copy.strength <= 0.05:
			continue
		match _decide_propagation_mode(carrier):
			"honest":
				state.team_known[to_id].append(copy)
				Probe.bump("msg.prop_done"); Probe.bump("msg.delivered")
			"unintentional":
				copy.is_distorted = true
				copy.strength *= 0.8
				DistortionEngine.distort_message(state, copy, "unintentional")
				state.team_known[to_id].append(copy)
				Probe.bump("msg.prop_done"); Probe.bump("msg.delivered"); Probe.bump("msg.distorted")
			"malicious":
				copy.is_distorted = true
				copy.strength *= 0.5
				DistortionEngine.distort_message(state, copy, "malicious")
				state.team_known[to_id].append(copy)
				Probe.bump("msg.prop_done"); Probe.bump("msg.delivered"); Probe.bump("msg.distorted")
			"silent":
				pass
```

**注意**：`msg.prop_candidate` 加在 `_decide_propagation_mode(carrier)`（呼叫含 `randf`）之前——但 `Probe.bump` 不呼 randf，且加在既有 `var age` 前不改任何求值順序（bump 是純副作用）。`randf` 仍在 match 內同一位置求值 → 序不變。

- [ ] **Step 3: headless 綠**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: 見 `=== DONE ===`，無 `SCRIPT ERROR`。

- [ ] **Step 4: Commit**

```powershell
git add scripts/simulation/message_system.gd
git commit -m "feat(message): +傳播充足性 counter (sent/candidate/done/delivered/distorted)"
```

---

### Task 3: belief accessor counters（belief_system.gd）

**Files:**
- Modify: `scripts/simulation/belief_system.gd`

**Interfaces:**
- Produces: keys `bel.has_belief_call`、`bel.has_belief_true`、`bel.best_call`、`bel.best_hit`、`bel.claim_fresh`、`bel.claim_mid`、`bel.claim_stale`、`bel.reconcile_opportunity`、`bel.reconcile_compared`。

三元組定義：
- **實質 belief 讀率** want=`bel.has_belief_call`（決策問「有沒有情報」）/ feasible=`bel.has_belief_true`（有 claim）/ happened=`bel.best_hit`（best_estimate 回非空＝決策實讀到估值）。
- **claim 新鮮度分佈** = `bel.claim_fresh/mid/stale`（best_estimate 選中 claim 的 age 桶；fresh<1 月、mid<3 月、stale≥3 月）。
- **口碑比對率** want/feasible=`bel.reconcile_opportunity`（親見 record 且有 ≥1 relayed 可比）/ happened=`bel.reconcile_compared`（實跑比對即 trust_up/down 的機會母數）。

- [ ] **Step 1: `has_belief` 掛 call/true counter**

`has_belief`（約 :81-82）改：

```gdscript
static func has_belief(state: WorldState, obs_id: int, tgt_id: int) -> bool:
	var r: bool = not claims(state, obs_id, tgt_id).is_empty()
	if Probe.enabled:
		Probe.bump("bel.has_belief_call")
		if r: Probe.bump("bel.has_belief_true")
	return r
```

- [ ] **Step 2: `best_estimate` 掛 call/hit + 新鮮度桶**

`best_estimate`（約 :87-97）改。在選出 best 後，用 best 的 tick 算 age 分桶。`TICKS_PER_MONTH` 走 `WorldState.TICKS_PER_MONTH`：

```gdscript
static func best_estimate(state: WorldState, obs_id: int, tgt_id: int) -> Dictionary:
	var cs: Array = claims(state, obs_id, tgt_id)
	if Probe.enabled: Probe.bump("bel.best_call")
	if cs.is_empty(): return {}
	var best: Dictionary = cs[0]
	var best_eff: float = effective_credibility(state, best)
	for c in cs:
		var eff: float = effective_credibility(state, c)
		if eff > best_eff \
				or (eff == best_eff and int(c["tick"]) > int(best["tick"])):
			best = c; best_eff = eff
	if Probe.enabled:
		Probe.bump("bel.best_hit")
		var age: int = state.world.current_tick - int(best["tick"])
		if age < WorldState.TICKS_PER_MONTH: Probe.bump("bel.claim_fresh")
		elif age < 3 * WorldState.TICKS_PER_MONTH: Probe.bump("bel.claim_mid")
		else: Probe.bump("bel.claim_stale")
	return best["value"]
```

**注意**：`best_estimate` 純讀無 randf → counter 加行零序擾。

- [ ] **Step 3: `reconcile_firsthand` 掛比對機會 counter**

`reconcile_firsthand`（約 :156-177）。`truth` 有效後、比對 loop 內加 counter。`truth <= 0.0: return` 之後（＝有親見真值＝比對前提），及每個實比對的 relayed source（進 update_reputation 前的母數）：

```gdscript
	if truth <= 0.0: return
	if Probe.enabled: Probe.bump("bel.reconcile_opportunity")
	for c in cs:
		var sid: int = int(c["source_id"])
		if sid == obs_id or c["source_type"] == "親見": continue
		if not state.teams.has(sid): continue
		var rep: float = float((c["value"] as Dictionary).get("population_est", -1.0))
		if rep <= 0.0: continue
		if Probe.enabled: Probe.bump("bel.reconcile_compared")
		var r: float = rep / truth
		if r >= 0.7 and r <= 1.3:
			obs_team.update_reputation(sid, TRUST_DELTA)
			Probe.bump("g3.trust_up")
		elif r < 0.4 or r > 2.5 or bool(c.get("distorted", false)):
			obs_team.update_reputation(sid, -TRUST_DELTA)
			Probe.bump("g3.trust_down")
```

- [ ] **Step 4: headless 綠**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `=== DONE ===`，無 `SCRIPT ERROR`。**特別驗**：belief 有回歸測（`_test_leak_*`）——確認 best_estimate/has_belief 改動未破斷言（斷言比的是回傳值，未動）。

- [ ] **Step 5: Commit**

```powershell
git add scripts/simulation/belief_system.gd
git commit -m "feat(belief): +讀取充足性 counter (has_belief/best/新鮮度/reconcile 機會)"
```

---

### Task 4: G3 識破謊言母數（belief_system.gd + message_system.gd）

**Files:**
- Modify: `scripts/simulation/message_system.gd`

**Interfaces:**
- Produces: key `g3.lie_claim`。既有 `g3.detect_信假/生疑/裁決`、`g3.scout_dispatch`、`g3.scout_converge`、`prosp.gate_scout_defer`、`g3.trust_up/down` 收編（不重做）。

三元組定義：
- **識破率** want=`g3.lie_claim`（收到 distorted claim＝有謊可識）/ feasible=同 / happened=`g3.detect_生疑`+`g3.detect_裁決`（實壓信；`信假`=沒識破）。
- **scout 收斂率** want=`prosp.gate_scout_defer`（情報不足→想查證）/ feasible=`g3.scout_dispatch`（實派）/ happened=`g3.scout_converge`（收斂轉攻）。← 全既有，Task 9 reformat。

- [ ] **Step 1: distorted claim 記錄處掛 lie_claim**

`message_system.gd` `_exchange_intel`（約 :216-228），`if distorted:` block 內、detection_discount 之後加 `g3.lie_claim`（既有 detect_* bump 已在此）：

```gdscript
			if distorted:
				Probe.bump("g3.lie_claim")
				var recv_leader: PersonData = state.persons.get(receiver.leader_id)
				var giver_leader: PersonData = state.persons.get(giver.leader_id)
				var my_skill: float = 0.0
				if recv_leader:
					my_skill = maxf(float(recv_leader.skills.get("偵查", 0.0)), float(recv_leader.skills.get("計謀", 0.0)))
				var their_scheme: float = float(giver_leader.skills.get("計謀", 0.0)) if giver_leader else 0.0
				var det: Dictionary = BeliefSystem.detection_discount(my_skill, their_scheme)
				cred *= float(det["discount"])
				entry["is_suspicious"] = bool(det["suspicious"])
				if det["discount"] == BeliefSystem.DETECT_ADJUDICATE_MULT: Probe.bump("g3.detect_裁決")
				elif det["discount"] == BeliefSystem.DETECT_SUSPECT_MULT: Probe.bump("g3.detect_生疑")
				else: Probe.bump("g3.detect_信假")
```

**注意**：`g3.lie_claim` 加在 block 開頭，不動既有 detect 邏輯與求值。

- [ ] **Step 2: headless 綠**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `=== DONE ===`，無 `SCRIPT ERROR`。

- [ ] **Step 3: Commit**

```powershell
git add scripts/simulation/message_system.gd
git commit -m "feat(g3): +謊言母數 g3.lie_claim (識破率分母)"
```

---

### Task 5: 外交提案 counters（diplomatic_ai_system.gd）

**Files:**
- Modify: `scripts/simulation/diplomatic_ai_system.gd`

**Interfaces:**
- Produces: keys `dip.proposal_sent`、`dip.proposal_handled`、`dip.proposal_accept`。既有 `envoy.dispatched/delivered/accept/reject` 收編。

三元組定義：
- **提案接受率** want=`dip.proposal_sent`（發提案）/ feasible=`dip.proposal_handled`（提案抵達決策者＝handle_diplomacy_message 實跑，排除 player-forced）/ happened=`dip.proposal_accept`（回 accept）。
- **envoy 送達率** want=`envoy.dispatched` / feasible=同 / happened=`envoy.delivered`（既有；已知 0=首列病單，QA 判）。

- [ ] **Step 1: `_send_diplomacy_message` 掛 proposal_sent**

`diplomatic_ai_system.gd` `_send_diplomacy_message`（約 :145-165）。函數尾段 NPC 分支呼 `handle_diplomacy_message` 前加 `dip.proposal_sent`（涵蓋真送出；player 分支已提早 return 不計，一致「提案給可決策 NPC」語意）。在 `print("[Diplomacy] Team%d → Team%d: %s"...)` 之後：

```gdscript
	print("[Diplomacy] Team%d → Team%d: %s" % [sender.team_id, target.team_id, action])
	Probe.bump("dip.proposal_sent")
	var response: String = handle_diplomacy_message(state, target, sender, action)
```

- [ ] **Step 2: `handle_diplomacy_message` 掛 handled + accept**

`handle_diplomacy_message`（約 :180-201）。開頭算 score 前加 `dip.proposal_handled`；`match action` 各分支回 "accept" 處加 `dip.proposal_accept`。改：

```gdscript
func handle_diplomacy_message(state: WorldState, self_team: TeamData,
		sender_team: TeamData, action: String, gift: Dictionary = {}) -> String:
	if Probe.enabled: Probe.bump("dip.proposal_handled")
	var score: float = _calc_diplomacy_score(state, self_team, sender_team, gift)
	match action:
		"propose_alliance":
			if score > ALLIANCE_ACCEPT_THRESHOLD:
				_form_alliance(state, self_team, sender_team)
				if Probe.enabled: Probe.bump("dip.proposal_accept")
				return "accept"
			return "reject"
		"propose_trade":
			if score > 0.4:
				self_team.update_reputation(sender_team.team_id, 0.05)
				sender_team.update_reputation(self_team.team_id, 0.05)
				if Probe.enabled: Probe.bump("dip.proposal_accept")
				return "accept"
			return "reject"
		"demand_tribute":
			var _acc: bool = tribute_accept(state, self_team, sender_team, 0.0)
			if _acc and Probe.enabled: Probe.bump("dip.proposal_accept")
			return "accept" if _acc else "refuse"
		"offer_surrender":
			if score > 0.3:
				if Probe.enabled: Probe.bump("dip.proposal_accept")
				return "accept"
			return "reject"
```

**注意**：`invite_settle` 及其他分支保持原樣（不在本三元組範圍；只加 accept 計數不改邏輯）。`demand_tribute` 原 `return "accept" if tribute_accept(...) else "refuse"` 拆成先算 `_acc` 再計數 return——**行為等價**（tribute_accept 呼一次，無副作用重複；確認 `tribute_accept` 純函數無 state 寫）。

- [ ] **Step 3: 確認 tribute_accept 無副作用（拆呼安全）**

Read `diplomatic_ai_system.gd:38-59`（`tribute_accept`）：確認全為讀（best_estimate/relation_edges/values 讀），無 state 寫 → 拆成 `var _acc =` 單呼安全。若發現寫副作用，改回 inline 呼叫並用旗標記數。

- [ ] **Step 4: headless 綠**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `=== DONE ===`，無 `SCRIPT ERROR`。

- [ ] **Step 5: Commit**

```powershell
git add scripts/simulation/diplomatic_ai_system.gd
git commit -m "feat(diplomacy): +提案充足性 counter (sent/handled/accept)"
```

---

### Task 6: RelationGraph tribute 邊效應 counter（diplomatic_ai_system.gd）

**Files:**
- Modify: `scripts/simulation/diplomatic_ai_system.gd`

**Interfaces:**
- Produces: keys `rel.tribute_eval`、`rel.tribute_with_edge`、`rel.tribute_edge_flipped`。

三元組定義（「feud/gratitude 邊改變 tribute_accept 結果次數 / 含邊評估次數」）：
- want=`rel.tribute_eval`（tribute_accept 評估總次數）/ feasible=`rel.tribute_with_edge`（該評估有 feud 或 gratitude 邊＝邊有機會咬）/ happened=`rel.tribute_edge_flipped`（去掉邊項後門檻穿越結果反轉＝邊真的改變了決策）。

- [ ] **Step 1: `tribute_accept` 掛三 counter（純加算，無 RNG）**

`tribute_accept`（約 :38-59，static）。原公式算完 score 後判 `score > TRIBUTE_ACCEPT_THRESHOLD`。加：算 `score_no_edge`（不含 feud/gratitude 項），比對兩者門檻穿越是否不同。改：

```gdscript
static func tribute_accept(state: WorldState, defender: TeamData, aggressor: TeamData,
		threat: float) -> bool:
	if defender.current_task == TeamData.TASK_FLEE:
		return true
	var leader: PersonData = state.persons.get(defender.leader_id) if defender.leader_id != -1 else null
	if leader == null:
		return false
	var caution: float  = float(leader.values.get("慎重", 0.5))
	var honor: float    = float(leader.values.get("義氣", 0.5))
	var survival: float = float(leader.values.get("求生欲", 0.5))
	var agg_pop_est: int = BeliefSystem.best_estimate(state, defender.team_id, aggressor.team_id) \
		.get("population_est", defender.population)
	var power_r: float = clampf(float(agg_pop_est) / maxf(float(defender.population), 1.0),
		0.0, TRIBUTE_POWER_R_CAP)
	var score_base: float = (power_r - 1.0) * TRIBUTE_W_POWER \
		+ caution * TRIBUTE_W_CAUTION - honor * TRIBUTE_W_HONOR \
		+ survival * TRIBUTE_W_SURVIVAL + leader.fear * TRIBUTE_W_FEAR \
		+ clampf(threat, 0.0, 1.0) * TRIBUTE_W_THREAT
	var edge_term: float = 0.0
	if aggressor.leader_id != -1:
		edge_term = -_edge_intensity_to(leader.relation_edges, "feud", aggressor.leader_id) * TRIBUTE_W_FEUD \
			+ _edge_intensity_to(leader.relation_edges, "gratitude", aggressor.leader_id) * TRIBUTE_W_GRATITUDE
	var score: float = score_base + edge_term
	if Probe.enabled:
		Probe.bump("rel.tribute_eval")
		if absf(edge_term) > 0.0:
			Probe.bump("rel.tribute_with_edge")
			var with: bool = score > TRIBUTE_ACCEPT_THRESHOLD
			var without: bool = score_base > TRIBUTE_ACCEPT_THRESHOLD
			if with != without: Probe.bump("rel.tribute_edge_flipped")
	return score > TRIBUTE_ACCEPT_THRESHOLD
```

**注意**：原碼 `score` 直接加 feud/gratitude 兩行。重構成 `score_base + edge_term` **數學等價**（同浮點運算次序：原 `score` 先算 base 六項，再 `score -= feud`、`score += gratitude`；新 `score_base`=六項，`edge_term`=−feud+gratitude，`score = score_base + edge_term`）。⚠ 浮點加法非結合律 → 需驗結果位元一致。若 seeded diff 出現微差，改為：保留原 `score` 逐步加法，另存 `score_before_edge`（在加 feud 前 snapshot），counter 用 snapshot 比對。見 Step 2 驗證。

- [ ] **Step 2: headless 綠 + 微驗浮點等價**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `=== DONE ===`，無 `SCRIPT ERROR`。tribute 相關測（若有）綠。若 Task 12 seeded diff 顯示 tribute 分支行為變（極不可能但浮點），回此步改用 snapshot 法：

```gdscript
	var score: float = (power_r - 1.0) * TRIBUTE_W_POWER \
		+ caution * TRIBUTE_W_CAUTION - honor * TRIBUTE_W_HONOR \
		+ survival * TRIBUTE_W_SURVIVAL + leader.fear * TRIBUTE_W_FEAR \
		+ clampf(threat, 0.0, 1.0) * TRIBUTE_W_THREAT
	var score_no_edge: float = score
	var had_edge: bool = false
	if aggressor.leader_id != -1:
		var feud_i: float = _edge_intensity_to(leader.relation_edges, "feud", aggressor.leader_id)
		var grat_i: float = _edge_intensity_to(leader.relation_edges, "gratitude", aggressor.leader_id)
		score -= feud_i * TRIBUTE_W_FEUD
		score += grat_i * TRIBUTE_W_GRATITUDE
		had_edge = feud_i > 0.0 or grat_i > 0.0
	if Probe.enabled:
		Probe.bump("rel.tribute_eval")
		if had_edge:
			Probe.bump("rel.tribute_with_edge")
			if (score > TRIBUTE_ACCEPT_THRESHOLD) != (score_no_edge > TRIBUTE_ACCEPT_THRESHOLD):
				Probe.bump("rel.tribute_edge_flipped")
	return score > TRIBUTE_ACCEPT_THRESHOLD
```
此法 `score` 逐步加法與原碼**逐位元相同**（只多一個 snapshot 讀），為安全預設。**實作時直接採 Step 2 snapshot 法**（Step 1 的重構法僅備參）。

- [ ] **Step 3: Commit**

```powershell
git add scripts/simulation/diplomatic_ai_system.gd
git commit -m "feat(relation): +tribute 邊效應 counter (eval/with_edge/flipped)"
```

---

### Task 7: intent 選擇 counters（faction_ai_system.gd 讀側）

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`（僅 `_update_goals` 及 `_set_solo`，**遠離** caravan 區 1470-1477/1949-1964 及 `_decide_unified` 1487-1540 內部）

**Interfaces:**
- Produces: keys `intent.sel_<type>`（type ∈ 征服/致富/防衛/擴張/守成/建國）、`intent.goal_emit`。既有 `conq.intent`、`conq.winner_loot/prosperity/other/none`（征服名實斷點）收編。

三元組定義（「各 intent 想=做 轉化率」）：
- want=`intent.sel_<type>`（該 intent 被選為戰略意圖＝想）/ feasible=`intent.goal_emit`（意圖生成了 ≥1 子命令）/ happened：征服走既有 `conq.winner_prosperity`/`conq.intent`（實派攻擊 winner）；其餘 intent 的 happened=goal 實 emit（`_emit_goal` 已計 per-goal）。bed 註明：非征服 intent 今僅到「goal emit」層可觀測，實派 task 一致率待 specimen 擴（QA 素材）。

- [ ] **Step 1: `_update_goals` 掛 commander intent 選擇 counter**

`faction_ai_system.gd` `_update_goals`（約 :982-985），`f.intent = intent` 後加 per-type 計數：

```gdscript
	var intent: Dictionary = _select_intent(state, f)
	f.intent = intent
	f.strategy = intent["type"]
	var itype: String = intent["type"]
	if Probe.enabled and itype != "": Probe.bump("intent.sel_" + itype)
```

- [ ] **Step 2: `_emit_goal` 掛 goal_emit counter**

`_emit_goal`（約 :1079-1084），`f.goals.append(goal)` 附近加。改：

```gdscript
func _emit_goal(state: WorldState, f, goal: String, intent_type: String, why: String, mode: String) -> void:
	if goal not in f.goals:
		f.goals.append(goal)
	f.goal_drivers[goal] = {"intent": intent_type, "why": why, "mode": mode}
	if Probe.enabled: Probe.bump("intent.goal_emit")
	SpecimenTracer.capture_intent(state, f.leader_team_id, intent_type, why, mode)
```

- [ ] **Step 3: `_set_solo` 掛獨立隊 intent 選擇 counter**

`_set_solo`（約 :1092-1094），`state.set_solo_intent(...)` 後加：

```gdscript
func _set_solo(state: WorldState, team: TeamData, itype: String, why: String, mode: String) -> void:
	state.set_solo_intent(team, itype, why, mode, "solo:" + itype)
	if Probe.enabled and itype != "": Probe.bump("intent.sel_" + itype)
	SpecimenTracer.capture_intent(state, team.team_id, itype, why, mode)
```

- [ ] **Step 4: headless 綠**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `=== DONE ===`，無 `SCRIPT ERROR`。

- [ ] **Step 5: Commit**

```powershell
git add scripts/simulation/faction_ai_system.gd
git commit -m "feat(intent): +意圖選擇 counter (sel_<type>/goal_emit, 讀側)"
```

---

### Task 8: event 型 eligible/fire counters（event_system.gd）

**Files:**
- Modify: `scripts/simulation/event_system.gd`

**Interfaces:**
- Produces: keys `evt.<name>.check`、`evt.<name>.fire`（name ∈ event_unrest_split / event_unrest_replace / event_faction_defect / event_tag_shift）。

三元組定義（「各 event 型 fire/eligible 檢查次數」）：
- want=`evt.<name>.check`（每 team-tick 該 event 的 eligibility 被檢）/ feasible=同 / happened=`evt.<name>.fire`（check 通過並 execute）。fire/check = 觸發率。

- [ ] **Step 1: `_init` 預算各 event 名（避免 per-tick 字串處理）**

`event_system.gd` 加 parallel names 陣列。改 `_init`（:5-10）：

```gdscript
var _events: Array = []
var _event_names: Array = []

func _init() -> void:
	_events.append(load("res://scripts/simulation/events/event_unrest_split.gd").new())
	_events.append(load("res://scripts/simulation/events/event_unrest_replace.gd").new())
	_events.append(load("res://scripts/simulation/events/event_faction_defect.gd").new())
	_events.append(load("res://scripts/simulation/events/event_tag_shift.gd").new())
	for e in _events:
		_event_names.append(String(e.get_script().resource_path.get_file()).get_basename())
```

- [ ] **Step 2: `process_events` loop 掛 check/fire counter（Probe-gated）**

`process_events`（:12-21）。用 index 對齊 `_event_names`。改：

```gdscript
func process_events(state: WorldState, team_ids: Array) -> Array:
	var new_teams: Array = []
	for tid in team_ids:
		if not state.teams.has(tid):
			continue
		var team: TeamData = state.teams[tid]
		for i in range(_events.size()):
			var event = _events[i]
			if Probe.enabled: Probe.bump("evt.%s.check" % _event_names[i])
			if event.check(state, team):
				if Probe.enabled: Probe.bump("evt.%s.fire" % _event_names[i])
				new_teams.append_array(event.execute(state, team))
	return new_teams
```

**注意**：原 `for event in _events` 改為 index loop 以配 `_event_names[i]`——迭代同序、`event.check`/`execute` 呼叫同參同序 → 行為不變。字串 `"evt.%s.check" %` 只在 `Probe.enabled` 內求值 → 一般跑零成本。

- [ ] **Step 3: headless 綠**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `=== DONE ===`，無 `SCRIPT ERROR`。

- [ ] **Step 4: Commit**

```powershell
git add scripts/simulation/event_system.gd
git commit -m "feat(event): +各型 eligible/fire counter (evt.<name>.check/fire)"
```

---

### Task 9: sufficiency_bed 主體 + 率表輸出（含三元組 + JSON 區塊）

**Files:**
- Create: `scripts/debug/sufficiency_bed.gd`

**Interfaces:**
- Consumes: `Probe`（enabled/reset/counts/peaks）、`WorldState`、`SimRunner.advance_tick`、`GameSetup.setup/load_config`、`WorldState.TICKS_PER_MONTH`。
- Produces: bed 印全系統率表（每列率＋三元組＋月切面）＋表尾 JSON 一行/列。env：`SUFF_SEEDS`（default "1337,2674"）、`SUFF_MONTHS`（default 6）、`SUFF_DUMP`（事件流 dump 路徑，Task 10）。

**設計要點**：
- **自然世界（無玩家）**：`GameSetup.setup` 後 `state.player_id = -1` → 所有 player 分支 skip（forced_event 不觸、以 NPC AI 跑 ex-player 隊）＝乾淨自然世界。
- **encounter 自解**：仿 warring——`state.encounter_active and state.encounter_tick > 800` → `runner._encounter_system.resolve_encounter_end(state, "draw")`。
- **月切面**：每 `TICKS_PER_MONTH` snapshot 當月 Probe.counts 快照（存 delta 供月切面），全滅哨兵。
- **三元組表**：資料驅動——一個 `ROWS` 常數陣列，每列 `{chain, label, want_key, feasible_key, happened_key, note}`，迴圈算 `happened/feasible` 率 + 印 want/feasible/happened。貿易列 note=佔位引用。

- [ ] **Step 1: 寫 bed 骨架（setup + 跑迴圈 + 月切面）**

Create `scripts/debug/sufficiency_bed.gd`:

```gdscript
extends SceneTree

# 全系統充足性率表 harness（純機器，零 sim 邏輯變）。
# default 自然世界（無玩家）× 多 seed × N 月自跑 → 全系統率表。
# 每列：分子/分母=率 + 月切面 + 想要/可行/發生 三元組（可行定義各鏈自述）。
# 表尾 machine-readable JSON（一行/列）。事件流 dump 見 --SUFF_DUMP。
# 復用 Probe：開 enabled → 既有+新增 counter 全計 → 讀 counts 排率表。
# 不判決（合理 0 vs 斷鏈 0 歸 QA）；貿易列=佔位引貿易軌漏斗。
#
# 用法（env）：
#   SUFF_SEEDS   多 seed 逗號集，default "1337,2674"
#   SUFF_MONTHS  跑幾月，default 6
#   SUFF_DUMP    事件流落檔路徑（global_messages+observer_messages）
#   SUFF_JSON    率表 machine-readable JSON 落檔路徑（可選；default 只印 stdout）

const CONFIG_PATH: String = "res://config/default.json"

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var seeds: Array = _parse_seeds()
	var months: int = int(OS.get_environment("SUFF_MONTHS")) if OS.has_environment("SUFF_MONTHS") else 6
	var ticks: int = maxi(months, 1) * WorldState.TICKS_PER_MONTH
	print("=== sufficiency_bed：seeds=%s months=%d (ticks=%d) config=%s ===" % [
		str(seeds), months, ticks, CONFIG_PATH])
	var all_results: Dictionary = {}
	for s in seeds:
		var r: Dictionary = _run_one(int(s), ticks)
		if r.is_empty():
			print("[FAIL] seed=%d 空（config 載入失敗？）" % int(s)); continue
		all_results[str(int(s))] = r
		_print_rate_table(int(s), r)
	_print_json_block(all_results)
	print("=== sufficiency_bed DONE ===")

func _parse_seeds() -> Array:
	var raw: String = OS.get_environment("SUFF_SEEDS")
	if raw == "": raw = "1337,2674"
	var out: Array = []
	for tok in raw.split(",", false):
		var t: String = tok.strip_edges()
		if t.is_valid_int(): out.append(int(t))
	return out

# 跑一 seed → 回 {seed, final_counts, final_peaks, monthly[], msg_dump{}}。
func _run_one(world_seed: int, total_ticks: int) -> Dictionary:
	seed(world_seed)                    # 播 global RNG（runtime bare randf/randi）
	Probe.enabled = true
	Probe.reset()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config(CONFIG_PATH)
	if config.is_empty():
		Probe.enabled = false
		return {}
	config["seed"] = world_seed         # 播 setup RNG（map/team/person gen local rng）
	GameSetup.setup(state, config)
	state.player_id = -1                 # 自然世界：無玩家 → 全 NPC AI 自解，無 forced_event 卡死
	var no_player := Vector2i(-1, -1)
	var monthly: Array = []
	var prev_snapshot: Dictionary = {}
	for tick in range(total_ticks):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if (tick + 1) % WorldState.TICKS_PER_MONTH == 0:
			var cur: Dictionary = Probe.counts.duplicate(true)
			monthly.append({
				"month": (tick + 1) / WorldState.TICKS_PER_MONTH,
				"delta": _counts_delta(prev_snapshot, cur),
				"teams": state.teams.size(),
				"pop": _total_pop(state),
			})
			prev_snapshot = cur
		if state.teams.is_empty():
			monthly.append({"month": -1, "delta": {}, "teams": 0, "pop": 0})
			break
	var result: Dictionary = {
		"seed": world_seed,
		"final_counts": Probe.counts.duplicate(true),
		"final_peaks": Probe.peaks.duplicate(true),
		"monthly": monthly,
		"msg_dump": _collect_msg_dump(state),
	}
	Probe.enabled = false
	return result

func _counts_delta(prev: Dictionary, cur: Dictionary) -> Dictionary:
	var d: Dictionary = {}
	for k in cur:
		var p: int = int(prev.get(k, 0))
		if int(cur[k]) - p != 0:
			d[k] = int(cur[k]) - p
	return d

func _total_pop(state: WorldState) -> int:
	var n: int = 0
	for tid in state.teams: n += state.teams[tid].population
	return n

func _collect_msg_dump(_state: WorldState) -> Dictionary:
	return {}   # Task 10 填
```

- [ ] **Step 2: 寫率表輸出（ROWS 資料驅動 + 三元組 + 月切面）**

在同檔加 `ROWS` 常數與 `_print_rate_table`/`_rate`：

```gdscript
# 率表列定義。want/feasible/happened = Probe counts key（缺→0）。
# rate = happened / feasible。可行(feasible)定義寫在 note（各鏈自述），供 QA 判合理 0 vs 斷鏈 0。
const ROWS: Array = [
	# 貿易：佔位引貿易軌六站漏斗（本軌不重做）
	{"chain": "貿易", "label": "六站漏斗", "want": "", "feasible": "", "happened": "",
	 "note": "佔位——引貿易軌 g1.order_placed→board_read→arb_hit→order_fulfilled 六站，本軌不重做"},
	# 消息傳播
	{"chain": "消息傳播", "label": "送達/發出", "want": "msg.sent", "feasible": "msg.prop_candidate", "happened": "msg.delivered",
	 "note": "可行=同格鄰隊有未知訊息(可傳機會);想要=emit_message 發出;發生=copy 實 append receiver"},
	{"chain": "消息傳播", "label": "失真/傳播", "want": "msg.prop_done", "feasible": "msg.prop_done", "happened": "msg.distorted",
	 "note": "可行=實傳 copy 總數;發生=標 distorted 的 copy"},
	{"chain": "消息傳播", "label": "消費/送達", "want": "msg.delivered", "feasible": "msg.delivered", "happened": "g1.board_read",
	 "note": "消費=訂單看板讀(唯一有決策消費者的 msg 類);非 order 類今無消費 chokepoint→結構性缺(QA 素材)"},
	# belief
	{"chain": "belief", "label": "實質讀/問", "want": "bel.has_belief_call", "feasible": "bel.has_belief_true", "happened": "bel.best_hit",
	 "note": "想要=決策問 has_belief;可行=有 claim;發生=best_estimate 回非空(實讀到估值)。fallback 路徑=has_belief_call−has_belief_true"},
	{"chain": "belief", "label": "口碑比對/機會", "want": "bel.reconcile_opportunity", "feasible": "bel.reconcile_opportunity", "happened": "bel.reconcile_compared",
	 "note": "可行=親見 record 有 relayed 可比;發生=實比對(→trust_up/down 母數)"},
	# G3 識破
	{"chain": "G3識破", "label": "識破/謊言", "want": "g3.lie_claim", "feasible": "g3.lie_claim", "happened_sum": ["g3.detect_生疑", "g3.detect_裁決"],
	 "note": "可行=收到 distorted claim;發生=生疑+裁決(信假=沒識破)"},
	{"chain": "G3識破", "label": "scout 收斂/派出", "want": "prosp.gate_scout_defer", "feasible": "g3.scout_dispatch", "happened": "g3.scout_converge",
	 "note": "想要=情報不足想查證;可行=實派斥候;發生=收斂轉攻"},
	# 外交
	{"chain": "外交", "label": "提案 accept/發出", "want": "dip.proposal_sent", "feasible": "dip.proposal_handled", "happened": "dip.proposal_accept",
	 "note": "可行=提案抵達決策者(handle 實跑);發生=回 accept"},
	{"chain": "外交", "label": "envoy 送達/派出", "want": "envoy.dispatched", "feasible": "envoy.dispatched", "happened": "envoy.delivered",
	 "note": "既有;已知 delivered≈0=首列病單(QA 判)"},
	# RelationGraph
	{"chain": "RelationGraph", "label": "邊改結果/含邊評估", "want": "rel.tribute_eval", "feasible": "rel.tribute_with_edge", "happened": "rel.tribute_edge_flipped",
	 "note": "可行=tribute_accept 評估含 feud/gratitude 邊;發生=去邊後門檻結果反轉(邊真咬)"},
	# 意圖→行為
	{"chain": "意圖→行為", "label": "征服 想=做", "want": "intent.sel_征服", "feasible": "conq.intent", "happened": "conq.winner_prosperity",
	 "note": "想要=選征服意圖;可行=_decide_unified 見征服隊;發生=實派 prosperity 攻擊 winner。其餘 intent 見 sel_<type>/goal_emit(未到 task 層,QA 素材)"},
	# 捕俘/同化/佔村/立國（既有漏斗收編）
	{"chain": "捕俘", "label": "capture/戰", "want": "conq.combat_entered", "feasible": "conq.combat_entered", "happened": "capture.total",
	 "note": "既有漏斗;可行=進戰鬥;發生=產生俘虜"},
	{"chain": "同化", "label": "assimilate/capture", "want": "capture.total", "feasible": "capture.total", "happened": "p1.assimilate",
	 "note": "既有;可行=有俘;發生=同化啟動"},
	{"chain": "佔村", "label": "flip/dispatch", "want": "occupy.dispatch", "feasible": "occupy.dispatch", "happened": "occupy.capture_flip",
	 "note": "既有;可行=派佔村;發生=翻旗"},
	{"chain": "立國", "label": "found/夠格", "want": "indep.gate_ambitious", "feasible": "indep.gate_path_ok", "happened": "g2.faction_found",
	 "note": "既有;想要=野心夠;可行=路徑可達;發生=立國完成"},
	# 事件系統（各型 fire/check，Task 9b 動態補）
]

func _get(counts: Dictionary, key: String) -> int:
	return int(counts.get(key, 0))

func _happened_val(counts: Dictionary, row: Dictionary) -> int:
	if row.has("happened_sum"):
		var s: int = 0
		for k in row["happened_sum"]: s += _get(counts, k)
		return s
	return _get(counts, row.get("happened", ""))

func _rate_str(hap: int, feas: int) -> String:
	if feas == 0: return "n/a"
	return "%.1f%%" % (100.0 * float(hap) / float(feas))

func _print_rate_table(s: int, r: Dictionary) -> void:
	var counts: Dictionary = r["final_counts"]
	print("\n────────── [充足性率表] seed=%d ──────────" % s)
	print("%-14s %-18s %8s   想要/可行/發生   定義" % ["鏈", "列", "率"])
	for row in ROWS:
		if String(row.get("want", "")) == "" and not row.has("happened_sum") and String(row.get("happened","")) == "":
			print("%-14s %-18s %8s   [%s]" % [row["chain"], row["label"], "—", row["note"]])
			continue
		var want: int = _get(counts, row.get("want", ""))
		var feas: int = _get(counts, row.get("feasible", ""))
		var hap: int = _happened_val(counts, row)
		print("%-14s %-18s %8s   %d/%d/%d   %s" % [
			row["chain"], row["label"], _rate_str(hap, feas), want, feas, hap, row["note"]])
	# 事件系統動態列（各 evt.<name>.fire / .check）
	print("── 事件系統（各型 fire/check）──")
	var evt_names: Dictionary = {}
	for k in counts:
		if String(k).begins_with("evt.") and String(k).ends_with(".check"):
			evt_names[String(k).trim_prefix("evt.").trim_suffix(".check")] = true
	for name in evt_names:
		var chk: int = _get(counts, "evt.%s.check" % name)
		var fire: int = _get(counts, "evt.%s.fire" % name)
		print("%-14s %-18s %8s   %d/%d/%d   可行=eligibility 檢查;發生=fire" % [
			"事件", name, _rate_str(fire, chk), chk, chk, fire])
	# 月切面（各 seed）
	print("── 月切面 delta（非零 counter/月）──")
	for m in r["monthly"]:
		print("[月%s] teams=%d pop=%d delta=%s" % [
			str(m["month"]), int(m["teams"]), int(m["pop"]), str(m["delta"])])
```

- [ ] **Step 3: 寫 JSON 區塊輸出**

加 `_print_json_block`（表尾 machine-readable，一 seed 一行、率表列一物件）：

```gdscript
func _print_json_block(all_results: Dictionary) -> void:
	print("\n────────── [JSON 區塊] machine-readable（parse 得動）──────────")
	for sk in all_results:
		var r: Dictionary = all_results[sk]
		var counts: Dictionary = r["final_counts"]
		var rows_out: Array = []
		for row in ROWS:
			if String(row.get("want", "")) == "" and not row.has("happened_sum") and String(row.get("happened","")) == "":
				continue
			var want: int = _get(counts, row.get("want", ""))
			var feas: int = _get(counts, row.get("feasible", ""))
			var hap: int = _happened_val(counts, row)
			rows_out.append({
				"chain": row["chain"], "label": row["label"],
				"want": want, "feasible": feas, "happened": hap,
				"rate": (float(hap) / float(feas)) if feas > 0 else null,
			})
		var obj: Dictionary = {"seed": int(sk), "rows": rows_out}
		print("[SUFF_JSON] " + JSON.stringify(obj))
	# 可選：落檔
	var json_path: String = OS.get_environment("SUFF_JSON")
	if json_path != "":
		var f := FileAccess.open(json_path, FileAccess.WRITE)
		if f != null:
			f.store_string(JSON.stringify(all_results, "  ")); f.close()
			print("[bed] 率表 JSON 已寫 → %s" % json_path)
```

- [ ] **Step 4: 跑 bed，驗率表完整**

Run:
```powershell
.\tools\godot.ps1 --headless --script scripts/debug/sufficiency_bed.gd
```
Expected: 見 `=== sufficiency_bed DONE ===`，無 `SCRIPT ERROR`。率表印出兩 seed（1337/2674）、全列有值（率或 n/a）、全帶分母（想要/可行/發生三元組）、`[SUFF_JSON]` 行可見、事件系統列印出四型。

- [ ] **Step 5: Commit**

```powershell
git add scripts/debug/sufficiency_bed.gd
git commit -m "feat(bed): sufficiency_bed 率表主體 (三元組+月切面+JSON 區塊)"
```

---

### Task 10: 事件流 dump（global_messages + observer_messages 落檔）

**Files:**
- Modify: `scripts/debug/sufficiency_bed.gd`（`_collect_msg_dump` 填實 + `_run` 尾 dump 落檔）

**Interfaces:**
- Consumes: `WorldState.global_messages`、`WorldState.observer_messages`（元素 = MessageData：id/type/description/source_pos/origin_team_id/origin_tick/strength/is_distorted/params）。
- Produces: `SUFF_DUMP` 路徑 JSON——`{seed → {global:[...], observer:[...]}}`。headless 直讀 state，不依賴 observer GUI dump（與貿易軌 `--obs-ticker-dump` 互補不撞檔）。

- [ ] **Step 1: `_collect_msg_dump` 填實**

替換 Task 9 的 stub：

```gdscript
func _collect_msg_dump(state: WorldState) -> Dictionary:
	return {
		"global": _msgs_to_array(state.global_messages),
		"observer": _msgs_to_array(state.observer_messages),
	}

func _msgs_to_array(msgs: Array) -> Array:
	var out: Array = []
	for m in msgs:
		out.append({
			"id": m.id, "type": m.type, "desc": m.description,
			"pos": [m.source_pos.x, m.source_pos.y],
			"origin_team": m.origin_team_id, "origin_tick": m.origin_tick,
			"strength": m.strength, "distorted": m.is_distorted,
			"params": m.params,
		})
	return out
```

- [ ] **Step 2: `_run` 尾把各 seed msg_dump 落檔**

在 `_run` 的 `_print_json_block(all_results)` 之後、`print("=== ... DONE ===")` 之前加：

```gdscript
	var dump_path: String = OS.get_environment("SUFF_DUMP")
	if dump_path != "":
		var dump: Dictionary = {}
		for sk in all_results:
			dump[sk] = all_results[sk]["msg_dump"]
		var f := FileAccess.open(dump_path, FileAccess.WRITE)
		if f == null:
			print("[FAIL] 無法寫 SUFF_DUMP=%s" % dump_path)
		else:
			f.store_string(JSON.stringify(dump, "  ")); f.close()
			var g0: int = int(all_results.values()[0]["msg_dump"]["global"].size()) if not all_results.is_empty() else 0
			print("[bed] 事件流 dump 已寫 → %s (seed0 global=%d)" % [dump_path, g0])
```

- [ ] **Step 3: 跑 bed 帶 dump，驗檔可讀**

Run:
```powershell
$env:SUFF_DUMP="C:\Users\I12\AppData\Local\Temp\claude\A--GDS-demo\0b135767-0a07-4116-9b28-7037a8748fc8\scratchpad\suff_eventdump.json"; .\tools\godot.ps1 --headless --script scripts/debug/sufficiency_bed.gd
Get-Content "C:\Users\I12\AppData\Local\Temp\claude\A--GDS-demo\0b135767-0a07-4116-9b28-7037a8748fc8\scratchpad\suff_eventdump.json" | Select-Object -First 5
```
Expected: 印 `[bed] 事件流 dump 已寫 → ...`，檔 parse 得動（JSON 開頭 seed key + global/observer 陣列）。

- [ ] **Step 4: Commit**

```powershell
git add scripts/debug/sufficiency_bed.gd
git commit -m "feat(bed): 事件流 dump (global+observer messages 落檔)"
```

---

### Task 11: docs 更新（progress + known_issues 佔位，harness spec 兌現）

**Files:**
- Modify: `docs/progress.md`（記 harness 落地）
- Modify: `docs/known_issues.md`（若有 harness spec 待固化常駐項）

- [ ] **Step 1: progress.md 加一段**

Read `docs/progress.md` 尾段，append 記錄（依既有格式）：sufficiency_bed 落地、率表+三元組+事件流 dump、counters 零行為變（seeded diff=0 證）、貿易列佔位、待 QA 跑判。縮減版常駐回歸留 backlog。

- [ ] **Step 2: 確認格式一致，commit**

```powershell
git add docs/progress.md docs/known_issues.md
git commit -m "docs(progress): sufficiency_bed harness 落地紀錄"
```

---

### Task 12: 驗收 — 中立性 diff=0 + 回歸全綠

**Files:**
- 無碼改（純驗證）。

- [ ] **Step 1: seeded warring 逐點對照（中立性總證）**

Run:
```powershell
$env:WARRING_BASELINE="C:\Users\I12\AppData\Local\Temp\claude\A--GDS-demo\0b135767-0a07-4116-9b28-7037a8748fc8\scratchpad\warring_baseline.json"; .\tools\godot.ps1 --headless --script scripts/debug/seeded_warring_bed.gd
```
Expected: 每 seed 印 `[same] seed=... 逐點相同（零行為變）`，末行 `total_diffs=0（0=零行為變證）`。
**若非 0**：定位 diff path（哪 metric 變）→ 回對應 counter task（最可能 Task 6 tribute 浮點；用 snapshot 法）修 → 重跑。counter 是純加行不該有 diff。

- [ ] **Step 2: headless 回歸綠**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `=== DONE ===`，無 `SCRIPT ERROR`。

- [ ] **Step 3: framework validation 綠**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/framework_validation.gd`
Expected: 見完成標記，無 `SCRIPT ERROR`（framework 綠）。

- [ ] **Step 4: coin_eq 守恆（headless 內含 或 game_sim_multi 抽驗）**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd`
Expected: `[CoinAudit] ... delta=0.00`（或既有容差內），無 `SCRIPT ERROR`。

- [ ] **Step 5: bed 最終完整跑（率表+dump 一次到位）**

Run:
```powershell
$env:SUFF_DUMP="...\scratchpad\suff_eventdump.json"; $env:SUFF_JSON="...\scratchpad\suff_ratetable.json"; .\tools\godot.ps1 --headless --script scripts/debug/sufficiency_bed.gd
```
Expected: 率表兩 seed 全列有值全帶分母、JSON 區塊 parse 得動、事件流 dump 落檔。**保存此輸出**（handback 附率表原始輸出，不附判決）。

- [ ] **Step 6: push branch**

```powershell
git push -u origin feat/sufficiency-rate-harness
```

- [ ] **Step 7: 寫 handback**

寫 `docs/superpowers/handbacks/2026-07-04-sufficiency-rate-harness.md`：實作摘要（每檔一行）、與 spec 差異（自然世界 player_id=-1 決策、消費/非征服 intent 的 happened 定義降級為結構性缺 note）、連動風險（Probe 新 key 不入 warring PROBE_KEYS 故 warring JSON 不變；event_system loop 改 index 迭代同序）、**附率表原始輸出（不附判決）**、待主 session 確認（縮減版常駐回歸固化排程、消費 chokepoint 是否補）。Commit handback。

- [ ] **Step 8: finishing-a-development-branch**

用 `superpowers:finishing-a-development-branch`。選單彈出時直接選 Keep the branch as-is（主 session 負責 merge），不向用戶提問。回報分支給用戶。

---

## Self-Review

**1. Spec coverage**（逐項對 spec）：
- ✅ 產出物1 `sufficiency_bed.gd` default 兩 seed 各 6 月 → Task 9 `_run`（SUFF_SEEDS default "1337,2674"、SUFF_MONTHS default 6）。
- ✅ 產出物2 輸出格式（率+月切面+三元組+JSON 一行/列）→ Task 9 `_print_rate_table`/`_print_json_block`，ROWS 帶 want/feasible/happened+note。
- ✅ 產出物3 事件流 dump（global+observer，headless 直讀）→ Task 10。
- ✅ 率表列（貿易佔位/消息/belief/G3/外交/RelationGraph/意圖→行為/捕俘同化佔村立國/事件系統）→ ROWS 全覆蓋 + 事件動態列。
- ✅ 硬約束 counters 零行為變（純 Probe.bump 加行、randf 不重排）→ 每 counter task 註明；Task 12 seeded diff=0 證。
- ✅ counter 放 chokepoint/單寫者入口 → emit_message/best_estimate/has_belief/record 入口/tribute_accept/event loop。
- ✅ 不修病 → 全 task 只加計數。
- ✅ 驗收1-4 → Task 12（率表/dump/回歸綠/diff=0/handback 附率表不附判決）。
- ✅ scope 勿碰 order/interaction trade/options/observer → Global Constraints + Task 7 caravan 區明列。

**2. Placeholder scan**：無 TBD/TODO。每 code step 有完整碼。貿易列是 spec 要求的佔位（非計畫 placeholder）。

**3. Type consistency**：Probe key 命名跨 task 一致（msg./bel./g3./dip./rel./intent./evt.）；`_get`/`_happened_val`/`_rate_str` 簽名一致；ROWS 物件 key（want/feasible/happened/happened_sum/note）在 `_print_rate_table` 與 `_print_json_block` 同構讀取。`WorldState.TICKS_PER_MONTH` 全處一致。

**風險備註**：Task 6 tribute 浮點等價——採 Step 2 snapshot 法（逐位元同原碼）為預設，Step 1 重構法僅備參。Task 9 `runner._encounter_system` 私有存取——仿 warring_harness:56 既有用法，確認欄位名一致（實作時若名不符，grep `_encounter_system` 對齊）。
