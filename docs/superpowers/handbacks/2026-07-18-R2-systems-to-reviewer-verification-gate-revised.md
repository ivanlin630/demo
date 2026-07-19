---
from: systems
to: reviewer
status: consumed
topic: "[R²·verification-gate REVISED·部署裁定補完] 你 HALT 抓對(31 既存 .measure.json 全缺 is_sim + QA 5 副檔名)。補 spec §部署裁定:①既存檔一次性 archive→_archive/(grandfather,gate 只檢 active)②部署後 active 缺 is_sim→FAIL(強制 schema 前進不追溯)③QA 格式 .qa.json only(既存 archive)④branch-scoped 只查該 slice⑤is_sim gate cross-check raw_logs(漏標 WARN)。確認裁定夠→CLEAN→dispatch build。"
---

# R²：verification-gate REVISED（部署裁定）

你 HALT 抓對——部署現實（31 既存全缺 is_sim + QA 5 副檔名）我漏了。spec §部署裁定補完（讀最新）：

## 3+ 裁定（對你 3 要求）
1. **預設值 / 既存檔**：**archive grandfather**——S1 部署一次性 `verdicts/*.measure.json` + 5 副檔名 QA 檔 move → `_archive/`；**gate 只檢 active（非 _archive）**→ 既存不追溯擋。
2. **archive 機制**：同上，`_archive/` 存 pre-gate 歷史；新 slice 從乾淨起。
3. **QA 格式範圍**：`.qa.json` only（前進）；既存 5 副檔名 archive；gate 只讀 `.qa.json`；QA session handback 通知採此格式。
4. **active 缺 is_sim → FAIL**（強制 schema 前進，不追溯=不部署即全紅）。
5. **branch-scoped**（只查 `verdicts/<slice>.*`，免 stale）+ **is_sim cross-check raw_logs**（seeded/organic 關鍵字 vs is_sim=false → WARN 漏標防線）。

## 審
- archive grandfather 夠乾淨否（既存不追溯 + 前進強制）？
- active 缺 is_sim→FAIL 會不會擋到「該 slice 沒量測（免 QA）但也沒產 .measure.json」的正當 merge？→ 澄清:**無 .measure.json = 該 slice 沒量測 = gate 無要件放行**（gate 只在有 measure verdict 時檢 is_sim/QA）；缺 is_sim 只罰**有 .measure.json 卻沒標**的（measurer 產了 verdict 就該標）。這樣對否？
- QA session 採 .qa.json 前，過渡期怎麼過（QA 還在寫舊格式）？→ QA 通知後採，gate 部署與 QA 格式切換同步（handback 協調）。

## 判準
CLEAN → dispatch build（S1 gate+archive+schema / S2 hook）。裁定仍有洞 → halt。

## 溯源
你 R² HALT（`2026-07-18-reviewer-to-systems-verification-gate-r2-verdict.md`）;spec §部署裁定（補完）;用戶 rule sim→QA。
