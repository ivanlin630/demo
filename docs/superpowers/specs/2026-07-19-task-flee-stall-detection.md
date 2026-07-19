# Spec：famine crisis-override（跨線危機 pre-empt 承諾；通用 stall-gap 安全網）

> **v2 泛化（blueprint 確認 2026-07-19，FLEE 專修太窄被 subsume）**：QA 坐实 seed1337 6 死 = 5 種 stuck-task（FLEE/等待新領主@10/建設@50/外交@70/併入@80-不resolve）卡住 famine 中無安全網。**核心校正：安全網 key on OUTCOME（famine 未緩解）非 task-TYPE（SURVIVAL_OPTION_SET）**。desperation 域，複用 ② relief-detection pattern 但泛化。**優先級 HIGH，平行 god-view E，須先於 D-後 doom-delta 讀（污染）**。

## 根（systems git 坐实 HEAD d0ab7f91）
- **committed 非-survival task 早退不 re-eval**：`faction_ai:386` `if team.current_task != TeamData.TASK_IDLE and not _busy_preemptible: return` → 隊 committed build@50/defection@10/diplo@70/FLEE（非 IDLE、非 preemptible）**早退**→ 不 re-rank → **survival 從沒被 dispatch @80** → 無 preempt（QA「survival_dispatch_would_succeed=true 卻沒 preempt」=根本沒嘗試 survival）→ 餓死。
- **② stall 只覆蓋 survival option**：`_detect_survival_stall`(`faction_ai:3452`) 只認 `survival_committed_option`（SURVIVAL_OPTION_SET，`_stamp_survival_commit:3430` gate）→ 非-survival task 不蓋章不 detect。FLEE(opt="survival")亦不在 set。
- ∴ **任何非-survival-committed task 卡住 + famine 爬 = 零安全網**。

## fix（HOW，OUTCOME-based crisis-override，blueprint 設計）
### 機制：跨線危機 → force preemptible → survival re-rank
- **OUTCOME 觸發（非 task-type）**：**深 famine（food_days < `CRISIS_FLOOR`）+ 未被緩解（committed N 天 food 沒回升 ≥RELIEF_MIN）** → **crisis-override fire**。
  - **★`CRISIS_FLOOR` = 自己的常數（R² Finding 3，decouple 非複用 SURVIVAL_BOOST_FLOOR）**：TEST VALUE（可略深於 boost-trigger 2.0，避 boost 平衡 tuning 誤動 crisis 敏感度=隱式耦合）。measurer 校。
- **force re-rank（破承諾，無硬例外）**：crisis fire → 令該隊 `_busy_preemptible = true`（或直接 release current task）→ 繞 `:386` 早退 → **re-eval → survival option @PRIO_SURVIVAL 80 競秤 rank → preempt 卡住的 task**。
- **★(B) survival 主宰，不特判 flee（blueprint 平衡裁 2026-07-19，撤回「flee 可贏」over-reach）**：re-rank 引擎競秤，**survival 主宰 threat**（守既有 `decision_engine:11` `THREAT_BOOST_MAX < SURVIVAL_BOOST_MAX` 故意設計不變量；深餓 survival 3.5 碾壓 flee 1.14）。∴ crisis 拉 stuck 隊（**含 valid-flee**）去 survival re-rank，survival 贏。**不特判 flee**（無硬例外=不 hard-exempt，秤結果 survival 主宰）。bug 修=invalid/stuck task → survival（餓極該吃>逃，逃也餓死，camping 至少有活機會）。
  - **★deferred 罕見角（blueprint flag，observe-first）**：valid-flee 逃**真威脅**的隊被 crisis 拉去 forage → 可能 camping 死於威脅 = **已知 nuance，非本 slice 修**。observe-first（真出現壞戲才 imminence/courage 化）→ 歸 **Arc5 死常數人格化**（[[project_unification_matrix]] 序5）。不過早優化。
- **track food baseline for ANY committed task**（泛化 ②）：committed 任何 task 時蓋 `task_committed_food` baseline + tick（現 `survival_committed_food` 只 survival option；泛化成任何 task，or 加平行 crisis-tracking）。relief 判定複用 ② pattern（baseline vs after-N-days + RELIEF_MIN）。

### 與 ② stall 互補（非取代）
- **crisis-override = 外層安全網**：任何 task 卡住 + 深餓未緩 → 拉回 survival rank。
- **② stall = 內層階梯**：已在 survival rank 內，當前 survival option 不 resolve → 換次 survival 格（progression）。
- 兩者組合：crisis-override 把 stuck 隊拉回 survival，② stall 管 survival 內進格。
- **★併入@80-不resolve = crisis-override 的安全網（R² Finding 2）**：併入是 survival option（在 set），② stall 該覆蓋——但 R² 坐实 ② **只在 try_set 成功時 re-stamp baseline**，併入被 host 拒-retry loop **不 re-stamp** → `survival_committed_option` 判定下 ② 不 fire。**crisis-override 涵蓋它**（OUTCOME=famine 未緩，不管 task 是否成功 dispatch → override）=併入-rejection 安全網。★② 那 gap（retry 不 re-stamp）另記 `known_issues`（非 crisis blocker，crisis 已覆）。

## 交付切片
- **S1 crisis-override**：任何 committed task food baseline 追蹤 + 深餓未緩偵測（複用 ② relief）→ force preemptible/release → survival re-rank。
- 行為變 → sim measure（**5 種 stuck-task 型不再卡餓死** + **量化「54% 逃跑真vs broken」**blueprint 要）→ QA 故事稽核（stuck→crisis→re-rank→survival or proper 窮死;真逃威脅的續逃=engine 秤對）→ blueprint release-pass → merge。

## 閘
- **R²**（premise code-坐实）：CRISIS_FLOOR/RELIEF_MIN/N 邊界、force-preemptible 不誤打斷正當 task（build 快完成/真逃威脅=engine 秤處理非硬例外，R² 驗 re-rank 真讓 threat 贏）、與 ② stall 不衝突/不雙重 release、baseline 追蹤泛化不破 determinism。
- **measure（sim seed1337/42/4201）→ QA → blueprint release-pass → merge**。**★先於 D-後 doom-delta 讀**（污染，blueprint）。
- **序：HIGH，平行 god-view E（orthogonal desperation vs god-view 位置域）**。

## 溯源
QA godview-F 泛化(5 stuck-task 坐实);blueprint OUTCOME-based crisis-override 確認(key on outcome 非 task-type,無硬例外 engine 秤);systems 坐实(:386 早退/② stall SURVIVAL_OPTION_SET-only/SURVIVAL_BOOST_FLOOR 危線);[[project_desperation_economy]] ② ladder;[[feedback-patch-gate-first]] 別打地鼠;複用 ② relief pattern。
