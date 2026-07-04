# P2b-1 survival 選擇統一 — non-unified `_trigger_survival` 委派 engine option scoring（消雙 owner）

> 系統 HOW spec。承 P2a（unified 隊 survival options done）+ 統一框架 arc 框架完成塊③。
> P2 第三步。P2b 再切：**本 spec = P2b-1（中風險：消 survival 動作選擇雙 owner，保 entry 函數）**。
> **P2b-2（延，最高風險）**：全退 `_evaluate_survival`/`_trigger_survival` entry，non-unified survival 整路由 engine entry——耦合 P3/P4（軍隊非-survival 行為 attack/threat/vendetta 不在 engine）。本 spec 不做。

## measure-first（2yr world_sim，先量再開藥 [[feedback_avoid_rabbithole]]）

non-unified 舊 `_trigger_survival` marker（unified 隊 gate 2237 早退不印 → 全來自 non-unified）：
- **`[Survival]` = 1037**（survival 進入 task 變）= **熱路徑**，絕大多數 = **home-path return_home**（有家隊餓→回家吃）。
- homeless 絕境分流稀有：`[SurvivalLoot]`=11、`[SurvivalCamp]`=2、`[SurvivalForage]`=2、`[BeastHunt]`=1、`[SurvivalJoin]`=0（RNG）。

→ 退役碰熱路徑（return_home），回歸面大；但分流公式（`_loot_pref`/`_join_pref`/`_camp_pref`）與 engine term weight（`loot`/`join`/`camp`，P2a 已對齊）**重複** = 真雙 owner。

## 雙 owner 真相

survival 動作選擇邏輯存兩處：
- **unified 隊**：`DecisionEngine` rank（term `restock_need`/`loot_drive`/`join_drive`/`camp_drive`/`beg_drive`/`survival_pressure` × 人格 weight）。
- **non-unified 隊**：`_trigger_survival` 手寫 `desperation × values` branch（`LOOT_GATE`/`JOIN_GATE`/`CAMP_GATE` + sort，`_loot_pref`/`_join_pref`/`_camp_pref`）。

兩處皆編碼「殘忍→掠奪、義氣→投靠、野心→紮營」。= 框架債「決策不統一」殘餘（[[project_framework_seams]]）。

## 範圍（中風險，緊守邊界）

**做**：non-unified `_trigger_survival` 的**動作選擇**改委派 engine survival-option rank（單一 owner = `DecisionTerms`/`DecisionOptions`）。手寫 `desperation×values` branch（含 home-path loot 分支 + homeless loot/join/camp + fallback forage/beg）刪，改：gather ctx → `DecisionEngine.rank_survival` → dispatch top 可派 option @ `PRIO_SURVIVAL`。

**保留**（不退役）：
- `_evaluate_survival` gate（**何時**進 survival：food<WARNING/URGENCY、recovery release、礦村豁免、camp-arrival[P2a hoist]）原樣。
- `_trigger_survival` 函數 entry（非 unified 薄 dispatch wrapper）+ `PRIO_SURVIVAL` 優先序（survival 仍 preempt，**非**降為 unified 的 PRIO_DISPATCH）。
- 殘餘 wrapper 邏輯：**hunt fallback**（`try_hunt_predator`，無 TASK 不能當 option）、**player-join guard**（投靠玩家→forced_event，同 P2a W2）、TASK_BUILD 農田不中斷（2375-2381）。

**非目標**（明文）：
- **不全退** `_evaluate_survival`/`_trigger_survival` entry（P2b-2）。
- **不刪** `~20 個 headless_test 直呼 `_trigger_survival`/`_evaluate_survival` 點**——委派後仍呼仍產 task；assertion 若因選擇機制變而對不上 → **調 assertion**（非刪測），預期少數需調。
- 不碰 unified 隊路徑（`_decide_unified`/P2a options 原樣）。
- 不碰 `_evaluate_solo` 的 survival（1058-1099 solo camp/join scoring）——另一處，本塊不碰（記 backlog，P2b-2 或獨立）。
- hunt 不 option 化（無 TASK，留 wrapper fallback）。
- 不新平衡值（weight/term 公式 P2a 已定，沿用）。

## 設計

### 1. `DecisionOptions`：survival-option 子集 + `返家補給` generalize
```gdscript
const SURVIVAL_OPTION_SET: Array = ["返家補給", "覓食", "掠奪", "投靠", "紮營", "乞食"]
```
- **`返家補給` applicable generalize**（關鍵：非商隊絕境也需 return-home，否則破 1037 熱路徑）：
```gdscript
"返家補給":
    if ctx.has_home_outpost and ( \
            (ctx.is_merchant and ctx.food_days < DecisionTerms.RESTOCK_DAYS) \
            or ctx.food_days < DecisionTerms.DESPERATION_DAYS):
        out.append(opt)
