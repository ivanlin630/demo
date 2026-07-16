> **★★2026-07-09 SHIP 定案（藍圖 `blueprint-to-systems-A2c1-ship-pure-fold`）**：**A2c-1 = 純 FA5 fold @423924c**（整併折入引擎 option、移除 weigh 前 pre-gate bypass）**已放行 merge**。續議的 survival-value 升級（`2026-07-09-A2c1-survival-value.md`）**撤銷**——多 seed 證「fold=regression」為 seed-1337 幽靈（starve 方向不一致）、且 merge 已證 food-blind/survival-inert。**已知限制**：merge food-blind = survival-inert（`known_issues`），歸未來絕境經濟設計。phantom current_option（`known_issues`，faction_ai:1487）獨立待修不變。

# A2c-1 Spec — faction consolidate 整併 pre-gate 折入統一引擎（FA5）

- from: systems
- slice: A2c-1（A2c 首塊；re-slice 見下）
- 工單/裁示: `docs/superpowers/handbacks/2026-07-09-blueprint-to-systems-A2c-direction.md`（藍圖 WHAT；seam/切法系統定，用戶 2026-07-09 授權）
- 依賴: A2a（子隊納引擎 option-fold pattern）、A2b（leader 納引擎；本 spec 鏡射其「拆 pre-gate 不加補丁 + 保真校準」philosophy）、序6（成員 `_decide_unified` + consolidate scaffolding 抽出）
- 憲法連動:「行為=引擎輸出」;「決策=rank_scored 競秤,非 weigh 前 pre-empt」
- reverse-findings 定位: slice#6 **FA5**（MERGE consolidate 在 weigh 前 hard-set pre-empt，`faction_ai:1396-1443`）

---

## ★re-slice 說明（系統切法，讀 code 後定案）

藍圖 A2c 方向 = 折 faction 剩餘 off-engine 權威（FA5/FA6/FA7/FA8/FA10）。scoping note（`2026-07-09-A2c-scoping-note.md`）原擬 A2c-1=FA5+FA6 綁一塊。**讀 code 後 re-slice**（per-slice 單機制獨立可驗，鏡射 A2a/A2b 各折一權威）：

| slice | 折 | 技術 | 狀態 |
|---|---|---|---|
| **A2c-1（本 spec）** | **FA5 consolidate** | 引擎 option-fold（clean，同 A2a/A2b） | 本 spec |
| A2c-2 | FA6 strategic 包圍/breakout | movement-layer bypass 移除（`strategic_assignments`→move_target 繞 arbiter；非 task-option，另技術） | 待 A2c-1 落地 |
| A2c-3 | FA8 diplomatic 背叛/結盟/徵貢 | 平行 scorer→引擎 input（最大玩家面，equivalence 硬驗） | 待排 |
| 延後 | FA7 + FA10-leader god-view | 感知作弊，跨 arc3 霧（`strategic_ai:96`/`faction_ai:906`；FA10 team-path G3 已 belief-gated） | arc3 對齊 |

**re-slice = 系統自決切法範疇**（用戶「系統決定一次折幾條」已授權，非改願景）。FA5/FA6 綁一塊不當：FA6 是 movement-overlay（不改 task、只 nudge move_target），不 map 成 task-option，與 FA5 option-fold 是兩路技術。

---

## 願景約束（藍圖 owner；系統遵守）

- **純折入保湧現不重塑**：consolidate 折進引擎後，玩家看到的隊伍整併戲（小隊併大隊、戰前向 leader 集結）**A2c-1 後大致等價**。
- **utility 校準到現行門檻**：`SMALL_TEAM_RATIO=0.3`/`SMALL_VS_LARGE=0.33`/`CONSOLIDATE_MAX_DIST=3` 觸發條件不動；consolidate_drive 量級校準到「現行 fire 幾乎恆勝」以保真。
- **深化留 A2d**：「受威脅小隊該不該仍整併」（現行 pre-gate 除 survival-sticky 外恆 fire，含威脅下）= 語意問題，**A2c-1 不改**（保現行行為）。若日後要讓 threat/生存跟整併真競秤 = A2d 深化。
- **驗收硬線**：`seeded_warring_bed` before/after 逐點對照 **total_diffs=0**（零行為變證）。

---

## 問題（現況，grep 重驗 2026-07-09）

