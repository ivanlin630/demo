# G3d-1 決策讀 uncertainty + 風險 gate Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 決策從「只讀 best_estimate 單值」→ **讀 (best 值 + 不確定性)**，攻擊性 commit 按 `個性慎重 × uncertainty` 風險調節（WHAT §7）。落地：**莽者吃假情報誘殺、慎重者面對矛盾情報先按兵**。脊椎接行為——belief 層（G3b/c）首度有決策後果。

**Architecture:** G3c 已 `BeliefSystem.uncertainty`(claim 分歧)。決策接入面已讀 `best_estimate`（G3a/b 遷移）。本 plan 加 `confident_enough(observer, target, caution)` 共用 gate，插在**攻擊性 commit**（faction_ai 掠食/攻擊鎖定 prey、diplomatic 敵對提案）：不確定且慎重 → **本 tick 不 commit**（按兵，待親見壓低 uncertainty）；莽者(低慎重)門檻低 → 照衝 → 假情報誘殺。

**Tech Stack:** Godot 4.2.2 GDScript；`BeliefSystem` 加 static gate；`faction_ai_system`/`diplomatic_ai_system` wiring；headless harness。

## Global Constraints

- wrapper 跑；改後 `--import`。
- WHAT/HOW 來源：`specs/2026-06-19-g3-info-decision-design`（§7 不確定性驅動行為、§8 決策接入面）、`...-how-design`（§5 G3d、§7）。
- 回歸閘：`=== DONE ===` + 0 assert fail + coin_eq=0 + InvariantAudit 0 + 1000 Tick。不用 multi drift。**特別驗：團隊仍會攻擊/掠食（gate 不凍結 AI）**——親見(uncertainty≈0)→confidence 高→照動；gate 只咬「矛盾多源」情報。
- **行為允許變**（攻擊 commit 受 uncertainty 調節）；閘 = 不崩+守恆+不凍結，非零漂移。
- **OUT（非本 plan）**：scout 主動查證迴路（不確定→dispatch scout→親見壓謊→才動）= **G3d-2**（本層 uncertain+慎重 = **被動按兵**，非主動派斥候）；威脅(防禦)uncertainty-gate = G3d-2（極性相反：不確定威脅→更警戒，非 hold-attack，與攻擊性 commit 不同模型）；team_known 事件謠言 claim 化 = G3d-2/專案。

## 鎖定設計決策（實作者勿再設計）

- **接入面 = 攻擊性 commit only**（uncertainty→hold 語義一致、誘殺載體）：
  - faction_ai：掠食/攻擊**鎖定 prey**（設 `prosperity_target_id` / `combat_target` 於 belief-derived 弱目標）。
  - diplomatic_ai：**敵對行動**（求貢/勒索/敵對提案）on belief。
  - **威脅(threat_assessment/_evaluate_threat)不在本 plan**：防禦反應的 uncertainty 極性相反（不確定威脅→更該警戒/查證，非按兵）→ G3d-2 一併（記 progress 告知藍圖 §8 威脅延後）。
- **gate 公式**：`confident_enough(state, observer, target, caution) -> bool`：
  ```
  confidence = 1 - uncertainty(observer, target)
  threshold  = lerp(GATE_CONF_LOW(0.0), GATE_CONF_HIGH(0.6), clamp(caution,0,1))
  return confidence >= threshold
  ```
  - 莽者(caution=0)→threshold 0→幾乎恆 commit（照衝）；慎重者(caution=1)→需 confidence≥0.6（uncertainty≤0.4）才 commit。
  - 親見單源 uncertainty=1-cred≈0→confidence≈1→恆過（正常掠食不凍結）；矛盾多源 uncertainty 高→慎重者按兵。GATE_* TEST VALUE。
- **gate 失敗 = 本 tick 不 commit（return/skip）**，非取消目標——下次 cadence 重評（親見後 uncertainty 降則 commit）。**被動**（主動 scout = G3d-2）。
- **不動 best_estimate 既有讀**（值照用）；只在 commit 分支**加** uncertainty gate。

## File Structure

- `scripts/simulation/belief_system.gd`（加 GATE 常數 + `confident_enough`）。
- `scripts/simulation/faction_ai_system.gd`（掠食/攻擊 prey commit 處加 gate）。
- `scripts/simulation/diplomatic_ai_system.gd`（敵對行動加 gate）。
- `scripts/debug/headless_test.gd`、`docs/invariants.md`、`docs/known_issues.md`、`docs/progress.md`。

---

### Task 1: confident_enough gate helper

