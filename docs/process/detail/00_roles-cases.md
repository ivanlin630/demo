# 00_roles 的血證與案例（按需讀，不在開場必讀區）

**必讀版留【規則本體】，這裡放【它為什麼成立】。**

> ★**2026-08-25 #4：開場讀不完的規則，等於不存在。**

## 五角色

| **實作**（Implementer） | worktree 寫 code、跑 sanity 測試 | 設計決定 | code + handback |
| **量測員**（Measurer） | **留 main dir**（`godot --path .worktrees/<slice>` 對 branch code）跑 HOB/探針/beds **＋ spec §驗收法客製守衛 ＋標準 full_probe 床（acceptance 全維度一次抓齊）** 出**獨立**數字**餵藍圖判**（2026-07-09 起，原餵 QA；藍圖不蹲 godot；★禁原地 checkout）。職責正典 `03b_measurer.md` | 判決、改 code、裁設計 | `.measure.json`/`.fullprobe.json` + handback to:blueprint |
| **驗收官**（QA） | **★2026-07-14 加回=故事性判官**（量測後讀全量 specimen trace 判 motive→action→outcome 鏈=好戲關可稽核閘,餵藍圖;`04_qa.md §第五職`）。**2026-07-09 release-gate 硬閘仍暫停**（pass 權→藍圖;故事性判官≠release-gate）；能力保留供按需調用：充足性判決/戲感觀者/UI 落差 + **`escaped_defects.md` ledger 續管**；maker/checker 分離=非蓋房者的腦 | 修 code、裁 WHAT、修 HOW、**自產數字** | 故事性稽核 + 落差清單 + `escaped_defects.md` 管理 |

**★★2026-07-09 流程改（用戶定案，`blueprint-to-systems-workflow-qa-measurer-change`）**：正式 per-slice **QA release-gate 硬閘砍除**，**release-pass 權 → 藍圖**（沒問題就過、有問題才升用戶；用戶=問題 backstop 非每次交付閘）。每 slice 仍保 **reviewer（對抗審）+ 量測員（標準 full_probe 床全維度數字）**——這兩個才真正 localize regression。QA 能力（充足性稽核/戲感/UI 落差/`escaped_defects` ledger）保留供藍圖按需調用，唯「交用戶前 QA 必綠」硬閘由藍圖 pass 權取代。**綁 user-in-loop：轉自動交付則 QA 硬閘回歸**（見 `04_qa.md` banner + `03b_measurer.md §④` + `05_acceptance.md`）。

兩個設計 session 都在 `A:\GDS\demo` / `main`。實作在 `.worktrees/<feature>/` / `feat/<feature>`。


## 接力流向（同一 feature 不同階段，非同時）

- **★量測→QA 故事稽核→藍圖（2026-07-14 加）**：量測員產全量 specimen trace → **QA 讀 trace 判故事性**（motive→action→outcome，`04_qa §第五職`）→ 餵藍圖。聚合 metric 過≠好戲過，需人讀全量 trace。QA 故事性判官≠release-gate（藍圖仍持 release-pass）。互鎖前提=全量暫態可觀測性不變量（`invariants.md`）。
- **★★QA 故事稽核不可跳（2026-07-18 用戶戳·systems 違反血證）**：release-gate 砍（2026-07-09）**≠故事稽核砍**——別 conflate 把整 QA 站丟。**canonical 鏈量測→QA 故事稽核→藍圖不可跳；QA session 沒開=flow owner flag blocker（arm QA / 呈報），非 silent skip 藉口**。**QA 故事稽核 ≠ multi-seed（兩軸）**：multi-seed 驗「普不普適(跨世界)」、QA 驗「故事對不對(隊在演啥)」；**單 seed trace 就足以故事稽核（餓死vs戰死），不必等 multi-seed**。血證：threat-oracle/starvation 全走量測員數字→藍圖跳 QA→systems 把「attrition 升」誤讀成 combat 好戲餵藍圖（實=starvation，沒人讀單 seed 死因故事）。連 memory [[feedback_qa_inversion]]。
- **★★QA-verdict 機械閘（2026-08-04 用戶定，治 hook 連漏）**：QA 故事稽核在鏈序裡但**鎖點零 gate**＝advisory 靠記憶必漏（§5/饑荒-flee/anomaly 三因果沒過 QA 就鎖 spec）。**治本＝gate 裝執行點**：**含因果結論的 handback 必帶 `QA:<ref 或 PENDING>` 欄；spec 鎖在長跑因果上、來源無 `QA:<ref>`（或 PENDING）→ systems 拒鎖**（詳 `01_architect §spec 鎖在長跑因果`）。量測員 findings 必附 specimen→QA（`03b_measurer §⑤`）。**通則：hook 提醒 ≠ gate，gate 裝執行點（鎖/merge）非 advisory 上游**（memory [[feedback_self_approve_gate]]）。**鏈序含 QA-ref**：長跑→量測(附 specimen)→**QA 故事稽核(出 verdict ref)**→verdict(帶 QA:ref)→systems 鎖/merge。

