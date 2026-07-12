# 中長期計畫層 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 把「被動讀數的野心階梯」升級成「主動攀爬的中長期計畫層」——rung 事件驅動穩定化 + phase 承諾軌跡偏置 rank_scored,讓隊真的爬到立國（established>0）而非反應式苟活餓死。

**Architecture:** 延伸既有 `AmbitionLadder` + `rank_scored`,**非新求解器**。`plan_phase` = feedback controller（讀進度訊號→調偏置→觀察→再調），唯讀既有階梯條件輸出當事後判讀,唯一作用=給 `rank_scored` 一個偏置 term 輸入。四層:目標階(rung)→milestone(達成條件)→phase(在幹嘛爬)→承諾+偏置。

**Tech Stack:** Godot 4.2.2 GDScript。`scripts/simulation/ambition_ladder.gd`（rung 引擎）、`scripts/simulation/decision/{decision_context,terms}.gd`（rank_scored 偏置）、`scripts/data/team_data.gd`（狀態欄）、`scripts/debug/headless_test.gd`（TDD）、`scripts/debug/warring_harness.gd`（探針/驗收）。

## Global Constraints

- **統一框架硬約束**：不建 bespoke planner。`rank_scored` 仍是唯一「決定行動」的求解器;`plan_phase` 只是餵它的一個偏置 term 輸入（同 archetype/threat 輸入維度層級）。
- **determinism byte-identical**（同 seed）：所有新邏輯**零 randf**;EWMA/trend 純算術;team 迭代穩定序。
- **複用非重造**：階梯條件(`target_rung`)/archetype(`derive_archetype`)/COMMITMENT_BONUS/survival·投靠·整併·遷移 option/敗北/threat——接線非重寫。
- **框架內冗餘 lens**：新 term 前確認 vs 既有 `intent_fit`/`ambient_train_drive` 非重複求解。
- **baseline 位移非 regression**：行為改動（rung 穩定化→階分布→established 變）;measurer 標「plan-layer 位移」重生 baseline（比照 world-gen 先例）。
- **TEST VALUE 全標**：新常數皆 `# TEST VALUE`,measurer 校。
- **establishment-redesign(B1+tenure 主閘版)已被用戶否決,不實作**;established 判定走本計畫層 milestone/rung。

---

## File Structure

- `scripts/simulation/ambition_ladder.gd` — **rung 引擎**（slice 1 改 update() 事件驅動 + trend；slice 3 加 survival-bypass）。所有權:此檔是 rung 唯一寫者。
- `scripts/data/team_data.gd` — **狀態欄**（slice 1 加 trend EWMA 欄;slice 2 加 plan_phase 欄）。純資料。
- `scripts/simulation/decision/decision_context.gd` — **phase 導出 + ctx 偏置**（slice 2:缺口×個性×隊形→plan_phase→ctx.plan_phase_drive）。
- `scripts/simulation/decision/terms.gd` — **偏置 term**（slice 2:`plan_phase_drive` term 加入 rank_scored）。
- `scripts/simulation/observer_query_api.gd` + Observer GUI（slice 4:露 plan_phase 欄）。
- `scripts/debug/headless_test.gd` — 各 slice TDD 斷言。
- `scripts/debug/warring_harness.gd` — 探針（rung 穩定度/phase 分布/established/軌跡）。

四 slice 序（reviewer 定，依賴序）：①rung 事件驅動（獨立驗 determinism，不碰 phase）②phase 導出+偏置（讀 rung 不碰 rung）③survival-bypass（掛①rung update）④GUI（純顯示）。每 slice 獨立可測、獨立 dispatch。

---

## Task 1: rung 事件驅動化（穩定化，不碰 phase）

把 `AmbitionLadder.update()` 從「每 10h 從瞬時指標重算 rung」改成「milestone 達成→升 / trend 持續失敗→降」的事件驅動。天生穩定（只事件變）。**本 slice 不引入 phase**,只穩定化 rung。

**Files:**
- Modify: `scripts/data/team_data.gd:74-75`（加 trend EWMA 狀態欄，鄰 food_flow）
- Modify: `scripts/simulation/ambition_ladder.gd:64-102`（target_rung 保留為 milestone 判讀；重寫 update()）
- Test: `scripts/debug/headless_test.gd`（加 `_test_plan_rung_event_driven`）

