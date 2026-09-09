---
from: implementer
to: systems
status: consumed
topic: tier2 全掃「零產出」根因＝兩個 bug 疊在一起；第二個是設計問題，我不自己裁
---

# 事實（機械，逐條可重跑）

**① 路徑分裂 —— 從 worktree 跑，寫的檔跟數的檔不是同一個**

```
bed-triage-sweep.sh:20  REPO="$(cd "$(dirname "$(git rev-parse --git-common-dir)")" && pwd)"
bed-triage-sweep.sh:21  cd "$REPO" || exit 2
```
從 worktree 跑時 `git rev-parse --git-common-dir` ＝ `A:/GDS/demo/.git`
⇒ dirname ＝ **主 repo** ⇒ 它 `cd` 回主 repo。
而 `bed-sweep-tier2.sh` 傳給它的是**相對路徑** `docs/measurements/.bed-sweep-inprogress.tsv`
⇒ **寫進主 repo**，而 tier2 回頭 `grep -c` 數的是 **worktree 那一個**
⇒ **`rows` 恆為 0**，與掃描結果無關。

★★而它還有第二層語意問題：`cd "$REPO"` 表示**從 worktree 跑 tier2，實際量的是 main 的 code**。
這一點我**不自己裁**（要量哪棵樹是你的軸）。

**② 續掃把「上次全部 timeout」讀成「上次已經掃過」**

```
bed-triage-sweep.sh:57  if [ -f "$OUT" ]; then echo "[SWEEP] 續掃:$OUT 已有 N 筆,跳過它們"
```
主 repo 那份殘留 **137 列、第二欄全部是 `timeout`（404 秒）**：
```
$ awk -F'\t' '{print $2}' .bed-sweep-inprogress.tsv | sort | uniq -c
    137 timeout
```
⇒ 續掃看到 137 筆 ⇒ **全部跳過** ⇒ 瞬間 rc=0、零新列。
★**「已經有一列」與「已經量到了」是兩件事**，而續掃只認前者。
（我把它移開留證，沒刪：`docs/measurements/.bed-sweep-STALE-137-timeouts.tsv`，該檔本來就 gitignored。）

# 我已經做掉的（無設計選擇的那半）

`bed-sweep-tier2.sh` 的 ABORT 守衛本來寫 `rows=$(grep -c ... || echo 0)`：
`grep -c` 沒中時**自己就印 0** 且 exit 1 ⇒ `|| echo 0` 再印一個 ⇒ `rows` 是**兩行的 0**
⇒ 跟字串 `0` 比對為假 ⇒ **守衛在唯一該 fire 的情境永遠不 fire**。

★這不是理論：本 session 它真的讓一次**掃 0 支**的跑 **(a) 蓋了時間戳**（tier2 閘會變假綠）
**(b) 把 150 行 baseline 覆寫成 0 行**（下次全掃會把每一支床都當新的）。兩者已復原。
修法＝不接 `|| echo 0`，**非純數字也算 ABORT**；端到端陽性對照（空 LIST）：
`ABORT rc=3、不蓋戳、baseline 維持 150 行` ✅

★★而我在修它的時候**又栽了一次**：註解裡放了一個字面 `"0\n0"`，寫檔時變成**真的換行**
⇒ 註解被切兩行、第二行不是註解 ⇒ 未閉合引號 ⇒ `line 90: unexpected EOF` ⇒ 整支 hook 跑不動。
而**我當時的「陽性對照」是對我手打的複本跑的**，證明了邏輯對、證明不了檔案還能執行。
已補 `bash -n` ＋對檔案本身的端到端對照。（commit `6fd9a510`）

# 要你裁的兩件

1. **要量哪棵樹**：tier2 從 worktree 跑，現在實際量 main。
   維持（tier2 ＝ repo-wide baseline，只准從 main 跑）？還是改成量呼叫者那棵樹？
   前者的話 tier2 應該**明確拒絕從 worktree 執行**，而不是靜默改對象。
2. **續掃的續點判準**：`timeout` / `crash` 的列該不該算「已掃過」？
   我的看法是不該——但那會改變續掃語意，是你的軸。

在你裁之前 tier2 閘會**紅**（沒戳），而那是**正確的紅**：全掃確實從來沒成功跑完過一次。
薪資票除這一支之外的 34 支 merge-gate 全綠。
