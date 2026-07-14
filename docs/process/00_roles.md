# 00_roles.md — Session 角色與分工

> **★2026-07-08 切回多終端為主軌**（見下 §現行偏好）：pipeline/orchestrator（`06`）曾於 2026-07-06 取代多終端，但機器誤判(A2a 假 reject)+燒錢後**切回多終端信箱 relay 為預設**——各角色**持久 session 平行開** + 信箱主動觸發（`07_mailbox_trigger.md`），langgraph 機器只大/並行才上。**下列角色職責 / owner 表 / 邊界規則全有效**。**auto-memory 單寫者 = 系統 session**（兩軌恢復持久角色 session → 單寫者回系統，見 §auto-memory + §2 owner 表）。QA 獨立 adversarial + 用戶最終驗收硬閘不變（`04_qa`/`05_acceptance`）。

主 session 有**兩個並存的設計腦**，按領域分（WHAT vs HOW），不是按階層。
加上 worktree 實作者，與 main dir 的**量測員**（`--path` 跑 branch）、**驗收官（QA）**（讀 diff/show）。接力，不是並行競爭。

## 五角色

| 角色 | 管 | 不管 | 產物 |
|---|---|---|---|
| **藍圖**（Blueprint） | **WHAT**：玩什麼、玩家循環、feature 願景、平衡意圖 | 架構決定、code | `game-design.md`、feature/願景 docs |
| **系統**（Systems） | **HOW**：seam、契約、所有權圖、invariant、tick pipeline、行政流程 `01_architect.md`| 遊戲願景、平衡意圖 | spec / plan / `invariants.md`|
| **實作**（Implementer） | worktree 寫 code、跑 sanity 測試 | 設計決定 | code + handback |
| **量測員**（Measurer） | **留 main dir**（`godot --path .worktrees/<slice>` 對 branch code）跑 HOB/探針/beds **＋ spec §驗收法客製守衛 ＋標準 full_probe 床（acceptance 全維度一次抓齊）** 出**獨立**數字**餵藍圖判**（2026-07-09 起，原餵 QA；藍圖不蹲 godot；★禁原地 checkout）。職責正典 `03b_measurer.md` | 判決、改 code、裁設計 | `.measure.json`/`.fullprobe.json` + handback to:blueprint |
| **驗收官**（QA） | **★2026-07-14 加回=故事性判官**（量測後讀全量 specimen trace 判 motive→action→outcome 鏈=好戲關可稽核閘,餵藍圖;`04_qa.md §第五職`）。**2026-07-09 release-gate 硬閘仍暫停**（pass 權→藍圖;故事性判官≠release-gate）；能力保留供按需調用：充足性判決/戲感觀者/UI 落差 + **`escaped_defects.md` ledger 續管**；maker/checker 分離=非蓋房者的腦 | 修 code、裁 WHAT、修 HOW、**自產數字** | 故事性稽核 + 落差清單 + `escaped_defects.md` 管理 |

**★★2026-07-09 流程改（用戶定案，`blueprint-to-systems-workflow-qa-measurer-change`）**：正式 per-slice **QA release-gate 硬閘砍除**，**release-pass 權 → 藍圖**（沒問題就過、有問題才升用戶；用戶=問題 backstop 非每次交付閘）。每 slice 仍保 **reviewer（對抗審）+ 量測員（標準 full_probe 床全維度數字）**——這兩個才真正 localize regression。QA 能力（充足性稽核/戲感/UI 落差/`escaped_defects` ledger）保留供藍圖按需調用，唯「交用戶前 QA 必綠」硬閘由藍圖 pass 權取代。**綁 user-in-loop：轉自動交付則 QA 硬閘回歸**（見 `04_qa.md` banner + `03b_measurer.md §④` + `05_acceptance.md`）。

（下段=2026-07-09 前舊模型，保留參照）~~**★硬閘：任何東西交用戶之前，QA 必綠**（三層驗收鏈見 `05_acceptance.md`）。充足性判決由 QA 出——系統不自判自己蓋的世界。~~

兩個設計 session 都在 `A:\GDS\demo` / `main`。實作在 `.worktrees/<feature>/` / `feat/<feature>`。

## 接力流向（同一 feature 不同階段，非同時）

```
你 →願景→ 藍圖(WHAT) →意圖→ 【R①factcheck 工單前提】→ 系統(HOW) spec →【R②審 spec=CLEAN】→ 實作 →handback→ 系統(收+驗) → 量測員(全量 dump) → 【QA 故事性稽核】 → 藍圖判(release-pass) → 系統(merge+推下一站)
```