faction **成員** 走統一引擎（`_decide_unified`），**但整併(MERGE)是 weigh 前 pre-gate**——`_assign_member_tasks`（`faction_ai_system.gd:1386-1414`）每成員先呼 `_try_consolidate_merge`（1400-1403），命中則 `TaskArbiter.try_set(TASK_MERGE, PRIO_DISPATCH)` + `continue`（成員**不進 `rank_scored`**）：

```
1399  var _tm := ...
1400  if not (mt.current_task in SURVIVAL_TASKS and != IDLE):   # survival-sticky（唯一 gate）
1401      if _try_consolidate_merge(state, mt, f, leader_team):  # 命中 → pre-empt engine
1402          ...
1403          continue                                            # ★成員略過 _decide_unified
1404  ...
1411/1414  _decide_unified(state, mt)
```

`_try_consolidate_merge`（1419-1443）兩支（**保留其觸發條件**）：
1. **容量吸收**：`_find_absorber`（1568，近 1<d≤CONSOLIDATE_MAX_DIST 有餘容量 member）非空 **且** `small_b`（pop < cap×SMALL_TEAM_RATIO）**且** `small_c`（pop < absorber.pop×SMALL_VS_LARGE）→ merge 向 absorber。
2. **戰前集結**：`"攻擊" in f.goals` **且** `1 < dist_to_leader ≤ CONSOLIDATE_MAX_DIST` **且** leader 有餘容量 → merge 向 leader。

命中 set `TASK_MERGE` + `order_target_id`；TASK_MERGE 由 `interaction_system:261/461` 消費（merger 抵 target → 併解）。

**病（FA5）**：整併是 **weigh 前 pre-empt**（parallel 決策路徑），非引擎 option。註解自承「faction-level 機制，故不入引擎 option，走 scaffolding」——**A2c 消除此 pre-empt**：整併降為 rank_scored 競秤 option，結構上進統一 weigh（survival 自然壓過=同現行 survival-sticky），行為校準保真。

---

## ★裁定方向（藍圖 WHAT → 系統 HOW）

| 藍圖裁示 | A2c-1 落地 |
|---|---|
| 消除平行 scorer + hard-set pre-empt | **D1**：拆 `_assign_member_tasks` 的 consolidate pre-gate（1400-1403）；整併降 rank_scored option「整併」 |
| 保湧現 / utility 校準現門檻 | **D2**：`consolidate_drive` term 量級校準到「現行 fire 恆勝 mundane/threat option」；觸發條件（三常數）不動；warring-bed total_diffs=0 |
| 深化留 A2d | 「威脅下該不該整併」不碰（保現行恆 fire 除 survival-sticky） |

**核心 = 鏡射 A2a/A2b：把 consolidate「送進引擎」當競秤 option，拆 pre-gate，觸發/target 保真。**

---

## 設計決定（HOW，全框架 option/term/ctx/gate）

### D1. 新引擎 option「整併」（`decision/options.gd`）

**REGISTRY**：加 `"整併": ["consolidate_drive"]`。

**`applicable`**（match 分支，A2a 通用 `is_subteam` gate 於 match 前已擋子隊）：
```gdscript
"整併":
    # FA5 折入：faction 非-leader 成員 + 有整併 target（容量吸收 or 戰前向 leader 集結）→ 候選。
    # 觸發條件保真（consolidate_target_id 於 gather 依現行 _find_absorber/rally 兩支算）。
    if ctx.consolidate_target_id != -1: out.append(opt)
```

**`to_task`**（不收 ctx → 局部 gather 取 target，鏡射 `攻擊`:185 法避改 17-caller 簽名）：
```gdscript
"整併":
    # FA5：向 target(absorber/leader)行軍 merge；TASK_MERGE 由 interaction_system:261 消費（抵達→併解）。
    var _cc: DecisionContext = DecisionContext.gather(state, team)
    var ctid: int = _cc.consolidate_target_id
    if ctid == -1 or not state.teams.has(ctid):
        return {"task": TeamData.TASK_IDLE, "target": Vector2i(-1,-1)}
    return {"task": TeamData.TASK_MERGE, "target": state.teams[ctid].tile_pos, "order_target": ctid}
```
- **★`order_target` 已被既有 seam 消費（reviewer 反證修正 v2）**：`to_task` 回 `"order_target": ctid` → `_decide_unified:1535` 既有 `_wire_threat_task(team, td)`（`faction_ai:401-403` 泛用消費 `order_target`/`order_task`/`prosperity_target`，non-unified/unified 兩路共用 DRY）**已無條件設** `team.order_target_id = int(td["order_target"])`（同 td、combat/social_target 後、return 前）。TASK_MERGE 靠 `interaction_system:261` 的 `order_target_id == id_b` 解 → **零新增 dispatch-key，直接依賴 `_wire_threat_task`**。（`options.gd:228` 求和 option 亦已回 order_target 走同路，非本 spec 首引入。）

