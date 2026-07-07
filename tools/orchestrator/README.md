# 生產線使用說明（orchestrator machine v2）

一條「自動寫程式的生產線」。你決定**要修什麼**，機器自己跑完（分解→寫規格→挑毛病→建造→量測→QA），你只在關鍵點回來。

---

## 0. 心智模型

```
你 ──談 WHAT──> 藍圖(=我，這個對話)
                   │ 我 prep 好、給你一行 ! 指令
你 ──按 GO(! 指令)──> 機器背景跑(不卡對話、VS Code 關也活)
                   ↓
   查證→系統→挑毛病→建造→量測員→QA→【人判】→merge
                   ↓
   有問題→halt 通知我 / API異常→定格 / merge前→問你批
你 ──答/批──> 完成
```

**談 / 按 / 看 全在這個對話框。** `!` 開頭 = 你 session 跑，輸出回對話。我讀 git 判決盯進度、到事件報你——**你不用 babysit**。

---

## 1. 執行模式：預設「本地 detached」（v2）

按 GO → 機器**本地 detached 背景跑**：
- **不卡對話**（`!` 秒返回）。
- **VS Code 關也活**（detached）+ **sqlite 持久**（斷了 `--resume` 續，不從頭）。
- **並行 = 各起一個 process**（各自 worktree，非衝突安全）。
- **不需要 server**（要 Studio live 圖才 `--server`，見 §7）。

---

## 2. 日常怎麼用

**小事**（一行修/改參數/typo）：跟我講，我 inline 改，走你平常批准。**沒 GO。**

**大事/多步**：
1. 跟我談 WHAT（白話「修 A2a」）。
2. 我 prep（worktree/工單）→ 給你一行 `!`。
3. 你按 GO：貼進對話送出。機器背景跑，我盯。
4. **halt / merge前 / API定格** 時我報你，你答（改方向 / approve / reject）。

### 按 GO（範例）
```
! PYTHONUTF8=1 python A:/GDS/demo/tools/orchestrator/run.py --slice A2a --brief-file A:/GDS/demo/tools/orchestrator/briefs/A2a.md --mode B
```
批准 / 打回：
```
! PYTHONUTF8=1 python A:/GDS/demo/tools/orchestrator/run.py --slice A2a --resume approve   （或 reject）
```

---

## 3. 你的控制指令（Studio 只能看，這些能動手）
```
! python A:/GDS/demo/tools/orchestrator/run.py --status              # 看板：各 slice 進度+花費
! python A:/GDS/demo/tools/orchestrator/run.py --cancel --slice A2a  # 停某條(殺 worker+node)
! python A:/GDS/demo/tools/orchestrator/run.py --cancel              # 清全部殭屍
```

---

## 4. 生產線的站（每站一個 AI 節點）

| 站 | 幹嘛 | 抓什麼 |
|---|---|---|
| 查證 factcheck | grep 驗工單每個 code 斷言 | 我唬爛（如引用不存在的東西） |
| 系統 systems | 出 spec + **plan**(writing-plans 技能) + **scope**(觸及集/可否並行) | — |
| 挑毛病 review | 對抗審 spec | 設計不健全、量測坑 |
| 建造 implementer | **TDD** 寫 code+測+commit（worktree） | — |
| **量測員 measurer** | 跑全探針/bed（單點/憲法/sanity/抖動檢） | 出真數字餵 QA |
| QA | **讀量測員數字**判 green/red | 沒真修好、退化、抖動 |

**你不跟中間節點對話。** 只在 halt/merge前，我轉告你判。

---

## 5. 三裁定（A2a/A1a 燒錢教訓，已內建）
1. **退回→halt**：查證/挑毛病 issues → 暫停通知我，**不 silent 重試迴圈**（省錢）。
2. **刪 GATE→人判**：QA 後強制中斷，我判（真 bug vs godot 框架噪音），approve 才 merge。
3. **API 異常→定格**：撞限流/超時 → 原地凍、保留狀態，**不自動重試空轉**；額度回 resume 續。

---

## 6. 角色 + 技能（已上線）
- 每節點 prompt **載職責正典** `docs/process/0X_<role>.md`（00 藍圖/01 系統/02 審查/03 實作/04 QA）。
- **superpowers 技能可用**（驗過）：systems 用 writing-plans、implementer 用 TDD、review 用 systematic-debugging 等。

---

## 7. 並行 & 分解（現況 + 待建）
- **並行執行**：各 slice 各自 worktree + process → 同跑安全。
- **能不能並行 = systems 的 scope.json 判**（touch_files/depends_on/parallel_safe）。觸及集相交 → merge 要排序。
- **★分解階段（A→A1~A5 + 並行圖）= 待建（批次2）**。目前藍圖(我)手動切 slice + 判並行。
- **Studio（選配）**：想看 live 圖 → 開 `.\tools\orchestrator\run_studio.ps1`（server, port 2025, N_JOBS=4 並行）+ 發動時加 `--server`。server 死=run 狀態丟（in-memory），不如 --local 硬。

---

## 8. spec/產物放哪
每 slice 的 worktree（`.worktrees/machine-<slice>`），merge 時進 main：
- spec → `docs/superpowers/specs/`
- plan → `docs/superpowers/plans/`
- scope/verdict → `docs/process/verdicts/<slice>.*.json`
- 帳單 → `docs/process/metrics.jsonl`
- 報告 → `docs/superpowers/handbacks/`

---

## 9. 疑難排解
- **卡某站**：貼對話輸出給我。worktree 隔離、git 全留，動不到 main。
- **中文亂碼**：指令前 `PYTHONUTF8=1`。
- **VS Code 關了跑一半**：sqlite 在 → `--resume` 續（不從頭）。
- **殭屍/卡住**：`--cancel` 清。
- **worktree 髒了重來**：`git worktree remove .worktrees/machine-<slice> --force`。

---

## 檔案地圖（tools/orchestrator/）
| 檔 | 是啥 |
|---|---|
| `run.py` | 啟動器（GO/--status/--cancel/--resume；預設 local detached） |
| `runner.py` | node-runner（headless claude + 分層權限 + API 異常偵測） |
| `nodes.py` | judge/write 共用 + 角色 doc/技能 preamble |
| `real_nodes.py` | 真節點 graph（三裁定/量測員/halt） |
| `gate.py` | (舊)閘 script，graph 已不用 |
| `bus.py` | git-handback 傳遞面 |
| `run_studio.ps1` | (選配)啟 Studio server |
| `briefs/` | 工單 |
