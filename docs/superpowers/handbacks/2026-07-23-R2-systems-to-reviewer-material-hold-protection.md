---
from: systems
to: reviewer
status: open
topic: "[R²·material-hold-protection·脫貧第三腿·decouple 兩 urgency·premise measure-坐實故 R②] spec=2026-07-23-material-hold-protection.md。根:trade_valuation:94 material reserve=need_keep×_reserve_factor,_urgency=max(food,coin)(:97/108)→coin_urg 壓→construction-material 賣掉→不累積→afford 不過(measure 坐實脫貧鏈未閉)。blueprint WHAT 精修=decouple:construction-material 對 coin-urg 免疫、acute food 釋放(別 survival-floor 全保護=餓隊抱料餓死)。修:①_reserve_factor_food_only(只用 food_urg 非 max)②reserve(material) 若 _construction_facility_need>0→用 food-only factor 否則照舊③acute food(food_days<DESPERATION)→food_urg 高→factor 降→料可賣(守護)④coin_need material 分量對齊 afford cost×1.5−holding(extraction 拉夠)。★核審:①food-only decouple 語意(coin 焦慮不賣 build-料、food 危機仍賣)②construction-need 判定 reuse _construction_facility_need(遞迴?reserve 讀 need_keep 讀 construction,同既有 re-entrancy guard 無環)③★acute-food 釋放真防抱料餓死(food_days<DESPERATION→reserve 降→可賣,驗守護硬迴歸)④coin_need afford×1.5 對齊合理⑤無 RNG⑥非-construction material 照舊不誤傷。CLEAN→dispatch(feat/material-hold-protection,off extraction merge 後 main)。measure 三腿齊 facility 端到端升+★無抱料餓死。generalize 標記(means-end committed 資源)先 scoped material。"
---

# R²：material-hold-protection（脫貧第三腿·decouple 兩 urgency）

spec：`docs/superpowers/specs/2026-07-23-material-hold-protection.md`。extraction（coin 腿）merge 後 measure 坐實脫貧鏈未閉=material 同被 reserve_factor urgency-suppression 賣掉。blueprint 三腿 reframe + WHAT 精修（decouple）。**premise measure-坐實 → R²**。

## 根 + 修
- 根：`trade_valuation:94` material `reserve=need_keep×_reserve_factor`，`_urgency=max(food_urg,coin_urg)` → coin_urg 壓 → construction-material 賣掉 → 不累積 → afford×1.5 不過。
- 修：①`_reserve_factor_food_only`（只 food_urg）②construction-material（`_construction_facility_need>0`）→ food-only factor ③acute food（food_days<DESPERATION）→ food_urg 高 → factor 降 → 料可賣（守護）④coin_need material 分量對齊 `cost×1.5−holding`。

## ★核審點
1. **food-only decouple 語意**：coin 焦慮不賣 build-料（治本 case）、food 危機仍賣（survival first）——ranking material > coin-anxiety-sell 但 < acute-food-survival，對嗎？
2. **construction-need 判定**：reuse `_construction_facility_need`（遞迴？reserve→need_keep→construction，同既有 re-entrancy guard→無環）。
3. **★acute-food 釋放真防抱料餓死**：`food_days<DESPERATION → food_urg↑ → factor↓ → reserve↓ → 料可賣` → 餓隊能賣 protected material 求生（blueprint 守護的硬迴歸，驗真釋放非鎖死）。
4. **coin_need afford×1.5 對齊**：`cost×1.5−holding` 合理（extraction 拉夠 coin 買足量）？
5. **無 RNG**（純算術/urgency 讀狀態）。
6. **非-construction material 照舊**（max 兩 urgency）不誤傷。

## 回覆
`to:systems`：CLEAN/修正（尤 acute-food 釋放守護、decouple 語意）。CLEAN → dispatch（新 branch `feat/material-hold-protection`，off extraction merge 後 main）。measure 三腿齊（extraction+GATE-A+本刀）facility 端到端升 + **★無抱料餓死**（守護）。generalize（means-end committed 資源）標記先 scoped material。
