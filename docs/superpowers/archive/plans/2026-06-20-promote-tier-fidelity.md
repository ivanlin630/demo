# 升 named 忠於 tier（#0b）Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:test-driven-development（每 Task 先寫失敗測試再實作）+ superpowers:executing-plans。Steps 用 checkbox 追蹤。

**Goal:** 升 anon→named 讀來源 tier 設戰鬥簇技能 + 晉升偏好抽高 tier → 高技能 named = 被提拔的老兵/菁英，補 #0 戲劇尾巴被晉升稀釋的缺口。

**Architecture:** 只改 `PersonGenerator.generate_for_team`：(1) `kill_random` 傳偏高 tier 權重並用回傳值取得來源 tier；(2) 依來源 tier 套戰鬥簇技能帶（`maxf` 不蓋 archetype 尾巴）。複用既有 `AnonTierSystem.kill_random(tier_weight)`，零新概念、不改 AnonTierSystem、簽名不變、不碰守恆。

**Tech Stack:** Godot 4.2.2 GDScript；`person_generator.gd`；headless + world_sim harness。

## Global Constraints

- wrapper 跑（UTF-8）：`.\tools\godot.ps1`。
- **只改生成技能值，不碰 state 流 / 守恆 / treasury share**。
- 來源：`specs/2026-06-20-promote-tier-fidelity-design`、藍圖 ruling `2026-06-20-blueprint-to-systems-dramatic-distribution`（item 4/5）。
- 回歸閘：headless 全綠、coin_eq=0、InvariantAudit 0；既有 `_test_promote_anon_takes_share` 不破。不用 multi drift。
- 全權重 / 技能帶 = TEST VALUE。

## File Structure

- `scripts/simulation/person_generator.gd`（const 表 + `generate_for_team` 改 + 私有 helper）。
- `scripts/debug/headless_test.gd`（tier fidelity 測試）。

---

### Task 1: 升 named 讀來源 tier 設戰鬥簇技能

**Files:**
- Modify: `scripts/simulation/person_generator.gd`
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- `generate_for_team(state, team, role, seed_offset)` 簽名不變。
- 新行為：升菁英 anon → named 戰鬥/戰術/統領 高；升平民 → 低。

- [ ] **Step 1: 寫失敗測試**

`headless_test.gd` 加 func，`_initialize()` 在 `_test_promote_anon_takes_share()` 後註冊 `_test_promote_tier_fidelity()`：

```gdscript
func _test_promote_tier_fidelity() -> void:
	print("--- #0b 升 named 忠於 tier ---")
	# 全菁英隊：升上來的 named 戰鬥簇應高
	var s_elite := WorldState.new(); s_elite.world = WorldData.new()
	var t_elite := TeamData.new()
	t_elite.team_id = 0; t_elite.leader_id = -1; t_elite.named_members = []
	AnonCohort.add(t_elite.anon_cohorts, "菁英", "healthy", 10)
	s_elite.teams[0] = t_elite
	var pe := PersonGenerator.generate_for_team(s_elite, t_elite, "member")
	assert(pe != null, "菁英隊應產 named")
	assert(pe.skills["戰鬥"] >= 0.7, "菁英升 named 戰鬥應≥0.7，實際=%.2f" % pe.skills["戰鬥"])
	assert(pe.skills["統領"] >= 0.5, "菁英升 named 統領應≥0.5，實際=%.2f" % pe.skills["統領"])

	# 全平民隊：升上來的 named 戰鬥簇應低（無加成）
	var s_pleb := WorldState.new(); s_pleb.world = WorldData.new()
	var t_pleb := TeamData.new()
	t_pleb.team_id = 0; t_pleb.leader_id = -1; t_pleb.named_members = []
	AnonCohort.add(t_pleb.anon_cohorts, "平民", "healthy", 10)
	s_pleb.teams[0] = t_pleb
	var pp := PersonGenerator.generate_for_team(s_pleb, t_pleb, "member")
	assert(pp != null, "平民隊應產 named")
	# 平民升 = generate 預設低值（容忍 archetype outlier 偶發；用低期望斷言均值面向）
	assert(pp.skills["戰鬥"] <= 0.6, "平民升 named 戰鬥不應高，實際=%.2f" % pp.skills["戰鬥"])
	print("#0b tier fidelity OK (菁英戰鬥=%.2f / 平民戰鬥=%.2f)" % [pe.skills["戰鬥"], pp.skills["戰鬥"]])
```

> 註：平民斷言用 `<=0.6` 容忍 generate 的 archetype outlier（rate 0.18）偶發推高；核心是菁英 vs 平民的階梯差。若 flaky，改用固定 seed_offset 鎖兩隊 rng。

- [ ] **Step 2: --import + 跑驗證失敗**

```
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
```
Expected fail：現 `generate_for_team` 不看 tier → 菁英隊 `pe.skills["戰鬥"]` 落 [0,0.3]（除非 outlier 偶中）→ 斷言 `>=0.7` 掛。

- [ ] **Step 3: 實作**

`person_generator.gd` 檔頭加 const（接在現 `ARCHETYPES` 後）：

```gdscript
# #0b 升 named 忠於 tier：晉升偏好抽高 tier + 新 named 戰鬥簇技能讀來源 tier。
const PROMOTE_TIER_WEIGHT := {"平民": 0.2, "新兵": 0.6, "老兵": 1.5, "菁英": 3.0}  # TEST VALUE
const PROMOTE_TIER_SKILLS := {              # TEST VALUE：來源 tier → 戰鬥簇技能帶
	"平民": {},
	"新兵": {"戰鬥": [0.30, 0.50]},
	"老兵": {"戰鬥": [0.50, 0.70], "戰術": [0.30, 0.50], "統領": [0.30, 0.50]},
	"菁英": {"戰鬥": [0.70, 0.90], "戰術": [0.50, 0.70], "統領": [0.50, 0.70]},
}
```

