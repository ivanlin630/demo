# 長程計畫 / means-end 決策系統 — HOW 架構 spec（systems 2026-07-24）

> **對應 WHAT 設計**：`docs/superpowers/specs/2026-07-24-long-range-planning-means-end-design.md`（scope B 四塊+5 前置+湧現順序+折現，願景本體 blueprint 確認不變）。
> **premise（R① 異質框外審 CONTRADICTION 更正後）**：**全建中等新子系統**，接既有 `rank_scored` 湧現本體（唯一真複用的薄薄一塊）。其餘四塊真新增（options.gd 是 ~25 靜態手寫 entry 非動態生成、NeedOracle chaining 硬 scope 只覆蓋資源型、無持久 goal state、委派非真 option、折現零 scaffolding）。
> **紀律**：whole-system-first（用戶原則②：整個建完當 whole 才 measure，別邊建邊 patch）；憲法（utility 餵 utility / 人格 WEIGH 不 GATE / 加 goal=加資料）；有界（淺/local applicable/無 plan-state）；決定性（resolver 禁耗 global RNG，同 [[feedback_observer_no_global_rng]]）。

---

## 1. 架構總覽（資料流）

```
每 tick，每隊 decide()：
  team.goal_state (持久遠慾望列表, 跨 tick)        ← 組件 A（新 state）
        │
        ▼
  GoalResolver.frontier_candidates(team, ctx)      ← 組件 C（新中間層）
    對每個 active goal：walk GoalRegistry 拆前置鏈       ← 組件 B（宣告式資料表）
      前置滿 → 該 goal 本身 = frontier candidate
      前置未滿 → 遞迴到「當下能做的」子目標 = frontier candidate
        資源型前置 → NeedOracle 泛化（組件 E）
        定位型前置 → 通用 tile-resolver「找滿足條件 C 最近可達 tile」
        人力/設施/子目標型 → 遞迴 registry
      每 frontier candidate 算 util = 預期回報 × 折現(延遲,人格)  ← 組件 F（新折現）
      candidate 有「自己做」+「派子隊做」兩變體            ← 組件 D（委派 peer option）
        │
        ▼
  rank 池 = static REGISTRY options ∪ goal frontier candidates   ← 組件 G（rank 泛化，唯一改既有）
    argmax（既有 rank_scored 湧現本體：util 降序 + 承諾 bonus + boost）
        │
        ▼
  winner.to_task → TaskArbiter dispatch（既有）
```

**核心**：goal → frontier candidate 合成，併入既有 `rank_scored` 池一起 argmax。順序**湧現**（只能挑當下 applicable 的 frontier，applicability 鏈自逼順序），零腳本序列、無 plan-state。

---

## 2. 組件 A：持久 goal state schema（TeamData 新結構化欄）

- **新欄** `TeamData.goal_state: Array`（結構化，非 string tag）。每元素 = `GoalInstance`：
  ```
  { goal_type: String,          # registry key（"acquire_material" / "build_weaponsmith" / …）
    target: Variant = null,      # 選填：per-instance 目標（tile_pos / facility_type / res），定位型/多實例用
    created_tick: int,           # 承諾/折現/timeout 用
    status: String }             # active / satisfied / abandoned
  ```
- **持久跨 tick**：不因當下不能做而清（vs `FactionData.goals` 每 cadence `clear()`＝反模式）。
- **不重用既有 3 欄**（R① 坐实全不能用）：`PersonData.goals`（reaction 消費、與 decision 脫節）/`FactionData.goals`（每 cadence 重建）/`FactionData.strategic_goals`（`invariants:372` 禁當獨立權威）。**team-level 全新欄**。
- **goal 生成/維護**（誰掛 goal 上去）：cadence 評估（人格×現況 → 掛「想要 X」慾望，util-driven 非硬派）。**基礎 goal-set**（WHAT §8）：資源維持（food/material/tools/weapons/coin 各「維持夠用」）+ 設施發展（每座設施「想要 F」）。**掛/退 goal 本身也走 util 門檻**（夠想才掛、達成/長期折零則退），非 scripted。
- **決定性**：goal 掛/退 讀狀態+人格閾，禁 randf。
- **invariants 新增**：goal_state = team-level means-end 唯一權威；跨 tick 持久；禁他處（faction tag/person goals）平行定 team goal。

---

## 3. 組件 B：宣告式依賴 registry（GoalRegistry 資料表）