- **★reviewer 是鏈上的站**（`02_reviewer.md` reviewer 讀；系統側閘序見 `01 §兩道對抗閘`）：**R②（審 spec）每 slice 必過，CLEAN 才 dispatch/merge**；**R①（factcheck 前提）只新概念大框且前提含未驗 code 斷言才啟用**（小 slice/已 file:line 坐實則免）。**無斷點自動鏈 ≠ 跳站**——推下一站含推 reviewer②。
- 同一 feature 不會同時找兩個談：先藍圖定要什麼，再系統定怎麼架。
- 你「找兩個」只在做**不同 feature 的不同階段** = pipeline，不是腦力衝突。


## 三條釘死規則

### 2. 共用單例 owner（防檔案 race；同目錄同 branch 無 git 保護）

| 檔 | owner |
|---|---|
| `game-design.md`、feature/願景 docs | 藍圖 |
| `invariants.md`、架構/流程 docs、`progress.md`、`known_issues.md`、`CLAUDE.md`、`docs/process/*` | 系統 |
| `escaped_defects.md`、判決表 | 驗收官（QA） |
| **auto-memory（`~/.claude/projects/A--GDS-demo/memory/` + MEMORY.md）** | **系統（單寫者）** |

- 不碰對方 owner 的檔。要改 → 呈報 owner。
- 藍圖的設計事實寫進 `game-design.md`（git），**不寫 auto-memory**。
- **★禁原地 checkout（全角色 canonical，2026-07-09 事故規則）**：`A:\GDS\demo`（main）是全 session 共用工作樹 → **絕不原地 `git checkout <branch>`**（會換掉所有共用此 dir 的 session 的 branch，別人 commit 落錯分支）。看 branch 內容用 `git show <branch>:<file>` / `git diff main..<branch>`；跑 branch code 用 `godot --path .worktrees/<slice>`；實作在獨立 worktree。各角色 doc 只指此條。

### 3. 衝突仲裁
- 藍圖想要 X、架構撐不住 → **系統有可行性否決權**（不假裝架構支援不了的東西）。
- 藍圖有 WHAT 決定權，系統有 HOW 決定權。
- 喬不攏 → 你裁。


## 跨角色交接 channel（handback，泛用）

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
> **★2026-08-21 harness v2**：watcher arm 改**搶佔式**（新的一定贏、舊的印「讓位」自退）；lock 帶 `session_id` ⇒ 「覆蓋仍在」變成**可驗證事實**；`SEEN` 落地 ⇒ **重 arm 不重吐**；**每 turn 閘**在你打字時就告訴你 watcher 掛了。細節見 `07_mailbox_trigger §收件端`。
1. **發送方寫信一律 `status: open`**——不管你自己「做完沒」。open/consumed 表**收件端讀了沒**,非寄件端做完沒。**寄件端絕不自寫 `consumed`**（自寫=收件 Monitor 只掃 open→這封永不被主動喚醒送達→靜默漏看）。「我這輪做完了」=寫一封 open 信給下一站,那封的 consumed 由**下一站**改。詳 `07_mailbox_trigger §status 所有權`。
2. **每 session 開頭掃 `handbacks/`，讀 `to: 本角色 / status: open` 的**（義務）。
   - **自動 📬（hook，gitignore 本地）**：`SessionStart → session-role.sh`（開頭掃一次）+ `UserPromptSubmit → handback-inbox.sh`（**每 turn 掃**，補 session 中途別角色寫的；空則靜默）。掃 frontmatter `to:$SESSION_ROLE status:open` = 讀真值源，免 QUEUE.md drift。消滅人肉轉述。
   - **★`/clear`·`/compact` 會重觸 SessionStart hook**（`source="clear"/"compact"`）→ `session-role.sh` **自動重注入職責 + arm 指令**。∴ 清 ctx 後職責**自動重載、忘不了**，agent 只需重 arm inbox-watch。**注意**：`/clear` 本身是**用戶鍵入動作**（agent/hook 都不能自 issue）。
