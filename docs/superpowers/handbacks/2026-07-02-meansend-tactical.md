# Hand Back: means-end 接戰術層（intent_fit 第一增量）

> plan = `plans/2026-07-01-meansend-tactical.md`；spec = `specs/2026-07-01-meansend-tactical-design.md`。
> branch = `feat/meansend-tactical`（未 merge，等系統 session 確認）。

## 實作摘要

一句話：把「team 自己戰略 intent」注入戰術 `DecisionContext`，複製 `faction_duty` 先例做新 `intent_fit` term，讓意圖→子需求 reshape 戰術 option util。修斷點「獨立隊 solo_intent reshape 零」。

改的檔案（每檔一行）：
- `scripts/simulation/decision/decision_context.gd`：`gather` 尾注入 `intent`（獨立=`solo_intent.type` / faction leader=`f.intent.type`；member 已由 faction_stakes 供訊號→不重覆）+ `intent_target`/`intent_target_pos`（征服帶 target，獨立 fallback weak_prey）。新 3 欄位。
- `scripts/simulation/decision/terms.gd`：新 `intent_fit` term + `_intent_fit(ctx,opt)` helper（致富+餘糧→貿易/囤貨、征服→攻擊、匱乏+野心/好戰→掠奪；人格染 baked in eval，`weight("intent_fit")=1.0`）。新 3 常數（`INTENT_FIT_DRIVE`/`SURPLUS_FOOD_DAYS`/`SCARCITY_RAID_MIN`，全 TEST VALUE，mirror `FACTION_DUTY_DRIVE`）。
- `scripts/simulation/decision/options.gd`：貿易/掠奪/攻擊 掛 `intent_fit` term；新 `囤貨` option（致富 accumulate，複用 `TASK_TRADE`→市集 hub）；`攻擊` applicable 對征服 intent 開（非只 faction_stakes）。
- `scripts/simulation/faction_ai_system.gd`：`_decide_unified` 內 — 征服 intent 驅動的 `攻擊` winner → route 到 scout-gated `_evaluate_prosperity_attack`（消粗 `_nearest_independent` 直取），faction directive 攻擊維持既有指定 target 路徑。
- `scripts/debug/headless_test.gd`：3 新單測（`_test_intent_fit_term` / `_test_intent_fit_gather_and_options` / `_test_intent_fit_enrich_beats_build`）+ 註冊。

與 spec/plan 差異：
- **囤貨 option** 未新增 stockpile task，複用 `TASK_TRADE`→市集 hub（spec「複用貿易 barter or 新 task」的前者，避新機制擴守恆面）。
- **匱乏→搶** 只 boost `掠奪`（已 applicable），**不**開全面 `攻擊`（防 over-war 升級），比 spec 表「掠奪/攻擊」保守。

## 四關結果（誠實標）

| 關 | 結果 | 證據 |
|---|---|---|
| ① 真變好戲 | **部分** | merchant specimen 想=致富 263→做=貿易 263（**100%**，症狀 a 解）。conqueror specimen 想=征服 88→做=掠奪 88（**見下**）。|
| ② 跑得動 | **PASS** | scaling_bed evaluate_all N=100/200/400 = 337/711/1440ms，與既有 hostile-within O(N²) 同型（intent_fit=O(options) 可忽略）。|
| ③ 看得懂 | **PASS** | specimen tracer 顯 intent→candidates util→winner，reshape 可 trace。|
| ④ 還在賺 | **部分** | 交易網 fire（merchant 貿易 100%）；征服→prosperity 路由 **6.6×**（見下）；不 mass-starve/不全滅；over-war 落 unseeded 噪內；**capture 轉化未升**（見下）。|

### 症狀 a（致富→貿易/囤貨）— 解
- 單測：致富商隊 貿易=2.08 / 囤貨=1.27 > 建設=0.20（前 spec 記 0.79>0.26 建設碾貿易，現反轉）。
- merchant specimen bed：263/263 決策 想=致富→做=貿易，鏈 100% 通。

### 症狀 b（征服→攻擊統一）— 機制成，flagship 受食物 gate
conquest_measure（warring 14400 tick，**unseeded=drift 噪**，見 [[reference_multi_sanity_unseeded]]）baseline vs 本 branch：

| metric | baseline | branch |
|---|---|---|
| conq.winner_loot | 0 | 0 |
| conq.winner_prosperity | 13 | **86**（6.6×）|
| conq.intent | 39 | 94 |
| capture.total | 3 | 1 |
| teams 月0→月2 | 102→76 | 101→72 |

