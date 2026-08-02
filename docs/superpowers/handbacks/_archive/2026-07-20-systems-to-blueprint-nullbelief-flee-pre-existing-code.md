---
from: systems
to: blueprint
status: consumed
topic: "[急查·code 強證 null-belief-flee=PRE-EXISTING 非 E 引入·E 沒碰個體 FLEE 路·route measure 確認] 查 E branch diff(62697e6c vs 8146c4a2)只碰 4 檔:E1/E2/E3(faction_ai conquest/JOIN/subjugate belief_pos)+E5(strategic breakout _find_escape_dir 用 belief)。★E5=_assign_breakout 設 strategic_assignments[-1]=sa_pos(移動分派)非 task=逃跑/flee_from→E5 不是 team75/4/13 culprit。★team75/4/13 的 task=逃跑+flee_from=(-1,-1)=個體 FLEE 路(faction_ai:1595/1948 flee_from_pos=_flee_threat_pos=威脅 belief 位;positionless→(-1,-1);movement:81 說『(-1,-1)不設 target 靠 release 收』但沒 release→卡凍結)。★E 沒碰這條路→null-belief-flee=PRE-EXISTING(slice2 belief-化威脅位+缺 flee-release),E 改世界暴露它(cascade)非引入。∴ 建議:Slice E belief-化機制方向對(team67/54 coherent 證)可 release-pass;null-belief-flee 另立 known-issue+★Slice D 前必修(每 belief-化 slice 都會暴露更多)。已 route measurer baseline diff 確認 code 判讀。修方向認可(flee_from=(-1,-1)→release FLEE 轉覓食,look-before-leap)。"
---

# 急查：code 強證 null-belief-flee = PRE-EXISTING，非 E 引入

## E branch 只碰 4 檔（diff 8146c4a2 vs 62697e6c）
E1/E2/E3（`faction_ai` conquest/JOIN/subjugate move_target→belief）+ E5（`strategic_ai` breakout `_find_escape_dir` 用 belief 位）。

## ★E5 不是 team75/4/13 的 culprit
`_assign_breakout`（`strategic_ai:159`）設 `self_team.strategic_assignments[-1] = sa_pos`（**空間移動分派**），**不設 `task=逃跑`/`flee_from`**。∴ team75/4/13 的 `task=逃跑 + flee_from=(-1,-1)` **不是 E5 產的**。

## ★team75/4/13 = 個體 FLEE 路（E 沒碰）
- `task=逃跑 + flee_from_pos` = 個體 survival FLEE：`faction_ai:1595/1948` `if td.task==TASK_FLEE: team.flee_from_pos = _flee_threat_pos(state, team)` = **威脅 belief 位**。
- positionless belief（`belief_pos` stale/無座標回 `(-1,-1)`）→ `flee_from_pos=(-1,-1)`。
- `movement_system:81`：`flee_from_pos==(-1,-1)（無威脅情報）→ 不設 target → continue，靠 release 收`——**但「release 收」顯然沒真發生** → team 卡 `task=逃跑` 凍結、不覓食、餓死。
- **★E diff 沒碰 `_flee_threat_pos`/`flee_from_pos`/1595/1948**（只 E1/E2/E3 conquest/JOIN/subjugate + E5 strategic_assignments）→ **這條路 E 一行沒改**。

## ∴ 結論：PRE-EXISTING（E 暴露非引入）
null-belief-flee 凍結機制 = **個體 FLEE 讀威脅 belief 位（slice2 belief-化）+ positionless 時缺真 flee-release** = **pre-existing**（slice2 或更早）。E belief-化改了世界軌跡（cascade）→ 讓這 pre-existing bug 現在打在 team75/4/13——**E 暴露非引入**。

## 建議
1. **Slice E belief-化機制方向對**（team67/54 coherent 證，你已認同）→ 可 release-pass（凍結非 E 之過，是 sample 撞到 pre-existing bug）。**但**你要 merge-hold 到 measure 確認我 code 判讀 → 已 route measurer baseline diff（8146c4a2 應同有此凍結=pre-existing 證）。measure 綠 code 判 → Slice E 放行。
2. **null-belief-flee 另立 known-issue + ★Slice D 前必修**：你顧慮對——每個 belief-化 slice（E 已、D 更大）都會暴露更多這 pre-existing bug。∴ **修在 D 前**（否則 D 的 doom-delta 被同款污染）。
3. **修方向認可**（你提的）：`flee_from_pos==(-1,-1)`（威脅無座標）→ **release FLEE → re-rank（轉覓食）**，非凍結。look-before-leap：FLEE 無座標 = not applicable，不該卡死。這是 movement/survival 的 flee-release 補洞（HOW 我 spec）。

## 序
measurer baseline diff 確認 pre-existing（code 已強證）→ Slice E 放行 + 另開 null-belief-flee fix 票（Slice D 前插入）。你若同意此判，我 route 走。
