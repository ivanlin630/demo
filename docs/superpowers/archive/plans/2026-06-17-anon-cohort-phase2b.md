# Anon Cohort Phase 2b（wounded 折入 cohort health 維度 + 修漏水）Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 把 `wounded` int 欄位折入 `anon_cohorts` 的 `health="wounded"` 桶；`wounded` 改唯讀 getter；受傷/治療/轉移改走 cohort `move`，**結構性消除 wounded 單調膨脹漏水**。

**Architecture:** 受傷 = `move(tier|healthy → tier|wounded)`（受 healthy 池上限約束 → 無法膨脹）。anon encounter unit 無 tier 資訊 → 受傷/治療 weighted-random 選 tier（對齊 `kill_random` 分布）。`population - wounded` 戰力公式**自動續正確**（wounded getter 回 cohort wounded，population 仍含 wounded anon），故 combat 公式不動。`kill_random` 維持只殺 healthy（戰場部署的是 healthy；wounded 在營，只因治療失敗死）。

**Tech Stack:** Godot 4.2.2 GDScript。回歸網 = `headless_test.gd` 全套 + multi sanity `game_sim_multi.gd`（coin_eq delta=0、InvariantViolation 不增、wounded 不再膨脹）。

> **整體藍圖**：Phase 1 ✅、2a ✅（storage flip，cohort 全 healthy）。**本 plan = 2b**（啟用 wounded 維度）。後續 2c（population→getter + 刪手動 pop 寫入）、Phase 4（audit cohort 自洽網 + docs + 存檔）。

**前置（強制，依 `docs/process/03_implementer.md`）：**
```powershell
git worktree add .worktrees/anon-cohort-phase2b -b feat/anon-cohort-phase2b
cd .worktrees/anon-cohort-phase2b
```

**Baseline：** `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd` → `=== DONE ===` 無 `SCRIPT ERROR`。

> **⚠ 原子型別替換**：`wounded` 轉 getter 後所有舊寫入點同時失效，Task 1–5 全落地後才綠（中途不可執行屬正常），Task 6 回歸驗證。

---

## File Structure

| 檔案 | 動作 | 職責 |
|---|---|---|
| `scripts/data/team_data.gd:82` | Modify | `wounded` int → 唯讀 getter（`AnonCohort.by_health(anon_cohorts, "wounded")`） |
| `scripts/simulation/anon_tier_system.gd` | Modify | 加 `wound_random` / `heal_random` / `kill_wounded` + `_weighted_tier`；`transfer_proportional` 改 health-aware（兩桶都搬） |
| `scripts/simulation/health_system.gd:159-190` | Modify | `resolve_anon_units`：3 處 `wounded += 1` → 算受傷 anon 數 → `wound_random` 一次（修漏水） |
| `scripts/simulation/npc_combat_system.gd:419` | Modify | `_apply_casualties`：anon 傷 `wounded += 1` 累加 → 迴圈後 `wound_random` |
| `scripts/simulation/interaction_system.gd:155-174` | Modify | `_treat_wounded`：`wounded -= to_treat` → `heal_random(saved)` + `kill_wounded(died)`（保 `population -= died`） |
| `scripts/simulation/subteam_system.gd:85-87` | Modify | 移除手動 wounded 轉移（改由 health-aware `transfer_proportional` 帶走） |
| `scripts/simulation/invariant_audit.gd:12-22` | Modify | population 公式去掉 `+ wounded`（wounded 已含於 `total_pop`） |
| `scripts/debug/headless_test.gd` | Modify | 加 wound/heal/kill_wounded/wounded-getter/transfer-wounded 測試 |

**不變量**：`wounded` 永不超過 anon 總數（move 受 healthy 上限約束）；`total_pop` = healthy + wounded；治療死亡走 `kill_wounded` + `population -= died`。

---

## Task 1: team_data wounded → 唯讀 getter

**Files:** Modify `scripts/data/team_data.gd:82`

- [ ] **Step 1: 換 getter**

把 `var wounded: int       = 0` 改成：
```gdscript
# 傷兵數 = cohort wounded 桶投影（取代舊 int 累加器；唯讀，舊寫入走 AnonTierSystem wound/heal/kill_wounded）
var wounded: int:
	get:
		return AnonCohort.by_health(anon_cohorts, "wounded")
	set(_value):
		pass
```

- [ ] **Step 2: 不單獨跑**（待 Task 2-5）。進 Task 2。

---

## Task 2: AnonTierSystem 加 wound/heal/kill_wounded + transfer health-aware

