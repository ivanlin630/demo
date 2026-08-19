# perf/pipeline：loop1 faction 決策雙跑去重（tick-stamp）（HOW / systems）

status: DRAFT→R²（2026-08-20）
owner: systems（HOW）← blueprint 裁定 2026-08-20（方案 (c)、**WHAT 定性=接管語意上的事故非設計**、意圖語意=**每 faction 每 tick 決策一次**、修=**歸正非新設計**）
溯源：perf 線索包① → `near.faction_ai` 獨占 93.1% wall、`loop1.factions`+`loop1.assign_tasks` 合計 **37.8%** 相對占比 → measurer 指出 + **systems code-read 坐實**雙跑。

## §0 命門
- **★這是行為影響道**（perf 憲章）：faction 決策頻率 **2×/tick → 1×/tick** = **fp intended-change** + **全故事審**（憲章①「每改→full sim→Story QA 不降」）。
- **禁降 fidelity**：去重**不減決策深度/廣度**（每 faction 仍每 tick 決策、只是不重複跑第二次）——這正是「歸正」而非「降頻」：**降頻=行為影響道的另一種（每 N tick 才決策），本 slice 不做**。
- **零新旋鈕**：tick-stamp 是機制、非參數。
- **世界若顯著變樣 → Story QA 判、變壞回退重議**（blueprint 裁）。

## §1 現況（grounded、我 code-read 坐實）
- `_evaluate_all_body(state, _team_ids)`（`faction_ai_system.gd:712`）：參數 **`_team_ids` 底線前綴=刻意未用**；迴圈 `for fid in state.factions`=**全量 factions**。每 faction 依序跑 `member_snap`(BeliefSystem.best_estimate per member) → `_update_goals` → `_assign_tasks` → `_evaluate_infrastructure`(interval-gated `% INFRA_INTERVAL`) → `try_proactive_diplomacy`(interval-gated `% FACTION_UPDATE_INTERVAL`)。
- `sim_runner.gd:152`：`{"name":"faction_ai", ... **"lod": LOD_BOTH**, "shape":"teams"}` → near/far 各呼一次、loop1 全量掃、**LOD 近遠分流對 loop1 完全不生效**。
- **★★R² 訂正頻率 premise（我 code-read 漏、reviewer 追時序抓到）**：**far pass 不是每 tick 跑**——`sim_runner:284-289` `if current_tick % FAR_ZONE_INTERVAL == 0`（`:4` FAR_ZONE_INTERVAL=`10*TICKS_PER_HOUR`=**100 ticks**）→ **一般 faction 重評的雙跑只發生在 1% 的 tick**（99% tick 只有 near-pass 單跑）。原稿「每 tick 跑兩次」**不準、已訂正**（診斷方向與修法不受影響）。
- **★★但 interval-gated 三子行為=100% 必雙跑（結構性必然、非巧合）**：`FACTION_UPDATE_INTERVAL`(faction_ai:4)=**200**、`INFRA_INTERVAL`(:4186)=**500**、`BETRAY_CHECK_INTERVAL`(diplomatic_ai:4)=**500** — **三者皆 100 的整數倍** → 它們自己 cadence 觸發的那個 tick **必然同時滿足 `tick%100==0`**、far pass 必然也在跑 → **只要 infra/diplo/betray 有機會 fire，它就一定 fire 兩次**。
- **★★★且其中兩個是 RNG 雙擲（reviewer 逐行親證）**：`try_proactive_diplomacy`(diplomatic_ai:130) `randf() < caution³` 進場骰、`consider_betrayal`(:325) `randf() < margin×BETRAY_MARGIN_CHANCE` 邊際骰 → **雙跑=同一週期擲兩次獨立骰**、實際觸發率 ≈ `1−(1−p)²`（p 小時 ≈2p）→ **去重後回到 p = 外交主動提案/背叛觸發率「大略腰斬」**。`_evaluate_infrastructure` 無 RNG，但雙跑仍給「第二次嘗試機會」（far-only 步驟已跑過→資源狀態可能改變、第一次因門檻失敗者第二次可能成功）。
- **★語意澄清（reviewer (b)）**：「讀哪份 snapshot」與「決策頻率」是**兩回事**——去重不改後者（每 faction 每 tick 仍決策一次）、只在那 1% tick 讓遠區隊改用與其餘 99% tick **一致**的 context=**行為趨於一致非劣化**。
- 既有 instance 狀態先例：`_last_site_sig`/`_last_dispatch_fail`（instance 欄、sim_runner 持有穩定 instance）=**同款 bookkeeping pattern 可複用**。