### D2. 新 term `consolidate_drive`（`decision/terms.gd`）

```gdscript
"consolidate_drive":
    # FA5 折入：faction 整併驅力（faction-level 機制，非個人 utility → flat 高量級，保真「現行恆 fire」）。
    # 校準：量級須 > mundane(生產/駐守/貿易 ≈0.3-0.6) + threat option(備戰/迎戰/求和 ≈0.5-0.9) → 現行
    #   pre-gate「除 survival-sticky 外恆 fire」保真。survival-sticky 由 TaskArbiter priority-gate 保
    #   （非 rank_scored 內競秤；見 D4）：獨立 _trigger_survival 設 PRIO_SURVIVAL(80) task → 整併走
    #   _decide_unified PRIO_DISPATCH(50) 寫不進 = 同現行。稀有性/威脅競秤=A2d 深化,A2c-1 不碰(保恆 fire)。
    if opt != "整併" or ctx.consolidate_target_id == -1: return 0.0
    return CONSOLIDATE_DRIVE   # TEST VALUE（初值 2.0；warring-bed total_diffs=0 校準）
```
- `const CONSOLIDATE_DRIVE: float = 2.0`（TEST VALUE；初值取「> FACTION_DUTY_DRIVE 1.5 且 > threat option 量級」使現行 fire 恆勝，校準至 total_diffs=0）。
- **weight**：`w_term("consolidate_drive")` = 1.0（faction 機制非人格染色；mirror intent_fit/faction_duty flat 處理）。查 `terms.gd` w_term 映射表補 `"consolidate_drive": 1.0`。

### D3. ctx 欄 `consolidate_target_id`（`decision/decision_context.gd`）

`DecisionContext` 加欄 `var consolidate_target_id: int = -1`。`gather` 內算（**鏡射現行 `_try_consolidate_merge` 兩支觸發，保真**）：
```gdscript
# FA5：整併 target（容量吸收優先，否則戰前向 leader 集結）。非-leader faction 成員 + 非子隊才算。
consolidate_target_id = -1
if team.faction_id != -1 and team.parent_team_id == -1:
    var _f = state.factions.get(team.faction_id)
    if _f != null and team.team_id != _f.leader_team_id:
        consolidate_target_id = FactionAISystem.consolidate_target_of(state, team, _f)
```
- 新 helper `FactionAISystem.consolidate_target_of(state, mt, f) -> int`：抽 `_try_consolidate_merge` 的 **target 決策**（非 dispatch），回 absorber_id（branch1 條件成立）／leader_team_id（branch2 條件成立）／-1。內部**沿用既有 instance-call 慣例**（`decision_context.gd:121/153`、`options.gd:150` 同法）複用 `_find_absorber`/`_hex_dist`，不新造 static 雙生：
```gdscript
static func consolidate_target_of(state, mt, f) -> int:
    var fai := FactionAISystem.new()
    var leader_team: TeamData = state.teams.get(f.leader_team_id)
    # branch1 容量吸收（逐條件鏡射 _try_consolidate_merge:1421-1427）
    var absorber_id: int = fai._find_absorber(state, mt, f)
    if absorber_id != -1:
        var mt_leader = state.persons.get(mt.leader_id)
        var mt_cmd: float = float(mt_leader.skills.get("統領", 0.0)) if mt_leader else 0.0
        var mt_cap: int = TeamData.pop_cap_from_leadership(mt_cmd)
        if mt.population < int(float(mt_cap) * SMALL_TEAM_RATIO) \
                and float(mt.population) < float(state.teams[absorber_id].population) * SMALL_VS_LARGE:
            return absorber_id
    # branch2 戰前集結（逐條件鏡射 1432-1442）
    if "攻擊" in f.goals and leader_team != null:
        var d: int = fai._hex_dist(mt.tile_pos, leader_team.tile_pos)
        if d > 1 and d <= CONSOLIDATE_MAX_DIST:
            var ldr_leader = state.persons.get(leader_team.leader_id)
            var ldr_cmd: float = float(ldr_leader.skills.get("統領", 0.0)) if ldr_leader else 0.0
            var ldr_cap: int = TeamData.pop_cap_from_leadership(ldr_cmd) - leader_team.population
            if ldr_cap > 0: return f.leader_team_id
    return -1
```
- **行為需逐條件等價現行 `_try_consolidate_merge`**（QA #5 驗）。

