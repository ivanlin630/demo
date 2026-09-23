# P4 母體衛生——世代7同儀器對照（補派工）

派工：`docs/superpowers/handbacks/2026-09-23-systems-to-measurer-one-more-run-gen7-control-for-P4.md`
床：`scripts/debug/freeze_sample_bed.gd`（當前main版本,含母體三欄+P4死因+[B3-FREEZE]判決行,覆蓋進世代7樹跑,production tap呼叫點在22ac1b096已存在）
樹：`.worktrees/gen7-p4-control`（世代7邊界commit `22ac1b096`,detached,code-dirty=1僅床檔覆蓋）
config：warring_states｜種子：1337／42｜12天窗

## 硬體戳
```
[HW] cpu=AMD Ryzen 7 5800X3D 8-Core Processor cores=8 threads=16
```

## 判決行對照（P2、順手一起坐實）

```
世代7 seed=1337：[B3-FREEZE] gen=7 seed=1337 days=12/12 over2s_days=6/12 p99_ms=1110 verdict=FAIL
世代7 seed=42  ：[B3-FREEZE] gen=7 seed=42   days=12/12 over2s_days=4/12 p99_ms=948  verdict=FAIL
世代8 seed=1337：[B3-FREEZE] gen=8 seed=1337 days=12/12 over2s_days=0/12 p99_ms=257  verdict=PASS（已交付,73670028d）
世代8 seed=42  ：[B3-FREEZE] gen=8 seed=42   days=12/12 over2s_days=0/12 p99_ms=267  verdict=PASS（已交付,73670028d）
```
★★同儀器同config同seed,世代7兩seed皆FAIL、世代8兩seed皆PASS——凍結消失這句話現在有完整4點對照坐實(非單邊)。

## P4 母體三欄＋死因（世代7,本輪首次量到的同儀器基準）

```
世代7 seed=1337：真隊=71｜野獸pseudo-team=0｜在外子隊=42｜總計=113
                 extinct.starve/combat/other=0/0/0｜mergein.dissolve/subteam=0/0｜convoy.stranded=0
世代7 seed=42  ：真隊=67｜野獸pseudo-team=0｜在外子隊=37｜總計=104
                 extinct.starve/combat/other=0/0/0｜mergein.dissolve/subteam=0/2｜convoy.stranded=0

世代8 seed=1337：真隊=66｜野獸pseudo-team=0｜在外子隊=38｜總計=104｜死因/終止全0
世代8 seed=42  ：真隊=70｜野獸pseudo-team=0｜在外子隊=39｜總計=109｜死因/終止全0
```

★★★判讀：這是「不可判」被同儀器對照解開的一格——世代7 seed42 量到`mergein.subteam=2`(非零)，
證明這個母體在同一支儀器下**不是恆為0**（不是儀器沒接電，是這個config/種子下事件本來就稀疏）。
四個讀數裡三個是0、一個是2，世代7/8兩邊都以0為主——**沒有看到死因/終止事件因裁定(A)而系統性增加**，
但樣本太稀疏（4組讀數只有1組非零）不足以說「完全不變」，只能說「同量級、無可見劣化」。

## 誠實限
- p99_ms在「同seed」下兩次量測不同（本輪seed1337先後兩趟量到1110ms/1095ms）——這是真實壁鐘時間雜訊
  （seed只控世界邏輯決定性，不控真實跑速），不是不穩定,已知現象。
- mergein.subteam=2的樣本量過小（n=1個非零事件），不足以做分布或趨勢宣稱，只坐實「非恆零」這件事。

## 途中一個自抓錯誤（記入memory,見下）
第一次跑seed42時用了`SPECIMEN_SEED=42`環境變數——那是**另一支床**(`forage_blanket_evict_recheck_bed.gd`)
的變數名,`freeze_sample_bed.gd`實際讀的是`FS_SEED`。第一輪seed42的輸出跟seed1337逐行相同（母體三欄/幀數/
p99全同)才發現：兩次其實都跑了預設值1337。已用正確`FS_SEED=42`重跑,本卷面數字為修正後版本。

## 落地(原始log)
`docs/measurements/P4-gen7-control-seed1337.log`
`docs/measurements/P4-gen7-control-seed42.log`
