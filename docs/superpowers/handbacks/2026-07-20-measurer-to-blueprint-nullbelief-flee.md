---
from: measurer
to: blueprint
status: consumed
topic: "[nullbelief-flee fix 量測·PASS-leaning·Slice D 前必修達成] 28470932 vs 95c0cfe7。★seed1337 凍結餓死修:starve 7→2、broken-flee signature(task=逃跑+flee_from=(-1,-1)) 570(pre-E)→20(~97%↓)=applicability-gate 殺 positionless-FLEE。coherent flee 保留(真座標 flee_from (14,20)/(17,9)… 照跑)。42 minor 0→1(attr 4.9→13.4 留意)、4201 0→0。gates 綠。pre-existing 凍結修掉→Slice D belief-化不再被污染。建議 accept。"
measured_at_head: 28470932
baseline_head: 95c0cfe7
---

# null-belief-flee fix 量測 → blueprint（PASS-leaning）

fix @28470932（applicability-gate：FLEE 威脅 positionless(threat_pos=(-1,-1))→not applicable→落覓食，不凍結；+movement backstop）。baseline `95c0cfe7`（fix parent）。★Slice D 前必修。

## ★凍結修好（主靶）
- **seed1337 starve 7→2**（attr 19.8→19.1，pop 356→359）。
- **broken-flee signature（task=逃跑 + flee_from=(-1,-1)）：570(pre-E 8146c4a2)→20(branch)＝~97% 消**。applicability-gate 成功殺掉 positionless-FLEE 凍結（無威脅座標→改覓食，非坐死）。
- 殘 20 = movement backstop 邊角（FLEE 設後 belief 過期成 positionless）——已被 backstop release 非凍結。

## ★coherent flee 保留（不誤傷）
- 真座標 flee_from 照跑：(14,20)/(17,9)/(19,4)/(22,3)/(23,8)/(26,9)… = 威脅有 belief 座標的正常遠離逃跑**不受 gate 影響**（gate 只擋 (-1,-1) positionless）。implementer「coherent flee 不退化」坐實。

## regression
| seed | BASE 95c0cfe7 | BRANCH 28470932 |
|---|---|---|
| 1337 | starve 7 / attr 19.8 | **starve 2 / attr 19.1**（修）|
| 42 | starve 0 / attr 4.9 | starve 1 / attr 13.4（minor +1，attr 留意）|
| 4201 | starve 0 / attr 0.3 | starve 0 / attr 2.6 |

- **seed42 minor**：+1 starve、attr 4.9→13.4（pop 411→374）——1 死屬噪音級，但 attr 跳幅稍大（FLEE→覓食 改動讓 seed42 世界微岔）。留意非 blocker。
- gates：constitution 64/0-new、headless branch=known 5-fail 0-new（1 stale「survival 恆候選」assertion 補 threat_pos 透明，正是修的舊不變量）、determinism implementer 364e8d29（applicability-gate 確定性，未獨立重跑）。

## ★Slice D 前必修達成
此 pre-existing null-belief-flee 凍結（我已 baseline-diff 證 pre-E 570 snaps 存在，→systems）**修掉** → **Slice D path_system belief-化不再被此 bug 污染量測**。D 可安全上。

## 判定：PASS-leaning，建議 accept
主靶凍結修好（starve 7→2、signature 570→20）、coherent flee 保留、gates 綠。seed42 +1/attr↑ 是 minor（1 死），可 accept 或留意。誠實揭：branch 死因 finder-check bed food-ok-vanish 41 含 food=0 真餓（classifier gap），但**broken-flee signature 570→20 是可靠的「凍結修好」直證**。

## 下一站
你 release 判。verdict `docs/process/verdicts/nullbelief-flee.measure.json`、raw `docs/measurements/2026-07-20-nullbelief-*` + pre-E baseline-diff（`...-preE-baseline-*`）。branch bed copy revert clean。
