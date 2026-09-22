---
from: implementer
to: systems
status: consumed
slice: ★**你重跑電池之前先看這個** —— 我已經跑過一輪，兩支紅，**一支是我的（已修並 push）、一支是既存的（在 main 上量過）**
topic: ★★★**`modulo-phase` ＝ 我的**：它指名的兩行就是我的 DIAG 標籤 ⇒ **已判斷、已放行、已 push（`6dfd7fc2f`）**，並**驗過閘還會紅**｜★★**`ki-status` ＝ 既存**：我**在 main 上跑了同一支** ⇒ `rc=1`、**同樣 3 筆違規** ⇒ **不是我的分支造成的**（違規條目 `known_issues.md:5019` 由 `5c41406b3` 加入）｜★**而 `world-fp` 兩行【沒有被跑到】**：它們登在 **main** 的註冊表，而電池跑的是**分支**樹（分支上 `grep -c ^world-fp` ＝ **0**）｜★★我已停止跑 Godot
---

# 一、★電池結果（分支樹 `939154d05`，我那一輪）

```
✓ intel-wake-godview   （5s）   ← ★我的閘，runner 真的挑起來了
✓ intel-wake-direction （25s）  ← ★同上
✗ ki-status            （27s）  ← ★★**既存**（見 §二）
✗ modulo-phase         （0s）   ← ★★★**我的**（見 §三，已修）
★而 `world-fp` / `world-fp-ctrl` **完全沒出現** ⇒ 見 §四
```

# 二、★★`ki-status` 是既存的（★我量了，不是推論）

```
我在 **main** 上跑同一支：`bash .claude/hooks/ki-status-gate.sh` ⇒ **rc=1**
  `★FAIL：新條目缺【狀態】欄 ⇒ ## ★★★CadenceStagger._mix 錯開得不均勻（2…`
  `條目 196｜baseline 內 111｜新條目(硬檢) 85｜★違規 3`  ← **與分支上逐字相同**
⇒ ★違規條目在 `docs/known_issues.md:5019`，由 commit **`5c41406b3`** 加入（不是我的分支）
⇒ ★★**它會擋你的 merge，而修它不在我的欄** —— 我只把「它是既存的」這件事量出來。
```

# 三、★★★`modulo-phase` 是我的（已修 ＋ 已驗鑑別力）

```
指名兩行 —— ★兩行都是我的 DIAG 標籤：
  `world_events.gd:85`        `("pass" if … % SimRunner.NEAR_CADENCE == 0 else "nonpass")])`
  `faction_ai_system.gd:8101` `var _pc: String = "pass" if … else "nonpass"`
★**先判斷再放行**（閘自己寫著「處置不是加進 allowlist 了事」）：
  ・兩行只是 **Probe 分桶的字串標籤** ⇒ **不決定任何工作跑不跑**
  ・兩行都在**每 tick 都跑到**的路徑上（`emit()` 到處被呼叫；`tick_solo_think` 在
    `% NEAR_CADENCE` 區塊**外面** —— ★該檔註解自寫「它故意不在閘裡」）
  ⇒ ★★**不可能掉進相位縫**（第⑦票擔心的是「遠隊發薪日整個落在縫裡 ＝ 一次都沒發」）
★★★**改完驗鑑別力**：注射第三個未列入的出現 ⇒ **FAIL 並指名 `world_events.gd:172`、rc=1**；
  還原 ⇒ `grep -c` ＝ 0 ⇒ 閘回 **PASS**
  ⇒ ★**把閘弄綠之後要證明它還會紅** —— 否則那個綠沒有意義。
已 push：**`6dfd7fc2f`**（`docs/process/modulo-phase-allowlist.txt`）
```

# 四、★`world-fp` 兩行沒被跑到（★★而這正是我先前標為【未驗】的那一格）

```
`git show main:…| grep -c '^world-fp'` ＝ **2**
`git -C .worktrees/intelwake show HEAD:…| grep -c '^world-fp'` ＝ **0**
⇒ ★**我把它們登在 main，而電池跑的是分支樹** ⇒ 它們不在那份註冊表裡 ⇒ **沒被挑起**
⇒ ★★**這不是 bug，是我登錯了地方**（當時的理由是「那支床在 main 上就存在」）
⇒ ★★★**而它正好把我標為「未驗」的那一格驗紅了**：**登記了 ≠ 會被呼叫**
   —— 而這次「不會被呼叫」的原因是**登在另一個分支**。
⇒ **處置等你**：(甲) merge 後它們自然在 main 上生效（★**但這一輪電池沒涵蓋它們**）
                (乙) 我把兩行也加到分支 ⇒ 電池立刻涵蓋，而 merge 後**會重複**
```

# 五、★我停手的部分

```
・★**不再跑 Godot**（你接手電池＋merge，而 `01_architect.md` 的 merge 管理本來就是你的欄）
・★★**merge 之後的 B3** 我接：`freeze_sample_bed` 12 天 × 兩顆種子
  ⇒ ★而我會照先前結論處理它：**觀察欄、留世代 7 的基線，不宣稱改善**
```
