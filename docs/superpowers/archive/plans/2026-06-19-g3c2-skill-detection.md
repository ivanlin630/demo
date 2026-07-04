# G3c-2 技能識破 + 觀察吃技能 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 技能 = 理解力（WHAT §6）。(1) **技能識破**：收到謊言時按「我技能 vs 對方計謀」分級 **信假→生疑→裁決**，折扣該 claim 可信度（非 un-distort，真值不隨行）→ 高計謀大說謊家騙過低技能、笨拙謊對高技能透明。(2) **觀察吃技能**：低技能者親見也誤判 → 在源頭生出他自己深信(cred 1.0)的**錯 claim**（觀察品質 = 觀察者技能）。

**Architecture:** G3c-1 已 `source_credibility`(type×trust×hop) + `effective_credibility`(×time) + best_estimate 排 effective。本 plan：
- **識破** = message 收到 distorted claim 時，`detection_discount(my_skill, giver_計謀)` 折 stored credibility → best_estimate 排序消費（謊低於誠實/親見 = 「可靠源壓謊」）。**消費者 = best_estimate cred 排序**（非 dormant flag）。
- **觀察吃技能** = vision/interaction 親見寫值時，noise 加技能項（低 偵查/戰術 → 放大誤差），cred 仍 1.0（深信的錯值）。
- 兩者 pure helper 抽進 `BeliefSystem`（static，免 sim 單測）。

**Tech Stack:** Godot 4.2.2 GDScript；`BeliefSystem`/`message_system`/`vision_system`/`interaction_system`；skills dict（PersonData，0..1，key 中文：偵查/計謀/戰術…）；headless harness。

## Global Constraints

- wrapper 跑；改後 `--import`。
- WHAT/HOW 來源：`specs/2026-06-19-g3-info-decision-design`（§6 技能=理解力）、`...-how-design`（§4 G3c-2、§7）。
- 回歸閘：`=== DONE ===` + 0 assert fail + coin_eq=0 + InvariantAudit 0 + 1000 Tick。不用 multi drift。
- **行為允許變**（識破折 cred → best_estimate 排序變；觀察噪 → 親見值分佈變）；閘 = 不崩+守恆，非零漂移。
- **OUT（非本 plan）**：決策讀 uncertainty + scout 主動查證（G3d；裁決級的「觸發查證」只在 G3d 接，本層裁決 = 強折 cred + flag）；team_known 事件謠言 claim 化（G3d/專案）；戰術識破伏兵/佯動（戰鬥域，非 belief，OUT）。

## 鎖定設計決策（實作者勿再設計）

- **識破效果 = 折 credibility**（best_estimate 排序吃）。`is_suspicious` 現**無決策消費者**（G3b 只寫不讀=dormant）→ 本 plan 改由 cred 折扣承載行為效果，is_suspicious 降為 UI/G3d 提示 flag（保留寫，不作唯一效果，免再 dormant）。
- **識破只作用於 distorted claim**（mode unintentional/malicious）。honest/親見 不折（基礎版不誤判誠實源；false-positive 留後續）。「我技能」= `max(receiver_leader 偵查, 計謀)`（理解力雙技能取高）；「對方計謀」= `giver_leader 計謀`。
- **分級（TEST VALUE）**：`detect = clamp(my_skill − giver_計謀×DETECT_SCHEME_GAIN, 0, 1)`：
  - `detect < DETECT_SUSPECT_T(0.3)` = **信假** → discount 1.0（全信，被騙）。
  - `[0.3, 0.6)` = **生疑** → discount `DETECT_SUSPECT_MULT(0.5)` + suspicious。
  - `≥ DETECT_ADJUDICATE_T(0.6)` = **裁決** → discount `DETECT_ADJUDICATE_MULT(0.2)` + suspicious（查證 dispatch = G3d）。
  - `cred_final = source_credibility × discount`。**非 un-distort**：claim.value 不動，只壓信。高計謀 giver → detect 低 → 不折 → 騙過。
- **觀察吃技能**：`observation_noise(base_noise, skill) = clamp(base_noise + (1 − skill) × OBS_SKILL_NOISE_GAIN(0.5), 0, 1)`。
  - vision `_write_tier01` pop_est：`noise` 由 `1.0 - dist_f` → `BeliefSystem.observation_noise(1.0 - dist_f, 偵查)`（偵查 = observer leader）。低偵查 → 即使近距離殘留噪 → 高 conf 親見錯值。
  - interaction `_write_tier2` armed_est：observer 端 `戰術` 低 → armed_est 加誤判（軍略不足看不懂武裝）。在現 deceive 邏輯**後**疊 observer-side 戰術噪（`armed_est *= randf_range(1-n, 1+n)`，`n = observation_noise(0, 戰術)`），clamp ≥0。
  - **cred 仍 1.0**（親見源質不變；錯的是值不是信）。
  - **bounded**：OBS_SKILL_NOISE_GAIN TEST VALUE，限幅免炸平衡。