- **winner_loot=0 兩者皆是** → 此 bed baseline 無「掠奪 hijack 征服」（該冒煙槍在此 seed 未重現，或前工已收）。
- **intent_fit 讓征服→prosperity 攻擊路由 6.6×**（13→86）：`攻擊` 成 scored option + 征服路由到 scout-gated → 更多征服 intent 真驅乾淨攻擊鏈。
- **capture 轉化未升**（3→1，噪級小數）：路由對，但 scout→打垮→**吞併完成** 深度仍低 = combat/subjugate 完成率問題（pre-existing，本增量 scope 外）。**plan「轉化率升」未達**，誠實記。
- **conqueror specimen（Team18, 野心/好戰 0.98, 獨立）**：想=征服 但做=掠奪 88 — 因 **food_days≈3.0 慢性缺糧**→走 survival loot 路徑（`_evaluate_survival`/rank_survival），非決策層 name-deed 斷。= 食物經濟/survival-sticky 把 flagship 困在覓食級，餵不飽故發不出乾淨征服。**這是 emergence（餓 conqueror 靠搶續命）非 bug，但也顯食物軌張力壓過戰略層**。

### 症狀 c（匱乏→搶）— gated，防 over-war
- 單測：匱乏+野心 0.8+prey → 掠奪 intent_fit>0；匱乏+溫和(野心/好戰 0.2) → 掠奪 intent_fit=0（不全民搶）。
- over-war：branch attrition 29% vs baseline 25%（4pp，落 unseeded 噪內）；teams 不→0，無全滅。**未見明確 over-war**，但無 seeded 對照無法斷定 4pp 是訊號還是噪。

## 守恆閘（Task 6）— 全綠
- headless：`=== DONE ===`、無 SCRIPT ERROR；3 新單測綠。
- coin_eq 全池 200-tick delta=0.00。
- framework S1-S6 = **7/7 PASS**（無新 DORMANT）。
- InvariantAudit population/faction/subteam/roster 全 OK。
- 北極星：intent_fit 每 boost 帶 driver（連回 ctx.intent 子需求），無無因令。
- **既有 stale [FAIL]「弱目標未加入攻擊 goal」**：baseline 已存在（commander-v1 舊式測，非我引入），soft print 非 assert，DONE 照印。未動。

## 連動風險（主 session 決定是否補修）

- **單寫者 slice3 並行**：本軌碰 `faction_ai._decide_unified`（新增征服路由 branch）；slice3 碰 leader 指派/combat_target/banks。**同檔不同函數**，merge 序解（plan 已預告）。`_decide_unified` 的 branch 只讀 `_solo_type`/`_is_prosperity_candidate`，不寫 combat_target（交給 `_evaluate_prosperity_attack`）。
- **`faction_ai`：** `_decide_unified` 征服路由對 non-prosperity-candidate 用 `continue`（試次佳），不落回粗攻擊 → 理論上某些 uses_unified 征服隊本 tick 可能不派攻擊（等次佳 option）。measure 未見凍結（winner_none=0）。
- **食物軌 × 戰略層**：conqueror specimen 顯食物 survival 壓過征服意圖。若藍圖要 flagship conqueror 真打乾淨征服，需食物經濟側（餵得起擴張）或 survival-entry gate 對高野心放寬 — **跨軌，非本增量**。
- **囤貨 option**：複用 `TASK_TRADE`→市集，與 `貿易` 同 task 不同 target；到場履約走既有 interaction trade，無新守恆面。若市集/arb 皆無則退 `_merchant_trade_target`。

## 待主 session 確認

1. **capture 轉化未升**（症狀 b plan 目標）：路由已對（prosperity 6.6×），但 scout→吞併完成深度低。是否開後續 task 攻 capture 完成率（combat/subjugate depth）？= 移動標靶下一步。
2. **conqueror 食物 survival-trap**：flagship 高野心獨立隊被 food_days≈3 困在 survival-loot。是否屬「餓則搶」正確 emergence（收），還是要戰略層對高野心鬆 survival gate（另議，跨食物軌）？
3. **over-war 4pp** 落 unseeded 噪：若要硬證「不 over-war」，需 seeded warring 對照 harness（現 conquest_measure 用 warring config 無 seed）。建議系統決定是否值得建 seeded 回歸閘。
4. **TEST VALUE 校**：`INTENT_FIT_DRIVE=1.5`/`SURPLUS_FOOD_DAYS=7`/`SCARCITY_RAID_MIN=0.55` 全 TEST VALUE，正式平衡 pass 調。
5. **wrapper 360s 硬 timeout**：full warring（172800 tick, 2yr）跑不完 → 全窗 warring 驗收本 session 無法做，改用 conquest_measure（warring config capped 14400 tick）當代理窗。若要全窗需調 `GODOT_TIMEOUT` 或分段。
