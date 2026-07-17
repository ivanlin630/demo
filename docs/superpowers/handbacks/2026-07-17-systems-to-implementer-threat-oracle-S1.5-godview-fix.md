---
from: systems
to: implementer
status: consumed
topic: "[dispatch·threat-oracle S1.5·god-view fix·行為變小] R² CLEAN。(a)_power_ratio(threat_assessment.gd:42)無belief fallback other.population→改保守 self_team.population(視等強,禁讀god-view,虛張生效)。(b)ctx 曝 perceived_power_ratio(clean,供 S2 winnable;禁拿 threat_react 當 proxy)。TDD+measure:虛張在無belief窗口生效+首接觸threat評估變保守。worktree feat/threat-oracle-s1.5 off origin/main@e0198666。invariants.md:173 已修名單我(systems owner)merge 時補。"
---

# threat-oracle S1.5：god-view fix + power_ratio 曝（行為變小）

## scope（R² finding1/2 解，S2 前置）
spec `docs/superpowers/specs/2026-07-17-threat-oracle-severity-convergence.md` §交付切片 S1.5。
1. **(a) 修 god-view leak**：`threat_assessment.gd:42` `var pop_est: int = int(intel.get("population_est", other.population))` → **fallback 改 `self_team.population`**（無 belief=視對方等強，比照 `invariants.md:173` 已補 5 處法/`diplomatic _get_pop_est` fallback=self_pop 模式）。**禁讀 `other.population`**（god-view，違 invariants.md:171，破虛張）。
2. **(b) ctx 曝 perceived_power_ratio**：`decision_context.gd` gather 時算 `perceived_power_ratio`（`_power_ratio` 邏輯或直取，clean 供 S2 winnable 用）+ 加 ctx 欄。**注意:此欄 ≠ threat_react**（threat_react=approach+hostility+power blend;perceived_power_ratio=純戰力比）——S2 winnable 用此純比，禁拿 threat_react 當 winnable proxy（finding2 誤用風險）。

## byte-identical? 否——行為變（小）
- (a) 首接觸敵隊（無 belief claim）那 tick，`_power_ratio` 從讀真 pop → 讀 self_pop（視等強）→ threat_react 微變（首接觸威脅評估變保守/中性）。**非 byte-identical**。
- (b) 純加 ctx 欄（無 caller 用前）= 該部分 byte-identical。
- measure=行為驗證（非 byte-identical）:**虛張/偽裝在無 belief 窗口生效**（隱藏/偽裝隊首接觸 threat 評估不再洩真 pop）+ 首接觸 threat 評估變保守（視等強）+ 無其他回歸（有 belief 路徑不變）。

## TDD
1. test:無 belief 時 `_power_ratio` 用 self_pop 非 other.population（合成兩隊,一無 intel claim,驗 pop_est=self_pop）。
2. test:ctx.perceived_power_ratio 曝值正確 + ≠ threat_react。
3. 修 + 綠。
4. seeded 對照:有 belief 路徑 byte-identical（fix 只動 fallback 分支）；無 belief 路徑行為變（記錄 delta 供 measure 判合理）。
5. git commit per green。

## 完成 → 下一站
done+綠 → to:measurer（虛張生效案 + 首接觸保守 + 有-belief 路徑不變 + ctx 欄正確）。measurer 綠 → to:systems 判 merge（我 merge 時補 `invariants.md:173` 已修名單 +1）。**S2（util 重設計）待 S1.5 merged 後另 dispatch**（winnable 立在乾淨 perceived_power 上）。

## 溯源
threat-oracle R² CLEAN（`2026-07-17-reviewer-to-systems-threat-oracle-revised-r2-clean.md`）；spec §S1.5；`invariants.md:165-173` 信息域不變量；`threat_assessment.gd:37-45`；`decision_context.gd:39,180,193`。
