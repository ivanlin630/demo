# G3c-1 可信度 + 身份信任 + 類型基準 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** claim 可信度從 G3b interim flat 值 → **真公式 `類型基準 × 身份信任 × 跳數 × 時效`**（WHAT §5）。落地「誰準誰被信、騙子看破後沒人聽」：source_type 正名為真來源類別、`known_reputations` 當動態身份信任、親見比對 relayed claim 回饋調信任。best_estimate 改排 effective credibility（含時效衰減）。

**Architecture:** G3b 已 `team_intel[obs][tgt]=Array of claim`、`record_claim`/`best_estimate`/`claims` accessor。本 plan：(1) claim 寫入帶**真 source_type**（G3b 誤存 mode）；(2) `BeliefSystem.source_credibility` 算 `base×(floor+trust)×hop`，寫時存進 claim.credibility；(3) `effective_credibility` 讀時乘 time_decay，best_estimate 改排它；(4) 親見 record 觸發 trust 回饋迴路（`update_reputation`）。**身份信任 = `TeamData.known_reputations`（已存，team→team 0..1）——不開 RelationGraph person 邊**（claim 是 team-keyed；HOW spec §4「RelationGraph trust 邊」本 plan 覆寫為 known_reputations，理由見下）。

**Tech Stack:** Godot 4.2.2 GDScript；`BeliefSystem` 擴充（已 class_name，`--import`）；`message_system`/`vision_system`/`interaction_system` 寫端；headless harness。

## Global Constraints

- wrapper 跑（UTF-8）；改後 `--import`。
- WHAT/HOW 來源：`specs/2026-06-19-g3-info-decision-design`（§5 可信度雙層×衰減）、`...-how-design`（§4 G3c、§7 invariants）。
- 回歸閘：`=== DONE ===` + 0 assert fail + coin_eq=0 + InvariantAudit 0 + 1000 Tick。不用 multi drift（無 seed）。
- **行為允許變**（可信度真公式 → best_estimate 排序變、決策觀感微移）；回歸閘 = 不崩+守恆，非零漂移。決策接口仍讀 best_estimate 單值面（多源排序內部變）。
- **OUT（非本 plan）**：技能識破 信假/生疑/裁決（G3c-2）、觀察吃技能 親見也錯（G3c-2）、決策讀 uncertainty + scout 主動查證（G3d）、team_known 事件謠言 claim 化（G3d/專案）。本 plan 查證 = **被動**（親見偶遇既有 relayed claim 才比對），無 scout dispatch。

## 鎖定設計決策（實作者勿再設計）

- **身份信任 = `TeamData.known_reputations[source_team]`**（0..1，default 0.5，`update_reputation(other,delta)` clamp helper 已存）。**不新增 RelationGraph 邊**。
  - 覆寫理由：claim source_id = giver **team**；known_reputations 正是 team→team 動態信任，WHAT §5 明列「複用 known_reputations」。person-level trust 邊只在 per-信使 信任才需，belief team-keyed 不需 → 免過度設計 / 免新型別 dormant。
  - **coupling 註記（TEST）**：known_reputations 兼外交/施捨/勒索口碑。belief 查證 ±它 → 「騙我者我也少分享」(message rep2 gate 連動) = emergent-coherent，非 bug。若量測顯衝突再拆專用 trust（後續）。
- **類型基準表**（const `CRED_BASE`，TEST VALUE，序遵 game-design §資訊來源 親見>隊友>商旅>酒館>官方>書籍>流民）：
  ```gdscript
  const CRED_BASE := { "親見": 1.0, "隊友": 0.8, "商旅": 0.6, "流民": 0.3 }
  # 官方/酒館/書籍：待 producer 再加（免休眠；現無寫端產這些類別）
  ```
- **source_type 正名**（G3b 誤存 distortion mode，無 reader → 安全改）：
  - 親見（vision/interaction）：續傳 `"親見"`。
  - message relay：依 giver 性質分類 —— 同 faction(`faction_id!=-1 且==`)→`"隊友"`；giver `tags.has("商隊")`→`"商旅"`；else→`"流民"`。**mode 仍另存 distorted flag**（失真≠來源類別，兩維度）。
