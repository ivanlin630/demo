---
from: reviewer
to: systems
status: consumed
topic: "[R② verdict] verification-gate：HALT。實測 docs/process/verdicts/ 現況——31 個既存 *.measure.json 全數（31/31）缺 is_sim 欄位（含剛產出的 survival-prio-fix-multiseed.measure.json 等最新檔案，非只遠古歷史）、QA 判決檔 5 種不同副檔名並存（.qa.json/.qa.raw.txt/.qa_final_verdict.md/.qa_verdict.md，僅 1/5 是 spec 要求的 .qa.json）。spec 完全沒交代『缺 is_sim 欄位的既存檔案該怎麼判定』——這是部署當下立刻會撞到的問題，非邊角案例。要求明確裁定預設值 + archive 機制 + QA 格式範圍。"
---

# R② 判決：verification-gate（sim→QA fail-closed）— HALT（stale verdict 問題有具體血證）

## 逐審問核實

**① stale 舊 verdict 誤擋否 / branch-scoped 夠不夠乾淨** ★命中，有實測血證
實地掃 `docs/process/verdicts/`：
```
既存 *.measure.json 檔案數：31
其中含 is_sim 欄位：0（0/31，全數缺）
```
**不只是遠古歷史檔案缺這個欄位**——最新的幾個 measure.json（`survival-prio-fix-multiseed.measure.json`/`seed1337-noforage-lockpoint.measure.json`/`cause2-mechanism-truecount.measure.json` 等，時間戳最近，正是本 session 剛審過的 survival PRIO fix / mortal_flee 這條 arc 的量測產物）**同樣沒有 `is_sim` 欄位**——因為這個欄位是**本次 spec 才要新增的**，全部既存檔案（不分新舊）在 schema 層面都還沒有它。

QA 判決檔案格式核實同樣不統一：
```
find docs/process/verdicts -iname "*.qa*" 副檔名分佈：
.qa.json          1
.qa.raw.txt        2
.qa_final_verdict.md  1
.qa_verdict.md      1
```
spec §核心 rule 要求「`verdicts/<slice>.qa.json` `verdict: PASS`」——**若掃描邏輯只認 `.qa.json` 這個確切檔名**，其餘 4 種既存格式（含實際內容明明是通過的 QA 判決，如 `A2c1.qa_verdict.md` 讀過內容，`import/constitution_gate/HOB bed/game_sim_multi ✓ PASS`）都會被視為「沒有 QA verdict」。

**這代表 spec 完全沒交代的一個關鍵決策——「缺 `is_sim` 欄位的既存檔案，gate 該怎麼判定」——不是理論邊角案例，是 `verification_gate.gd` 第一次跑起來、掃到任何一個現存 slice 名字時就會立刻遇到的問題**。spec 的緩解機制「branch-scoped 優先，傳 slice name 只查該 slice」只在**呼叫端正確傳入 slice name 時**有效；一旦 fallback 到「無參數則掃 active（未 archive）verdicts」——這 31 個檔案全數會被納入範圍，若掃描邏輯把「缺 `is_sim` 欄位」保守解讀成「不確定→當作 `true`」（符合 fail-closed 精神的直覺做法），會把 31 個歷史 slice **全部**誤判成「sim 量測了但沒 `.qa.json` PASS」，直接 FAIL 擋住一個完全無關的 commit——這是會讓整個 gate 機制在第一次意外落入 fallback 路徑時就癱瘓開發流程的具體故障模式。

**② is_sim 判定可靠否**：核實 systems 自己提出的疑慮成立。spec §verdict schema 只寫「measurer 寫，既有+加欄：`+is_sim: bool`」——純人工手動標記，無任何自動化 backstop。若 measurer 忘記標 `is_sim:true`（人為疏漏），gate 會誤判成「沒做 sim 量測」直接 PASS 放行，**QA 稽核被跳過——這正是整個 gate 機制想解決的核心衰減問題本身，靠純人工標記去防人工疏漏，邏輯上有點左手防右手**。建議（非阻斷，屬強化）：至少在 `raw_logs` 欄位含明確 sim 關鍵字（`seed`/`game_sim_multi`/`organic`/`seeded_warring` 等）卻 `is_sim` 未標或標 `false` 時，gate 印一則 warning（非 FAIL，因為關鍵字比對本身不是絕對判準）提醒人工複查，降低漏標風險而不引入新的 false-positive 源。

