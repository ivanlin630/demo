---
from: implementer
to: systems
status: open
slice: failure-memory-structural-identity
topic: ★③解封完成:①可量(兩集合都是既有tap,零硬湊)+已量+判決通過;exact path在內(branch @43d5da55 / 報告檔);★★但這是maker側數字,請派measurer獨立重跑
---

# ③ `failure-memory ①` — **解封 + 落地**

## ★第一步（你要求的）：**①到底量不量得出來 ⇒ 量得出來，兩個集合都是既有 tap**
| 集合 | 來源 | 為什麼是它 |
|---|---|---|
| **A ＝ 被折價的結構身分** | `failure.suppressed.<structural_id>` 的 key 尾巴 | ★`FailureMemory.mult` **只在 `m < 1.0` 時 bump**（`failure_memory.gd:117`）⇒ 這是**折價【真的生效】**的集合，不是「記憶裡有」 |
| **B ＝ 本輪被選過的 option** | `decision.opt_chosen.<label>` 的 key 尾巴 | `decision_engine:172` |

★**唯一需要正規化的一處**：**candidate 的結構身分 ＝ `goal_type:frontier_kind`（`decision_engine:114`），
而 label 多一截 `:delegate`（`goal_resolver:658`）** ⇒ 比對前去掉那截。
★**這是接線事實（兩個 file:line 擺著），不是我湊的對照表。**

## ★★量了：`peaceful_economy` / `seed 1337` / **30 天**
```
A 被折價的結構身分(10) = [build_apothecary:resource, build_workshop:resource,
                          maintain_food:resource, survival, 求和, 覓食, 買糧, 貿易, 返家補給, 駐守]
B 本輪被選過的 option(17) = [...上述全部... + build_stable:resource, build_workshop:facility,
                          build_workshop:location, deliver_material, maintain_material:resource, 備戰, 自救建田]
★A∖B（沒被選過卻被折價＝連坐嫌疑）= []   ← 0 個
★陽性對照：買糧 ∈ A = true（failure.suppressed.買糧 = 13）
```
⇒ ★**①判決 ＝ 通過**（**A∖B ＝ ∅ 且陽性對照成立**）。

★★**「沒量到」與「通過」有被分開報**：**day10 那格陽性對照還是 `false`（買糧=0）⇒ 報告當下印的是
「⚠【陽性對照未成立】…先別當通過」**，到 day20/30 才轉綠。**兩邊都空會被判成「沒量到」，不會冒充通過。**

★**母體四問**：①A=10 個結構身分／B=17 個 option ②都不是 0 ③**單位＝一個【結構身分】**（非一次事件）
④**它是【被折價的動作】的母體**（★不是「失敗次數」的母體）。另附現存記憶快照 12 隊/18 key（★快照會被 `prune`，所以 A 用累計 tap 不用快照）。

## ★exact path
| | |
|---|---|
| **worktree** | `A:\GDS\demo\.worktrees\failure-memory-structural-identity` |
| **branch** | `feat/failure-memory-structural-identity` |
| **commit** | `43d5da55`（在 PARKED `e1161eea` 之上） |
| **改的檔** | `scripts/debug/failure_feedback_measure_bed.gd`（★**只有量測床，零 production 改**） |
| ★**報告落地** | `.worktrees/failure-memory-structural-identity/docs/measurements/2026-08-26-failure-memory-face1-collateral-30d.txt` |
| **完整 stdout** | `…\scratchpad\failure_face1.txt`（含 day10/20/30 三格） |

## ★★這是 **maker 側**數字，不是驗收
★**請派 measurer 用同床同 seed 獨立重跑一次**（`--path .worktrees/failure-memory-structural-identity`，
`LW_CONFIG=peaceful_economy PERF_SEED=1337 ADHOC_DAYS=30`，bed＝`failure_feedback_measure_bed.gd`）。
★**判準隨票走**：①＝**A∖B＝∅ 且 買糧∈A**；②＝`failure.suppressed.買糧 > 0`（本輪 13，方向：不得回歸 0）。

## ★仍未動的一面：③
**③紮根執行型失敗 ＝ 0，`failure.recorded` 只有 `order_abandoned_buy=169`。**
★**PARKED 記錄裡寫的封存理由仍成立**：**紮根每次都停在建材閘、從沒走到執行**
⇒ ★**執行型失敗在這張床上【不可能發生】** —— **要嘛建材鏈打開，要嘛給我一張紮根真的被 dispatch 的床。**
★**這一格我不硬湊，等你指示。**（★而今天那顆 `dispatch_builder.attempt` tap 正好給了它的分母：**20 天 39/39 全卡建材**。）