- **可信度公式**（拆寫時/讀時兩段，使時效隨 tick 自然衰減）：
  - 寫時（存進 claim.credibility，時不變部分）：`source_credibility = clamp(base × (TRUST_FLOOR + trust) × pow(1-BELIEF_HOP_DECAY, hop), 0, 1.5)`，`TRUST_FLOOR=0.5`（trust 0..1 → 乘數 0.5..1.5）、`BELIEF_HOP_DECAY=0.15`（對齊 message HOP_DECAY）、親見 hop=0 relay hop=1。親見 source_id==obs → trust 取 default 0.5 → 乘數 1.0 → cred=1.0。
  - 讀時（best_estimate/排序用）：`effective_credibility = credibility × time_decay(now - claim.tick)`，`time_decay = clamp(1 - age/AGE_FULL_DECAY, TIME_FLOOR, 1)`，`AGE_FULL_DECAY = TICKS_PER_DAY*30`、`TIME_FLOOR=0.2`（TEST VALUE）。
  - **best_estimate 改排 effective_credibility**（含時效）→ 新鮮勝陳舊；uncertainty 維持 pop_est 分歧（不動）。
  - **修 G3b relay 雙重 HOP debt**：message 不再 `(1-HOP_DECAY)*entry.confidence` 當 cred → 改傳 `source_credibility(...,hop=1)`（hop 只一次）。`_distort_intel_entry` 對 `value.confidence` 的改寫保留（legacy 欄，不再參與 cred 排序）。
- **trust 更新迴路（被動）**：record_claim 寫入**親見**(source_type=="親見" 且 source_id==obs)後，比對同 (obs,tgt) 其他 source(relayed) claim 的 `value.population_est` vs 親見 pop：
  - 比值 `r = relayed/firsthand`（firsthand>0 才比）：`r∈[0.7,1.3]`→該 source **準** `update_reputation(source, +TRUST_DELTA)`；`r<0.4 或 r>2.5 或 claim.distorted`→**錯/騙** `update_reputation(source, -TRUST_DELTA)`；之間→不動。`TRUST_DELTA=0.05`（TEST VALUE）。
  - = 「準線人被信、騙子被棄」被動落地（scout 主動查證 G3d）。

## File Structure

- `scripts/simulation/belief_system.gd`（加 CRED_BASE/常數、`source_credibility`、`effective_credibility`、`_time_decay`、reconcile；best_estimate 改排）。
- `scripts/simulation/message_system.gd`（`_exchange_intel`：source_type 正名 + cred 用 source_credibility）。
- `scripts/simulation/vision_system.gd`、`interaction_system.gd`（親見 record_claim 傳 cred=source_credibility(...,"親見",obs,0)=1.0；觸發 reconcile）。
- `scripts/debug/headless_test.gd`、`docs/invariants.md`、`docs/known_issues.md`、`docs/progress.md`、`docs/superpowers/specs/2026-06-19-g3-info-decision-how-design.md`（系統 owner，更 §4/§7 trust 來源 + G3c 拆分）。

---

### Task 1: 類型基準表 + source_type 正名

**Files:**
- Modify: `scripts/simulation/belief_system.gd`（const CRED_BASE）、`scripts/simulation/message_system.gd`（`_claim_source_type` + record_claim 傳真 type）
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- `BeliefSystem.CRED_BASE`（const Dictionary）。
- message `_exchange_intel`：`record_claim(..., source_type=_claim_source_type(giver, receiver), ...)`（取代 G3b 傳 `mode`）。distorted flag 仍 `mode in [...]`。

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_claim_source_type() -> void:
	print("--- G3c-1：source_type 正名 ---")
	# 親見：vision/interaction 寫 → source_type=="親見"（既有 scenario 加斷言）
	# relay：同 faction giver → "隊友"；商隊 tag giver → "商旅"；else → "流民"
	# 構造兩 team 同 faction，giver 有 intel，_exchange_intel → receiver claim.source_type=="隊友"
	# 斷言 claim["source_type"] 為真類別，非 honest/malicious
	print("source_type OK")
```

- [ ] **Step 2: 跑 harness 驗證失敗**

- [ ] **Step 3: 實作**

`belief_system.gd` 加 const（檔頭，MAX_* 旁）：
```gdscript
const CRED_BASE := { "親見": 1.0, "隊友": 0.8, "商旅": 0.6, "流民": 0.3 }  # TEST VALUE
```
`message_system.gd` 加 helper + 改 record_claim 呼叫：
```gdscript
func _claim_source_type(giver: TeamData, receiver: TeamData) -> String:
	if giver.faction_id != -1 and giver.faction_id == receiver.faction_id:
		return "隊友"
	if giver.tags.has("商隊"):
		return "商旅"
	return "流民"
