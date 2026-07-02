# R1 三帶（拔 rung-food 攻擊閘 + means-end 後勤因子）+ R2 judge 收編退役 — Design

> 藍圖裁定 `2026-07-02-blueprint-to-systems-r1-threeband-r2-retire`（與用戶走查定稿）。
> measure 根據 `2026-07-02-systems-to-blueprint-attack-combat-measure-refutes`：征服者 14400 tick 僅發 1 次攻擊，
> 卡 `_evaluate_prosperity_attack` 第一關。雙根：R1 rung-food 閘鎖死 86.5% 餬口帶（50%）、R2 intent↔archetype desync（48%）。

## ★ 統一性硬約束（藍圖裁定原文，違反即打回）

- 三帶（絕境/餬口/富足）= **敘述性 regime，嚴禁實作成 band 判斷器/enum**。全用既有連續信號：
  - 絕境 = survival util 量級支配（已有，`SURVIVAL_TASKS` 早退 + food_days 低 → util 碾壓）
  - 餬口/富足 = `food_flow_avg` 連續進既有 gate/util，非「你屬哪帶」分類
  - 人格分流 = 既有 DecisionEngine / intent scorer 人格權重
  - 飢餓搶（survival option）vs 戰略攻擊（prosperity option）= 引擎既有兩 option，util 量級自然分流，**非攻擊分類器**
- **淨變化 = 拔一閘 + 補一因子 + 退役一 judge。判斷器總數 −1。** 任何新增 classifier = 違反裁定。

## R2：intent/archetype 單一 source（先做，R1 的 archetype gate 依賴它才一致）

### 現狀（兩 judge 讀同 leader values，48% 分類矛盾）
- Judge A `FactionAISystem._intent_scores`（faction_ai:690-710）：`征服 = 野心*0.4+好戰*0.4−義氣*0.4`，argmax vs 守成(0.25)/致富(貪婪*0.6+野心*0.1)/防衛(慎重*0.4+義氣*0.2)。
- Judge B `AmbitionLadder.derive_archetype`（ambition_ladder:24-35）：`force=野心*0.5+好戰*0.5`、`trade=貪婪`、`settle=義氣*0.5+慎重*0.5`，平手序 武力>商業>定居。

### 修法（收編退役，禁第三仲裁器）
1. **單一人格傾向公式**：新 static `AmbitionLadder.disposition_scores(values: Dictionary) -> Dictionary`，回 `{"征服": 野心*0.4+好戰*0.4−義氣*0.4, "致富": 貪婪*0.6+野心*0.1, "防衛": 慎重*0.4+義氣*0.2, "守成": 0.25}`——**即現 `_intent_scores` 人格層原式搬家**（intent 公式是首燒統一 scorer，留它、退役舊式）。
2. `_intent_scores` 改呼 `disposition_scores` 取人格層，其上疊 viability（established/weak_enemy/can_levy）不變。行為位元不變（同公式搬家）。
3. `derive_archetype` **退役自有公式，委派**：`argmax(disposition_scores)` → 映射 `征服→ARCHETYPE_FORCE`、`致富→ARCHETYPE_TRADE`、`防衛|守成→ARCHETYPE_SETTLE`。平手序保留 武力>商業>定居。函式簽名/回傳值不變（呼叫端零改動）。
4. **結構保證 desync=0**：征服傾向 leader 恆 FORCE archetype（同 argmax 同公式）。`prosp.gate_archetype` 探針天然歸零（征服 intent 進 prosperity eval 者必 FORCE）。

### ⚠ 分布風險（必驗，非可選）
新公式改變 FORCE/TRADE/SETTLE 佔比（舊 force=0.5/0.5 無義氣負項；舊 trade=純貪婪）。義氣高的好戰者從 FORCE 滑向 SETTLE 等。
- **驗**：headless 加 archetype 分布 sanity 測（world gen 全 leader 三型佔比皆 >10%，無單型 >80%）；framework S5(mint)/S6(order) 過 = 商隊/生產經濟未死；coin_eq delta=0。
- 平手序測：三軸同分 → FORCE。

## R1：拔 rung-food 攻擊閘 + 補 means-end 後勤因子

### 拔一閘（`_evaluate_prosperity_attack`，faction_ai:199-208 探針版）
- 現：`archetype != FORCE or rung < RUNG_EXPAND → return`。
- 改：**只留人格 gate**（`archetype != FORCE → return`，R2 後=征服傾向），**刪 `rung < RUNG_EXPAND` 條件**。
- `prosp.gate_rung` 探針移除（閘不存在）；`prosp.gate_archetype` 留（R2 後應≈0，殘量=偵測 desync 回歸）。
- **rung 職權收窄不動的地方**（食物盈餘只管立國/坐穩/擴編）：
  - `can_expand`（faction_ai:778，擴張 intent = faction 級領土 pressure）**保留 rung gate**。
  - 建國 `accum_ok`（faction_ai:999）**保留**。
  - `rung_task` ambient（ambition_ladder:89）**不動**。
  - 其餘讀 `ambition_rung` 處一律不動（本 spec 只拔攻擊路徑一處）。
