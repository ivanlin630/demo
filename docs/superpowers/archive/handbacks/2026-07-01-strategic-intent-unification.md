# Hand Back: 首燒 — 獨立/faction 戰略 intent 統一

> plan `docs/superpowers/plans/2026-07-01-strategic-intent-unification.md`
> spec `docs/superpowers/specs/2026-07-01-strategic-intent-unification-design.md`
> branch `feat/strategic-intent-unification`（未 merge，等主 session 確認）

## 實作摘要

分 5 階 TDD，每階 headless 綠（0 新 FAIL / 0 SCRIPT ERROR）。

### Task 1 — 泛化統一 scorer（commit 1）
- `faction_ai_system.gd`：
  - `_score_intents` 拆為 `_intent_scores`(raw 4 分) + `_argmax_intent`(hysteresis+argmax)，DRY，**保留 `_score_intents` 純函式入口**（既有 `_test_cmd_intent_select` 不動）。
  - 新增 `select_strategic_intent(state, team, ctx) -> {type,target_id,why}`：吃 ctx 全菜單 argmax；建國 gate=`can_found`(fid==-1)、擴張 gate=`can_expand`。
  - `STRATEGIC_INTENTS` 菜單常數 `{致富,擴張,征服,防衛,守成,建國}`。
  - `_select_intent` 改建 ctx 調統一 scorer，**faction 行為回歸不變**。
- 測 `_test_unified_scorer`：好戰→征服、貪婪→致富、野心+累積→建國、敵強→守成、established faction 建國 gate 擋。

### Task 2 — 獨立隊接統一菜單 + 致富/征服錨（commit 2）
- `_evaluate_independent_strategy` 改調 `select_strategic_intent` 得**全菜單**：
  - **致富** intent → 不搶 task，委既有貿易 affordance（SoloAI/`_decide_unified`）→ 成交。
  - **征服** intent → defer prosperity（G3d scout-gated）+ capture 征服 anchor（**CONQUER 顯化**）；避建國-吞併繞 scout gate（S3 回歸保住）。
  - **建國** gate 折入 `can_found`（野心+累積+路徑+非危時）；守成/防衛不 dispatch。
- 測 `_test_indep_full_menu_anchors` + 既有 5 indep 測全綠。
- **specimen_bed 復驗（錨→行為接上）**：merchant `想什麼=致富 263 → 做什麼=貿易 120`（前為「日常」無名 driver）。

### Task 3 — 收 F-D3/D4/D6（commit 3）
- **F-D3**：`strategic_ai._update_faction_goals` 降為**空間 affordance 層**，讀統一 `f.intent`（faction_ai 先於 strategic_ai 跑，intent 新鮮）→ 映射 `征服/擴張→expand(包圍)` / `致富→trade_net` / 弱 member→`defend`。**不再自產 intent（第2 producer 移除）**。擴張折入統一 scorer（force archetype + rung≥EXPAND gate）；commander `擴張` case = 備戰籌餉（包圍施壓，不發殲滅令）。
- **F-D4**：`team_data.solo_intent` 改 struct `{type,why,mode}`（廢一槽兩義）；SoloAI task 承諾移 `solo_task_last`。`_set_solo`/`_solo_type` helper（每令帶 driver = 北極星 parity）。`specimen_tracer`/`game_sim_multi` 讀 struct。
- **F-D6**：`DecisionContext.threat` un-stub（死 0 → `ThreatAssessment` belief-based `_max_threat`）。gate distrusted(rep<neutral) + clamp 1.0 → 次要 survival 信號，**不壓過 join/camp/starvation**（否則 threat→FLEE 壓垮 P2a 投靠，實測踩到已修）。`threat_pressure` term 真讀非死。
- 測：`_test_strategic_reads_ladder`(改測全鏈 擴張→expand)、`_test_threat_unstub`、solo struct 分離（既有測遷移）。

