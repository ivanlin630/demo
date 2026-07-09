---
from: systems
to: implementer
status: open
topic: 實作 敗北出路前置（絕境逃決策膽量秤）——spec 鎖(blueprint sign-off+reviewer CLEAN)
---

# 實作工單：敗北出路前置（絕境逃決策）

spec（已鎖，blueprint 三端配比 sign-off + reviewer CLEAN）：`docs/superpowers/specs/2026-07-09-defeat-model-flee-before-annihilation.md`

## 在哪做
**新 worktree** `feat/defeat-flee`（base origin/main；獨立）。

## 做什麼（照 spec + reviewer 3 精修）
1. `npc_combat_system.gd`：+`_mortal_flee_check(state,id_self,id_enemy)`（eff≤`MORTAL_EFF_POP=3` 瀕滅時 `mortal_pressure=(1-str_ratio)+(3-eff)*0.3` vs `flee_thr=MORTAL_FLEE_BASE(0.5)+courage*MORTAL_COURAGE_SPREAD(0.6)`，過則 `_force_retreat`+回 true）；`_resolve_combat_round` **casualty apply 後、drain(:190)前、殲滅檢查(:193)前**插雙方查（a→return,再 b，鏡射現行殲滅序）。
2. `_eff_strength(state,team)` = 2 行 `team_strength(state,team.team_id)*team.readiness`（棄 terrain 不對稱=一致）。
3. 探針（`warring_harness`）：`mortal_flee` **分開標籤**（記 drain 前 readiness，別混 readiness_abandon 池）+ `combat.str_ratio_at_annihilation` 分布。

## 驗（spec §驗收線）
- `--headless --import` 綠、sanity、constitution 綠。
- **★acceptance full_probe 3 seed(1337/42/7)**：①三端復活（`combat.end_annihilation` 降/`end_rout` 升常態/`capture` 升，殲滅稀但>0）②照妖鏡#1 啟動（`rout.n_*` courage 桶有數據，怯桶多勇桶少）③弱小隊倖存率升④大隊(eff>3)分布≈baseline⑤`str_ratio_at_annihilation` 集中≈1（殲滅=勢均消耗非絕望硬撐）。
- TDD 逐步 commit。

## 完後
handback to:systems + **acceptance 數字 to:blueprint 判三端配比**（blueprint pass）。**若殲滅歸零（過度逃）或仍過高** → 標明報 systems，我判調 `MORTAL_FLEE_BASE/SPREAD` 或回 blueprint。measurer 可背景併行 3 seed。
