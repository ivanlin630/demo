# 性別資料 + 生育需兩性 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans. Steps use checkbox (`- [ ]`).

**Goal:** 加性別資料（PersonData.sex + team anon_female_ratio）+ 生育需兩性（全單性隊內部不繁衍）。④Trait 前置、獨立小改。

**Architecture:** PersonData.sex（named, 50/50 生成）+ TeamData.anon_female_ratio（float metadata, 不動 cohort schema）+ reaction 生育 gate by 兩性平衡。conservation 安全（ratio 不影響 pop count）。

**Tech Stack:** Godot 4.2.2 GDScript。測試 `headless_test.gd` + `world_sim.gd`。

## Global Constraints
- wrapper 跑 Godot（UTF-8）。
- **不動 anon_cohort key schema**（`tier|health` 不變）→ 既有 cohort 測零衝突、InvariantAudit population 零影響。
- 不碰 resources/coin → coin_eq/InvariantAudit 0。
- seeded rng 生成 sex（可重現）。
- TEST VALUE：生成 50/50、anon_female_ratio 預設 0.5。

---

### Task 1: PersonData.sex + 生成

**Files:**
- Modify: `scripts/data/person_data.gd`（加 sex）
- Modify: `scripts/simulation/person_generator.gd`（generate() 設 sex）
- Test: `scripts/debug/headless_test.gd`（加 `_test_person_sex`，註冊）

**Interfaces:**
- Produces: `PersonData.sex: String`（"male"/"female"，預設 "male"）；generate() 50/50 設 sex。

- [ ] **Step 1: 寫失敗測試**

`headless_test.gd` 加（決策/data 測群）：
```gdscript
func _test_person_sex() -> void:
	print("--- 性別資料生成 ---")
	var pg := PersonGenerator.new()
	var rng := RandomNumberGenerator.new(); rng.seed = 42
	var males := 0; var females := 0
	for i in 200:
		var p: PersonData = pg.generate(rng)   # 確認 generate 簽名(下方 Step3 對齊)
		assert(p.sex in ["male", "female"], "sex 應 male/female，實際=%s" % p.sex)
		if p.sex == "male": males += 1
		else: females += 1
	assert(males > 50 and females > 50, "200 抽應兩性皆有(≈均衡)，男=%d 女=%d" % [males, females])
	print("person sex OK (男=%d 女=%d)" % [males, females])
```
> 註：先讀 `person_generator.gd` 確認 `generate()` 確切簽名（是否吃 rng 參數 / 回 PersonData）。測試與呼叫對齊實際簽名。

註冊進 `_run_sim_test`。

- [ ] **Step 2: 跑測試確認失敗**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: FAIL — PersonData 無 sex（預設 "male" → 全 male → `females>50` 失敗）或 sex 未生成。

- [ ] **Step 3: 加 sex 欄位 + 生成**

`scripts/data/person_data.gd`：欄位區（age 附近）加：
```gdscript
var sex: String = "male"   # "male"/"female"（④Trait 前置資料；anon 用 team.anon_female_ratio）
```
`scripts/simulation/person_generator.gd` `generate()` 內（設 age 那行附近）加（用該函式既有 rng）：
```gdscript
	p.sex = "female" if rng.randf() < 0.5 else "male"
```
（若 generate() 無 rng 參數，用其內部既有 rng 來源；對齊現有 pattern。）

- [ ] **Step 4: 跑測試確認通過**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: PASS — `person sex OK` 兩性皆有；`=== DONE ===` 既有測全綠。

- [ ] **Step 5: Commit**

```bash
git add scripts/data/person_data.gd scripts/simulation/person_generator.gd scripts/debug/headless_test.gd
git commit -m "feat(data): PersonData.sex + generate 50/50(④Trait前置資料)"
```

---

### Task 2: anon_female_ratio + 生育需兩性

