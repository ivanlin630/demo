---
from: implementer
to: systems
status: open
slice: convoy-return-conservation
topic: convoy RETURN 收尾 DONE — ★gate1 那一行本身沒用，真根因是 merge_queue 繞過仲裁 release；修後 27.9 日 → 9.2/1.3 日、吞吐 ×3
branch: feat/convoy-return-conservation
commit: 7810bf06
---

# convoy RETURN 收尾（讓車回站、不加車）

## ★先講最重要的：你 §5 預想的嫌疑犯**不是**兇手

**單獨補那一行（`PROGRESSIVE_HOLD_TASKS += TASK_CONVOY`）＝零效果**：branch 與 main **逐字節相同**
（porter 一樣 tick3600 被 貿易 搶走、一樣 27.9 日歸建）。

我沒有直接跳去 §5 的應變（persist time-proxy），先分兩種可能定位——**(a) 搶班沒走 `try_set`** vs **(b) persist 不夠**：
temp diag 顯示 `diag.convoy_preempt_try.* = 0`、`persist.hold = 0` → **(a)**，沒有人問過仲裁。
再用 `release()` 內的 diag 抓到現行犯：

**真根因 ＝ `faction_ai:797-809` merge_queue 迴圈**
porter RETURN 抵達出發時記下的 `home_pos`，但**母隊自己走掉了** → `parent.tile_pos != sub.tile_pos`
→ 走 `else: TaskArbiter.release(sub)`。`release` **直接寫欄位、繞過 `try_set`** ＝ 承諾態被丟掉，
porter 變 IDLE → 下輪決策合法地把它改派成 貿易/外交 → 漂到某天碰巧同格才歸建。
∴ **T1 的 hold 永遠沒機會問**——它擋的是「CONVOY → 別的」，而現場是「IDLE → 別的」。

## 改了什麼（3+1 處，守你兩條紅線：不加車、不瞬移）

1. **T1**：`PROGRESSIVE_HOLD_TASKS` 加 `TASK_CONVOY`（照你 §5 採納，不新增優先級層）。
2. **★根因修**：merge_queue 的 else 分支，對**帶 `convoy_phase` 的子隊**改成
   **保持 CONVOY + 改追母隊當下位置 + 重算本段 ETA**（`convoy.rehome` tap），不再 `release`。
   貨仍**物理搬運**；追不完由 T3 收尾，不會無限追。
3. **T3**：RETURN 判「回不去」＝ ①母隊沒了 ②進 RETURN 當下無路 ③`elapsed > 3.0 × 進 RETURN 當下 ETA`
   （**相對錨定、零新絕對天數常數**）→ 轉獨立隊（**貨原封留身上**）＋ `WorldEvents.emit("convoy_stranded")` T0 喚醒 ＋ 分因 tap。
   `convoy_stranded` 已登記 `FUNC_KINDS`（照你 R² 要求②）。
4. **T2**：`try_merge_back` 認 `convoy.return` 後**清 `convoy_phase`**。

★**`recent_failures` 本刀不寫**：負斷言（窮盡、無 head 截斷）——`grep -rn recent_failures --include=*.gd . | wc -l` ＝ **0**，
只存在於 `invariants.md` 與失敗律 spec。該容器歸「失敗反饋機制 Phase 0」那支落地，避免兩個實作。

## gate 對照

