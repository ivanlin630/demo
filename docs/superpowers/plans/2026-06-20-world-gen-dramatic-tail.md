# world-gen 戲劇性尾巴 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** world-gen 從「人人平庸」→「多數凡人 + 關鍵少數狂人」，狂人（霸主/屠夫/謀士/懦夫）驅動立國/血仇/陰謀。藍圖 ruling #0（root），最可能連帶解 emergent 魂全 0。

**Architecture:** `PersonGenerator.generate` 加集中式 outlier 尾巴（多數窄帶 + per-person archetype roll 推連貫 trait 簇極端 + skills 尾巴）。量測 config（world_sim.json）種幾個極端 leader 讓重量立即有戲。只改 person 生成值，不碰守恆。

**Tech Stack:** Godot 4.2.2 GDScript；`person_generator.gd`；config json；headless + world_sim harness。

## Global Constraints

- wrapper 跑（UTF-8）。
- **只改生成值，不碰 state 流/守恆**：generate 只 procedural（晉升/member/random）；explicit config 隊 leader 值由 config 定，generate 不覆寫。
- 來源：`specs/2026-06-20-world-gen-dramatic-tail-design`、藍圖 ruling `2026-06-20-blueprint-to-systems-measurement-rulings`（#0）。
- 回歸閘：headless 全綠、coin_eq=0、InvariantAudit 0（極端值不破守恆/不崩）；world_sim 重量 emergent 數項 0→非零。不用 multi drift。
- 全 outlier 機率/帶值 = TEST VALUE。可重現（generate 已 seeded）。

## File Structure

- `scripts/simulation/person_generator.gd`（`generate` 戲劇尾巴 + const + archetype 表）。
- `config/world_sim.json`（種子極端 leader）。
- `scripts/debug/headless_test.gd`（分佈測試）。

---

### Task 1: PersonGenerator.generate 戲劇尾巴

**Files:**
- Modify: `scripts/simulation/person_generator.gd`
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- `generate(state, seed_offset, role)` 簽名不變；內部分佈改。
- Produces: 多數 values 窄帶 [0.35,0.65]、skills 低；少數 outlier 在 archetype 簇推極端。

- [ ] **Step 1: 寫失敗測試**（分佈有尾巴）

```gdscript
func _test_world_gen_dramatic_tail() -> void:
	print("--- world-gen 戲劇尾巴 ---")
	var s := WorldState.new()
	var n := 200
	var has_extreme_hi := false   # 任一 value >0.85
	var has_extreme_lo := false   # 任一 value <0.15
	var has_skill_tail := false   # 任一 skill >0.5
	var normal_count := 0
	for i in n:
		var p := PersonGenerator.generate(s, 1000 + i, "member")
		for v in p.values.values():
			if v > 0.85: has_extreme_hi = true
			if v < 0.15: has_extreme_lo = true
		for sk in p.skills.values():
			if sk > 0.5: has_skill_tail = true
		# 凡人 proxy：野心在窄帶
		if p.values["野心"] >= 0.3 and p.values["野心"] <= 0.7: normal_count += 1
	assert(has_extreme_hi, "有極端高 value 尾巴")
	assert(has_extreme_lo, "有極端低 value 尾巴")
	assert(has_skill_tail, "有高 skill 尾巴(謀士/宿將)")
	assert(normal_count > n / 2, "多數仍凡人(野心窄帶)")
	print("dramatic tail OK (normal=%d/%d)" % [normal_count, n])
```
`_initialize()` 註冊。

- [ ] **Step 2: 跑 harness 驗證失敗**（現均勻 [0.2,0.8] 無 >0.85/<0.15、skills ≤0.4）

- [ ] **Step 3: 實作 generate 尾巴**

`person_generator.gd` 加 const + archetype 表（檔頭）：
```gdscript
const OUTLIER_RATE := 0.18          # TEST VALUE：member 成狂人機率
const OUTLIER_RATE_LEADER := 0.45   # TEST VALUE：leader 更高（leader 驅動戲劇）
const NORMAL_LO := 0.35             # 凡人窄帶
const NORMAL_HI := 0.65
const EXTREME_HI_LO := 0.85         # 極端高帶
const EXTREME_LO_HI := 0.15         # 極端低帶
const SKILL_TAIL_LO := 0.5          # outlier/宿將 高起點 skill
const SKILL_TAIL_HI := 0.9

# archetype 簇：高 values / 低 values / 高 skills（連貫人格）
const ARCHETYPES := {
	"霸主": { "hi_v": ["野心", "好戰"],        "lo_v": [],        "hi_s": ["統領"] },
	"屠夫": { "hi_v": ["殘忍", "好戰"],        "lo_v": ["信義"],  "hi_s": ["戰鬥"] },
	"謀士": { "hi_v": ["慎重"],                "lo_v": [],        "hi_s": ["計謀", "偵查"] },
	"懦夫": { "hi_v": ["求生欲"],              "lo_v": ["好戰", "野心"], "hi_s": [] },
}
```

`generate` 的 values/skills 段改（取代現 :31-42 三迴圈）：
```gdscript
	# Values：多數窄帶凡人
	for v in p.values.keys():
		p.values[v] = rng.randf_range(NORMAL_LO, NORMAL_HI)

	# Attributes 0.4~0.8（不變）
	for a in p.attributes.keys():
		p.attributes[a] = rng.randf_range(0.4, 0.8)

	# Skills：多數低；leader +0.1
	for sk in p.skills.keys():
		var base: float = rng.randf_range(0.0, 0.3)
		if role == "leader": base += 0.1
		p.skills[sk] = clampf(base, 0.0, 1.0)

	# 戲劇尾巴：per-person outlier roll → archetype 簇推極端
	var rate: float = OUTLIER_RATE_LEADER if role == "leader" else OUTLIER_RATE
	if rng.randf() < rate:
		var names: Array = ARCHETYPES.keys()
		var arch: Dictionary = ARCHETYPES[names[rng.randi() % names.size()]]
		for v in arch["hi_v"]:
			p.values[v] = rng.randf_range(EXTREME_HI_LO, 1.0)
		for v in arch["lo_v"]:
			p.values[v] = rng.randf_range(0.0, EXTREME_LO_HI)
		for sk in arch["hi_s"]:
			p.skills[sk] = rng.randf_range(SKILL_TAIL_LO, SKILL_TAIL_HI)
```