**Files:**
- Modify: `scripts/data/team_data.gd`（加 anon_female_ratio）
- Modify: `scripts/simulation/reaction_system.gd`（`_evaluate_life_events` 生育 gate）
- Test: `scripts/debug/headless_test.gd`（加 `_test_breed_needs_both_sexes`，註冊）

**Interfaces:**
- Consumes: `PersonData.sex`、`AnonTierSystem.total_pop(team)`、`team.named_members`、`BREED_BASE_CHANCE`。
- Produces: `TeamData.anon_female_ratio: float`（預設 0.5）；生育 gate：全單性 → 0、平衡 → 縮放。

- [ ] **Step 1: 寫失敗測試**

`headless_test.gd` 加：
```gdscript
func _test_breed_needs_both_sexes() -> void:
	print("--- 生育需兩性(全男隊不繁衍) ---")
	var rs := ReactionSystem.new()
	# 全男隊(named 全 male + anon_female_ratio 0) → 生育 gate=0
	var t_m := TeamData.new(); t_m.team_id = 0
	_seed_pop(t_m, 10); t_m.anon_female_ratio = 0.0
	var lm := PersonData.new(); lm.id = 1; lm.sex = "male"; lm.needs = {"food": 0.9, "safety": 0.9}
	t_m.named_members = [1]
	# 兩性隊 → 可繁衍
	var t_b := TeamData.new(); t_b.team_id = 1
	_seed_pop(t_b, 10); t_b.anon_female_ratio = 0.5
	# 用 helper 算 effective 平衡(下方 Step3 暴露的判定函式)，或直接驗 _evaluate_life_events 不出 P5_breed
	# 全男隊 effective female=0 → balance=0 → 不該出 P5_breed
	var fed_safe := {"food": 0.95, "safety": 0.95}
	# 設足糧足安全環境(對齊 _evaluate_life_events 前置:surplus_ok/cap)
	t_m.resources = {"food": 100000.0}; t_b.resources = {"food": 100000.0}
	# 直接驗判定：全男隊 breed_balance==0、兩性隊>0（Step3 暴露 _breed_balance(team)）
	assert(rs._breed_balance(t_m) == 0.0, "全男隊 breed_balance 應 0(不繁衍)")
	assert(rs._breed_balance(t_b) > 0.0, "兩性隊 breed_balance 應 >0")
	print("breed needs both sexes OK")
```
> 註：先讀 `reaction_system.gd _evaluate_life_events` 確認結構 + `team.named_members`/needs 存取 + `_seed_pop` 給的 anon 性別。測試對齊實際（若 named needs 結構不同，調整 fixture）。`_breed_balance` 為 Step3 抽出的判定 helper。

註冊。

- [ ] **Step 2: 跑測試確認失敗**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: FAIL — `_breed_balance` 不存在 / anon_female_ratio 無欄位。

- [ ] **Step 3: 加 anon_female_ratio + 生育 gate**

`scripts/data/team_data.gd`：欄位區（minor_population 附近）加：
```gdscript
var anon_female_ratio: float = 0.5   # anon 女性占比(metadata,不影響 pop count);戰損可扭斜(combat他域後)
```

`scripts/simulation/reaction_system.gd` 加判定 helper + 接進 `_evaluate_life_events`：
```gdscript
# 兩性平衡因子(0..1)：全單性→0(不繁衍);越平衡越高。named 用 sex,anon 用 team ratio。
func _breed_balance(team: TeamData) -> float:
	var anon_total: int = AnonTierSystem.total_pop(team)
	var m: float = float(anon_total) * (1.0 - team.anon_female_ratio)
	var f: float = float(anon_total) * team.anon_female_ratio
	# 不在此 fn 內遍歷 named（呼叫端傳 state 才拿得到 PersonData）→ 由呼叫端補 named 計數
	if min(m, f) <= 0.0: return 0.0
	return min(m, f) / maxf((m + f) / 2.0, 1.0)
```
（**named 性別計數**：`_evaluate_life_events` 有 team 但需 state 取 named PersonData.sex。確認該 fn 簽名是否帶 state；若無，用 team-level anon ratio 為主 + named 由呼叫鏈補。最小實作：`_breed_balance` 先用 anon ratio；named 計數若 fn 可取 state.persons 則加 named males/females 進 m/f。對齊現有 `_evaluate_life_events(p, t)` 簽名——它逐 person 呼叫，p 是 breeder；可累積 team named 性別需在 team 層。實作者：若簽名只有 (p,t) 無 state，則 `_breed_balance` 用 anon ratio + 把 breeder 自身 sex 計入一方，並在 team 首次評估時掃 named（透過 t.named_members 需 state）——若取不到 state，退而用「anon ratio + breeder sex」近似，註明。)

