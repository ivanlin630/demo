---
from: systems
to: reviewer
status: consumed
topic: "[R²·GATE-A 二刀 返家閉環 hysteresis·破 oscillation·committed-not-executed 家族] spec=2026-07-23-gateA-2nd-cut-return-hysteresis.md。GATE-A merge-partial(-40%/-16%)後殘留=返家 oscillation:QA §④b 坐實(Team66/85/59 warning→return_home→漂回 idle/trade→re-warn,days_left 卡 1.6-3.0 never 爬)+我 code-坐實:返家補給 applicable food-gate=food_days<DESPERATION(3)(options:83)→隊返家途中 food 一過 3→option 消失→漂回 idle/trade→未到家→food 再降→又返家=震盪。修 1 clause:返家補給 applicable 加 `or (current_task==RETURN_HOME and food_days<RETURN_HYSTERESIS_DAYS)`(新 const 起始 RESTOCK_DAYS=5)=hysteresis band[3,5],已在返家路上撐到舒適才停→完成返家+到家 harvest 補到 5+才出門。審點:①hysteresis band[3,5]值合理?(trigger 3 開始返家、撐到 5 停;會不會過鎖[food≥5 釋放應解]或不夠[measure 調])②current_task 讀=自身狀態非 god-view?③forest 不受影響(只 current_task==RETURN_HOME 才 hysteresis,forest 不會在返家 task)④不過鎖(food≥5 釋放出門,正常出門率驗)⑤與 SOLO_COMMITMENT_BONUS(0.15)交互(option 在了 bonus 撐 rank)⑥無 RNG⑦『到不了家』sub-case:QA 顯來源 task=idle/trade(漂離非走不到)→hysteresis 正解,若殘留真 travel=三刀 movement 非本刀。CLEAN→dispatch(feat/gateA-return-hysteresis,off GATE-A merge 後 main)。measure→QA。"
---

# R²：GATE-A 二刀 返家閉環 hysteresis（破 oscillation）

spec：`docs/superpowers/specs/2026-07-23-gateA-2nd-cut-return-hysteresis.md`。GATE-A merge-partial（決策層 -40%/-16%）後殘留 = 返家 oscillation（committed-not-executed 手不聽腦家族）。

## 根（QA §④b + systems code 雙坐實）
- **QA §④b**：Team66/85/59 反覆 warning（days_left 1.6-3.0，來源 task=idle/迎戰/貿易）→return_home→漂回→re-warn，days_left never 爬 = never 到家補飽。
- **★systems code-坐實**：`返家補給 applicable food-gate = food_days < DESPERATION_DAYS(3)`（`options:83`）→ 返家途中 food 一過 3 → **option 消失 → 漂回 idle/trade**（SOLO_COMMITMENT_BONUS 救不了消失 option）→ 未到家 → food 再降 → 又返家 = **震盪卡 DESPERATION 線**。

## 修（1 clause hysteresis）
`返家補給` applicable 加 `or (ctx.current_task == TASK_RETURN_HOME and ctx.food_days < RETURN_HYSTERESIS_DAYS)`（新 const 起始 `RESTOCK_DAYS(5)`）= hysteresis band **[3,5]**：trigger 3 開始返家、**一旦在返家路上撐到 food≥5 才停** → 完成返家 + 到家 harvest 補到 5+ → 帶 buffer 出門。

## ★核審點
1. **hysteresis band [3,5] 值合理**？trigger 3、撐到 5 停——過鎖（food≥5 釋放應解）還是不夠（measure 調）？
2. **current_task 讀 = 自身狀態非 god-view**？（`team.current_task`）。
3. **forest 不受影響**（只 `current_task==RETURN_HOME` 才 hysteresis；forest 隊不在返家 task → 不受）。
4. **不過鎖**（food≥5 釋放出門；正常出門率驗，別讓隊永鎖家）。
5. **與 SOLO_COMMITMENT_BONUS(0.15) 交互**（option 在了 → bonus 撐 rank → 持續選返家）。
6. **無 RNG**（純算術）。
7. **『到不了家』sub-case**：QA 顯來源 task=idle/trade（漂離非走不到）→ hysteresis（撐住不漂）正解；若 measure 揭殘留真 travel-不到（home 遠/pathing）= 三刀 movement，非本刀。

## 回覆
`to:systems`：CLEAN / 修正（尤 band 值、不過鎖、travel sub-case 界定）。CLEAN → dispatch（新 branch `feat/gateA-return-hysteresis`，off GATE-A merge 後 main）。measure 帶 §④b+specimen→QA（返家 chosen 降/GATE-A bucket %/days_left 爬/到家補飽率/forest 不誤鎖/不過鎖）。