### D4. 拆 pre-gate（`faction_ai_system.gd:_assign_member_tasks`）

```
func _assign_member_tasks(state, f):
    for mid in f.member_team_ids:
        if mid == f.leader_team_id: continue
        var mt = ...
        if mt.parent_team_id != -1: continue
        if mt.combat_target != -1: continue
        if not mt.player_commanded_task.is_empty(): continue
        # ★A2c-1：刪 consolidate pre-gate（1396-1404）——整併改走 _decide_unified「整併」option 競秤
        _decide_unified(state, mt)
```
- **刪除**：1396-1404 的 `_try_consolidate_merge` 呼叫 + `continue` + phase_timing 包裹。
- **保留 helper**：`_try_consolidate_merge`（1419-1443）若無他呼叫者 → 刪；target 邏輯已抽 `consolidate_target_of`。`_find_absorber`（1568）保留/提 static（供 `consolidate_target_of`）。grep 確認 `_try_consolidate_merge` 無他 caller 再刪。
- **survival-sticky 保真（機制：TaskArbiter priority-gate，非 rank_scored 內競秤）**：舊 guard（1400 `if not survival task`）→ 拆除後靠 arbiter 保：獨立 `_trigger_survival`（`rank_survival`，`faction_ai:3067-3099`）設 `PRIO_SURVIVAL(80)` task；整併經 `_decide_unified` 統一以 `PRIO_DISPATCH(50)` try_set，`TaskArbiter.try_set`（`task_arbiter.gd:30` `priority > team.task_priority` 才覆寫）**結構上寫不進** 已在 survival task 的隊 → 餓/危成員停在 survival 非整併，**與整併是否入 option 無關、同現行**。`_decide_unified:1453` survival-sticky pass 亦保。

### D5. 憲法閘 baseline（`scripts/debug/constitution_baseline.txt`）

- `_try_consolidate_merge` 的兩 `try_set`（1428/1439）**移除**（整併 try_set 現全經 `_decide_unified`→to_task 的引擎 dispatch，baseline 既有落點）。
- `_assign_member_tasks` 註記更新：consolidate pre-gate 拆除，成員全走引擎。
- 淨：**無新增引擎外 try_set 落點**（整併從 pre-gate try_set → 引擎 dispatch try_set）→ gate 綠（current ⊆ baseline）。若 constitution_gate 抓 `to_task 整併` 為新落點 → baseline 補此引擎 dispatch（合法，非 off-engine）。

---

## 觸及檔

| 檔 | 改點 | D |
|---|---|---|
| `scripts/simulation/decision/options.gd` | REGISTRY +`"整併":["consolidate_drive"]`；`applicable` +`"整併"` 分支（`ctx.consolidate_target_id != -1`）；`to_task` +`"整併"`（TASK_MERGE, target=target tile, order_target=ctid，局部 gather） | D1 |
| `scripts/simulation/decision/terms.gd` | `eval` +`"consolidate_drive"`；`const CONSOLIDATE_DRIVE=2.0`；w_term 映射 +`"consolidate_drive":1.0` | D2 |
| `scripts/simulation/decision/decision_context.gd` | +欄 `consolidate_target_id:int=-1`；`gather` 內算（非-leader 成員/非子隊 → `consolidate_target_of`） | D3 |
| `scripts/simulation/faction_ai_system.gd` | 拆 `_assign_member_tasks` consolidate pre-gate(1396-1404)；+`consolidate_target_of(state,mt,f)`（抽 target 兩支邏輯，內以 `FactionAISystem.new()._find_absorber(...)`/`._hex_dist(...)` instance-call 複用既有，不新造 static 雙生）；`_try_consolidate_merge` 無他 caller 則刪 | D1/D3/D4 |
| `scripts/debug/constitution_baseline.txt` | `_assign_member_tasks`/`_try_consolidate_merge` 註記更新（pre-gate→引擎 option） | D5 |