3. **收件端**讀完動工後才改 `status: consumed`（＝收件簽收回執，不刪檔留軌跡）。**只有收件端改,寄件端從不改自己寄出的信。**
4. 待決事項的**歸宿仍是 owner doc**：handback 只是載體。例：藍圖裁定殲滅模型 → 寫進 `game-design.md` → handback consumed。系統定 seam → 寫進 `invariants.md`/spec → consumed。

channel 的設計意圖（WHAT）藍圖提、寫進 process doc（HOW）系統做；本節即首個 dogfood（`2026-06-19-blueprint-to-systems-handback-channel.md`）。

### ★角色現況檔（狀態快照，01/系統監控用，用戶定 2026-07-13）  ⏸ **已停更（O1，2026-08-21）**
> **⏸ 停更中（O1，2026-08-21）**：本現況檔的**更新義務已停**——它宣稱是「即時狀態快照」，實際 `03_implementer` 停在 8/5（16 天）、`04_qa` 停在 8/14（7 天），而且已從快照長成 append log（02 已 153KB）。**★病根：它是「不會過期的手寫狀態」，所以爛了**——對照 `.busy.*` beacon 帶死線會自動過期，兩個方向的錯都不致命。
> **改用**：`bash .claude/hooks/peers.sh`（誰在線＝讀 lock 租約，**推導不手寫**）＋ watchdog v4 的 `open 信/長工作/commit` 分類。
> **處置**：先停更 → 觀察一週（**至 2026-08-28**）沒人 miss → 刪檔。**這段期間不要再寫入。**

信箱=工單傳遞;**現況檔=即時狀態快照**（互補非重複）。**02/03/03b/04 各自更** `docs/process/status/<code>_<role>.status.md` 的 frontmatter `status`（idle/working/blocked）+ `current_ticket`——收工單開工標 working+工單、完工回 idle。**01(系統/architect) grep 監控**整體 pipeline（誰忙誰閒免逐一問）：`grep -H -E "^(status|current_ticket):" docs/process/status/0*.status.md`。慣例詳 `status/README.md`。**義務**:各角色開工/完工時順手更新自己那格（一行 frontmatter，低成本）。


## ★★無斷點自動鏈（用戶定案 2026-07-09，總則）

3. **只為用戶裁決停**：唯一停鏈時機 = 真需用戶決策——願景 fork（改玩家體感/平衡意圖）／授權（如 LG code）／喬不攏的優先序。**其餘角色間自動鏈，不回問用戶。**
4. **要用戶輸入時給具體待裁問題**（「FA6 折入改包圍格局，A/B 哪個」），非「要不要繼續／收工」。
5. 與 QA-pass 同族：mailbox in-loop 下鏈自動跑，只在 blueprint 判出真問題時升用戶。

memory [[feedback-never-wrap]]。


## ★★框外挑框：降 groupthink（用戶挖，2026-07-09）

2. **相關跳因果**；
3. **覺得 ironclad/很確定**（高信心=危險信號）+ **難逆**（build/ship/merge）。
- **放早**（第一次下大框 call 時）prevent 白工（A2c-1 挑框太晚→已白建 survival-value）。
- **分層省**：便宜先自 steelman 反面（filter）；貴的**異質模型 skeptic** 只給最大 call。
- **落地=reviewer 承此**：判斷角色下大框 call（三對齊）時召 reviewer，且**★reviewer 用不同模型/代 + prompt 明確 refute（非 confirm）**才有框外效果（同 Opus reviewer=框內審）。詳 `02_reviewer.md`。memory [[feedback_frame_challenge]]（補框外，配 [[feedback_patch_gate_first]]/[[feedback_avoid_rabbithole]] 框內紀律）。


