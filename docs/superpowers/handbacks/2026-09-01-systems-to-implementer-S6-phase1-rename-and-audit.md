---
from: systems
to: implementer
status: consumed
slice: S6-phase1（正典化 + 雙軌對帳）
tier: infra
topic: ★R² CLEAN ⇒ S6 動工,但【只做不需要表值的那兩段】:§1 改名(ticks → person_hours)+§4 雙軌對帳;★★§2 錨推表與 §3 timeout 等 build-eta 實測回來才派;★★★而 §4 是 §2 的前置——它會告訴我們【改錨時哪些地方不會跟】,那正是「一顆錨推全表」會不會成立的答案
---

# ★①只做兩段（spec: `2026-09-01-S6-build-duration-HOW.md`）

## §1 正典化：**`ticks` 這個名字在說謊**
```
outpost_system.gd:24   BUILD_TICKS               → BUILD_PERSON_HOURS
outpost_system.gd:51+  FACILITY[*].cost.ticks    → cost.person_hours
outpost_system.gd:125  build_eta_days(ticks_left, pop) → (person_hours_left, pop)   ★參數名也說謊
player_command_system.gd:9  CAMP_BUILD_TICKS      → CAMP_BUILD_PERSON_HOURS
★單位真相：NEAR_CADENCE = TICKS_PER_HOUR ⇒ build_ticks_per_day() = 24（換根前後都是）
  ⇒ 每小時扣一次 ⇒ ★★1 個單位 ＝ 1 person-hour
```
★★**這不是美觀**：它是**病6 命名說謊**的同族，★★★**而今天已經證過那一族會在換根時把人騙去改錯東西。**

### ★驗收（硬）
```
★fp 逐位元不變 —— ★★純改名不得動到任何值
★★tile 欄位 construction_ticks_left 若也改名,注意存檔/序列化相容;★★★不確定就【不改它】並在信裡說
   （欄位名說謊比改壞存檔便宜 —— 這條我先裁了）
```

# ★★②§4 雙軌對帳（★它是 §2 的前置，不是附錄）
```
★窮盡列出【所有】讀工期的地方，逐處標【新表／舊制／不適用】並對帳總數
起點（★不是全部，你要窮盡）：
  decision_context.gd:389/392   goal_resolver.gd:913
  faction_ai_system.gd:4129/4133  ★:5086 SURVIVAL_BUILD_MAX_TICKS  ★:5133 預設 72
  outpost_system.gd:486/509/586/615/617/625/717/770
  player_command_system.gd:9/239/242
```
## ★★★特別查那兩顆「拿工期當門檻」的
```
:5086  int(cost.get("ticks", 9999)) <= SURVIVAL_BUILD_MAX_TICKS
:5133  int(cost.get("ticks", 72))
⇒ ★工期一改,它們的【語意】就變（「求生期蓋得起什麼」的界線移動）
⇒ ★★而它們【不會報錯】—— 沒有任何測試會紅
⇒ ★★★所以要你標出來:它們是【該跟著錨走】,還是【本來就該是絕對值】？
   你只標,不改 —— 判定是我的
```

# ★★★③為什麼 §4 是前置
★**§2 的驗收是「改錨 ⇒ 全表八項等比例跟」。**
★★**而 §4 會先告訴我們：有哪些地方【拿了工期卻不在那八項裡】** ——
★★★**那些地方不會跟，而它們不會報錯。** ⇒ **先知道有幾個，再決定 §2 怎麼寫。**

# ★④不做
```
★不改任何數值（表值等實測，我另派）／★★不改倍數（WHAT，用戶核可）
★★★不順手修病3 MOVE_TILES_PER_DAY（同族但另票）
★換根微分那條線照你原順序,不受影響
```
