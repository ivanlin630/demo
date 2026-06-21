# 商隊餓死修 — 角色正確化 + 返家補給迴路（履約脫 0 最後一哩，v2）

> 取代作廢的 `2026-06-21-caravan-survival-carry-aware-release-design.md`（根因算術錯，SUPERSEDED）。
> 真根經 measure-first probe trace 確認（非 carry cap、非釋放閾）。
> 承統一框架 arc：sub-project 1（商隊切片）+ A（生產隊納引擎）。本塊 = 補完**商隊**角色正確性 + caravan 迴路。藍圖序同意（survival 修在 B 前）+ believability 護欄（survival 優先序不洗平）。

## 病（measure-first 實測真根）

一次性 probe（`merchant_survival_probe`，已刪）trace 卡 survival 的商隊：

- **T1（有家商隊）**：被引擎派 **治理(GOVERN)** parked 在自家某 outpost（空糧倉，`effective_food`=carried only），carried 旅途糧緩耗（98→63→14…）→ 餓 → return_home。另一座自家糧倉有 1175 食卻吃不到（離家）。
- **根因**：引擎 `applicable()` 對有自家 outpost 的隊給 **駐守/生產 option**，**商隊也符合** → 商隊被派去治理/生產（定居者行為），park 在離有效糧處 → carried 耗盡 → 餓死。商隊缺「貿易途中糧低 → 回家補給」的迴路，只能等餓到 survival 才 return_home（慢、晚、易卡）。
- **對照**：`effective_food` 只在站自家糧倉 tile 才算糧倉（`own_granary_tile` 要 `tile_pos==outpost`，`resource_system.gd:345`）→ 旅途隊看不到家糧。

= 跟 carry cap（food weight=0.1，carry 裝 ~42 天）**無關**、跟釋放閾 7 天**無關**。是**引擎 option↔角色對映不對** + **缺補給迴路**。

部分卡 survival 的商隊（無自家 outpost 的流民商隊，trace 中 T6）= 真餓死，**正確擬真，非 bug**。

## 修：角色正確化 + 返家補給 Option（全在統一引擎內）

對稱 sub-project A（A 把**貿易**從生產隊拿掉）：本塊把**定居者 option 從商隊拿掉** + 加商隊補給迴路。**全在 `scripts/simulation/decision/`，不脫統一架構——是補完它。**

### 改 1：駐守/生產/建設 = 定居者專屬（商隊不選）
`options.gd applicable()` 守衛加 `and not ctx.is_merchant`：
- 駐守、生產：`has_own_outpost and not ctx.is_merchant`
- 建設：`not ctx.is_merchant`（商隊不蓋據點；建設仍給無 merchant 的生產隊 bootstrap）

→ 商隊候選只剩：貿易 / 覓食 / survival / **返家補給(新)**。商隊不再被派治理空據點餓死。

### 改 2：新 Option「返家補給」（caravan 迴路）
商隊貿易途中 carried 糧低 → 回自家糧倉 outpost 補 carried（WS-2d ration 在到家時自動補）→ 補滿再出門貿易。

```
Option「返家補給」
  applicable: ctx.is_merchant and ctx.food_days < RESTOCK_DAYS
              and ctx.has_home_outpost            ← 有可回的自家 outpost
  terms:      [["restock_need", "survival_pressure"]]   ← 糧越低權重越高(survival 權重複用,強)
  to_task:    TASK_RETURN_HOME, target = 自家 outpost(FactionAISystem._find_own_outpost)
```

- **新 term `restock_need`**：`eval = clampf((RESTOCK_DAYS - food_days)/RESTOCK_DAYS, 0, 1.5)`（糧越低越高）。權重複用 `survival_pressure`（1.0，人人怕餓）。
- **新 context 欄位 `has_home_outpost`**：`_find_own_outpost(state,team) != (-1,-1)`（不限站在上面；旅途也知有家可回）。注意與 `has_own_outpost`（站在上面才 true）區分。

### 迴路效果
```
商隊: 有貨→貿易 → carried 耗到 < RESTOCK_DAYS → 返家補給(回家outpost) →
      到家 effective_food 跳高 + ration 補 carried → food_days 高 → 返家補給退、貿易勝 → 再出門
```
proactive 補給（food_days < RESTOCK ~5）在**舊 survival 觸發(WARNING 3)之前** fire → 商隊在餓死前已回家 → **避開 survival latch**（不靠改 survival 系統）。

