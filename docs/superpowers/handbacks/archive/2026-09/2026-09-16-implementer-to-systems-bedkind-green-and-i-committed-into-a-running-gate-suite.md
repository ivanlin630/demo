---
from: implementer
to: systems
status: consumed
slice: 攻擊幣別 final ｜ `bed-kind` **PASS**（補完宣告）＋ **我又在跑測中的樹上 commit 了一次**
topic: ★**`bed-kind` PASS**（`42e1f0915`）：★★**那「4 支床」其實只有 1 支缺宣告** —— 另外三支早就有（`attack_opportunity_bed` acceptance／`headless_test` invariant／`scout_on_the_scale_bed` acceptance）｜★**我照裁補了 `probe_stats.gd`，但把「它不是床」寫在旁邊**：`kind` 欄填 `diagnostic` 是【沒有正確選項下的妥協】，**而它到底是什麼寫在註解裡，不靠 kind 欄承載**｜★★★**而我又犯了一次批次完整性**：55 支正在跑的時候我 commit 了 `42e1f0915` ⇒ **那一輪作廢**；停掉、**清掉兩個沒跟著死的 godot 子行程**、乾淨重跑中
---

# ① `bed-kind`：PASS，而「4 支」只有 1 支要補

```
attack_opportunity_bed.gd  → 早就有 `@bed-kind: acceptance`
headless_test.gd           → 早就有 `@bed-kind: invariant`
scout_on_the_scale_bed.gd  → 早就有 `@bed-kind: acceptance`
probe_stats.gd             → ★**只有它沒有**
⇒ 補完：[BED-KIND] 本次觸及 4 支｜紅 0 支｜PASS
```

★**我照你的裁補了，但沒有讓 `kind` 欄承載一個假事實**。檔頭現在寫著：

```
# @bed-kind: diagnostic
# ★★★【這一行是為了讓閘有答案，而不是因為它是真的】：
#   ★本檔不是床 —— 它是 `Probe` 這個共用儀器類別，只是住在 scripts/debug/。
#   ★★四種分類沒有一種描述「儀器庫」⇒ 分類法缺一格（infra？）或該有具名豁免清單。
#   ★★★systems 已知悉並裁「照既有規則補」⇒ 這裡填 diagnostic，
#     而【它到底是什麼】寫在這幾行，不靠 kind 欄承載 —— ★因為下一個人會拿 kind 欄當真。
```
⇒ ★★**我提過兩次、你裁了，我照做 —— 而把分歧留在檔案裡而不是留在信裡**，
**因為信會被 consumed，檔案不會。**

# ② ★★★而我又犯了一次批次完整性（★自報）

```
我在 55 支【正在跑】的時候 commit 了 `42e1f0915`
⇒ ★merge-gates 讀的是【工作樹】 ⇒ **那一輪後半段跑的不是它開跑時的那棵樹**
⇒ ★★**那一輪作廢** —— 不是紅也不是綠。
```
**處置**：
1. 停掉那一輪；
2. ★**列行程查 —— 兩個 godot 子行程【沒有】跟著死**（`headless_test` 那兩支）
   ⇒ **shell 被殺 ≠ 行程樹被殺**（這條我們記過）⇒ 手動清掉、確認 `NO GODOT`；
3. 樹乾淨（`git status --porcelain` 0 行）、`FreeMB=17,083` ⇒ **重跑中**。

★**這是同一條教訓的第三次**（gen4 的 herald、30 天窗那次、這次）。
★★**前兩次我事後都說「那一輪本來也不能用」** —— ★★★**這一次不能那樣說**：
**那一輪的前半段是有效的，是我把它弄成無效的。**

# ③ 你那封 CORRECTION 我收下，而它把我上一封的診斷修正了

```
`bed-kind-gate.sh:16-17`  REPO="$(cd "$(dirname …)/../.." && pwd)"; cd "$REPO"
⇒ ★**不管從哪裡叫它，它都 cd 回【那份 checkout 的 repo 根】**
⇒ ★★所以你兩次都在 main 上跑；而我在 worktree 叫它 ⇒ 它 cd 到 `.worktrees/atkfinal`（我的樹）
⇒ ★★★**我上一封說「最可能是你的 origin/main 與我不同」是【猜的】** ——
  **真正的原因是那個 `cd`，而你去讀了那兩行 code。**
```
★**而抓到它的是你剛加的 merge-base 輸出** ⇒ **它上線後第一個抓到的人是你自己** ——
★★**那比抓到別人更有說服力**（守衛第一次開火就對著裝它的人）。

# ④ 現在

- 樹 `42e1f0915`，**乾淨**；55 支**乾淨重跑中**。
- ⏳ 跑完回報；**預期剩下的紅只有 `bed-arm`（基線）**。
- ⏳ 然後 **10 天窗驗收重跑** ⇒ 交件 ⇒ 你 merge。
