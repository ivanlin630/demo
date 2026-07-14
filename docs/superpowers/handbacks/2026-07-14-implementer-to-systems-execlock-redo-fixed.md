---
from: implementer
to: systems
status: consumed
topic: "[REDO 已改] 求生執行鎖——uprising skip 收斂回窄白名單；Fix A 其餘兩處+Fix B 保留；重驗全綠"
---
# Hand Back：求生執行鎖 REDO 收斂完成

branch `feat/survival-execution-lock` @ `b962fc74`（已 push），承接 REDO `2026-07-14-systems-to-implementer-execlock-REDO-uprising-scope.md`。

## 收斂內容（照 REDO 指示）
`commit b962fc74` — `_evaluate_uprising`(:3484) 改回窄白名單：
```gdscript
if team.current_task in SURVIVAL_TASKS: return   # 只全隊一致對外求生 task skip 起義
```
- **理由（REDO）**：買糧/掠奪 @PRIO_SURVIVAL 隊仍駐紮在地，內部 loyalty 崩壞仍可能起義——用 `_in_survival` 會 skip 掉、掩蓋叛亂訊號。
- **Fix A 其餘兩處保留 `_in_survival`**：核心執行鎖入口(:3093) + leader-sticky(:1360)——那兩處要的正是認得買糧/掠奪 survival。
- **Fix B（specimen tap）不動**。

## 重驗（commit b962fc74；log 落地 docs/measurements/）
- **unit test 8/8 PASS**（`...-unittest-b962fc74.log`）：Test 1 HOLD 綠、Test 2 recognizer 白盒綠（helper 未動）。
- **headless ≥1000 tick 3+3 baseline 零新增**（`...-headless-sanity-b962fc74.log`）。
- **憲法閘 PASS** sites=29 removed=0。
- **determinism 保**：seeded warring reproducible OK (seed=1337 ticks=1200) 逐點重現。

## 下一站需求（同前，未變）
measurer 標準床產 headline：thrash 歸零 / 買糧單下得成 / Fix B tap-gap 收（子隊 decision_count>0）/ `.specimen.jsonl` 給 QA 判故事性 / 雙數字（thrash flip + attrition，不回歸 established）。

## 待確認
- 無 spec 未覆蓋決策。完成判定 = systems + reviewer/QA。context hold warm 等裁決信（`[DONE]`/`[REDO]`）。
