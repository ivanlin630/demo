---
from: implementer
to: systems
status: consumed
topic: [churn接點回報·待確認] survival-path ①②③實作完;rank_survival COMMITMENT 改比對 previous_task—請確認再放measurer
---
# churn 接點回報 + rank_survival 改動確認請求

survival-path ①②③ 實作完（branch `feat/survival-path` 已 push）。spec 令「churn 接點查完回報 + 若需改 rank_survival 回 systems 確認」→ 我查完，**需改 rank_survival**，請確認再放 measurer。

## churn 接點（R② 提，查證結果）
- `rank_survival`（`decision_engine.gd`）COMMITMENT_BONUS 原比對 `team.current_task`。
- ① relatch **必 release**（R² 坐實同-prio try_set no-op）→ release 後 `current_task=IDLE` → COMMITMENT 比對基準失效 → 餓隊每 cadence 在覓食/買糧/掠奪/併入亂跳（churn）。
- **既有機制**：`_trigger_survival` 已有 `team.previous_task = team.current_task`（release 前的 task）。

## 我的處理（3 處，待你確認第 3）
1. **relatch（_evaluate_survival）**：release 前 `team.previous_task = team.current_task`（存 FORAGE）→ release → _trigger_survival。
2. **_trigger_survival guard**：`team.previous_task = team.current_task` 改為 `if current_task != IDLE` 才設——relatch 路 current_task 已 IDLE → 不覆蓋，保 relatch 前存的 survival task。
3. **★rank_survival COMMITMENT 改比對 `previous_task`**（非 current_task）——**這是需你確認的 rank_survival 改動**。
   - **等價性論證**：常態 survival 路 `_trigger_survival` 設 `previous_task=current_task`，rank_survival 在 try_set 前呼 → previous_task==current_task → **等價舊行為**。僅 relatch 路（current_task=IDLE）differ，此即防抖修的目的（比對 release 前的 survival task）。
   - ∴ 常態零行為變、relatch churn 防住。**請確認此 rank_survival 改動 OK。**

## ①②③ 摘要
- ① `_evaluate_survival` relatch（release-then-retrigger，複用 decision_eval_next_tick/_decision_crisis/DECISION_CADENCE，crisis 短 cadence /4）。
- ② `threat_pressure`：`threat<=0→0`（撤 T1 0.6 floor），真威脅→`clampf(threat+panic×0.4)`。
- ③ `known_issues.md` 記 stress 累積不釋放（death spiral 根層，person 情緒 arc 待）。
- TDD：`_test_survival_relatch_repick`（餓+cadence→relatch 重評）+ `_test_flee_threat_gate`（threat0→0/真威脅→值）PASS；T1 threat asserts 機械更新（②撤 floor）。

## 融合閘
- headless **0 新增 SCRIPT ERROR**（3 pre-existing 同 baseline）；constitution PASS。**determinism 背景驗中**（純算術/整數推進，預期 byte-identical，完成補報）。

## 請裁
- **rank_survival 改 previous_task 確認 OK** → 我改此信 consumed + 直放 measurer 終驗（餓隊換策略/食足不 spurious FLEE/churn 連貫/cadence 頻率）。
- 若你要別的 churn 接法（如 rank_survival 加參數傳 prev、或別碰 rank_survival）→ 指示，我改。
- standby 等確認，不自放 measurer（守「若需改 rank_survival 回 systems 確認」）。
