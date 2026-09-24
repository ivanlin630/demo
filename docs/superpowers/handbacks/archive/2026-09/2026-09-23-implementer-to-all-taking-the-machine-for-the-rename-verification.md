---
from: implementer
to: all
status: consumed
slice: 裁定(A) 後續｜驗收
topic: ★★機器我佔了（量測員那輪跑完了，我量到 Godot=0，已扣掉自己那條鏈）｜★跑三件：`--check-only` ×2、`join_accept_measure_bed` **兩棵樹各一次**、`pass_tick_phase_breakdown_bed`｜★★★判準不是「綠」，是【兩棵樹的數逐字相同】
---

# 一、我要跑什麼（★逐條寫出來，免得別人以為我只是「跑一下」）

```
①--check-only：faction_ai_system.gd／join_accept_measure_bed.gd／pass_tick_phase_breakdown_bed.gd
   ★這一輪我動了【控制流】不只是字串 ⇒ parse 風險比前兩次高
②join_accept_measure_bed，★【兩棵樹】各跑一次、同 env（PERF_SEED=1337、ADHOC_DAYS=10）
   樹甲：A:/GDS/demo（main，舊鍵 evaluate_all_body.*）
   樹乙：A:/GDS/demo/.worktrees/stag（b62fd597e，新鍵 evaluate_loop1.*）
   ★★判準：那四顆數【逐字相同】—— 同一顆種子、同一份世界，改的只有鍵名
   ★★★若不同 ⇒ 我停，回報：那代表改名改到了【不只是名字】
③pass_tick_phase_breakdown_bed（只跑樹乙）：看三格的數，
   ★並確認那三條新守衛【在乾淨世界不要紅】——若紅，那不是抓到缺陷，是我門檻寫錯
```

★**床是 seeded 的**（`join_accept_measure_bed.gd:12-15`，`seed(sd)`，預設 1337）
⇒ ★★兩棵樹的比較有意義；**若它沒有 seed，這個比法本身不成立**，所以我先查了。

# 二、機器

```
量法（★自我排除走 process 鏈不是字串）：
  往上追 $PID 的 ParentProcessId 列出自己那條鏈 ⇒ 從 Godot 清單裡扣掉
結果：Godot = 0
```

★**跑完我立刻回報並放開機器。** 期間請別起 Godot。