## 文檔導覽（★單一權威源 + 各角色開場只讀自己那格，降 CTX）

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

**★2026-08-21 新法索引（三條都不住在本 doc，開場必須知道去哪找）**：
- **執行失敗反饋鐵律**（用戶立法）：執行失敗＝事件、必反饋決策層、**禁靜默丟棄**；同一原因**禁無記憶反覆撞** → 本體與 HOW 四項在 **`invariants.md`〈執行失敗反饋鐵律〉**。
- **長考閘**（用戶立法）：**半成品禁跑驗收考**；驗收考＝清單清零、診斷考＝**對齊審查**（一道閘兩模式）→ **`process/09_exam_gate.md`**。
- **事件比例計算**（用戶拍板、取代「LOD／重要性」語彙）：模擬層零 LOD、計算跟隨**事件密度**不跟隨觀察者 → spec `2026-08-20-event-proportional-compute-HOW.md` + `progress.md`〈效能 arc〉。


## 你的負擔

| 實作 | 貼一行啟動 + 收 handback | 機械、低腦力 |

兩個設計腦不重複（異工），實作非同步跑（並行紅利）。

---


## ★P7 三態誠實表（用戶核 2026-08-21；`docs/process/*` 每條流程規則標「有沒有東西在檢查它」）

**為什麼**：`docs/process/*` 現在**讀起來全部都像已武裝**，實際幾乎全靠 agent 自律。
敢寫下「這條宣告了但沒有東西在執行」，比假裝有守誠實得多。
★ 而**兩態不夠**——用戶 2026-08-04 就立過法：**hook 提醒 ≠ gate**。所以分三態：

| 記號 | 意思 |
|---|---|
| 🔒 **enforced** | 機器會**擋**（gate 失敗／`decision:block`／merge 前紅燈） |
| 🔔 **advisory** | 機器**偵測到並告訴你**，但攔不住（hook 注入提醒／Monitor 事件） |
| 📜 **declared** | **沒有任何東西在檢查**，純 agent 自律 |

### 現況（2026-08-21 盤，`.claude/hooks/` + `scripts/debug/` 逐支對照）

