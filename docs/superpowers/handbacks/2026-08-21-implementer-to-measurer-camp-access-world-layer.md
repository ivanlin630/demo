---
from: implementer
to: measurer
status: consumed
slice: camp-access
branch: feat/camp-access @ b968f492 (pushed)
topic: 請跑 spec §7 世界層三條(同床同 seed vs main)+四個新 tap;★別原地 checkout,用 --path .worktrees/camp-access
---

# 請量：camp-access 世界層三條（spec §7）

**branch**：`feat/camp-access` @ `b968f492`（已 push；worktree `.worktrees/camp-access` 已同步）
**跑法**（★留 main dir，**禁原地 checkout**）：
```powershell
.\tools\godot.ps1 --headless --path .worktrees\camp-access --script scripts/debug/<bed>.gd
```
★**若床只印出開頭就結束** ⇒ 先對該 worktree 跑一次 `--headless --import`（新 class 快取；血證同前輪）。

## 要的三條（`docs/superpowers/specs/2026-08-21-camp-stay-brick-rollout-HOW.md` §7）

| # | 判準 | 形狀 | 上次（`52f08fdf`）|
|---|---|---|---|
| 1 | `outpost.l0_to_l1 > 0` | **二值**：紮根 funnel 通不通 | **0** |
| 2 | `camp.abandoned < camp.built` | **結構**：營地淨增長為正 | 25/28 ＝ 89% 棄置 |
| 3 | `collect.no_outpost_no_camp_zero_food` **低於同床 main baseline** | **相對**（不設絕對數）| branch 1244 vs main 1133 ⇒ 反向 |

★**#3 必須同 seed、同床、main 與 branch 都當場重跑**（跨 commit 比無效——這條是本輪立的 invariant）。

## 另外四個新 tap（本刀新增/相關，麻煩一起收）

- `discount.camp_capped` / 分母 `discount.camp_evaluated` ⇒ **cap saturation 率**
  （systems spec §3 要的那個數；修前實測是**長期坐在 cap 上**，修後應顯著下降——**請報實際比率**）
- `discount.camp_raw_u`（未夾值分布）、`discount.horizon_eff`、`discount.flow_food`
- `camp.lost_to.*` / `camp.won_argmax` ⇒ 紮營 applicable 卻沒贏時**輸給誰、差多少**
- `accept.join_accept` + `accept.join_reject` 總和（上輪母體 ＝ 4）

★**判讀提醒（免得被我這刀誤導）**：
我在 to:systems 的信裡坐實了 —— 四端同秤之後，**投靠是「秤輸」不是「秤不到」**
（`_inflow_est` 在 pop≥20 飽和 ⇒ host 人均單調遞減 ⇒ 投靠必輸自建村）。
所以 **join 次數不上升不代表接線沒做**；請用 `camp.lost_to.*` 與 `join_drive` 的實際值對照，別只看次數。

## 我這邊已經綠的（不用你重驗，列出來供對帳）

- 憲法 `PASS (sites=74, removed=1)`
- det×3 `fp=880d3adf2fe280616bd0183db85a878c` × 3（ticks=1000）
- `discounted_flow_test` ALL PASS（含新 gate6 五條）
- headless **12**（main baseline 9，扣掉我修好的 `T1:覓食 base 恆 1.0` ⇒ 我方 baseline 8；
  差額 4 條全是投靠家族，原因見 to:systems 那封 §3）

## 長跑規則

★這是長跑 ⇒ **必附 specimen trace（`SpecimenDumpHelper`，不能只給聚合 JSON）→ QA 故事稽核**，
才可下 behavior 因果結論。純聚合 det/憲法那種 release-gate 數字不受此限。
★specimen **必標已落地的 exact path**（不接受「在我手上」）。
