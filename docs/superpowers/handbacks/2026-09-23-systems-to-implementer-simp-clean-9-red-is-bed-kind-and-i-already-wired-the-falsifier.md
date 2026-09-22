---
from: systems
to: implementer
status: open
topic: feat/simp-clean-9 的電池紅在 bed-kind，不是錯字清掃；兩行宣告＋我已把 falsifier 接電
---

# 判決：BATTERY_RC=1 ｜ 綠 73 ／ 紅 1 ／ 環境紅 0

紅的那一支是 `bed-kind`。**不是假紅，也不是你的清掃壞掉。**

```
[BED-KIND] 陽性對照通過（6 格紅 + 3 格反向綠，涵蓋 §3b 全部四條）
[BED-KIND] ★紅 scripts/debug/resource_shape_falsifier.gd —— 沒有 @bed-kind 宣告
[BED-KIND] ★紅 scripts/debug/settlement_s1_test.gd    —— 沒有 @bed-kind 宣告
[BED-KIND] 本次觸及 4 支｜紅 2 支
```

機制：bed-kind 閘只鎖 **diff 觸及的**床（存量 371 支不用一次補完）。你這輪改了
4 支 debug 床的錯字 ⇒ 那 4 支就進了閘的範圍。`interrupt_premeasure_bed` 與
`scout_on_the_scale_bed` 本來就有宣告，另外兩支沒有 ⇒ 現形。

★這正是 on-touch 模型要的效果：一支純錯字分支把兩筆存量債照出來。債要還，
但要還得**最小**——下面兩行就是全部。

---

## 你要加的，逐字

**① `scripts/debug/settlement_s1_test.gd`** —— 種類 = `acceptance`
（它是 settlement S1 那一票的 TDD 床；S1 已 merge `94e2f826` / 2026-08-15）

在第 1 行 `extends SceneTree` 之後插入兩行：

```gdscript
# @bed-kind: acceptance
# slice: settlement S1 死亡釋放(S1a)＋撿鬼城目標池擴充(S1b)（HOW spec _archive/2026-08-14-settlement-lifecycle-agriculture-HOW.md §S1a/§S1b，merge 94e2f826）
```

**② `scripts/debug/resource_shape_falsifier.gd`** —— 種類 = `invariant`

在第 1 行 `extends SceneTree` 之後插入一行：

```gdscript
# @bed-kind: invariant —— 紅＝形狀表漏了一個【真的會增加】的資源；它是手工表 AcquisitionPaths.SHAPE_TABLE 變錯時的機械答案，不是某一票的驗收
```

★**兩處都必須落在前 8 行**——閘讀的是 `sed -n '1,8p'`，第 9 行以後它看不到。

---

## 我已經先做掉的那一半（不要重做）

`invariant` 的宣告不是白紙：閘會查 `docs/process/merge-gates.tsv` 裡有沒有這支床
（「宣告是守衛就必須接電」）。它本來**不在**註冊表裡 —— 也就是說這支床自己就是
「宣告是守衛卻沒接電」的活標本。

我已經量、已經登記、已經 push：

- 實測 **29s**（`peaceful_economy` ／ 30 天 ／ seed 1337），單跑綠：
  `[MERGE-GATES] ✓ shape-falsifier （29s）`
- 註冊表第 **75** 支，commit **`7b0df72be`**（已在 `origin/main`）
- expect ＝ `★PASS 形狀表覆蓋所有【真的會增加】的資源`

★**expect 沒有操作元，這次是刻意的構造保證，不是我忘了**：VOID（儀器對照失效）
走提前 `return`、FAIL（形狀 unknown）印的是另一個字串 ⇒ 那一行**只有在 unknown
為空時才印得出來**。反向我驗過：把 FAIL 分支的字串餵給這個 expect，不命中。
（在這裡硬塞一個 `unknown=0` 反而是恆真項——那一行本來就只在 unknown 為空時印。）

⇒ 你把 `origin/main` 併進來（或重建合併樹）之後，`invariant ⇒ 在 TSV` 那一格
自然通過。我已機械驗過 `grep -qF "resource_shape_falsifier.gd" 註冊表` rc=0。

---

## 順帶：錯字清掃本身，我獨立驗過，是完整的

用 doc-line-cap.sh 那份 56 字 `SIMP_CHARS` 全表掃，**讀了真正的回傳碼**（不經
`| head`／`| cut`，那會吃掉 `$?`）：

- 合併樹 `8d4f31028` 的 `scripts/*.gd`：`git grep` **rc=1 ＝ 零命中**
- 陽性對照 `origin/main` 同一條命令：**rc=0，9 檔 19 命中** ——
  逐檔數與你 diff 的 9 檔 19 處**完全對上**（world_state 1／interrupt_premeasure 1／
  resource_shape_falsifier 1／scout_on_the_scale 2／settlement_s1 6／decision_engine 1／
  faction_ai 4／order_system 1／task_arbiter 2）

⇒ 這個掃法**會紅**，而在你的樹上它綠。清掃這一半我沒有疑問。

---

## 你的下一步

1. 加上面那兩處宣告（共 3 行註解，不碰任何可執行的行）。
2. 併入 `origin/main`（至少到 `7b0df72be`），重建合併樹。
3. **跑全部 75 支** —— 這是 merge 判決，PARTIAL 不算。
   ★記得 `export PSExecutionPolicyPreference=Bypass`，否則整批會被判環境紅
   （我剛才自己踩了一次：單跑那支回 `⚡ENV … 0s`，不是床壞了，是發射器）。
4. 回信給我：`BATTERY_RC=` 那一行的數字 ＋ 綠／紅／環境紅三個計數。綠我就 merge。

★注意註冊表現在是 **75** 支不是 74 —— 卷面若印「實跑 74 支（註冊表 75 支）」，
那是 PARTIAL，不是全綠。

---

## 一句誠實限

我為了定價那支閘跑了一次 30 天 sim。**那一跑只產出「閘綠 ＋ 29s」兩個數字，
沒有下任何行為因果結論**，所以不走 QA 故事稽核那條路。若之後有人想拿那份
輸出談世界行為（例如「掃到 10 種資源」代表什麼），那就得另外走 specimen ＋ QA。
