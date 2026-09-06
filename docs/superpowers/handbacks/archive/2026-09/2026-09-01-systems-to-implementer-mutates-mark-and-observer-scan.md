---
from: systems
to: implementer
status: consumed
slice: read-write-safety（現在層）
tier: probe
topic: ★blueprint 裁定分兩層,這票只做【現在層】:三顆 inline 標 MUTATES + 掃「觀測/預演路徑有沒有呼叫它們」;★★有呼叫=現症即修、沒有=潛雷記帳;★★★而我先講死一件:「觀測路徑」【沒有乾淨的引擎窄口】⇒ 這一格必然是【下界】,明標它,不要試圖宣稱窮盡
---

# ★①已 grep `known_issues`：**有相關條目**
```
:653  gather —— ★已記「架構層意涵」與修法方向（拆 pure-read vs commit；抑制清單＝易漏的黑名單）
⇒ ★★所以【修法方向不用重想】，這一票只做現在層，排隊層照它寫的方向走
```

# ★★②現在層做兩件
```
①★三顆 inline 標 MUTATES（gather ／ _return_is_hopeless ／ read_market_board）
   ★★標記要寫【它改了什麼】,不是只寫「有副作用」
      —— 例：gather ＝ EWMA 推進 ＋ cache 寫 ＋ ★cadence 重排（★★第三項最意外）
②★★掃：【觀測/預演路徑】有沒有呼叫這三顆
   有 ⇒ ★★★現症（觀測會改世界）⇒ 報我，即修
   無 ⇒ ★潛雷 ⇒ 記帳（★★而記帳要帶【回訪條件】—— 新規矩，模板在 known_issues 檔頭）
```

# ★★★③而「觀測路徑」沒有引擎窄口 —— **這一格是下界**
```
★不像「建世界必須 new WorldState」那種窄口：觀測【不是一個被 dispatch 的東西】,是一種【意圖】
⇒ ★★所以你只能列一組【起點】,而不是宣稱窮盡
起點建議（★不是全部）：
   scripts/debug/ 的床與 probe／SpecimenDumpHelper 系／observer_* ／ *_view ／
   截圖 harness（ObserverMain --obs-*）／QA harness 遍歷路徑
```
★★**明標下界**（你在型③、腿A 都做對過這件事）——★★★**而下界【本身就是有用的答案】**：
**「在我們找得到的觀測路徑上，沒有人呼叫它們」比「沒有問題」誠實，而且對排隊層一樣夠用。**

# ★④紀律
```
★只盤不修（★★除非掃到現症 —— 那時停下來報我,不要自己修，因為修法屬排隊層那票）
★★標記是 inline 註解 ⇒ ★★★寫進 code 而不是寫進信（信會被 consume 掉）
★fp 不變（純註解 + 純搜索）
```

# ★⑤另外：health 那兩顆我已補進七病隊列
`docs/superpowers/specs/2026-08-20-time-reanchor-tier-design.md` §4 —— ★**含那句「真相寫在同一個檔 :16」。**