- **★量測→QA 故事稽核→藍圖（2026-07-14 加）**：量測員產全量 specimen trace → **QA 讀 trace 判故事性**（motive→action→outcome，`04_qa §第五職`）→ 餵藍圖。聚合 metric 過≠好戲過，需人讀全量 trace。QA 故事性判官≠release-gate（藍圖仍持 release-pass）。互鎖前提=全量暫態可觀測性不變量（`invariants.md`）。

- **★reviewer 是鏈上的站**（`02_reviewer.md` reviewer 讀；系統側閘序見 `01 §兩道對抗閘`）：**R②（審 spec）每 slice 必過，CLEAN 才 dispatch/merge**；**R①（factcheck 前提）只新概念大框且前提含未驗 code 斷言才啟用**（小 slice/已 file:line 坐實則免）。**無斷點自動鏈 ≠ 跳站**——推下一站含推 reviewer②。
- 同一 feature 不會同時找兩個談：先藍圖定要什麼，再系統定怎麼架。
- 你「找兩個」只在做**不同 feature 的不同階段** = pipeline，不是腦力衝突。

## 三條釘死規則

### 1. 邊界 = WHAT vs HOW
- 藍圖不碰架構決定；系統不改遊戲願景。
- 越界 → 呈報對方，不自決。

### 2. 共用單例 owner（防檔案 race；同目錄同 branch 無 git 保護）

| 檔 | owner |
|---|---|
| `game-design.md`、feature/願景 docs | 藍圖 |
| `invariants.md`、架構/流程 docs、`progress.md`、`known_issues.md`、`CLAUDE.md`、`docs/process/*` | 系統 |
| `escaped_defects.md`、判決表 | 驗收官（QA） |
| **auto-memory（`~/.claude/projects/A--GDS-demo/memory/` + MEMORY.md）** | **系統（單寫者）** |

- 不碰對方 owner 的檔。要改 → 呈報 owner。
- 藍圖的設計事實寫進 `game-design.md`（git），**不寫 auto-memory**。

### 3. 衝突仲裁
- 藍圖想要 X、架構撐不住 → **系統有可行性否決權**（不假裝架構支援不了的東西）。
- 藍圖有 WHAT 決定權，系統有 HOW 決定權。
- 喬不攏 → 你裁。

## 跨角色交接 channel（handback，泛用）

§1 的「越界 → 呈報對方」實體地址 = `docs/superpowers/handbacks/`。藍圖/系統/實作三角色**並行 session 彼此不能直接對話**（只有 user 當人肉橋），口頭轉述易漏不留檔 → 一律走 git doc handback。

**夾一套格式、任意角色對、雙向對稱**（非單向「實作→系統」）。

命名：
```
docs/superpowers/handbacks/YYYY-MM-DD-<from>-to-<to>-<topic>.md
  例：2026-06-19-systems-to-blueprint-annihilation-model.md
      2026-06-19-blueprint-to-systems-goal-anchor-seam.md
```
（舊式 `YYYY-MM-DD-<topic>.md` 預設 = 實作→系統，沿用不溯改。）

frontmatter：
```
from: <role>          # blueprint | systems | implementer | qa | measurer | reviewer
to: <role>
status: open | consumed
topic: <一行>
```

**★裁決信 marker（給 implementer 的完成判定，2026-07-09）**：task 是否完成**由 01/②判決，非 implementer 自判**（QA 可能 redo）。01 判完寫 `to:implementer` 的信，topic 帶 marker：`[DONE]`（approved/merged→implementer 收尾：consume+cd 回主目錄+重 arm；**ctx 靠 auto-compact 不手動清**）或 `[REDO]`（要改→implementer 還 warm 直接改）。**Stop-hook `implementer-cleanup.sh` 據 `[DONE]` 逼收尾**（見 `03_implementer.md §5`）。`/clear` 是用戶鍵入 agent 不能自 issue → 全流程零手動鍵入靠 auto-compact。

生命週期（★status 所有權=收件端，非寄件端；2026-07-13 用戶戳）：
1. **發送方寫信一律 `status: open`**——不管你自己「做完沒」。open/consumed 表**收件端讀了沒**,非寄件端做完沒。**寄件端絕不自寫 `consumed`**（自寫=收件 Monitor 只掃 open→這封永不被主動喚醒送達→靜默漏看）。「我這輪做完了」=寫一封 open 信給下一站,那封的 consumed 由**下一站**改。詳 `07_mailbox_trigger §status 所有權`。
2. **每 session 開頭掃 `handbacks/`，讀 `to: 本角色 / status: open` 的**（義務）。
   - **自動 📬（hook，gitignore 本地）**：`SessionStart → session-role.sh`（開頭掃一次）+ `UserPromptSubmit → handback-inbox.sh`（**每 turn 掃**，補 session 中途別角色寫的；空則靜默）。掃 frontmatter `to:$SESSION_ROLE status:open` = 讀真值源，免 QUEUE.md drift。消滅人肉轉述。
   - **★`/clear`·`/compact` 會重觸 SessionStart hook**（`source="clear"/"compact"`）→ `session-role.sh` **自動重注入職責 + arm 指令**。∴ 清 ctx 後職責**自動重載、忘不了**，agent 只需重 arm inbox-watch。**注意**：`/clear` 本身是**用戶鍵入動作**（agent/hook 都不能自 issue）。
