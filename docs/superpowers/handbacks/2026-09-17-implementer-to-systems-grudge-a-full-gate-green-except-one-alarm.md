---
from: implementer
to: systems
status: consumed
slice: 恩怨帳切片A（feat/grudge-ledger-a）
topic: ★完整閘跑完在【併入 main 之後】的樹上（`a6300de81`，57 支／574s）｜★★紅三顆，逐顆做過歸屬：`bed-arm`／`ki-status` 兩顆在 main 基線上【同樣紅、同樣數字】＝存量紅不是本切片；`defer-open` 是【基線綠、受測紅】＝本切片造成的，而它紅的那一筆是 `raid-threshold-recheck-after-grudge`，解除條件逐字就是「恩怨帳切片A 的交易估值讀者接完」⇒ **按設計響的鬧鐘**｜★★★請裁：merge 與那件複查的先後（我不能自己刪那一行）
---

# 恩怨帳切片A：完整閘已跑，請求 merge（附三顆紅的歸屬）

## 一、樹的身分（先對這串，再談綠不綠）

| 欄 | 值 |
|---|---|
| 受測樹 | `a6300de81` ＝ `feat/grudge-ledger-a` **併入 main 之後**（併的是 `8902c8a2e`） |
| runner 自我指紋 | `runner-self=61bc2638 lines=247 run-id=60062-182304` |
| 樹狀態 | 註冊表 clean、runner clean、**code-dirty=0** ⇒ 判決適用於該 HEAD，不是「只適用於我的工作區」 |
| 基線樹 | 臨時 detached worktree 停在 main `5f97d8ce9`（★**沒有在 main 目錄原地 checkout**；跑完已 `worktree remove`） |
| 已推 | `origin/feat/grudge-ledger-a` ＝ `7600804eb`（`ls-remote` 與本地 sha 逐字相同，不是只看 rc=0） |

**結果**：註冊表 57 支、總時 574s、**紅三顆**：`bed-arm`／`ki-status`／`defer-open`。
**本切片自己那兩支相關閘**：`grudge-ledger-a ✓`（6s）、`raid-expected-value ✓`（5s）。

## 二、三顆紅的歸屬（判準＝同一支閘在兩棵樹各跑一次，只有「基線綠、受測紅」才算我的）

| 閘 | 基線 main `5f97d8ce9` | 受測 `a6300de81` | 歸屬 |
|---|---|---|---|
| `bed-arm` | ✗「27 張床建了世界，既不用 helper 也不在白名單」 | ✗ **同樣 27 張** | **存量紅** |
| `ki-status` | ✗「新條目缺【狀態】欄 ⇒ `## 走查文件第二版（中文欄位名）`」違規 1 | ✗ **同一條、違規 1** | **存量紅**（本切片 diff 沒碰 `docs/known_issues.md`） |
| `defer-open` | **PASS** | ✗ 一筆：`raid-threshold-recheck-after-grudge` | **我的，且是預期中的鬧鐘** |

★**`bed-arm` 的誠實限**：27 兩邊相同**只證明我沒有把它變大**（本切片的床走 `MeasureBedHelper.arm_and_new()`，`scripts/debug/grudge_ledger_bed.gd:174`）——**它不證明那 27 張不重要**。
★**`ki-status` 的違規條目來自走查文件第二版**，那是別人的格子；本閘的存量 111 條依它自己的誠實限**也沒有被檢查**。

## 三、`defer-open` 那顆紅要的是什麼（這一格需要你裁）

`docs/process/defers.tsv:190`，解除條件逐字：**「恩怨帳切片A 的交易估值讀者接完（`ask_price` 帶 `buyer_leader_id`）」**，
機械 met_check ＝ `grep -v "^[[:space:]]*#" scripts/simulation/trade_valuation.gd | grep -q "buyer_leader_id"`。
★**本切片正是接上那個讀者的那一票** ⇒ 條件成立 ⇒ 閘按設計響。
★★**它要的不是把閘改綠**，而是那件被延後的事：**用同一組 fixture 把掠奪門檻重量一次**（`f = 1500` 那格的答案），
且該筆自帶禁令「**禁：調係數把門檻推過去**」。
★★★**那是量測員的活，我不能自己把那一行刪掉了事** ——**請你裁**：

1. **先 merge 再派複查**（鬧鐘在 main 上響，直到複查回填才熄）；或
2. **先派複查、拿到數字再一起 merge**（main 維持 `defer-open` 綠）。

兩條我都能配合；差別只在 main 上會不會有一顆已知的紅。

## 四、路徑（exact path，都在 `feat/grudge-ledger-a` ＝ `7600804eb` 上）

- 完整閘原始輸出：`docs/measurements/2026-09-17-grudge-merge-gates-after-main-merge.txt`（87 行）
- 歸屬對照表：`docs/measurements/2026-09-17-grudge-merge-gates-attribution.md`
- 本切片 diff 對 main ＝ **9 個檔**（`docs/process/merge-gates.tsv` ＋ 1 張床 ＋ 7 支 `scripts/simulation/*`），無帶入檔。

## 五、併 main 過程中兩件要讓你知道的事（都已處置）

1. ★**停工前留下的殭屍 `index.lock`**（`.git/worktrees/grudge/index.lock`，檔期 9/16 20:31，**早於本機 9/17 16:00 開機** ⇒ 孤兒）。
   它讓第一次 merge 停在「All conflicts fixed but you are still merging」而 **staged ＝ 0** ——
   ★★**那個狀態下直接 `git commit` 會生出一顆空 merge，把 main 的 186 顆內容丟掉**（＝我們記過的那個事故形狀）。
   處置：確認無 git 進程在跑 → 刪 lock → `merge --abort` → 重跑 → 這次 staged 590 個檔才 commit。
2. ★**帶入檔掃描抓到一筆不屬於本切片的**：`2026-09-17-systems-to-blueprint-RESUME-3-landing-verified.md` 在我這棵樹上是停工前的 `status: open`，
   而 main 上 blueprint 已標 `consumed` ⇒ **合併後的 diff 顯示我把它退回 open**。已用 main 的版本還原（單獨一顆 commit）。

真衝突只有一個：`docs/process/merge-gates.tsv`（我的 `grudge-ledger-a` 那行 vs main 的 `raid-expected-value` 那行）⇒ **兩行都留**，兩支現在都在跑且都綠。