**Files:**
- Modify: `scripts/simulation/belief_system.gd`
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- `BeliefSystem.confident_enough(state, observer_id:int, target_id:int, caution:float) -> bool`（pure-ish，讀 uncertainty）。

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_confidence_gate() -> void:
	print("--- G3d-1：confident_enough gate ---")
	var s := WorldState.new(); s.world = WorldData.new()
	s.team_intel = {}
	# 親見高 cred 單源 → uncertainty≈0 → 慎重者也過
	BeliefSystem.record_claim(s, 1, 2, 1, "親見", {"population_est": 50}, 1.0, false)
	assert(BeliefSystem.confident_enough(s, 1, 2, 1.0), "親見確定→慎重者 commit")
	# 矛盾多源 → uncertainty 高 → 慎重者按兵、莽者照衝
	BeliefSystem.record_claim(s, 1, 2, 9, "流民", {"population_est": 200}, 0.4, true)
	assert(BeliefSystem.uncertainty(s, 1, 2) > 0.5, "矛盾→高 uncertainty")
	assert(not BeliefSystem.confident_enough(s, 1, 2, 1.0), "慎重者矛盾→按兵")
	assert(BeliefSystem.confident_enough(s, 1, 2, 0.0), "莽者→照衝")
	# 無 belief → uncertainty=1 → 慎重者按兵
	assert(not BeliefSystem.confident_enough(s, 1, 99, 1.0), "無情報→慎重者按兵")
	print("confidence gate OK")
```

- [ ] **Step 2: 跑 harness 驗證失敗**

- [ ] **Step 3: 實作**

```gdscript
const GATE_CONF_LOW := 0.0    # TEST VALUE：莽者門檻
const GATE_CONF_HIGH := 0.6   # TEST VALUE：慎重者門檻

# 風險 gate：個性慎重 × 情報不確定性 → 是否夠把握 commit 攻擊性行動。
# 莽者門檻低(照衝,假情報誘殺)；慎重者需高 confidence(矛盾情報按兵)。
static func confident_enough(state: WorldState, observer_id: int, target_id: int, caution: float) -> bool:
	var confidence: float = 1.0 - uncertainty(state, observer_id, target_id)
	var threshold: float = lerpf(GATE_CONF_LOW, GATE_CONF_HIGH, clampf(caution, 0.0, 1.0))
	return confidence >= threshold
```

- [ ] **Step 4: --import + 回歸**；Expected `confidence gate OK`、`=== DONE ===`、既有綠。

- [ ] **Step 5: Commit**
```bash
git add scripts/simulation/belief_system.gd scripts/debug/headless_test.gd
git commit -m "feat(g3d1): confident_enough 風險 gate(慎重×uncertainty)"
```

---

### Task 2: faction_ai 攻擊/掠食 commit gate

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- Consumes: `BeliefSystem.confident_enough`。
- 掠食/攻擊**鎖定 prey** 前（設 `prosperity_target_id`/`combat_target` 於 belief 弱目標）加 gate：`if not BeliefSystem.confident_enough(state, team.team_id, prey_id, leader 慎重): continue/return`（不 commit，下次 cadence 重評）。

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_faction_attack_gate() -> void:
	print("--- G3d-1：攻擊 commit gate ---")
	# 構造 team(leader 慎重高) + prey；team 對 prey 持矛盾多源 belief(高 uncertainty)
	#   → 跑掠食評估 → prosperity_target_id 不被設(按兵)
	# 另案：leader 慎重低(莽) 同 belief → prosperity_target_id 被設(照衝)
	# 或：親見確定 belief → 慎重者也 commit
	# 用既有掠食評估 entry（_evaluate_prosperity/掠食 cadence）構造最小 scenario
	print("attack gate OK")
```

- [ ] **Step 2: 跑 harness 驗證失敗**

- [ ] **Step 3: 實作（gate 插各 prey-commit 分支）**

掠食/攻擊鎖定 prey 的 commit 點（候選 `prosperity_target_id =` 設值處：~169 掠食選 prey、~274 threat-prey、~535 vendetta 追擊刷新、~2123）。**鎖 belief-derived 弱目標的 commit** 前插：
```gdscript
	var _gleader: PersonData = state.persons.get(team.leader_id)
	var _caution: float = float(_gleader.values.get("慎重", 0.5)) if _gleader else 0.5
	if not BeliefSystem.confident_enough(state, team.team_id, prey_id, _caution):
		continue   # 或 return / 跳過此 prey：本 tick 不 commit，下次 cadence 重評（親見後 uncertainty 降則動）
```
> **判斷哪些 commit 該 gate**：只 gate「**因為認為對方弱才主動攻擊**」的選擇（掠食 prey 選擇、prosperity 鎖定）。**不 gate** 防禦/復仇必動分支（vendetta 私仇是 §G2d 確定性脫軌、threat 被動反應是 G3d-2）——若某分支非「belief-弱→主動攻」語義則跳過該處。實作者讀各分支語義判定；只插攻擊性主動選擇。
> **不凍結驗證**：gate 後跑 1000 Tick 確認仍有掠食/攻擊發生（親見目標 uncertainty≈0 過 gate）。

- [ ] **Step 4: --import + 回歸**；Expected `attack gate OK`、`=== DONE ===`、coin_eq=0、InvariantAudit 0、1000 Tick、**仍有攻擊發生**（log/掠食計數 > 0）。

- [ ] **Step 5: Commit**
```bash
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(g3d1): 掠食/攻擊 commit 加 uncertainty gate(慎重者矛盾按兵,莽者誘殺)"
```

---