| 規則 | 態 | 執行者 |
|---|---|---|
| 憲法 site-freeze（禁新增引擎外 task 指派／god-view） | 🔒 | `constitution_gate.gd`（merge 前跑，`current ⊆ baseline`） |
| implementer 收尾（consume／回主目錄／提醒重 arm） | 🔒 | `implementer-cleanup.sh`（Stop hook，`decision:block`） |
| 母體地板（普查塌到 0 不得讀成綠） | 🔒 | `expect-min-gate.sh`（exit 1） |
| **空 merge／改動被丟**（git 說已合併但 code 不在樹上） | 🔒 | `merge-verify.sh`（exit 1）——**每次 merge 後跑**。血證 `4bdce7c1` |
| **QA verdict 存在**（長跑因果類 slice） | 🔒 | `seam-gate.sh` 驗 `qa: required` → 有 `from: qa` 的 slice handback（HARD 擋 merge）。**2026-08-04 立、2026-08-21 從自律升機械** |
| **共用 main 禁全量 `git add`** | 🔔 | `bash-guard.sh`（PreToolUse，**warn-only／fail-open**）——血證：別角色 WIP 被掃進他人 commit |
| **長跑兼職互斥**（起 Godot 前查別人的 beacon） | 🔔 | `bash-guard.sh` 同上——兩角色同時長跑會互相拖慢並污染 perf 量測 |
| **[DONE] 後拆 worktree** | 🔔 | `implementer-cleanup.sh` Stop hook 把「拆」寫進 nag，**並先判 worktree 髒不髒**（髒的不叫你直接拆）。56GB 血案根治 |
| **承諾即檔名**（信裡說「已派」必附檔名） | 🔔 | **收件端簽收時 `ls` 驗**（執行點在收件端）——`07 §承諾即檔名`。**機器不驗散文**，見下列 |
| 「信裡承諾了一張票、但票沒開」 | 📜 | **無機器，且全自動化不可行**（**prose ≠ schema**）。★血證：systems 自己犯兩次（T3 派工單沒推／gate9 票只寫在被 consumed 的信裡）|
| 量測主張保鮮期（R6） | 🔒 | `stale-claims.sh`（exit 1／2）**但只綁新寫的** |
| 交接縫產物齊全（P9） | **🔒** | ★**2026-08-21 已轉 HARD（預設擋 merge）**。轉前兩件對齊完成（measurer `.measure.json` `slice`＝branch id；HARD 只管轄**有含 `tier` 派工單**的 slice）＋逐 slice 表**零誤殺**。逃生門 `SEAM_MODE=soft`。**已 merge 的舊 slice 仍讀紅＝歷史殘影，閘不會再擋它們**（見 `01_architect §P9`） |
| 信箱主動觸發（別人寫信會叫醒你） | 🔔 | `inbox-watch.sh`（Monitor 事件） |
| 每 turn 未讀提醒 | 🔔 | `handback-inbox.sh` |
| **watcher 失聰偵測** | 🔔 | `handback-inbox.sh` 每 turn 閘（**warn-only／fail-open，刻意不擋**） |
| 停滯／鏈斷（含出貨沒推下一站） | 🔔 | `watchdog.sh` v4（喚醒 blueprint，**blueprint 才決定推不推用戶**） |
| 角色在線 | 🔔 | `peers.sh`（純讀，供人與 watchdog 用） |
| L 層級判定（L1/L2/L3） | 🔔 | `layer-check.sh`（PreToolUse 注入提醒，**攔不住**） |
| 長跑必經 QA 故事稽核 | 🔔 | `longrun-qa-gate.sh`（PostToolUse 注入，**攔不住**） |
| **感知鐵律**（決策讀 belief 非 god-view） | 🔒**半** | `constitution_gate` 抓得到 `gv_mapscan`/`gv_teamstate` 這類**已指紋化**的 god-view；**新形態的隔空作用抓不到** |
| **R② 每 slice 必過 reviewer** | **🔒**（受 P9 管轄的 slice） | P9 HARD 後，**有含 `tier` 派工單的 slice 缺 R² verdict ＝ 擋 merge**；未宣告的仍在母體外（📜） |
| status 所有權（寄件端不自寫 consumed） | 📜→🔔 | inbox-watch v2 會把「誤寫 consumed」的信**撈出來一次**（治得到症狀，治不到寫的人） |
| **QA-ref 鎖閘**（含因果結論的 handback 必帶 `QA:<ref\|PENDING>`；無則 systems 拒鎖 spec） | 📜 | **無機器**——寫在 00_roles:30、由 systems 人工守。★「這段有沒有下因果結論」是判斷題，機器判不了；能機器化的只有「宣告了要 QA 卻沒附 ref」 |
| 無斷點自動鏈（收信＝做完＋推下一站） | 📜 | 只有 `COMMIT-NO-LETTER` 間接偵測；**「有沒有推對下一站」沒有東西在看** |

### ★★覆蓋欄：**「機制已立」≠「機制已覆蓋」**（用戶／blueprint 核准 2026-08-25）

**帳上把一條律／守衛記成 `done`／🔒 時，必須同時記【覆蓋率】。**

### ★★覆蓋率是**雙側**的（systems 自糾 2026-08-25，blueprint 裁）
| 側 | 問 | 血證 |
|---|---|---|
| **查詢側** | 機制**認得幾種**對象 | 失敗律 `mult_for_*`：**2 → 19** |
| ★**記錄側** | **幾件事真的被送進來** | ★**失敗律 `record()` ＝【1 個事件源】（買單）** |

★**我把查詢側從 2 提到 19，記錄側一直是 1，而我報「覆蓋率」時只講了前者。**
⇒ ★**只報一側 ＝ 沒報**。**兩側都要，且都要能機械數（母體來自窮盡盤點，不是手工表）。**
「**律已落地**」與「**它對 2/N 個對象生效**」是**兩件事**，
★**只記前者會讓一條幾乎沒接線的律看起來像已完成。**

#### ★列管物種：**手工對照表**（三次同型 ⇒ 列管）
**症狀**：一張**人工維護的白名單／對照表**決定「誰受這條律管」⇒ **漏列 ＝ 靜默豁免**。