- **新資料表** `GoalRegistry`（static dict，goal_type → 前置宣告）。一列結構（WHAT §5 五種前置固定，資料隨 goal 變）：
  ```
  "build_weaponsmith": {
    prereqs: [
      {kind: "resource",  res: "material", qty: <build-cost>},
      {kind: "resource",  res: "tools",    qty: <build-cost>},
      {kind: "facility",  facility: "military_outpost"},   # 設施型前置
      {kind: "manpower",  pop: <N>},
    ],
    payoff: <解掉的上層 util 估>,     # 折現用
    invest: true/false,               # 投資型才折現
    action: <前置全滿時的終端動作 to_task template>,
  }
  "acquire_material": {
    prereqs: [ {kind:"location", terrain:"forest", control:true} ],  # 定位型（本場核心缺口）
    action: <harvest template>,
  }
  ```
- **前置種類 = 引擎認的固定 enum**（`resource` / `location` / `manpower` / `facility` / `subgoal`）。每種對應一個 resolver handler（組件 C）。**加 goal = 填這幾格 = 資料**，零決策 code＝通用性實體（憲法：加 goal=加資料）。
- **淺、有界**（WHAT §9）：鏈幾層；registry 是 DAG（前置遞迴防環——複用 NeedOracle re-entrancy guard 精神，`visiting` set 切環）。
- **基礎 goal-set 初始填**：food/material/tools/weapons/coin 取得鏈 + 8 座設施發展鏈（WHAT §8）。coin 取得鏈特殊（§8：可賣 surplus + 觸得到買家，非採集；涵蓋 coin-liquidity 取代 extract flat 0.4）。

---

## 4. 組件 C：GoalResolver（新中間層，runtime frontier 合成）

**核心新子系統。** `GoalResolver.frontier_candidates(state, team, ctx) -> Array[Candidate]`：

- 對 `team.goal_state` 每個 active goal，walk `GoalRegistry[goal_type].prereqs`：
  - 每前置查「滿了沒」（per-kind handler，見下）。
  - **全滿** → 該 goal 的終端 `action` = frontier candidate。
  - **有未滿** → 遞迴該未滿前置成子目標，找到「當下 applicable（前置滿）的最深 frontier」= candidate。（= WHAT §3：前置未滿 fall through 到當下能做的子目標。）
- **per-kind prereq handler**：
  | kind | 滿足判定 | 未滿→子目標 candidate |
  |---|---|---|
  | `resource` | holding ≥ qty | 「取得 res」（採/產/買，走 NeedOracle 泛化 + 既有取得 option）|
  | `location` | 隊控制/在 滿足條件 C 的 tile | **通用 tile-resolver**「找最近可達、滿足 C 的 tile」→「移動到/settle 該 tile」candidate |
  | `manpower` | pop ≥ N | 「長 pop」candidate（既有繁殖/招募路）|
  | `facility` | 自有 outpost 有該設施 | 遞迴 `build_<facility>` goal |
  | `subgoal` | 另一 goal satisfied | 遞迴該 goal |
- **★通用 tile-resolver**（定位型核心新增，取代一次性 finder）：`find_nearest_tile(state, team, condition_fn, reachable=true) -> tile`。condition_fn 宣告式（terrain==forest / 有 material regen / unowned…）。**這是現有各 `_find_*` finder 缺的通用版**（R① 坐实）。決定性（無 randf；tie-break 用 tile_id）。
- **有界**：只 resolve 到 frontier（當下能做的一層），**不算整圖、無 plan-state**（vs 退役 S2）。每 tick 重算 frontier（cheap，local）。
- **決定性**：純讀狀態+registry，禁 randf（[[feedback_observer_no_global_rng]]）。

**Candidate 結構**：`{ util: float, to_task: Dictionary, source_goal: GoalInstance, label: String, delegate: bool }`。

---

## 5. 組件 D：委派 peer option（泛化 `_try_dispatch_or_invite`）

- **現況**（R① 坐实）：`_try_dispatch_or_invite`（`faction_ai:554-570`）= 手評 heuristic（`ambition*0.5+military*0.3`）在 rank 池**外**跑，非 option。
- **改**：每個 frontier candidate 若可委派（該 action 能由子隊執行），resolver 產**兩變體**：`{delegate:false 自己做}` + `{delegate:true 派子隊做}`，**都進 rank 池競 util**（WHAT §4：委派跟自己做並列按 util 挑）。
- 委派變體 util：含「母隊留守本業 + 子隊並行」的價值（多線紅利）；扣「餘力成本」（pop-guard 不夠則委派變體 not applicable）。
- **餘力 gate 配額**（WHAT §4）：能同時跑幾線 = 既有 dispatch pop-guard（`MIN_PARENT_POP_AFTER_DISPATCH` 等）；窮隊少線、強權多線=寫實。跨線協調=隱式（util 排序+餘力 gate 自動分配，不建總參謀）。
- **gate②**（settle attempt-gate 矛盾，known_issues flagged）**在此一併正解**：委派 candidate 的 applicable 就用真 viability（pop−settler≥MIN_PARENT），attempt-gate 與 dispatch guard 同源，無 8-12 浪費帶。