**Interfaces:**
- Consumes: 既有 `team.food_flow_avg`（decision_context 已維護日均淨食物流 EMA）、`team.population`、`team.faction_id`、`team.ambition_cap`、`team.ambition_rung`。
- Produces（slice 3 依賴）：
  - `team.rung_trend_ewma: float`、`team.rung_trend_ewma_last: float`、`team.rung_stall_count: int`（trend 狀態）。
  - `AmbitionLadder.milestone_met(state, team, target_rung_val) -> bool`（判目標階達成，slice 3 bypass 複用）。
  - `AmbitionLadder.update(state, team)` 語意：事件驅動 rung（升=milestone、降=stall），簽名不變。

### 設計（HOW，systems 定）
- **milestone 判達成**：複用既有 `target_rung()` 的階梯條件——「當前 rung+1 的達成條件是否滿足」= milestone_met。條件即 target_rung 內既有 gate（ACCUMULATE:food_flow≥0.5 / EXPAND:pop≥8 / STATE:faction≥2 / HEGEMON:faction≥4）。
- **rung 升**：`milestone_met(rung+1)` 為真 → rung+1（reckless=野心>0.65+慎重<0.4 直跳 target,保留既有）。承諾式:達成才升。
- **rung 降**：**trend 停滯 K 次才降**（非瞬時）。trend = milestone 指標的 EWMA 斜率。
  - milestone 進度指標 = 當前目標階對應的主指標:RUNG_ACCUMULATE→`food_flow_avg`;RUNG_EXPAND→`float(population)`;RUNG_STATE/HEGEMON→`float(faction teams)`。
  - `trend = ewma_now − ewma_last`（每 cadence 更新）。`trend ≤ 0` 連續 `RUNG_STALL_K` 次 → rung−1（一步退）+ 重置 stall_count。`trend > 0` → stall_count=0（有進度撐住）。
- **常數**（ambition_ladder.gd 頂）：
  ```gdscript
  const RUNG_TREND_ALPHA: float = 0.3    # TEST VALUE — EWMA 平滑係數
  const RUNG_STALL_K: int = 3            # TEST VALUE — trend≤0 連續幾 cadence 判停滯降 rung
  ```

- [ ] **Step 1: 寫失敗測試**（team_data 欄先加否則 parse fail——先加欄再測）

先在 `team_data.gd` food_flow 欄後加：
```gdscript
var rung_trend_ewma: float = 0.0       # 計畫層：milestone 進度指標 EWMA
var rung_trend_ewma_last: float = 0.0   # 上次 EWMA（算 trend 斜率）
var rung_stall_count: int = 0           # trend≤0 連續次數（達 K 降 rung）
```
`headless_test.gd` 加測（手構最小 state + team，驗事件驅動語意）：
```gdscript
func _test_plan_rung_event_driven() -> void:
    print("--- 計畫層 T1: rung 事件驅動（milestone 升 / trend 停滯降）---")
    var state := _mk_min_state()
    var team := _mk_team(state, 10, {"野心": 0.5, "慎重": 0.5})  # 非 reckless
    team.ambition_cap = AmbitionLadder.RUNG_HEGEMON
    team.ambition_rung = AmbitionLadder.RUNG_SURVIVE
    # milestone: food_flow≥0.5 → 升 ACCUMULATE
    team.food_flow_avg = 1.0
    AmbitionLadder.update(state, team)
    assert(team.ambition_rung == AmbitionLadder.RUNG_ACCUMULATE, "milestone 達成→升 ACCUMULATE")
    # trend 停滯 K 次 → 降。food_flow 保持不漲（trend=0）
    team.food_flow_avg = 1.0
    for _i in range(AmbitionLadder.RUNG_STALL_K + 1):
        AmbitionLadder.update(state, team)
    assert(team.ambition_rung == AmbitionLadder.RUNG_SURVIVE, "trend 停滯 K 次→降回 SURVIVE (got %d)" % team.ambition_rung)
    print("[OK] _test_plan_rung_event_driven")
```
（`_mk_min_state`/`_mk_team` 用既有 test helper;無則比照 `consolidation_decision_trace.gd` 的 `_mk_leader` 構造。）

- [ ] **Step 2: 跑測試驗證失敗**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: FAIL（`_test_plan_rung_event_driven` 斷言不過——舊 update 是瞬時重算,trend/milestone 語意未實作）。

- [ ] **Step 3: 重寫 `AmbitionLadder.update()` 為事件驅動**