| 表 | 位置 | 覆蓋 | 血證 |
|---|---|---|---|
| `PROGRESSIVE_HOLD_TASKS` | `task_arbiter.gd:22` | 7 個 task | ★**漏過兩次**：CONVOY（27.9 日漂流）、TASK_CAMP（89% 棄營） |
| ★`OPTION_FAIL_KEY` | `failure_memory.gd` | ★**2 個 option**（買糧／買料） | 失敗反饋律**對其餘 option 零行為**；`build_workshop` 連贏 45 次 |
| ★**「四端同秤」的那張表** | `terms.gd` ／ 我寫的 spec | ★**4 / 21** | ★**漏列紮根**（第五端）—— 詳下方 |
| ★★`RES_HARVEST_TERRAIN` | `goal_resolver.gd` | ★**1 筆**（`{"material": "forest"}`） | ★★★**與真相源【直接矛盾】的教科書實例** —— 見下 |
| （新增請續列） | | | |

#### ★★「我改了 N 個」≠「該改的是 N 個」（systems 自糾 2026-08-25，blueprint 裁入負斷言帳）
**血證**：我寫「**四選項同秤**」並列了一張表（覓食・遷移找糧／併入／佔村／紮營）——
★**那張表看起來完整，但它是【我的工作範圍】，不是【母體】。**
**真母體**：`terms.gd` 的 `*_drive` 類 term **共 21 個**，`DiscountedFlow.flow_utility` 只覆蓋 **4 個**。
★**`rooting_drive`（紮根）從頭到尾不在裡面** —— 而紮根正是我們追了一整輪的「為什麼不發生」。

**若當時做了什麼就會抓到**：★**機械列舉母體**
（`grep -oE '"[a-z_]+_drive"' terms.gd | sort -u` ⇒ 21 個，再問「哪些在同一個 argmax 池競爭」），
**而不是列出「我打算改的那幾個」。**

★**判準**：**寫「全部／四端／唯一」之前，先問「這個數字是從哪裡數出來的？」** ——
**若答案是「我列的」而不是「掃出來的」，那就不是窮盡。**

#### ★★★教科書實例：**表說不能採，真相源說三種地形全都產**（2026-08-25）
```gdscript
# goal_resolver.gd —— 手工表
const RES_HARVEST_TERRAIN = {"material": "forest"}        # ★food 不在表上 ⇒「不可採」

# resource_system.gd —— 真相源
const REGEN_RATE = {
  "plains":   {"food": 8.0,  "material": 0.5 },           # ★food 8.0 —— 全表最高之一
  "forest":   {"food": 3.0,  "material": 12.0},
  "mountain": {"food": 0.5,  "material": 2.0 },
}                                                          # ★★三種地形【全都產 food】
```
⇒ ★★**最該被採的資源（`plains` 的 food 8.0），恰恰是手工表上沒有的那個。**
⇒ ★**這不是「表過期了」，是【表從來沒有跟真相源對齊過】。**

★**處置原則**：**手工對照表是暫時形態，不是終態。**
**能由【結構身分】機械導出的，一律改導出**（覆蓋 ＝ 構造性 100%、**無表可漏**）——
同〈估算器禁手抄物理〉家族：**第二份人工維護的真相必然 drift。**
| 角色邊界（不越界、不 inline 代打） | 📜 | 無。**「這個決定該不該他做」是判斷題，機器做不了**（P9 §6 明列不做） |
| 長考閘（09，半成品禁跑驗收考） | 📜 | 人工清單；§6 地基保鮮期那格才有 `stale-claims` 撐 |
| 全量暫態可觀測性（新 decision 必接 tap） | 📜 | 無 |
| 負斷言協議（窮盡搜索、禁 `head`） | 📜 | 無（`expect-min-gate` 只擋「母體塌陷」這一種失敗型態） |
| 機制意圖帳（改既有機制先對照） | 📜 | 無 |
| doc glance-aid 瘦身 | 📜 | 無（on-touch 自律） |

★★ **範圍紀律：主線＝世界機制，儀器只修「擋著判決的」（blueprint 定 2026-08-21）**
> **從現在起，儀器／harness 只修「正在擋住某個判決」的那一件，不再擴建。**