- **interaction risk（記 known_issues）**：觀察吃技能 → 親見 truth 本身可能錯 → G3c-1 `reconcile_firsthand` 拿錯 truth 比對 relayed → 可能誤罰對的 source。主題 coherent（你看錯怪線人），balance watch；若量測顯線人信用噪過大 → reconcile gate by observer 偵查 或降 gain（後續）。

## File Structure

- `scripts/simulation/belief_system.gd`（加 const + `detection_discount`/`observation_noise` static pure）。
- `scripts/simulation/message_system.gd`（`_exchange_intel`：識破折 cred，取代 dormant is_suspicious randf 塊）。
- `scripts/simulation/vision_system.gd`（`_write_tier01` noise 吃 偵查）、`interaction_system.gd`（`_write_tier2_intel` armed 吃 戰術）。
- `scripts/debug/headless_test.gd`、`docs/invariants.md`、`docs/known_issues.md`、`docs/progress.md`。

---

### Task 1: 技能識破（信假/生疑/裁決 折 credibility）

**Files:**
- Modify: `scripts/simulation/belief_system.gd`（const + `detection_discount`）、`scripts/simulation/message_system.gd`（`_exchange_intel`）
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- `BeliefSystem.detection_discount(my_skill: float, their_scheme: float) -> Dictionary`：回 `{"discount": float, "suspicious": bool}`（pure）。
- message `_exchange_intel`：distorted 時 `cred *= detection_discount(max(recv 偵查,計謀), giver 計謀).discount`；set `entry["is_suspicious"]`。

- [ ] **Step 1: 寫失敗測試**（pure helper 確定性）

```gdscript
func _test_detection_discount() -> void:
	print("--- G3c-2：技能識破分級 ---")
	# 信假：低技能 vs 高計謀 → discount==1.0, suspicious==false
	var d0: Dictionary = BeliefSystem.detection_discount(0.1, 0.9)
	assert(d0["discount"] == 1.0 and d0["suspicious"] == false, "低技能信假")
	# 生疑：中
	var d1: Dictionary = BeliefSystem.detection_discount(0.5, 0.1)  # detect≈0.42
	assert(d1["discount"] < 1.0 and d1["discount"] > 0.3 and d1["suspicious"], "中技能生疑")
	# 裁決：高技能 vs 低計謀
	var d2: Dictionary = BeliefSystem.detection_discount(0.9, 0.0)  # detect=0.9
	assert(d2["discount"] <= 0.2 and d2["suspicious"], "高技能裁決強折")
	# 高計謀騙過中技能：my=0.5 their=0.6 → detect≈0.02 → 信假
	var d3: Dictionary = BeliefSystem.detection_discount(0.5, 0.6)
	assert(d3["discount"] == 1.0, "高計謀說謊家騙過")
	print("detection OK")
```

- [ ] **Step 2: 跑 harness 驗證失敗**

- [ ] **Step 3: 實作**

`belief_system.gd`（const 區 + helper）：
```gdscript
const DETECT_SCHEME_GAIN := 0.8       # TEST VALUE：對方計謀壓低我識破
const DETECT_SUSPECT_T := 0.3         # TEST VALUE：生疑門檻
const DETECT_ADJUDICATE_T := 0.6      # TEST VALUE：裁決門檻
const DETECT_SUSPECT_MULT := 0.5      # TEST VALUE：生疑 cred 折扣
const DETECT_ADJUDICATE_MULT := 0.2   # TEST VALUE：裁決 cred 折扣

# 識破分級（信假/生疑/裁決）：我理解力 vs 對方計謀 → cred 折扣 + 疑點 flag。
# 非 un-distort（真值不隨行）：只壓對該謊的信任，不還原值。
static func detection_discount(my_skill: float, their_scheme: float) -> Dictionary:
	var detect: float = clampf(my_skill - their_scheme * DETECT_SCHEME_GAIN, 0.0, 1.0)
	if detect >= DETECT_ADJUDICATE_T:
		return { "discount": DETECT_ADJUDICATE_MULT, "suspicious": true }
	if detect >= DETECT_SUSPECT_T:
		return { "discount": DETECT_SUSPECT_MULT, "suspicious": true }
	return { "discount": 1.0, "suspicious": false }
```

