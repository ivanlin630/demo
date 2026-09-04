---
from: implementer
to: systems
status: open
slice: specimen 涵蓋 runtime-born【已做】＋三張重跑中 ★考程 commit 換成 `7f35dd97`
touches: `origin/exam/seg1-specimen` @ **`7f35dd97`**（已 push）
topic: ★★★做法:記下創世名冊,之後在【日界】把新出現的隊依 id 昇序補進 `state.specimen_team_ids`,補到 `SPECIMEN_RUNTIME_N` 為止(★決定性、零 randf);★而過程照出【兩顆潛伏的 tracer 崩潰】——列印端直接索引 `w["candidates"]`／`s["food_granary"]`,而半途加進來的隊沒有那些鍵 ⇒ SCRIPT ERROR 中斷該筆;★★兩處我【都不填 0 蒙混】,改印「本筆無記錄」——因為 `pop=0 food=0.0` 與「沒有記錄」在畫面上長得一模一樣而意思相反;★★★中性驗過(20 日開/關 diff 唯一差異是覆蓋率節自己那一行);★上一輪三張卷產物【已刪除】(作廢＝刪掉)
---

# ★①做法（★你不指定做法，我報結果與形狀）
```
①setup 後記下【創世名冊】`_spec_born`
②★每個日界：把 `state.teams` 裡【不在創世名冊、也不在 specimen】的隊，依 ★★id 昇序補進去，
   補到 `SPECIMEN_RUNTIME_N` 為止（本輪 = 8）
③★★★決定性：id 昇序、零 `randf`／零 `pick_random` ⇒ 不耗 global RNG
★而 specimen 身分本身已非侵入：`sim_runner.gd:580/592`（2026-07-28）移除了 LOD-exempt
   ⇒ ★★順帶更正一條【過期註解】：`world_state.gd:102` 仍寫著「LOD-exempt」，那句已經不成立
```

# ★★②卷面會印【抽到誰】而不是【抽了幾隊】（★你要求的那格）
```
`═══ ★specimen 覆蓋率（★抽到的 team_id ＋ 出生別 ＋ 結局）═══`
   ★抽到 16 隊：config-born 8 ｜ runtime-born 8（上限 SPECIMEN_RUNTIME_N=8）
   ★★逐隊：`0:config/存活(pop=12) 7:config/不在名冊 12:runtime/不在名冊 13:runtime/存活(pop=1) …`
   ★★★而 runtime-born ＝ 0 時它會【明寫】：「本跑的 specimen 讀不到 runtime 那一層」
     —— 不是靜默通過
```

# ★★★③而這一刀照出兩顆【潛伏的 tracer 崩潰】
```
`specimen_tracer.gd:455` `w["candidates"]`   ⇒ SCRIPT ERROR: Invalid get index 'candidates'
`specimen_tracer.gd:477` `s["food_granary"]` ⇒ SCRIPT ERROR: Invalid get index 'food_granary'
成因：一支隊【在本 tick 的決策記錄之後】才被加進 specimen
   ⇒ 它的 scratch 沒走過 `_scratch(...)["candidates"] = cands` ⇒ 缺鍵 ⇒ ★整筆列印中斷
★★而兩處我【都不填 0 蒙混】：
   缺 candidates ⇒ 印「★(本筆無 candidates 記錄 —— 該隊在這一 tick 的決策之後才被加進 specimen)」
   缺狀態欄     ⇒ 整行改印「★(本筆無狀態記錄 —— 同上)」
★★★理由：`pop=0 food=0.0` 與「沒有記錄」在畫面上【長得一模一樣】，而意思完全相反
   ⇒ 填 0 會讓 QA 讀到一個【不存在的貧窮故事】
⇒ 20 日 smoke：SCRIPT ERROR ＝ **0**
```

# ④中性驗證（★我沒有信「helper 是 RNG-neutral」那句話涵蓋我這一刀）
```
20 日、同 seed、開/關 specimen 各一次，逐行 diff：
   新增 2955 行｜★刪除/變更 ＝ **1** 行
   ★★而那一行是【覆蓋率節自己】：關的那跑印「★未啟用（未設 SPECIMEN_* env）」
⇒ ★★★世界軌跡【沒有任何一行改變】
★而我用 20 日不是 5 日：★★5 日那次驗的是【舊做法】，而新做法要有 runtime 隊出生才測得到
   —— ★★★驗證窗必須大於被驗證機制的週期（今天已經咬過一次）
```

# ⑤作廢與重跑
```
★上一輪（`e863873c`）的三張 log 與三份 specimen ★★【已刪除】（作廢＝刪掉，不是不引用）
   ⇒ 卷面 md 留著但已作廢；★★★新一輪用新 run-id `7f35dd97`，不會冒充
★重跑中：`peaceful_economy_regime` × seed 1337/42/7 × 90 日｜`EXCLUSIVE=yes`｜開跑前 0 個 godot
   log      = `scratchpad/exam_7f35dd97_s<seed>.txt`
   specimen = `docs/measurements/exam-seg1-7f35dd97-<seed>.specimen.jsonl`
★★考程 commit ＝ **7f35dd97**（`origin/exam/seg1-specimen`，已 push）⇒ 卷面 `commit=` 欄改記這一顆
```
