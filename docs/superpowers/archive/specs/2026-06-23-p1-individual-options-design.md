# P1 個體域 options — 掠奪/偵查 納統一引擎（個體人格驅動）

> 系統 HOW spec。承他域 ruling `2026-06-22-otherdomain-ruling` #1（**team 日常 op = 個體人格 weigh**，非頂層協同）+ 統一框架 arc（他域遷入=各加 Option row）。
> P1（他域鏈第二塊，**不需 faction 協調 seam**=P3 才做）。**解鎖 loot option**（P2 survival 全隊退役前置）。

## 範圍（緊，防 P0 式 sprawl）

**只做**：給 `uses_unified` 隊（TAG_MERCHANT|TAG_PRODUCE）加兩個人格加權 engine option：
1. **`掠奪`**（loot/raid）— 機會主義打弱者（殘忍/好戰/貪婪 leader）。
2. **`偵查`**（scout）— 查探鄰隊（慎重/計謀 leader）。
3. **`小徵收`（extort）= 不另做 option**：搭 `掠奪` 既有 interaction（loot 到場 → `_should_pay_tribute` → submit 則 extort、否則 combat，`interaction_system` 既有）→ 自動隨 loot 來。

**非目標**（明文排除）：
- 頂層協同/faction_duty（= P3）、大攻擊/開戰（= P4）、結盟/立國/大徵收（= P4）、戰俘（= P5）。
- **不碰非 unified 隊**（舊 faction_ai loot/scout/survival 路徑原樣零改）。
- 不新 TASK_*（TASK_LOOT/TASK_SCOUT 既有）。
- 不改 targeting 機制（既有 `_find_weakest_prey`/belief-read `best_estimate` 複用，G3-targeting 已 merged）。
- 不改 interaction extort 機制（既有複用）。

## 設計：兩個人格加權 option（複用既有 term/target/task）

### 1. `掠奪` option — `options.gd` REGISTRY + `terms.gd`
```
REGISTRY["掠奪"] = [["loot_drive", "loot"]]
```
- **term `loot_drive`**（新，`terms.gd`）：機會主義掠奪驅力。eval = 有可達弱獵物時的價值（複用 `_find_weakest_prey` 邏輯判斷「有無弱者」+ 獵物估富 belief）。無弱獵物→0。
- **weight `loot`**（新，`terms.gd::weight`）：`殘忍×0.5 + 好戰×0.3 + 貪婪×0.2`（複用既有 `_loot_pref` 公式，對齊非 unified loot pref）。
- **applicable()**（`options.gd`）：`has reachable weak prey`（複用 `_find_weakest_prey != -1`，含 belief 守衛——無情報不評估，符 G3）。
- **to_task()**：`{task=TASK_LOOT, target=_find_weakest_prey(...)位}`（複用）。
- **believability**：weight 對一般商隊（殘忍/好戰 低）→ loot_drive×low weight ≪ trade → 不掠奪；殘忍/好戰/貪婪 leader → 可贏 trade → 機會打劫（湧現 raider 商隊，稀有）。

### 2. `偵查` option — `options.gd` REGISTRY + `terms.gd`
```
REGISTRY["偵查"] = [["scout_drive", "scheme"]]
```
- **term `scout_drive`**（新）：對「有價值但不確定」鄰隊的查探驅力。eval = 鄰近有 belief-uncertain 且潛在有值的隊時為正（複用 `BeliefSystem.uncertainty`/`has_belief`；無不確定目標→0）。
- **weight `scheme`**（新）：`計謀×0.5 + 慎重×0.3`（謀略/謹慎者愛查探）。
- **applicable()**：鄰近有 uncertain 目標。
- **to_task()**：`{task=TASK_SCOUT, target=best_estimate 位}`（複用 G3d-2 scout 機制：移入視野→親見壓 uncertainty）。
- **註**：scout 既有為「攻擊前驗證」子步（G3d-2 in faction_ai）。本 option = unified 隊**主動日常查探**（好奇/謹慎），非綁攻擊。低值 enrichment，但 ruling 明列為日常 op。

### COMMITMENT_BONUS / tie
複用既有 `DecisionEngine.rank` COMMITMENT_BONUS（防抖）+ REGISTRY 順序 tiebreak。掠奪/偵查 排序置 trade/survival 後（survival-class 危時仍量級碾壓 = P0 既有 survival_pressure 不破）。

## believability（守 ruling #1 + 統一框架守則）

- **個體人格 weigh**（非頂層強制）：loot/scout 由 leader 人格權重決，各隊自走（符 ruling「日常 op=個體」）。
- **稀有/湧現**：多數商隊人格溫和→照貿易；殘忍/好戰 leader→機會打劫（湧現角色轉換，非每隊）。
- **危時不掠奪做日常**：survival-class（食物危）量級仍碾壓（P0 survival_pressure `4×(3-food)` 危時 ≥2 > loot_drive 域）→ 餓商隊先求生非打劫（除非 loot 本身是求生手段=P2 範疇，本塊機會掠奪非絕境 loot）。
- **吃 belief**：掠奪選誰讀 best_estimate（偽裝弱誘殺/慎重 scout 看穿 = G3 既有閉環，不重做）。

