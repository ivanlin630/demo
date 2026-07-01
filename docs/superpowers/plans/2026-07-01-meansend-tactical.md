# Plan — means-end 接戰術層（第一增量,守四關）

> spec = `specs/2026-07-01-meansend-tactical-design.md`。分階,每階 headless + bed。四關驗收。
> 前置：headless 基準 PASS + coin_eq(全池)0 + framework 7/7 記下。specimen_bed baseline（商隊 winner 分布）記下。

## Task 1 — inject intent 進 DecisionContext + intent_fit term 機制（TDD）
- `decision_context.gd:104-122`：ctx 加 `intent`（獨立=solo_intent.type / faction leader=f.intent.type / member 已有 faction_stakes）+ intent target。獨立隊改由 intent 供 tactical 訊號。
- `terms.gd`：新 `intent_fit` term（intent→子需求→option 貢獻打分）+ 常數（TEST VALUE,mirror FACTION_DUTY_DRIVE）。人格適性染色。
- **測**：ctx 帶 intent;intent_fit 對 intent-match option 加分、非 match 不加;非 specimen 零影響。
- **DoD**：intent 進 ctx、intent_fit 機制綠、faction 行為回歸不變。

## Task 2 — 致富→貿易/囤貨（症狀 a：建設碾貿易）
- intent_fit：致富+餘糧 → 貿易 boost + 新 `囤貨` option（REGISTRY，蓋倉/存貨,affordance=致富+市集/arb 潛力）。
- **測**：致富商隊 貿易/囤貨 util > 建設（前 0.26<0.79）。
- **bed（四關①③）**：specimen 商隊 想=致富→winner=貿易/囤貨（非建設從不貿易）。
- **DoD**：致富驅動貿易/囤貨、specimen trace 顯 reshape、交易網 fire。

## Task 3 — 征服→攻擊統一路徑（症狀 b：攻擊分裂）
- 征服 intent → `攻擊` option（scored via intent_fit,applicable 對征服 intent 開非只 faction_stakes）→ **route scout-gated prosperity/subjugate**（消舊 `_nearest_independent` 粗攻擊 + _decide_unified 外分離 gate）。
- **測**：征服隊 攻擊 winner → 導 prosperity/subjugate（非粗攻擊）;capture 轉化。
- **bed**：conquest_measure 復跑——征服 intent→攻擊→capture 轉化率升（前 243→1）。
- **DoD**：兩條攻擊路徑消、征服真驅乾淨攻擊→capture。

## Task 4 — 匱乏→搶（症狀 c：匱乏壓平→匱乏驅動侵略）
- intent_fit：低 food_days + 野心/貪婪 → 「弄到資源」子需求 → 掠奪/攻擊 boost。**gate**（野心/好戰門檻 + 稀有）防 over-war。
- **測**：窮+野心隊 → 掠奪/攻擊（非只 flee/beg）;窮+溫和隊 → 仍 survival（不全民搶）。
- **bed（四關④）**：warring 匱乏隊搶（CONQUER/掠奪起）但**不 over-war**（非全民劫掠潮）。
- **DoD**：匱乏變侵略驅力、自平衡（富貿易/窮搶）、不 over-war。

## Task 5 — 四關驗 + 活世界
- **四關**：①specimen trace 規劃像（三症狀）②scaling_bed tick-time 沒爆（intent_fit O(options)）③trace 可讀 ④warring:交易網轉+CONQUER 起(>0 轉 capture)+不 mass-starve+不 over-war;邊際遞減標。
- warring 全窗（bg,長 timeout）：CONQUER 起、established 起、不 mass-starve、不 over-war。
- **DoD**：四關過 + 誠實標 emergence（三症狀解到哪 + 移動標靶有無自平衡）。

## Task 6 — 守恆閘
- headless PASS≥基準、coin_eq(全池)0、pop 守恆、framework S1-S6 PASS、InvariantAudit 0、北極星 holds（intent_fit boost 帶 driver）。

## 不碰（scope + 並行 guard）
- 防衛/守成/建國/擴張 intent uplift（後增量）、完整 planner、tile-bank/combat_target chokepoint（單寫者軌）、單寫者 ledger。**只碰 decision/*（context/terms/options）+ faction_ai(_decide_unified/征服 route)+ team_data(若需)+ bed**。

## 完成
- handback：intent_fit 機制 + 三症狀解（致富→貿易/征服→capture/匱乏→搶）+ 四關結果 + **誠實標**移動標靶自平衡到不到 + emergence（CONQUER/交易網）。
- ⚠ 與單寫者 slice3 並行同觸 faction_ai 不同函數 → 系統 merge 序解。
