# 統一統領決策 v2 — 手段-目的意圖驅動（means-end 貢獻匹配，只真 affordance）

> 系統 HOW spec。承藍圖 `commander-v2-core-what`（means-end 模型）+ `ruling-A-deception-anchored`（裁 A：先真 affordance、欺敵 anchored-pre-player）+ 北極星不變量（已納 invariants）。
> **v1 單姿態 + war-priority 作廢。** 統一決策 arc 真根最後一處（統領層）。排玩家面之前。

## 真根 + 模型

`_update_goals`（faction_ai:632-712）= 多閾值並行 append（measure 證每 persona 同發 ≥2 無因令）。**北極星**：凡 named 意圖必有可解釋驅動。統領層第一處落實。

**means-end 貢獻匹配**（讓 AI 真思考非查表）：意圖=目標 predicate → 子需求=主行動未滿足前提現算 → 行動=多義 affordance → util=Σ(affordance∩子需求)×人格×可行性 → 湧現協同 scheme（多肢、每肢可解釋、driver=填了哪條子需求）。**深度 1**（只回推主行動前提，不遞迴）。

## affordance 真實性（盤點後，只掛真）
v2 **只用 sim 真產出的 affordance**（盤點 `known_issues` affordance 債）：
| 行動 | 真 affordance（effect, 服務目標, 模式） |
|---|---|
| 攻擊 | 削敵軍力(削敵,combat) / 掠奪得資源(致富,raid) |
| 徵收 | 籌資(致富/軍費,levy) / 壓迫(控制,oppress[stress hit]) |
| 外交 | 真結盟(補力/盟,ally-merge) / 背叛(betray) |
| 貿易 | 致富(+coin,enrich) |
| 建設 | 鑄幣(致富coin,mint) / 練騎(補力,stable) / 倉儲(cap) |
| 結盟 | 真結盟補力(faction merge,ally) |
**孤兒（欺敵外交/貿易戰/離間/緩兵/城防/威望…）不掛** → 欺敵=anchored-pre-player 承諾 arc（建好插回）；其餘 richness pipeline。

## 範圍（往死裡守 scope，藍圖明令別 boil ocean / 別又白做）
**做**：refactor `_update_goals` → means-end（小意圖集 + 小行動集 + 深度1 + 只真 affordance + 每令帶 driver + 意圖 hysteresis + viability）。
- **小意圖集**：`{征服X, 致富, 防衛, 守成(default)}`（立國=擴張先不做，沿用既有立國 gate 分離）。
- **小行動集**：攻擊/外交(結盟)/徵收/貿易/建設。
- **深度 1**：只算主行動未滿足前提→填補行動命中即用，**不遞迴填補行動自己的前提**。

**非目標**（明文）：
- **不掛孤兒 affordance**（欺敵/貿易戰/離間/城防…）。
- **不碰成員側 P3/P4 option**（攻擊/徵收/外交 engine option 原樣）；成員按人格分配到統領子命令。
- **不碰 `strategic_ai`**（expand/defend/trade_net 另層）。
- **不做完整階層 planner**（淺回推深度1足夠思考）。
- **不做並行多意圖**（成熟派系多戰線=未來）；單主意圖。
- 緊急徵收=survival override（意圖前）。立國=既有分離 gate。不新 TASK_*。
- **war-priority revert**（FACTION_DUTY_DRIVE_LESSER 移除，單意圖後成員選欺敵/外交=服務意圖非 skip，moot）。

## 設計

