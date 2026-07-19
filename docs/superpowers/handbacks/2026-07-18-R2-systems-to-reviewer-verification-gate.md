---
from: systems
to: reviewer
status: consumed
topic: "[R²·verification-gate·結構強制 QA] 用戶定 rule:sim 量測→QA 必跑(fail-closed 擋 merge),沒 sim→免。審 gate 邏輯 edge case:①stale 舊 verdict 誤擋否(branch-scoped 夠?)②is_sim 判定可靠否(誰標,measurer 漏標=漏閘)③hook 繞過(--no-verify)④false-positive 擋正當 merge。spec `specs/2026-07-18-verification-gate-sim-qa-coupling.md`。CLEAN→dispatch build。"
---

# R²：verification-gate（sim→QA fail-closed）

spec `docs/superpowers/specs/2026-07-18-verification-gate-sim-qa-coupling.md`。用戶定 rule=有 sim 量測就要 QA 故事稽核（fail-closed 擋 merge），沒 sim 免（量測 discretionary）。結構強制非 doc 意圖（意圖層會衰減，血證=7/14 加回 QA 7/18 又跳）。

## 審（gate 邏輯 edge case）
1. **stale 舊 verdict 誤擋**：gate 掃 verdicts/，舊 slice 的 is_sim measure 若沒 archive 會不會誤擋新 merge？branch-scoped（傳 slice name 只查該 slice）夠不夠乾淨？
2. **is_sim 判定可靠否**：誰標 is_sim？measurer 手標=可能漏標（漏標 sim→gate 放行=漏閘）。有無更可靠判定（如 raw_logs 含 seeded_warring/organic 關鍵字自動判）？
3. **hook 繞過**：`--no-verify` 繞過（同 constitution_gate 須系統認可）——夠 fail-closed 否？
4. **false-positive**：擋到不該擋的（純結構/byte-identical slice 被誤判 is_sim）？
5. **gate 本身**：verification_gate.gd 是純工具（byte-identical，不動 sim 行為）→ 免 QA（is_sim=false，自證 rule）——對否？

## 判準
- CLEAN → dispatch build（S1 gate + S2 hook + verdict schema）。
- edge case 漏（誤擋/漏閘） → halt。

## 溯源
用戶 rule（sim→QA）;blueprint fail-closed 結構修法;spec;constitution_gate fail-closed 先例。