```
`_exchange_intel` record_claim：`source_type` 參數由 `mode` → `_claim_source_type(giver, receiver)`；`distorted` 維持 `mode in ["unintentional","malicious"]`。

- [ ] **Step 4: --import + 回歸**；Expected `source_type OK`、`=== DONE ===`、既有綠。

- [ ] **Step 5: Commit**
```bash
git add scripts/simulation/belief_system.gd scripts/simulation/message_system.gd scripts/debug/headless_test.gd
git commit -m "feat(g3c1): 類型基準表 + source_type 正名(真來源類別 vs distort mode)"
```

---

### Task 2: 可信度公式（類型×信任×跳數×時效）+ best_estimate 改排 + 修 relay 雙重 HOP

**Files:**
- Modify: `scripts/simulation/belief_system.gd`、`scripts/simulation/message_system.gd`、`scripts/simulation/vision_system.gd`、`scripts/simulation/interaction_system.gd`
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- `BeliefSystem.source_credibility(state, observer_id:int, source_type:String, source_id:int, hop:int) -> float`：寫時 cred（type×trust×hop，時不變）。
- `BeliefSystem.effective_credibility(state, claim:Dictionary) -> float`：讀時 = `credibility × time_decay(now-tick)`。
- `best_estimate` 改用 `effective_credibility` 排序（tie→新 tick）。

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_credibility_formula() -> void:
	print("--- G3c-1：可信度公式 ---")
	var s := WorldState.new(); s.world = WorldData.new()
	s.teams = {}
	# obs=1，src=隊友(高基準) vs src=流民(低基準) 同值不同源 → best 取隊友
	# 構造 obs team known_reputations 與 source team
	# 斷言 source_credibility("隊友") > source_credibility("流民")
	# 斷言 trust 高 → cred 高（同 type 不同 known_reputations）
	# 時效：兩 claim 同 cred 不同 tick → effective 新者勝；best_estimate 取新
	# hop：relay hop=1 < 親見 hop=0（同 base 時）
	print("credibility OK")
```

- [ ] **Step 2: 跑 harness 驗證失敗**

- [ ] **Step 3: 實作 BeliefSystem 公式**

```gdscript
const TRUST_FLOOR := 0.5             # trust 0..1 → 乘數 0.5..1.5
const BELIEF_HOP_DECAY := 0.15       # 對齊 message HOP_DECAY
const CRED_AGE_FULL_DECAY := WorldState.TICKS_PER_DAY * 30  # TEST VALUE
const CRED_TIME_FLOOR := 0.2

static func source_credibility(state: WorldState, observer_id: int,
		source_type: String, source_id: int, hop: int) -> float:
	var base: float = float(CRED_BASE.get(source_type, 0.3))
	var trust := 0.5
	var obs_team: TeamData = state.teams.get(observer_id)
	if obs_team != null and source_id != observer_id:
		trust = float(obs_team.known_reputations.get(source_id, 0.5))
	var hop_decay: float = pow(1.0 - BELIEF_HOP_DECAY, hop)
	return clampf(base * (TRUST_FLOOR + trust) * hop_decay, 0.0, 1.5)

static func _time_decay(state: WorldState, tick: int) -> float:
	var age: int = state.world.current_tick - tick
	if age <= 0: return 1.0
	return clampf(1.0 - float(age) / float(CRED_AGE_FULL_DECAY), CRED_TIME_FLOOR, 1.0)

static func effective_credibility(state: WorldState, claim: Dictionary) -> float:
	return float(claim["credibility"]) * _time_decay(state, int(claim["tick"]))
```
`best_estimate` 排序鍵 `float(c["credibility"])` → `effective_credibility(state, c)`（兩處比較）。

- [ ] **Step 4: 寫端傳真 cred**