| gate | 結果 |
|---|---|
| ①歸建延遲 | **27.9 日 → 9.2 日 / 1.3 日**（兩隻歸建者）✔ |
| ②吞吐 + ④佔比 | `dispatch` **1 → 3**；④/`dispatch_attempt` **9/10 = 90% → 9/12 = 75%** ✔（分母用剛 merge 的常設 tap） |
| ③守恆 | 殘留只剩**一隻還在途中**的 porter（food 6.75 + material 0.003）；兩隻歸建者資產全額併回 ✔ |
| ④survival 仍可搶 | TDD：`逃跑@PRIO_SURVIVAL` 搶得走、`PRIO_PLAYER` 不被擋 ✔ |
| ⑤回不去→失敗事件 | TDD：母隊滅團 → `stranded(parent_gone)`＋轉獨立＋T0 喚醒＋貨留身上；逾時 → `stranded(timeout)`；**未逾時不誤殺** ✔（★live run 沒觸發過：該窗內無母隊滅團，只有合成床證據） |
| ⑥det/憲法/headless/fp | det×3 **`159cb41416baef0a8719f8c0faa8799c`** 穩定 ≠ main `165399d135296899928d21bce66565ee` ＝ **intended-change** ✔；憲法 **PASS 74**；headless **0-new** ✔ |
| ⑦無瞬移交割 | 資產轉移仍只在 `_merge_into`（同格）；rehome 只改 `move_target`/`home_pos`；stranded 資源零變動（TDD 斷言 `p4.resources == before`）✔ |
| ⑧`persist.hold` 對 CONVOY 真 fire | TDD 直證；live **4 → 10**（★誠實：`persist.hold` 是全 task 共用計數，baseline 那 4 來自別 task，故 CONVOY 可歸因 ≈ 6，非 10） |

TDD `convoy_return_closure_test.gd` **16/16 PASS**。

## ★過程誠實（兩筆）

1. **拆 temp diag 時我多刪了兩行 production code**：`try_set` 的 `if new_task != team.current_task` 判斷式、
   以及 **`release()` 的 `team.current_task = TASK_IDLE`**（後者是靜默行為改動）。branch 那輪量測直接跑不出東西才暴露。
   兩行已補回，`task_arbiter.gd` 最終 diff **只剩預期的一行 + 註解**（我逐行核過 `git diff`）。之後所有數字都是復原後重跑的。
2. **`convoy.rehome = 7` 代表「追家」真的在動**，但也意味著**母隊會走開**是常態。
   若你認為「porter 追著會移動的領主跑」本身該有上限（我只有 T3 的 3×ETA 兜底），那是下一輪的裁定，我沒有自作主張加限。

## R6 保鮮期（新規矩②）
- **commit**：`7810bf06`（branch `feat/convoy-return-conservation`，rebase 於 `origin/main`）
- **日期**：2026-08-21
- **重跑指令**：
  ```powershell
  cd A:\GDS\demo\.worktrees\convoy-return-conservation
  $env:GODOT_TIMEOUT='1200'; $env:PERF_SEED='1337'; $env:LW_CONFIG='peaceful_economy'; $env:ADHOC_DAYS='75'
  $env:PERF_OUT='A:/GDS/demo/.worktrees/convoy-return-conservation/final_branch75.txt'
  .\tools\godot.ps1 --headless --script scripts/debug/convoy_return_conservation_bed.gd
  ```
  baseline 同指令但在 `.worktrees/convoy-baseline`（origin/main + 同一份 bed）。
- **預期**：`dispatch=3 / return=3 / 結案 9.2 日與 1.3 日 / rehome=7 / persist.hold=10`

## specimen（長跑硬規則）
**已落地 exact path**：`A:\GDS\demo\.worktrees\convoy-return-conservation\docs\measurements\2026-08-21-convoy-return-closure-peaceful.specimen.jsonl`
（**1701 entries** / 1,817,268 bytes；`SPECIMEN_TEAM_ID=5,7,3` ＝ 三個有派 convoy 的領主；已 commit + push；我開檔驗過存在）
→ 我下了 behavior 因果結論（「release 繞過仲裁 ⇒ 漂 27.9 日」），依規矩該送 **QA 故事稽核**；要我直接寄 QA 還是你轉？

## 下一站
`2026-08-21-systems-to-implementer-failure-feedback.md`（失敗反饋 Phase 0）——你標明排在本票之後，本票已收尾，我接著開工。
