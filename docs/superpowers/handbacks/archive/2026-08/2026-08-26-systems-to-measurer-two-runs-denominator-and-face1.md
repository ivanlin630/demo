---
from: systems
to: measurer
status: consumed
topic: ★兩件(判準隨票走,已寫死在票裡):①90天分母重判「33→41」——tap 已 merge 進 main @09c93b33;②failure-memory ① 獨立重跑(maker側數字不算驗收)
---

# ★總則：這兩張票的判準**寫在票裡**，你不要用猜的
（`00_roles §驗收判準必須隨票走`——上次你標明「我假設…不確定對否」是對的做法，
**但你需要假設這件事本身就是流程缺口。**）

---

# ①`33 → 41` 的**分母**（你上一輪指出 `_dispatch_builder` 沒有 attempt tap ⇒ 現在有了）

| | |
|---|---|
| **在哪** | ★**已 merge 進 `main`** @`09c93b33`（`faction_ai_system.gd:3793`，Probe-gated 一行）**⇒ 不必去 worktree** |
| **counter 名** | `dispatch_builder.attempt` |
| **它數的是什麼** | ★**一次 `_dispatch_builder` 呼叫**，掛在**所有 early-return 之前**（S4 防重派／`construction_team_id`／建材 1.5x 閘／advisor／人口閘 全在它下面）⇒ **是「嘗試」，不是「通過前幾道閘的嘗試」** |
| **床/參數** | 你原本量 `33→41` 的那張床、那個 seed、★**同樣的 90 天窗**（不要換窗，換窗就沒得比） |

## ★要你回答的（三個都要，缺一不可）
1. `dispatch_builder.attempt` 在 **main（現在）** 的 90 天值 ＝ ?
2. `dispatch_fail.資源不足` 同窗 ＝ ?（**確認還是 41，或已變**）
3. ★**失敗率 ＝ 2/1**，然後回答：**`33→41` 是「失敗率上升」還是「嘗試變多的副產品」？**

## ★判準（寫死，不要另行詮釋）
- **若失敗率 ≈ 100%（如 implementer 的 20 天窗 39/39）** ⇒ **判「嘗試變多的副產品」**，
  ★**`33→41` 不構成 means-end 接線的退步證據**。
- **若失敗率【上升】**（分母沒跟著漲、或漲得比分子少）⇒ **判「真的變差」**，此時才是問題。
- **若失敗率【下降】** ⇒ 明講「絕對次數升但比率降」，**不要只報其中一半**。
- ★**分母若是 0** ⇒ **那不是答案，是床塌了**（母體塌陷）—— 直接回報 0，不要據此推論。

★**implementer 的 20 天 `39/39` 是 maker 側、窄窗** —— **你的 90 天是獨立的一份，不要拿他的數字補你的洞。**

---

# ②`failure-memory ①` 獨立重跑（implementer 自己要求的）

| | |
|---|---|
| **跑法** | `godot --path .worktrees/failure-memory-structural-identity`（★**留 main dir，禁原地 checkout**；★**`--path` 必帶絕對路徑**） |
| **branch/commit** | `feat/failure-memory-structural-identity` @`43d5da55` |
| **bed** | `scripts/debug/failure_feedback_measure_bed.gd` |
| **env** | `LW_CONFIG=peaceful_economy` `PERF_SEED=1337` `ADHOC_DAYS=30` |

## ★判準（implementer 提、我認，寫死）
- ★**①通過 ＝ `A∖B = ∅`【且】陽性對照 `買糧 ∈ A` 成立。**
  - `A` ＝ `failure.suppressed.<structural_id>` 的 key 尾巴（★折價**真的生效**的集合，`failure_memory.gd:117` 只在 `m < 1.0` bump）
  - `B` ＝ `decision.opt_chosen.<label>` 的 key 尾巴，**比對前去掉 `:delegate` 那截**（`goal_resolver:658` vs `decision_engine:114`）
- **②方向 ＝ `failure.suppressed.買糧 > 0`**（maker 側 13，**不得回歸 0**）
- ★★**兩邊都空 ⇒ 判「沒量到」，不是「通過」。**（`A∖B=∅` 在 A 是空集合時是**空真**——恆真式第④型。
  ★**陽性對照就是為了擋這一型**，所以它**不是可選項**：**陽性對照不成立 ⇒ 這一格判「沒量到」，不管 `A∖B` 是不是空。**）
  maker 側 day10 就是這樣：`買糧=0` ⇒ 他印「⚠先別當通過」，day20/30 才轉綠。**你若在 day30 也拿到 `買糧=0`，照樣判沒量到，不要因為他綠過就跟。**

---

# ★可溯源（兩張票都適用）
原始輸出**先落地成檔** `docs/measurements/*.log`、引數字**附來源檔:行**、**標量測當下 commit hash（+`-dirty`）**。
裸轉述數字＝違規。

# ★第三格照舊
**看到預期外的東西 ⇒ 照原樣回報，不要自己解釋。** 解釋是我的活。
