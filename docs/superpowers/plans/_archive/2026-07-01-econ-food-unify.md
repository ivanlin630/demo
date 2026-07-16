# 經濟底 — 統一食物存取（成長/累積讀 coherent 食物）Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:subagent-driven-development or executing-plans. Steps use checkbox (`- [ ]`).

**Goal:** 統一食物模型——成長/累積/生育的 food surplus gate 讀 **`ResourceSystem.effective_food`（coherent：私產+自家糧倉）**，非私產 silo。→ regen 與交易共餵同一累積邏輯 → forest 隊賣特產→買糧→effective_food↑→生育/擴張 fire→pop 長。= 久掛 🟡 經濟底站穩。**統一非補丁**（藍圖鐵令）。

**Architecture:** 診斷確定（碼+measured）：`reaction_system:164`(_score_expand `food>100`)+`:199`(_evaluate_life_events surplus 7天) 讀 `t.resources["food"]`（私產 silo）→ 定居 forest 隊糧在糧倉、私產低 → gate fail → 不長。`ambition_ladder:49`(rung 累積)**已用 effective_food**（WS-2c 範例，對的）。fix=把這 2 處 silo-read 也換 effective_food（同 accessor 全用）。**不 nerf regen、保交易摩擦。**

**Tech Stack:** Godot 4.2.2 GDScript。測試 `scripts/debug/headless_test.gd`。

## Global Constraints
- **UTF-8 wrapper**：`.\tools\godot.ps1`。worktree：每 Godot/git 前 `Set-Location`。重型用 `GODOT_TIMEOUT=NNNN`（bash env prefix）。
- **★ 統一非補丁（藍圖鐵令）**：成長讀 **coherent 食物**（effective_food = 私產+自家糧倉，**既有 WS-2c accessor**）。**不**加「交易糧→bump granary」特殊線。同 accessor 全用（對齊 ambition_ladder:49）。
- **★ 守兩條**：①**不 nerf 地形 regen**（`resource_system` REGEN_RATE 絕不碰，forest 仍 3）②**交易摩擦保留**（不碰市集可達/價差/運輸 → plains 原生糧佔優、forest 靠交易興旺較費力 = 地形仍有意義）。
- **守恆**：純讀取改（food-read 換源），不碰守恆數學。coin_eq 0、InvariantViolation 0。
- **scope guard**：只 `reaction_system` 2 處 food-read 換 effective_food + state 接線 + 乾淨 bed + 測。不碰 REGEN_RATE/市集/交易機制/granary 填法/戰鬥/P1。
- baseline：開工前 headless 全綠。

---

### Task 1: 成長/擴張/生育 surplus gate 讀 effective_food（統一）

**Files:**
- Modify: `scripts/simulation/reaction_system.gd`（`_score_expand`:164 + `_evaluate_life_events`:199 → effective_food；thread state）
- Test: `scripts/debug/headless_test.gd`

**Interfaces:**
- Consumes: `ResourceSystem.effective_food(state, team)`（既有，私產+自家糧倉）。
- Produces: `_score_expand`/`_evaluate_life_events` 的 food surplus gate 讀 effective_food（需 state）。

- [ ] **Step 1: 讀 `reaction_system` _score_expand(163)/_evaluate_life_events(195) + 其 callers（找 state 從哪傳入 reaction system；evaluate 入口簽名）。確認 state 可 thread 到這兩函數。**

- [ ] **Step 2: 寫 failing test**
```gdscript
func _test_econ_growth_reads_coherent_food() -> void:
	# 定居隊糧在糧倉(私產低) → 生育/擴張 surplus gate 該認糧倉(effective_food)而非私產 silo
	var state := WorldState.new(); var cfg := {"map":{"radius":4},"teams":[]}; GameSetup.setup(state, cfg)
	var rs := ReactionSystem.new()
	var t := _mk_settled_team_granary_food(state, Vector2i(1,1))  # helper: 私產 food=0, 自家糧倉 food=500, pop 10
	# effective_food=500 >> 7天 buffer(10×2.4×7=168) → surplus_ok 該 true
	assert(ResourceSystem.effective_food(state, t) > 168.0, "[econ] 前置:effective_food 不足")
	var leader := state.persons[t.leader_id]
	# 生育 life-event：糧倉足 → surplus_ok true（讀 effective_food 非私產 0）
	var ev := rs._evaluate_life_events_for_test(state, leader, t)  # 或經公開入口
	assert(_has_breed_event(ev), "[econ] 糧倉足卻不生育(仍讀私產 silo=0)")
	# 擴張：糧倉足 + 統領 → _score_expand 該認 effective_food
	assert(rs._score_expand_food_ok(state, t), "[econ] 糧倉足卻擴張 food gate fail")
	print("[econ] growth reads coherent food OK")
```
> 測入口依實作（若 _evaluate_life_events 私有→經 evaluate 公開入口 + 注入 state；helper 造私產0+糧倉500 隊）。