**背景（誠實帳）**：2026-08-21 當日 7 個 merge 裡，**世界機制只有 2 個**，
**其餘 5 個是儀器與身分基礎建設**。那筆投資 blueprint 認了——**因為 QA 連三次判不了**
（主角沒被錄到 → 沒有座標 → 身分被縫接），**修儀器是前置、不是跑題**；
而今天挖出的真 bug（「明明相鄰卻不走最後一步」）**正是靠修好的儀器才看得見**。

★ **但這條紀律是對 systems 自己的約束**：**儀器很好修、成就感很即時、而且永遠修得完下一個**——
**所以要有人（這裡是這條規則）擋著**。**判準：這件儀器現在擋著誰的判決？答不出具體的人和判決，就不修。**

★★ **通則：閘的成本也是要量的東西（2026-08-21 血證、blueprint 核准入表）**
> **把一道閘從 advisory 轉成 enforced 之前，必須先量它自己跑一次要多久。**

血證：`seam-gate` 單次 **1m47s**（對 300+ 封信每檔 spawn 一次 `head`）——
而 `handback-inbox.sh` 的檔頭**正好記著 2026-07-05 修過同一個病**（改單次 awk），**systems 原封不動重犯一次**。
已修 **1m47s → 1.0s**。
★ **為什麼這件事非記不可**：**跑不動的硬閘最後一定會被繞過或關掉，比沒有閘更糟**
——它會留下「我們有守」的錯覺，而那正是 P7 三態表存在的理由。

★ **這張表本身也要 on-touch 維護**：新增 hook／gate 時順手改一行，不必特批。
★ **看到 📜 不代表該補機器**——有些（角色邊界、內容品質、該不該他做）**本來就只能是人的活**，
硬做就變成「**a proxy for judgement is a prose claim wearing a schema**」。
標 📜 的價值在於**不再假裝它有守**。


### ★★用戶立法 2026-08-21：**思考模型缺件通則**（診斷通則升級，systems owner）

**預測（用戶）**：「**某個選項從不 fire／永遠輸**」這一型問題，**會在各領域重複發生，直到思考模型完善為止**。
**缺件是可枚舉的**，而**歷史症狀全部對得上**：

| 缺件（原語） | 已對上的症狀 |
|---|---|
| **延遲價值折現** | **紮營永遠輸**（`camp_u` 天花板 0.826 vs 對手 3.17+）／`workshop`＋`mint` 沒人蓋 |
| **means-end 依賴圖** | 征服死鎖／`workshop` 那條也有份 |
| **承諾泛化** | porter 的 T0 承諾 |
| **失敗回饋** | 絕境階梯不往下爬 |
| **成功回饋** | （同族，待對號） |
| **T0 全突發** | porter／子隊求生 |

### ⇒ 診斷順序升級（**在「補丁閘優先查」之後加一步**）
```
症狀：某動作從不 fire／永遠輸
  ① 先查補丁閘（硬 gate／override／繞過引擎）          ← 既有
  ② ★對【缺件表】查號                                  ← 新增
       命中 ⇒ ⛔【禁開孤修】
       症狀點【只做兩件】：
         (a) 事實修正 —— 估算器說謊就照修（例：基準線與世界矛盾）
         (b) 掛驗收計數器 —— 讓它之後可被驗
       案子【掛到對應的原語磚】上，不另立一個一次性修法
```

### ★脊椎 ＝ **有機疊磚制**（不整包提前）
- **每個 fork 命中 ⇒ 落一塊對應的原語磚**（**折現磚 ＝ 第一塊、先例**）
- **全部用脊椎語彙寫** ⇒ **磚會累積、不報廢**
- **`completion checklist` 的 A5 改記「思考模型進度條：磚 N／總表」**
- **考卷標註「未完件相關行為不讀」** ⇒ **半成品不背鍋**（同 `09_exam_gate` 的精神）

### ★分工
**缺件表本體掛 `completion checklist`**：**WHAT 由 blueprint 維護**／**code 對應由 systems 補**。
**可預報的下一批**：**貿易遠征／囤積備戰／遷村／結盟類**。

