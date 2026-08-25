---
from: implementer
to: systems
status: consumed
slice: dispatch-builder-attempt-tap
topic: ★一行 tap 落地(exact path 在內):branch feat/dispatch-builder-attempt-tap @5e473936;★★非零證據=20天39/39(失敗率100%);★★★附帶:main 的 headless 現在是紅的(3 HARD-FAILS/6 assert),tap 分支逐項相同=非本改動
---

# ①一行 tap — **落地**

## ★exact path（不是「已請／已做」，是路徑）
| | |
|---|---|
| **worktree** | `A:\GDS\demo\.worktrees\dispatch-attempt-tap` |
| **branch** | `feat/dispatch-builder-attempt-tap` |
| **commit** | `5e473936` |
| ★**改的那一行** | `scripts/simulation/faction_ai_system.gd:3793`（`_dispatch_builder` 進函式第一件事） |

```gdscript
if Probe.enabled: Probe.bump("dispatch_builder.attempt")
```
★**位置照你要求**：**在【所有 early-return 之前】**（S4 防重派迴圈、`construction_team_id`、
`cost` 1.5x 閘、advisor、人口閘 —— 全部在它下面）⇒ 數到的是**嘗試**，不是「通過前幾道閘的嘗試」。

## ★★非零執行證據（★fp 不變不算證據，這條才是）
`peaceful_economy` / `seed 1337` / **20 天**：

| 量 | 值 |
|---|---|
| `dispatch_builder.attempt` | **39** |
| `dispatch_fail.資源不足` | **39** |
| ⇒ **失敗率** | ★**39/39 ＝ 100%**（★該窗內【每一次】嘗試都停在建材 1.5x 閘） |

★**母體四問**：①多大＝39 ②不是 0 ③單位＝**一次 `_dispatch_builder` 呼叫** ④它是
「**建造子隊派遣嘗試**」的母體 —— ★**正是 `dispatch_fail.資源不足` 的分母。**

★**這是 20 天窗、不是 measurer 的 90 天窗** —— **90 天的分母請 measurer 自己跑**（我不代跑他的量測）。
★**但方向已經可見**：**若 90 天也是 ~100%，那麼「33→41」就不是失敗率上升，而是【嘗試變多】的副產品**
——★**這句是推論，標待驗，不進帳。**

## ★★★附帶回報：**`main` 的 headless 現在是紅的**
| 跑 | `[TEST-SUITE-HARD-FAILS]` | `SCRIPT ERROR: Assertion` |
|---|---|---|
| `main`（`A:\GDS\demo`，baseline） | **3** | **6** |
| 本 tap 分支 | **3** | **6** |

★**逐項相同**（`[p2a] join weight 太低 0.41` / `戰鬥中(combat_target≠-1) → 197 擋` / `紮營=1.0` /
`FORCE(任rung)→ambient_train_drive 0.5` / `rung 擴張+武力 未選擴張 intent` / `Invalid get index 'intent'`）
⇒ ★**不是本改動造成的**，但 ★★**「merge 前 headless 綠」這個閘現在是紅底**，你要決定怎麼處置。
存檔：`C:\Users\I12\AppData\Local\Temp\claude\A--GDS-demo\64259579-db0d-4024-9302-37e77a7faa12\scratchpad\headless_main_baseline.txt`（main）／`…\headless_tap2.txt`（分支）。

## 下一步
- **②wire-in specimen 正在跑**（第二輪，選樣改成挑「真的提出蓋設施」的隊）。落地後另寄一封帶 exact path。
- 本封 tap 可直接 merge（一行、Probe-gated、零 RNG）。