`ambition_ladder.gd` 頂加常數（上方 §設計）。加 helper + 重寫 update：
```gdscript
# milestone：當前 rung+1 的達成條件是否滿足（複用 target_rung 階梯 gate）
static func milestone_met(state: WorldState, team: TeamData, next_rung: int) -> bool:
    var pop: int = team.population
    match next_rung:
        RUNG_ACCUMULATE: return team.food_flow_avg >= ACCUMULATE_FLOW_MIN
        RUNG_EXPAND:     return team.food_flow_avg >= ACCUMULATE_FLOW_MIN and pop >= EXPAND_MIN_POP
        RUNG_STATE, RUNG_HEGEMON:
            if team.faction_id == -1 or not state.factions.has(team.faction_id): return false
            var ft: int = state.factions[team.faction_id].member_team_ids.size()
            return ft >= (STATE_MIN_FACTION_TEAMS if next_rung == RUNG_STATE else HEGEMON_MIN_FACTION_TEAMS)
    return false

# 當前目標階的進度指標（算 trend）
static func _progress_metric(state: WorldState, team: TeamData) -> float:
    match team.ambition_rung:
        RUNG_SURVIVE, RUNG_ACCUMULATE: return team.food_flow_avg
        RUNG_EXPAND: return float(team.population)
        _:
            if team.faction_id != -1 and state.factions.has(team.faction_id):
                return float(state.factions[team.faction_id].member_team_ids.size())
            return float(team.population)

static func update(state: WorldState, team: TeamData) -> void:
    var leader: PersonData = state.persons.get(team.leader_id)
    team.ambition_archetype = derive_archetype(leader)
    team.ambition_cap = derive_cap(leader)
    var old: int = team.ambition_rung
    # trend EWMA 更新（進度指標斜率）
    var metric: float = _progress_metric(state, team)
    team.rung_trend_ewma_last = team.rung_trend_ewma
    team.rung_trend_ewma = (1.0 - RUNG_TREND_ALPHA) * team.rung_trend_ewma + RUNG_TREND_ALPHA * metric
    var trend: float = team.rung_trend_ewma - team.rung_trend_ewma_last
    # 升：milestone 達成（capped by ambition_cap）
    var next_rung: int = old + 1
    if next_rung <= team.ambition_cap and milestone_met(state, team, next_rung):
        var amb: float = float(leader.values.get("野心", 0.5)) if leader else 0.5
        var prud: float = float(leader.values.get("慎重", 0.5)) if leader else 0.5
        var reckless: bool = amb > 0.65 and prud < 0.4
        # reckless 直跳到最高連續達成的 rung
        if reckless:
            var t: int = next_rung
            while t + 1 <= team.ambition_cap and milestone_met(state, team, t + 1):
                t += 1
            team.ambition_rung = t
        else:
            team.ambition_rung = next_rung
        team.rung_stall_count = 0
        Probe.bump("g2.ambition_promote")
    # 降：trend 停滯 K 次（遲滯，非瞬時）
    elif old > RUNG_SURVIVE:
        if trend <= 0.0:
            team.rung_stall_count += 1
            if team.rung_stall_count >= RUNG_STALL_K:
                team.ambition_rung = old - 1
                team.rung_stall_count = 0
                Probe.bump("g2.ambition_demote")
        else:
            team.rung_stall_count = 0
    team.ambition_eval_next_tick = state.world.current_tick + LADDER_EVAL_CADENCE
    if team.ambition_rung != old:
        print("[Ambition] Team%d rung %d→%d (%s cap=%d)" % [
            team.team_id, old, team.ambition_rung, team.ambition_archetype, team.ambition_cap])
```
（保留 `target_rung()` 函式不刪——其他既有 caller 可能讀,且 milestone_met 複用其語意;但 update 不再呼它。grep 確認 target_rung 其他 caller 若有則保持相容。）

- [ ] **Step 4: 跑測試驗證通過 + 迴歸**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `[OK] _test_plan_rung_event_driven` + 既有 rung 測（`_test_r2_*`/rung_dissolution）不回歸。若既有測依賴瞬時 rung 行為斷言 → 標「行為改動非 regression」報 systems。

- [ ] **Step 5: determinism + 探針**

加探針 `warring_harness.gd`：`g2.rung_promote`/`g2.rung_demote` 已有;加 `plan.rung_stall_events`（stall 觸發降計數）+ per-rung 分布快照（rung 0-4 各幾隊）。
Run determinism：`WARRING_SEEDS=1337 WARRING_MONTHS=1` 兩跑 byte-identical。

- [ ] **Step 6: Commit**

```bash
git add scripts/data/team_data.gd scripts/simulation/ambition_ladder.gd scripts/debug/headless_test.gd scripts/debug/warring_harness.gd
git commit -m "feat(plan-layer S1): rung 事件驅動化—milestone升/trend停滯K降,棄瞬時target_rung重算(穩定化)"
```

**驗收（handback to:measurer）**：rung 抖動顯著降（vs baseline 瞬時版,同 seed rung 變更次數）+ determinism byte-identical + 階分布（不再全卡瞬時抖動）+ 融合閘綠。