### 1. 資料：意圖 predicate + 行動 schema（affordance/前提）+ FactionData 欄
```gdscript
# 意圖 = 目標 predicate（小集）
INTENTS = {
  "征服":  {goal:"target 不再獨立", main_action:"攻擊", needs_target:true},
  "致富":  {goal:"treasury 增", main_action:null(多行動服務)},
  "防衛":  {goal:"領土不失", main_action:"守成"},
  "守成":  {goal:"維持", main_action:null},   # default
}
# 行動 schema：前提 + 真 affordance
ACTIONS = {
  "攻擊": {preconds:["force_ge_target","can_reach"], affordances:[{goal:"削敵",mode:"combat"},{goal:"致富",mode:"raid"}]},
  "結盟": {preconds:[], affordances:[{goal:"補力",mode:"ally"}]},
  "徵收": {preconds:["has_richer_member"], affordances:[{goal:"致富",mode:"levy"},{goal:"補力",mode:"fund_war"}]},
  "貿易": {preconds:["has_market"], affordances:[{goal:"致富",mode:"enrich"}]},
  "建設": {preconds:[], affordances:[{goal:"致富",mode:"mint"},{goal:"補力",mode:"stable"}]},
}
```
FactionData：`var intent: Dictionary = {}`（{type,target_id,why} 承諾追蹤）；`var goal_drivers: Dictionary = {}`（goal→{intent,why,mode} 每令 driver）。f.goals 保 Array[String]（成員消費不變）。

### 2. `_update_goals` 重構（means-end 5 步）
```
_update_goals(state, f):
    f.goals.clear(); f.goal_drivers.clear()
    1. player override / 緊急徵收 override(food<emergency→["徵收"]driver=survival,return) / 立國 gate(既有,分離)
    2. 意圖選擇（resource-aware + 人格 + belief + hysteresis）：
        for 每候選意圖:
            score = 人格適性(征服←好戰/野心、致富←貪婪、防衛←慎重/威脅) × 可行性(viable?) × belief
            征服 viable = 能湊出足夠實打力打贏 target(belief 敵力 + 我力 + 可補力餘裕)；湊不出→score 低(resource-aware 選更小意圖)
        + 承諾 bonus(==f.intent.type，COMMANDER_COMMITMENT_BONUS)
        argmax → f.intent
    3. 分解子需求（深度1，主行動未滿足前提 vs live 世界）：
        main = INTENTS[intent].main_action（征服→攻擊target）
        open_needs = [前提 for 前提 in ACTIONS[main].preconds if not 前提滿足(state,f,target)]
        # 如 攻擊.force_ge_target 不足 → open "補力"；can_reach 但 target 有盟擋 → 欺敵孤兒→該 need 無真 filler→不開(或 viability 降)
    4. 匹配 + emit（util=affordance∩需求×人格×可行性）：
        emit 主行動（攻擊target，driver={intent,why:"主手段取target"}）
        for need in open_needs:
            候選 filler = [a for a in ACTIONS if a.affordance.goal 命中 need]   # 補力←結盟/徵收(fund)/建設(stable)
            best = argmax util(filler|need,世界)×人格適性   # 從人格餘裕抽輔助肢
            if best viable: emit(best, driver={intent,why:need,mode})
        致富意圖（無單一 main）：emit 最高 util 的致富行動（貿易/徵收/建設mint 按人格/可行性）
        守成/防衛：emit 守成(無 stakes 令)/徵收(備戰)
    5. viability check：主手段(攻擊)若仍湊不出足夠力 → 退更小意圖(回 2)或降級守成。輔助肢從人格適性餘裕抽（非硬塞）。
```
- **每令帶 driver**（`f.goal_drivers[goal]={intent,why,mode}`）= 北極星滿足（追回意圖）。
- **承諾 hysteresis**：意圖層（戰略別每 cadence 翻）。釋放：意圖 predicate 達成/不可行（敵消失/belief 變敵強→征服不 viable）。
- **吃 belief**：征服 viability 用 `BeliefSystem.best_estimate` 敵力（既有 attack gate 複用）。

### 3. war-priority revert
單主意圖後成員一次服務一個意圖的子命令（攻擊+補力肢）→ 無「打 vs 談」同級矛盾 → `FACTION_DUTY_DRIVE_LESSER` 移除（徵收/外交 drive 回 1.5）。成員按人格分配到子命令（好戰→攻擊、義氣→外交結盟肢、貪婪→徵收肢）= 多重性 feature。

