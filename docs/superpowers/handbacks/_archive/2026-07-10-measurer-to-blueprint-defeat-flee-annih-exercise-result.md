---
from: measurer
to: blueprint
status: consumed
topic: 敗北逃 rev2 殲滅端 exercise 床結果——n_high>0 達成，但 annihilation=0（結構性，非機率稀），根因查到公式層
---

# 量測回報：殲滅端定向 exercise 床

工單：`2026-07-10-systems-to-measurer-defeat-flee-annih-exercise-bed.md`。床 code：
`.worktrees/defeat-flee/scripts/debug/defeat_flee_annih_exercise_bed.gd`（synthetic encounter matrix，非 organic warring；`--import` 後跑，`GODOT_TIMEOUT=180` 足夠，無 crash/error）。
數字全檔：`tools/orchestrator/runs/defeat-flee-annih-exercise.json`。

## 矩陣
courage{high/mid/low} × self_eff{1,2,3} × enemy_eff{1,2,3,4} × 20 repeat = 720 場，deterministic seed（900001+ 遞增）。

## 結果（分 courage 桶，self=受測方）
| courage | n | annihilation | mortal_flee | other(rout) | timeout |
|---|---|---|---|---|---|
| high | 240 | **0** | 160 | 80 | 0 |
| mid  | 240 | **0** | 180 | 60 | 0 |
| low  | 240 | **0** | 200 | 40 | 0 |

`mortal_flee.n_high=80`（**n_high>0 達成**✅，工單定案前提滿足）。`annih.n_high=annih.n_mid=annih.n_low=0`——**全 720 場，殲滅=0**。

## 根因：非稀，是結構性歸零（查到 code 層，非猜）
`NpcCombatSystem._resolve_combat_round` casualty 公式：
```
loss = int(round(eff_self * str_enemy_share * ROUND_CASUALTY_RATE(0.1)))
```
`MORTAL_EFF_POP=3` 是絕境逃判進場閘 → 進 mortal zone 的隊必 `eff∈{1,2,3}`。`str_enemy_share≤1.0` → 積上限 `3×1.0×0.1=0.3<0.5` → **恆 round 到 0**，與 seed/strength/courage 無關。手算驗證 eff∈{1,2,3}×str_ratio∈{0.3,0.5,0.7,0.9} 共 12 格全 0（見 json `root_cause_finding`）。flanking bonus 乘的是已 round 過的 0，救不回。

∴ 一旦隊進 mortal zone，**每 round 不流血**——只靠 `mortal_flee`（膽量壓力判）或 `_abandon_threshold`（readiness rout）收場，pop 永遠掉不到 ≤1。工單點名的「近均等 1v1 last-stand 窗」（self_eff=1 vs enemy_eff=1）在此矩陣裡也是 0——因為根本進不了會流血的路徑，不是「打不到這格」。

## 我不判的（blueprint/systems 裁）
organic full_probe 的 annih=0，**不只是**「n_high=0 sample 空洞」——即使 n_high>0 強制達成，annihilation 依然結構性 0。若配比意圖要「殲滅稀但>0」，現有 mortal-zone 內 round-casualty 路徑本身給不出這條路，需要（a）獨立於此 round 公式的流血管道，或（b）round-casualty 公式在小 pop 端的捨入方式重看——這是 systems 設計決策，非量測員調參範圍。

## 產物
- 床 code（worktree，守衛可複跑）：`scripts/debug/defeat_flee_annih_exercise_bed.gd`
- 數字 json：`tools/orchestrator/runs/defeat-flee-annih-exercise.json`
