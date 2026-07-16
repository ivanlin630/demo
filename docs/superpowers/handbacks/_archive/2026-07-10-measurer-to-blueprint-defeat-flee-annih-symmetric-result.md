---
from: measurer
to: blueprint
status: consumed
topic: 敗北逃 rev2 殲滅端——de-patch 後 annih 非結構死，brave×brave 對稱格 45% annih（str/pop_ratio=1.000）；mid/low 對稱=0
---

# 量測回報：對稱格補跑（implementer 假說驗證）

工單/前情：implementer handback `2026-07-10-implementer-to-measurer-defeat-flee-annih-bleed-done.md`（commit a6b90e2 de-patch 傷亡累積器）+ 建議加 enemy=high 對稱格。**修正前一封回報**（`2026-07-10-measurer-to-blueprint-defeat-flee-annih-exercise-result.md`，@84b9d66 舊 commit，annih=0 結論已被 de-patch 推翻，見下）。

床：同一支 `defeat_flee_annih_exercise_bed.gd`（worktree，`--import` @a6b90e2 後跑，無 crash）+ 新增對稱段。數字全檔更新：`tools/orchestrator/runs/defeat-flee-annih-exercise.json`。

## 非對稱矩陣（enemy 固定 mid courage，720 場，含 de-patch 後 bleed）
| self courage | n | annihilation | mortal_flee | other(rout) |
|---|---|---|---|---|
| high | 240 | **0** | 185 | 55 |
| mid  | 240 | **0** | 212 | 28 |
| low  | 240 | **0** | 231 | 9 |

`n_high(mortal_flee)=87`（達成）、`n_high(annih)=0`。de-patch 前的「結構性零流血」已修（rout/capture 由 0→92/148），但 annih 仍 0——**只在此矩陣**（enemy 恆 mid）。

## 對稱矩陣（implementer 建議，self courage == enemy courage，同 eff，180 場）
| courage | n | annihilation | mortal_flee | other(rout) |
|---|---|---|---|---|
| **high×high** | 60 | **27（45%）** | 10 | 23 |
| mid×mid | 60 | 0 | 49 | 11 |
| low×low | 60 | 0 | 56 | 4 |

`str_ratio_annih_mean=1.000`、`pop_ratio_annih_mean=1.000`（annih_n=27）——殲滅時兩方勢力/pop 完全均等，非「以多打少」。

## 判讀（我不裁，數字給你）
1. **annih 非結構死**：de-patch 後、brave-vs-brave 對稱格能到 45%。implementer 假說證實——`mortal_flee` 兩路搶跑（任一方壓力先過自己 flee_thr 就先逃），非對稱矩陣裡 enemy 恆 mid（flee_thr 較低）→ enemy 恆先逃 → annih 進不去。
2. **mid×mid / low×low 對稱仍 0**：連雙方都不外部不對稱時，mid/low 的 flee_thr 本身夠低（≤0.8/0.5）→ 兩方壓力還沒到殲滅線就先逃。**只有雙方都 high courage（flee_thr=1.1）才撐得到殲滅**。
3. **待你判的「稀度」**：population-wide annih 率 = 取決於 organic 世界裡「brave×brave 同 eff 進 mortal zone」交集頻率——這需要 organic 分布數字（courage 分布 × mortal-zone 進場率），非本床能出。若 blueprint 認為此交集本就窄（courage 極端值本少、matched-eff 遭遇也少）→ 「稀但>0」語意成立；若嫌太窄（等於 near-0）→ 需 systems 開工單調（候選：`MORTAL_COURAGE_SPREAD`↓ 讓中庸 courage 也進得了血戰窗）。

## 產物
- 床 code 更新（worktree）：`scripts/debug/defeat_flee_annih_exercise_bed.gd`（新增對稱段，原矩陣不動）
- 數字 json 更新：`tools/orchestrator/runs/defeat-flee-annih-exercise.json`（含舊 pre-de-patch 段 supersede 註記）
