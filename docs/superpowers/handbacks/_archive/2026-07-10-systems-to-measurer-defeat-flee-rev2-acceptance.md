---
from: systems
to: measurer
status: consumed
superseded_by: 2026-07-10-systems-to-measurer-defeat-flee-annih-exercise-bed.md
note: implementer 已跑 3seed/3mo full_probe=sample 空洞(annih=0 全 seed,n_high=0)；blueprint 裁需定向 exercise 床,非 organic full_probe。見接續 spec。
topic: 敗北逃 rev2 acceptance——full_probe 3 seed(base main vs fix worktree)→ to:blueprint 判三端配比
---

# 量測工單：敗北逃決策 rev2 acceptance

## 現況
- worktree `feat/defeat-flee @84b9d66`（rev2：pop-based flee 公式 + capture pop-criticality 修 + `pop_ratio_annih` 探針）。**unpushed，local-only**。
- 系統已核 code 對 spec（`specs/2026-07-09-defeat-model-flee-before-annihilation.md` §D1 rev2）= **CLEAN**：
  - `_mortal_flee_check` 棄 str_ratio(pop-blind 反噬)→ `criticality=_pop_criticality(s)` + `outnumber*MORTAL_OUTNUMBER_W(0.5)`。
  - `capture_routed_as_captive` severity=`maxf(1-readiness, _pop_criticality)`（加性安全，reviewer 挖的 readiness-gate 脫鉤根因修）。
  - 探針 +`combat.pop_ratio_annih_sum`、+`conq.retreat_captured/no_capture`。
- reviewer rev2 verdict = CLEAN（4 查項全過，含框外自檢）。

## 跑什麼（標準 full_probe 床，3 seed 1337/42/7，3 月）
driver = `scripts/debug/seeded_warring_bed.gd`（env：`WARRING_SEEDS`/`WARRING_MONTHS`/`WARRING_OUT`/`WARRING_BASELINE`）。
1. **baseline（main，無 flee code）**：`--path A:\GDS\demo` + `WARRING_OUT=<base.json>`。
2. **fix（rev2 worktree）**：`--path A:\GDS\demo\.worktrees\defeat-flee` + `WARRING_BASELINE=<base.json>`（先對 worktree `--import`，新探針 key）。
   - ★禁原地 checkout；GODOT_TIMEOUT=600。

## 驗收線（blueprint 判配比，你只出數字不判）
1. **三端復活**：`end_annihilation` 顯著降、`end_mortal_flee` 升常態、`capture.total`（或 `conq.retreat_captured`）**升**、殲滅稀但 **>0**。
2. 照妖鏡#1 桶（`mortal_flee.n_high/mid/low` + `annih.n_*`）有數據。
3. 大隊(eff>3)≈baseline（`MORTAL_EFF_POP=3` gate，大隊不受擾）。
4. `str_ratio_annih_mean` + `pop_ratio_annih_mean` 證殲滅集中眾寡均等（≈1，非「以多打少沒逃成」）。
5. `--headless --import`/sanity/constitution 綠；相關≠因果+3 seed。

## 完後
出 `defeat-flee.fullprobe.json`（rev2）+ handback **to:blueprint** 判三端配比（潰散常態/俘虜中頻/殲滅稀）。
**若仍 under/over-fire** → 標明 to:systems（調 `MORTAL_FLEE_BASE/COURAGE_SPREAD/OUTNUMBER_W/EFF_POP` 或回 blueprint）。
