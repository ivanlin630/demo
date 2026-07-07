---
from: implementer
to: qa
status: open
topic: A1a 拆閥 — 實作驗收交 QA（code 對 spec + 5 條驗收全綠 + 一個 pre-existing FAIL 誠實揭露）
---

# A1a — implementer → QA handback

母 spec：`docs/superpowers/specs/2026-07-07-A1a-arbiter-valve.md`
前段 handback：`2026-07-07-systems-to-reviewer-A1a.md`（issue#1 修 / issue#2 defer）
查證員 verdict：`docs/process/verdicts/A1a.review.json`（`verdict:clean`，issues=[]）

本 handback = implementer 節點獨立過一遍 code↔spec + 重跑 5 條驗收，交 QA 判決。
**實作主體已在 commit（fef3702/c855f11/1573384），本節點無新 code 改動**——職責 =
驗證落地正確 + 誠實補一個前段 handback 漏報的 pre-existing FAIL。

## code ↔ spec 對照（逐點查實）

| spec 改點 | code 落點 | 對否 |
|---|---|---|
| 改點1 `ENGINE_SOURCES=["unified","solo"]` | `task_arbiter.gd:20` | ✅ |
| equal-priority self-replace（兩側 engine-owned gate） | `task_arbiter.gd:45-58` | ✅ 新 source∈白名單 + incumbent reason `trim_prefix("defy_")`∈白名單 |
| 同 task 重申=蓋 move_target 不蓋 task_start_tick（issue#1 修） | `task_arbiter.gd:48-50` | ✅ |
| TRADE preempt Probe parity | `task_arbiter.gd:51-52` | ✅ |
| 護欄：combat 鎖首檢 / PLAYER@60 不進 equal 分支 / 抗命窗口原樣 | `task_arbiter.gd:28-29,45,60-74` | ✅ |
| 改點2 `STATION_TASKS`/`STATION_TIMEOUT=TICK_PER_DAY*4` | `faction_ai_system.gd:122-125` | ✅ |
| loop3 STATION timeout release（`< PRIO_PLAYER` guard） | `faction_ai_system.gd:761-764` | ✅ Probe.bump("station.timeout")+release |
| 連動修：`transition` 加 `state` 蓋 task_start_tick | `task_arbiter.gd:87-91` | ✅ |
| 14 呼叫點全傳 `state` | grep 全 14 點簽名一致 | ✅ |
| 簽名變不動指紋（relpath::func 不變） | constitution gate `PASS sites=30 removed=0` | ✅ |

結論：code 與 spec **零漂移**，issue#1 修落地、issue#2 依 spec 明示 defer 至 A1b。

## 5 條驗收（main 現有工具，本節點親跑）

| # | 驗收 | 結果 |
|---|---|---|
| 1 | `--headless --import` 乾淨 | ✅ 0 SCRIPT ERROR |
| 2 | `hand_obeys_brain_bed.gd` 無 SCRIPT ERROR/timeout | ✅ `HOB_MONTHS=1 HOB_SEEDS=1337`：SCRIPT ERROR=0、TIMEOUT=0、跑到 `=== DONE ===` |
| 3 | `constitution_gate.gd` 不 FAIL | ✅ `PASS (sites=30, removed=0)` |
| 4 | 非退化 headless_test ≥1000 tick | ✅ SCRIPT_ERRORS=0、全測試序完成 `=== DONE ===`；FAIL=1 **屬 pre-existing，見下** |
| 5 | bed `arbiter_latch` 桶方向↓ | ✅ 76 (4.6%) vs 母 spec/systems baseline 270 (16.9%) = **−72%** |

## ★ 誠實揭露：一個 pre-existing FAIL（非 A1a 回歸）

headless_test 跑出 **1 個** `[FAIL]`：

```
  [FAIL] 弱目標未加入攻擊 goal
```

（`headless_test.gd:3180`，`_update_goals` 弱目標 armed_est=2 應加入攻擊 goal 的斷言）

**判定 = pre-existing，非本 slice 造成**，證據鏈：
1. 該測試**確定性**（無 RNG，硬編值），直呼 `_update_goals`。
2. `_update_goals` 最後改動 = commit `098f21d`（**pre-A1a**）；A1a 的 `faction_ai_system.gd`
   18 行改動只碰 `STATION_TASKS` const + timeout 塊，**未觸 goal 邏輯**。
3. A1a 的 headless_test 改動只加 `_test_arbiter_engine_self_replace` + transition/
   `_begin_facility_construction` 簽名更新，**未觸該弱目標測試（:3161-3180）**。
4. **決定性驗證**：checkout baseline `fef3702^`（=0a908f5，A1a 主體前）重跑
   headless_test → **同樣 `[FAIL] 弱目標未加入攻擊 goal`，FAIL count=1**。
   ∴ baseline==A1a，**FAIL count 未變壞**，非退化準則（#4）成立。

**注**：前段 systems→reviewer handback 記「headless_test 全 [OK]」與此不符——實測 baseline
即帶此 FAIL。非 A1a 缺陷，但**建議 QA 記入 known_issues 或另開修**（`_update_goals` 弱目標
攻擊 goal 判定與測試斷言不一致，範圍在 goal 系統，非本 arbiter slice）。

## 殘留疑點（呈報 QA）

1. **pre-existing FAIL `弱目標未加入攻擊 goal`**：非 A1a，但真實存在。屬 goal/實力比較邏輯，
   建議另立 issue，勿併 A1a arc。
2. **issue#2 beggar 恢復小 latch = A1b follow-up**（`transition` 預設 reason∉ENGINE_SOURCES →
   恢復的引擎 task 引擎同層換不掉；有界非永久，STATION/TRADE timeout + 嚴格大於 + 自完成兜底）。
   spec 已記為 defer 缺口，需 targeted restore-source（動 beggar 恢復語意 → A1b 範圍）。
3. **no_release_latch 方向不明顯**（40→42 噪音內）：STATION_TIMEOUT=4 天 TEST VALUE 在 1 月窗
   aggregate 效果被采樣噪音蓋；縮 latch 時長非瞬時 count。方向不追數字（母 spec :89 閘校正）達標。
4. **scratch 產物**：worktree 有未追蹤 `bed_before.txt`/`bed_after.txt`/`bed_baseline.txt`
   （direction 對照原始輸出）與已改未 commit 的 `docs/process/verdicts/A1a.review.json`
   （查證員 clean verdict）——非 code，QA/orchestrator 決定是否收編/清理。

## commit 序（本 slice 全歷史，死也丟最少）
- `fef3702` feat(A1a): 拆閥主體——equal-priority self-replace + 四駐地 timeout release
- `c855f11` fix(A1a): reaffirm 蓋 move_target（issue#1）
- `1573384` docs(A1a): spec 記 move_target 修 + issue#2 defer 缺口
- `88c6283` docs(A1a): systems→reviewer handback + 5 條驗收
- 本 commit：implementer→qa handback（本檔）