---

## 6. 組件 E：need-chaining（NeedOracle 泛化）

- **現況**（R① 坐实）：`_supply_chain`+`_construction_facility_need` 真有資源型 chaining，但硬 scope `CONSTRUCTION_COST_RES=["material","tools"]`。
- **改**：資源型前置的 need 傳播**泛化**——goal 的 `resource` 前置 → 生 res-need → 若該 res 需製造/採集則遞迴其鏈（既有 `_supply_chain` DAG walk 精神，但由 GoalRegistry 驅動非硬 scope）。
- **邊界**：NeedOracle 續管「資源數量 need」；**定位/人力/設施/子目標前置不塞 NeedOracle**（它 per-(team,res)→float 表達不了）——走 GoalResolver 的 per-kind handler。**分工清楚**：資源量→NeedOracle；非資源前置→Resolver。
- re-entrancy guard 精神沿用（防 material↔tools 型跨環）。

---

## 7. 組件 F：折現（投資型 util）

- **只投資型折現**（WHAT §6）：現在花、N tick 後回本（派隊走幾天建 forest 據點）。即時動作（現採糧）不折現。
- **candidate util** = `預期回報 × 折現(延遲, 人格)`：
  - **預期回報**（淺啟發，守有界）：該 frontier 解掉的**上層 goal payoff**（GoalRegistry `payoff` 欄）。非完整經濟報酬模型。
  - **折現(延遲, 人格)**：延遲越長折越重；**人格=折現率**（耐心/慎重折輕=遠視；衝動/絕境折重=短視）。**權重非 gate**（憲法：人格 WEIGH 不 GATE）。
  - 效果（WHAT §6）：快餓死隊折到趨零→輸給眼前糧危（不起步走遠路）；穩定隊遠視投資。**情境感知（餓=短視）由 food_days 進折現率**，同既有 survival boost 精神但反向（boost 拉近端、折現壓遠端）。
- **HOW 待 plan 細化**：`payoff` 估法、折現函數形（exp/linear）、人格折現率映射——plan 定具體公式（TEST VALUE，measure 後校）。

---

## 8. 組件 G：rank 池整合（唯一改既有 decision_engine）

- **現況**：`rank_scored_ctx`（`decision_engine.gd:56-91`）只 `for opt in DecisionOptions.applicable(ctx)`（static REGISTRY）。
- **改（最小侵入）**：rank loop **後追加** goal frontier candidates：
  ```
  for opt in DecisionOptions.applicable(ctx): … (既有不動)
  for cand in GoalResolver.frontier_candidates(state, team, ctx):   # 新增
      scored.append({u: cand.util (+ commitment if 現行), i: idx++, opt: cand.label, cand: cand})
  scored.sort … argmax (既有不動)
  ```
- winner 若是 goal candidate → 用 `cand.to_task`；若是 static option → 既有 `to_task_of`。
- **承諾**：goal-level 承諾（掛著的 goal 持久）+ 既有 option commitment bonus 對 frontier label 沿用（現行 frontier +bonus 防抖）。
- **boost 交互**：survival/threat boost 仍只作用 static SURVIVAL/THREAT option（goal candidate 是發展型，絕境時折現自然壓低=不需 boost 排除；survival boost 破頂仍優先＝存亡保序）。
- **決定性**：candidate 順序決定性（resolver 輸出 stable-sorted by goal created_tick + tile_id），tie-break 同既有 `i` 順序。

---

## 9. 既有複用 vs 新增 map（誠實，R① 後）

