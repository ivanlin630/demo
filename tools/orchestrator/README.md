# 生產線使用說明（orchestrator machine）

一條「自動寫程式的生產線」。你決定**要修什麼**，生產線自己跑完（寫規格→挑毛病→建造→檢查→測試），你只在關鍵點回來。

---

## 0. 心智模型（先懂這個）

```
你 ──談 WHAT──> 藍圖(=我，這個對話)
                   │ 我把 WHAT 翻成工單、prep 好一切
                   │ 給你一行 ! 指令
你 ──按 GO(! 指令)──> 生產線自己跑
                   │ 查證→系統→挑毛病→建造→品管→閘
                   ↓
                 停在 merge 前(B模式) 或 有問題時 → 回來問你
你 ──批准/回應──> 完成
```

**三個地方，但其實同一個：**
- **談 / 按 / 看**：全在**這個對話框**。`!` 開頭 = 在你 session 跑，輸出回到對話裡。
- **Studio（選配）**：想看視覺化生產線圖時開，非必要。
- **git 檔**：判決/帳單/報告永久留檔，隨時翻。

---

## 1. 一次性設定（只做一次）

想用 Studio 視覺化，開一次 server（否則跳過，不影響按 GO）：
```powershell
# 在 A:\GDS\demo 開 PowerShell，跑：
.\tools\orchestrator\run_studio.ps1
# 這個視窗別關。Studio 網址：
# https://smith.langchain.com/studio/?baseUrl=http://127.0.0.1:2025
# 第一次要登入免費 LangSmith 帳號。
```
不想碰 Studio = 完全不用做這步。按 GO 的輸出直接在對話裡看。

---

## 1b. 瀏覽器監視（Studio 詳解）

Studio = 生產線的**視覺化俯視圖**。

### 開啟
1. server 開著（`run_studio.ps1`，那個 PowerShell 視窗別關）。
2. 瀏覽器貼：`https://smith.langchain.com/studio/?baseUrl=http://127.0.0.1:2025`
3. 首次要登入免費 LangSmith 帳號。
   - 不想登：改開 `http://127.0.0.1:2025/docs`（陽春 API 頁，零登入）。
4. 想在 VS Code 裡看：`Ctrl+Shift+P` → `Simple Browser: Show` → 貼上面網址（官方 UI 長在 VS Code 分頁裡）。

### 你看得到什麼
- **節點圖**：整條線的形狀（哪站接哪站、interrupt 岔路一眼看全）。
- **按 Run + 填 `slice_id`** → 看節點一站站亮（**紙板 stub = 免費、瞬間**），熟悉畫面。
  - 輸入只填 `slice_id`（例 `demo1`），其他留空。或按 `View Raw` 貼 `{"slice_id":"demo1"}`。
- **點任一節點** → 那一刻的 state（verdict、stage 等）。
- **左邊 threads** = 每次跑的歷史，點進去重播、逐步看。
- **interrupt** → 畫面顯示暫停，可直接在 UI 填 resume 值繼續。

### 隱私
Studio 網頁是 LangChain 的，但**指向你本機 server**（127.0.0.1）。graph 在**本地跑**，`.env` 已關 tracing → 跑的資料**不上雲**。

### 即時看真線（已接好）
- 你按的 **GO（`! run.py`）投給 server 跑** → **Studio 即時顯示真工人一站站亮、卡哪**。
- **同時** console（對話裡）也串流每站進度。兩邊都看得到。
- 按 GO 後 run.py 會印出該次的 Studio 網址（帶 baseUrl）——開它就看得到這條真線。
- 前提：server 開著（`run_studio.ps1`，port 2025）。沒開 = 按 GO 會連不上。

---

## 2. 日常怎麼用

### 小事（一行修、改參數、typo）
**不進生產線。** 直接跟我講，我 inline 改，走你平常的批准。沒有 GO。