**Files:** Modify `scripts/simulation/anon_tier_system.gd`

- [ ] **Step 1: 加 weighted tier 選擇 + wound/heal/kill_wounded**

在「變動」區（`kill_random` 附近）加：
```gdscript
# 依某 health 桶各 tier count 加權隨機選一 tier（無人回 ""）
static func _weighted_tier(team: TeamData, health: String) -> String:
	var tot: int = AnonCohort.by_health(team.anon_cohorts, health)
	if tot <= 0:
		return ""
	var roll: int = randi() % tot
	var acc: int = 0
	for tier in TIER_ORDER:
		acc += int(team.anon_cohorts.get(AnonCohort._key(tier, health), 0))
		if roll < acc:
			return tier
	return ""

# 受傷 n 人：weighted 從 healthy 移到 wounded。回實際受傷數（受 healthy 池上限約束→不膨脹）
static func wound_random(team: TeamData, n: int) -> int:
	var done: int = 0
	for _i in range(n):
		var tier: String = _weighted_tier(team, "healthy")
		if tier == "":
			break
		AnonCohort.move(team.anon_cohorts, tier, "healthy", tier, "wounded", 1)
		done += 1
	return done

# 治癒 n 人：weighted 從 wounded 移回 healthy。回實際治癒數
static func heal_random(team: TeamData, n: int) -> int:
	var done: int = 0
	for _i in range(n):
		var tier: String = _weighted_tier(team, "wounded")
		if tier == "":
			break
		AnonCohort.move(team.anon_cohorts, tier, "wounded", tier, "healthy", 1)
		done += 1
	return done

# 傷兵死亡 n 人：weighted 從 wounded 桶移除。回實際移除數
static func kill_wounded(team: TeamData, n: int) -> int:
	var done: int = 0
	for _i in range(n):
		var tier: String = _weighted_tier(team, "wounded")
		if tier == "":
			break
		AnonCohort.remove(team.anon_cohorts, tier, "wounded", 1)
		done += 1
	return done
```

- [ ] **Step 2: transfer_proportional 改 health-aware（兩桶都搬，保 tier+health）**

把 2a 版 `transfer_proportional` 換成跨 health：
```gdscript
static func transfer_proportional(from: TeamData, to: TeamData, count: int) -> Dictionary:
	var moved: Dictionary = {}
	for tier in TIER_ORDER:
		moved[tier] = 0
	var total: int = AnonCohort.total(from.anon_cohorts)
	if total <= 0 or count <= 0:
		return moved
	var actual: int = mini(count, total)
	var remaining: int = actual
	# 兩輪 × 兩 health：按比例搬，保各 tier|health 桶
	for health in AnonCohort.HEALTH_ORDER:
		for tier in TIER_ORDER:
			if remaining <= 0:
				break
			var avail: int = int(from.anon_cohorts.get(AnonCohort._key(tier, health), 0))
			if avail <= 0:
				continue
			var n: int = mini(mini(int(round(float(avail) / float(total) * float(actual))), avail), remaining)
			var real: int = AnonCohort.remove(from.anon_cohorts, tier, health, n)
			AnonCohort.add(to.anon_cohorts, tier, health, real)
			moved[tier] += real
			remaining -= real
	# 補滿剩餘（順序）
	if remaining > 0:
		for health in AnonCohort.HEALTH_ORDER:
			for tier in TIER_ORDER:
				if remaining <= 0:
					break
				var avail2: int = int(from.anon_cohorts.get(AnonCohort._key(tier, health), 0))
				if avail2 > 0:
					var take: int = mini(avail2, remaining)
					var real2: int = AnonCohort.remove(from.anon_cohorts, tier, health, take)
					AnonCohort.add(to.anon_cohorts, tier, health, real2)
					moved[tier] += real2
					remaining -= real2
	return moved
```
> `kill_random` 維持 2a 版（只殺 healthy）——戰場死的是部署的 healthy 兵；wounded 在營只因治療失敗死。**不改 kill_random**。

- [ ] **Step 3: 不單獨跑**。進 Task 3。

---

## Task 3: health_system resolve_anon_units 修漏水

**Files:** Modify `scripts/simulation/health_system.gd:159-190`

- [ ] **Step 1: 改 wounded 累加為單次 wound_random**

把 `resolve_anon_units`（159-190）的尾段（原 176-190 的 `team.wounded += 1` 三處）改成：先**算這場受傷存活 anon 數**（每 anon 至多計一次，修原 +2 bug），再 `wound_random` 一次。