| 塊 | 既有可複用 | 新增 |
|---|---|---|
| argmax 湧現順序 | ★`rank_scored` 本體（唯一真複用薄塊）| rank loop 追加 candidate（組件 G，最小侵入）|
| 前置 gate | `applicable` **介面**精神 | frontier 的 per-kind 滿足判定（組件 C handler）|
| 資源 need 傳播 | `NeedOracle._supply_chain` DAG walk 精神 | 泛化脫 CONSTRUCTION_COST_RES 硬 scope（組件 E）|
| 承諾 | `COMMITMENT_BONUS`/timeout/priority | goal-level 承諾（組件 A created_tick）|
| 委派執行 | `SubteamSystem.dispatch` | 委派**當 option**（組件 D，泛化 heuristic）|
| goal 表示 | 無（3 欄全不能用）| TeamData goal_state schema（組件 A）|
| 依賴 registry | 無 | GoalRegistry 資料表（組件 B）|
| 定位型前置 | 無（finder 都一次性）| 通用 tile-resolver（組件 C）|
| 折現 | 無 | 組件 F（100% 新）|

---

## 10. slice 切分（plan 建議——whole-system-first：內部分 slice，但交付=whole，建完當 whole 才 measure）

> ★用戶原則②：**建完前不邊建邊 measure 個別症狀**。slice 是**內部開發/R②粒度**，非「每 slice measure 一次症狀」。整套接通跑得動（無崩潰、determinism 綠）才回頭 measure 基礎經濟活起來。

- **S1 骨架**：GoalState schema（組件 A）+ GoalRegistry 空表結構（組件 B）+ rank 池整合 hook（組件 G，先吃空 candidate 列表＝byte-identical no-op proof）。**驗**：determinism 2 跑 identical、既有行為零變（candidate 空）。
- **S2 resolver + 資源型**：GoalResolver（組件 C）+ 資源型 handler + NeedOracle 泛化（組件 E）+ 資源維持 goal-set（food/material/tools/weapons/coin）。定位型先 stub（回無 candidate）。**驗**：資源 goal 能 resolve、determinism。
- **S3 定位型 + 通用 tile-resolver**（組件 C 定位 handler）：解本場 material 核心缺口（缺料→找 forest tile→移動/settle candidate）。
- **S4 設施發展 goal-set + 設施/人力型前置**（8 座設施鏈）。
- **S5 委派 peer option**（組件 D）+ gate② 正解 + 餘力 gate 多線。
- **S6 折現**（組件 F）+ 人格折現率。
- **S7 goal 生成/維護 cadence**（掛/退 goal 的 util 門檻）+ 收尾接通。
- **whole 接通後** → measure（WHAT §12：基礎經濟活起來、EXPAND/harvest/facility/deal 脫近零、人格差異化投資、material/coin/掛單噪音自然消退）。
- 每 slice：**R② 必過** + determinism 綠 + 憲法 gate（constitution_gate：新機制禁引擎外 task 指派/god-view/RNG）。

---

## 11. 憲法 / 有界 / 決定性（驗收硬條件）

- **utility 餵 utility**：所有選擇走 rank argmax + frontier applicable，零 hardcode 決策 edge（「缺料→去森林」=圖走出的路徑）。
- **人格 WEIGH 不 GATE**：人格進折現率/util 權重，禁硬類別閘（[[project_unification_matrix]] 憲法）。
- **感知鐵律**：frontier resolver 讀 belief（team_known/belief_pos）非 god-view；tile-resolver「可達」用 belief-reachable 非全知（跨圖 leak 禁）。
- **有界**：淺 registry、只查 local frontier、無 plan-state、無總參謀。
- **決定性**：GoalResolver/tile-resolver/goal 生成**全禁耗 global RNG**（observe/resolve 路徑 suppress，[[feedback_observer_no_global_rng]]）；三跑 byte-identical 硬驗。
- **全量可觀測**：新 decision/state（goal 掛/退、frontier 選中、折現值）必接 tap（[[feedback_full_transient_observability]]，撐 QA 故事稽核）。

---

## 12. 開放待 plan 細化
- goal 生成 cadence 的 util 門檻具體值（TEST VALUE）。
- 折現函數形 + payoff 估法 + 人格折現率映射（組件 F）。
- 委派變體 util 的多線紅利/餘力成本公式（組件 D）。
- GoalRegistry 各基礎 goal 的前置資料填寫（組件 B，資料量大但機械）。
- tile-resolver 可達性成本（距離/地形）估法。
- goal_state schema 上限（防 goal 爆量，有界）。

## 溯源
WHAT 設計 2026-07-24；R① 異質框外審 CONTRADICTION（`2026-07-24-reviewer-to-systems-R1-…`）更正 premise；code-ground（decision_engine:56-91/options:385-411/need_oracle）；[[project_unification_matrix]]（means-end=flat 決策常數病最深版）[[feedback_whole_system_first]][[project_causal_spine]]。
