# 階段2 招人成幫 — Design

> 日期：2026-06-16
> 議題：Kenshi 型下而上玩家迴路第二階。玩家從階段1（獨自生存:狩獵/野獸/伏擊/絕境求生）進到「招募同伴成小隊」。後端 `recruit_anon`/`recruit_named` 已存在（向別隊付 coin 挖人）。本 spec 設計玩法包裝:為何招、招誰、從哪招、養得起否、招來幹嘛,並補「絕境散人收留」這條新路徑。

## 設計核心（接玩家到既有活世界動態,非新招募系統）

| 單元 | 內容 | 狀態 |
|---|---|---|
| **① 招募來源/成本** | emergent 流民供給 + config seed 開局;雙軌成本（絕境→食物 / 專才→coin） | 食物路徑新增;coin 路徑/emergent 流民動態已存在 |
| **② 收容觸發/流程** | NPC 主動求加（forced event）+ 玩家主動招（互動選單） | 接既有 forced_interaction + recruit emit |
| **③ 養得起 + 招來幹嘛** | 餵食壓力（reuse famine/loyalty/defect）+ emergent 部署（按真技能聚合） | 全 reuse,不新做 |
| **④ 能力 legibility** | 隊級能力讀數 + 招募 delta + 結果掛鉤 | DTO 暴露 + 復用面板 |
| **⑤ tutorial onboarding** | 閾值觸發一次性送小隊（scenario 層,疊在 ①②上） | 新增,走真投靠流程 |

## 不變量

- **食物=消耗品非守恆**：收留 onboarding 扣食物 = 被收留者吃掉（合法消耗,等同每日口糧）。`coin_eq` 審計不算食物,不碰守恆。
- **coin 招募守恆**：挖專才付 coin → 轉給對方隊（現 `_recruit_anon_internal` 已守恆,不蒸發）。
- **對稱性**：招募對象來自驅動 NPC 的同一套流民/投靠動態;玩家是這套的收容點,非招募專用特例。
- **同格 gate**：收留/招募需與對象同格（既有互動前提）。
- **UI 邊界**：經 query DTO + command,零直存。
- **emergent 部署按真技能聚合,不假造數字**（見③）。

## ① 招募來源 / 成本（API/sim）

**來源**：emergent 為主——流亡/敗殘/分裂/絕境流民團（既有人口動態持續產出遊蕩隊）。config 只 seed 開局（survival_start 已有乞丐團/野村）。**無特製 spawner**。

**雙軌成本（按觸發/誰主動分流,非按絕境度）**：
- **投靠（對方主動來）→ 食物**：絕境流民主動求收留 → 只收 **onboarding 食物 = MEAL × 收容人數**（MEAL = TEST VALUE ≈ `FOOD_PER_PERSON_PER_DAY/3`,一餐）。輕上前成本,真壓力在後續每日 burn。收留難民:你餵他進來。
- **招募（玩家主動去取）→ coin**：玩家主動挖人 → 沿用現 `recruit_anon`(50)/`recruit_named`(150),付 coin 轉對方隊（守恆）。挖角:對方不缺,要錢買。

**為何按觸發分流（非按絕境度）**：更明確 + 防玩家鑽絕境判定（找半絕境隊低價食物挖）。玩家**只能食物收留「主動來投靠的」**;想主動拿人 → 付 coin。

**絕境判定** helper：`_is_desperate(target) = food_days < 門檻 or current_task in SURVIVAL_TASKS` —— 用作 **NPC 是否對玩家發起投靠的閘**（絕境才會來投靠）,非玩家招募的成本選擇器。

## ② 收容觸發 / 流程（API + UI）

兩觸發並存,**成本由觸發決定（投靠=食物 / 招募=coin）**：
- **NPC 主動求加（投靠 → 食物）**：`_is_desperate` 流民團同格玩家 → 寫 `player_forced_event`（action="join_request", from_id）→ text_ui forced 模式顯「流民 TeamX 快餓死,願以勞力換口飯。收留?[食物 N]」→ 接受（扣食物 + 併入,reuse recruit 轉移,**跳過 coin**）/拒。接既有 forced_interaction 自動進場（U19）。
- **玩家主動招（招募 → coin）**：互動選單對同格隊「招募」(P3 已 emit recruit_anon)→ 付 coin（現成 `_recruit_anon_internal`,守恆）。**無食物軌**。

併入核心（人口/treasury/tier 轉移）兩軌共用;成本層分流:投靠扣食物跳 coin、招募扣 coin 轉對方。

## ③ 養得起 + 招來幹嘛（全 reuse,不新做）

**養得起**：新人計入 population → 每日 `FOOD_PER_PERSON_PER_DAY` burn。餵不飽 → 既有 famine（famine_days/hunger）+ loyalty 降 → defect 離隊。**不新做機制**,招人自動接入既有飢餓/忠誠/叛離鏈。拉動狩獵迴路（要養更多人 → 獵更多）。

**招來幹嘛 = emergent 部署（按真技能聚合,不假造）**。技能聚合三模式（現碼實況,設計須照實顯示）：

| 聚合模式 | 技能 | 招募影響 |
|---|---|---|
| **named 平均** | 求生（小獵物成功率/產出） | 招高求生 named ↑、招低求生 ↓（拉低平均）、招 anon 無影響 |
| **逐個體/最佳** | 戰鬥·弓箭（遭遇戰每單位）、偵查（偵測最佳）、醫療 | 每人貢獻自己;招強戰鬥 = 直接多強單位 |
| **僅 leader** | 統領（人口上限）、商業（貿易折扣）、戰術、計謀 | 主隊無用,但 **= 子隊長料**（見下） |