## §2 Task（單一小 slice）
- **T1 tick-stamp 去重（方案 c）**：`FactionAISystem` 加 instance bookkeeping（如 `_loop1_done_tick: Dictionary`，`faction_id → tick`，比照既有 `_last_site_sig` pattern）；`_evaluate_all_body` 迴圈內**每 faction 先檢查**：`if _loop1_done_tick.get(fid, -1) == state.world.current_tick: continue`，處理後蓋章。
  - **語意=first-pass-wins**（同 tick 第二次呼叫全 skip）。
  - **★死團清理**：faction 消滅時清 stamp（or 用 `state.world.current_tick` 比對天然失效、無需清=**優先無需清的寫法**，避免新 leak 面）。
  - **determinism**：dict 只讀寫自身 tick 比對、無 RNG、iteration 序不變（仍 `for fid in state.factions`）。
- **★T2 TDD 方法論硬要求（R² 必查項③）**：**必須用同一個 `FactionAISystem` instance 模擬 near→far 兩次呼叫**（比照 production `_step6b_faction_ai` 真實呼法：同一 `_faction_ai_system.evaluate_all(...)`）；**禁**像 `scripts/debug/*.gd` 慣例每次 `FactionAISystem.new()` 起新實例——那樣 `_loop1_done_tick` 每次都是空 dict、dedup 永遠判「這 tick 沒做過」→ **測試看起來過但完全沒驗到（false green）**。
- **T2 驗雙跑消失**：`loop1.*` phase 計數/呼叫數對半（temp tap 或 TDD 計數）；infra/diplo 同 tick 只 fire 一次。

## §3 gate
1. **★fp intended-change**（預期會變、標注；**非 byte-identical**）。
2. **★全故事審（blueprint 硬要求）**：full sim + Story QA——**世界是否顯著變樣**（faction 目標/任務指派節奏、外交/基建頻率）；**變壞=回退重議**。
3. **regression**：headless 0-new、constitution 75 不回升、既有 slice（settlement/agri/labor/churn）不破。
3b. **★★具名頻率檢查（R² 必查項②、非泛化「全故事審」可代替）**——因為「世界表面沒變糟」但**外交/背叛長期節奏被腰斬是隱性的**：
   - **`proactive_diplomacy` 提案次數**（`_send_diplomacy_message` 呼叫數、全類型合計）前後對比、**跨足夠多個 200-tick 週期**（非單點抽樣）。
   - **`consider_betrayal` 真觸發次數**（`_execute_betrayal` 呼叫數）前後對比、**跨足夠多個 500-tick 週期**。
   - **幅度落在「腰斬量級」=預期正常非 regression 訊號**，但**要求 blueprint/QA 明確簽字**：新頻率仍支撐好故事（外交/背叛戲碼夠不夠常見），**非默默滑過**。
   - infra 升級/擴建次數順手記前後對比（次要、資源臨界情境比例通常小）。
4. **perf 實收**：`near.faction_ai` 占比 / per-tick 成本前後（期望 loop1 兩桶約省一半≈**19% 量級**、以 measurer ③ 順帶量到的雙跑實際份額為準）。
5. **fidelity 不降**（憲章③）：每 faction 仍**每 tick 決策一次**（非降頻）。

## §4 界外
`unified.rank`(17.5%)/`assign.leader_unified`(12.8%)/`gather.market`(6.7%) 等其餘熱點=後續刀（待 ③scaling 正式版 + hotspot 地圖）。降頻/deferred 類=行為影響道另議。

序：R² → CLEAN → 待 measurer ③ 量到雙跑份額 → dispatch → gate（含全故事審）→ merge。**修好後 blueprint 於 `mechanism-intents` 加 row「faction 決策=每 tick 一次」**（他 owner）。地基 KEEP。

## §5 R² 訂正摘要（2026-08-20、CLEAN+3 必查項）
①頻率 premise 訂正（1% tick 一般重評、非每 tick）→ **要求 dispatch 前與 measurer 對量測窗口**：37.8%/19% 期望值須來自**涵蓋多個 100-tick 週期**的窗口（單點抽樣若抽到 100 倍數 tick 會系統性高估）。
②★interval 對齊=100% 必雙跑 + RNG 雙擲 → 已收進 §3 gate 3b（具名頻率檢查 + blueprint/QA 簽字）。**★WHAT 意涵**：今日的 `1−(1−p)²` 是**事故產物**、歸正後 `p` 才是**設計者原本寫的值**——「腰斬」實為**回到設計值**；但世界是在雙擲下 tune 出來的 → **要不要補償性調 p 是 blueprint 的 WHAT tuning 決定、非 systems 自決**（且調 p 屬 tuning 非 crank：目標是回復既有故事密度、非讓某選項贏）。
③T2 TDD 同一 instance 硬要求（見 §2）。