## 驗收

- **unified 隊可掠奪/偵查**：headless 新測——殘忍/好戰 leader unified 隊鄰有弱獵物→engine 選 `掠奪`(TASK_LOOT)；計謀 leader 鄰有 uncertain 目標→選 `偵查`(TASK_SCOUT)；溫和商隊鄰有弱獵物但→仍選貿易（weight 壓制=稀有）。
- **小徵收隨 loot**：unified 隊 loot 到場、目標 submit → extort（既有 interaction，trace `tribute`）。
- **危時不亂掠奪**：食物危 unified 隊→survival-class 贏（覓食/返家補給），非掠奪（除非 loot=求生 P2）。
- **non-unified 零影響**：舊 faction_ai loot/scout/survival 路徑全綠（既有絕境/feud/掠奪測原樣）。
- **TC1/4/6/7 原樣**（loot/scout 只在有獵物/uncertain 目標 + 人格夠才起，TC 隊無此條件→0 影響）。
- **守恆**：loot 戰鬥/extort 走既有守恆（不碰）；coin_eq 0、InvariantAudit 0。
- **world_sim 不崩**：2yr 不全滅、掠奪/偵查 emergent 可見（殘忍 leader 隊有 TASK_LOOT、`[Scout]`），無 over-loot（多數仍貿易/生產）。

## 檔案

- `scripts/simulation/decision/terms.gd`：新 term `loot_drive`/`scout_drive` eval + weight `loot`/`scheme`。
- `scripts/simulation/decision/options.gd`：REGISTRY 加 `掠奪`/`偵查`、applicable()、to_task()（複用 `_find_weakest_prey`/`best_estimate`）。
- `scripts/simulation/decision/decision_context.gd`：可能加 ctx 欄（`has_weak_prey`/`weak_prey_pos`/`uncertain_target_pos`）——若 `_find_weakest_prey` 簽名可從 options 呼叫則免，否則 gather 時算入 ctx。
- `scripts/debug/headless_test.gd`：新測（掠奪/偵查 option 選擇 + 人格分歧 + 溫和不掠奪 + 危時 survival 贏 + non-unified 不變）。
- 可能 `scripts/debug/framework_validation.gd`：S3 scout/S4 ambush 場景對齊（unified 隊 scout）。

## 風險 + 緩解

- **unified 隊掠奪破經濟世界**（商隊互打→經濟崩）：weight 嚴（殘忍/好戰/貪婪 才贏 trade）+ 只打弱獵物 + 危時 survival 碾壓 → 稀有。world_sim 量 over-loot（多數仍貿易為準），過頻調 weight 係數（TEST VALUE）。
- **scout option 低值/噪音**：scout 既有為攻擊驗證；獨立日常 scout 可能少觸發或無下游消費。若量測 dormant → 記 backlog（ruling 列為日常 op 故先加，量測定去留）。
- **與 P4 攻擊重疊**：P1 掠奪=機會打弱（個體、TASK_LOOT、survival-class 不到頂層）；P4 攻擊=蓄意開戰（頂層 faction、TASK_ATTACK、readiness gate）。明確分工避雙寫。
- **targeting god-view 回潮**：複用 `_find_weakest_prey` 既有 belief 守衛（無情報不評估，禁 fallback 真值）——驗證 unified 路徑同守 G3。
- **scope sprawl（P0 教訓）**：明文非目標 + 只碰 decision/ 三檔 + non-unified 短路零改。implementer 嚴守最小、不加 exemption 鏈（unified 隊掠奪走既有 combat/interaction，無需施工子隊式豁免）。

## 開放細節（plan 定）

- `loot_drive`/`scout_drive` eval 量級（對齊 trade 域 0.5-1.5，loot 危時不該碾壓 survival → 上限 ~1.5）。
- `_find_weakest_prey` 從 options/context 呼叫的簽名（`FactionAISystem.new()._find_weakest_prey` 或抽 static helper）。
- ~~scout 是否做~~ **系統定案：P1 只做 `掠奪`**。理由：① 掠奪真解鎖 P2 loot 遷移、是真行為 ② 獨立日常 `偵查` 下游消費存疑（既有量測 scout=0、scout 已是攻擊驗證子步 G3d-2）→ 建 standalone scout option = 風險落 dormant code（[[project_framework_seams]] 鐵則：不 land 無 consumer 函數）。**偵查 延 backlog**：待 P4 攻擊或實際需求出現再評（屆時 scout-as-want 有明確下游）。本 spec `偵查` 段保留為設計參考，不實作。
