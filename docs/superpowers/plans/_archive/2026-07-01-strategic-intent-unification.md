# Plan — 首燒：獨立/faction 戰略 intent 統一

> spec = `specs/2026-07-01-strategic-intent-unification-design.md`。分階,每階 headless+warring 驗不退化。
> 前置：`.\tools\godot.ps1 --headless --import` + headless 基準 PASS 記下。重型 seed `GODOT_TIMEOUT=2500` + bg。

## Task 1 — 泛化統一 scorer（TDD）
- `faction_ai_system.gd`：抽 `select_strategic_intent(state, team, ctx) -> {intent,target_id,why}`，菜單 `STRATEGIC_INTENTS={致富,擴張,征服,防衛,守成,建國}`，評分複用現 `_score_intents` 項（征服/致富/防衛/守成）+ 建國（現 `_evaluate_independent_strategy` found_score）。建國 gate=`faction_id==-1`。
- **測**：不同 leader values → argmax 對（好戰→征服、貪婪→致富、獨立+野心+累積→建國、敵強→守成）。
- **DoD**：統一 scorer 綠;faction `_select_intent` 改調它、行為不變（回歸）。

## Task 2 — 獨立隊接統一菜單（致富/征服錨接上）
- `_evaluate_independent_strategy` 改：先 `select_strategic_intent`（獨立隊得**全菜單**非截斷）→ 建國仍走 create_faction 升級;**致富→貿易 affordance / 征服→攻擊 affordance**（複用 unified team 貿易 option / 攻擊 dispatch）。
- `_emit_goal` 擴至獨立（intent 帶 why/driver，北極星 enforce）。
- **測**：獨立商隊(貪婪高)→致富 intent→貿易 winner;獨立好戰→征服 intent→攻擊。specimen_bed 復驗錨→行為接上。
- **DoD**：獨立隊致富/征服 intent fire 且驅動對應 action;守恆綠。

## Task 3 — 收 F-D3/D4/D6
- **F-D3**：`strategic_ai._update_faction_goals` 降 affordance dispatch（讀統一 intent，不自產 expand/defend）;擴張/防衛折入統一菜單。
- **F-D4**：solo_intent 統一 intent struct（type+why+mode），task 走 TaskArbiter，廢一槽兩義。
- **F-D6**：threat 併入（威脅→防衛/守成 intent）or un-stub DecisionContext.threat（擇一,測證 threat 真驅動非死）。
- **DoD**：單一 intent source;strategic_ai 不再第2 producer;threat 非死 stub;回歸綠。

## Task 4 — 活世界驗（不退化）
- warring seed（bg）：意圖分布 **CONQUER 不再恆 0、致富出現**、可解釋、viability（非病態全民開戰）;established rate 合理。
- **DoD**：意圖分布合理 + 錨→行為接上證 + 誠實標活世界 emergence 到不到。

## Task 5 — 守恆閘
- headless PASS≥基準、coin_eq 0、pop 守恆、InvariantAudit 0、無 GDScript 錯。北極星「凡 named 意圖必有可解釋驅動」holds（含獨立）。

## 不碰（scope + 並行 guard）
- 單寫者/tile/coin/roster（單寫者軌）、interaction resolver（BEG軌）、俘虜、player-dispatch。**只碰 faction_ai intent 函數 + strategic_ai + decision_context + team_data solo_intent**。

## 完成
- handback：統一 scorer 就位、獨立錨接上（致富/征服 fire）、F-D3/D4/D6 收、活世界意圖分布、誠實標 emergence。
- ⚠ 與單寫者/BEG 軌並行同觸 faction_ai 不同函數 → 系統 merge 順序解。
