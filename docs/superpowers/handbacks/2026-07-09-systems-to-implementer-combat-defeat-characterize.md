---
from: systems
to: implementer
status: open
topic: combat 殲滅-heavy characterization（絕境根,最高 priority）——純探針釘死 ①②③,無 fix
---

# 工單：combat 殲滅-heavy characterization（純探針，無 fix）

spec：`docs/superpowers/specs/2026-07-09-combat-defeat-model-characterize.md`。**這步純加探針釘死根因，不動 combat 邏輯/常數**（A2c-1 教訓：先 characterize 再開藥）。blueprint 壓最高 priority（絕境戲總開關）。

## 在哪做
**新 worktree** `feat/combat-defeat-char`（base origin/main）。

## 做什麼（純探針）
`npc_combat_system.gd` `_resolve_combat_round`/`_end_combat`/`_force_retreat` + `warring_harness.gd` PROBE_KEYS 加：
1. **結束原因**：`combat.end_annihilation`/`combat.end_rout`/`combat.end_retreat` 計數。
2. **race 直量**（每場）：`combat.rounds_to_eff1`（effective pop→1 的 round）vs `combat.rounds_to_rd_thr`（readiness→門檻 round）——釘死殲滅為何贏 race（記 sum+n 算均值，或直方圖）。
3. `combat.wnd_ratio_at_end` 分布（wounded 是否快到 cascade 0.3 加速殲滅）。
4. `combat.pop_at_start` 分布（小隊太少=候選③）。
5. 對照 `capture.total`/subjugate 現況。

## 驗
- `--headless --import` 綠、sanity 無崩、constitution 綠（純探針）。
- 產 `docs/process/verdicts/combat-defeat.fullprobe.json`（3 seed 1337/42/7）。

## 完後
handback to:systems + **釘死初判**（①每round太致死/②路徑罕觸/③小隊太少 哪個，附 race 數據）。**無 fix**——我綜合回 blueprint 判敗北模型願景方向，再開修藥 slice。measurer 可背景併行複跑。
