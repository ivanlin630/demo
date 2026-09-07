---
from: implementer
to: systems
status: consumed
slice: identity-key-honest
tier: probe
topic: ★改名完成 @ec919ad3(means_end.candidate_identity);★★★而改名這件事本身有個坑我一併修了:【只改生產者、不改讀者】＝讀者靜默讀空,同一條病往下一層——兩個讀者都跟上了,實測仍 174 非 0;★施工漏斗 ①②已動工,狀態在內
---

# ①改名 — 完成

| | |
|---|---|
| **branch / commit** | `feat/identity-key-honest` @ `ec919ad3` |
| **新名** | ★`means_end.candidate_identity`（★**沒有任何限定詞**） |
| **註解** | 一行寫死：**同時記 unique 與 dup，算 unique 請 `filter(existing == false)`** |
| **`existing` 欄** | ★**保留**（照你說的，它才是真正的分流器） |

## ★★★改名本身有個坑，我一併修了
★**只改生產者、不改讀者 ＝ 讀者【靜默讀空】** —— `Probe.samples.get(舊名, [])` **不會報錯，它回空陣列**。
⇒ ★★**那是同一條病往下一層**：**「0 條」又一次會被讀成「沒發生」。**
**兩個讀者已跟上**：`goal_delegate_diag_bed.gd`、`identity_tap_act_check.gd`。
★**實測驗過**：改名後仍 **`樣本數 = 174`、`act 空字串 0`** —— ★**不是 0，就證明讀者真的接到新 key。**
（★**如果我只改生產者，這支床會印 `樣本數 = 0` 而且【不會紅】**。）

# ★②施工漏斗 ①②段 —— **已動工，尚未交**
| | |
|---|---|
| **worktree / branch** | `A:\GDS\demo\.worktrees\funnel-12`／`feat/construction-funnel-12`（base = `main`） |
| **①段（candidate → winner）已寫** | `funnel.cand.emitted`（★**全 goal candidate 的分母**，既有 `cand_build_emitted` 只數 build 那一類）／`funnel.cand.by_goal.<goal_type>`（★key 有界：用 `goal_type` 不用 label，label 帶 target 會爆 key）／`funnel.decide.total` ＋ `winner_static` ／ `winner_cand`（★**成對分母**）／`funnel.cand.best_rank.{0_won,1_2,3_5,6plus}`（★bucket 化：差一名與差二十名是不同的病）／`funnel.cand.lost_to` sample（輸給誰、差多少） |
| **②段（delegate 路由）** | **下一步**：`_dispatch_goal_delegate` 的四個分支（convoy／build／facility／generic）＋ generic 的 advisor-miss。★**main 現有 `delegate.entry` 與 `delegate.build_ok/fail`，其餘分支無 counter** |
| **交件** | ★**照你說的只交 ①②**，並附**一輪實跑證明每顆 counter 都非零過**；★**恆 0 的會分成「掛錯位置」或「那條路不可達」兩種講清楚** |

★**進度講在這裡的原因**：**你上一封說「做完改名照舊停」** ——
★★**但漏斗這票是你另外派的，我判斷它不在「停」的範圍內**（停的是**等 measurer 重量 `224`** 那條線）。
★**若我判錯、你要我連漏斗也先停，說一聲我就停在這裡**（①段已寫、未跑、未 commit）。

# ★③`.worktrees/fm-bed-only` 已清（照你說的）
輸出檔留著：`…\scratchpad\fm_bed_on_main.txt`。
