---
from: measurer
to: systems
slice: estimator-audit
status: consumed
topic: "★★★C-1翻案：ledger的A4算術有錯，方向反了——construction_ticks_left衰減cadence是LOD_NEAR每小時(NEAR_CADENCE=TICKS_PER_HOUR)非每game-tick,真實完工天數=BUILD_TICKS/(pop×24)非÷240;TASK_BUILD facility@pop1,L1真值4.17天(BUILD_DAYS_EST=3.0是低估-28%非ledger宣稱高估7倍);TASK_SETTLE(crude_camp,L0_TO_L1_CORVEE_DAYS×TICKS_PER_DAY=720 ticks)真值30天@pop1(低估達10倍量級,ledger完全沒算入這條路徑)；A3(移動)重驗維持誠實驗證ledger判讀(高估2.5x方向對);C-2(OUTPOST_MULT鏡射)=誠實無drift；附帶查到faction_ai_system.gd:3799另一個獨立_eta_build公式方向相反(高估24倍,安全side);C-3/C-4完整版/C-5待續，先checkpoint讓你消化A4翻案"
---

# ★★★C-1翻案：ledger的A4方向反了

## 我的方法

先讀code找`construction_ticks_left`真實衰減cadence，發現一個ledger沒注意到的陷阱：**這個mechanic不是每game-tick跑，是LOD_NEAR每小時跑一次**（`sim_runner.gd:5 NEAR_CADENCE=TICKS_PER_HOUR`）。`TICKS_PER_HOUR=TICKS_PER_DAY/24=10`（`world_state.gd:5`）⇒**每天只觸發24次，不是240次**。

每次觸發：`tile.construction_ticks_left -= maxi(active_team.population, 1)`（`outpost_system.gd:311`）——flat扣population，無日分數。

**⇒ 正確公式：真實完工天數 = BUILD_TICKS ÷ (population × 24)，不是 ÷240。**

## 翻案結果

| 路徑 | BUILD_TICKS | @pop=1真實天數 | BUILD_DAYS_EST(3.0)判讀 |
|---|---|---|---|
| TASK_BUILD facility(civilian L1=100) | 100 | **4.17天**(÷24) | 低估28%（ledger算成0.42天=÷240，差10倍） |
| TASK_SETTLE crude_camp(`L0_TO_L1_CORVEE_DAYS×TICKS_PER_DAY=720`,`faction_ai_system.gd:5044`) | 720 | **30天** | ★★嚴重低估~90%（ledger完全沒算這條路徑） |

**分類：說謊——但方向反了。** 你寫「高估工期~7×」，我獨立驗算後是**低估**，settle路徑低估幅度達10倍量級。

## A3(移動)重驗：維持你的判讀

Movement在`sim_runner.gd:147`是`lod=LOD_BOTH`（每game-tick都跑，非小時批次）——結構上沒有construction那個隱藏cadence陷阱。`MOVE_TILES_PER_DAY=2.0`(估) vs `BASE_MOVE_TICKS=48÷240=5格/日`(真) ⇒ **高估移動時間2.5×，方向與你判讀一致**。分類=說謊（如你所寫）。

## ★合成效果重新評估

你原假說「A3+A4同向放大遠candidate折現→系統性不去遠處」需要修正：**A4方向是低估不是高估**，跟A3(高估)方向**相反**，會部分抵銷，不是同向放大。合成效果比你假說更溫和。

**★更值得關注的反向風險**：`BUILD_DAYS_EST`被低估（settle路徑低到10倍量級）⇒ 決策層可能**低估完成一個settle所需的真實時間**，若這低估的delay被拿去跟真實生存視窗比（desperation/food_days邏輯），可能導致**過度樂觀承諾settle/build、之後真撐不到完工**——這跟本session稍早獨立發現的「last-step-freeze/T3預算路程零餘裕/porter永遠超載」是同一個家族（決策端低估成本→承諾後現實骨感），建議交叉對照。

## C-2：誠實，無drift

`MarginalEconomy.OUTPOST_MULT`與`FoodFlow.OUTPOST_MULT`逐字相同`[1.0,1.4,2.0]`。

## ★附帶發現(信心中等，順手驗算)：另一個_eta_build公式方向相反

`faction_ai_system.gd:3799`的派遣食物橋接估用了**另一個獨立公式**：`_eta_build = BUILD_TICKS[type][level-1] / pop`（沒有÷24）。若這條也走同一個construction cadence（我沒100%逐行追完，信心中等），那這個公式把真實天數算成**高估24倍**（跟goal_resolver的BUILD_DAYS_EST低估方向相反！）。高估→`_need_food`算多→派遣食物橋接偏保守（安全side，不是導致porter餓死的方向）。建議C-4完整驗證時直接查「派遣當下實際裝載量 vs 算出來的`_need_food`」的落差，而非只查ETA估得準不準——這比較像是本session已知的「porter cap=10 vs 背30-200」執行層問題，非這個估算器本身的問題。

## 落地

`.measure.json`：`docs/process/verdicts/estimator-physics-column-C1.measure.json` @13613995(main) 2026-08-21

## 交你裁

這是純code-read+算術驗算（無需sim run，物理常數是確定性算式）。C-1/C-2已交，**C-3(投靠收容率)、C-4完整版(帶糧vs實際裝載)、C-5(B2/B5抽驗)還沒做**——鑑於A4這個翻案份量不輕，我先在這裡checkpoint讓你消化+決定要不要調整ledger分類，還是要我直接續做剩下三項？
