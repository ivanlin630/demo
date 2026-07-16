---
from: implementer
to: systems
status: consumed
topic: 求生執行鎖 thrash-fix 實作交付 — Fix A recognizer priority-based de-patch + Fix B 子隊 specimen tap；sanity 全綠
---
# Hand Back：求生執行鎖 thrash-fix

branch `feat/survival-execution-lock` @ `4fbaa7e8`（已 push origin），base = origin/main `f490f364`。

## 實作摘要（照 spec `2026-07-14-survival-execution-lock-thrash-fix.md`）
2 commit（TDD red→green）：
- `e301c7a6` test — 新 `scripts/debug/survival_execution_lock_test.gd`（thrash 重現 + recognizer 白盒）
- `4fbaa7e8` fix — `scripts/simulation/faction_ai_system.gd`（16+/3-）

**Fix A（root de-patch）**：加 helper `_in_survival(team) -> bool`（SURVIVAL_TASKS 白名單 ∪ `task_priority == PRIO_SURVIVAL`），放 SURVIVAL_TASKS 定義下方。三處 recognizer 呼點改呼 helper：
- 核心執行鎖入口（`_evaluate_survival`，原 `:3093`）：`if team.current_task in SURVIVAL_TASKS:` → `if _in_survival(team):`
- leader survival-sticky（`_assign_tasks`，原 `:1360`）：→ `if _in_survival(leader_team):`
- uprising skip（`_evaluate_uprising`，原 `:3484`）：→ `if _in_survival(team): return`

**Fix B（觀測 tap-gap）**：`_decide_subteam` winner commit（原 `:1742`，`HandBrainProbe.capture` 旁）補一行 `SpecimenTracer.capture_decision(state, sub, opt, td["task"], tgt)`。

**與 spec 差異**：無。無新 const/option/data 欄，純 recognizer 邏輯修 + 一行 tap，全依 spec 設計。

## 驗收（implementer sanity 自驗，commit 4fbaa7e8 @ worktree；log 落地 docs/measurements/）
- **unit test 8/8 PASS**（`survival_execution_lock_test.gd`；log `...-unittest-4fbaa7e8.log`）：
  - **thrash red→green 坐實**：修前 `current_task=idle / priority=0`（貿易→idle thrash 的 idle 端重現）→ 修後 `current_task=貿易 / priority=80(PRIO_SURVIVAL)` HOLD。
  - recognizer 精準：買糧/掠奪 @PRIO_SURVIVAL 認得；正常貿易/攻擊 @PRIO_DISPATCH 不誤判（不誤 skip uprising/誤 sticky）。
- **headless ≥1000 tick 零新增**（log `...-headless-sanity-4fbaa7e8.log`）：改後 3 SCRIPT ERROR + 3 [FAIL]；stash code 改跑 base 亦 3+3 → **零新增**（= known_issues baseline 子集）。
- **憲法閘 PASS**（log `...-constgate-4fbaa7e8.log`）：`sites=29, removed=0`（無新 mutation 面）。
- **determinism 保**：headless 內 `seeded warring reproducible OK (seed=1337 ticks=1200)` 逐點重現（純邏輯讀既有欄 + tap no-op，零 randf）。
- **既有測試不回歸**：`survival_layer_unify_test.gd` ALL PASS（0 FAIL）。

## 連動風險（收件方決定是否補修）
- `_decide_subteam`（引擎 @PRIO_DISPATCH）：spec §61 dual-producer 分析——Fix A 後 legacy @PRIO_SURVIVAL(80) HOLD → 引擎 @PRIO_DISPATCH(50) try_set 被 arbiter 拒（no-op），不再互蓋。sanity 未見新 churn，但正式 headline thrash 數字需 measurer 標準床產。
- `_assign_tasks` leader-sticky（Fix A 第 2 處）：買糧/掠奪 survival 中的 leader 現正確 sticky（原被主 rank 蓋）——行為變更，非-buy/loot survival 隊不受影響（原本就命中白名單）。

## 下一站需求（承 spec §驗收法 + dispatch）
本 slice 是**全量暫態可觀測性 + QA 故事性判官 workflow 首個試驗**。measurer 需：
1. **headline thrash 歸零**：Team14 型子隊 `貿易↔idle`（含掠奪/佔村同型抖）同-tick flip/tick → 歸零/趨零；`[Survival] TeamN …→…` 每-tick flip print 消失。
2. **買糧單下得成**：餓子隊 fire 買糧 → HOLD 到抵市集 + `[Order] TeamN buy food`。
3. **Fix B tap-gap 收**：`SPECIMEN_TEAM_ID` 設子隊時 `decision_count > 0`（非 0 假象）。
4. 產 `.specimen.jsonl`（`03b §⑤`）給 QA 判故事性（motive→action→outcome）。
5. 附雙數字（thrash flip + attrition），不回歸 established/attrition（本刀治抖不治死亡率）。

## 待確認
- 無 spec 未覆蓋的設計決策。完成判定 = systems + reviewer/QA（非 implementer 自判）——待裁決信（`[DONE]`/`[REDO]`）。context hold warm。
