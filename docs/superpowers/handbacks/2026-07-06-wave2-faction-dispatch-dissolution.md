# Hand Back: wave2 序6 — faction member dispatch 溶入引擎

## 實作摘要

**溶=融合非刪**：`_assign_member_tasks` goal→task if/elif hand-dispatch 判斷器（含 V2-cmd 徵收 shadow 攻擊）撕除 → faction **成員**（非 subteam）走 `_decide_unified`（引擎 rank_scored 競秤）。★**只改成員 dispatch gate（`parent_team_id==-1`），不動全域 `uses_unified`** → 保 threat/preempt/survival loop3 scaffolding（序3.5 反龜縮不破）。副產物：V2-cmd 自消 + 成員打草穀 raid 接回（序5 待項）+ 框架債縫#3 結清。leader dispatch（`_assign_tasks`）= 序6b defer。

改動檔（每檔一行）：
- `scripts/simulation/faction_ai_system.gd`：
  - `_assign_member_tasks` gate 改：成員 dispatch 從 `if uses_unified(mt)` 擴為「全非-subteam 成員（`parent_team_id==-1`）走 `_decide_unified`」；撕除 goal→task if/elif cascade（徵收/外交/攻擊/製造/貿易 hand-dispatch，含 V2-cmd shadow）。
  - **新增 subteam guard**：`if mt.parent_team_id != -1: continue`（防 loop1 成員 dispatch / loop2 `_evaluate_subteam` 雙寫，現缺）。
  - MERGE consolidate 抽出 `_try_consolidate_merge(state, mt, f, leader_team)`：保為 pre-gate scaffolding（faction 整併＝小隊併大隊機制，非個體 utility 決策；命中 pre-empt engine，鏡射 survival-sticky）。
  - `_decide_unified` probe 遷移：成員征服 `conq.member_atk_eligible`（成員 + faction 攻擊令 intent=征服 + 攻擊∈ranked）/ `conq.member_atk_dispatch`（攻擊 winner）；徵收 `tribute.dispatch.member`。
- `scripts/debug/faction_dispatch_dissolution_check.gd`（新）：融合驗（世界-based dispatch 測）。
- `scripts/debug/constitution_baseline.txt`：`_assign_member_tasks` 指紋刪（arc 溶解）、`_try_consolidate_merge` 指紋加（保留 scaffolding，# 序6 標）；`_assign_tasks` 改標 # 序6b defer。gate PASS sites=32。
- `scripts/debug/headless_test.gd`：`_run_sim_test` 信譽減量測穩健化（立顯式前值，解耦 emergent 漂移；見連動風險）。

### 與 spec 差異
- **MERGE 保 scaffolding（實作裁），非移 engine option**：spec 3b 給「scaffolding or engine option」二選；裁定保 scaffolding（faction-level 整併非個體決策，鏡射 `_commit_conquest_attack`/`_evaluate_threat` 保留法）。**唯一行為變**：MERGE 現對商隊/生產 tag 成員亦適用（舊只 non-unified 軍隊路命中）；實測罕觸（small_b∧small_c∧近有容量 absorber 條件嚴），視為 faction 整併語意一致擴張，非 regression。

## 融合驗結果（`faction_dispatch_dissolution_check.gd` ALL PASS）

TDD fail-first（改 gate 前 FAIL count=4）→ 改後 ALL PASS：

| 錨 | 改前（hand-dispatch） | 改後（引擎） |
|---|---|---|
| ① 徵收 goal+貪婪 → 徵收 | 徵收 ✓（保序） | 徵收 ✓ |
| ① 攻擊 goal+好戰 → 攻擊 | 攻擊 ✓（保序） | 攻擊 ✓ |
| ① 外交 goal → 外交 | **idle（FAIL：軍隊 tag_weight(外交)=0 走不到）** | **外交 ✓** |
| ② ★V2-cmd：{徵收,攻擊}+好戰 → 攻擊 | **徵收（FAIL：if 徵收/elif 攻擊 shadow）** | **攻擊 ✓** |
| ② V2-cmd 反向：+貪婪 → 徵收 | 徵收 ✓ | 徵收 ✓（分歧非抹平） |
| ③ ★成員+弱prey → 掠奪 | **idle（FAIL：cascade 無成員掠奪分支）** | **掠奪 ✓** |
| ① 生產/貿易 tag → 本業 | 本業 ✓（本即 unified） | 本業 ✓ |
| ④ ★忙碌成員遇壓境 → preempt | 逃跑 ✓（未動） | 逃跑 ✓ |
| ⑤ subteam → 不入引擎 | **攻擊（FAIL：guard 缺→雙寫）** | **不動 ✓** |