把原 176-190：
```gdscript
		var has_bleed: bool = false
		var has_major: bool = false
		for part in bp:
			if bp[part].get("bleeding", "none") == "major": has_major = true
			if bp[part].get("bleeding", "none") != "none":  has_bleed = true
		if has_bleed:
			var cost: int = 2 if has_major else 1
			if int(team.resources.get("medicine", 0)) >= cost:
				team.resources["medicine"] = int(team.resources["medicine"]) - cost
			else:
				team.wounded += 1
		if bp.values().any(func(x): return x.get("fracture", false)):
			team.wounded += 1
		elif bp.values().any(func(x): return x.get("status", "healthy") != "healthy"):
			team.wounded += 1
```
改成（用本地計數，迴圈外一次 wound_random）：
```gdscript
		var has_bleed: bool = false
		var has_major: bool = false
		for part in bp:
			if bp[part].get("bleeding", "none") == "major": has_major = true
			if bp[part].get("bleeding", "none") != "none":  has_bleed = true
		var injured: bool = false
		if has_bleed:
			var cost: int = 2 if has_major else 1
			if int(team.resources.get("medicine", 0)) >= cost:
				team.resources["medicine"] = int(team.resources["medicine"]) - cost
			else:
				injured = true
		if bp.values().any(func(x): return x.get("fracture", false)):
			injured = true
		elif bp.values().any(func(x): return x.get("status", "healthy") != "healthy"):
			injured = true
		if injured:
			wounded_count += 1
```
並在函數開頭（`var anon_units: Array = []` 之後）宣告 `var wounded_count: int = 0`，在迴圈**結束後**加：
```gdscript
	AnonTierSystem.wound_random(team, wounded_count)
```
> 每 anon 至多計一次（修原 bleed+fracture +2）。`wound_random` 受 healthy 上限約束 → 此場受傷數不可能超過現有 healthy → 漏水消失。`_is_unit_dead_bp` 死亡分支（原 173-174 `population -= 1`）原樣保留（死亡仍直接減 pop；該 anon 未進 cohort 統計，屬 encounter 暫時 unit）。

- [ ] **Step 2: 不單獨跑**。進 Task 4。

---

## Task 4: npc_combat _apply_casualties anon 傷改 wound_random

**Files:** Modify `scripts/simulation/npc_combat_system.gd:404-420`

- [ ] **Step 1: 累加 anon 傷數 → 迴圈後 wound_random**

`_apply_casualties`（404-420）把 `team.wounded += 1`（419）改累加。整段改成：
```gdscript
func _apply_casualties(state: WorldState, team_id: int, count: int) -> void:
	if count <= 0:
		return
	var team: TeamData = state.teams[team_id]
	var named_ids: Array = team.named_members.duplicate()   # MUST duplicate (Array by ref)
	if team.leader_id != -1:
		named_ids.append(team.leader_id)
	var anon_wounded: int = 0
	for i in range(count):
		if not named_ids.is_empty() and randf() < float(named_ids.size()) / maxf(float(team.population), 1.0):
			var idx: int = randi() % named_ids.size()
			var pid: int = named_ids[idx]
			var p = state.persons.get(pid)
			if p != null:
				_hit_person(state, team_id, p)
		else:
			anon_wounded += 1
	AnonTierSystem.wound_random(team, anon_wounded)
	_equip.on_anon_casualties(team, count)
```

- [ ] **Step 2: 不單獨跑**。進 Task 5。

---

## Task 5: interaction 治療 + subteam 轉移 + audit 公式

**Files:**
- Modify `scripts/simulation/interaction_system.gd:155-174`
- Modify `scripts/simulation/subteam_system.gd:85-87`
- Modify `scripts/simulation/invariant_audit.gd:16-22`

- [ ] **Step 1: _treat_wounded 走 cohort**

`_treat_wounded`（155-174）把 `team.wounded -= to_treat`（170）改成 heal/kill。原 166-171：
```gdscript
	var to_treat: int = mini(maxi(1, int(round(team.wounded * WOUNDED_TREATMENT_RATE))), team.wounded)
	var save_rate: float = (0.4 + best_medicine * 0.5) * resource_factor
	var saved: int = int(round(float(to_treat) * save_rate))
	var died: int  = to_treat - saved
	team.wounded   -= to_treat
	team.population = maxi(team.population - died, 1)
```
改成：
```gdscript
	var to_treat: int = mini(maxi(1, int(round(team.wounded * WOUNDED_TREATMENT_RATE))), team.wounded)
	var save_rate: float = (0.4 + best_medicine * 0.5) * resource_factor
	var saved: int = int(round(float(to_treat) * save_rate))
	var died: int  = to_treat - saved
	AnonTierSystem.heal_random(team, saved)        # 救活：wounded → healthy
	AnonTierSystem.kill_wounded(team, died)        # 治療失敗死：移除 wounded 桶
	team.population = maxi(team.population - died, 1)
```
> `team.wounded` 讀取（138 `if team.wounded > 0` / 164 food_per_person 分母用 population 不變 / 166 to_treat 用 wounded getter）自動走 getter，無需改。

