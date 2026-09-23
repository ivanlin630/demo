# 裁定(A)驗收——P2/P4/P7量測(世代8窗)

派工：`docs/superpowers/handbacks/2026-09-23-systems-to-measurer-dispatch-P2-P4-P7-gen8-window.md`
床：`scripts/debug/freeze_sample_bed.gd`(P2/P4，已加母體三欄+P4死因+[B3-FREEZE]判決行)｜
`scripts/debug/pass_tick_phase_breakdown_bed.gd`(P7，用既有pass tick dt總計換算吞吐)
樹：main（世代8，邊界 `92349afb6`）｜config：warring_states｜種子：1337／42｜12天窗

## 硬體戳

```
seed1337: [HW] cpu=AMD Ryzen 7 5800X3D 8-Core Processor cores=8 threads=16 mem_free=17.4GB/31.9GB
seed42  : [HW] cpu=AMD Ryzen 7 5800X3D 8-Core Processor cores=8 threads=16 mem_free=17.4GB/31.9GB
```

## P2 判決行(機器可讀，床自己印，格式未改)

```
[B3-FREEZE] gen=8 seed=1337 days=12/12 over2s_days=0/12 p99_ms=257 verdict=PASS
[B3-FREEZE] gen=8 seed=42   days=12/12 over2s_days=0/12 p99_ms=267 verdict=PASS
```
兩seed皆母體真跑滿(17280/17280 tick)，>2s事件=0，p99遠低於1000ms門檻——凍結消失了，
且這次有世代7同儀器同config同seed的對照(107/59事件，見`2026-09-23-B3-freeze-player-ruler-gen7.md`)，
implementer原先「拒絕講成凍結消失」的理由(缺對照)在此補齊。

## P4 母體衛生

```
母體三欄：
  seed1337：真隊=66｜野獸=0｜在外子隊=38｜總計=104
  seed42  ：真隊=70｜野獸=0｜在外子隊=39｜總計=109
死因(帶主詞)：
  兩seed皆 extinct.starve=0｜extinct.combat=0｜extinct.other=0
子隊終止：
  兩seed皆 mergein.dissolve=0｜mergein.subteam=0｜convoy.stranded=0
```
★誠實限：這一輪母體本身死因/終止事件恆為0(warring_states這個seed/窗內沒有隊死亡或子隊終止)，
所以「同量級」這句話目前**沒有可比的非零基準**——我沒有在世代7上跑過同一支帶死因統計的儀器版本
(那些print今天才加進床)，無法拿到gen7同儀器的死因數字做逐項比對。若這格需要更嚴格的「同量級」
坐實，需再派一輪：世代7 worktree上跑同一支(已加P4段落的)床，取得同儀器對照數字。

## P7 吞吐(ticks/真秒，對照錯開前基線)

```
基線(世代7，同儀器同seed，來自 docs/measurements/pass-tick-ceiling-gen7-seed{1337,42}-v3-faiadd.log)：
  seed1337：合計472446063+8802345=481248408us=481.25s → 35.91 ticks/s
  seed42  ：合計396720477+8692979=405413456us=405.41s → 42.62 ticks/s

世代8(本輪實測)：
  seed1337：合計140331304+128194474=268525778us=268.53s → 64.36 ticks/s（+79.2%）
  seed42  ：合計142823674+131878640=274702314us=274.70s → 62.91 ticks/s（+47.6%）
```
★★★兩seed方向一致：吞吐大幅**提升**（遠超±5%門檻，但方向是好的），不是「總工作量變多」。
成因對應前置票：`faction_ai_system.gd:1218 _evaluate_all_body`原本忽略team_ids對全世界重複跑，
該bug已在裁定(A)前置票修好(commit `16c5e0409`)，屬於本次改動連帶的效果，不是散相位本身的效果被算重了——
★誠實限：這代表P7原本設計的「散相位不該改變總工作量」這個假設沒有辦法乾淨隔離出「純散相位」的效果，
因為同一輪merge裡混了前置的faction_ai修法，兩者的效果疊在一起量。若要單獨看「散相位」貢獻多少，
需要一個只含散相位、不含faction_ai修法的中間樹，本輪未做(超出派工範圍)。

## 落地(原始log)

`docs/measurements/P2-freeze-gen8-seed1337-v2.log`／`P2-freeze-gen8-seed42.log`
`docs/measurements/P7-throughput-gen8-seed1337.log`／`P7-throughput-gen8-seed42.log`