- `vision_system._write_tier01` / `interaction_system._write_tier2_intel`：record_claim cred 參數 `1.0` → `BeliefSystem.source_credibility(state, obs_id, "親見", obs_id, 0)`（=1.0，但走公式一致）。
- `message_system._exchange_intel`：刪 `var cred = (1.0-HOP_DECAY)*entry.confidence`，改
  ```gdscript
  var stype := _claim_source_type(giver, receiver)
  var cred := BeliefSystem.source_credibility(state, receiver_id, stype, giver_id, 1)
  BeliefSystem.record_claim(state, receiver_id, tgt_id, giver_id, stype, entry, cred, distorted)
  ```
  （Task1 已把 source_type 改 stype；本步合併 cred。hop 只算一次 → 修雙重 HOP debt。）

- [ ] **Step 5: --import + 回歸**；Expected `credibility OK`、`=== DONE ===`、coin_eq=0、InvariantAudit 0、1000 Tick。既有 multi-claim 測試若依賴舊排序需更新斷言（最高 cred → effective）。

- [ ] **Step 6: Commit**
```bash
git add scripts/simulation/belief_system.gd scripts/simulation/message_system.gd scripts/simulation/vision_system.gd scripts/simulation/interaction_system.gd scripts/debug/headless_test.gd
git commit -m "feat(g3c1): 可信度公式 type×trust×hop×time + best_estimate 排 effective(修 relay 雙重 HOP)"
```

---

### Task 3: 身份信任更新迴路（親見比對 relayed → ±口碑）

**Files:**
- Modify: `scripts/simulation/belief_system.gd`（reconcile）、`vision_system.gd`/`interaction_system.gd`（親見後觸發）
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- `BeliefSystem.reconcile_firsthand(state, obs_id:int, tgt_id:int) -> void`：obs 對 tgt 有親見 claim 時，比對同 tgt 各 relayed source claim 的 pop_est → `obs_team.update_reputation(source_id, ±TRUST_DELTA)`。
- 呼叫點：vision/interaction record 親見後呼叫；或 record_claim 內偵測 source_type=="親見"&&source_id==obs 自動跑（擇後者=單一 choke，寫端零改）。**鎖定：record_claim 內自動**。

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_trust_reconcile() -> void:
	print("--- G3c-1：信任更新迴路 ---")
	var s := WorldState.new(); s.world = WorldData.new()
	# obs=1 收 src=9 relayed claim pop_est=50（先 record_claim relay）
	# obs=1 親見 tgt=2 pop=52（接近）→ record_claim 親見 → update_reputation(9,+)
	# 斷言 teams[1].known_reputations[9] > 0.5
	# 另案：src=8 relayed pop=200，親見 pop=50（離譜）→ rep[8] < 0.5
	print("trust reconcile OK")
```

- [ ] **Step 2: 跑 harness 驗證失敗**

- [ ] **Step 3: 實作 reconcile**

```gdscript
const TRUST_DELTA := 0.05   # TEST VALUE

static func reconcile_firsthand(state: WorldState, obs_id: int, tgt_id: int) -> void:
	var obs_team: TeamData = state.teams.get(obs_id)
	if obs_team == null: return
	var cs: Array = claims(state, obs_id, tgt_id)
	var truth := -1.0
	for c in cs:
		if c["source_type"] == "親見" and int(c["source_id"]) == obs_id:
			truth = float((c["value"] as Dictionary).get("population_est", -1.0)); break
	if truth <= 0.0: return
	for c in cs:
		var sid: int = int(c["source_id"])
		if sid == obs_id or c["source_type"] == "親見": continue
		var rep: float = float((c["value"] as Dictionary).get("population_est", -1.0))
		if rep <= 0.0: continue
		var r: float = rep / truth
		if r >= 0.7 and r <= 1.3:
			obs_team.update_reputation(sid, TRUST_DELTA)
		elif r < 0.4 or r > 2.5 or bool(c.get("distorted", false)):
			obs_team.update_reputation(sid, -TRUST_DELTA)
```
`record_claim` 尾段（cap 前/後皆可，但需在親見 claim 已入 cs 後）：
```gdscript
	if source_type == "親見" and source_id == obs_id:
		reconcile_firsthand(state, obs_id, tgt_id)