```
  - 商隊 proactive（food<RESTOCK 5）不變；**任何有家隊絕境（food<DESPERATION 3）→ return-home** 入榜。
  - 影響：unified produce 隊絕境也得 return-home option（先前無 = 更 believable，行為改善，記）。

### 2. `DecisionEngine`：`rank_survival`（survival 子集排序，不變 current_option）
```gdscript
static func rank_survival(state: WorldState, team: TeamData) -> Array:
    # 同 rank()，但 applicable 過濾到 SURVIVAL_OPTION_SET；不寫 team.current_option
    # （non-unified 隊 current_option 由 faction_ai 非-survival 行為管，survival dispatch 不奪）
    var ctx := DecisionContext.gather(state, team)
    var scored: Array = []
    var idx := 0
    for opt in DecisionOptions.applicable(ctx):
        if opt not in DecisionOptions.SURVIVAL_OPTION_SET: continue
        var u := 0.0
        for tw in DecisionOptions.terms_of(opt):
            u += DecisionTerms.weight(tw[1], ctx.leader_values) * DecisionTerms.eval(tw[0], ctx, opt)
        # 承諾慣性：對齊現行 task（非 current_option，non-unified 用 current_task）
        if DecisionOptions.to_task(state, team, opt).get("task") == team.current_task:
            u += COMMITMENT_BONUS
        scored.append({"u": u, "i": idx, "opt": opt}); idx += 1
    scored.sort_custom(func(a,b): return a["u"] > b["u"] if a["u"] != b["u"] else a["i"] < b["i"])
    var out: Array = []
    for e in scored: out.append(e["opt"])
    return out
```
> 承諾比對用 `team.current_task`（non-unified 無 current_option 語意）。to_task 在排序內呼一次判承諾——若效能疑慮，plan 可改記 current_task→option 反查；初版求正確。

### 3. `_trigger_survival`（non-unified wrapper）改寫
```gdscript
func _trigger_survival(state, team, severity):
    leader 檢查 / previous_task 記錄 / TASK_BUILD 農田不中斷（原樣保留）
    # === 委派 engine survival-option scoring（取代手寫 desperation×values branch）===
    for opt in DecisionEngine.rank_survival(state, team):
        var td := DecisionOptions.to_task(state, team, opt)
        var tgt: Vector2i = td["target"]
        if tgt == Vector2i(-1,-1) and td["task"] != TeamData.TASK_FLEE: continue   # 不可派試次佳
        # player-join guard（同 P2a W2）
        if opt == "投靠" and td.has("combat_target"):
            var pp := state.persons.get(state.player_id) if state.player_id != -1 else null
            if pp != null and int(td["combat_target"]) == pp.team_id:
                if _maybe_request_join_player(state, team): return
        if TaskArbiter.try_set(state, team, td["task"], tgt, TaskArbiter.PRIO_SURVIVAL, "survival"):
            if td.has("combat_target"): team.combat_target = int(td["combat_target"])
            (對應 print [Survival*]，可保留診斷)
            return
    # 全不可派 → hunt fallback（無 TASK option）→ release
    if try_hunt_predator(state, team): return
    TaskArbiter.release(team); team.previous_task = ""
