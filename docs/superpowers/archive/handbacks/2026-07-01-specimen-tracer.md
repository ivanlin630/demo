# Hand Back: 指標 specimen 決策 tracer

> spec = `specs/2026-07-01-specimen-tracer-design.md`、plan = `plans/2026-07-01-specimen-tracer.md`。
> 觀測 only、零行為變（唯一 cadence 變 = 指標團 LOD-exempt，刻意）。
> **交付含 measure 結論**（錨→行為斷點，見末段——這是藍圖要的答案）。

## 實作摘要

- `scripts/data/world_state.gd`：加 `var specimen_team_ids: Array[int] = []`（LOD-exempt + 詳捕 gate）。
- `scripts/debug/specimen_tracer.gd`（**新**，`class_name SpecimenTracer`，static，default `enabled=false`）：
  - `is_specimen/reset/capture_options/capture_intent/capture_decision/flush/dump/summary`。
  - `capture_options`：存本決策**全候選 {opt,util}**（decision_engine `scored[]` 現丟棄，唯一拿全 util 點）。
  - `capture_decision`：組完整 timeline entry（想什麼 intent+candidates+action-target belief / 做什麼 winner+task+target / 狀態 pop·food_private·food_granary·effective_food·consume_per_day·rung·faction·coin·material）。
  - 跨-flush 聚合 `winner_hist`/`intent_hist`/`decision_count` + `summary()`（供 measure 診斷）。
- `scripts/simulation/decision/decision_engine.gd`：`rank`/`rank_survival` sort 後加 `capture_options`（no-op-unless-specimen，零非-specimen 成本）。
- `scripts/simulation/faction_ai_system.gd`：
  - `_emit_goal` 加 `state` 參數 + `capture_intent`（commander goal → intent；10 caller 全補 state）。
  - `_evaluate_independent_strategy` 建國分支 `capture_intent`（solo 建國 intent）。
  - unified winner commit（`_decide_unified`）+ survival winner commit（`_trigger_survival`）加 `capture_decision`。
- `scripts/simulation/sim_runner.gd`：`_get_near_teams` specimen 一律納 near、`_get_far_teams` 排除 specimen（LOD-exempt，mirror player 豁免）；日邊界 `SpecimenTracer.flush()`（enabled 才印）。
- `scripts/debug/specimen_bed.gd`（**新**，measure 床）：merchant/conqueror specimen 指定 + 開 tracer + 跑 + 讀 timeline + 診斷印。env `SPECIMEN_MODE=merchant|conqueror|both`。
- `scripts/debug/headless_test.gd`：`_test_specimen_tracer`（全候選+intent+決策+狀態捕）、`_test_specimen_no_capture`（非 specimen / enabled=false 零捕）。

### 與 spec 的差異
- **無**功能差異。scope 內純觀測。
- dump 粒度：日邊界 flush（spec「傾向週期批」）；聚合 `summary()` 為 measure 加的（非 spec 明列，屬同類觀測）。
- **capture_decision 只 tap unified + survival winner commit**（plan Task 4 指定兩點）。commander/prosperity-attack/faction-goal-dispatch 的 TASK_ATTACK commit **不捕**（見連動風險）。

## 驗證

- `headless_test.gd`：`=== DONE ===`、0 SCRIPT ERROR、specimen 兩測綠、coin_eq 守恆 OK。
  - **1 FAIL = pre-existing baseline**（`[FAIL] 弱目標未加入攻擊 goal`，IntelSystem 攻擊決策測，與本 feature 無關；clean main 亦有）。
- `framework_validation.gd`：S1-S6 全 **PASS**、DORMANT=0。
- 模擬結果不變（tracer 零改決策；specimen LOD-exempt 僅該 1 團 cadence 變，刻意）。

## ★ Measure 結論（錨→行為斷點，藍圖要的答案）