- [ ] **Step 3: 跑測 FAIL**（現讀私產 silo=0 → gate fail）

- [ ] **Step 4: 實作**
- `_score_expand`:164：`var food := float(t.resources.get("food",0))` → `var food := ResourceSystem.effective_food(state, t)`（加 state 參數）。
- `_evaluate_life_events`:199：`float(t.resources.get("food",0))` → `ResourceSystem.effective_food(state, t)`。
- **thread state**：兩函數加 `state` 參數 → 改 caller（reaction evaluate 入口已有 state？順鏈傳）。`_breed_balance` 不動（人口比例，與 food 無關）。
- **不動** `p.needs["food"]`（satiety，已經 WS-2c 合併消費反映）；只改 raw food surplus gate。

- [ ] **Step 5: 跑測 PASS + 既有全綠**（飢荒/絕境/生育既有測——effective_food 是私產+糧倉 superset，舊私產足者仍足，不誤放寬餓隊：餓隊兩者皆空仍 fail）。

- [ ] **Step 6: Commit**
```
git add scripts/simulation/reaction_system.gd scripts/debug/headless_test.gd
git commit -m "feat(econ): 成長/擴張/生育 surplus gate 讀 effective_food(統一,coherent 私產+糧倉) (econ-food-unify)"
```

---

### Task 2: 乾淨 bed 驗整環（forest 賣特產→買糧→累積→長 pop）

**Files:**
- New: `config/econ_bed.json`（explicit：1 forest 隊 material 富 + 鄰 1 plains 存糧市集 + 無戰鬥噪音）
- New: `scripts/debug/econ_bed_diagnose.gd`（跑 bed + 量 forest pop/effective_food/granary/trade 軌跡）
- Test: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 建乾淨 bed config + runner**
`config/econ_bed.json`（explicit mode）：forest 隊（food 窮、material 富、pop 中）+ 鄰格 plains outpost 市集（food 充、掛 food sell order）+ **無第三方戰鬥隊**（隔離 combat 噪音）。runner 跑 ~6 月，月量 forest 隊：pop / effective_food / granary / 私產 food / task / 是否 TASK_TRADE。

- [ ] **Step 2: 跑 bed**
```
GODOT_TIMEOUT=600 powershell -NoProfile -Command ".\tools\godot.ps1 --headless --script scripts/debug/econ_bed_diagnose.gd"
```
**整環驗收**：forest 隊 food 危 → 賣 material 買糧（TASK_TRADE 成交）→ effective_food↑ → **pop 長（生育/擴張 fire）** → 興旺（非餬口 net0）。對照 plains 隊原生糧興旺。**forest 興旺較 plains 費力**（交易摩擦在=地形仍有意義）。

- [ ] **Step 3: 守恆 + framework + 既有 seed**
```
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd   # coin_eq 0
.\tools\godot.ps1 --headless --script scripts/debug/framework_validation.gd
.\tools\godot.ps1 --headless --script scripts/debug/food_ledger_diagnose.gd  # forest 是否改善
```
coin_eq 0、InvariantViolation 0、S1-S6 PASS。**確認 REGEN_RATE 未動。**

- [ ] **Step 4: Commit**
```
git add config/econ_bed.json scripts/debug/econ_bed_diagnose.gd scripts/debug/headless_test.gd
git commit -m "test(econ): 乾淨 bed 驗特化-交易-換糧-累積整環 (econ-food-unify)"
```

---

## 完成後（子 session）
1. push `feat/econ-food-unify`。
2. handback：改檔 + **乾淨 bed 整環結果（forest 賣特產→買糧→累積→長 pop fire 否？興旺較 plains 費力否？）** + 守恆 + 確認沒 nerf regen/沒動交易摩擦 + 連動風險（effective_food 換源對既有生育/擴張測、餓隊不誤放寬）+ 待確認（量級）。
3. finishing → Option 3，主 session merge。

## Self-Review（主 session）
- **統一非補丁**：用既有 effective_food（對齊 ambition_ladder），無「交易糧 bump granary」特殊線 → Task 1。
- **守 guards**：REGEN_RATE 未碰 + 交易摩擦未碰（Task 2 Step 3 確認）。
- **整環證** = 乾淨 bed forest 賣特產→累積→長 pop（Task 2），非混亂 seed。
- **不誤放寬餓隊**：effective_food 是私產+糧倉 superset；真餓隊兩者皆空仍 fail（Task 1 Step 5 既有飢荒測綠）。
- 風險：state 接線改 reaction 簽名（確認 caller 鏈有 state）；量級（surplus 閾 7天/擴張 100 沿用，effective_food 後是否需調 → bed 校）。
