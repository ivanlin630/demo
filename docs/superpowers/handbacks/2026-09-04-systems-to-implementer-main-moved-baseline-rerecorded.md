---
from: systems
to: implementer
status: consumed
slice: peaceful-regime-injection
topic: ★main 已 pushed(政權新檔+順序相依 bug 修+wrapper UTF-8 全在裡面)⇒ 你的 worktree rebase;★★headless baseline 我重錄過——【編碼修正非行為變更】,別把它讀成我放寬了判準;★★★重錄必須用 gate 自己的管線產(我先用 python 產,差在 awk 會壓空白)
---

# ①main 動了 ⇒ **rebase 你的 worktree**

已在 `origin/main`：政權新檔 `config/peaceful_economy_regime.json`／`_setup_explicit_teams` 順序相依 bug 修／
長跑每 10 日中途小結／全 option 勝負池 tap／`tools/godot.ps1` force UTF-8（含你補的 `2b0a5377`）。
**15 支閘全綠 277s。**

# ②★★headless baseline 我重錄了 —— 講清楚它**不是**什麼

```
[HEADLESS] ★FAIL：失敗【清單】與 baseline 不同    ←★merge 後這樣紅,1,9c1,9 全 9 行
```
★**而它是【編碼】不是【行為】**：wrapper 修好 UTF-8 後，中文不再是亂碼位元組 ⇒ 舊 baseline 逐行失配。
★★**我先證了內容沒變才重錄**：ASCII 骨架＋計數逐條比對，**同 9 條、同計數**。
⇒ ★★★**所以這是【重錄基準線】不是【放寬判準】** —— **HARD-FAILS 仍是 3，判準一字沒動。**

★**若你之後看到 baseline 又紅，先做同一件事：證內容有沒有變，再決定重錄還是修 code。**
**先重錄會蓋掉真迴歸。**

# ③★★★重錄的坑（下次你可能會踩）

**baseline 必須用 gate 自己的萃取管線產生**，不能另寫一份：
```
grep -aE "\[FAIL\]|Assertion failed" | sed 's/^ERROR: *//; s/^ *//' | LC_ALL=C sort | LC_ALL=C uniq -c \
  | awk '{c=$1; $1=""; gsub(/[0-9]+/,"N"); sub(/^ /,""); print c" "$0}'
```
★我第一次用 python 產，**只差在空白** —— `awk` 的 `$1=""` 會用 OFS 重組 `$0`，**把連續空白壓成單一空白**。
⇒ ★★**又是「A 承諾、B 兌現要用同一個標識」那條**，這次細到**空白處理**都算。

# ④你手上兩件我沒動

- **warring 90 日 pilot**（`EXCLUSIVE=unknown`）—— ★**目標是找出殺它的是什麼**，不是跑完。
  ★★**逐段落地**：被砍時已跑的段落要留得下結論（`[PilotRun]` 那行存在＝跑完，別用旗標）。
- **`徵收` 那格的新 tap** —— 等你的數字，我不催跑法細節（跑多久/幾次你自己定）。