### A. Merchant specimen（致富→交易；econ_bed Team2 商隊，25 天，263 決策）
```
想什麼(intent): { 日常: 263 }              ← 全 "日常"，零 named 致富 intent
做什麼(winner): { 貿易: 121, 覓食: 107, 買糧: 35 }
時序: 早期 100% 貿易 → 晚期 貿易~0，覓食/買糧 碾壓；末態 task=逃跑 coin=997 goods=80
```
**斷點 = 意圖層根本不存在 + 交易被食物生存吃掉**：
1. **無 named 致富 intent**：獨立商隊決策全走 DecisionEngine per-tick utility，標 `日常`。**commander/solo 皆無「致富」named intent** ——「致富錨」在隊層**不存在**（非 fire 沒，是壓根沒這個意圖節點）。交易純 emergent utility（貿易 option util 勝出），非錨驅動。
2. **交易不可持續**：早期貿易獨佔 → 隨食物壓力升，`覓食`(107)+`買糧`(35) util 反超 `貿易` → 商隊由「營利貿易」退化成「餬口採買」。致富**沒複利**（賺了 coin 卻轉去買糧/逃命）。
3. → **經濟真根修正藍圖假設**：不是「錨有名日常無實」，而是 **(a) 無致富錨可名**（致富非 named 意圖）+ **(b) 日常交易有實但被 survival 稀釋歸零**（食物收支迫商隊棄商）。R1 食物緩雖藍圖說緩，但**食物壓力正是掐死致富行為的直接手**（tracer 顯示 consume/覓食/買糧 擠掉貿易）。

### B. Conqueror specimen（征服→攻擊；warring Team18 野心0.98/好戰0.98，25 天，57 決策）
```
想什麼(intent): { 攻擊: 48, 日常: 9 }       ← "攻擊" = solo_intent task token（非 commander 征服）
做什麼(winner): { 掠奪: 54, 紮營: 3 }       ← 皆 survival-path option
候選示例: 掠奪=0.66 紮營=0.48 買糧=0.27（belief: prey pop_est=9）
Probe: faction_found=1, vendetta=1, indep_subjugate=0；末態 task=攻擊
```
**斷點 = 名義征服鏈未驅動，攻擊來自低層 survival-loot + 私仇**：
- **commander 征服 intent 全程未捕**（0 次）。這隻極端好戰隊的攻擊，**captured winner 全是 `掠奪`（survival-loot path）**——由**食物壓力**（候選 掠奪 vs 紮營 vs 買糧）+ **vendetta**（faction_found=1/vendetta=1）代打，**非** commander「征服X→攻擊X」means-end 協同鏈。
- **注意 scope 限制**：capture_decision 只 tap unified+survival，**prosperity-attack / faction-goal TASK_ATTACK commit 不捕** → 「做什麼」只顯 survival winner。故「commander 征服→攻擊」若真有，本 tracer 看不到那一段（見連動風險）。但 intent 面 commander 征服 0 次 = 該路徑至少在此窗未主導。

## 連動風險（主 session 決定是否補修）

- **軌 B（scaling-hardening）並行**：本軌同觸 `sim_runner`(_get_near_teams/_get_far_teams/日邊界)、`world_state`(欄位)、`faction_ai`(_emit_goal 簽名+winner commit)、`headless_test`(新測)——**不同函數/行**，但 merge 順序需系統收（plan 末已標）。`_emit_goal` 改簽名（加 state）是最可能撞點。
- **capture_decision 覆蓋不全（scope 缺口，非 bug）**：conqueror measure 揭露——攻擊 action 的真 commit（prosperity-attack `_evaluate_prosperity_attack`、faction-goal dispatch ~`:1090`）**不在 tap 點**。要完整 trace「征服 intent→攻擊 action」鏈，需增這兩點 capture_decision。**建議後續 task**（見下）。
- **無其他系統行為受影響**：tracer default off，capture 全 no-op-unless-specimen；LOD-exempt 僅影響 specimen 團自身 cadence（spec 明示接受）。

## 待主 session 確認

- **設計決策（實作中遇 spec 未覆蓋）**：
  - conqueror specimen 為獨立高野心隊時，其「intent」fallback 讀 `team.solo_intent`（task token，如「攻擊」），非 commander named intent。tracer 如實呈現；若要區分「commander 征服」vs「solo 攻擊 task」需 named-intent 專欄（暫夠診斷）。
- **建議後續 task**：
  1. **（econ 真根，高值）** 藍圖決策：致富要不要成 named 意圖？現商隊零致富錨、交易被食物碾。若要「致富驅動」須先給獨立商隊一個致富 intent 節點（commander-v2 只給 faction，獨立隊無）＝統一決策 arc 延伸。
  2. **（tracer 完整性）** capture_decision 增 tap prosperity-attack + faction-goal-dispatch commit → 完整 trace 征服→攻擊 action 段。
  3. **（food 已知連動）** merchant 交易退化成覓食/買糧 = R1 食物根的直接證據；藍圖雖緩 R1，但 tracer 證食物壓力是掐致富的手，排序時參考。
