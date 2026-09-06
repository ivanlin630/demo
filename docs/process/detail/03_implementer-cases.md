# 03_implementer 的血證與案例（按需讀）


## ★現況檔 ⏸已停更（開工/完工自更，01 監控用）


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


## ★★「改測」的合法性判準（systems 立 2026-08-21，血證 ＝ 四端同秤刀）

| 條件 | 說明 |
|---|---|
| **(a) 法條被授權變更** | 該行為的規則**被 blueprint／用戶明示改過**（不是實作者覺得該改） |
| **(b) 只改編碼、不改不變量** | 找出那條測試**真正在保護什麼**，新斷言**必須仍然保護同一件事** |
| **(c) 新編碼不得比舊的弱** | 換掉的斷言**至少同強度**；能更強更好 |

**非法**：為了讓紅變綠而**弱化**斷言、放寬容差、刪掉 case。

### 血證：`T1:覓食 base 恆 1.0`（`headless_test.gd:1988/14480/14482/15119`）
- 測試寫法：`ctx.food_days = 1.0` → assert `== 1.0`；`ctx.food_days = 30.0` → assert `== 1.0`
- ★**它真正保護的不變量 ＝「`survival_pressure` base 不隨 `food_days` 變（飢餓在 coeff）」**，
  `== 1.0` 只是**當時那個公式下的編碼**。
- 四端同秤把 base 改成「腳下 tile 真實可採日流」後：**飢餓仍然不在 base** ⇒ **不變量沒破，是編碼過期了**。
- ∴ **合法改測**，且新斷言必須**更強**：
  ① `food_days` 1.0 與 30.0 兩次 eval **必須相等**（★**相對斷言，零魔數** —— 比舊的 `== 1.0` 強，
     因為它直接測「不隨飢餓變」而不是測一個特定數值）
  ② **新增**：同 ctx 下「腳下自家營地 tile」vs「荒地 tile」⇒ **兩者必須不同**（證位置盲已解）
- ★**附帶觀察**：舊斷言裡的 `== 1.0` **本身就是一顆手抄常數**。
  **測試也適用〈禁手抄物理〉** —— 能寫成相對／結構斷言的，就別釘死一個數值。


## ★★★重構的「fp 不變」是等價證明，**不是執行證明**（2026-08-25）

| fp 不變證明了 | fp 不變**沒有**證明 |
|---|---|
| ★**新接線算出來的值 ＝ 舊值** | ★★**新接線【有被執行到】** |

★**反例**：**新 code 根本沒被呼叫**（舊路徑還在跑）⇒ **fp 當然不變** ⇒ **你證明了一段沒跑的 code 跟舊的一樣。**

★★**這是「gate 沒擋 ≠ gate 沒執行」的同族**（血證：`bridge.no_go_food = 0` 不是 gate 沒擋，是**那段 code 從未執行**）。

**⇒ 規矩：等價性重構要交【兩個】證據**
1. **fp 不變**（等價）
2. ★**新路徑有被執行的證據**（tap／counter／assert，**非零**）

★**缺任何一個都不算完成。**


## ★★★失敗處置有【兩個正交軸】：**會不會叫** vs **會不會停**（2026-08-25，我下錯指令的血證）


|  | ★**不停** | ★**停** |
|---|---|---|
| ★**不叫** | **原本的 `[FAIL] print`** ＝ 恆真式第五型（判準沒接） | — |
| ★**叫** | ★★★**正解：可數不致命** | `assert`（★**在會中止的 build 上 ＝ 撞第一個就死，後面全不跑**） |

★★**而失敗的輸出【看起來像成功】**：`ASSERT=5 ＝ baseline` —— **數字對得上，因為後面根本沒跑。**
★★★**抓到它的是【結尾標記】** —— 兩小時前才因為 parse error 那次加上的。
> ★**一條規則抓到了另一條規則造成的傷害。**

**⇒ 規矩**：★★**要求改變「失敗處置」之前，先確認該機制的【失敗語義】—— 叫 ≠ 停，兩軸要分開指定。**

## ★部分完成的跑，與完成的跑，長得一模一樣（2026-09-01，implementer 自訂正）
```
上一封報「抽樣 11 ok / 1 候選」⇒ ★正確是【10 ok / 2 候選】
成因：★★背景任務還沒跑完就把數字寫進信裡
而漏掉的那一張（s3b_body_probe）是【真盲床】,不是過度回報 —— ★★★結論方向也錯了
```
★**判準**：**報數字之前，先確認【產生那些數字的東西已經跑完】** ——
★★**因為部分完成的跑一樣會輸出數字，它不會說自己還沒跑完。**
★★★同族：今天的「真數字掛在錯母體上」「落地≠通知」——**都是【輸出存在】被當成【事情完成】。**

### ★而處置的形狀是對的
發現後**立刻發訂正信**、標明哪一句錯、修掉那張真盲床、並附上驗證。
★**不是等下一封順帶提** —— ★★**因為下游可能已經拿那個數字去做事了**（我當時已在回信裡引用「11 ok / 1 候選」）。

