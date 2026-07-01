# 首燒：獨立/faction 戰略 intent 統一 — 設計 spec

> 系統 HOW spec。承藍圖 `unification-matrix-program` 首燒 + `matrix-rulings`。統一矩陣 F-D1/D2/D3/D4/D5/D6/D7。
> **判準（藍圖判準）**：一領域一套機制、所有實體型插同一套、**實體型只決定 LOD/規模/細節非另起爐灶**。
> **目標**：戰略 intent-forming 統一成「**任何 leader 一套菜單**」。**帶出致富錨（獨立商隊）+ 征服錨（好戰獨立隊）一次解**（tracer 證前者不存在、warring 證後者 CONQUER=0）。**非再補獨立菜單**（第三次同型補丁 [[feedback_structural_audit_complement]]）。

## 現況（矩陣證，5 菜單 + 分岔）
- faction：`_score_intents`(670)+`_select_intent`(702) → 菜單{征服/致富/防衛/守成}(+立國 gate) → means-end(`_decompose_needs`/`_match_fillers`/`_emit_goal`)。
- 獨立：`_evaluate_independent_strategy`(883) → **截斷菜單{建國/守成}**(無致富/征服) → 建國分支 means-end(結盟/吞併)。
- 非統一 solo：`_evaluate_solo`(1290) → task-level scorer(第3條)。
- F-D3：`strategic_ai._update_faction_goals` 第2 producer(expand/defend/trade_net,擴張只在此)。
- F-D4：solo_intent 一槽兩義。F-D6：DecisionContext.threat=0.0 死 stub。

## 統一設計

### ① 一套 IntentMenu（任何 leader）
定義單一戰略意圖集 `STRATEGIC_INTENTS = {致富, 擴張, 征服, 防衛, 守成, 建國}`（合併 faction 的{征服/致富/防衛/守成/立國} + 獨立的{建國/守成} + strategic_ai 的擴張）。**任何有 leader 的隊**（faction leader / 獨立 team / 具 leader 的 unified team）都對同一菜單 argmax。

### ② 一個 scorer：`select_strategic_intent(state, team, ctx)`
泛化現 `_select_intent`/`_score_intents`：輸入 = leader values + 野心 rung(ambition_ladder) + belief(viability) + 規模 context。輸出 `{intent, target_id, why}`。
- 評分項複用既有：征服=野心·martial−honor + `_conquest_viable`(belief 敵力)；致富=greed·+ambition；防衛=caution·+honor；守成=base；擴張=rung≥EXPAND + pop；建國=獨立+野心+累積(現 `_evaluate_independent_strategy` found_score 邏輯)。
- **實體型只調 gate/scale 不改菜單**：建國 intent 僅 `faction_id==-1` 可選（已有 faction 的不重複建國）；其餘 intent 人人可選。

### ③ faction = 執行規模 context（非另菜單）
同一 intent，affordance 隨規模：
- **faction leader** 選征服/致富 → faction-scale：協調 members（現 `f.goals`→`faction_stakes`→member dispatch 不變）。
- **獨立 leader** 選征服/致富 → solo-scale：自身 affordance（攻擊/貿易），+ 若需規模則「建國」為 sub-goal（複用現 create_faction 升級路徑）。
- = 「獨立商隊選致富 → 驅動貿易 affordance（tracer 缺的錨接上）」「獨立好戰選征服 → 攻擊 affordance（CONQUER 錨接上）」。

### ④ means-end 統一（複用，不重造）
intent → `_decompose_needs` → `_match_fillers` → `_emit_goal`（faction 已有；**擴至獨立**：獨立 team 的 intent 也走同 decompose/emit，寫入統一 driver 結構）。

### ⑤ 收關聯 fork
- **F-D3**：`strategic_ai._update_faction_goals` 擴張/防衛折入統一菜單（intent=擴張/防衛）；strategic_ai 降為**空間 affordance 層**（encirclement/breakout/trade_net dispatch），**不再是第2 intent producer**。單一 intent source。
- **F-D4**：solo_intent 併入統一 intent 結構（intent.type + intent.why + mode），廢「task string 塞同槽」。task 該走 TaskArbiter。
- **F-D6**：threat 併入統一——威脅高→防衛/守成 intent（真驅動），廢 DecisionContext.threat 死 stub（或 un-stub 供 unified team survival；plan 定）。
- **F-D5**（unified-tag subteam 進不了 engine）：本 spec 不強收（subteam 走 `_evaluate_subteam`，戰略 intent 對 subteam 語意弱）；標 follow-up。

## believability / 不變量守恆
- **北極星「凡 named 意圖必有可解釋驅動」**：統一 scorer 每 intent 帶 why/driver（延續 commander-v2 enforce）。
- **不退化**：驗收=可解釋 + viability（非跟戰數，藍圖鐵律）。獨立商隊致富 intent → 真 fire 貿易（specimen tracer 復驗，錨→行為接上）。
- 守恆：coin_eq 0 / pop 守恆 / framework S1-S6 PASS / warring 意圖分布合理（CONQUER 不再恆 0、致富出現）。

## 檔案
- `faction_ai_system.gd`：`_score_intents`/`_select_intent` 泛化為 `select_strategic_intent`（任何 team）；`_evaluate_independent_strategy` 改調用統一 scorer（保建國 gate + create_faction 升級）；`_evaluate_solo` 戰略層改走統一（保 task-level 日常）；`_emit_goal` 擴至獨立。
- `strategic_ai_system.gd`：`_update_faction_goals` 降為 affordance dispatch，intent 不再自產（讀統一 intent）。
- `decision/decision_context.gd`：threat un-stub or 併入 intent（plan 定）。
- `team_data.gd`：solo_intent 語意統一（intent struct）。
- `scripts/debug/`：specimen_bed 復驗（獨立商隊致富 fire 貿易、好戰獨立征服 fire 攻擊）；warring seed 意圖分布。

## 風險 + 緩解
- **大改 faction_ai 決策核心**：分階（先泛化 scorer + 獨立接入，再收 F-D3/D4/D6），每階 headless + warring 驗不退化。
- **獨立隊突獲全菜單 → 行為劇變**（過度征服/交易）：TEST VALUE gate（野心/rung 門檻），warring seed 校，守 believability（稀有蓄意非全民開戰）。
- **與單寫者軌並行**：本軌碰 faction_ai intent 函數 + strategic_ai + decision_context；單寫者軌碰 resource/outpost/銀行 → 不同函數，merge 順序解（系統收）。**本軌不碰 tile/coin/roster 寫**。
- **scope**：只戰略 intent-forming 統一。**不碰**單寫者/俘虜/player-dispatch/互動 resolver（各自軌/後續）。

## 開放細節（plan 定）
- threat un-stub vs 併入 intent。
- 獨立「致富 intent → 貿易 affordance」的 affordance 接點（複用 unified team 貿易 option or 新 solo 貿易 affordance）。
- 擴張 intent 與現 rung EXPAND/建國 的關係（擴張=領土/pop、建國=立勢力，別重疊）。
- 分階 task 邊界。
