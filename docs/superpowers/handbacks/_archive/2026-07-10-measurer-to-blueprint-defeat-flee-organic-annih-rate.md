---
from: measurer
to: blueprint
status: consumed
topic: 敗北逃 rev2 organic 殲滅率——de-patch 後(a6b90e2/e8236cf) 3seed/3mo end_annihilation=0，觸你自訂「才回藍圖談放寬」支線
---

# 量測回報：de-patch 後 organic full_probe 殲滅端數字

工單：`2026-07-10-blueprint-to-measurer-defeat-flee-annih-organic-rate.md`。

## 跑法
標準 `seeded_warring_bed.gd`，3 seed（1337/42/7）3 月。
- baseline：main（無 flee code），輸出 `tools/orchestrator/runs/defeat_flee_base.json`。
- fix：`.worktrees/defeat-flee` @`e8236cf`（含 a6b90e2 de-patch + exercise 床 commit，非 core 邏輯變），輸出 `.worktrees/defeat-flee/tools/orchestrator/runs/defeat_flee_fix.json`（★路徑相對 `--path`，非 main repo 根——複跑注意）。
- `--headless --import` 已跑（新探針 key 生效，數字非 stale cache）。gate 綠沿用 implementer a6b90e2 handback 已報（`--import`/multi-sanity/constitution/determinism PASS），本次僅加 exercise 床 debug 檔、無 core 變更，不重跑三閘。

## 逐 seed 數字（fix worktree）
| seed | ended_n | end_annihilation | end_mortal_flee | end_rout | end_retreat | capture.total | mortal_flee.n_high |
|---|---|---|---|---|---|---|---|
| 1337 | 9  | **0** | 6  | 2 | 1 | 2 | 0 |
| 42   | 13 | **0** | 10 | 3 | 0 | 3 | 1 |
| 7    | 1  | **0** | 1  | 0 | 0 | 0 | 0 |
| **合計** | **23** | **0** | **17（74%）** | **5（22%）** | **1** | **5** | **1** |

annih 出現次數 = 0/23（0%）。`str_ratio_annih_n=0` 全 seed（str_ratio/pop_ratio_annih 無值可算——與 annih 未發生一致）。

## 對照定案判準（你信 §22-24 自訂）
> `end_annihilation`=0（organic 裡交集自然從不發生）→ **才回藍圖談是否 `MORTAL_COURAGE_SPREAD` 放寬**。

本次結果 = 此支線。**非「稀但>0」**——3 seed 9 個月合計 23 場戰鬥，annih 0 次。

## 附加脈絡（供你判斷放寬與否，不代判）
- 對稱床已證：annih 只在 brave×brave 同 eff 才發生（45%），organic `mortal_flee.n_high`（高勇氣小隊進戰次數）3 seed 合計僅 **1**——高勇氣小隊本身在 organic 世界極少落入 mortal zone 戰鬥，遑論撞到「敵方也 brave」的窄上加窄交集。
- 這與先前 exercise 床發現一致：annih 視窗窄（雙 brave 同 eff）× organic 進場率窄（courage 分布 + mortal-zone 進場本稀）= 兩層窄相乘，3 seed/9 月級樣本量級不夠撞出一次不算意外。
- 若要「稀但>0」在合理樣本量內成立，候選：`MORTAL_COURAGE_SPREAD`↑（拉開勇/怯 flee_thr 差距，讓中庸 courage 也可能撐到血戰）或加大 organic 觀測窗（更多 seed/更長月數，先確認是否真 0 還是超低機率非 0）。兩案都是你/systems 裁，我不代判。

## 產物
- baseline：`tools/orchestrator/runs/defeat_flee_base.json`
- fix：`.worktrees/defeat-flee/tools/orchestrator/runs/defeat_flee_fix.json`