## ★開跑前先 grep `known_issues`（blueprint 立 2026-09-01）
★**要量一件事之前，先 `grep docs/known_issues.md` ★★【與 `docs/archive/resolved_issues.md`】（2026-09-02 起雙目標：已結案的搬進 archive，只查前者會重造）** —— ★★**它可能已經被記過，而你正要重新量它。**
★★★血證 `:728`：「製造 no-op 混三因」早就記著，2026-09-01 仍有一輪重新量了它。
（★檢索義務明確涵蓋本檔；★★而派票端的對應紀律：票裡要有「已 grep known_issues：<結果>」一行。）

## ★GDScript 找函式：`^func ` 會漏掉 `static func`（systems 立 2026-09-01）
★**一律用 `^\s*(static )?func `。** ★★血證：我用 `^func ` 找「誰累積 breed_progress」，
它跳過真身（`static func`）落在下一個 plain func 上 —— ★★★而那個是【退休空殼】，
而我拿它當「機制實存」的證據寫進了 `known_issues`。
★**規模**：`scripts/` 全域 600/4130（14.5%）是 static；★★而在 production 母體下是 36%，
**且有 39~49 個檔【整檔皆 static】—— 對那些檔，`^func ` 每一行都會答錯。**

## ★多段刪除用 anchor，不用行號（systems 立 2026-09-05，implementer 血證）
★**每刪掉一段，後面所有行號就全錯** —— 而編輯工具不會抗議，它照著你給的（現在已經指錯地方的）行號動手。
★★血證：③收束時用行號做多段刪除 ⇒ 誤刪 `cs.append(...)`、留下孤兒 `if` 與半截 dict literal ⇒ **把 production 檔改壞**。
★★★而 Godot 只報 `Could not resolve class BeliefSystem, because of a parser error`，**不指出真正壞的那一行**
⇒ **第一層看起來像是「測試檔」壞掉** —— 錯誤訊息把你導向錯的檔。
★**真正的破口不是「用了行號」，是【anchor 沒對上就退回行號，而退回的那一步沒有補上驗證】**
⇒ 規則：anchor 對不上 ⇒ **先弄清楚為什麼對不上**（多半是空白/全形字/CRLF），**不是換一種定位方式**；
真的要退回行號，**每刪一段就重新取一次行號**，且刪完**立刻**跑一次語法檢查再繼續。

## ★改 Probe key 時，**同一顆 commit 要一起改讀者**（systems 立 2026-09-05）
```
★血證:code 的 tap 改指新閘(salary.tick.mod.* → salary.tick.due.*),而【床的讀者沒改】
⇒ 卷面印「modulo 命中 0 次」,而【下一行】是「進入 _pay_salary 65 次」
⇒ ★★「一次都沒命中」與「發了 65 次薪」【不可能同時為真】
```
★**新形態**：這不是「儀器沒開」也不是「事情沒發生」，是**【儀器改名了而讀者沒跟著改】**
—— ★★而**孤兒讀者印出來的 0，跟真的 0 一模一樣**。
★★★**而救它的是【同一張卷上的另一個數字】**（65 就在下一行）——
**那正是對帳式的價值：兩個數字互相矛盾時，儀器的毛病會自己跳出來，不必靠誰想起來去查。**
⇒ **規矩**：①改 key ＝ 同一顆 commit 改讀者；②**卷面盡量讓兩個相關的數字並列**（能互相打臉的那種）。

## ★★★長跑／三跑 determinism 必須在**不會被編輯的樹**上跑（systems 立 2026-09-05）
```
★血證:背景三跑進行中,改了它【正在讀】的那個 .gd
   ⇒ run1/run2 逐位元相同,run3 只有 12 行:`Parse Error: Identifier "FactionAiSystem" not declared`
   ⇒ ★★而那個 FAIL 【不能拿來當 determinism 的結論】(無論哪個方向)——run3 根本沒跑
★新變體(同族第 5 次):不是 edit-then-run 吃掉錯誤,是【edit-during-run 打斷正在跑的那一份】
   —— ★★★Godot 是【跑到才載入】那個 .gd,所以「開始跑了」不代表「檔案已經被讀完」
```
★**機械修法（不是「記得別編輯」）**：
```
①determinism／長跑一律在【暫時 worktree】跑(git worktree add --detach <短路徑> <commit>)
   ⇒ ★那棵樹沒有人會編輯,而它【綁在一顆 commit 上】=「跑的是哪一版」本身可查
②★★而主樹照常編輯 —— 兩件事不再互相打斷
③★★★若真的要在主樹跑:跑之前 `git stash list`/`git status` 不夠 ——
   要的是【跑完之前不碰那些檔】,而那是【承諾】不是【機制】⇒ 所以選①
```