### Task 3: diplomatic 敵對行動 gate

**Files:**
- Modify: `scripts/simulation/diplomatic_ai_system.gd`
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- Consumes: `BeliefSystem.confident_enough`。
- 敵對行動（求貢/勒索/敵對提案 on belief 弱目標）commit 前 gate。**非敵對**（結盟/求和）不 gate（uncertainty 不增風險）。

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_diplomacy_hostile_gate() -> void:
	print("--- G3d-1：外交敵對 gate ---")
	# 慎重 leader + 對目標矛盾 belief → 敵對行動不發；莽者 → 發
	# 復用 try_proactive_diplomacy / 敵對分支最小 scenario
	print("diplomacy gate OK")
```

- [ ] **Step 2: 跑 harness 驗證失敗**

- [ ] **Step 3: 實作**

`diplomatic_ai_system` 敵對分支（求貢/勒索/敵對 score 觸發處）commit 前：
```gdscript
	var _dcaution: float = float(self_leader.values.get("慎重", 0.5))
	if not BeliefSystem.confident_enough(state, self_team.team_id, other.team_id, _dcaution):
		continue   # 敵對行動不確定→按兵；結盟/求和分支不受此 gate
```
> 只 gate 敵對（基於「對方弱可欺」）；友好/求和分支跳過。

- [ ] **Step 4: --import + 回歸**；Expected `diplomacy gate OK`、`=== DONE ===`、coin_eq=0、1000 Tick。

- [ ] **Step 5: Commit**
```bash
git add scripts/simulation/diplomatic_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(g3d1): 外交敵對行動加 uncertainty gate"
```

---

### Task 4: invariant + progress + 回歸

**Files:**
- Modify: `docs/invariants.md`、`docs/known_issues.md`、`docs/progress.md`

- [ ] **Step 1: invariant 補**

`docs/invariants.md` belief 段補：
```markdown
- **決策風險 gate**：攻擊性 commit（掠食/攻擊鎖定、外交敵對）前經 `BeliefSystem.confident_enough(觀察者,目標,慎重)`——不確定且慎重 → 本 tick 不 commit（被動按兵）。莽者門檻低→照衝→假情報誘殺。scout 主動查證 = G3d-2。
```

- [ ] **Step 2: progress / known_issues**

- progress：G3d-1 ✅（攻擊性決策讀 uncertainty + 慎重風險 gate；誘殺/按兵 emergent）。**G3d-2 待**：scout 主動查證迴路（不確定→dispatch scout→親見壓謊→才動）+ 威脅(防禦)uncertainty-gate + team_known claim 化。
- **告知藍圖（progress 註）**：WHAT §8「威脅」uncertainty-gate 延 G3d-2，因防禦極性與攻擊 commit 相反（不確定威脅→更警戒非按兵）→ 與 scout 查證一併設計較一致。
- TEST VALUE 記：GATE_CONF_LOW/HIGH。

- [ ] **Step 3: 全回歸**
```
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
```
Expected: `=== DONE ===`、coin_eq=0、InvariantAudit 0、1000 Tick、仍有攻擊發生。

- [ ] **Step 4: Commit**
```bash
git add docs/invariants.md docs/known_issues.md docs/progress.md
git commit -m "docs(g3d1): 決策風險 gate invariant + 進度(威脅/scout→G3d-2)"
```

---

## Self-Review 註記

- **不凍結 AI**：gate 只咬高 uncertainty（矛盾多源）；親見單源 uncertainty≈0→恆過→正常掠食/攻擊不受影響。Task2/4 強制驗 1000 Tick 仍有攻擊（gate 全擋 = bug，停查 GATE_CONF_HIGH 或 uncertainty 計算）。
- **被動非主動**：gate 失敗 = 本 tick 不 commit（下次 cadence 重評），**非**派 scout（G3d-2）。慎重者靠後續親見自然壓低 uncertainty 再動；G3d-2 給主動 scout 加速。
- **接入面收斂攻擊性**：只 gate「belief-弱→主動攻/敵對」。威脅(防禦,極性反)、vendetta(私仇確定性脫軌 G2d)不 gate。實作者依分支語義判定，誤 gate 防禦/必動分支會凍結 → 驗證捕捉。
- **誘殺 emergent**：G3c 產假 belief(relay 失真/觀察吃技能) + 本層莽者低門檻照衝 → 攻擊假弱目標 → 誘殺。慎重者按兵避開。**魂訊號首度由決策生**。
- **行為非保留**：攻擊 commit 受 uncertainty 調節。閘 = 不崩+守恆+不凍結。既有攻擊測試多以親見/高 cred 構造→uncertainty 低→照過；若有測試用矛盾 belief 觸發攻擊 → 對齊 gate（提高 cred 或降慎重）。
- **OUT 邊界**：scout 主動查證 + 威脅 uncertainty + team_known claim 化 = G3d-2。
- **執行確認**：新 const/helper→`--import`；gate 只插攻擊性 commit 分支；1000 Tick 驗仍攻擊；既有矛盾-belief 攻擊測試對齊。
