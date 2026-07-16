---
from: implementer
to: systems
status: consumed
topic: 敗北出路前置完成——機制對但 under-fire（str_ratio 項反噬）；acceptance 數字待 blueprint 判 + 常數/公式調
---

# 敗北出路前置（絕境逃決策膽量秤）— 完成 + ★under-fire 呈報

worktree `feat/defeat-flee` @ `19ffb82`（base origin/main 18c2f00，已含 combat-defeat + 照妖鏡#1 探針）。
數據：`docs/process/verdicts/defeat-flee.fullprobe.json`（3 seed 1337/42/7，3月，vs pre-fix baseline）。

## 做了什麼（照 spec + reviewer 3 精修）
- `_mortal_flee_check(state,id_self,id_enemy)`：eff≤`MORTAL_EFF_POP=3` 瀕滅 → `mortal_pressure=clampf((1-str_ratio)+(3-eff)*0.3,0,1.5)` vs `flee_thr=MORTAL_FLEE_BASE(0.5)+courage*MORTAL_COURAGE_SPREAD(0.6)`，過則 `_force_retreat`+return true。
- `_eff_strength=team_strength×readiness`（棄 terrain 不對稱）。
- `_resolve_combat_round`：casualty 後 / drain 前 / 殲滅檢查前，雙方各查（a→return 再 b）。round 計數上移保各端一致。
- 探針分流：`mortal_flee.n`+`readiness_sum`（drain 前，別混 readiness_abandon）+ `mortal_flee.n_{courage桶}` + `annih.n_{courage桶}` + `combat.str_ratio_annih`。

## acceptance（3 seed，fix vs pre-fix baseline）
| metric | base→fix |
|---|---|
| `end_annihilation` | 17 → **15** |
| `end_mortal_flee` | 0 → **3**（全在 seed1337；42/7=0） |
| `end_rout` | 1 → 1 |
| `capture.total` | 1 → **1（未升）** |
| mortal_flee courage 桶(h/m/l) | 1337: 2/1/0 |
| annih courage 桶(h/m/l) | 1337:0/6/1、42:0/7/0、7:0/1/0 |
| `str_ratio_at_annihilation` mean | **6.5 / 9.3 / 6.7** |

## ★★診斷：機制對但 under-fire（str_ratio 項反噬，根因釘死）
三端**未復活**（annihilation 仍 15/19、capture 平、mortal_flee 僅 3）。根因=**`str_ratio_at_annihilation` mean 6.5~9.3（»1）**：
- 被殲滅的小隊 `_eff_strength`（=team_strength×readiness）**遠高於**對手（6~9×）→ 但仍因 **pop 歸零**（eff≤1）被殲滅。team_strength 反映 leader 技能/裝備，**不隨 pop 縮**→小隊「看起來強」卻死於人數。
- ∴ `mortal_pressure` 的 `(1-str_ratio)` 項對這些隊 **變負**（str_ratio»1）→ **壓抑** pressure → 遠低於 flee_thr → **不逃 → 殲滅**。
- eff 項 `(3-eff)*0.3` 上限僅 0.6（eff=1），單獨 < 中膽 flee_thr 0.8 → 光靠瀕滅程度也觸不動。
- ∴ 只有 str_ratio<0.33 的「真弱」隊才逃；多數小隊 str_ratio 虛高 → under-fire。

**courage 桶佐證**：annih 桶集中 mid（0/6/1 等），mortal_flee 桶 high=2（絕望勇者也逃，符 str_ratio≈0 例）——但**population courage 窄聚 mid** → 膽量梯度弱顯（非 bug，世界 leader courage 分布窄）。

## 待 systems/blueprint 判（spec「殲滅仍過高→報 systems」分支已觸）
機制無誤（膽量秤、殲滅線前 fire、byte-safe 探針），但**當前公式/常數 under-fire**。候選調法（你判，或回 blueprint）：
1. **改 mortal_pressure 公式**：`str_ratio` 項對小隊反噬——改用 **pop-based** 瀕滅度（如 `eff/MORTAL_EFF_POP` 或敗方 pop 佔比）取代/弱化 str_ratio 項，讓「小隊 pop 危」直接推 pressure，不被虛高 team_strength 抵消。
2. **調常數**：降 `MORTAL_FLEE_BASE`（0.5→更低）或升 eff 項權重（0.3→更大），讓瀕滅小隊更易逃。
3. **capture 端**：`_force_retreat` 對逃脫小隊未產 capture（俘虜端沒升）——需查 `_force_retreat` 俘殘部條件（spec 說「已完整」但實測 capture 平）。
4. 回 blueprint：三端配比意圖 vs 現實（team_strength 不隨 pop 縮=更根本的戰力模型問題？）。

我不擅自改公式/常數（願景+平衡=你/blueprint）。**請裁調法**，我照做再跑。

## 閘
- `--headless --import` 無 error；`game_sim_multi` 0 SCRIPT ERROR/invariants=0；`constitution_gate` PASS(29,0)。

完成判定 systems + blueprint（acceptance 三端配比）。