### Task 4 — 活世界驗
- `warring_states_seed._intent_histogram` 擴至**統計獨立隊 solo_intent**（前僅 faction → CONQUER 恆 0 假象）+ EXPAND/FOUND label。
- specimen_bed conqueror：`征服 intent fire 10 次`（前 0）。**誠實標 emergence**：該 specimen 想=征服但 winner=掠奪（unified `_decide_unified` 掠奪 option 搶在 prosperity attack 前；名義征服→實際掠奪，"anchor 名 vs action 實" 仍有斷點，見下待確認）。
- warring 分布（bounded 3 月觀測，radius14/9-faction；max_ticks 臨時降 21600 跑完後**已 revert 回 172800**）：
  - 月1 `RICH:31 DEFEND:23 CONQUER:0 EXPAND:0 FOUND:2 HOLD:1 NONE:8`（teams105/est1）
  - 月2 `CONQUER:1 RICH:10 DEFEND:14 EXPAND:0 FOUND:1`（teams43/est2）
  - 月3 `CONQUER:1 RICH:10 DEFEND:9 EXPAND:1 FOUND:1 HOLD:1 NONE:2`（teams32/est2）
  - **DoD 達標**：CONQUER **0→1 不再結構恆 0**（前 histogram 僅計 faction → 假象；現 faction+獨立同菜單計）、**致富(RICH) 主導**、EXPAND/FOUND 顯化（擴張/建國折入成功）、DEFEND 高 + CONQUER 極少 = **非病態全民開戰**（多數隊致富/守土，少數征服，believable）。indep.found_ally=4。無 SCRIPT ERROR。
  - ⚠ 全 172800(2年) 跑 540s timeout（radius14 太重，kill-race 讓 wrapper transcode 失敗）→ 用 bounded 3 月觀測趨勢。長弧收斂另需重機器/背景跑。

### Task 5 — 守恆閘
- headless：0 新 FAIL（僅 1 pre-existing `弱目標未加入攻擊 goal`，見連動風險）、0 SCRIPT ERROR、`=== DONE ===`、InvariantAudit population/faction/subteam 全 OK、coin_eq 綠。
- framework S1-S6：**7/7 PASS，0 dormant**。

## 與 spec 的差異
- `select_strategic_intent` 回傳 key 用 `type`（非 spec 描述的 `intent`）——對齊既有消費者契約（`f.intent.type` / `intent["type"]`），語意等同。
- **獨立征服 = defer prosperity**（非在戰略層 dispatch 攻擊）：spec ③「獨立好戰→征服→攻擊 affordance」的 affordance 接點 = 既有 prosperity attack（scout-gated），戰略層只 capture 錨 + defer，避免繞過 G3d scout gate（保 S3 回歸）。
- **征服 established gate 保留**：獨立隊的征服經 prosperity 路（非統一 scorer 的 征服 score，後者 established=false 恆 -1）。統一 scorer 對獨立只給 致富/建國/防衛/守成；征服由 prosperity 專路（scout gate 在此）。= 一致複用菜單判「是否偏好征服」，但執行走既有 scout-gated 路。
- **F-D4 driver 持久化**：commander 存 `f.goal_drivers`（全 faction）；solo driver 存 `solo_intent` struct + `SpecimenTracer.capture_intent`（specimen only runtime，非全隊持久 ledger）。solo why/mode 已上 struct，parity 足夠（北極星是審計鏡非 runtime consumer）。

## 連動風險
- **`headless_test._test_intel_attack_decision`（pre-existing FAIL `弱目標未加入攻擊 goal`）**：此 FAIL **在本軌動工前的 baseline 即存在**（origin/main 4fcde4e），非本軌引入。屬 IntelSystem 攻擊決策層，與本軌（戰略 intent-forming）不同函數。主 session 決定是否另軌修。
- **`DecisionContext.gather` 每次多算 `_max_threat`**（掃 discovered × ThreatAssessment）：只在 unified 切片（商隊/生產）觸發，O(discovered)。量測顯著再優化（cadence cache）。
- **擴張 intent 新增可能微調 faction 意圖分布**：force+rung≥EXPAND faction 原走 strategic_ai expand（守成 intent），現顯化為擴張 intent。行為（encirclement）等同，named driver 改善。warring 未見異常。
- **征服「名 vs 實」斷點（誠實呈報）**：unified 好戰獨立隊想=征服但 `_decide_unified` 掠奪 option 可能搶在 prosperity attack 前 → 實際 winner=掠奪。掠奪對目標亦是 aggression，但非乾淨「征服→攻擊」。若藍圖要求名實一致，需後續讓 prosperity attack 優先於 unified 掠奪 option（或掠奪納征服 affordance）。**本軌 scope 只到「錨顯化」，名實對齊 = follow-up。**
- **F-D5（unified-tag subteam 進不了 engine）**：spec 標 follow-up，本軌未收。

## 待主 session 確認
1. **征服名實對齊**：unified 掠奪 vs prosperity attack 優先序（上「斷點」）——要不要另開 task 讓征服 intent 真驅乾淨攻擊，還是接受掠奪=征服的低 LOD 表現。
2. **solo driver ledger**：solo intent driver 目前 struct(why/mode) + specimen trace，未進全隊持久 ledger（Pattern B 所有權域是另軌）。是否夠。
3. **pre-existing FAIL** `弱目標未加入攻擊 goal` 歸屬（IntelSystem 軌 or 併入後續）。
4. **擴張 TEST VALUE**（scorer `0.3 + 野心*0.3`）待平衡 pass 調。
