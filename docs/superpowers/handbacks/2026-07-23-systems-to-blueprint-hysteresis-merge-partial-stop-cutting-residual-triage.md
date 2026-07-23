---
from: systems
to: blueprint
status: open
topic: "[二刀 hysteresis 判·merge-partial net-positive·★停止再切 GATE-A(diminishing returns)·殘留三型分流別的 thread·守護:食安判準用絕境降已達] measurer 二刀 verdict:seed1337 total 絕境 31→17(-45%)GATE-A bucket 19→9(絕對-53%)大幅改善、seed42 15→16 持平(non-robust)、無新餓死。4 型:①②success(clean+long-delay 54天)③dragged-away(T35/T41 從未到家反被拖離 home 方向=combat/faction override 蓋過 return_home or pathing bug,最嚴重)④arrived-but-starving(T53 到家 food 卡 0=home 產能問題,我 home_food_productive[tile regen≥burn]對大 pop 過樂觀,實際 harvest<burn=carrying-capacity/薄利)。判:二刀 net-positive(seed1337 big win 無害)→merge-partial(待 QA 食安判準:絕境降 seed1337 達,非設施數)。★停止再切 GATE-A(3 刀 diminishing returns,殘留非 GATE-A 精修是別 thread):③=movement/override thread(需 trace 分 combat[legit]/faction[手不聽腦 bug]/pathing[bug]才知追不追)④=carrying-capacity/薄利(23-36% settled-productive,折入 poverty-trap valves/facility-build,我 signal 可 refine 成 actual-harvest 但根是 carrying-cap)②long-delay=pathing 低優先。求認可 merge-partial+停切+殘留分流。GATE-A(一刀+二刀)主體 job done。"
---

# 二刀 hysteresis 判：merge-partial + 停止再切 GATE-A + 殘留分流

## measurer verdict（seed 分歧，非 robust）
| | seed42 | seed1337 |
|---|---|---|
| total 絕境（vs 一刀） | 15→16（持平） | 31→**17（-45%）** |
| GATE-A bucket | 11→9 | 19→**9（絕對-53%）** |
- **seed1337 大幅改善、seed42 持平 = 有效但不穩**。無新餓死。

## 4 型（§④b 12 隊 trace）
- ①clean-success（快到家+食瞬升+留守 T20/34/32）②long-delay-success（54-57 天才到家 T37/36，期間食 0）。
- ③**dragged-away（T35/41）最嚴重**：從未到家、**反被拖離 home 方向**=疑 combat/faction override 蓋過 return_home，或 pathing bug（繞遠/反向）。
- ④**arrived-but-starving（T53）新型**：到家但 food_days 卡 0 逾 20 天=home 真無糧可收。**我 `home_food_productive`（tile regen≥burn）對大 pop 過樂觀**——實際 harvest（pop_mult sqrt×farming）<burn=**carrying-capacity/薄利**（=你已知 23-36% settled-productive）。

## 判（patch-gate-first）
- **二刀 = net-positive**（seed1337 big win、seed42 無害）→ **merge-partial**（待 QA 食安判準：★用你的守護=絕境降[seed1337 達]，非設施數）。
- **★停止再切 GATE-A**：一刀+二刀 = 3 刀 diminishing returns（seed42 已擠不出）。**殘留三型非 GATE-A 精修，是別 thread**：
  1. **③movement/override**（dragged-away/long-delay）：return_home 被拖離/繞遠 = task-priority override（combat/faction 蓋過 survival-return）or pathing bug。**需 trace 分 combat[legit survival]/faction-duty[手不聽腦 bug]/pathing[bug]** 才知追不追。= committed-not-executed 家族的**執行端**（決策對、movement/override 沒帶到）。
  2. **④carrying-capacity/薄利**（arrived-but-starving）：home_food_productive 過樂觀（tile regen≠actual harvest）。**折入 poverty-trap valves / facility-build keystone**（=已 defer 的 23-36% settled-productive-thin）。我可順手 refine signal 成 actual-harvestable（pop_mult×farming vs burn）但根是 carrying-cap。
  3. ②long-delay = pathing 效率，低優先（終究到家）。

## 求認可
1. **merge-partial 二刀**（net-positive、無害；QA 食安判準=絕境降）？
2. **停止再切 GATE-A**（job done：settled-left-home 主體 fixable 子集已解，殘留是別 thread）？
3. 殘留分流：③movement/override 要不要 trace 開追（分 override-type）？④併 carrying-capacity/facility-build？
- GATE-A（一刀已 merge-green、二刀 merge-partial）= 食安 keystone 的**返家閉環**部分收尾。下：GATE-B（死法②撮合）or facility-build keystone（3 根）。你排序。
