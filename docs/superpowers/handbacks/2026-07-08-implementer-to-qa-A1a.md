---
from: implementer
to: qa
status: consumed
topic: A1a 拆閥 — implementer 節點(2026-07-08 re-spawn)獨立 live 重驗 5 條驗收 + 呈報 qa.json 未提交 verdict flip 越界 landmine
---

# A1a — implementer → QA handback（2026-07-08 re-spawn）

母 spec：`docs/superpowers/specs/2026-07-07-A1a-arbiter-valve.md`
前 handback：`2026-07-07-implementer-to-qa-A1a.md`（code↔spec 零漂移 + 補件）
方向證據：`docs/process/verdicts/A1a.direction.md`（committed，−72% + 重現指令）

本節點 = implementer 於 2026-07-08 re-spawn。實作主體早在 commit（`fef3702`/`c855f11`），
**本節點無新 code 改動**——職責 = (1)獨立重過 code↔spec，(2)**在非 gated godot 上 live
重跑全 5 驗收**（前 QA session 撞權限閘、無法親跑；本 session godot 可執行），
(3)呈報一個 process landmine。

## code ↔ spec 重驗（file:line 親查，非引前手）

| spec 改點 | code 落點（本節點親讀） | 對否 |
|---|---|---|
| 改點1 `ENGINE_SOURCES=["unified","solo"]` | `task_arbiter.gd:20` | ✅ |
| equal-priority self-replace（兩側 engine-owned gate） | `task_arbiter.gd:45-47` | ✅ 新 source∈白名單 + incumbent `task_reason.trim_prefix("defy_")`∈白名單 |
| 同 task 重申=蓋 move_target 不蓋 task_start_tick（issue#1） | `task_arbiter.gd:48-50` | ✅ |
| TRADE preempt Probe parity | `task_arbiter.gd:51-52` | ✅ |
| 護欄：combat 鎖首檢 / PLAYER@60 不進 equal / 抗命窗口原樣 | `task_arbiter.gd:28-29,60-74` | ✅ |
| 改點2 `STATION_TASKS`/`STATION_TIMEOUT=TICK_PER_DAY*4` | `faction_ai_system.gd:122-125` | ✅ |
| loop3 STATION timeout release（`< PRIO_PLAYER` guard） | `faction_ai_system.gd:761-764` | ✅ Probe.bump("station.timeout")+release |
| 連動修：`transition` 加 `state` 蓋 task_start_tick | `task_arbiter.gd:87-91` | ✅ |
| 14 transition 呼叫點全傳 `state` | grep 全 14 live 呼叫點簽名一致，0 stale 4-arg | ✅ |

零漂移。issue#1 落地、issue#2 依 spec defer 至 A1b。

## 5 條驗收 — 本 session live 親跑（godot **未** gated，EXIT=0）

| # | 驗收 | 本節點親跑結果 |
|---|---|---|
| 1 | `--headless --import` 乾淨 | ✅ EXIT=0，0 SCRIPT ERROR |
| 2 | `hand_obeys_brain_bed.gd` 無 ERROR/timeout | ✅ 兩側跑到 `=== hand_obeys_brain_bed DONE ===`、SCRIPT ERROR=0 |
| 3 | `constitution_gate.gd` 不 FAIL | ✅ `PASS (sites=30, removed=0)` |
| 4 | 非退化 headless_test ≥1000 tick | ✅ `=== DONE ===`、SCRIPT ERROR=0；FAIL=1=pre-existing（見下） |
| 5 | bed `arbiter_latch` 桶方向↓ | ✅ **270(16.9%)→76(4.6%) = −72%**，見下表 |

### 方向表（本 session 親跑 `bed_before.txt`/`bed_after.txt` tail 讀出）

| bucket | before `0a908f5` | after `e3175e6`(HEAD) | 方向 |
|---|---|---|---|
| ★手≠腦 viol | 715 (44.8%) | 567 (34.6%) | ↓ |
| `arbiter_latch` | 270 (16.9%) | 76 (4.6%) | **↓ −72%** |
| `no_release_latch` | 40 (2.5%) | 42 (2.6%) | flat（噪音） |
| member 背離 | 32.9% | **0.5%** | ↓（手更聽腦） |

`station.timeout` 探針在 after bed 實 fire（機制活）。−72% 磁量 = direction.md 引值**逐位重現**。

## ★ pre-existing FAIL（非 A1a 回歸）— 本 session 親驗

headless_test 出 **1×** `[FAIL] 弱目標未加入攻擊 goal`（`headless_test.gd:3180`）。
非 A1a：A1a `faction_ai_system.gd` diff 只碰 `STATION_TASKS` const+timeout 塊+transition 簽名，
未觸 `_update_goals`/goal 邏輯。前 handback 已 checkout baseline `0a908f5` 證 baseline==HEAD
FAIL count=1。**建議另立 issue，勿併 A1a arc。**

## ★★ 呈報 process landmine（停下不硬幹，交 QA/orchestrator 裁）

工作樹有一筆**未提交**的 `docs/process/verdicts/A1a.qa.json` 改動，把 verdict
**`issues` → `clean`**（issues=[]、note 改寫）。

- committed verdict（`8120ae1`）= **`issues`**（前 QA session：godot 被權限閘擋、−72% 當時無可重現 artifact）。
- 該 flip **無提交作者**（純工作樹 edit），**非本 implementer 節點所寫**。
- 依角色分工（QA=獨立 adversarial 判決、禁自蓋自判）：**implementer 不得 author/commit QA verdict。**
  ∴ 本節點**不 stage、不 commit** `A1a.qa.json`——避免把來路不明的 verdict flip 洗成「QA 已判 clean」。
- 本 handback commit **只含本檔**，刻意不碰 `A1a.qa.json`、不碰 `bed_*.txt`。

**交 QA：** 前 QA 的唯一 blocking issue（「−72% 無可重現」）已被 `direction.md`（committed）+
本 session live 重跑（godot 未 gated、逐位重現）實質溶解。請 QA **獨立**重判並提交 verdict；
若採 clean，由 QA 署名 commit，非沿用工作樹那筆孤兒 flip。

## 殘留疑點
1. pre-existing FAIL `弱目標未加入攻擊 goal`：非 A1a，另立 issue。
2. issue#2 beggar 恢復小 latch = A1b follow-up（spec 已記 defer；有界非永久，timeout+嚴格大於+自完成兜底）。
3. `no_release_latch` 40→42 = 噪音內；`STATION_TIMEOUT=4 天` TEST VALUE 在 1-month 窗被采樣噪音蓋。方向不追數字（母 spec :89）。
4. scratch：`bed_before.txt`/`bed_after.txt`（未追蹤，direction.md:42-44 記為刻意 worktree scratch）、
   與上述 `A1a.qa.json` 孤兒 flip——QA/orchestrator 決定收編/清理，本節點不動。