---

## Task 2: phase 導出 + 偏置 term（讀 rung，不碰 rung）

從（缺口×個性×隊形/archetype）導出 `team.plan_phase`,在 `rank_scored` 加 `plan_phase_drive` 偏置 term——當前 phase 偏置相關 option。**讀 slice 1 的 rung,不改 rung**。

**Files:**
- Modify: `scripts/data/team_data.gd`（加 `plan_phase` 欄）
- Modify: `scripts/simulation/decision/decision_context.gd:248-254`（archetype/rung 區塊後加 phase 導出 → ctx.plan_phase + ctx.plan_phase_drive_map）
- Modify: `scripts/simulation/decision/terms.gd:172-175`（train_drive 後加 `plan_phase_drive` term）
- Modify: `scripts/simulation/decision/decision_engine.gd`（rank_scored weight 表加 `plan_phase_drive` 權重，比照 train_drive）
- Test: `headless_test.gd`（`_test_plan_phase_derive` + `_test_plan_phase_bias`）

**Interfaces:**
- Consumes（slice 1）：`team.ambition_rung`、`team.ambition_archetype`、`team.ambition_cap`。既有 ctx：`c.food_days`/`c.rung`/`c.archetype`。
- Produces（slice 4 依賴）：`team.plan_phase: String` ∈ `{"", "求糧", "成長", "聚勢", "立國"}`（`PHASE_*` const）。`DecisionContext.derive_plan_phase(state, team) -> String`。

### 設計（HOW）
- **phase enum**（decision_context 或新小 const 檔）：
  ```gdscript
  const PHASE_NONE := ""
  const PHASE_SEEK_FOOD := "求糧"   # 缺糧
  const PHASE_GROW := "成長"        # 缺人
  const PHASE_GATHER := "聚勢"      # 缺勢（結盟/整併/立國前置）
  const PHASE_ESTABLISH := "立國"   # 立國傾向
  ```
- **導出 = 缺口 × 個性 × 隊形**（機械+人格，複用 values，零新 scorer）：
  1. **缺口偵測**（機械，比對目標階 milestone 缺哪項）：
     - `food_flow_avg < ACCUMULATE_FLOW_MIN` → 缺糧候選。
     - `pop < EXPAND_MIN_POP` 且不缺糧 → 缺人候選。
     - rung≥EXPAND 且 faction teams < STATE_MIN → 缺勢候選。
     - rung≥EXPAND 且 pop 足 且 faction 足 milestone → 立國候選。
  2. **個性選哪個**（多缺口時序，用 values）：慎重高→先求糧穩;野心高→先成長/聚勢賭;貪婪高→求糧但走囤積（archetype TRADE）。實作:多候選時按 `disposition_scores` 傾向 + rung 缺口優先序（低階缺口先:糧>人>勢>立國）。
  3. **隊形/archetype 修飾承諾範圍**：SETTLE 有據點→可走到立國;TRADE→可能封頂在求糧/囤積;FORCE→成長→聚勢→稱霸;子隊(parent≠-1)→NONE（服母團無獨立計畫）。
- **承諾（防亂跳）**：phase 只在 milestone 達成（進下一）或 rung 變（slice 1 事件）時換——**複用 slice 1 的 rung 事件當 phase 轉移觸發**（rung 升→phase 進;rung 降→phase 退）。cadence 內沿用 `team.plan_phase`（hysteresis）。**不新增獨立承諾狀態機**——phase 轉移綁 rung 事件 = 天然承諾。
- **偏置 term**（rank_scored，過冗餘 lens）：
  - `plan_phase_drive` = 當前 phase 對齊的 option 加成。map:求糧→{覓食,買糧,貿易};成長→{返家補給,紮營,繁育相關};聚勢→{外交,整併,投靠};立國→（無直接 option,靠 rung/milestone 達成觸發既有立國 gate）。
  - **冗餘 lens 判別**：`intent_fit` 是「意圖→子需求→option」（致富/征服短期意圖染色）;`ambient_train_drive` 是 FORCE 練兵 base。`plan_phase_drive` 是「中長期 phase→承諾式偏置」——**語意不同層**（phase=跨 cadence 攀爬階段,intent=當下意圖）。非冗餘。但**magnitude 低**（TEST VALUE 0.4，讓位 survival/緊急,同 ambient_train 0.5 量級）避免碾壓短期反應。
  - 常數 `const PLAN_PHASE_DRIVE_MAG: float = 0.4  # TEST VALUE`。

