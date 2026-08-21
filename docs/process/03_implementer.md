**子 session**（`.worktrees/<feature>/`，`feat/<feature>` branch）：實作 plan。

## ★現況檔 ⏸已停更（開工/完工自更，01 監控用）
> **⏸ 停更中（O1，2026-08-21）**：本現況檔的**更新義務已停**——它宣稱是「即時狀態快照」，實際 `03_implementer` 停在 8/5（16 天）、`04_qa` 停在 8/14（7 天），而且已從快照長成 append log（02 已 153KB）。**★病根：它是「不會過期的手寫狀態」，所以爛了**——對照 `.busy.*` beacon 帶死線會自動過期，兩個方向的錯都不致命。
> **改用**：`bash .claude/hooks/peers.sh`（誰在線＝讀 lock 租約，**推導不手寫**）＋ watchdog v4 的 `open 信/長工作/commit` 分類。
> **處置**：先停更 → 觀察一週（**至 2026-08-28**）沒人 miss → 刪檔。**這段期間不要再寫入。**

收工單開工 → 更 `docs/process/status/03_implementer.status.md` frontmatter `status: working` + `current_ticket: <handback檔名/worktree>`;handback 完 → `status: idle`;卡點呈報 systems → `status: blocked` + 卡點簡述。低成本一行,01(系統) grep 監控。詳 `status/README.md`。

### 第一步（強制）：建立隔離 worktree

**禁止在主 checkout 原地 `git checkout -b`**（會與主 session 共用目錄、撞 git）。子 session 必須跑在獨立 worktree。`executing-plans` / `subagent-driven-development` 不會自動建 worktree，要自己先建：

```powershell
# 在主 repo 根目錄執行，<feature> 換成功能名（kebab-case，對齊 plan 檔名）
git worktree add .worktrees/<feature> -b feat/<feature>
cd .worktrees/<feature>
```

之後所有實作、commit、push 都在此目錄。確認 `git rev-parse --show-toplevel` 指向 `.worktrees/<feature>/` 再開工。

### 子 session 標準流程：

- 將 Spec 轉換成可實作 Plan

必須先閱讀：
- docs/invariants.md

禁止：

- 發明 Spec 沒有的新規則
- 修改世界模型


**開始前：**
```powershell
# 確認 baseline 乾淨
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

**實作工具：** 使用 `superpowers:executing-plans` 或 `superpowers:subagent-driven-development`

**測試標準：**
- 每個 task 完成後跑 headless test
- 必須看到 `=== DONE ===`，無 `SCRIPT ERROR`
- 新功能加對應驗證 print

**Commit 規範：**
```
feat(系統): 功能描述
fix(系統): 修正描述
docs(主題): 文件更新
test: 測試新增/更新
```

**完成後：**

1. 推 branch：
```powershell
git push -u origin feat/<feature>
```

2. 寫 hand-back 到 **★唯一 main mailbox 的絕對路徑**（不是你 worktree 的！）：
   `<main-repo>/docs/superpowers/handbacks/YYYY-MM-DD-implementer-to-<to>-<feature>.md`，frontmatter `from: implementer / to: <measurer|systems|qa> / status: open / topic:`。
   - main-repo 算法：`git rev-parse --path-format=absolute --git-common-dir` 去掉尾 `/.git`（從 worktree 也算得出）。
   - **★為何**：信箱靠實體資料夾共享，你 worktree 的 `docs/handbacks/` 是**另一個資料夾**、下一站 main dir session 看不到。寫 main mailbox 才 live 觸發下一站。**code 留 worktree、handback 寫 main mailbox。**
   - 開場也 arm `Monitor(bash .claude/hooks/inbox-watch.sh, persistent)`（hook 已指 main mailbox）→ systems 寫 to:implementer 的信你也自動讀。

**★★問題/卡點 → `to:systems` handback，禁在自己終端直接問 user（用戶定 2026-07-11）**：
- 遇「設計不明／spec 有歧義／不確定怎麼做／發現前提不對／需裁決」→ **寫 `to:systems` 的 handback 問**（systems 是你的上游、答疑窗口）。**禁在你 worktree 終端直接問 user**——user 是整條鏈的**問題 backstop**，非 implementer 的答疑/QA 窗口；直接問 user = 破壞角色鏈（systems 該接的丟給 user 人肉轉述）。
- 例外＝§3「回報分支給 user」（merge 前告知 branch，非提問）。真需 user 裁的願景/授權，也走 `to:systems` → systems 判斷該不該升 user（不是你直接升）。
- 卡住時：寫 `to:systems status:open` 問 + standby，systems ~20s 內 Monitor 喚醒回你。不空等、不改猜、不問 user。

3. 回報分支給user

```markdown
---
from: implementer
to: measurer          # 下一站(量測員)；也可 systems/qa 視流程
status: open
topic: <功能名稱> 實作交付 — <一句摘要>
---
# Hand Back: <功能名稱>

