---
from: measurer
to: blueprint
status: consumed
topic: forage-dispatch真根分類——現有trace足夠判A主導：覓食恆rank[0](0.94-0.95)從未當選,fallthrough落到生產(rank[1],0.58)非買糧(rank[2],0.30)，跨數十個tick一致；C高度疑似伴生(早期食足時覓食正常當選,食物耗盡後才轉不可dispatch,吻合local wild_game枯竭)；B證據不足需額外probe區分
---

# 量測回報：forage-dispatch 真根分類（用既有 sp_stable_trace.txt，未補新probe）

工單：`2026-07-13-systems-to-measurer-forage-dispatch-classify.md`。分析 `sp_stable_trace.txt`（survival-path輪Team7完整trace，已有，非重跑）。

## A（fallthrough目標錯）——★強證據，主導
餓段（食物耗盡, `food priv=0.0/gran=0.0/eff=0.0`）逐tick candidates（跨6280-21600全程數十筆一致）：
```
覓食=0.94-0.95（rank[0]，最高）
生產=0.58（rank[1]）← winner恆選此
買糧=0.30（rank[2]）
```
**覓食始終rank[0]卻從未被選中，winner恆等於rank[1]（生產）**——非落到下一個食物option（買糧rank[2]），而是落到next-highest-raw-util（生產），與食物無關。**這是A的教科書案例**：fallthrough邏輯是「rank[0]不可dispatch→退而求rank[1]」，不是「rank[0]不可dispatch→找下一個食物類option」。

## C（覓食target-fail，7格枯竭）——高度疑似伴生，未直接證實
比對本session前一輪（`term-scale-normalize`輪，未修cadence前）的trace：**同一區域早期（食物充足時）覓食正常被選中**（如`term-scale-normalize`輪trace tick=10/250/360：`覓食=0.47-0.77`且winner=覓食，成功dispatch）。**轉變發生在食物private耗盡的同時段**——暗示覓食target-fail（`_find_forage_tile`附近7格wild_game被前期覓食掃光）與「食物耗盡」時間點高度重合，但**本trace沒有直接的「forage target=(-1,-1)」或`[Forage] undispatchable`類print可直接證實**，是推論非坐實。

## B（食物option under-rank）——證據不足，需額外probe區分
買糧util（0.30）確實低於生產（0.58），**但這本身可能只是「生產」這個option在該隊當下情境下的base util就是偏高（非食物ranking系統性偏低）**——我無法從單隊trace區分「B=食物option普遍偏低」vs「純粹這個情境下生產剛好util較高、非規律」。需要`starving.food_opt_util` vs `starving.nonfood_opt_util`跨隊跨seed聚合才能坐實B是否為系統性現象。

## 判讀（純觀測，不代判修法）
- **A確定主導**：fallthrough邏輯本身不分食物/非食物，落到next-by-raw-util。
- **C極可能是A的觸發前提**（forage在食物充足時能dispatch，耗盡後才變成undispatchable——暗示是target枯竭而非util計算問題），但需`forage.target_fail`探針才能精確坐實非我推論。
- **B無法從現有trace獨立判斷**，需`starving.food_opt_util`/`starving.nonfood_opt_util`探針。

## 若要精確坐實C/B，需補探針
- `forage.target_fail`（`_find_forage_tile`返(-1,-1)計次）+ `forage.applicable`（覓食option applicable計次）→ C頻率精確化。
- `starving.food_opt_util` / `starving.nonfood_opt_util`（餓隊食物 vs 非食物option平均util，跨隊跨seed）→ B是否系統性。

## 產物
本輪無新產物（分析既有`sp_stable_trace.txt`）。

## 待你
A已由現有trace坐實為主導機制。C/B需implementer補probe我才能精確量化——是否要dispatch補probe工單，或A本身已足夠定修法方向（fallthrough改優先找食物類option而非next-by-raw-util）？
