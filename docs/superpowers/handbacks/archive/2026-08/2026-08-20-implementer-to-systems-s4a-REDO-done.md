---
from: implementer
to: systems
status: consumed
topic: "[§4a REDO done(含 addendum 兩護欄)·branch feat/settlement-s4a @b4c84692·①留 survival set 不動②priority_for 加通用 optional 欄『priority』(set membership vs commit priority 語意解耦、無此欄走舊推導)③紮根標 PRIO_DISPATCH+why-comment·★護欄:PRIORITY_ALLOWED 白名單=TaskArbiter 具名常數、priority_for assert 值域+非法退回預設(禁裸 int、code 端非只註解)·★TDD⑨動態驗:priority_for(紮根)=50+仍在 survival set+committed task_priority=50+威脅@70 真 preempt 成功+絕境@80 真 preempt 成功且 corvee_site 仍在(recovery 前提)·重驗全綠:s2b ALL PASS(9 組)/constitution PASS 75/determinism 三跑 byte-identical fp=24cffe3b4241f9e56d0bf25683e22a69/headless 0-new(6 known assert+3 known FAIL)/s1+s2a+agri a/b 全綠·fp 仍與 base main 同(a4 窗內紮根 dormant、非沒生效)]"
branch: feat/settlement-s4a
commit: b4c84692
---

# §4a REDO done（含 addendum 兩條護欄）

你抓的漂移成立：紮根在 survival set → `priority_for` 回 **80 > PRIO_THREAT(70)** → 壓境威脅打不斷工期；舊 `_evaluate_l0_settle` 是 `transition(..., PRIO_DISPATCH)`。**我原本的 TDD⑤ 確實抓不到**（那是靜態 `TASK_BUILD in PREEMPTIBLE_TASKS` 的集合成員資格，不是動態驗打斷）。

## 修（照裁定三步）
1. **留 survival set 不動**（拿掉＝絕境隊結構性沒紮根選項＝隱含硬門檻）。
2. **`priority_for` 加通用 optional 欄 `"priority"`**：REGISTRY entry 有此欄就用它，否則走舊推導（survival→80／threat→70／其餘→50）。語意分離＝**set membership（在哪些 rank 清單競爭）** vs **commit priority（committed 後誰能打斷）**。
3. **紮根 entry 標 `"priority": TaskArbiter.PRIO_DISPATCH` + why-comment**。

## ★addendum 兩護欄（code 端落實）
- **①值域鎖死**：新增 `PRIORITY_ALLOWED`（＝`PRIO_DISPATCH/PLAYER/THREAT/SURVIVAL` 具名常數本身）；`priority_for` 讀該欄時 **assert 值域**，非法值 **退回預設推導**（assert 在 release build 被剝時仍不會讓裸 int 生效＝雙保險）。新增層級時在 TaskArbiter 定常數並加進白名單（單一源）。
- **②必附 why-comment**：紮根 entry 已有三行理由（含「@80 會讓壓境威脅打不斷工期」的具體後果）。

## ★TDD⑨（動態、非靜態）
- `priority_for("紮根") == PRIO_DISPATCH`、且**仍在 survival set**（兩件事分離的直接驗）。
- committed 紮根後 `team.task_priority == 50`。
- **威脅 @PRIO_THREAT(70) → try_set 真的成功**、`current_task` 從 `建設` 變 `逃跑`＝工期可被打斷。
- **絕境 @PRIO_SURVIVAL(80) → 真的成功**（去覓食），且**`corvee_site` 仍記著工地**＝既有 recovery 回頭續建、進度不丟。
（形式說明：⑨ 走 `TaskArbiter.try_set` 直驗「誰能打斷誰」的契約層，而非架一個完整威脅世界；判斷打斷與否的單一決定點就是 arbiter 的優先序比較，這樣測到的正是漂移發生的那一環。）

## 重驗（全綠）
| gate | 結果 |
|---|---|
| `settlement_s2b_test`（真引擎路徑） | **ALL PASS**（9 組，含 ⑧零 zombie、⑨動態 preempt） |
| constitution | **PASS sites=75**（硬 gate 保持） |
| determinism | **三跑 byte-identical** `fp=24cffe3b4241f9e56d0bf25683e22a69` |
| headless | **0-new**（6 known assert + 3 known FAIL、與 main 同集合） |
| `settlement_s1`/`s2a`/`agriculture_a`/`agriculture_b` | 全 **ALL PASS** |

**fp 仍與 base main 相同**（同 `24cffe3b`）＝a4 warring 1000t 窗內沒有隊走到「有自己 L0 營地」→ 紮根 dormant；不是沒生效（端到端行為在 s2b 真引擎路徑已證）。fp 差異要靠 measurer 的 settled/長局床。

你補的 measurer gate（壓境頻繁區 vs 無威脅區的**中斷-續建循環次數 / 平均完工時長**，驗 recovery 不變成「開工又中斷」新 churn）＝我這邊沒做、留給那輪。地基 KEEP。
