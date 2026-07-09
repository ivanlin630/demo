# 08_machine_workflow_v2.md — 生產線工作流 v2（2026-07-08 討論鎖定）

> 取代 06/07 的機制部分。這是**用戶親自討論鎖定**的 workflow（他真實工作模式：只跟 00 談、00 當 gate、重工 off-他-context、輕基建）。

> **★★2026-07-09 流程改（用戶定案）——兩軌 QA 模型（更正前版過簡）**：QA 砍與否**綁模式（in-loop vs autonomous），非綁軌**。定位表：
>
> | 軌 | 模式 | QA |
> |---|---|---|
> | mailbox / 單 slice（用戶盯） | **in-loop** | 砍 QA release-gate，**藍圖 pass 權**（沒問題就過、有問題升用戶） |
> | **LG 下游平行**（fire N 條走開） | **autonomous** | **`rn_qa` 保留硬閘**（獨立判決）——這正是 autonomous lane 該有 QA 的時候 |
>
> ∴ **LG 下游 `rn_qa` 不搬藍圖 pass、保留自動硬閘**（呼應 workflow-qa-measurer-change caveat「autonomous→QA 回」；LG 下游=那個 autonomous lane 的具體化）。下方 `[04 QA] green/red` + `qa_review 三路` 在 **LG 軌照舊有效**（autonomous）；mailbox 軌才由藍圖 pass 承接。
> - **rn_measure 升標準 full_probe 床**（`03b_measurer.md §④`）→ 治 bounce，讓 rn_qa 判在完整數據上。
> - **★LG 下游改動已做（用戶 2026-07-09 直接授權「改 LG 下游」）**：發現下游平行骨架**早已存在**（`real_nodes.py build_real` = `--from-impl` lane：implementer→measure→qa→qa_review→merge，run.py 已支援）。實改=**`rn_measure` 升標準 full_probe 床**（全維度一次抓齊治 bounce）+ **`rn_qa` 讀 fullprobe.json + 完整性 gate 認 full_probe 維度**（autonomous 硬閘保留、判完整數據）+ graph.py stub 同步（補 measure node）+ test_graph.py（measure 在鏈 + 完整性 gate 強制 red，12/12 PASS）。上游節點不碰。**平行多條 = fire N 個 `run.py --from-impl`**（各自 thread/worktree），非 graph 改。
> - cost $27/slice → 值得時機=手上一批獨立 specced slice 想一次平行；1-2 條走 mailbox。

## 流程（含兩個檢查點）
```
你+00 定 feature A
  ↓
[02① factcheck]  grep 驗工單每個 code 斷言        前提假→halt→報00→報你
  ↓
[01 systems: 寫 spec]  只 spec，先不 plan
  ↓
[02② review spec]  設計健不健全(讀廣一點抓跨系統)   issues→halt
  ↓
{★檢查點① 00審}  01 handback「重點」給 00(我，非全spec) + 02findings
     怪/踩願景 → 找你討論 → 你定    /    好 → 00 gate 放行
  ↓  (放行才寫 plan = fail-early，爛 spec 不浪費 plan)
[01 systems: 寫 plan]  writing-plans/TDD task 分解
  ↓
[03 implementer]  照 plan+TDD 寫 code+測+commit
  ↓
[量測員 measurer]  跑全探針/bed/sanity(整 sim)——退化靠「跑」抓,非讀全code
  ↓
[04 QA]  讀量測數字 + scoped diff → 判 green/red
  ↓
{★檢查點② 你判}  00 報 QA數字+diff → 你 approve/reject
  ↓ approve
 merge
```
人碰的點全經 00(我)：開頭定A / ①spec審(怪才找你) / ②結果判 / halt / API定格。**重工在各節點 context，不塞 00。**

## 執行 & 基建
- **預設 --local detached + sqlite**（不阻塞/VS Code關也活/斷了 --resume 續）。server/Studio 選配。
- 並行 = 各 slice 各起 process（worktree 隔離，執行安全）；衝突在 merge。
- 控制指令：`--status`(看板) / `--cancel`(殺 worker+node)。

## 成本控制
- **判斷節點用 haiku**（02①/02②/QA/量測判讀）；**opus 只給 01-spec/03-實作**。
- **scope 限讀**：節點讀 touch_files+工作需要，別盲掃全庫（A1a $12=systems讀太多）；**02②讀廣一點**(抓跨系統)。
- 退化偵測 = 量測員跑全 sim(行為)，非誰讀全 code。

## 記憶（節點 CTX）
- 節點 = `claude -p` 子行程，**0-CTX**、靠 git 產物(spec/plan/handback/verdict)接力。
- **session-resume 優化**：同角色重複(01-spec→01-plan)用 `claude -p --resume <session-id>` 免重讀；**跨角色故意斷**(保 02 對抗獨立)。state/git 存 per-role-per-slice session-id。

## 三裁定（已內建）
1. 退回不 silent 重試 → halt 通知 00。
2. 刪 GATE → QA 後強制中斷(裁定②)，00+你判(真bug vs godot噪音)。
3. API 限流/超時 → 原地定格，不自動重試。

## 分解階段（批次2，缺）
```
你+00 定 A → [01 分解: A→A1~A5 + 各片scope + 並行圖] → {⓪00審分解} → 藍圖按圖 fan-out
  → 每片各走上面 pipeline → merge 按依賴序
```
現況：藍圖(我)手動切 slice + 判並行。

## 01 下游軌（`--from-impl`，2026-07-08）
配合信箱兩軌（`07_mailbox_trigger.md`）：**01 在 persistent session 已寫好 spec+plan+scope 並 push 後**，只把機械的下游丟機器自動跑，省上游 spec/review/plan（那些 01 已在 session 帶 ctx 做完）。
```
01 session 寫 spec+plan+scope → git push → python run.py --slice X --from-impl
  → [implementer → measure → qa → ②qa_review(你判) → merge]
```
- graph = `make_impl_graph`（START→implementer→measure→qa→qa_review→merge）；`pipeline_impl` 註冊在 langgraph.json。
- worktree off origin/main → 取得 01 push 的 plan/scope（**01 必先 push，否則 worktree 拿舊 main 無 plan**）。
- ②qa_review 三路：approve→merge / redo→implementer(重跑下游) / **revise→END**(QA 揭 spec 缺陷；此軌無 spec 站 → halt，01 回 session 改 spec/plan 再 re-fire) / reject→END。
- 全走既有 pause-poll / freeze-resume / 成本分層（判斷節點 haiku、實作 opus）。

## 批次排程
- **批次1**（done, 5896e7c 等）：--local detached / 控制指令 / A2a修 / README / 三裁定 / 角色doc+技能 / 量測員 / scope.json。
- **批次1.5**：①檢查點(00審 handback重點) + spec/plan 拆(中插02②) + 判斷節點 haiku + scope 限讀。
- **批次1.6**：session-resume 優化（做完量 vs 重讀）。
- **批次2**：分解階段（01 分解 A→A1~A5 + 並行圖 + ⓪審）。
- **並行**：A2a 重跑（工單已補回歸-capture 特判）+ 續 A2b(leader) 等。

## 角色↔doc
00 藍圖 / 01 systems(01_architect) / 02 reviewer(02_reviewer) / 03 implementer(03_implementer) / 量測員(03b_measurer.md；★maker 側產數字≠QA 判，非 QA 角色，含 spec §驗收法守衛) / 04 QA(04_qa)。節點 prompt 載職責正典 + superpowers 技能(已驗上線)。