`message_system._exchange_intel`：取代 G3c-1 後的 `var distorted` + 舊 `is_suspicious` randf 塊：
```gdscript
		var distorted: bool = mode in ["unintentional", "malicious"]
		if distorted:
			var recv_leader: PersonData = state.persons.get(receiver.leader_id)
			var giver_leader: PersonData = state.persons.get(giver.leader_id)
			var my_skill: float = 0.0
			if recv_leader:
				my_skill = maxf(float(recv_leader.skills.get("偵查", 0.0)), float(recv_leader.skills.get("計謀", 0.0)))
			var their_scheme: float = float(giver_leader.skills.get("計謀", 0.0)) if giver_leader else 0.0
			var det: Dictionary = BeliefSystem.detection_discount(my_skill, their_scheme)
			cred *= float(det["discount"])
			entry["is_suspicious"] = bool(det["suspicious"])
		BeliefSystem.record_claim(state, receiver_id, tgt_id, giver_id, stype, entry, cred, distorted)
```
**刪** G3c-1 殘留的 `# 偵查識破` randf is_suspicious 塊（:233-240 那段 `if randf() < intel_skill*0.5 …`）—— 由上面分級取代（is_suspicious 改進 entry 寫入前）。

- [ ] **Step 4: --import + 回歸**；Expected `detection OK`、`=== DONE ===`、coin_eq=0、1000 Tick。既有 message 交換測試若依賴舊 is_suspicious randf 行為 → 對齊新分級。

- [ ] **Step 5: Commit**
```bash
git add scripts/simulation/belief_system.gd scripts/simulation/message_system.gd scripts/debug/headless_test.gd
git commit -m "feat(g3c2): 技能識破 信假/生疑/裁決 折 credibility(消費者=best_estimate,取代 dormant is_suspicious)"
```

---

### Task 2: 觀察吃技能（親見值誤差吃觀察者技能）

**Files:**
- Modify: `scripts/simulation/belief_system.gd`（`observation_noise`）、`scripts/simulation/vision_system.gd`、`scripts/simulation/interaction_system.gd`
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- `BeliefSystem.observation_noise(base_noise: float, skill: float) -> float`：低技能 → 放大噪（pure）。

- [ ] **Step 1: 寫失敗測試**（pure helper）

```gdscript
func _test_observation_noise() -> void:
	print("--- G3c-2：觀察吃技能 ---")
	# 高技能 → 趨近 base
	assert(abs(BeliefSystem.observation_noise(0.0, 1.0) - 0.0) < 0.001, "滿技能無額外噪")
	# 低技能 → 殘留噪（即使 base=0）
	assert(BeliefSystem.observation_noise(0.0, 0.0) > 0.3, "零技能高殘留噪")
	# 單調：低技能噪 > 高技能噪（同 base）
	assert(BeliefSystem.observation_noise(0.2, 0.2) > BeliefSystem.observation_noise(0.2, 0.8), "技能↑噪↓")
	# 限幅 ≤1
	assert(BeliefSystem.observation_noise(1.0, 0.0) <= 1.0, "限幅")
	print("observation OK")
```

- [ ] **Step 2: 跑 harness 驗證失敗**

- [ ] **Step 3: 實作**

`belief_system.gd`：
```gdscript
const OBS_SKILL_NOISE_GAIN := 0.5     # TEST VALUE：低技能額外觀察噪

# 觀察品質吃觀察者技能：base = 距離噪；低技能疊殘留噪（親見也錯，cred 仍 1.0）。
static func observation_noise(base_noise: float, skill: float) -> float:
	return clampf(base_noise + (1.0 - clampf(skill, 0.0, 1.0)) * OBS_SKILL_NOISE_GAIN, 0.0, 1.0)
```

`vision_system._write_tier01`：`var noise: float = 1.0 - dist_f` → 
```gdscript
	var obs_team: TeamData = state.teams.get(obs_id)
	var scout_skill: float = 0.0
	if obs_team:
		var obs_leader: PersonData = state.persons.get(obs_team.leader_id)
		if obs_leader: scout_skill = float(obs_leader.skills.get("偵查", 0.0))
	var noise: float = BeliefSystem.observation_noise(1.0 - dist_f, scout_skill)
```

`interaction_system._write_tier2_intel`：deceive 邏輯**後**、`record_claim` **前**，疊 observer 戰術噪於 armed_est：
```gdscript
	var obs_leader2: PersonData = state.persons.get((state.teams.get(obs_id) as TeamData).leader_id) if state.teams.has(obs_id) else null
	var tactic: float = float(obs_leader2.skills.get("戰術", 0.0)) if obs_leader2 else 0.0
	var armed_noise: float = BeliefSystem.observation_noise(0.0, tactic)
	snap["armed_est"] = maxi(0, roundi(float(snap["armed_est"]) * randf_range(1.0 - armed_noise, 1.0 + armed_noise)))
```