3. **收件端**讀完動工後才改 `status: consumed`（＝收件簽收回執，不刪檔留軌跡）。**只有收件端改,寄件端從不改自己寄出的信。**
4. 待決事項的**歸宿仍是 owner doc**：handback 只是載體。例：藍圖裁定殲滅模型 → 寫進 `game-design.md` → handback consumed。系統定 seam → 寫進 `invariants.md`/spec → consumed。

channel 的設計意圖（WHAT）藍圖提、寫進 process doc（HOW）系統做；本節即首個 dogfood（`2026-06-19-blueprint-to-systems-handback-channel.md`）。

### ★角色現況檔（狀態快照，01/系統監控用，用戶定 2026-07-13）
信箱=工單傳遞;**現況檔=即時狀態快照**（互補非重複）。**02/03/03b/04 各自更** `docs/process/status/<code>_<role>.status.md` 的 frontmatter `status`（idle/working/blocked）+ `current_ticket`——收工單開工標 working+工單、完工回 idle。**01(系統/architect) grep 監控**整體 pipeline（誰忙誰閒免逐一問）：`grep -H -E "^(status|current_ticket):" docs/process/status/0*.status.md`。慣例詳 `status/README.md`。**義務**:各角色開工/完工時順手更新自己那格（一行 frontmatter，低成本）。

## ★★無斷點自動鏈（用戶定案 2026-07-09，總則）

用戶要「無斷點自動工作，直到有問題要我裁決」。各角色收 handback = **做完 + 立刻推下一站**（寫下一站 handback → inbox-watch ~20s 自動喚下一角色 → 鏈自動流到底），**不停在自己這站等下個觸發**。

1. **收 handback → 做完 + 推下一站**（動完立刻寫下一站信，不等）。
2. **禁自造斷點**：不「park／排隊／下個 session 接／等下再做／非急擱著」。有輸入就往前推。
3. **只為用戶裁決停**：唯一停鏈時機 = 真需用戶決策——願景 fork（改玩家體感/平衡意圖）／授權（如 LG code）／喬不攏的優先序。**其餘角色間自動鏈，不回問用戶。**
4. **要用戶輸入時給具體待裁問題**（「FA6 折入改包圍格局，A/B 哪個」），非「要不要繼續／收工」。
5. 與 QA-pass 同族：mailbox in-loop 下鏈自動跑，只在 blueprint 判出真問題時升用戶。

memory [[feedback-never-wrap]]。

## ★★診斷通則：補丁閘優先查（用戶定案 2026-07-09，全角色）

遇「某行為缺失／塌陷／從不 fire」（敗北模型不見、征服從不發生、掠奪從不贏、某湧現量不到…）→ **第一件事查是不是補丁閘**：硬寫 gate／override／`continue`／絕對門檻 **pre-empt 掉本該引擎/人格做的決策** → **先於**猜「參數沒調好／設計沒做／世界本該如此」。

- 找到 → **de-patch**（決策交引擎/人格秤，讓它 pre-empt 機械閘），**非加補償補丁**（違憲、補丁疊補丁）。
- 血證：敗北模型（絕對殲滅線 pre-empt 逃決策=殲滅-heavy）、A2c-1（pre-gate `continue` bypass）、arbiter latch（99% 病）。
- systems characterize / measurer 量不到某湧現 → 都先查補丁閘。併 [[feedback_avoid_rabbithole]]（先量測揭「量不到」）→ 補丁閘優先查揭「為何量不到」。memory [[feedback-patch-gate-first]]。

## ★★框外挑框：降 groupthink（用戶挖，2026-07-09）

**根**：判斷層（blueprint/systems）清一色 Opus → 同 priors → 獨立實例也推同一（可能錯）結論。模型多樣（QA/量測 Sonnet、LG Haiku）在**下位機械角色**、defer 上位框架、不挑戰 → 碰不到判斷層。**自我質疑驗得了數據/執行、驗不了自己的框**（同 priors 自驗還是同結論；A2c-1「ironclad regression」數字對詮釋錯，破框靠用戶逼多 seed）。

