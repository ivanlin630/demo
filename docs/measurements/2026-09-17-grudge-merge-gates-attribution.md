# 恩怨帳切片A：完整閘三顆紅的歸屬（2026-09-17，implementer）

★**兩棵樹**：
- 受測樹 ＝ `feat/grudge-ledger-a` 併入 main 之後的 `a6300de81`（註冊表與 runner 皆 clean、code-dirty=0）
- 基線樹 ＝ 臨時 detached worktree 停在 main `5f97d8ce9`（★**我沒有在 main 目錄原地跑**）

★★**判準**：同一支閘在兩棵樹上各跑一次；**只有「基線綠、受測紅」才算我的**。

| 閘 | 基線（main `5f97d8ce9`） | 受測（`a6300de81`） | 歸屬 |
|---|---|---|---|
| `bed-arm` | ✗ ——「27 張床建了世界，既不用 helper 也不在白名單」 | ✗ —— **同樣 27 張** | **存量紅，不是本切片** |
| `ki-status` | ✗ ——「新條目缺【狀態】欄 ⇒ `## 走查文件第二版（中文欄位名）`」、違規 1 | ✗ —— **同一條、違規 1** | **存量紅，不是本切片**（本切片 diff 沒有碰 `docs/known_issues.md`） |
| `defer-open` | **PASS**（`raid-threshold-recheck-after-grudge` 判「條件未達成」） | ✗ —— 該筆判「**解除條件已達成而它還躺在表上**」 | **是本切片造成的，而且是【預期中的鬧鐘】** |

★**`bed-arm` 的誠實限**：27 這個數字兩邊相同，**只證明我沒有把它變大**；本切片新增的 `scripts/debug/grudge_ledger_bed.gd` 走 `MeasureBedHelper.arm_and_new()`（該檔 :174），所以不在那 27 張裡。★★**它不證明那 27 張不重要** —— 那是既有的未涵蓋存量，歸屬在別人的格子。

★**`defer-open` 那顆紅的內容**（`docs/process/defers.tsv:190`）：
該筆延後裁定的解除條件逐字是「**恩怨帳切片A 的交易估值讀者接完（`ask_price` 帶 `buyer_leader_id`）**」，
機械 met_check 是 `grep -v "^[[:space:]]*#" scripts/simulation/trade_valuation.gd | grep -q "buyer_leader_id"`。
★★**本切片正是把那個讀者接上的那一票** ⇒ 條件被滿足 ⇒ 閘按設計響。
★★★**它要的不是把閘改綠，是去做那件被延後的事**：用同一組 fixture 把掠奪門檻重量一次（`f = 1500` 那格的答案）。
那是量測員的活，**不是我可以自己把那一行刪掉了事**。