`generate_for_team` 改尾段（現 :91-93，`state.persons[p.id] = p` 後的 `kill_random` 那行）：

```gdscript
	state.persons[p.id] = p
	# 晉升：抽 1 anon（偏高 tier = 提拔精銳）→ 轉 named；記實際來源 tier
	var killed: Dictionary = AnonTierSystem.kill_random(team, 1, "promote", PROMOTE_TIER_WEIGHT)
	var src_tier: String = ""
	for tier in AnonCohort.TIER_ORDER:
		if int(killed.get(tier, 0)) > 0:
			src_tier = tier
			break
	if src_tier != "":
		_apply_promotion_skills(p, src_tier, _team_seed(state, team, seed_offset))
	return p

# 來源 tier → 新 named 戰鬥簇技能下限（maxf 不蓋 archetype 尾巴）
static func _apply_promotion_skills(p: PersonData, src_tier: String, seed: int) -> void:
	var bands: Dictionary = PROMOTE_TIER_SKILLS.get(src_tier, {})
	if bands.is_empty():
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = seed * 31 + 7   # 與 generate 內部 rng 區隔，保可重現
	for sk in bands:
		var band: Array = bands[sk]
		var v: float = rng.randf_range(float(band[0]), float(band[1]))
		p.skills[sk] = maxf(float(p.skills.get(sk, 0.0)), v)
```

> 執行確認：
> - `kill_random` 回傳 `{tier: 死亡數}`（所有 tier 鍵，多為 0）；只升 1 人 → 恰一 tier =1，取首個 >0。
> - `_team_seed` 已存在（:117）；技能 rng 與 generate 內 rng 不同 seed 偏移，避免相關。
> - cohort/population drift 致 `kill_random` 空（全 0）→ `src_tier=""` → 跳過 → 退回 generate 預設（安全）。

- [ ] **Step 4: --import + 跑驗證通過**

```
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
```
Expected：`#0b tier fidelity OK`、`=== DONE ===`、coin_eq=0、InvariantAudit 0。
既有 `CoinStorage Task7 OK`（`_test_promote_anon_takes_share`，_seed_pop 全平民）仍綠 = 平民升 coin share 不變。

- [ ] **Step 5: Commit**
```bash
git add scripts/simulation/person_generator.gd scripts/debug/headless_test.gd
git commit -m "feat(world-gen): 升 named 忠於來源 tier(戰鬥簇技能+偏高 tier 晉升)"
```

---

### Task 2: 回歸 + world_sim 重量 + 回報

**Files:** 無 code 改（跑 + 回報）。

- [ ] **Step 1: headless 回歸**
```
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
```
Expected：`=== DONE ===`、`#0b tier fidelity OK`、coin_eq=0、InvariantAudit 0。

- [ ] **Step 2: world_sim 重量（2 年，seed 77 可重現）**
```
.\tools\godot.ps1 --headless --script scripts/debug/world_sim.gd
```
Expected：跑通無 SCRIPT ERROR；`[ProbeSummary]` 印；不變量/coin_eq 維持。
（觀察：晉升後 named 戰技分佈是否拉開；可選加臨時 print 比對升 named 技能，回報後移除。）

- [ ] **Step 3: 回報 handback**

寫 `docs/superpowers/handbacks/2026-06-20-implementer-to-systems-promote-tier-fidelity.md`（frontmatter `from: implementer / to: systems / status: open`）：
- tier fidelity 測試結果（菁英 vs 平民升 named 戰技值）。
- world_sim 2 年 `[ProbeSummary]` 對照前次（有無 emergent 變化；技能尾巴更耐久是否影響戰/立國）。
- 異常（守恆 / flaky / 平衡 feel）。

- [ ] **Step 4: Commit handback**
```bash
git add docs/superpowers/handbacks/2026-06-20-*promote-tier*.md
git commit -m "docs(world-gen): #0b 升 named 忠於 tier world_sim 重量回報"
```

---

## Self-Review 註記

- **複用而非新建**：`kill_random` 已有 `tier_weight` 參數（spine 量測前已加）；本項只是首個非空 caller + 用回傳值。AnonTierSystem 零改。
- **守恆安全**：只改 named 生成技能值（非資源/coin/cohort 數）。treasury share 邏輯原樣。coin_eq 無關。
- **不蓋 #0 尾巴**：`maxf` 套用 → archetype outlier named 若已 roll 高戰技，不被 tier 帶降。
- **確定性**：來源 tier 抽走 global randf（pre-existing kill_random 行為，非本項引入）；技能 roll seeded。測試用單一 tier 隊 → 來源唯一 → 穩定。若平民隊測 flaky（outlier 偶發），鎖 seed_offset。
- **一致性**：初始 leader（game_setup generate role=leader）已有 #0 戲，不動；本項只補晉升路徑。兩路徑都有技能尾巴來源（ruling item 5）。
- **TEST VALUE**：PROMOTE_TIER_WEIGHT、PROMOTE_TIER_SKILLS 帶值 = 待平衡。
- **非戰鬥技能不動**：只設戰鬥/戰術/統領（避免菁英兵升上來突會醫術/商業）。
