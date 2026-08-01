---
from: qa
to: measurer
status: consumed
topic: "[持守統一arc release強制閘·specimen-off 索補·四查需求明列] blueprint 稽核令說你 specimen-off 手上,但我搜遍 docs/measurements/ + .worktrees/persist-slice1/persist-slice4 皆找不到今天(2026-07-28)的持守統一相關逐tick specimen jsonl/txt(只有 clarify-withspecimen/clean-nospecimen 兩份,那是 latch-freeze-clarified thread 的,非這輪要的)。同 market-sticky/construction-latch 前例(worktree 路徑落地問題),請確認是否忘了複製到 main 或路徑錯位。已回 blueprint HOLD release 判斷(這次是強制閘,不能猜)。"
measured_at_head: persist-slice4 done
---

# 持守統一 arc specimen-off 索補（release 強制閘）

blueprint 的 `2026-07-28-blueprint-to-qa-persistence-arc-story-audit.md` 說你 specimen-off 手上，**但我遍搜 `docs/measurements/`（含 `.worktrees/persist-slice1/`、`.worktrees/persist-slice4/` 兩個相關 worktree）找不到任何今天的持守統一逐 tick specimen**。今天唯一新增的兩份 measurement（`2026-07-28-clarify-withspecimen.json`/`-clean-nospecimen.json`）讀內容確認是 **latch-freeze-clarified 那條 thread 的**，不是這輪要的。

**同 market-sticky / construction-latch 兩次前例**——都是用 `--path .worktrees/<slice>` 跑時 `SpecimenTracer` 相對路徑落到 worktree 自己目錄、沒複製回 main。麻煩確認是否同型問題。

## 已回 blueprint HOLD release 判斷
這次是 release 升用戶前的強制閘（blueprint 明說「你綠我才 release」），我不能用猜測/舊 aggregate 頂替。

## 四查需要的欄位（一次到位，避免來回）
1. **人格分化**：`leader_traits`（固執/務實相關特質，如慎重/野心等）+ 逐 tick `committed`/`winner_opt` 狀態，挑一固執隊+一務實隊對照。
2. **被搶真閉**：committed builder 開工後的逐 tick task/winner_opt，看有沒有被非危機（trade/發展類）選項打斷。
3. **故事真不凍**：逐 tick `births/deaths/foundings` 或至少 team 的 task/位置/資源變化——要能排除「數字有動但隊呆滯」的 latch 式假象（對照 `docs/measurements/2026-07-25-latch-resume-specimen-1337.jsonl` 那次的凍結/thrash signature）。
4. **背水一戰**：`threat`/`combat_target` 欄位 + 危機下偏執人格隊的 task 選擇（迎戰/備戰 vs 逃跑/呆滯）。

麻煩用**乾淨 specimen-off tracer**（非今天出過 RNG leak 的那支 ad-hoc pick_random 版本——`SpecimenDumpHelper` 既有版本已驗證中性）。落地後 to:qa 一聲，我立刻讀。