```
- **刪**：`gate`/`options 陣列`/`sort_custom`/`LOOT_GATE`/`JOIN_GATE`/`CAMP_GATE` 用法、home-path 手寫 loot 分支（2391-2402）、homeless loot/join/camp match（2424-2451）、fallback forage/beg（2457-2468）——皆併入 rank_survival 子集。
- **forage viable-pop**：舊 `team.population <= FORAGE_VIABLE_POP` 才覓食 → 移入 `覓食` applicable（or 維持？見開放細節）。
- `LOOT_GATE`/`JOIN_GATE`/`CAMP_GATE` const 若無其他 reader → 刪（grep 驗）；`_loot_pref`/`_join_pref`/`_camp_pref` 若仍被 `_evaluate_solo` 用 → 保留（本塊不碰 solo）。

## 行為對齊 / 預期變化（believability）

- **熱路徑 return_home 保**：有家隊絕境 → `返家補給`（restock_need=1.5×(5−food)×survival_weight 1.0，food 2.5→3.75）量級支配 loot(殘忍 0.8)/join/camp → **回家吃**（1037 熱路徑保）。
- **homeless 分流公式不變**：loot/join/camp/beg 由同 weight（P2a=舊 pref 公式）決 → 殘忍→掠奪、義氣→投靠、野心→紮營、墊底→乞食、可覓→覓食。**單一 owner 後行為連續**。
- **預期行為變（可接受，記）**：舊 home-path「eta>5天 + 殘忍/好戰 → 改掠奪（不長途返家）」的**距離 nuance 丟失**（restock_need 非距離感知）→ 殘忍遠家隊現傾向返家而非就近掠。loot 稀有（11/2yr），影響小。若願景要保 → backlog「restock_need 距離衰減」（系統可後補，非本塊）。
- **urgent/warning severity 簡化**：舊 warning 用 `*_GATE` 個性門檻、urgent gate=0 解閘。委派後**統一靠 drive 量級**（食物越低 drive 越高，severity 自然由 food_days 表達）→ severity 參數對選擇不再有額外 gate 效果（entry gate 仍用 WARNING/URGENCY 判何時進）。= believable（餓越深越不挑），記行為簡化。

## 驗收

- **熱路徑保**：world_sim 2yr —— 有家隊絕境仍 return_home（`返家補給`/TASK_RETURN_HOME 為主），**無 mass starvation**（died 不暴增 vs P2a baseline）、存活隊數穩。
- **homeless 分流 emergent**：殘忍 non-unified 隊→掠奪、義氣→投靠、野心→紮營 可見（headless 人格分歧測，仿 P2a）。
- **單一 owner 證**：`_trigger_survival` 不再含 `LOOT_GATE`/sort branch（grep）；選擇全經 `rank_survival`→`DecisionTerms`/`DecisionOptions`。
- **~20 test 直呼點**：跑全套，因選擇機制變而對不上的 assertion 調至新單一 owner 結果（**非放寬語意**：人格→動作對映同義，僅機制換）；記哪些調了。
- **unified 不變**：P2a options/`_decide_unified` 路徑 + TC1/4/6/7 原樣。
- **守恆**：loot/join/camp/beg/return 走既有守恆；coin_eq 0、InvariantAudit 0。
- **framework S1-S6 PASS**、無 SCRIPT ERROR、headless 全綠。

## 檔案

- `scripts/simulation/decision/options.gd`：`SURVIVAL_OPTION_SET` const、`返家補給` applicable generalize。
- `scripts/simulation/decision/decision_engine.gd`：`rank_survival`。
- `scripts/simulation/faction_ai_system.gd`：`_trigger_survival` 改寫（刪手寫 branch→委派）；`LOOT_GATE`/`JOIN_GATE`/`CAMP_GATE` const 視 grep 刪；pref helper 視 solo 用否保留。**不碰** `_evaluate_survival` gate / `_evaluate_solo`。
- `scripts/debug/headless_test.gd`：調受影響 assertion（~20 直呼點）+ 新 homeless 分流人格測（仿 P2a）。

## 風險 + 緩解

- **熱路徑回歸（1037 return_home）**：`返家補給` generalize 必須涵蓋非商隊 → 漏則 mass starvation。驗收硬閘：world_sim died 不暴增 + 有家隊返家為主。先寫熱路徑測（有家絕境隊→TASK_RETURN_HOME）再改。
- **~20 test 直呼點連鎖 fail**：委派改選擇機制 → 部分 assert 對不上。緩解：逐一檢視，確認新結果與舊「人格→動作」同義才調 assertion（非盲放寬）。若某 case 新舊分歧揭真 believability 退化 → 停、呈報。
- **承諾比對 to_task 內呼效能**：rank_survival 每 survival tick 多呼 to_task 判承諾。survival 非每 tick（entry gated）→ 可接受；疑慮則改 current_task→option 反查表。
- **severity gate 語意丟失**：warning 個性門檻沒了 → 輕飢也可能 loot/camp？緩解：drive=食物量級，輕飢 drive 低 → 仍偏 return/forage；entry gate（WARNING）擋非飢隊。world_sim 量「輕飢亂掠奪」否。
- **scope sprawl**：明文不全退 entry、不碰 solo、hunt 不 option 化。只碰 decision/ 兩檔 + `_trigger_survival` 一函數改寫 + 測。

## 開放細節（plan 定）

- `覓食` applicable 是否加 `FORAGE_VIABLE_POP` 守衛（舊 homeless forage 限 pop≤15）→ 移入 applicable 或棄（unified 隊現 `覓食` 無此限；對齊則 unified 也加）。**plan 定**：傾向移入 applicable 保大軍不覓食（與舊一致）。
- 承諾比對實作（to_task 內呼 vs 反查表）。
- `LOOT_GATE`/`JOIN_GATE`/`CAMP_GATE`/pref helper 刪留（grep solo/其他 reader 定）。
- 診斷 print（`[SurvivalLoot]` 等）保留與否（保留利 world_sim 量測）。