- [ ] **Step 1: 寫失敗測試**（先加 team_data `plan_phase` 欄 + PHASE const）

`team_data.gd` 加 `var plan_phase: String = ""`。`decision_context.gd` 頂加 PHASE_* const。
`headless_test.gd`：
```gdscript
func _test_plan_phase_derive() -> void:
    print("--- 計畫層 T2: phase 導出（缺口×個性×隊形）---")
    var state := _mk_min_state()
    # 缺糧隊 → 求糧
    var t1 := _mk_team(state, 10, {"野心": 0.5, "慎重": 0.6})
    t1.food_flow_avg = -1.0  # 缺糧
    assert(DecisionContext.derive_plan_phase(state, t1) == DecisionContext.PHASE_SEEK_FOOD, "缺糧→求糧")
    # 糧足人少 → 成長
    var t2 := _mk_team(state, 4, {"野心": 0.7})
    t2.food_flow_avg = 2.0
    t2.ambition_rung = AmbitionLadder.RUNG_ACCUMULATE
    assert(DecisionContext.derive_plan_phase(state, t2) == DecisionContext.PHASE_GROW, "糧足人少→成長")
    # 子隊 → NONE
    var t3 := _mk_team(state, 10, {})
    t3.parent_team_id = t1.team_id
    assert(DecisionContext.derive_plan_phase(state, t3) == DecisionContext.PHASE_NONE, "子隊→無計畫")
    print("[OK] _test_plan_phase_derive")

func _test_plan_phase_bias() -> void:
    print("--- 計畫層 T2: phase 偏置 term ---")
    var state := _mk_min_state()
    var team := _mk_team(state, 10, {})
    team.plan_phase = DecisionContext.PHASE_SEEK_FOOD
    var ctx := DecisionContext.gather(state, team)
    # 求糧 phase → 覓食 option 有 plan_phase_drive 加成
    assert(ctx.plan_phase_drive_map.get("覓食", 0.0) > 0.0, "求糧 phase 偏置覓食")
    assert(ctx.plan_phase_drive_map.get("攻擊", 0.0) == 0.0, "求糧 phase 不偏置攻擊")
    print("[OK] _test_plan_phase_bias")
```

- [ ] **Step 2: 跑測試驗證失敗**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: FAIL（`derive_plan_phase`/`plan_phase_drive_map` 未定義）。

- [ ] **Step 3: 實作 phase 導出 + ctx 偏置 map**

`decision_context.gd` 加 `derive_plan_phase` + 在 gather 的 :248-254 archetype 區塊後填 `c.plan_phase` + `c.plan_phase_drive_map`：
```gdscript
static func derive_plan_phase(state: WorldState, team: TeamData) -> String:
    if team.parent_team_id != -1: return PHASE_NONE   # 子隊服母團
    # 缺口偵測（低階缺口優先）
    if team.food_flow_avg < AmbitionLadder.ACCUMULATE_FLOW_MIN:
        return PHASE_SEEK_FOOD
    if team.population < AmbitionLadder.EXPAND_MIN_POP:
        return PHASE_GROW
    # 糧足人足：看勢（faction 規模）
    var ft: int = 0
    if team.faction_id != -1 and state.factions.has(team.faction_id):
        ft = state.factions[team.faction_id].member_team_ids.size()
    if ft < AmbitionLadder.STATE_MIN_FACTION_TEAMS:
        return PHASE_GATHER   # 缺勢→聚勢（結盟/整併/立國前置）
    return PHASE_ESTABLISH
```
gather 內：
```gdscript
c.plan_phase = derive_plan_phase(state, team)
c.plan_phase_drive_map = _phase_option_bias(c.plan_phase)   # {option: mag}
```
`_phase_option_bias(phase)` static：
```gdscript
const PLAN_PHASE_DRIVE_MAG: float = 0.4   # TEST VALUE
static func _phase_option_bias(phase: String) -> Dictionary:
    match phase:
        PHASE_SEEK_FOOD: return {"覓食": PLAN_PHASE_DRIVE_MAG, "買糧": PLAN_PHASE_DRIVE_MAG, "貿易": PLAN_PHASE_DRIVE_MAG}
        PHASE_GROW:      return {"返家補給": PLAN_PHASE_DRIVE_MAG, "紮營": PLAN_PHASE_DRIVE_MAG}
        PHASE_GATHER:    return {"外交": PLAN_PHASE_DRIVE_MAG, "併入": PLAN_PHASE_DRIVE_MAG}
    return {}
```
（★option 實名對齊 `DecisionOptions.SURVIVAL_OPTION_SET`（options.gd:49）——**「投靠」「整併」已被 S-A consolidation 統一成單一「併入」(join+整併合一)**,勿用舊名（rank_scored 靜默對不上）。求糧/成長 option 名亦 grep 確認實名。）