- [ ] **Step 2: subteam 移除手動 wounded 轉移**

`subteam_system.gd:85-87`：
```gdscript
	var w_xfer: int = int(round(float(absorbed.wounded) * frac))
	absorber.wounded += w_xfer
	absorbed.wounded = maxi(absorbed.wounded - w_xfer, 0)
```
**刪除**這三行（wounded 現為 getter，手動寫入無效；wounded 桶改由 caller 的 `AnonTierSystem.transfer_proportional`（已 health-aware）一併帶走）。更新函數開頭註解，把「按比例搬 wounded + resources」的 `wounded` 字樣移除。
> ⚠ **確認 caller**：搜 `transfer_proportional` 在 subteam 合併路徑的呼叫，確認 anon（含 wounded 桶）確實經它轉移。若某合併路徑未呼叫 transfer_proportional 而僅靠這三行搬 wounded → 需在該路徑補 `transfer_proportional`，否則 wounded 桶遺留被刪隊上而丟失。實作時讀 subteam_system 合併流程核對。

- [ ] **Step 3: invariant_audit population 公式去 +wounded**

`invariant_audit.gd:16-22`，把 `+ t.wounded` 拿掉（wounded 已含於 `AnonTierSystem.total_pop`）：
```gdscript
	static func _check_population(state: WorldState, out: Array[String]) -> void:
		for tid in state.teams:
			var t: TeamData = state.teams[tid]
			var expected: int = (1 if t.leader_id != -1 else 0) \
				+ t.named_members.size() + AnonTierSystem.total_pop(t)
			if t.population != expected:
				out.append("population drift Team%d: 欄位=%d 期望=%d (leader%d+named%d+anon%d)" % [
					tid, t.population, expected,
					(1 if t.leader_id != -1 else 0), t.named_members.size(),
					AnonTierSystem.total_pop(t)])
```
並更新 :12 註解為 `# population 不變量：== leader(0/1) + named + anon(含 wounded 桶)`。

- [ ] **Step 4: 不單獨跑**。進 Task 6。

---

## Task 6: 測試 + 回歸 + multi sanity

**Files:** Modify `scripts/debug/headless_test.gd`

- [ ] **Step 1: 加 2b 單元測試**

加並於 `_initialize()` 註冊：
```gdscript
func _test_anon_wound_heal_kill() -> void:
	var t := TeamData.new()
	t.anon_cohorts = {}
	AnonCohort.add(t.anon_cohorts, "平民", "healthy", 10)
	# wound 3：healthy 7 / wounded 3
	var w: int = AnonTierSystem.wound_random(t, 3)
	assert(w == 3, "wound 應 3，實際 %d" % w)
	assert(AnonCohort.by_health(t.anon_cohorts, "healthy") == 7, "healthy 應 7")
	assert(AnonCohort.by_health(t.anon_cohorts, "wounded") == 3, "wounded 應 3")
	assert(t.wounded == 3, "wounded getter 應 3，實際 %d" % t.wounded)
	# wound 超量受 healthy 上限約束（不膨脹）
	var w2: int = AnonTierSystem.wound_random(t, 99)
	assert(w2 == 7, "剩 7 healthy，wound 99 應只傷 7，實際 %d" % w2)
	assert(AnonCohort.by_health(t.anon_cohorts, "healthy") == 0, "全傷後 healthy 0")
	assert(t.wounded == 10, "wounded 上限 = anon 總數 10")
	# heal 4
	var h: int = AnonTierSystem.heal_random(t, 4)
	assert(h == 4 and t.wounded == 6, "heal 4 後 wounded 6")
	# kill_wounded 2
	var k: int = AnonTierSystem.kill_wounded(t, 2)
	assert(k == 2 and t.wounded == 4, "kill_wounded 2 後 wounded 4")
	assert(AnonCohort.total(t.anon_cohorts) == 8, "總數 8（4 healthy + 4 wounded）")
	print("[OK] _test_anon_wound_heal_kill")

func _test_anon_transfer_carries_wounded() -> void:
	var a := TeamData.new(); a.anon_cohorts = {}
	var b := TeamData.new(); b.anon_cohorts = {}
	AnonCohort.add(a.anon_cohorts, "新兵", "healthy", 6)
	AnonCohort.add(a.anon_cohorts, "新兵", "wounded", 4)   # 共 10
	AnonTierSystem.transfer_proportional(a, b, 10)         # 全搬
	assert(AnonCohort.total(a.anon_cohorts) == 0, "來源清空")
	assert(b.wounded == 4, "wounded 桶隨轉移帶走，實際 %d" % b.wounded)
	assert(AnonCohort.by_health(b.anon_cohorts, "healthy") == 6, "healthy 6 帶走")
	print("[OK] _test_anon_transfer_carries_wounded")
```
註冊（接在 `_test_anon_cohort_stats()` 後）：
```gdscript
	_test_anon_wound_heal_kill()
	_test_anon_transfer_carries_wounded()
```

