> ⛔ **SUPERSEDED（2026-06-21，根因錯誤作廢）**。本 spec 根因前提算術錯：`carry-cap-in-days=BASE_CARRY/FOOD_PER_PERSON_PER_DAY=10/2.4≈4.17` **隱含假設 food weight=1，但實際 `_resource_weight("food")=0.1`**（movement_system.gd:114）→ carry 實裝 ~100 食物/人 ≈ 41.7 天 ≫ RECOVER(7)，**carry latch 不存在**，carry-aware 釋放為 no-op。子 session BLOCKER 正確抓出（`handbacks/2026-06-21-caravan-survival-carry-aware-release.md`）。
>
> **實測真根（merchant_survival_probe trace）**：商隊**離家時無可靠糧源**——`effective_food` 只在站自家糧倉 tile 才算糧倉（`own_granary_tile` 要 `tile_pos==outpost`）；商隊離家（貿易/被引擎派駐守治理 parked 別 tile/return_home）→ carried 旅途糧緩耗 → 到別處無糧源 → 終究 survival。跟 carry cap / 釋放閾**皆無關**。
>
> **教訓**：見 `[[feedback_avoid_rabbithole]]`——根因建在算術公式上必先讀碼驗每個常數 + trace 實測，別憑公式定 spec。重修走新 brainstorm（provisioning / effective_food 旅途語意 / 引擎別 park 商隊離家）。

# 商隊 survival latch 修 — carry-aware 釋放（履約脫 0 最後一哩）

> 承 sub-project A（`2026-06-21-economy-settle-unified-design.md`，merge `e6433e9`）：生產側經濟環備好，但履約卡商隊 survival latch。
> 藍圖序同意（`caravan-survival-believability` handback）+ 1 believability 護欄：**survival 修是參數/釋放邏輯，非優先序洗平**。
> 本 spec = 統一框架 arc 插塊（B 他域遷入之前），讓履約**首次端到端真活**。

## 病（arithmetic 確認的結構性 latch）

`_evaluate_survival`（`faction_ai_system.gd:2087`）survival 釋放條件 = `days_left >= SURVIVAL_RECOVER_DAYS(7.0)`，用 `ResourceSystem.effective_food`。

**`effective_food` = 私產 food + 自家糧倉 food，但糧倉只在隊「站在自家 outpost」才算**（`own_granary_tile` 要 `team.tile_pos == outpost tile`，`resource_system.gd:345`）。→ 旅途隊（離家）`effective_food` = **只算 carried food**。

**關鍵算式**：carried food 受 carry cap 限（`movement_system` BASE_CARRY=10/人）。
> carry-cap-in-days = `BASE_CARRY / FOOD_PER_PERSON_PER_DAY` = 10 / 2.4 ≈ **4.17 天**（pop 無關：food 需求與 carry 容量都隨 pop 線性縮放）。

`SURVIVAL_RECOVER_DAYS=7 > 4.17` → **旅途隊永遠到不了 7 天釋放閾** → 進 survival(FORAGE) 後永不釋放 → 永不回貿易 → world_sim 履約 ≈0。`PROVISION_DAYS=10` 乾糧 buffer 本身也被 carry 砍到 ~4 天，商隊出門即接近 WARNING(3)。

= 結構性不可能（非機率）。measure-first（sub-project A world_sim）已見 `merchant_survival≈164`、`seek_market=1`（商隊幾乎不出門），佐證。

## 修：carry-aware survival 釋放

`_evaluate_survival` 釋放分支（現 2114-2119）改成旅途隊**可滿足**。在 survival task 中，釋放 = 下列**任一**成立：

1. **`days_left >= SURVIVAL_RECOVER_DAYS`**（**現有**，保留）：給站糧倉/大儲量隊的足糧釋放。
2. **「forage 已盡力」釋放（新）**：隊**無法再多攜 food**（carry 空間對 food 耗盡）**且** `days_left >= WARNING_DAYS(3.0)`（非瀕餓）→ 釋放回 IDLE。

白話：「你已 forage 到攜不下、且不再瀕餓 → 停止 forage，回正常決策」。釋放後引擎/舊系統重評；引擎 `survival_pressure` term 仍按糧況加權（真變餓→自然再進 survival option）。