```

- [ ] **Step 4: --import + 回歸**；Expected `trust reconcile OK`、`=== DONE ===`、coin_eq=0、1000 Tick。注意 reconcile 改 known_reputations → 可能微動外交/分享行為（coupling，預期非 bug）。

- [ ] **Step 5: Commit**
```bash
git add scripts/simulation/belief_system.gd scripts/debug/headless_test.gd
git commit -m "feat(g3c1): 親見比對 relayed→±known_reputations(被動查證,準者升騙者降)"
```

---

### Task 4: invariant + HOW spec 更新 + debt + 回歸

**Files:**
- Modify: `docs/invariants.md`、`docs/superpowers/specs/2026-06-19-g3-info-decision-how-design.md`、`docs/known_issues.md`、`docs/progress.md`

- [ ] **Step 1: invariant 補**

`docs/invariants.md` belief 段補：
```markdown
- **可信度公式**：claim 排序用 `effective_credibility = source_credibility(類型基準×身份信任×跳數) × 時效衰減`。身份信任 = `TeamData.known_reputations`（team→team，動態）。禁在 BeliefSystem 外算 claim 可信度。
- **身份信任迴路**：親見 record 比對同 tgt relayed claim → `update_reputation(source, ±)`（準升/錯降）。被動（scout 主動查證 = G3d）。
```

- [ ] **Step 2: HOW spec 更新（系統 owner）**

`...-g3-info-decision-how-design.md`：
- §1/§4：G3c 拆 **G3c-1（可信度+信任+類型，本 plan）/ G3c-2（技能識破+觀察吃技能）**。
- §4/§7：身份信任 `RelationGraph trust 邊` → **改 `TeamData.known_reputations`（team-keyed claim 不需 person 邊；person-level trust 待 per-信使 需求再開）**。記覆寫理由。

- [ ] **Step 3: known_issues/progress + debt**

- progress：G3c-1 ✅（可信度真公式 + 身份信任 known_reputations + 被動查證迴路）。G3c-2（技能識破/觀察吃技能）/ G3d（決策讀 uncertainty + scout 主動查證）/ team_known claim 化 = 待。
- TEST VALUE 記：CRED_BASE 各值、TRUST_FLOOR、BELIEF_HOP_DECAY、CRED_AGE_FULL_DECAY、CRED_TIME_FLOOR、TRUST_DELTA、reconcile 比值門檻。
- debt 收：G3b relay 雙重 HOP 已修（Task2）。known_reputations coupling（外交/belief 共用）= interim，量測後評估是否拆專用 trust。

- [ ] **Step 4: 全回歸**
```
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
```
Expected: `=== DONE ===`、coin_eq=0、InvariantAudit 0、1000 Tick。

- [ ] **Step 5: Commit**
```bash
git add docs/invariants.md docs/superpowers/specs/2026-06-19-g3-info-decision-how-design.md docs/known_issues.md docs/progress.md
git commit -m "docs(g3c1): 可信度 invariant + HOW spec(trust=known_reputations,G3c 拆分) + 進度"
```

---

## Self-Review 註記

- **不開 RelationGraph 邊**：claim team-keyed → known_reputations 已是 team→team 動態信任，複用免新型別 dormant。覆寫 HOW spec §4（Task4 同步更新 spec，免 doc drift）。
- **行為非保留**（與 G3a 別）：可信度真公式 → best_estimate 排序變、決策觀感微移。回歸閘 = 不崩+守恆，非零漂移。既有 multi-claim 測試的排序斷言要對齊 effective_credibility。
- **source_type 正名安全**：G3b 寫 mode 無 reader → 改真類別零破壞；distorted flag 另存（失真≠來源類別兩維度）。
- **修 G3b debt**：relay 雙重 HOP → source_credibility hop 算一次（Task2）。
- **coupling 自覺**：known_reputations 兼外交/施捨/勒索口碑；belief 查證 ±它 = 「騙我者我也少分享」emergent-coherent。量測若顯衝突 → 拆專用 trust（後續，非本 plan）。
- **被動查證**：reconcile 只在親見偶遇既有 relayed claim 才跑（無 scout dispatch）→ 主動查證/不確定驅動 = G3d。
- **OUT 邊界**：技能識破/觀察吃技能（G3c-2，依賴本 plan cred）；決策讀 uncertainty + scout（G3d）；team_known 事件謠言 claim 化（G3d/專案）。
- **執行確認**：新 const/func → `--import`；既有測試排序斷言對齊 effective_credibility；reconcile 在親見 claim 入 cs 後跑；firsthand pop=0 守衛除零。
