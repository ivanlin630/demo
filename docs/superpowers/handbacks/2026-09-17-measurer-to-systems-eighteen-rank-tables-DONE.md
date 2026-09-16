---
from: measurer
to: systems
status: consumed
slice: 絕境暴力——18筆rank表交件
topic: ★三個事前假說：①贏家分佈【不成立】(乞食/紮營從未出現過贏家)②掠奪util非0【成立】③掠奪64%不在候選集【成立】｜★★★事前沒登記的第四發現：seed777 team126連兩天掠奪贏argmax(rank1)卻沒被設上(實際task=投靠)——同一族「贏了卻沒被設上」手不聽腦｜★★★同時如實報一個未解的population discrepancy(兩輪同seed母體數不同，已排除兩個常見假說，根因未定)
---

# ① 三個事前假說逐一對照

```
①「贏家多半是乞食／紮營／覓食」 —— ★不成立
   28筆贏家：徵收6／maintain_food或tools 6／偵查4／買糧2／歸建2／survival2／
             掠奪2(未被設上)／覓食1／外交1／併入1
   乞食、紮營一次都沒出現過。

②「掠奪util不是0，只是排後面」 —— ★確認成立
   掠奪在候選集裡10筆，u值域0.0046~3.6623，從未見過0.0000
   （對照：攻擊倒是有幾筆u=0.0000）

③「掠奪大量不在候選集」 —— ★確認成立
   28筆裡掠奪不在候選集18筆(64.3%)——過半的『0動手』是沒上場，不是輸了。
```

# ② ★★★事前沒登記的第四格：贏了卻沒被設上

```
seed777 team126：
  day9  掠奪u=1.5776 排第1名，實際task_snapshot=投靠
  day10 掠奪u=3.6623 排第1名，實際task_snapshot=投靠
```
同一支隊連續兩天掠奪在rank上贏了argmax，而它的實際task不是掠奪——這是同一族
「贏了卻沒被設上」（此session前面(4a)(4b)那題查過的手不聽腦形狀）。
★投靠(TASK_JOIN)是survival-class，commit priority可能@80壓過掠奪(@50)——
本卷不往下查是誰擋的、擋得對不對，只標出這格跟(4a)(4b)是同一族問題，建議一起看。

# ③ ★★★如實報一個沒解開的東西：population discrepancy

第一輪(無rank表)seed1337母體=9，第二輪(加了gather+rank_scored_ctx呼叫)同seed母體變成6。
排查過兩個最常見假說：
```
①production code變動？—— 三輪commit逐對git diff --stat scripts/simulation/ = 0，排除
②我加的呼叫耗RNG？—— decision_context.gd/decision_engine.gd/terms.gd/options.gd
  逐檔grep randf/randi = 0命中，呼叫鏈本身不耗RNG，排除
```
兩個都排除，根因未定。候選第三假說(未驗證)：多呼叫gather+rank_scored_ctx(每天~500+次)
增加的CPU work若碰到任何thread-timing依賴的引擎子系統，可能移動軌跡而不需要耗RNG——
我沒有驗證這個，如實報上來，你判斷值不值得再開一輪查。

# 收下的

★不下WHAT/HOW結論、不調參數。母體=18/28兩輪動手都是0，方向一致。
