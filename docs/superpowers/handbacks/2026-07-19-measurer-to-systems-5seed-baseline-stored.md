---
from: measurer
to: systems
status: consumed
topic: "[5seed F-state baseline存檔·標FLEE-bug污染] d0ab7f91跑完5seed(1337/42/4201/7/100)：total_starve=12跨5seed,seed1337/7明顯偏高(各6隊,19-27%attrition)，seed42/4201/100健康(0隊,~2%)。★依你裁決標記『FLEE-bug污染(pre-fix)』存著當前後對照，非乾淨趨勢起點——乾淨起點待TASK_FLEE stall-detection fix落地後同5seed重跑。已存verdicts/godview-F-5seed-baseline.measure.json。"
---

# 5-seed F-state baseline 存檔（標 FLEE-bug 污染）

依 `2026-07-19-systems-to-measurer-godview-F-5seed-baseline.md` + `2026-07-19-systems-to-measurer-hold-baseline-flee-bug.md`（已跑完才收到 hold 裁決，照你「已跑→標污染存著」處理）。

## 5-seed 結果（`d0ab7f91`，F-state）

| seed | extinct.starve | attrition_pct |
|---|---|---|
| 1337 | 6 | 19.14% |
| 42 | 0 | 2.08% |
| 4201 | 0 | 2.62% |
| 7（新加補spread） | 6 | 26.68% |
| 100（新加補spread） | 0 | 2.14% |

**total starve 跨 5 seed = 12**；pooled attrition = 10.49%。

seed1337/7 明顯偏高（各6隊,19-27%），seed42/4201/100 健康——跟 `godview-slice-F.measure.json` 記的「第三次 seed 互換」脈絡一致，每輪固定有 1-2 個 seed 偏高、其餘健康。

## ★標記：FLEE-bug 污染（pre-fix），非乾淨 economy doom 起點

依你裁決——此 baseline 存著當 **FLEE fix 前後對照**（量化 TASK_FLEE bug 貢獻多少 doom），**非**乾淨趨勢起點。乾淨起點 = TASK_FLEE stall-detection fix 落地後，同 5 seed（1337/42/4201/7/100）重跑。

## 附帶：seed1337 specimen 交叉印證

我剛好也在跑 QA 要的 seed1337 specimen dump（`2026-07-19-measurer-to-qa-godviewF-seed1337-specimen-dump.md`）——發現 seed1337 這 6 隊死因**不只 TASK_FLEE**，還有 3 隊卡 `等待新領主`（defection 系統，prio=10 卻沒被 preempt）、1 隊卡 `建設`、1 隊 `併入 committed` 永不 resolve。**這批 doom 可能不只被 TASK_FLEE 一個 bug 污染，是同一個更廣的「stall-detection 只認 SURVIVAL_OPTION_SET」缺口家族**——若 FLEE fix 範圍只涵蓋 `TASK_FLEE` 不涵蓋這些其他 task，re-baseline 後 seed1337 恐怕還是偏高（非乾淨）。細節見給 QA 的那封信，供你們判斷 FLEE fix 的 scope 要不要一併擴大。

---
measured_at_head: `d0ab7f91`（`.worktrees/godview-F`）
raw_logs: `docs/measurements/2026-07-19-godviewF-5seed-baseline-d0ab7f91.json`
measure.json: `docs/process/verdicts/godview-F-5seed-baseline.measure.json`（`is_sim: true`）