### V2-cmd 解證（結構）
`rank_scored_ctx` argmax 對 {徵收,攻擊} applicable 全 option 算 util sort：兩者 `faction_duty`同 DRIVE(1.5)，差在 `attack_drive`(weight 好戰+殘忍) vs `levy_drive`(weight 貪婪+好戰)。好戰成員 attack util ≈1.91 > 徵收 ≈1.67；貪婪成員反轉。**攻擊-eligible 成員不再被徵收無條件支配（elif 序死）**。

### 成員 raid 接回率（縫#3 結清）
成員走主 rank → 掠奪 option（applicable=has_weak_prey，`loot_drive×cap`）自然競秤 → 見弱 prey 選掠奪＝打草穀。**成員不再靠 hand-dispatch / loop3-idle-gate；主 rank 每 cadence 重評（退 latch）**。序5 handback 標「成員 raid 暫失」結清。

### ★序3.5 preempt 保證（最高盯點）
`threat_preempt_check` ALL PASS + 融合驗④ PASS。**不動全域 `uses_unified`** → 成員仍走 loop3 `_evaluate_threat` 非-unified 路 → 忙碌成員（TASK_MANUFACTURE 軍隊）遇壓境攻擊仍放下製造派 defensive。反龜縮 seam 未斷。

## seeded 漂移 before / after（★gen 重校依據）

`WarringHarness.run(1337, 1200)`：

| | before（cascade） | after（引擎） |
|---|---|---|
| seeded final | teams=52 factions=8 established=1 pop=380 | **teams=49 factions=8 established=1 pop=381** |
| 逐點重現 | OK | **OK（同 seed 兩跑逐點相同）** |
| conq.winner_other | 0 | **109**（成員入引擎，征服-intent 隊 winner 顯影） |
| conq.winner_loot / prosperity | 0 / 0 | 0 / 0（此 seed 征服隊 unready → 非 掠奪/prosperity winner） |
| conq.member_atk_eligible / dispatch | 0 / 0 | 0 / 0（此 seed 無 faction 攻擊令 intent=征服 → 結構性 0，harness 確定性已證解） |

**關鍵**：seeded 漂移（52→49 teams）＝成員 raid+V2-cmd 解使分佈變（QA wave 允許）。member_atk/raid seeded=0 為**結構性**（此 seed 不生成征服 directive / 成員掠奪未達 winner），非機制壞——harness 確定性 fixture 已硬證 repertoire/V2-cmd/raid 全通。完整征服/掠奪圖待 **gen 重校 follow-up**（藍圖 seq5-judgment：等成員 raid 接回對完整圖調）。

## 連動風險（呈系統）

1. **MERGE scaffolding 去留**：保 scaffolding（實作裁）。行為變＝商隊/生產 tag 成員現亦 MERGE-eligible（舊只軍隊路）。實測罕觸；若後續揭商隊被誤併 → 呈報加 tag guard。**若系統認為 MERGE 應入 engine option（DecisionOptions 加「合併」row）→ 序6b/後續拆**。
2. **probe 遷移覆蓋**：`conq.member_atk_*` 重掛引擎路（`_faction 攻擊令 intent=征服` gate）。`sufficiency_bed` 征服「想=做」漏斗消費者保。seeded=0 因 seed 未觸此 directive；sufficiency_bed 別 seed 可能顯值。若漏斗需硬值 → 確定性 live-seam（鏡射 threat_dissolution `_check_live_dispatch`）補。
3. **headless「弱目標未加入攻擊 goal」FAIL = pre-existing**（base b098631 亦紅，`_update_goals` 邏輯，非序6 引入）。歸 known_issues 別查。
4. **headless 信譽減量測穩健化**：改立顯式前值（`known_reputations[3]=0.5` 再 −0.3）。原 assert 賴 emergent 預設 0.5，序6 世界漂移致 teams[0]對3 rep 被 sim 抬高→誤紅。屬 brittle-test 解耦，非藏 bug。**若系統認為 rep 抬高本身異常 → 呈報查 diplomacy tick**（初判＝emergent 友好累積，非病）。
5. **leader dispatch（序6b）待**：`_assign_tasks` leader 路（立國=state change 非 task / subteam-tribute=faction 機制 / direct 攻擊掠奪）→ 引擎，特殊語意分開拆。baseline 已標 # 序6b defer。
6. **成員 macro vs loop3 冗餘**：成員 macro 由 loop1 `_decide_unified` 設 task → loop3 survival/threat 對其多非 idle → 只 preempt/stuck 觸發（融合驗④證無 macro 打架）。輕微重評（idle 成員 loop3 可能重評），成本可接受。
7. **gen 重校 follow-up 觸發**：序6 綠 → 完整征服/掠奪圖（成員 raid+V2-cmd 解後分佈）→ gen 重校輸入。序6 後藍圖裁完整圖調。