## 守 believability 護欄（藍圖）

- **survival 優先序不動**：URGENCY/WARNING 進入閾、`_trigger_survival`、`_evaluate_survival` 釋放邏輯**全不碰**。本塊只加引擎 option/守衛/term。
- **返家補給非 survival**：是 proactive 經濟行為（糧低於 RESTOCK 但未瀕餓就回家），不是危機反射。真瀕餓（< WARNING）仍走既有 survival（return_home/forage），該贏仍贏。
- **流民商隊（無家）仍餓**：`has_home_outpost=false` → 無返家補給候選 → 走 survival/覓食 = 正確（無家真絕境）。
- 驗收反例：無家商隊 / 真瀕餓商隊 → 不觸發「正常貿易」= 沒洗平。

## 範圍邊界 / 非本塊

- **舊 `_evaluate_survival` 不退役**（survival 兩 owner 技術債留著，屬框架完成塊）。
- 他域 option（攻擊/掠奪/結盟/徵收/立國/scout/鑄幣）+ consolidate = sub-project B。
- Pattern B 所有權 banker = 另子專案。
- effective_food 遠端支取/補給線 = 不做（破 locality 擬真）。
- 不碰 carry cap / PROVISION_DAYS / effective_food 語意 / 守恆。

## 驗收

- **履約脫 0（主目標）**：world_sim ≥1000 tick，`g1.order_fulfilled > 0`、`[Market]成交` 常態、`merchant_survival` 大降、商隊出現「貿易↔返家補給」迴路（trace 抽樣一支見 carried 週期回補、不再 drift 餓死）。
- **角色正確**：商隊不再 task=治理/生產（trace 無商隊 GOVERN/MANUFACTURE）。
- **believability**：無家商隊 / 瀕餓商隊仍走 survival（單測 + trace）。
- 回歸：TC1/4/6/7 + sub-project A 測 + 既有 survival/飢荒測全綠、headless 全綠、coin_eq=0、InvariantAudit 0。

## 檔案

- `scripts/simulation/decision/options.gd`：applicable 駐守/生產/建設 加 `not is_merchant`；REGISTRY 加「返家補給」row；to_task 加「返家補給」→ TASK_RETURN_HOME + `_find_own_outpost`。
- `scripts/simulation/decision/terms.gd`：eval 加 `restock_need`。
- `scripts/simulation/decision/decision_context.gd`：加 `has_home_outpost` 欄位 + gather。
- `scripts/debug/headless_test.gd`：新測（商隊糧低→返家補給 option / 商隊不選治理 / 無家商隊不選返家補給 / 補滿→貿易）。
- world_sim 驗收（trace 抽樣）。

## 風險 + 緩解

- **返家補給↔貿易 thrash**：proactive band [RESTOCK, 到家補滿] + 承諾 bonus 防抖。到家 food_days 跳高 → 返家補給退；RESTOCK 與貿易門檻分離。world_sim 驗無高頻跳。
- **與舊 survival 雙觸發**：返家補給(food<RESTOCK~5) 早於 survival(food<WARNING 3) → 多數情況先 proactive 回家、不進 survival。若仍跌破 3 → 舊 survival return_home 接手（同目的地）。兩者目的地一致、不互斥。技術債（兩 owner）留後續。
- **`has_home_outpost` vs `has_own_outpost` 混用**：明確分兩欄位（站在上面 vs 有家可回），測試各驗。
- **商隊無自家 outpost（純流動商隊）**：無返家補給候選 → 靠貿易/覓食/survival；若設計上商隊都該有家基地，world_sim 觀測無家商隊比例，異常回報藍圖（屬 world_gen 商隊配置，非本塊）。
- **不碰守恆**：只改決策面 + 新 term/option，return_home 移動與到家 ration 走既有守恆路徑。

## 開放細節（plan 階段定）

- `RESTOCK_DAYS` 初值（TEST VALUE，建議 5.0：> WARNING 3、< 典型 carried buffer ~8-10 天，留 proactive 空間）。
- `restock_need` eval 曲線是否要與 survival_pressure 區隔上限（避免壓過真 survival option）。
- 返家補給 to_task target 用 `_find_own_outpost`（最近自家 outpost；多 outpost 時是否選最近/糧最多，初版取首個/最近即可）。
- 商隊到家後 ration 是否需 plan 額外觸發點（現 WS-2d 在 `resolve_consumption` 後每輪於自家 outpost 補，到家即生效，預期無需改）。
