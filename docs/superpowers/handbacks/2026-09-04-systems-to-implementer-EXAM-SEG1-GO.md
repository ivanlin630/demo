---
from: systems
to: implementer
status: open
slice: ★長考 C 方案【第一段】開跑
tier: slice
topic: ★用戶扳機落地(「等 cap 再 C」):cap 已 merge、17 支閘綠 295s、已 push;★★考程樹【凍結生效】(docs/process/.exam-freeze 已建)⇒ 從現在起改世界的 merge 會被第 16 支閘擋下 —— 那是預期行為不是故障;★★★第一段＝peaceful_economy_regime × seed 1337/42/7 × 90 日(≈22 分),而每張卷【表頭四格對帳缺一不可】,缺任一【重跑】不要「看起來對就收」;★第一段期間 warring【不跑】(用戶序)
---

# ①現在的 main（★三張卷都要跑在這一顆上）
```
commit = 7c37ef1e
★cap 已 merge（u = CAP × x/(1+x)、x = payoff/UNIT）｜★★17 支閘全綠 295s
★★★凍結生效:docs/process/.exam-freeze ⇒ 改世界的 merge 會被擋 —— 【那是它的用途】
```

# ②第一段（★用戶序：warring 這一段不跑）
```
world = peaceful_economy_regime ｜ seed = 1337 / 42 / 7 ｜ window = 90 日 ｜ ≈22 分（單位成本 7.2 分/張）
★三張都跑【同一顆 code】= 7c37ef1e —— ★★同版本比同一天重要
★★★計數類可並跑;而【wall-clock 那一格要獨佔】⇒ 若並跑,那格標 EXCLUSIVE=unknown 不要標 yes
```

# ③★★每張卷的表頭（★缺一不可，缺任一【重跑】）
```
world=  seed=  window_days=90  commit=7c37ef1e
①心跳段數 =    ／應有 = 9（90 ÷ 10）
②每張表列數 =  ／該表自報母體 =
★③section 數 =  ／應有 =      （★2026-09-04 血證:整張表消失而四張各自對得平）
★★④跨表:stage N 出口 == stage N+1 入口 ⇒ 不平【宣告該輪不可用】
EXCLUSIVE=      （★預設 unknown 不是 yes）
```
★**模板在 `docs/process/exam-paper-template.md`** —— **照它填，不要另創格式。**

# ④★★★產出物（§3 交付清單；★「答不了」是合法結果）
```
①判定:逐科 PASS/FAIL/★答不了
②報不修讀數:施主可及率／承諾紮根數／★空殼隊比例
③免費補答三項:founding 沉默【是否存在】(★先答存在,不答為什麼)／recamp 觸發／人口成長率
④§7-D 三行:★分層讀數(config 隊 vs runtime 新生隊【兩層分開】)／空殼隊/出生潮(★留讀數不解讀)
⑤★cap 的回訪格:build 的 pop 分層【大(≥9)】—— 上一輪 n=0,這輪若有大隊就免費補上
```

# ⑤★兩句必附的產地免責（★不是客套）
```
①「這 13 個 goal 的【歷史】argmax 讀數是插入序 artifact」⇒ 卷面標【不可解讀】
②「本卷 argmax 產自 payoff 導出＋cap 壓縮【之後】」⇒ 與更早的讀數【不同源】,對照必標 commit
```
★**報告一律【寫檔】（`store_string`）、螢幕只印摘要** —— **今天的 16383 血證。**
