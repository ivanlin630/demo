# Spec：verification-gate（sim 量測 → QA 故事稽核 fail-closed coupling）

> 根因（blueprint+用戶挖）：驗證紀律（QA 故事稽核/multi-seed/measure-first）在**意圖層 doc**→跳了工作照前進無後果→衰減（7/14 加回 QA、7/18 又跳=證）。運輸層（handback/hook）跳了工作動不了→自我強制不衰減。∴ **把 coupling 搬上關鍵路徑做結構強制**（像 constitution_gate 擋 merge）。
> 用戶定 rule（2026-07-18）：**有模擬量測就要跑 QA 故事性，沒模擬量測就不用；量測本身 discretionary（費時非每 slice）**。∴ 只堵「sim 量測了卻沒 QA 讀故事」的衰減（正是 attrition 誤讀成 combat 的病），不強制量測、不加無謂負擔。

## 核心 rule（fail-closed coupling）
- **slice 有 sim 量測（`verdicts/<slice>.measure.json` 且 `is_sim: true`）→ 必需 `verdicts/<slice>.qa.json` `verdict: PASS`** 才可 merge。缺 / QA≠PASS = gate FAIL 擋 merge。
- **無 sim measure verdict → 無要件**（byte-identical/char-bed/純結構免；量測 discretionary）。

## verdict schema
- **`docs/process/verdicts/<slice>.measure.json`（measurer 寫，既有 + 加欄）**：`+ is_sim: bool`（organic/seeded sim 跑=true；char-bed/byte-identical-only/純結構=false）。既有 `measured_at_head`/`raw_logs` 留。
- **`docs/process/verdicts/<slice>.qa.json`（QA 寫，新）**：`{slice, verdict: "PASS"|"THRASH"|"FAIL", read_measure: "<measure-file>", story_audit: {…thrash判準表:thrash餓死❌/窮死✅/idle❌…}, note}`。

## 交付切片
- **S1 verification_gate.gd**（sibling of `constitution_gate.gd`，headless）：
  - 掃 `docs/process/verdicts/*.measure.json`（or 傳入 slice/branch 範圍）。
  - 任一 `is_sim: true` 的 measure verdict **缺對應 `.qa.json` 或 qa.verdict≠PASS** → print `[VERIFICATION-GATE] FAIL: <slice> sim-measured but no QA PASS verdict` + 回 FAIL exit。
  - 全 sim-measure 有 QA PASS（or 無 sim-measure）→ `[VERIFICATION-GATE] PASS`。
  - **範圍**：branch-scoped 優先（傳 branch/slice name 只查該 slice verdict，避免 stale 舊 verdict 誤擋）；無參數則掃 active（未 archive）verdicts。
- **S2 接 hook（★blueprint 裁 2026-07-18:pre-push 非 pre-commit + 折 constitution_gate + install 後補）**：
  - **★pre-push 非 pre-commit**（blueprint）：gate 在**分享（push origin/main）**非每 WIP commit——不擋本地 WIP，只擋推共享。addresses「全 session +2-5s/commit」成本（只 push 時跑）。
  - **★範圍=constitution_gate + verification_gate 同折進 pre-push**（blueprint:constitution_gate 現手動=可跳=正是「機器證」的洞）。push origin/main 時跑兩閘,任一 FAIL 擋 push。
  - **★install 非 optional（blueprint:框架①claim 為真的必要,不裝則①空頭）**——但 **install 時機=starvation fix 落地後**（現在裝擾 active implementer commits;本輪 systems active attention 手動跑夠,hook 是下 slice backstop）。
  - **★premise 修正**：原 spec 假設「constitution_gate 已在 hook=運輸層」**假**——實際兩閘皆手動、hook 尚不存在。「機器證零殘留綠」框架①從來非機器強制=靠人記得跑=會衰減（同 QA decay）。install pre-push=補這洞。
  - 繞過 `--no-push`... 用 `git push --no-verify` 須系統認可（同規矩）。
- **S3（次階，通用化）**：is_sim measure verdict 加 `seeds: [...]` 欄，gate 檢 multi-seed（≥N 含 designated 硬 seed）——收 blueprint「3 紀律同 pattern」的 multi-seed 那條。measure-first（迭代期禁大窗）留意圖層（難結構化,是 iteration 習慣非 merge 閘）。

## ★部署裁定（R² HALT:31 既存 .measure.json 全缺 is_sim + QA 5 副檔名並存）
1. **既存檔 grandfather via archive**：S1 部署時**一次性把現有 `verdicts/*.measure.json` + 所有 QA 檔（5 副檔名 .qa.json/.qa.raw.txt/.qa_final_verdict.md/.qa_verdict.md）move → `verdicts/_archive/`**（pre-gate 歷史）。**gate 只檢 active（非 `_archive/`）verdicts** → 既存歷史不追溯擋，新 slice 從乾淨起。
2. **active verdict 缺 is_sim → FAIL（強制 schema 前進）**：部署後**新** `.measure.json` 缺 `is_sim` 欄 = gate FAIL（measurer 必設）。**不追溯**（既存已 archive）→ 只推 schema 向前，不部署即全紅。
3. **QA 格式 = `.qa.json` only（前進）**：既存 5 副檔名 archive；going-forward QA 只寫 `.qa.json`，gate 只讀 `.qa.json`。（QA session handback 通知採此格式。）
4. **branch-scoped**：gate 傳 slice/branch name，只查該 slice 的 verdict（`verdicts/<slice>.*`），進一步免 stale 誤擋。
5. **is_sim 可靠性（R② ②，S1 加 cross-check）**：measurer 設 is_sim + **gate cross-check raw_logs**（含 `seeded_warring`/organic/多 seed 關鍵字卻 is_sim=false → WARN 疑漏標）。auto-infer 為 S2 強化（measurer 漏標=漏閘防線）。

## 非回歸
- **不強制量測**（無 sim measure→gate PASS，量測 discretionary）。
- **byte-identical/char-bed/純結構 slice 不受影響**（is_sim=false → 無 QA 要件）。
- **stale 舊 verdict 不誤擋**（branch-scoped）。
- constitution_gate 不動（verification_gate 是 sibling）。

## 閘
- **R②**（gate 邏輯 edge case:stale verdict 誤擋/branch-scoping/is_sim 判定/hook 繞過）。
- 這是 process 結構工具（非 behavior），measurer/QA 需同步採 verdict schema（handback 通知）。

## 溯源
blueprint 結構修法（`2026-07-18-blueprint-to-systems-qa-structural-gate-not-doc.md`:fail-closed vs 意圖衰減）;用戶 rule（sim→QA/量測 discretionary）;[[feedback_qa_inversion]] QA 故事稽核;constitution_gate（fail-closed 運輸層先例）;血證=attrition 誤讀（跳 QA 讀 sim 量測）。