- [ ] **Step 2: 全套 headless 回歸**

```powershell
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
```
Expected: `=== DONE ===`、`[OK] _test_anon_wound_heal_kill`、`[OK] _test_anon_transfer_carries_wounded`、所有既有斷言綠、無 `SCRIPT ERROR`。

- [ ] **Step 3: multi sanity（漏水消失驗證）**

```powershell
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd
```
Expected: coin_eq delta=0；無 `SCRIPT ERROR`；`[InvariantViolation]` 仍只剩 `population drift`（2c 才修，量級不應**增加**）；**wounded 不再單調膨脹**（drift 訊息中 anon 數含 wounded 桶但 wounded 受 anon 上限約束，不會出現 wounded 遠超 pop 的舊膨脹特徵）。

- [ ] **Step 4: Commit**

```bash
git add scripts/data/team_data.gd scripts/simulation/anon_tier_system.gd scripts/simulation/health_system.gd scripts/simulation/npc_combat_system.gd scripts/simulation/interaction_system.gd scripts/simulation/subteam_system.gd scripts/simulation/invariant_audit.gd scripts/debug/headless_test.gd
git commit -m "refactor(anon): Phase 2b wounded 折入 cohort health 維度 + 修膨脹漏水"
```

---

## Task 7: hand-back

- [ ] **Step 1: 寫 hand-back** `docs/superpowers/handbacks/2026-06-17-anon-cohort-phase2b.md`（依 03_implementer 格式）：
- 實作摘要：每檔一行。
- 與 spec 差異：`kill_random` 保持只殺 healthy（wounded 在營不戰死）；combat `pop-wounded` 公式未改（getter 透明）—— 說明理由。
- 連動風險：`population` 仍手動（2c 轉 getter）；anon 死亡分支（resolve_anon_units `_is_unit_dead_bp`）仍直接 `population -= 1`，與 cohort 死亡（kill_random）並存，2c 統一；存檔若存 `wounded` 欄位需 Phase 4 處理。
- 待主 session 確認：2c 啟動（population → getter + 刪所有手動 population 寫入點）。

- [ ] **Step 2: Commit + push + 回報**

```bash
git add docs/superpowers/handbacks/2026-06-17-anon-cohort-phase2b.md
git commit -m "docs: anon cohort phase2b hand-back"
git push -u origin feat/anon-cohort-phase2b
```
回報分支（finishing 選 Option 3，主 session merge）。

---

## Self-Review

**Spec coverage：** 涵蓋 spec「wounded → 衍生」「health/combat 增傷改 move」「修漏水」「audit 公式同步」。`kill_random` 只殺 healthy 是對 spec「wounded 來源」的合理具體化（anon 無 per-unit 傷況，wounded 在營）。population→getter 屬 2c，combat `healthy_pop` 改寫因公式透明而不需要（已在 architecture 說明）。

**Placeholder scan：** 無 TBD。Task 5 Step 2 的「確認 caller」附明確核對指示（讀 subteam 合併流程），非 placeholder。

**Type consistency：** 新 helper 簽名 `wound_random/heal_random/kill_wounded(team,n)->int`、`_weighted_tier(team,health)->String` 跨 task 一致；測試呼叫對齊。`AnonCohort._key/by_health/move/remove/add/total` 對齊已 merge 版。`wounded` getter 回 int，所有讀取點（interaction/movement/game_setup/event_tag_shift）透明續用。