★ **為什麼這條值得立法**：**它把「又一個不 fire 的選項」從「再開一張修法票」變成「查號 → 掛磚」**。
**孤修會製造一堆彼此不知道對方存在的一次性公式** —— 那正是今天已經栽過五次的同一族
（specimen 選樣／fate 推論／trip 以 id 為鍵／七份 `_next_team_id`／五套「走一格多久」）。


## ★★對抗鏈**往上咬也要通**（blueprint 記 2026-08-25）

**本 session 的一次實例**：
implementer  →  systems  →  blueprint
「那 23 不該算在 A 頭上」   「這條 acceptance 不在因果下游」   「那是我指定的錯，我認」

★**下游的人訂正了上游的裁定，而且是【逐層往上】的。**

⇒ ★**紀律**：**對抗鏈不是只有「上游審下游」** ——
| 方向 | 例 |
|---|---|
| **往下** | R②審 spec、QA 判交付、systems 裁 implementer |
| ★**往上** | ★**implementer 用數字訂正 systems 的裁定；systems 訂正 blueprint 的指定** |

★**要讓往上咬得通，靠的是【證據而非位階】** ——
本例的關鍵是 **`delegate.build_ok = 0`** 這個**任何人都能驗的事實**，不是誰說了算。
★**而上游要接得住**：**「那是我指定的錯，我認」——認得越快，下游下次越敢咬。**


## ★★★驗收判準必須【隨票走】——量測員不該用猜的（2026-08-25）

**血證**：measurer 重驗兩面時寫「**我假設 ＝ ①文明化恢復 ＋ ②買糧 339，不確定對否已標明**」。
★**他標明假設是對的做法** —— ★★**但他需要假設這件事本身，就是流程缺口。**
**⇒ 派量測時，票裡必須明寫**：

| # | 必寫 | 少了會怎樣 |
|---|---|---|
| 1 | ★**每條判準的【方向】** | ★★**「穩定不變」到底是 PASS 還是零鑑別力，取決於它是「該變的」還是「該不變的」** |
| 2 | ★**它會變紅的場景** | **恆真式混進來** |
| 3 | ★**陽性對照** | **儀器沒開會自動通過** |

★★★**「該變的」與「該不變的」不寫清楚，同一個數字可以被讀成完全相反的結論** ——
**這不是量測員的責任，是派工的人沒寫。**


## ★★★工作流停頓的真根：**`RUNNING` 遮蔽了「出貨沒推鏈」**（2026-08-25，用戶親自問出來）

**用戶問「我們不是改裝工作流了嗎？怎麼還會停頓？」—— 實查後三層都不是原先的猜測**：
| 猜測 | 實況 |
| 有人偷懶 | ★**否** —— implementer 在跑背景 job，全程在動 |

| 機制不存在 | ★**否** —— `watchdog v4` 有 `COMMIT-NO-LETTER`，字面就是「出貨沒推下一站」 |
| watchdog 掛了 | ★**否** —— lock 心跳新鮮，blueprint session 持有 |

★★★**真根在 `watchdog.sh` 的分類順序**：
```
elif [ -n "$running" ]; then
    class="OK"                # ★量測跑半天走這條
```
⇒ **只要長工作在跑，`COMMIT-NO-LETTER`／`UNRESPONSIVE`／`CHAIN-BROKEN` 三類全部跳過。**

**今天完全命中**：implementer **在跑 job（`running` 非空）★同時★ commit 了沒發信** ⇒ **watchdog 判 `OK`。**

> ★★**`RUNNING` 只證明【有人在忙】，不證明【鏈沒斷】—— 兩者可以同時為真。**

**已修**：`COMMIT-NO-LETTER` 提到 `running` 之前，與 `DEAD-ROLE` 同級（判準相同：**它是已完成的事實，跟誰忙不忙無關**）。

### ★而角色端的兩條配套（implementer 自提，我採納）
1. ★**落地 ≠ 遞送**：**Monitor 靠【信】喚醒，不靠 commit。** 產出落地後**必發 `status: open` 的信含 exact path**。
2. ★★**起長跑前先發一封短的**（跑什麼／預期多久／在等什麼）——
   ★**「安靜地正常工作」和「卡住」在外面看起來一模一樣**，別讓下游用猜的。


