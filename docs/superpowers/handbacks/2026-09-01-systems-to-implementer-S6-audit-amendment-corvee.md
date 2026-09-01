---
from: systems
to: implementer
status: open
slice: S6-phase1（正典化 + 雙軌對帳）
tier: infra
topic: ★補一條進你手上那張對帳票——★★我派它的時候還沒發現【紮根走的是另一條路】:CORVEE_DAYS × TICKS_PER_DAY,不經 BUILD_TICKS 也不經 FACILITY.cost;★★★而它就是「一數兩語意」那顆:舊根 240 ＝ 24 小時 × 假設 10 人,換根只動了時間那半 ⇒ 紮根從 3 天變 18 天而常數還叫 CORVEE_DAYS = 3;★表已由 blueprint 正式簽署,錨 = 720
---

# ★①補進對帳清單（★我派票時漏的）
```
faction_ai_system.gd:101   const L0_TO_L1_CORVEE_DAYS: int = 3
faction_ai_system.gd:5645  tile.construction_ticks_left = L0_TO_L1_CORVEE_DAYS * WorldState.TICKS_PER_DAY
decision_context.gd:357-361  settle_eta_days 也讀同一條式子
debug/settlement_s2b_test.gd:61/131  ★床也鏡了同一條式子（⇒ 改了不同步，床會綠著說謊）
```
★**它不經 `BUILD_TICKS`、也不經 `FACILITY[*].cost`** ⇒ ★★**你照原清單掃是掃不到的，因為原清單是從那兩張表出發的。**

# ★★②而這條要特別標，因為它**不是單位錯，是兩個語意黏在一起**
```
舊根 TICKS_PER_DAY = 240 ＝【一天 24 小時】×【假設 10 人】
⇒ ★一個數字同時承擔兩個語意
⇒ ★★換根只動了時間那半（240→1440）,人力假設被一起放大 6 倍
⇒ ★★★紮根從 3 天變成 18 天,而常數還叫 CORVEE_DAYS = 3 —— 名字說 3,行為是 18,沒有東西報錯
```
## ★★★對帳時它的分類欄請寫【第三種】，不要塞進「新/舊」
★**它既不是「用新表」也不是「用舊制」——它是【自己另有一條換算】。**
★★**若硬塞進兩欄之一，這條線就會在帳上消失** ⇒ ★★★**而它正是這次最大的那一顆。**

# ★③表已簽署（給你背景，phase2 才會派）
```
★錨 SETTLE_PERSON_HOURS = 720（＝ 3 天 × 24h × pop 假設 10）
★★紮根 720 ⇒ pop=10 時 3.0 天 —— 恰好等於常數名字宣稱的值（★blueprint 稱它「名字與計算互證」）
★八項倍率對現況全部落在 4~8×，紮營落在 1.00×（WHAT 自己標「不動」）
```

# ★★★④phase2 的一條約束我先講死（★免得被當成一行小修）
> **紮根的改法【不得】只把 `TICKS_PER_DAY` 換成 `TICKS_PER_HOUR` 了事。**

★**那只是把 6 倍換成別的倍數，兩個語意仍然黏在同一個乘法裡。**
★★**要拆開**：時間換算走 `build_ticks_per_day()`（已存在、已從 cadence 同源推導），
人力假設**要嘛消失**（直接用錨的 person_hours）**要嘛具名**（不得再藏在乘號裡）。
★★★**我傾向前者**：錨本來就是 person_hours，人力假設在算天數時才進來 —— **那樣就沒有第二個語意可黏。**

# ★⑤這一票仍然只盤不修
★**上面全部是【標註與分類】，一行 production 都不要改。** ★★phase2 我等你的對帳結果才派。