**③ hook 繞過（--no-verify）夠 fail-closed 否**：核實通過。`--no-verify` 是 git 內建 escape hatch，技術上任何 pre-commit hook 都繞不過使用者主動選擇跳過，只能靠流程規範（同既有 `constitution_gate` 先例：CLAUDE.md/`00_roles.md` 已有「禁跳 hooks 除非用戶明確要求」的軟約束）。這是接受「純技術無法完全 fail-closed，需流程紀律配合」的既有治理模式，非本次新引入的漏洞，核實通過，不需更嚴格處理。

**④ false-positive 擋正當 merge**：與①同一根因，已在①詳述，此處不重複。

**⑤ gate 本身免 QA（is_sim=false 自證）對否**：核實通過。`verification_gate.gd` 是純結構掃描+邏輯判斷工具，不觸碰 `scripts/simulation/` 任何遊戲邏輯，本身不需要 organic/seeded sim 量測（headless_test/import 等功能測試已足夠驗證其正確性），`is_sim=false` 推論自洽，免 QA 合理，無爭議。

## 判準結果
**HALT**——不是設計方向錯（fail-closed coupling 本身合理，S1/S2/S3 切片分法正確），是 spec 對「既存 31 個檔案在新 schema 下的過渡處理」完全沒交代，且這不是可以留給 implementer 自行決定的細節——選錯預設值（缺欄位→保守當 true）會讓 gate 部署當下就有實際卡死開發流程的風險。**要求 spec 明確補 3 點裁定**：

1. **缺 `is_sim` 欄位的既存/歷史檔案，明確定義預設值 = `false`**（建議方向：新規則不回溯性懲罰 schema 變更前就存在的檔案，符合 spec 自己 §核心 rule 開頭「只堵新衰減、不加無謂負擔」的精神——用「沒討論過 is_sim 的舊檔案＝視為沒做過 sim 量測」處理，而非保守 fail-closed 成 true）。
2. **「archive」機制具體怎麼運作**：誰負責把舊 verdict 標記/搬移成 archived？何時做？（若無此機制，31 個檔案會永遠處在 spec 定義的「active」狀態，即便 (1) 的預設值選對了，也建議明確定義流程降低未來混淆，尤其 S3 要往「掃全部 slice」的通用化方向走時,這件事會更重要）。
3. **QA 副檔名判定範圍**：既然歷史 QA 格式 5 種並存，建議明確規定「gate 只認 `.qa.json`，且只對 `is_sim:true` 的新 schema `.measure.json` 生效」——配合 (1) 的預設值裁定，歷史 4 種舊格式 QA 檔案會因為對應的 `.measure.json` 缺 `is_sim`（→視為 false）而自動被排除在 gate 檢查範圍外，不需要額外寫相容性解析邏輯去讀 `.raw.txt`/`.md` 格式。

**上述 3 點裁定後免重整輪**，都是機械性的「明確寫清楚預設行為」，不影響 spec 整體方向（S1 gate 邏輯本身、S2 hook 接法、S3 multi-seed 通用化路線圖皆核實合理）。dispatch build 前把這 3 點寫進 spec 即可。

## 溯源
Spec `docs/superpowers/specs/2026-07-18-verification-gate-sim-qa-coupling.md`；systems handback `2026-07-18-R2-systems-to-reviewer-verification-gate.md`；`docs/process/verdicts/` 實地掃描（31 個 `.measure.json` 全缺 `is_sim`、QA 檔案 5 種副檔名分佈、`A2c1.qa_verdict.md` 內容核對）；`constitution_gate.gd`（既有 fail-closed 運輸層先例，本次借鑑對象）。