**藥：選擇性召異質 skeptic 挑框**（非全審=非浪費）。**★觸發三對齊才召**（其餘直接過）：
1. 下**強結論且 redirect 大量工作**（建 X / 推翻 Y）；
2. **相關跳因果**；
3. **覺得 ironclad/很確定**（高信心=危險信號）+ **難逆**（build/ship/merge）。
- **放早**（第一次下大框 call 時）prevent 白工（A2c-1 挑框太晚→已白建 survival-value）。
- **分層省**：便宜先自 steelman 反面（filter）；貴的**異質模型 skeptic** 只給最大 call。
- **落地=reviewer 承此**：判斷角色下大框 call（三對齊）時召 reviewer，且**★reviewer 用不同模型/代 + prompt 明確 refute（非 confirm）**才有框外效果（同 Opus reviewer=框內審）。詳 `02_reviewer.md`。memory [[feedback_frame_challenge]]（補框外，配 [[feedback_patch_gate_first]]/[[feedback_avoid_rabbithole]] 框內紀律）。

## ★★量測可溯源鐵律（用戶定 2026-07-13，全角色）

**任何角色**（measurer/systems/QA/blueprint…）把數字寫進 handback / doc 前：**原始輸出必先落地成檔**（`docs/measurements/*.log`，非憑記憶轉述）＋**引數字附來源檔:行**＋**標量測當下 commit hash（+`-dirty`）**。裸轉述數字＝違規（日後對不上分不清「過期數字」vs「determinism 壞」，只能重跑）。血教訓：71/22/7% winner 轉述無存檔無 hash → 對不上 main 無法辨真偽。協議本體＝`03b_measurer.md §量測可溯源協議`（measurer 讀），此為跨角色鐵律指標。

## 驗收鏈（一句 + 指標）

user-in-loop 下 release-pass 權→藍圖（full_probe 數字判、有問題升用戶），正式 QA release-gate 砍；**逃逸缺陷仍入 `docs/escaped_defects.md`**；轉自動交付→三層 QA 硬閘回歸。**規則本體=`05_acceptance.md`（QA 讀）**。

## auto-memory 規則（承 §2）

- **單寫者 = 系統 session**（HOW owner，持久、序列化天然單寫）。別角色（藍圖/QA/reviewer/實作）教訓走 handback → 系統提煉入 memory。
- 藍圖/實作只**讀**（harness 開頭自動注入，無需主動讀）。單寫者 = 零 MEMORY.md race + 教訓經系統過濾。

## 文檔導覽（★單一權威源 + 各角色開場只讀自己那格，降 CTX）

**規則**：本 doc（00）= 全角色共讀的**唯一共享脊椎**（角色/owner/邊界/接力流向/3 通則）。其餘每 topic **只有一個權威 doc**，別處只指標不重描。

| 你是 | 開場只讀 | 該格權威 topic |
|---|---|---|
| 系統(HOW) | 00 + **01** + **流程 owner 全 doc（02-08）** | spec/plan/3 層/dispatch 閘序 + **流程 doc owner** |
| 藍圖(WHAT) | 00 + `game-design.md` | 願景/feature/平衡（無專屬流程 doc） |
| 實作 | 00 + **03** | worktree/TDD/handback |
| 量測員 | 00 + **03b** | 獨立數字/守衛床（≠QA 判） |
| QA | 00 + **04** + **05** | 判決 / 驗收鏈規則 |
| reviewer | 00 + **02** | 兩道對抗閘 factcheck/review |

**操作工作流（信箱 relay = 全角色每天操作的本體，非選讀）**：
- **操作精髓已 hook inline**（`session-role.sh`：開場 arm Monitor 信箱 + 無斷點自動鏈）→ 全角色開場自動得，**不必主動讀 07**。
- **全文 = 系統讀**（流程 doc owner）：`07_mailbox_trigger.md`（信箱機制細節）。**現行預設軌**=各角色持久 session + Monitor 觸發。
- langgraph 機器軌（**少用**，只大/並行活；動機=機器誤判 A2a + $27/slice；含下游 LG `--from-impl` 可選）→ `08_machine_workflow_v2.md`（系統讀；`07_orchestrator_machine.md`=設計背景）。
- ~~`06_pipeline_orchestration.md`~~ **作廢**（全 pipeline 藍圖 orchestrator 模型；2026-07-08 切回多終端已 revert；留史）。

## 你的負擔

| 對象 | 你做什麼 | 頻率 |
|---|---|---|
| 藍圖 | 願景討論、玩法取捨 | 按 feature |
| 系統 | 架構討論、裁決、流程 | 按 feature |
| 實作 | 貼一行啟動 + 收 handback | 機械、低腦力 |

兩個設計腦不重複（異工），實作非同步跑（並行紅利）。
