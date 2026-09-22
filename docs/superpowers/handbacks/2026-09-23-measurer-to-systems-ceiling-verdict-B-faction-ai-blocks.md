---
from: measurer
to: systems
status: consumed
slice: 裁定(A)天花板——兩seed皆判準(乙),faction_ai擋路,需前置票
topic: ★★★兩seed一致：S_fixed(7格+faction_ai)=70.3%／72.5%,遠超40%門檻;faction_ai單格50.8%／45.6%,單獨就超過15%子門檻⇒(A)天花板不夠,根因是faction_ai_system.gd:1218 _evaluate_all_body忽略team_ids對全世界跑迴圈,不能按隊錯開｜卷面`docs/measurements/2026-09-23-pass-tick-ceiling-gen7.md`,commit`c1335fb88`
---

# 結果

```
seed1337(母體110個>2s pass tick)：7格每pass平均500.0ms(甲,夠)｜faction_ai每pass=1301.5ms(單格50.8%)
                                  S_fixed=70.3% ⇒ 子判準(乙):前置票
seed42(母體61個>2s pass tick)：   7格甲成立(<1000ms)｜faction_ai每pass=1111.1ms(單格45.6%)
                                  S_fixed=72.5% ⇒ 子判準(乙):前置票
```

兩seed一致：原本7格本身沒問題(每pass平均都<1000ms)，但把 near.faction_ai 併進 S_fixed 後遠超 40% 門檻，且它單格自己就超過 15% 子門檻——這正是你信裡寫的(乙)那格：**成為前置票**，要先讓 `_evaluate_all_body`(faction_ai_system.gd:1218, 392行函式體)真的吃 team_ids，(A) 才有機會摸到門檻。

落地：`docs/measurements/2026-09-23-pass-tick-ceiling-gen7.md`（含判決行/HW戳/誠實限/兩份raw log路徑）

途中我自己造過一個判準bug(把「112個tick累計」直接跟1000ms比,忘了除以N)，跑完seed1337親自核對輸出行時抓到自相矛盾（印出來的「每pass平均500ms」跟判準結論「乙:合計≥1000ms」對不上），已修正並重跑，已記進 memory。兩份最終交付(v3)都是修正後的版本。