- [ ] **Step 4: --import + 回歸**；Expected `observation OK`、`=== DONE ===`、coin_eq=0、InvariantAudit 0、1000 Tick。注意：親見值現帶技能噪 → 既有依賴精確 pop_est/armed_est 的測試容差需放寬（或用高技能 leader 構造）。

- [ ] **Step 5: Commit**
```bash
git add scripts/simulation/belief_system.gd scripts/simulation/vision_system.gd scripts/simulation/interaction_system.gd scripts/debug/headless_test.gd
git commit -m "feat(g3c2): 觀察吃技能 親見值噪吃偵查/戰術(低技能深信錯值,cred 仍 1.0)"
```

---

### Task 3: invariant + debt + 回歸

**Files:**
- Modify: `docs/invariants.md`、`docs/known_issues.md`、`docs/progress.md`

- [ ] **Step 1: invariant 補**

`docs/invariants.md` belief 段補：
```markdown
- **技能識破**：收 distorted claim 時 `detection_discount(我 max(偵查,計謀), 對方計謀)` 折 claim credibility（信假1.0/生疑0.5/裁決0.2）。**非 un-distort**（值不動，只壓信）。效果經 best_estimate cred 排序（謊低於誠實/親見）。
- **觀察吃技能**：親見值噪 = `observation_noise(距離噪, 觀察者技能)`，低技能殘留噪 → 高 conf 親見可錯值（cred 仍 1.0）。源頭 claim 正確性 = 觀察者技能函數。
```

- [ ] **Step 2: known_issues/progress + debt**

- progress：G3c-2 ✅（技能識破折 cred + 觀察吃技能）。G3d（決策讀 uncertainty + scout 主動查證；裁決級觸發查證在此接）/ team_known claim 化 = 待。**G3c 全收（c-1+c-2）→ 魂的「源質+理解力」層完成；缺決策消費（G3d）**。
- TEST VALUE 記：DETECT_SCHEME_GAIN/SUSPECT_T/ADJUDICATE_T/SUSPECT_MULT/ADJUDICATE_MULT、OBS_SKILL_NOISE_GAIN。
- debt：is_suspicious 由 dormant → cred 折扣承載效果（flag 留 UI/G3d）。**觀察吃技能 × reconcile 交互**（記 known_issues）：親見 truth 可能錯 → G3c-1 reconcile 誤罰對的 source；balance watch，量測線人信用噪過大 → reconcile gate by 偵查 或降 gain。

- [ ] **Step 3: 全回歸**
```
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
```
Expected: `=== DONE ===`、coin_eq=0、InvariantAudit 0、1000 Tick。

- [ ] **Step 4: Commit**
```bash
git add docs/invariants.md docs/known_issues.md docs/progress.md
git commit -m "docs(g3c2): 技能識破+觀察吃技能 invariant + 進度 + reconcile 交互 watch"
```

---

## Self-Review 註記

- **識破有真消費者**：折 cred → best_estimate 排序（謊排親見/誠實下）。**不**留 is_suspicious 當唯一效果（dormant 教訓）；flag 降 UI/G3d 用。
- **非 un-distort**：claim.value 不動，只壓 credibility。高計謀 giver → detect 低 → 不折 → 「騙過多數」；笨拙謊（低計謀）對高技能 detect 高 → 強折 → 「透明」。對齊 WHAT §6。
- **觀察吃技能風險**：改親見值正確性 → 影響所有讀 best_estimate 的決策；OBS_SKILL_NOISE_GAIN bounded + clamp 限幅，TEST VALUE 平衡 pass 調。
- **reconcile 交互**（G3c-1）：親見 truth 帶噪 → reconcile 比對基準可能錯 → 誤罰 source。主題 coherent，記 known_issues balance watch。
- **行為非保留**：識破排序 + 觀察噪 = 真行為變。閘 = 不崩+守恆，非零漂移。既有測試精確 pop/armed 斷言放寬或用高技能 leader 構造。
- **OUT 邊界**：裁決級「觸發查證」的 scout dispatch = G3d（本層裁決只強折 cred+flag）；決策讀 uncertainty = G3d；team_known claim 化 = G3d/專案；戰術識破伏兵 = 戰鬥域 OUT。
- **執行確認**：新 const/static helper → `--import`；pure helper 確定性單測（detection/observation）；message 刪舊 randf is_suspicious 塊（由分級取代）；觀察噪 clamp 限幅；既有精確值測試對齊。