`_evaluate_life_events` 出 P5_breed 前乘 balance：
```gdscript
		var balance: float = _breed_balance(t)
		if balance <= 0.0:
			return events   # 全單性 → 不繁衍
		var chance: float = (BREED_BASE_CHANCE + float(p.skills.get("醫療", 0.0)) * 0.1) * balance
		if randf() < chance:
			events.append("P5_breed")
```

- [ ] **Step 4: 跑測試確認通過（含回歸）**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: PASS — `breed needs both sexes OK` + 既有人口/繁衍/飢荒測全綠（兩性隊仍繁衍）；`=== DONE ===`、coin_eq/InvariantAudit 0。**若既有人口成長測因 gate 變紅 → 檢查 fixture 是否需設兩性(契約更新)，記錄；勿放寬斷言掩蓋真 bug。**

- [ ] **Step 5: Commit**

```bash
git add scripts/data/team_data.gd scripts/simulation/reaction_system.gd scripts/debug/headless_test.gd
git commit -m "feat(reaction): 生育需兩性 — anon_female_ratio+balance gate(全男隊不繁衍)"
```

---

### Task 3: 2 年 world_sim 驗收 + 回歸

**Files:** Verify only：`world_sim.gd`、`headless_test.gd`、`config/world_sim.json`（若種全男隊驗 emergent）

- [ ] **Step 1: 跑 2 年 world_sim**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/world_sim.gd`
觀察：pop 仍成長（兩性隊）、`InvariantAudit population` 0、`=== DONE ===`、無 conservation 破。

- [ ] **Step 2: emergent 驗（全男隊不繁衍）**

可選：`config/world_sim.json` 種一支全男隊（named 全 male + anon_female_ratio 0）→ trace 其 pop：內部不長（minor_population 不增），只靠招募/吸收。或用單測 `_test_breed_needs_both_sexes` 已證機制。記錄。

- [ ] **Step 3: 全回歸閘**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: 全綠 `=== DONE ===`、coin_eq/InvariantAudit 0。

- [ ] **Step 4: handback（無 code 改則記量測）**

寫 handback：sex 生成、生育 gate 行為、2 年 world_sim pop/conservation、emergent（全男不繁衍）證據、回歸。

---

## 完成後
子 session handback：sex 資料 + ratio、生育 gate（_breed_balance named/anon 計數實作細節）、2 年 world_sim pop+conservation、全男隊 emergent、回歸。**標 combat 接點**：戰損扭斜 anon_female_ratio（戰爭傷疤）= 待他域 combat（未決）。

## Self-Review
- Spec coverage：PersonData.sex+生成=Task1；anon_female_ratio+生育兩性 gate=Task2；2年sim+emergent=Task3。全覆蓋。
- Placeholder：無（generate/`_evaluate_life_events` 簽名 Step 註明先讀確認）。
- Type consistency：`sex: String`、`anon_female_ratio: float`、`_breed_balance(team)->float`；不動 cohort schema → conservation 安全。
- **風險**：`_breed_balance` 的 named 性別計數依賴 `_evaluate_life_events` 能否取 state.persons（簽名 (p,t) 可能取不到）→ 實作者對齊：取不到則用 anon ratio + breeder sex 近似並註明，回報 systems 是否需改簽名傳 state（系統可後續精修）。
