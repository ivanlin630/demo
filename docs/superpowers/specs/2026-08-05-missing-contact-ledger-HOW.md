# 失聯帳本 — HOW（systems，實作設計）

status: DRAFT → reviewer R²
owner: systems（HOW）；WHAT=`2026-08-05-missing-contact-ledger-design.md`（blueprint LOCKED、R① CLEAN）
date: 2026-08-05
branch: 新 slice `feat/missing-contact-ledger`（off 更新後 main，含核心 arc merge）

## 目標（承 WHAT）
所有派出單位共用一張「預期聯絡帳本」——逾時→belief 標失聯→思考層人格反應。**通例統一非特例**（禁散建），**reuse 既有 last_tick 原語、母↔子收斂一套**（R① 整併義務、防第 4 散落點）。

## Seam（親驗 file:line、2026-08-05 merged main）
- 既有**反方向（子→母）**：`faction_ai:4651 _evaluate_owner_contact`（resident 感領主失聯）——原語＝`BeliefSystem.best_estimate(state, team_id, owner_id).last_tick`（:4658-4659）+ elapsed days（:4662）+ `CONTACT_TIMEOUT_DAYS` 硬門檻（:4663）→ `_trigger_defection_evaluation`（:4620、人格 path A/B/C 已在）。呼點 `:843`。
- **派出單位**：herald=`state.in_transit_letters`（非 team、arc 新建、有 origin team）；scout/subteam=team（`best_estimate` 可追）；convoy=`_dispatch_convoy`（distribute/trade）。
- **10+ 散落 timeout 死常數**（R① 揭）：FOUNDING/TRADE/STATION/SCOUT/FLEE/CONTACT/CONSTRUCT_TRANSIT/letter timeout/envoy recall…**全子單位側自我到期、非母隊側帳本**＝統一標的清單（本批建帳本統一「母→子失聯感知」；各常數本身 de-const=照妖鏡 faction-balance 批）。

## 設計（三塊）

### 塊①：共享失聯原語（整併義務核心、防第 4 散落點）
新 `_contact_elapsed_days(state, observer_id, subject) -> int`（faction_ai helper）：
- `subject` 是 **team_id**（scout/subteam/convoy-team）→ elapsed = `(current_tick − best_estimate(observer, subject).last_tick)/TICKS_PER_DAY`（last_tick=-1→未接觸、回 -1）。**＝reuse `_evaluate_owner_contact` 同原語**。
- `subject` 是 **非-team dispatch（letter）**→ elapsed = `(current_tick − dispatched_tick)/TICKS_PER_DAY`（自我 dispatch-log，letter 無 belief entry；界＝WHAT「自我記憶 own dispatch log+elapsed」）。
- **★重構 `_evaluate_owner_contact:4662` 改呼此 helper**（子→母 也走共享原語）→ 雙方向**一套失聯感知**。其 `CONTACT_TIMEOUT_DAYS` 硬門檻**本批不動**（照妖鏡 faction-balance 批、blueprint 定）——本批只收斂 detection 原語、不 de-const 既有反向 threshold。

### 塊②：帳本結構 + 記帳（母→子正向）
`TeamData.dispatch_ledger: Array[Dictionary]`（新欄、空初始）。每筆 detach 記：
```
{ kind:"herald|scout|convoy|subteam", subject_ref:<team_id 或 letter_id>,
  is_team:<bool>, dispatched_tick:int, expected_return_tick:int, resolved:bool }
```
- **記帳點**：`_try_herald_side`/`_try_scout_side`/`_dispatch_convoy`/subteam dispatch 各 spawn 後 append 一筆（既有 dispatch 路加一行、非新機制）。
- **`expected_return_tick` = 機械估**（估算是物理、允許公式、WHAT界）：`dispatched_tick + round_trip_estimate(hex_dist(母,target)/移速 × 2 + task_service_ticks)`。**純機械、零人格**（人格只在反應端）。
- **清帳**：單位回歸/交付確認（letter deliver、subteam 回、convoy settle）→ `resolved=true`（或移除）。belief 更新。

