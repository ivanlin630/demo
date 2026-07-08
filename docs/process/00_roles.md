# 00_roles.md — Session 角色與分工

> **★2026-07-08 切回多終端為主軌**（見下 §現行偏好）：pipeline/orchestrator（`06`）曾於 2026-07-06 取代多終端，但機器誤判(A2a 假 reject)+燒錢後**切回多終端信箱 relay 為預設**——各角色**持久 session 平行開** + 信箱主動觸發（`07_mailbox_trigger.md`），langgraph 機器只大/並行才上。**下列角色職責 / owner 表 / 邊界規則全有效**。**auto-memory 單寫者 = 藍圖 session**（見 §auto-memory）。QA 獨立 adversarial + 用戶最終驗收硬閘不變（`04_qa`/`05_acceptance`）。

主 session 有**兩個並存的設計腦**，按領域分（WHAT vs HOW），不是按階層。
加上 worktree 實作者，與 main dir 的**量測員**（`--path` 跑 branch）、**驗收官（QA）**（讀 diff/show）。接力，不是並行競爭。

## 五角色

| 角色 | 管 | 不管 | 產物 |
|---|---|---|---|
| **藍圖**（Blueprint） | **WHAT**：玩什麼、玩家循環、feature 願景、平衡意圖 | 架構決定、code | `game-design.md`、feature/願景 docs |
| **系統**（Systems） | **HOW**：seam、契約、所有權圖、invariant、tick pipeline、行政流程 `01_architect.md`| 遊戲願景、平衡意圖 | spec / plan / `invariants.md`|
| **實作**（Implementer） | worktree 寫 code、跑 sanity 測試 | 設計決定 | code + handback |
| **量測員**（Measurer） | **留 main dir**（`godot --path .worktrees/<slice>` 對 branch code）跑 HOB/探針/beds **＋ spec §驗收法客製守衛** 出**獨立**數字餵 QA（藍圖不蹲 godot；★禁原地 checkout）。職責正典 `03b_measurer.md` | 判決、改 code、裁設計 | `.measure.json` + handback to:QA |
| **驗收官**（QA） | 充足性判決/戲感觀者/release gate/UI 落差（`04_qa.md` 四職）；**maker/checker 分離=非蓋房者的腦**，★讀量測員數字判、不自產 | 修 code、裁 WHAT、修 HOW、**自產數字** | 判決表/落差清單 + `escaped_defects.md` 管理 |

**★硬閘：任何東西交用戶之前，QA 必綠**（三層驗收鏈見 `05_acceptance.md`）。充足性判決由 QA 出——系統不自判自己蓋的世界。

兩個設計 session 都在 `A:\GDS\demo` / `main`。實作在 `.worktrees/<feature>/` / `feat/<feature>`。

## 接力流向（同一 feature 不同階段，非同時）