### 大事 / 多步（改架構、修系統）
1. **跟我談 WHAT**（白話：「修 A1a 拆閥」「征服修一修」）。
2. 我 **prep**：建 worktree、寫工單、給你**一行 `!` 指令**。
3. 你**按 GO**：把那行 `!` 貼進對話框送出。生產線跑，**進度印在對話裡**。
4. B 模式 → 品管綠+閘過後**停在 merge 前**問你。
5. 你**批准**：我給你 `! ... --resume approve`（或 reject 打回）。

### 按 GO 長怎樣（範例）
```
! $env:PYTHONUTF8=1; python A:/GDS/demo/tools/orchestrator/run.py --slice A1a --brief-file A:/GDS/demo/tools/orchestrator/briefs/A1a.md --mode B
```
批准 merge：
```
! python A:/GDS/demo/tools/orchestrator/run.py --slice A1a --resume approve
```

---

## 3. 生產線的站（每站一個 AI 工人）

| 站 | 幹嘛 | 抓什麼 |
|---|---|---|
| 查證（factcheck） | grep 驗工單每個 code 斷言 | 我唬爛（如「X不存在」但其實有） |
| 系統（systems） | 把 WHAT 寫成精確 spec | — |
| 挑毛病（review） | 對抗審 spec | 設計不健全（真根治 vs 搬問題） |
| 建造（implementer） | 寫 code + 測 + commit（在 worktree） | — |
| 品管（qa） | 驗「效果真發生」非「能力存在」 | 沒真修好 |
| 閘（gate） | 憲法閘 + 手聽腦 bed（確定性 script） | 退化、崩 |

**你不跟中間工人對話**（不需要）。他們讀 git、做事、傳下一棒。只有工人喊「前提錯了」時，生產線**自動停、彈給你**。

---

## 4. 模式：B vs C

- **B（merge 前煞車）**：跑到品管綠+閘過，**停下給你看才 merge**。機器沒證明前用這個。
- **C（每 arc 全自動）**：整批 slice 跑完才回報。機器跑順後再升。

---

## 5. 停下來時怎麼辦

生產線只在兩種時候回來找你：
- **前提矛盾**（工人發現方向錯）→ 印出問題，你回一句（改方向 / 繼續）。
- **煞車點**（B 模式 merge 前）→ 給你看 QA+閘結果，你 `--resume approve` 或 `reject`。

---

## 6. 看細節去哪

- **判決**：`.worktrees/machine-<slice>/docs/process/verdicts/*.json`（每個判決工人的結論+file:line）
- **帳單/進度**：`docs/process/metrics.jsonl`（每站：花多少錢、多久、判什麼、有沒抓到問題）
- **報告**：`docs/superpowers/handbacks/`（系統/建造工人寫的「做了啥」）
- **程式**：worktree 分支的 commits

---

## 7. 扳機：按一下 vs 授權一次

- **現在**：大活每次按一下 GO（`!` 指令）。這是「放出沙盒關掉的自主 agent」的人類檢查點——安全設計。
- **機器跑順幾個 slice 後**：你可**授權一次**（加權限規則，接受風險）→ 我能自動觸發、零按鍵。別在未驗機器上先跳。

---

## 8. 疑難排解

- **卡某站**：貼對話裡的輸出給我。worktree 隔離、git 全留，動不到 main，安全。
- **中文亂碼**：指令前面 `$env:PYTHONUTF8=1`（run_studio.ps1 已內建）。
- **server 開不起來**：`.\tools\orchestrator\run_studio.ps1`；掛了重開一次。
- **worktree 髒了想重來**：`git worktree remove .worktrees/machine-<slice> --force` 再重跑。

---

## 檔案地圖（tools/orchestrator/）

| 檔 | 是啥 |
|---|---|
| `run.py` | 啟動器（你按 GO 跑這個） |
| `runner.py` | node-runner（headless claude 節點 + 分層權限） |
| `nodes.py` | 判決/寫檔共用函式 |
| `real_nodes.py` | 真節點 graph |
| `graph.py` | 拓撲 + 路由（紙板 stub，Studio 用） |
| `gate.py` | N6 閘 script |
| `bus.py` | git-handback 傳遞面 |
| `run_studio.ps1` | 啟 Studio server |
| `briefs/` | 工單 |
| `langgraph.json` / `.env` | Studio 設定 |