## 實作摘要
- 改了哪些檔案（每檔一行說明）
- 與 spec 的差異（若有）

## 連動風險
列出其他系統可能受影響的部分，收件方決定是否補修：
- `系統A`：說明為何可能受影響
- （無則寫「無已知連動風險」）

## 待確認
- 設計決策（實作中遇到 spec 未覆蓋的情況）
- 建議後續 task（發現的潛在問題或改進點）
```
★**frontmatter 必帶 `from/to/status/topic`**——否則沒 `to:` = 信箱掃不到 = 下一站不會自動讀（舊式純 topic 已淘汰）。

3. Commit hand-back 文件，不要直接 merge 到 main，等主 session 確認。

4. **finishing-a-development-branch skill 彈出選單時，直接選 Option 3（Keep the branch as-is），不向用戶提問。**主 session 負責 merge。

## ★每-task lifecycle（待命↔worktree，2026-07-09 用戶定）

implementer 是**主目錄 standby session**，per-task 進 worktree 做、做完回主目錄，**主目錄永遠停在 main**（防共用 dir 卡 feature branch 的事故）。

1. **待命**：session 在主目錄 `A:\GDS\demo`（main branch）、arm `Monitor(bash .claude/hooks/inbox-watch.sh, persistent)`，等 `to:implementer` 信。
2. **接 task**：收信 → `git worktree add .worktrees/<feature> -b feat/<feature>`（已存在則 `cd` 進）→ `cd .worktrees/<feature>`。所有實作/commit/push 在此。
3. **做**：照 plan TDD、逐 task commit、跑 godot 驗。**★改既有機制前先查 `docs/mechanism-intents.md`（WHAT 權威方向表）；發現 code 與表不符=呈報 owner 非默改**（用戶立法 2026-08-14；code 服從表、表只服從用戶）。**★報 TDD PASS/FAIL 數字前必實際跑一次、讀印出的 `=== DONE ===` 行真實計數**（別憑印象/半途 grep 湊；連續 S6/S7/A1 三輪自報數≠實際=reviewer grep 抓，2026-07-25 流程項）。**★execution-end TDD 禁 teleport 繞真觸發**（movement/arrival/cadence）——teleport 到 target 會遮 same-tile-no-arrival 型 bug（A1 血證）；須驅真 `MovementSystem.process()` tick 迴圈+`arrived_tick>=0` 斷言，抵達後才驗效果（連 memory `feedback_verify_execution_end`）。
4. **交付（task 完成）**：寫 handback（X-to-Y frontmatter）到**唯一 main mailbox 絕對路徑**（見上 §2）→ **`cd` 回主目錄 `A:\GDS\demo`**（確認 `git branch --show-current`=**main**；worktree 的 feat 分支不動、只 shell 回家；★絕不在主目錄 checkout feat）。
5. **★hold warm 等裁決（完成判定歸 01，非自判）**：**先別清 ctx**。task 是否真完成由**下游裁決**（measure→QA→01/②判），因為 QA 可能 redo。context held warm、待命等 `to:implementer` 的裁決信：
   - **`[REDO]` 信**（要改）→ 你 context 還在，直接改 → 新 handback（回步 4）。**不冷啟**。
   - **`[DONE]` 信**（approved/merged）→ 這時才收尾：**consume 該信 → cd 回主目錄 → 重 arm inbox-watch → 待命下一 task**。**ctx 不用手動清**（`/clear` 是用戶鍵入、agent/hook 不能自 issue → 不強制）；context 累積到滿 Claude Code **自動 compact**，`/compact` 重觸 SessionStart(source=compact) → **職責自動重載**。Stop-hook `implementer-cleanup.sh` 偵 `[DONE]` 逼你做這幾步。

∴ 完成判定歸 01（防過早清 ctx→redo 冷啟）、主目錄恆 main、worktree 隔離改 code、handback 走 main mailbox 自動觸發下一站、職責 compact 後自動重載、**零手動鍵入**。

---

## ★長工作 beacon（watchdog v4 用，2026-08-21 用戶定案）

長工作（長跑量測／大窗 bed／長編譯）**開跑前寫、跑完刪**：

```bash
# 開跑前
echo $(( $(date +%s) + 28800 )) > .claude/hooks/.busy.implementer      # 8h 死線
# 跑完
rm -f .claude/hooks/.busy.implementer
```

**★紀律（設計重點，不是實作細節）**：
- **beacon 只能「壓下」警報，永遠不能「製造」警報**——它讓 watchdog 知道「這裡的靜止是有原因的」，不會反過來讓 watchdog 因為它而報警。
- **帶死線、會自動過期**：忘了刪 → 8h 後自動失效、回到 derived 判斷；忘了寫 → 只是多響一次。**兩個方向的錯都不致命。**
- ⇒ 通則：**手寫狀態只准存在於「會過期」的形式**。這樣拿得到宣告式的準確度，又躲得開「手寫狀態會腐爛」的刀
  （反例：`docs/process/status/*.status.md` 是不會過期的手寫狀態，所以爛了——見 O1）。

**忘了寫 beacon 會怎樣**：watchdog 還有 `ps -W | grep -i godot`（★必須帶 `-W`，實測不帶抓不到 WMI-detach 起的 Godot）
與檔案活動兩層 derived 判斷兜底，所以最壞只是多一次 `CHAIN-BROKEN` 誤報，不會打斷你。

---

## ★裁定：`plans/` 停用，HOW spec 就是唯一產物（systems 裁 2026-08-21）

**背景**：blueprint 在 P9 工單裡把「`plans/` 空目錄＝plan 還欠不欠」交給 systems 前置定。

**實測**（負斷言協議：窮盡、不用 `head`）：
- `docs/superpowers/plans/` **頂層 0 個 md**；遞迴 **52 個全在 `_archive/`**，最新一份 **2026-07-13**。
- 同期 `docs/superpowers/specs/` 頂層 **30 份**活躍，最新是今天。
- ★而 `session-role.sh` 到今天為止**仍叫 implementer「照 `docs/superpowers/plans/` 逐 task 做」**——**指向一個空目錄**。

**裁定**：**不恢復產出 plan，改 doc 宣告**。理由：plan 這個中間產物在 2026-07 已被 **HOW spec 吸收**
（spec 本身就帶 §任務拆解／§驗收法），再維護第二份等於雙寫；**實務上大家早就只寫 spec 了，只有文件沒跟上**。

**連動已修**：`session-role.sh` 的 implementer 指路 → `docs/superpowers/specs/<日期>-<slice>-HOW.md`。
**保留**：`plans/_archive/` 不刪（歷史脈絡）。

★ 這條同時是 P7「三態誠實」的樣本：**一條規則寫在 doc 上、實際沒有東西在執行它，就該明寫，而不是繼續讀起來像已武裝。**

### ★[DONE] 收尾必做：**拆掉本 slice 的 worktree**（用戶拍板 2026-08-21）
```bash
git worktree remove .worktrees/<slice>
```
- **不拆會累積成磁碟黑洞**（**56GB 血案**）。
- ★**worktree 有未 commit 的東西時，先確認那些改動要不要留，別直接拆**
  —— `implementer-cleanup.sh` 會**先判髒不髒**，髒的時候**不會叫你拆**，而是叫你先處理。
