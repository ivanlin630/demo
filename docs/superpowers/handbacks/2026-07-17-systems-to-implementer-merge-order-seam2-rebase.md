---
from: systems
to: implementer
status: consumed
topic: "[merge 時序裁定] bucketB 已先 merge+push origin/main@ad294112(comment-only 小)+baseline re-freeze 72。seam#2 S1 完成前 rebase 你的 seam#2 worktree onto origin/main@ad294112(納 bucketB 的 faction_ai_system.gd gate-ok 註)→ handback 前 branch current，避同檔 merge conflict。bucketB 標的是 _evaluate_*/_pick 等函式,你 seam#2 改 _facility_deficit=不同函式,rebase 應 auto-clean(近 hunk 若衝突手動取兩者)。"
---

# merge 時序裁定 + seam#2 rebase

你 bucketB done 提的同檔 conflict 預警 — 裁定：
- **bucketB 先 merge**（已完成，origin/main@`ad294112`，含 merge commit + baseline re-freeze 72）。comment-only 小 slice 先落地正確。
- **seam#2 S1 完成前 rebase**：你的 seam#2 worktree（off 舊 origin/main）→ `git rebase origin/main`（拉到 `ad294112`）再 handback，確保 branch current（[[feedback_worktree_stale_base]]）。
- **conflict 評估**：bucketB 的 inline `# gate-ok` 註在 `_evaluate_*`/`_consider_extraction`/`_pick_outpost_type`/`_decide_unified` 等函式；你 seam#2 改 `_facility_deficit`（不同函式）→ rebase 應 auto-clean。若近 hunk 誤衝突=手動取兩者（gate-ok 註 + registry 化並存，兩者獨立）。
- **baseline_v2.txt 現 72**：seam#2 若再 relocate/移除 facility fingerprint（`_facility_deficit::early_return/threshold` 現在 baseline L47/48），measurer 驗後我 post-merge re-freeze（同 S1 89 / bucketB 72 作法）——你 handback 報 gate sites 前後數即可，baseline 我管。

無其他變更。續你的 seam#2 S1（facility registry，byte-identical，逐 case file:line）。