**不碰**：`_decide_unified` 決策邏輯（rank/survival-sticky 不改；唯 additive +`order_target` dispatch-key）、survival/threat/faction_duty/intent_fit term（零 patch）、`interaction_system` TASK_MERGE 消費端（target/order_target_id 語意不變）、觸發三常數（`SMALL_TEAM_RATIO`/`SMALL_VS_LARGE`/`CONSOLIDATE_MAX_DIST` 保）、leader 路（A2b）、子隊路（A2a）、solo、FA6/FA7/FA8（另 slice）。

---

## ★呈報藍圖（player-visible，spec 鎖前 sign-off）

藍圖 A2c 約束：「純內部路由等價你自決；任一折入若**實測改玩家體感/平衡意圖** → 鎖 spec 前回 blueprint sign-off」。

**A2c-1 = 純結構折入（pre-empt→競秤 option），觸發/target 保真、行為校準到 total_diffs=0**。預設**無 player-visible 變**（整併戲等價）。**一項需藍圖確認**：

1. **pre-empt→競秤語意**：整併從「weigh 前 hard-set（除 survival-sticky）」→「rank_scored 競秤（survival/threat 結構上可壓過）」。**A2c-1 保真**（consolidate_drive 校準到現行 fire 恆勝 threat option，行為不變）；但**結構上**整併不再 pre-empt。→ 若平衡意圖依賴「整併恆 pre-empt 威脅」= 藍圖確認；系統判合「消除 pre-empt」mandate + 保真（威脅下仍整併=校準保，A2d 才深化競秤）。→ **等價（total_diffs=0）則自決放行；若校準顯示 threat 下整併行為變 → 呈報。**

---

## 驗收法（QA/量測員跑；systems 不跑 godot）

1. **無 GDScript 錯誤**；`.\tools\godot.ps1 --headless --import` 綠。
2. **constitution_gate 綠**：current ⊆ baseline（整併 try_set 從 pre-gate → 引擎 dispatch，無新 off-engine 落點）。
3. **sanity**：`game_sim_multi` headless ≥1000 tick 無崩；`[Merge]…完全合併` print 仍出現（整併戲活）。
4. **★手聽腦 bed**（`hand_obeys_brain_bed.gd`）：整併成員現走 `unified` src（非 pre-gate）；`member` obey 率不降、背離不暴增；determinism 段 PASS。
5. **★★行為保真硬線（`seeded_warring_bed` before/after 逐點對照）**：`total_diffs=0`（整併觸發時機/target/併解結果零變）。**≠0 → consolidate_drive 校準未收斂 → FAIL（回 D2 調 CONSOLIDATE_DRIVE 至收斂；若無論如何 ≠0 表 threat 下整併行為變 → 呈報藍圖）**。
6. **★守衛（硬閘）：整併不塌成零**——長跑 seeded 仍見小隊併大隊 + 戰前向 leader 集結（`[Merge]` count > 0 且量級同 before）。整併=0 = FAIL（consolidate_drive 過低被 mundale 壓過=校準失敗）。
7. **★守衛（硬閘）：survival 仍壓過整併**——餓/危小隊（food<DESPERATION 或 survival task）選 survival 非整併（同現行 survival-sticky）；seeded 抽驗無「餓隊丟下求生去 merge-march」徵候。
8. **效能**：拆 pre-gate 後成員全走 `_decide_unified`（+1 option 評估/member/tick）→ per-tick wall-time 不顯著退化（before/after 同 seed ≤5%）。
9. **非退化**：leader/solo/子隊/成員其他 category 背離不暴增；`arbiter_latch` 維持低檔；seeded final 漂移 QA 判合理非退化。
10. **效果發生**（consolidate pre-gate 真消失 + 整併經引擎競秤 dispatch）非只「改了 code」。

---

## ★Future-work（立案，非 A2c-1 職責）

- **A2c-2 FA6**：strategic_ai 包圍/breakout `strategic_assignments`→movement:65 直寫 move_target 繞 arbiter；movement-layer bypass 移除（另技術，非 option-fold）。
- **A2c-3 FA8**：diplomatic 背叛/結盟/徵貢平行 scorer 折入引擎 input（最大玩家面，equivalence 硬驗）。
- **FA7 + FA10-leader god-view**：`_nearest_independent` 讀真 faction_id+pos；跨 arc3 感知霧，鏡射 team-path 既有 belief-swap。
- **A2d 深化**：整併/外交真參與統一 weigh（威脅下該不該整併=競秤語意），非只保真折入。
