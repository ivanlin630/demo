# 裁定(A)天花板量測——那2.4秒怎麼分給27格(世代7)

派工：`docs/superpowers/handbacks/2026-09-23-systems-to-measurer-measure-the-ceiling-thresholds-written-before-the-data.md`
補充：`docs/superpowers/handbacks/2026-09-23-systems-to-measurer-reading-rule-amendment-faction-ai-goes-in-the-fixed-bucket.md`

床：`scripts/debug/pass_tick_phase_breakdown_bed.gd`（同一輪加了 dt>2s 母體聚合 + near.faction_ai 判準）
樹：main @ 世代7（≥22ac1b096）｜config：warring_states｜種子：1337／42（同 B3）
母體：只取 dt>2s 的 pass tick（不是全部 pass tick）

## 硬體戳

```
seed1337: [HW] cpu=AMD Ryzen 7 5800X3D 8-Core Processor cores=8 threads=16 mem_free=16GB/31.9GB
seed42  : [HW] cpu=AMD Ryzen 7 5800X3D 8-Core Processor cores=8 threads=16 mem_free=16.5GB/31.9GB
```

## 判決行

```
seed1337: 母體=110個>2s pass tick／全部288個pass tick
  7格(vision/move/market+propagate+intel/interactions/faction_snapshot) 每pass平均=500.0ms（判準甲：<1000ms 夠）
  near.faction_ai 每pass平均=1301.5ms（單格佔比50.8%）
  S_fixed(7格+faction_ai)=70.3%（門檻≤40%）
  ★★★子判準(乙)：S_fixed>40% 且 faction_ai單格≥15% ⇒ 成為【前置票】

seed42: 母體=61個>2s pass tick／全部288個pass tick
  7格 每pass平均<1000ms(判準甲：夠)
  near.faction_ai 每pass平均=1111.1ms（單格佔比45.6%）
  S_fixed=72.5%（門檻≤40%）
  ★★★子判準(乙)：同上，成為【前置票】
```

## ★★★結論

```
兩顆種子一致：原本7格本身在門檻內(甲，每pass平均<1000ms)，
但補上 near.faction_ai 後 S_fixed 遠超40%門檻(70.3%／72.5%)，
且 faction_ai 單格本身就超過15%子門檻(50.8%／45.6%)
⇒ ★裁定(A)的天花板【不夠】——但根因不是7格本身太貴，是 faction_ai_system.gd:1218
  _evaluate_all_body 忽略傳進去的 team_ids、對 state.factions 跑全世界迴圈，
  導致它不能照原樣按隊錯開（按隊散成60批會把全世界派系AI重複跑60次）
⇒ ★按你信裡寫的規則：這【成為前置票】——要先讓 _evaluate_all_body 真的吃 team_ids
  (392行函式體)，(A)才有機會摸到門檻
```

## 落地(原始log)

`docs/measurements/pass-tick-ceiling-gen7-seed1337-v3-faiadd.log`
`docs/measurements/pass-tick-ceiling-gen7-seed42-v3-faiadd.log`

## ★誠實限(原派工兩條，仍適用)

```
①「攤成1/60」是理想錯開的上界，真實效果比這估計差（faction_ai本身連錯開的資格都沒有，這條更明顯適用）
②母體=dt>2s的pass tick，答的是「最壞情況怎麼組成」，不答平均情況
③S_fixed%用的分母是【母體自身>2s tick的總dt】(pass_dt_over2s)，不是外部參照值，
  跟你信裡舉例的「2.44s中位數×40%≈976ms」算法不同分母但同一條線(比值意義一致)
```