```
你 ──願景──> 藍圖(WHAT) ──設計意圖──> 系統(HOW) ──spec──> 實作 ──handback──> 系統
```

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
from: <role>          # blueprint | systems | implementer | qa
to: <role>
status: open | consumed
topic: <一行>
```

生命週期：
1. 發送方寫 `status: open`。
2. **每 session 開頭掃 `handbacks/`，讀 `to: 本角色 / status: open` 的**（義務）。
   - **自動 📬（hook，gitignore 本地）**：`SessionStart → session-role.sh`（開頭掃一次）+ `UserPromptSubmit → handback-inbox.sh`（**每 turn 掃**，補 session 中途別角色寫的；空則靜默）。掃 frontmatter `to:$SESSION_ROLE status:open` = 讀真值源，免 QUEUE.md drift。消滅人肉轉述。
3. 消費後改 `status: consumed`（不刪檔，留軌跡）。
4. 待決事項的**歸宿仍是 owner doc**：handback 只是載體。例：藍圖裁定殲滅模型 → 寫進 `game-design.md` → handback consumed。系統定 seam → 寫進 `invariants.md`/spec → consumed。

channel 的設計意圖（WHAT）藍圖提、寫進 process doc（HOW）系統做；本節即首個 dogfood（`2026-06-19-blueprint-to-systems-handback-channel.md`）。

## 驗收鏈（QA 反轉,2026-07-04 事故級規則）

**用戶眼球=願景輸入,永遠不是驗收工具。**交付用戶前三層機器全綠（①充足性閾值②常駐漏斗③戲感審計）,**判決由驗收官（QA）出**;用戶發現的問題=逃逸缺陷入 `docs/escaped_defects.md`（QA 管理）。規則本體+enforcement 見 `05_acceptance.md`（**每 session 交付前讀**）。

## auto-memory 規則（承 §2）

- **★★兩軌切回後（2026-07-08，現行權威）：auto-memory 單寫者 = 系統 session**（HOW owner，持久、序列化天然單寫）。理由：pipeline 只有藍圖一持久 session（故彼時單寫=藍圖）；兩軌恢復持久角色 session（bp/systems/qa/reviewer）→ 單寫者回系統（承 §2 owner 表 + 原始模型）。**別角色（藍圖/QA/reviewer/實作）教訓走 handback → 系統提煉入 memory**。
- （下記 pipeline 段=歷史參照，非現行）**pipeline 切換期（2026-07-06~08）：auto-memory 單寫者 = 藍圖 orchestrator session**（持久、序列化=天然單寫）。系統/實作 subagent ephemeral 不寫 memory，教訓走 handback → orchestrator 提煉。以下「系統 session 寫」= 切換前=兩軌後模型（現行）。
- **（切換前）只有系統 session 寫** auto-memory。藍圖 / 實作只**讀**（harness 開頭自動注入，無需主動讀）。
- 藍圖 / 實作學到的跨 session 教訓 → 寫進 handback（git doc）→ 系統提煉進 memory。
- 單寫者 = 零 MEMORY.md race + 教訓經系統過濾，避免各記不一致。

## 流程文件地圖（掛勾）

角色/職責/owner/邊界本體在本 doc；細流程分檔：
- `01_architect.md` — 系統(HOW) 職責 / spec / plan 本體
- `02_reviewer.md` — 對抗式審查者（factcheck 驗前提 / 審 spec）
- `03_implementer.md` — worktree 實作 + TDD + handback
- `03b_measurer.md` — ★量測員（maker 產獨立數字，含 spec §驗收法守衛；≠QA 判）
- `04_qa.md` — QA 四職判決（充足性/戲感/release gate/UI 落差）
- `05_acceptance.md` — ★交付前驗收鏈（三層機器全綠=硬閘）
- `06_pipeline_orchestration.md` — pipeline 編排（藍圖 spawn 下游 subagent）
- `07_mailbox_trigger.md` — ★信箱主動觸發（多終端 relay，Monitor 喚醒收件 session）
- `07_orchestrator_machine.md` — langgraph 機器編排說明
- `08_machine_workflow_v2.md` — 機器 v2 流程 + 01 下游軌（`--from-impl`）

## ★現行偏好（2026-07-08）：多終端信箱 > LG 機器

用戶現**傾向多終端信箱 relay 為主軌**（各角色持久 session + Monitor 主動觸發，見 `07_mailbox_trigger.md`），**langgraph 機器少用**——只在大/並行活才上；輕/序列/設計來回一律走信箱。動機：機器誤判（A2a 假 perf reject）+ 燒錢（$27/slice）。兩軌並存但預設走信箱。

## 你的負擔

| 對象 | 你做什麼 | 頻率 |
|---|---|---|
| 藍圖 | 願景討論、玩法取捨 | 按 feature |
| 系統 | 架構討論、裁決、流程 | 按 feature |
| 實作 | 貼一行啟動 + 收 handback | 機械、低腦力 |

兩個設計腦不重複（異工），實作非同步跑（並行紅利）。
