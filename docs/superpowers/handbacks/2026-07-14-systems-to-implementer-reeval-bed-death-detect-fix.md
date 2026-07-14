---
from: systems
to: implementer
status: consumed
topic: "[L3] reeval_bed 死亡偵測 false-positive 修——瞬間 remove-readd 誤判死;改連續 N tick 查無;execlock worktree"
---

# L3：reeval_bed 死亡偵測 false-positive

QA/measurer 找團滅 specimen 時發現：`reeval_attribution_bed.gd` 死亡偵測**單次 `state.teams` dict 查無即判死** → Team18 在 tick7239 **瞬間 remove-readd**（併入嘗試的 lifecycle）被誤判永久死亡。→ measurer 把沒死透的隊誤當團滅。**在關鍵路徑**（要找真團滅 specimen 給 blueprint #3 驗死得連貫）。

## 在哪
worktree `.worktrees/survival-execution-lock`（`feat/survival-execution-lock` @ `200d7e49`）→ `scripts/debug/reeval_attribution_bed.gd`，死亡偵測那段（`elif spec_death_tick==-1 and not spec_last.is_empty(): spec_death_tick=tick`）。

## 改什麼（L3，擇一，你判哪個乾淨）
- **選 A（連續 N tick 查無，簡單）**：加計數器，連續 ≥N tick（建議 N=TICK_PER_DAY 或適當值）`state.teams` 查無才判死；中途重現則歸零。濾掉 remove-readd 瞬態。
- **選 B（讀真死事件）**：若有 extinct/population==0 的權威事件/清單（如 `_step_cleanup_extinct_teams` 或某 extinct probe），讀它而非 dict-membership 瞬態。更根本但要找對事件源。
- 傾向 A（低風險、bed-local）；B 若你發現有現成 extinct 權威源更好。

## 守則
- **只改死亡偵測判定**，不動 bed 其他行為（seed/env 開關/specimen trace 全不碰）。
- determinism 不破（純判定改，無 RNG）。
- 快驗：Team18 型 remove-readd 隊不再誤判死；真團滅隊仍正確偵測。

## 完成後
→ measurer 重跑找**真團滅 specimen**（死透隊）+ 已補 tap 的 Team20 可解釋 → QA 複判 → blueprint 批 execlock。
- L3 debug 床判定修，無需 R②。commit execlock 分支 + push + handback `to:systems`（或 `to:measurer` 告知可跑）。scope 疑義走 `to:systems`。
