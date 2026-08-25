---
from: implementer
to: systems
status: consumed
topic: "[生育連續速率 done·branch feat/breed-rate-continuous @44d93f5d·T1 rel_surplus 比例量/T2 f=r/(r+K) K=0.15 + BASE_RATE=0.0133【註解寫明 §7 反推】/T3 累積器取代抽獎/★必查項 per-team 真實 elapsed + sentinel -1 首次只蓋戳記/T4 兩新欄入 fp/T5 breed 移出 LOD trials 其餘補償不動/T6 breed.born+rate_sample·gate①-⑩ 全綠:反推實算 30.1 日/名額、健康小村會生、餓村零產、無懸崖(單調+步長減半→步差減半)、pop3≡pop30、LOD 等價、穿梭不重複累加、冷啟動產 0、det×3 fp=244600896bd615f28cec06d56f96cb67、constitution 75、headless 0-new·⑩peaceful 90 日 breed.born=1 人口 24→25 平滑(30 日窗 0＝該世界 rel≈0.03→~250 日/名額，符合窮就少生)·headless 五個舊契約 breed 測依新契約重寫]"
branch: feat/breed-rate-continuous
commit: 44d93f5d
---

# 生育＝per-capita 相對盈餘驅動的連續速率 done

## 實作（照 spec §5–§8，零自作主張）
- **T1** `rel_surplus = food_flow_avg / max(pop × FOOD_PER_PERSON_PER_DAY, ε)`
- **T2** `f(r) = 0 (r≤0) / r/(r+K) (r>0)`、`K=0.15`；`BREED_BASE_RATE = 0.0133`，**註解寫明 §7 反推**（`1/30 = BASE × 0.5 × 5 × 1.0`），不是只寫 TEST VALUE。`persona_mult` 沿用既有 `醫療` 與 `_breed_balance`；醫療改寫成 `(1 + 醫療×0.667)` 以保持舊式 `0.1/0.15` 的相對語意（**沒新增旋鈕**）。
- **T3** `breed_progress += rate × eligible × elapsed_days`；`while progress≥1 且 minor<cap → minor+=1、progress-=1`。★另加一條：`minor >= cap` 時**直接不累加**（避免存滿一大桶後解禁瞬間噴出）。
- **★必查項** `breed_progress_last_tick`（新欄、sentinel `-1`）：`elapsed_days = (now − last)/TICKS_PER_DAY`、算完更新；**首次評估只蓋戳記不累加**。沒有用任何 cadence 常數當 elapsed。
- **T4** 兩新欄入 `_emit_teams`（`breedp=`/`breedt=`）。
- **T5** breed 的 LOD trials 分支移除；**其餘累積型補償（morale `w_eff` / 技能 XP / comply loyalty / unrest ×trials）原封不動**。
- **T6** `breed.born` + `breed.rate_sample`。

## gate（①–⑩ 全綠）
| gate | 結果 |
|---|---|
| ①常數註解指向 §7 | TDD 實算 `f(K)=0.5`、5 適齡 → **30.1 日/名額**（目標 30） |
| ②健康小村會生 | 60 日內 `minor=1`（舊規則為 0） |
| ③餓村不生 | `rel≤0` → 60 日零產、`progress` 不增 |
| ④無懸崖 | 單調不減 + **步長減半→最大步差同步減半**（粗 0.1176 vs 細 0.0625＝連續無斷點）+ `r≤0→f=0` |
| ⑤無絕對 pop 依賴 | 同 `rel_surplus=1.25` 下 pop3 與 pop30 每人速率因子相同 |
| ⑥LOD 等價 | near（每小時）vs far（每 12 小時）同 30 日 `minor` 相同 |
| ⑦★穿梭不重複累加 | 混合節奏（同 tick 再被 far pass 掃一次、Δt=0）結果 ＝ near |
| ⑧★冷啟動不爆 | 新隊首次評估 `progress=0`、`minor=0` |
| ⑨det/constitution/headless | **三跑 byte-identical** `fp=244600896bd615f28cec06d56f96cb67`（intended-change）、**PASS 75**、**0-new** |
| ⑩短窗 sanity | peaceful **90 日 `breed.born=1`、人口 24→25 平滑非指數** |

## ★兩件要你知道的
1. **⑩ 的 30 日窗是 0**，我加跑 90 日才見 1。原因不是機制沒動，而是**該世界真的窮**：`breed.rate_sample` 實測 `rel_surplus≈0.03`（p90 是 0.148）→ `f≈0.15` → `daily_rate≈0.004`／隊 → **約 250 日/名額**。這正是設計要的「窮就少生」，但也等於：**在現況的 peaceful 世界，人口增長會非常慢**。要不要調 `BASE_RATE`/`K` 是你們拍的錨，**我沒動**——只把數字擺上檯面。
2. **headless 五個舊契約 breed 測全部依新契約重寫**（新 helper `breed_within_days_for_test`：推真實時間看 `minor` 是否成長，取代「逐次抽獎看 `P5_breed` 事件」）。舊測寫法在新設計下必紅——這是預期的契約變更，不是回歸。

地基 KEEP。
