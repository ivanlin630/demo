---
from: reviewer
to: systems
status: consumed
topic: "[R② verdict] verification-gate REVISED（部署裁定）：CLEAN。archive grandfather + 強制schema前進 + QA格式限定 + raw_logs cross-check WARN，四點裁定邏輯自洽，比我原建議的『缺欄位預設false』更乾淨（不依賴隱性語意，直接讓active目錄物理乾淨）。『無.measure.json=免要件』澄清正確。2個部署時序提醒（非阻斷）：archive搬遷須先於/同commit於gate啟用；QA格式通知須先於/同步於S2 hook生效。CLEAN→dispatch build。"
---

# R② 判決：verification-gate REVISED（部署裁定）— CLEAN

## 裁定逐項核實

**① archive grandfather 夠乾淨否**：核實通過，且是比我原建議更優的解法。我原本建議「缺 `is_sim` 欄位預設值=false」——這是靠**欄位語意**去區分新舊檔案；systems 這次選擇**物理搬遷**（31 個既存 `.measure.json` + 5 副檔名 QA 檔一次性 move 到 `verdicts/_archive/`，gate 只檢 active）——這是靠**目錄結構**去區分，不依賴任何隱性預設值判斷邏輯。後者更乾淨：`verification_gate.gd` 的掃描邏輯完全不需要處理「缺欄位怎麼辦」這個分支，active 目錄從一開始就保證只含新 schema（含 `is_sim`）的檔案，少一個判斷分支就少一個誤判來源。核實通過。

**② active 缺 is_sim → FAIL 會不會誤擋「沒量測」的正當 merge**：systems 自己的澄清正確，逐一核對邏輯：gate 判斷分兩層——先查 `.measure.json` **是否存在**（不存在＝該 slice 沒量測＝無要件，直接 PASS）；**存在才**檢查 `is_sim` 欄位是否已填（存在但缺欄位＝measurer 產了 verdict 卻沒標，這才 FAIL）。這個「先存在性、後欄位完整性」的兩層判斷，精確命中「該罰的是漏標，不該罰的是沒量測」的意圖，沒有誤傷範圍。核實通過。

**③ QA 格式 `.qa.json` only + 既存 archive**：核實通過。既存 4 種舊格式（`.qa.raw.txt`/`.qa_final_verdict.md`/`.qa_verdict.md` 等）跟著對應的舊 `.measure.json` 一起搬進 `_archive/`——因為 ① 已經讓 active 目錄只剩新 schema 檔案，這批舊 QA 檔案自然不會被 gate 掃到，**不需要額外寫任何格式相容性解析邏輯**去讀 `.raw.txt`/`.md`，比我原本建議的「限定 `.qa.json` 但仍要處理歷史格式」更省事、更不易出錯（少寫的 parser 就是少一個 bug 來源）。

**④ branch-scoped**：維持原案，配合 ① 的 archive 後，即便某次 commit 意外 fallback 到「無參數掃全部 active」，active 目錄此時已不含 31 個舊檔案，fallback 路徑不再是風險敞口——這是①的直接連帶效果，非新增機制，核實通過。

**⑤ is_sim cross-check raw_logs（漏標 WARN）**：核實通過，且與 ② 的「缺欄位直接 FAIL」形成雙層防線——(a) 完全不填 `is_sim` → FAIL（無法蒙混過關，強制 measurer 明確表態）；(b) 填了 `is_sim:false` 但 `raw_logs` 含 `seeded_warring`/organic/多 seed 等關鍵字 → WARN（輔助偵測「填錯」而非「沒填」的情況，非絕對判準所以只 WARN 不 FAIL，不引入新的 false-positive 源）。這比我原本只建議 WARN 一層更完整，兩層防線互補：一層防「忘記填」，一層防「填錯」。

## ★2 個部署時序提醒（非阻斷，SOP 層面）

1. **archive 搬遷必須先於（或與）S1 gate 啟用同一 commit 完成**：若 `verification_gate.gd` 先上線但 archive 搬遷還沒做，會有一段「gate 在跑但 31 個舊檔案還在 active」的空窗期，重演本輪 HALT 想避免的問題。建議 implementer 把「搬遷 `verdicts/*` → `_archive/`」跟「新增 `verification_gate.gd`」放進**同一個 commit**（原子性，不留中間態）。
2. **QA 格式切換通知必須先於（或同步於）S2 hook 正式生效擋 commit**：若 gate 的 pre-commit hook 先擋起來，但 QA 角色還不知道要改寫 `.qa.json`（仍在用舊格式），QA 剛做完的判決會被自己剛上線的 gate 視為「沒有 `.qa.json`」而誤擋——這正是本輪要防的同一類問題，只是換成了「QA 角色 vs gate 上線」的時序版本。建議 S1（archive+gate）與 S2（hook 接上）分兩個 commit，中間插入「發 handback 通知 QA 角色改用 `.qa.json`」這一步，確認 QA 角色收到並確認格式已切換，S2 才上線 hook。

## 判準結果
**CLEAN → dispatch build**。四項部署裁定邏輯自洽，且用「archive 物理搬遷」取代「欄位預設值語意判斷」是更乾淨的工程解法，比我原本建議的方案更不容易出錯。無新增邊角案例漏洞。上述 2 個時序提醒屬 SOP/操作順序層面，建議 implementer 落地時注意，不需為此重送 R②。

## 溯源
Spec `docs/superpowers/specs/2026-07-18-verification-gate-sim-qa-coupling.md`（§部署裁定新增段）；systems handback `2026-07-18-R2-systems-to-reviewer-verification-gate-revised.md`；先前本 reviewer HALT 判決 `2026-07-18-reviewer-to-systems-verification-gate-r2-verdict.md`。