## believability / 驗收（藍圖 viability bar，取代跟戰 3/4）
**兩條都要**：
1. **每選擇可解釋**：每令 `goal_drivers` 追回意圖（driver→意圖通）。`commander_directive_measure` 擴量——每令印 intent+why+mode，**無無因令**。
2. **scheme viable（intent realized）**：征服意圖→**真有足夠實打力**（主手段攻擊填夠），欺敵/籌餉/補力=**輔非替**（核心優先填，輔助從餘裕抽）。征服湊不出力→退更小意圖（resource-aware，不硬發打不贏的攻擊令）。
- **人格/belief 分歧**：好戰→征服 / 貪婪→致富 / 慎重→防衛守成；敵 belief 顯強→征服不 viable→退守成/致富。
- **意圖 hysteresis**：committed 征服連續 cadence 不翻（情勢不變）。
- **緊急徵收 override**：food<emergency→強制徵收(driver survival)。
- **守恆+魂驗**：coin_eq 0、InvariantAudit 0、framework S1-S6 PASS（S1 立國/S2 feud fire）。
- **world_sim**：2yr 不崩、派系下協同令（有 driver、無矛盾）、意圖穩定、征服稀有（多數致富/守成）、**無無因令**。
- **P3/P4 不回歸**：成員在統領單意圖子命令下響應（攻擊/徵收/外交 option 原樣 fire）；跟戰**不數**，看可解釋+viable。

## 檔案
- `scripts/simulation/faction_ai_system.gd`：`_update_goals` means-end 重構 + helper（`_select_intent`/`_decompose_needs`/`_match_fillers`/`_emit_goal`/前提 check）。
- `scripts/data/faction_data.gd`：`intent`/`goal_drivers` 欄。
- `scripts/simulation/decision/terms.gd`：revert `FACTION_DUTY_DRIVE_LESSER`。
- `docs/invariants.md`：「隊目標單一 owner」段補統領=means-end（意圖→子需求→真 affordance 匹配，深度1，非並行閾值/非收斂單一）；意圖驅動段已納（北極星）。
- `scripts/debug/headless_test.gd`：新測（意圖選擇人格/belief/viability 分歧 + 子需求分解 depth1 + 每令 driver 可解釋 + hysteresis + 緊急徵收 override + war-priority 移除 + viability 退更小意圖）。
- `scripts/debug/commander_directive_measure.gd`：擴量 driver（印 intent+why+mode、驗無無因令 + viability）。

## 風險 + 緩解
- **過度設計/boil ocean**（藍圖最怕，前兩輪教訓）：**死守小集 + 深度1 + 只真 affordance**。意圖 4 個、行動 5 個、affordance 每行動 1-2 條。先證 means-end 跑出湧現 viable scheme，再擴。
- **viability 量化**（征服「湊得出力」判定）：複用既有 attack readiness/strength gate（own_armed vs belief 敵力 + 可補力餘裕粗估）。TEST VALUE，world_sim 量「發打不贏的攻擊令」否。
- **意圖 hysteresis 過硬/鬆**：predicate 達成/不可行釋放 + COMMANDER_COMMITMENT_BONUS TEST VALUE。
- **P3/P4 回歸**：成員 option 不動；統領下意圖子命令（攻擊+補力肢）→ 成員按人格響應。驗 P3/P4 headless + world_sim（非跟戰數，看可解釋）。
- **欺敵孤兒留洞**（征服需「擋敵盟」但欺敵孤兒）：該子需求**無真 filler→不開/viability 降**（不硬塞假 affordance）；欺敵 arc 建好後此 need 自動有 filler。**標 anchored-pre-player**。
- **scope**：只 `_update_goals` + faction_data 2 欄 + terms revert + 測。不碰成員 option/strategic_ai/孤兒。

## 開放細節（plan 定）
- 意圖/行動 schema 放哪（faction_ai const dict vs 新 `commander/` 模組）—— 傾向 faction_ai 內 const（小集，避過度抽象）。
- 前提 check 函式（force_ge_target/can_reach/has_richer_member/has_market）複用既有 gate。
- viability 量化公式（征服湊力判定）。
- `COMMANDER_COMMITMENT_BONUS` 量級。
- 致富意圖無單一 main_action 的 emit（多致富行動按 util）。
- 守成 = f.goals=[] vs ["守成"]（消費端容忍空）。