- 絕境帶不受影響：`SURVIVAL_TASKS` 早退（faction_ai:194）在 gate 前，絕境隊本就走 survival 域拚死搶。

### 補一因子（③後勤 by 目標歸屬 + ②路程糧，合一連續因子進 `find_prosperity_prey`）
`find_prosperity_prey`（faction_ai:137-166）現 score = `(richness*貪 + weakness*殘 + border*野)/eta_days`，已有 ①打得贏（belief armed_est weakness）+ 可達性（estimate_catch_up reachable + eta）。缺 ②路程糧、③打了會怎樣。

新增 **一個連續 `logistics` 因子**乘進 score（非 filter、非分類器）：
- **②路程糧**：`trip_food_ok = effective_food(state,team) 對 eta_days × pop × FOOD_PER_PERSON_PER_DAY 的比值`，clamp 連續（糧夠→1.0，半途餓→往 0 滑）。raid 級輕量：只算單程到 prey，不算佔領後勤。
- **③目標歸屬（吃 belief，禁 god-view）**：prey 的 believed faction 歸屬：
  - believed 獨立（或無歸屬情報）→ 1.0（一次 raid，可打）。
  - believed 屬 faction → 罰項 `war_cost`（連續）：基準罰 × 攻擊者戰爭能力減免（自身 established faction + rung 高 → 罰輕 = 開得起戰爭）。母勢力規模加權罰 = 若 belief 有信號才用，無則基準罰即可（raid 級輕量,別為此建 faction 級 belief）。**獨立餬口隊對強勢力屬村 → score 被壓到幾乎不中選 = ③管住 over-war**。
  - belief 錯（過期/謊報歸屬）→ 照 belief 行動 → 捅馬蜂窩 = G3 戲劇，**設計要的，不做真值防呆**。
- **belief 已有歸屬欄位**：tier2 intel 已寫 `snap["faction_id"]`（interaction_system:728）→ ③直讀 `bel.get("faction_id", -1)`，tier0/1 無此欄 → 未知 → 視為獨立（1.0）。**禁 fallback 讀 prey.faction_id 真值。**
- 常數全標 TEST VALUE。

### 不做（scope guard）
- rung yo-yo 平滑（ambition_ladder promote/demote 抖動）——攻擊路徑已不吃 rung，另案。
- R1 選項 b（調 `ACCUMULATE_FLOW_MIN`）——藍圖裁 c 路線（解綁），門檻不動。
- survival loot 路徑、encounter/戰鬥結算、capture 機制——全不動。
- `_evaluate_solo` 舊 solo path 的 TASK_ATTACK 計分——不動（非 prosperity 鏈）。

## 驗收（藍圖裁定原文 + 系統回歸）

1. **seeded conquest_measure**（探針已在 tree `adc5a26`）：
   - `conq.prosperity_reached` 1 → 顯著上升（餬口帶狼放出來）。
   - `prosp.gate_rung` 探針刪除、`prosp.gate_archetype` ≈0（R2 結構保證）。
   - `capture.total`/`capture.by_attack` 上升（capture PAY 已備，打得起來就收）。
2. **不 over-war**（seeded WarringHarness）：
   - 知足/溫和 leader 隊仍蹲（非 FORCE 傾向不進 prosperity）→ 世界不全員開戰、隊數不雪崩。
   - 強勢力屬村不被獨立餬口隊亂捅（③罰項壓住）——量「獨立隊攻擊 believed-faction-owned 目標」次數低。
3. **絕境仍搏**：survival loot 路徑計數不降（`SurvivalLoot` 探針/print 仍見）。
4. **specimen trace**：狼性餬口隊「想=征服→做=raid→積累→（盈餘→擴張）」弧在 trace 可見。
5. **R2 desync=0**：單測——同 values 下 `select_strategic_intent` 選征服 ⟹ `derive_archetype`=FORCE（公式共源，測 argmax 映射一致）。
6. **回歸**：headless 全綠（1 FAIL pre-existing 弱目標容忍）+ 0 SCRIPT ERROR、framework 7/7 DORMANT=0、coin_eq 全池 delta=0、InvariantAudit 0、archetype 分布 sanity 新測過。

## 檔案 scope（並行紀律）

| 檔 | 動什麼 |
|---|---|
| `scripts/simulation/ambition_ladder.gd` | 新 `disposition_scores`、`derive_archetype` 委派改寫 |
| `scripts/simulation/faction_ai_system.gd` | `_intent_scores` 改呼共源、`_evaluate_prosperity_attack` 拔 rung 條件、`find_prosperity_prey` logistics 因子 |
| `scripts/debug/headless_test.gd` | 新測：desync=0 / 分布 sanity / 拔閘後 gate 行為 / logistics 因子 |
| `scripts/debug/conquest_measure.gd` | 刪 `prosp.gate_rung` key（閘已拔） |
