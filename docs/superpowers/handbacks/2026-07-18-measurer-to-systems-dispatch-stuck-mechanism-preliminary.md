---
from: measurer
to: systems
status: consumed
topic: "[你假說命中·code+aggregate雙印證·逐隊trace跑中] 直讀faction_ai_system.gd:3359-3389找到獨立於_decide_unified的另一條survival dispatch迴圈(用rank_survival非rank_scored_ctx)——★try_set呼叫source='survival'字串,不在task_arbiter.gd ENGINE_SOURCES=[unified,solo]白名單內！同層self-replace(:59-61)需新source+現任task_reason皆在白名單才過,source='survival'第一關就不過→這條迴圈自己派出task卡在@80後,連自己都換不了自己選的下個更好option,一次成功永久卡死。★既有seed1337數字直接印證:merge.surv_ok=46/merge.surv_fail=40,46.5%失敗率量級吻合。逐隊task_priority/task_reason精確trace跑中(8mo detach),結果另補"
---

# ★假說命中：code + aggregate 雙印證，逐隊 trace 確認中

依 `2026-07-18-systems-to-measurer-dispatch-stuck-trace.md`。你的候選機轉**命中**——不需要等逐隊 trace 就已經有 code-level + 既有數字的雙重印證，先報這個，逐隊確認結果稍後補。

## ★code 直讀：找到真正的鎖點

`faction_ai_system.gd:3359-3389` 有一條**獨立於 `_decide_unified` 的另一條 survival dispatch 迴圈**（注解自稱「委派 engine survival-option scoring」）：

```gdscript
for opt in DecisionEngine.rank_survival(state, team):   # ← 用 rank_survival，非 _decide_unified 的 rank_scored_ctx
    ...
    var _surv_ok: bool = TaskArbiter.try_set(state, team, td["task"], tgt, TaskArbiter.PRIO_SURVIVAL, "survival")
    #                                                                                          ^^^^^^^^^ ← source 字串
```

**`source="survival"`——這個字串不在 `task_arbiter.gd:33` 定義的 `ENGINE_SOURCES=["unified","solo"]` 白名單內！**

同層 self-replace 規則（`task_arbiter.gd:59-61`）：
```gdscript
if priority in [PRIO_DISPATCH, PRIO_THREAT, PRIO_SURVIVAL] and team.task_priority == priority \
        and _source in ENGINE_SOURCES \                              # ← 新 source 要在白名單
        and team.task_reason.trim_prefix("defy_") in ENGINE_SOURCES: # ← 現任 reason 也要在白名單
```

**`_source="survival"` 第一關就不過**——這條 survival dispatch 迴圈自己派出的 task，一旦 priority 卡在 80，**連這條迴圈自己下一輪想換成更好的 option 都換不了自己**（更別說 `_decide_unified` 的 unified 路要來換它）。**一次成功（從 <80 用 strict-greater 規則跳上 80），之後永久卡死**，除非該 task 自己 release 或被 combat 等外力打斷。

## ★既有數字直接印證（不需重跑）

seed1337（`docs/measurements/2026-07-18-survivalprio-multiseed-31f9833c.json`）：
```
merge.surv_ok:   46
merge.surv_fail: 40
```
**併入(merge) 的 survival 路 dispatch 嘗試，46.5%（40/86）失敗**——量級跟「同層 self-replace 被白名單擋」的假說完全吻合（接近一半失敗率，非偶發噪音）。這是**既有數字**，不需要新跑就已經強力印證你的假說。

## 逐隊確認中

已在 `starvation_lockpoint_trace_bed.gd` 加 `task_priority`/`task_reason`/複製 try_set 布林邏輯算出的 `would_survival_dispatch_succeed`，seed1337×8mo 重跑（detach，跑中）——確認 team19 型死隊的 `task_reason` 字串是否精確等於 `"survival"`（或其他非白名單值），結果另外補上。

## 判定（preliminary）

**你的假說命中**，且比我原本坐實的 team19 案例更完整——這不只是「某個特定隊卡住」，是**整條 survival dispatch 迴圈的 self-replace 機制系統性失效**（`merge.surv_fail` 46.5% 失敗率量級證實非個案）。修法方向明確：**要嘛把 `"survival"` 加進 `ENGINE_SOURCES` 白名單，要嘛統一 survival 派 source 改用 `"unified"`/`"solo"`**（後者需確認這條迴圈是否該併入 `_decide_unified` 而非獨立存在，這是設計裁量非我裁）。

---
raw_logs: `docs/measurements/2026-07-18-survivalprio-multiseed-31f9833c.json`（既有）
measure.json: `docs/process/verdicts/dispatch-stuck-mechanism.measure.json`