**生 anon**：不碰任何 named 技能;貢獻 = anon tier 戰力 + 負重 + （多張嘴）。

**真張力（保留,Kenshi 寫實）**：生招一堆 anon = 多嘴 + 戰力,但**不會自己獵小物餵自己** → 餓更快,除非招求生專才 或 靠打野獸（戰鬥→肉）。教玩家「招人要嘛招獵手、要嘛靠獵肉養」。

**specialist → 子隊（leader-only 技能的出路,現成）**：`subteam_system.dispatch(parent, sub_leader_id, task)` 讓玩家指定 named 當子隊長 → 其統領撐子隊 pop cap、其商業套用子隊貿易折扣（`interaction:638`）。招商業/統領專才 = 未來貿易/分隊子隊長。**dispatch_subteam + subteam 面板已存在 → 階段2 不造,只要招募餵得進去**。橋接階段3 分工。

**不做每人任務指派 UI**（YAGNI;早期小隊「整隊做什麼」決策已足,逐人 micro = 管理負擔）。

## ④ 能力 legibility（讓 emergent 有感）

emergent 若隱形 → 招了沒感覺。暴露**隊級能力讀數**（按③真聚合計算,非假數字）：
- DTO 加衍生欄位：`hunt_chance`/`hunt_yield`（從 named avg 求生）、`combat_power`（從單位數+tier+戰鬥+武器,沿用遭遇戰 spawn 公式）、`food_burn_per_day`(pop×2.4)/`food_days`、`carry`（pop-based）。
- **招募 delta 回饋**：收容時 feedback「收留4人:戰力+12 / 日耗+9.6食 / 求生不變⚠不增獵食」。一行秀價值+代價。
- **結果掛鉤**：狩獵結果顯「N 人狩獵 → 肉 M」;遭遇戰上場單位數 = 隊（既有）;人手足 → 「可獵掠食者」提示亮（孤身 disabled）。
- **招募價值顯示**：預覽各 named 技能,標「主隊用（戰鬥/求生）/ 子隊長料（商業/統領）」——誠實反映該技能在玩家隊有沒有用,不標「無用」。
- **復用**：成員面板（B4 已列 named/anon）、status chrome（P2 food_days）。新 = 隊級能力衍生 DTO（多為把既有狩獵/戰鬥公式的結果算出來顯示,非新邏輯）。

## ⑤ tutorial onboarding（scenario 層,疊在 ①②）

- **一次性**，`player_state["recruit_tutorial_fired"]` flag-gated（不重複,之後交 emergent）。
- **觸發**：玩家 `food` 盈餘 ≥ 閾值（訊號「撐過荒野、夠格帶人」+ 隱性教養得起前提:觸發時真養得起）。
- **內容**：forced event 送 **1 堪用 named（略偏有用,保底一個堪用技能如狩獵/戰鬥中上）+ 3 tier-0 anon（白丁,不送菁英）** @ 玩家旁,**忠誠偏高**（學習期不落跑）。
- **成本**：收 onboarding 食物 = MEAL×4（閾值保證有盈餘,不痛但教完整成本決策）。
- **走真投靠流程**（與 emergent 同 UI/command）→ tutorial 教的是真機制,非假路徑。

## 資料模型
- **named** = 個體 `PersonData`（attributes/skills/values/loyalty）。
- **anon** = 匿名集體（population 數 + `AnonTierSystem` tier）,無個別屬性,不送菁英（菁英靠 named 或後期 tier 升級賺）。

## 風險
- **食物軌 reuse `_recruit_anon_internal`**：該函數內建 coin 扣 + coin 轉對方。食物軌需抽參數化（cost_type: food/coin）或拆共用核心（人口/treasury/tier 轉移）+ 成本層分流。勿複製整段（DRY）。
- **絕境判定門檻**：`_is_desperate` food_days 門檻 = TEST VALUE,需量測（太鬆 → 全免費;太嚴 → 沒人免費投靠）。
- **能力讀數按真聚合**：combat_power 須沿用遭遇戰實際 spawn/戰力公式（avoid 與實戰不符的假數字）;hunt 用 `_avg_survival`。
- **tutorial 閾值**：太低 → 玩家還沒站穩就塞人餓死;太高 → 遲遲不觸發。TEST VALUE 待調。
- **emergent 供給稀疏**：玩家在偏僻處可能久無流民 → 招募餓死。config seed 開局先擋;若量測顯太稀,**再**加遊蕩團地板/流民趨人煙（不先做）。
- **同格 gate**：收留/招募須同格,對齊既有互動。

## 測試
- API headless：`_is_desperate` 判定;食物軌招募扣食物+併入（pop/treasury/tier 轉移正確,coin 不動）;coin 軌守恆（現有測涵蓋）;能力 DTO（hunt_chance 隨 avg 求生、combat_power 隨單位、food_burn 隨 pop）;tutorial flag 觸發一次。
- ui_flow：NPC join_request forced event → 接受流程;互動選單招募流程;能力讀數顯示;招募 delta feedback。
- 守恆整合：食物軌招募前後 coin_eq 不變（食物非 coin_eq,只驗 coin/ore 不動）。

## 範圍 / 分階（plan）
單一 spec,plan 分 task：
1. **能力 DTO + legibility**（③讀數 + ④暴露,先有「看得到」基礎）
2. **食物軌招募核心**（①成本分流 + `_is_desperate` + reuse recruit 核心參數化）
3. **②觸發流程**（NPC join_request forced event + 玩家主動招 UI）
4. **⑤ tutorial onboarding**（scenario 事件）
5. 註冊 + 守恆/flow 整合測

養得起（reuse famine/loyalty）、specialist→子隊（reuse dispatch_subteam）、coin 軌（existing）**不需新建**,僅確認接得上。