> **★watch-item（reviewer R² 標，measurer 觀察）**：`intent_fit`「致富」貿易偏置（food_days 充裕觸發）vs `plan_phase_drive`「求糧」貿易偏置（food_flow_avg 赤字觸發）——兩條件通常反相關但非嚴格互斥,窄邊緣 case 可能對「貿易」option 雙重疊加。MAG 0.4 已刻意壓低,風險可控。measurer S2 驗收順帶觀察「貿易」option util 量級有無異常疊加。

- [ ] **Step 4: 加 `plan_phase_drive` term 到 rank_scored**

`terms.gd` train_drive 後：
```gdscript
"plan_phase_drive":
    # 計畫層（中長期 phase→承諾偏置;語意≠intent_fit 短期意圖、≠ambient_train 練兵 base）。
    return float(ctx.plan_phase_drive_map.get(opt, 0.0))
```
`decision_engine.gd` weight 表加 `"plan_phase_drive": 1.0`（additive，人格/phase 已 baked in map，比照 intent_fit/train_drive weight=1.0）。DecisionContext 加欄 `var plan_phase_drive_map: Dictionary = {}`。

- [ ] **Step 5: 跑測試 + 冗餘 lens 自查 + 迴歸**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `[OK] _test_plan_phase_derive` + `[OK] _test_plan_phase_bias` + 既有決策測不回歸。
冗餘自查:grep `plan_phase_drive` 貢獻 vs `intent_fit`/`ambient_train_drive` 同 option 疊加——確認語意分層非雙算（求糧偏置覓食 vs intent_fit 致富偏置貿易,不同觸發源）。

- [ ] **Step 6: phase 轉移綁 rung 事件（承諾）**

phase 每 gather 導出（讀當前 rung/state）——因 rung 已 slice 1 事件穩定,phase 自然跟 rung 穩（rung 不抖→phase 不抖）。**確認 phase 不需獨立承諾狀態機**（rung 事件=phase 轉移觸發）。加測:rung 穩定期 phase 不亂跳。

- [ ] **Step 7: Commit**

```bash
git add scripts/data/team_data.gd scripts/simulation/decision/decision_context.gd scripts/simulation/decision/terms.gd scripts/simulation/decision/decision_engine.gd scripts/debug/headless_test.gd
git commit -m "feat(plan-layer S2): phase導出(缺口×個性×隊形)+plan_phase_drive偏置term(讀rung不碰rung,承諾綁rung事件)"
```

**驗收（to:measurer）**：phase 分布（不同個性/隊形出≥2 種明顯不同 phase 序列——誠實用「≥2 種模式」非「全不同」）+ 偏置生效（求糧隊真偏覓食/貿易）+ determinism + 冗餘 lens 綠 + 融合閘。

---

## Task 3: survival-bypass（劇變立即接管 rung，掛 slice 1）

遲滯設計的風險:rung 該降沒降的窗口內行為停舊高 rung 但實質活不下去。加**劇變幅度立即重算 rung**（無視 milestone 遲滯）。掛 slice 1 的 update()。**與既有 survival task-override 不同層**（那是行動層插隊覓食;這是目標階層立即下修）。

**Files:**
- Modify: `scripts/simulation/ambition_ladder.gd`（update() 開頭加 bypass 檢查）
- Modify: `scripts/data/team_data.gd`（加 `rung_pop_last: int` 記上期 pop 算驟降）
- Test: `headless_test.gd`（`_test_plan_rung_bypass`）

**Interfaces:**
- Consumes（slice 1）：`AmbitionLadder.update()`、`milestone_met`、rung 欄。
- Produces：無下游（GUI 不依賴）。bypass 後 rung 立即反映承載力,phase（slice 2 每 gather 導出）自動跟。

### 設計（HOW）
- **劇變觸發**（任一單 cadence，比照 §韌性「局勢劇變」）：
  - pop 單期驟降 > `RUNG_CRASH_POP_DROP_PCT`（30%）。
  - leader 陣亡（`team.leader_id == -1` 或此 cadence 換過——用 pop 驟降 proxy + leader null 檢）。
  - food_flow 深負 < `RUNG_CRASH_FOOD_DEEP`（−2.0/day）。