**「無法再多攜 food」判定**：用既有 WS-3 carry 空間 accessor（`MovementSystem` 的 `carry_space_for_res(team, "food")` 或 `remaining_carry_space`）。food 可攜空間 `<= EPSILON`（≈0）= 攜滿。**正確處理 goods 競爭**：商隊載滿 goods 時 food 空間本就≈0 → forage 無用 → 釋放（讓引擎改去賣 goods/貿易，正是要的）。

**保留 proactive_camp 例外**（現 2115-2116）：SoloAI 主動 TASK_CAMP（PRIO_DISPATCH）不被糧足釋放，避免 churn。新分支同樣排除 proactive_camp。

## 守藍圖護欄（believability）

- **survival 優先序不動**：進入閾值 `URGENCY_DAYS(1)`/`WARNING_DAYS(3)` 不變、`_trigger_survival` 不動。只改**釋放**側。
- **真餓/真危險仍卡 survival**：`days_left < WARNING(3)` → 新分支不觸發（要 `>= WARNING`）→ 瀕餓商隊續 forage，不會被放去巡市集。受威脅（survival task 由威脅觸發）同理：糧足但威脅在 → 屬 threat 維度，本修只放「攜滿+不瀕餓」的糧因 survival，不碰 threat 釋放。
- **驗收反例**（藍圖提案）：量一筆「商隊 `days_left<3` 或受威脅 → seek_market 不觸發」仍成立 = 沒洗平。

## 範圍邊界 / 非本塊

- **survival 不遷進引擎**：統一隊 survival 仍由舊 `_evaluate_survival` 擁有（兩 owner 技術債留著）。survival 子行為（FORAGE/CAMP/BEG/JOIN/RETURN_HOME）變 engine option = 後續框架完成塊，非本塊。本塊只修舊系統釋放閾的結構 bug。
- 不碰 carry cap 常數、不碰 `PROVISION_DAYS`、不碰 `effective_food` 語意。
- 不碰守恆（只改 task 釋放決策，不碰 resources/coin/state 池）。

## 驗收

- **履約脫 0（主目標）**：world_sim ≥1000 tick，`g1.order_fulfilled > 0`、`[Market]成交` 常態、`merchant_survival` 大降、`seek_market`/`market_arrive` 升。
- **believability 反例**：`days_left<3` 商隊不釋放（headless 單測 + world_sim 抽樣）。
- **不破飢荒鏈**：既有 survival/飢荒/絕境測試全綠（真絕境隊仍正確進/留 survival）。
- headless 全綠、coin_eq=0、InvariantAudit 0。
- 無 survival↔IDLE thrash（釋放後不立刻重進；hysteresis band [WARNING, 攜滿] 足夠 + 引擎承諾）。

## 檔案

- 改 `scripts/simulation/faction_ai_system.gd`：`_evaluate_survival` 釋放分支（2114-2119）加 carry-aware OR 條件。
- 改 `scripts/debug/headless_test.gd`：新測「旅途攜滿商隊（days_left∈[3,7]、food 空間≈0）→ 釋放」+ 反例「瀕餓（days_left<3）→ 不釋放」。

## 風險 + 緩解

- **釋放後立刻重進 survival（thrash）**：釋放要 `days_left >= WARNING(3)`，重進要 `< WARNING(3)`，band 本身防抖；+ 引擎承諾慣性。world_sim 驗無高頻 survival↔trade 跳。
- **carry 空間 accessor 語意**：確認 `carry_space_for_res`/`remaining_carry_space` 對 food 回傳「還能裝多少」（WS-3 既有，plan 驗签名 + EPSILON 值）。
- **誤放真絕境隊**：真絕境 = 糧近 0 → `days_left < WARNING` → 新分支不觸發 → 安全。
- **goods 滿但糧也低（<3）**：food 空間≈0 但 days_left<3 → 不釋放（續 survival）→ 正確（真餓優先，即使攜不下也不放去貿易；此隊靠既有 survival 子行為自救）。

## 開放細節（plan 階段定）

- carry 空間 accessor 確切签名 + EPSILON（"攜滿"門檻，如 `<= 0.5`）。
- 是否需排除「站自家 outpost 的隊」走新分支（站 outpost 時 effective_food 已含糧倉，案 1 多半已釋放；新分支對它無害但冗餘）→ plan 定是否加 `own_granary_tile == null`（旅途）守衛收窄。