- [ ] **Step 4: --import + 跑驗證通過**

Expected: `dramatic tail OK`、`=== DONE ===`。既有測試若依賴 generate 中庸值（精確斷言）→ 對齊（極端尾巴是預期；用固定 seed 或放寬）。

- [ ] **Step 5: 回歸守恆**

```
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
```
Expected: `=== DONE ===`、coin_eq=0、InvariantAudit 0（極端值不破守恆）。

- [ ] **Step 6: Commit**
```bash
git add scripts/simulation/person_generator.gd scripts/debug/headless_test.gd
git commit -m "feat(world-gen): generate 戲劇尾巴(多數凡人+少數 archetype 狂人)"
```

---

### Task 2: 量測 config 種子極端 leader

**Files:**
- Modify: `config/world_sim.json`

> explicit config leader 值不走 generate → 量測重量要立即有狂人，需 config 直接種（否則等死亡晉升才見尾巴）。

- [ ] **Step 1: 種極端 leader**

`config/world_sim.json` 改幾個 leader 值為極端 archetype（保留其餘隊中庸當凡人對照）：
- **Team0「統領城」leader → 霸主**：`values.野心=0.95, 好戰=0.85`、`skills.統領=0.8`。
- **Team2「敵對軍隊」leader → 屠夫**：`values.殘忍=0.9, 好戰=0.9, 信義=0.2`、`skills.戰鬥=0.7`。
- **Team5「流亡狼軍」leader → 謀士**：`values.慎重=0.85`、`skills.計謀=0.85, 偵查=0.75`。
- 其餘隊 leader 值不動（凡人對照）。

> 只動 values/skills 既有鍵，不增刪欄位。守恆無關（人格值非資源）。

- [ ] **Step 2: --import + config 載入驗證**

```
.\tools\godot.ps1 --headless --import
```
（純資料，import 不報錯即可；實跑 Task3。）

- [ ] **Step 3: Commit**
```bash
git add config/world_sim.json
git commit -m "feat(world-gen): world_sim.json 種子極端 leader(霸主/屠夫/謀士)"
```

---

### Task 3: 回歸 + world_sim 重量 + emergent 回報

**Files:**
- 無 code 改（跑 + 回報）。

- [ ] **Step 1: headless 回歸守恆**

```
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
```
Expected: `=== DONE ===`、`dramatic tail OK`、coin_eq=0、InvariantAudit 0。

- [ ] **Step 2: world_sim 重量（2 年）**

```
.\tools\godot.ps1 --headless --script scripts/debug/world_sim.gd
```
（max_ticks 172800 已在 config；分鐘級。）
Expected:
- 跑通（或自然全滅提早收尾）無 SCRIPT ERROR。
- `[ProbeSummary]` 印；**對照前次全 0 的 emergent**：`g2.faction_found` / `g2.vendetta_trigger` / `g2.feud_formed` / `g3.detect_裁決` / `g3.scout_dispatch` / `g3.ambush` 至少數項 **0→非零**（狂人驅動魂自己冒）。
- 不變量/coin_eq 維持。

- [ ] **Step 3: 回報 handback**

寫 `docs/superpowers/handbacks/2026-06-20-implementer-to-systems-world-gen-numbers.md`：
- 分佈測試結果（凡人/狂人比）。
- world_sim 2 年 `[ProbeSummary]` 全表 + **對照前次（spine measurement）逐鍵 0→非零**。
- 哪些魂冒出來（立國/血仇/裁決/誘殺）、哪些仍 0（若有 → 該機制可能要場景或門檻，回報藍圖）。
- 異常（守恆/世界更激烈致崩/平衡 feel）。

- [ ] **Step 4: Commit handback**
```bash
git add docs/superpowers/handbacks/2026-06-20-*world-gen*.md
git commit -m "docs(world-gen): 戲劇尾巴 world_sim 重量回報(emergent 0→?)"
```

---

## Self-Review 註記

- **explicit vs procedural 邊界**：Task1 改 generate（procedural 根）+ Task2 config 種子（explicit 量測隊）→ 兩路徑都有狂人。重量立即見戲（config）+ 長期晉升維持尾巴（generate）。
- **守恆安全**：只改人格 values/skills（非資源/coin）→ coin_eq 無關。回歸驗 InvariantAudit 0。
- **行為非保留**：極端值入世界 → 更激烈（戰/裂/脫軌變多）= 預期戲劇。既有精確值斷言放寬/固定 seed。
- **驗收核心 = world_sim 重量 emergent 0→非零**：證實 #0 是 root（藍圖預測）。若仍 0 → 該機制門檻太嚴或要場景，回報藍圖（#3）。
- **TEST VALUE**：OUTLIER_RATE(.18)/LEADER(.45)、NORMAL 窄帶、EXTREME 帶、SKILL_TAIL 帶、archetype 簇成員。全待平衡。
- **執行確認**：archetype hi_s 用 skill 鍵（計謀/偵查/統領/戰鬥 = skills 非 values）；謀士「計謀」是 skill 不是 value；outlier roll 用同 rng 保可重現；config 只動既有鍵。