- **接管**：觸發 → **無視遲滯,rung 立即重算為當前實際承載力對應值**（= 從 SURVIVE 起,連續 milestone_met 爬到的最高 rung，capped）→ 直接 set，不走 stall_count。
- **與 survival task-override 釐清**：此 bypass 只改 `ambition_rung`（目標階基準）;不碰 `_evaluate_survival`（行動層）。兩者獨立觸發條件（避免 :39 誤判等價重演）。
- 常數：
  ```gdscript
  const RUNG_CRASH_POP_DROP_PCT: float = 0.30   # TEST VALUE
  const RUNG_CRASH_FOOD_DEEP: float = -2.0      # TEST VALUE
  ```

- [ ] **Step 1: 寫失敗測試**

`team_data.gd` 加 `var rung_pop_last: int = 0`。`headless_test.gd`：
```gdscript
func _test_plan_rung_bypass() -> void:
    print("--- 計畫層 T3: survival-bypass（劇變立即降 rung）---")
    var state := _mk_min_state()
    var team := _mk_team(state, 20, {"野心": 0.9, "慎重": 0.5})
    team.ambition_cap = AmbitionLadder.RUNG_HEGEMON
    team.food_flow_avg = 2.0
    team.rung_pop_last = 20
    team.ambition_rung = AmbitionLadder.RUNG_EXPAND
    # pop 驟降 50% (20→10) + food 深負 → 劇變 bypass 立即降（不等 stall K）
    team.set_population_for_test(10)   # 或直接構造 anon 使 population getter=10
    team.food_flow_avg = -3.0
    AmbitionLadder.update(state, team)
    assert(team.ambition_rung <= AmbitionLadder.RUNG_SURVIVE + 1, "劇變 bypass 立即降 rung 到承載力 (got %d)" % team.ambition_rung)
    assert(team.rung_stall_count == 0, "bypass 不經 stall_count")
    print("[OK] _test_plan_rung_bypass")
```
（pop 構造用既有 test 手法;population 是 getter → 構造 anon_cohorts 或用 test setter。）

- [ ] **Step 2: 跑測試驗證失敗**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: FAIL（bypass 未實作,劇變下 rung 仍走遲滯不立即降）。

- [ ] **Step 3: 實作 bypass（update 開頭）**

`ambition_ladder.gd` update() 開頭（trend 更新前）加：
```gdscript
# survival-bypass：劇變幅度 → 無視遲滯立即重算 rung 為當前承載力
var pop_now: int = team.population
var pop_drop: bool = team.rung_pop_last > 0 \
    and float(team.rung_pop_last - pop_now) / float(team.rung_pop_last) > RUNG_CRASH_POP_DROP_PCT
var food_crash: bool = team.food_flow_avg < RUNG_CRASH_FOOD_DEEP
var leader_lost: bool = leader == null
if pop_drop or food_crash or leader_lost:
    var carry: int = RUNG_SURVIVE
    var n: int = RUNG_ACCUMULATE
    while n <= team.ambition_cap and milestone_met(state, team, n):
        carry = n; n += 1
    if carry < team.ambition_rung:
        team.ambition_rung = carry
        team.rung_stall_count = 0
        Probe.bump("g2.ambition_crash_bypass")
    team.rung_pop_last = pop_now
    team.ambition_eval_next_tick = state.world.current_tick + LADDER_EVAL_CADENCE
    return   # 劇變當 cadence 只做 bypass,不再走正常升降
team.rung_pop_last = pop_now
```
（放 leader 取得後、trend 更新前。`leader` 變數已在 update 開頭取。）

- [ ] **Step 4: 跑測試驗證通過 + 迴歸**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `[OK] _test_plan_rung_bypass` + slice 1 測（`_test_plan_rung_event_driven`）仍過 + 既有不回歸。

- [ ] **Step 5: determinism + 探針**

`g2.ambition_crash_bypass` 探針。determinism 1seed×1mo byte-identical。

- [ ] **Step 6: Commit**

```bash
git add scripts/simulation/ambition_ladder.gd scripts/data/team_data.gd scripts/debug/headless_test.gd
git commit -m "feat(plan-layer S3): survival-bypass—劇變(pop驟降/food深負/leader失)立即重算rung為承載力,無視遲滯(目標階層≠行動層survival override)"
```

**驗收（to:measurer）**：劇變隊 rung 立即反映（不卡舊高階持續失敗）+ 崩潰矩陣:加 bypass 後死磕原地減少（re-plan 遷移/投靠苗頭）+ determinism + 融合閘。

---

## Task 4: GUI 可讀性（顯示 plan_phase，純顯示層）

Observer GUI 露 `plan_phase` 欄——看得見各隊攀爬軌跡。純顯示,零 sim 邏輯。