## ★★★假紅的代價跟假綠一樣大（implementer 揭 2026-09-05，systems 立）
```
★血證:determinism run1 vs run2 sha 不同、而【行數一樣】
   ⇒ 逐行 diff:60 行差異【全部是】 `[TickPerf] day=N avg=…us max=…us … teams=18 factions=2`
      ↑★teams/factions 完全相同 —— 差的只有【儀器自己印的耗時】
   ⇒ ★★成因:過濾器抓 `usec`,而它印的是 `us`
⇒ 補上之後 run1/run2 【逐位元相同】
```
★★**方向相反，代價相同**：
```
假綠 ⇒ 讓人【不查】
假紅 ⇒ 讓人【不再看這支閘】—— ★★★而一支沒人看的閘,跟沒有那支閘一樣
```
★**而這次若只看 sha 不同、沒去看那 60 行，結論會是「⑦ 破壞了 determinism」** —— **一個完全錯的、而且會擋掉正確修法的結論。**
⇒ **規矩**：determinism/回歸的過濾器**要對【自己印的東西】做一次陽性對照**（故意讓儀器多印一行，確認它被過濾掉）；
★★**而 sha 不同時，第一件事是【逐行 diff】不是下結論** —— **「不同」有兩種：世界不同，與【卷面不同】。**

## ★★★背景指令裡**不得有對 repo 檔案的寫入**（systems 立 2026-09-06，同族第 4 次）
```
★血證:把「改 lod_perf_bed」＋「跑 warring perf」【串在同一個背景指令裡】
   ⇒ python 的 anchor assert 失敗,而【那個 traceback 在背景任務的輸出裡,沒有人看】
   ⇒ 後面用 `;` 接的 powershell 【照樣起跑】—— 用的是【沒改到的床】
   ⇒ ★★它會再跑滿一個月、再被砍,而執行者會以為是「配置沒生效」
   ⇒ ★★★抓到它的是 `git status` 顯示【那個檔沒有 diff】—— 不是任何人「發現」的
```
★**而「知道規則、寫下規則、然後在忙的時候違反規則」＝ 靠記得是不夠的**（他自己的原話）。
★★**判準（可分辨，不是一刀切）**：
```
✅ 背景指令【寫到 scratchpad／log 檔】—— 正當,而且必要(那是它的產物)
✗ 背景指令【寫到 repo 內的檔】(sed -i／python write_text／> 到 scripts,docs／git commit)
   ⇒ ★因為那一步失敗時【沒有人看得到】,而後面的步驟【照樣跑】
```
★★★**而【不做 PreToolUse hook】的理由要寫死**：要機械分辨「寫到 repo」vs「寫到 scratchpad」
需要**解析 shell**，★而**解析 shell 的守衛本身會是新的假陽性來源** —— 今天已經有兩道閘因為
「解析出錯而靜默通過」被抓過。⇒ **改用兩個便宜的、已被證明有效的動作**：
```
①背景跑【之前】:`grep -n` 驗改動【已經落地】(而不是相信 edit 成功了)
②背景跑【之後、讀結果之前】:`git status --porcelain` —— ★若宣稱「只跑不改」而有 diff ⇒ 停
   ⇒ ★★這正是這次真的抓到它的那個動作,把它從【意外】變成【程序】
```

## ★★★一個判準的守衛，**不該靜默壓掉另一個判準**（implementer 揭 2026-09-06）
```
★血證:驗收床的【薪資窗長守衛】只管薪資那一條,卻擺在【所有判準之前】而且 `return`
⇒ 短窗時把【與窗長無關的】三系統判準【一起吞掉】
⇒ ★★卷面只印「窗太短」⇒ 看起來像【一條沒過】,實際是【三條根本沒跑】
⇒ ★★★而「沒跑」與「跑了沒過」在卷面上長得一樣
```
★**規矩**：守衛的作用範圍**不得大於它守的那個判準** —— 要 `return` 就只 `return` 它自己那一段。
★★**而檢查方式很便宜**：**看那個守衛之後【還有幾條判準】** —— 有的話它就不能 `return`。

## ★★★批次刪行的自檢要寫成**兩型**（同日，同一個人踩的第二型）
```
①【被刪的行夾帶其他敘述】 ⇒ `git diff -U0 <path> | grep "^-" | grep ";"`
②★【被刪之後有區塊變空】 ⇒ if/for/while/func/match 的下一非空行縮排 <= 該行 ⇒ 空塊 ⇒ Parse Error
   (血證:`if OS.get_environment("FORCE_FULL_HD") == "1":` 底下【唯一那行】被整行刪掉)
```
★★**而他自己的話值得原樣留著**：**「我只做了①，而【①做得很仔細】反而讓我覺得已經防住了。」**
⇒ ★★★**一個仔細的檢查會製造「已經防住了」的錯覺** —— 而**錯覺的強度跟那個檢查做得多仔細成正比**。
⇒ **抓到②的是 `bed-parse` 閘，不是他的自檢** —— **機械防線與自檢的分工，這一格是現成的例子。**