### 塊③：逾時偵測 + 人格反應（思考層、side-action 家族）
母隊 cadence step（新 `_step_contact_ledger`，或掛既有 faction_ai cadence）掃 `dispatch_ledger` 未 resolved 筆：
- `overdue_ratio = _contact_elapsed_days(...) / expected_days`（**逾時程度、連續值**，非布林門檻）。
- `overdue_ratio > ~1.0` → 標 belief「失聯」（`team_belief` 加 lost flag、**零 god-view：只知逾時、不知對方真死活**）。
- **反應 = 人格 mini-util**（★人格非死常數、逾時程度進 mini-util）：
  - `react_util(kind) = overdue_ratio × 人格加權`——務實(責任)→再派 herald/scout side-dispatch（接既有 `_try_herald_side`/`_try_scout_side`、**不新建動詞**）；多疑(慎重高)→防禦準備 belief；重情(義氣高)→標救援意圖(flag、本批不建救援隊動詞)；冷酷/野心→註銷(resolved=true 當沒了)。
  - **禁「逾時 X tick 必派」死常數**——逾時 ratio × 人格權重秤、argmax/throttle 同 side-action 家族。
- **失聯單位真相**：死了不通知（沉默即資訊）；活著回→帳本清、belief 更新（既有交付/回歸 hook）。

## 守（憲法/感知鐵律）
- **零 god-view**：帳本＝自我 dispatch-log + elapsed（own memory）；team-subject 走 belief `best_estimate.last_tick`（既有 provenance）；**禁查對方 live 死活/位置真值**。失聯 belief 不含對方真實狀態（只含「我多久沒消息」）。constitution gate 綠。
- **通例統一非特例**：一個帳本 + 一個共享原語 `_contact_elapsed_days`（母↔子收斂）；反應 reuse 既有 side-action 動詞（herald/scout）——不散建「信使一套/子隊一套」。
- **人格非死常數**：反應傾向=mini-util 人格加權；逾時程度連續進 util、禁硬門檻必派。
- **反應走既有機制**：再派/去查=既有 side-action（herald/scout side-dispatch）；「救援隊」新動詞**不在本批**（若人格反應需要→flag blueprint sign-off、side-action 家族新增型規矩）。
- determinism byte-identical（機械估+util、零新 RNG）。

## TDD 驗收（implementer）
1. **記帳**：dispatch herald/scout/convoy/subteam → dispatch_ledger append 對應筆、expected_return_tick 機械估合理（RED：記帳點 neuter→帳本空）。
2. **共享原語收斂**：`_evaluate_owner_contact` 與 ledger 皆走 `_contact_elapsed_days`（RED：改 helper 回傳→兩方向同步變=證一套非兩套）。
3. **逾時偵測**：elapsed > expected → 失聯 belief 標記（RED：overdue_ratio 門檻移→永不標）。
4. **人格反應分化**：務實母隊 overdue→再派 fire vs 冷酷母隊→註銷（per-option mini-util dump 證分化、RED：人格權重 neuter→齊一）。
5. **零 god-view 硬驗**：失聯 belief 不含 subject live pop/food/死活；帳本讀自我 dispatch-log/best_estimate 非 `state.teams[subject].live`（感知鐵律 gate）。
6. **清帳**：letter deliver / subteam 回 → resolved=true、不再觸反應（RED：清帳 hook 移→重複再派）。

## 量測（湧現式、measurer→QA）
- 失聯事件→反應 fire 且**人格分化**（務實派查多/冷酷註銷多）——per-option util dump。
- 領主對久無音訊村查訪 fire（子→母 既有 + 母→子 新，兩方向一套）。
- 零 god-view 洩漏（失聯 belief 不含 subject 真實狀態）。determinism byte-identical。
- 長跑→QA 故事稽核（派出→失聯→人格反應鏈、motive→action→outcome）。

## 追蹤 / 註
- `dispatch_ledger` + 失聯 belief = 全量 tap（`contact.ledger_add`/`contact.overdue`/`contact.react_{redispatch,defensive,writeoff}`）——全量暫態可觀測性（[[feedback_full_transient_observability]]）。
- **★照妖鏡候選記 faction-balance 批**（非本批）：`CONTACT_TIMEOUT_DAYS`/`OWNER_CHANGE_BUFFER_DAYS`（`_evaluate_owner_contact` 反向硬門檻）+ 10+ 子單位側 timeout 死常數 → 逾時該人格秤非硬常數（同 `DEFECT_HONOR_THRESHOLD`、[[project_desperation_economy]] 照妖鏡）。本批帳本反應端已人格化、既有反向 threshold 留待照妖鏡批。
- 機械估 round_trip = 真移速 DERIVED、非 fire-crank。