**Files:**
- Modify: `scripts/simulation/observer_query_api.gd`（team stats 加 plan_phase + rung）
- Modify: Observer GUI 面板（隊詳情顯示「階N phase」）——沿用既有 observer inspect slice 結構
- Test: `scripts/debug/observer_inspect_test.gd`（query 含 plan_phase）

**Interfaces:**
- Consumes（slice 1/2）：`team.ambition_rung`、`team.plan_phase`。
- Produces：GUI 顯示,無下游。

- [ ] **Step 1: 寫失敗測試**

`observer_inspect_test.gd`：
```gdscript
func _test_query_includes_plan_phase() -> void:
    var state := _mk_min_state()
    var team := _mk_team(state, 10, {})
    team.plan_phase = "求糧"
    team.ambition_rung = 1
    var q := ObserverQueryApi.team_stats(state, team.team_id)
    assert(q.has("plan_phase") and q["plan_phase"] == "求糧", "query 含 plan_phase")
    assert(q.has("ambition_rung"), "query 含 rung")
    print("[OK] _test_query_includes_plan_phase")
```

- [ ] **Step 2: 跑測試驗證失敗**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/observer_inspect_test.gd`
Expected: FAIL（team_stats 無 plan_phase key）。

- [ ] **Step 3: query 加 plan_phase + rung**

`observer_query_api.gd` team_stats 回傳 dict 加：
```gdscript
"plan_phase": t.plan_phase,
"ambition_rung": t.ambition_rung,
"ambition_archetype": t.ambition_archetype,
```

- [ ] **Step 4: GUI 面板顯示**

Observer 隊詳情面板加一行（沿用既有 inspect panel 結構,如 `observer_inspect_panel.gd`）：`"計畫: 階%d %s (%s)" % [rung, plan_phase, archetype]`。純顯示,對齊既有欄位渲染 pattern。

- [ ] **Step 5: 跑測試 + 手驗**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/observer_inspect_test.gd`
Expected: `[OK] _test_query_includes_plan_phase`。
截圖 harness（`ObserverMain --obs-*`）手驗面板顯示 plan_phase（fidelity 驗收義務,見 reference_screenshot_harness）。

- [ ] **Step 6: Commit**

```bash
git add scripts/simulation/observer_query_api.gd scripts/ui/ scripts/debug/observer_inspect_test.gd
git commit -m "feat(plan-layer S4): Observer GUI露plan_phase+rung欄—攀爬軌跡可讀(純顯示層)"
```

**驗收（to:measurer + 用戶手驗）**：GUI 跑幾 seed 顯不同攀爬軌跡（≥2 種模式）+ query 32/32 + 截圖 fidelity + 純觀測零 sim 動。

---

## 整體驗收（全 4 slice 後，to:blueprint）
- **計畫湧現可見**：GUI 不同個性/隊形 ≥2 種明顯攀爬軌跡（非全卡低階抖動）。誠實:野心分布窄→可能高度同質,標「人格分布限制」非系統失敗。
- **主動攀爬**：`established > 0`（隊爬到立國）+ 階分布上移（非全階0/1）。
- **韌性**：劇變隊 re-plan（bypass→遷移/投靠/降目標）非死磕餓死。
- **崩潰**：default.json 深度窗——加計畫層後世界撐/建國（對照 default-collapse 系列 baseline 位移）。
- **統一框架**（無 bespoke planner，plan_phase=偏置 term）、determinism、framework/coin/憲法閘綠、headless 零新增 FAIL。

## Self-Review 註記
- **spec 覆蓋**：四層模型（rung/milestone/phase/承諾偏置）→ S1(rung事件+milestone)/S2(phase+偏置+承諾綁rung)/S3(survival-bypass)/S4(GUI)。韌性(逃生閥/劇變重規劃)→S3+S2 導出式重導。誠實化(同質風險)→驗收「≥2種模式」。
- **TEST VALUE 留白全填**：RUNG_TREND_ALPHA=0.3/RUNG_STALL_K=3/PLAN_PHASE_DRIVE_MAG=0.4/RUNG_CRASH_POP_DROP_PCT=0.30/RUNG_CRASH_FOOD_DEEP=-2.0。
- **型別一致**：plan_phase:String(PHASE_* const)、rung:int、trend:float 跨 slice 一致。`milestone_met`/`derive_plan_phase` 簽名 slice 間對齊。
- **待實作者補**：`_mk_min_state`/`_mk_team` test helper（若 headless_test 無現成，比照 consolidation_decision_trace 構造）;option 實名（覓食/買糧/貿易/外交/整併/投靠）grep `DecisionOptions` 對齊;GUI panel 檔實名對齊既有 observer slice。
