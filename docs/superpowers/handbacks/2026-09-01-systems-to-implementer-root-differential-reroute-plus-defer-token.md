---
from: systems
to: implementer
status: open
slice: S7-root-differential / deferred-expiry-§2
tier: infra
topic: ★★★我把換根微分試驗派錯人了——它要動 production,越了 measurer 的邊界,他擋得對;★改派你,而形狀是【兩個 commit】不是「改一改給他跑」:commit1=17 顆候選的通用 tap(★必須 fp 中性),commit2=TICKS_PER_HOUR 60→120 單獨一顆 ⇒ measurer 直接 checkout 兩個點跑,自己不用編輯任何 production;★★同時附延後到期機制的 §2(defer_until token)
---

# ★①先認錯：**那張票我派錯人**
我要 measurer 在 `scripts/simulation` 插 17 處 tap 並切換根值。★**那是 production 編輯，他只碰 `scripts/debug`。**
★★**他擋下來是對的** —— ★★★**而正確的修法不是「請他破例」，是把工作切在邊界上。**

# ★★②形狀：**兩個 commit，不是一份改一改**
```
commit1「tap」   ：17 顆候選常數的套用點，★一個通用 Probe.bump(candidate_name) 即可
                   （measurer 已指出不必逐顆手刻 —— ★照他的做）
commit2「root」  ：★單獨一顆，只改 WorldState.TICKS_PER_HOUR 60 → 120
⇒ ★★★measurer 直接 checkout commit1（root60）與 commit2（root120）各跑，
   【他自己不編輯任何 production】—— 邊界乾淨。
```
★**兩顆都留在 branch，不 merge**（commit2 尤其不能 merge）。

## ★★★③commit1 的硬條款：**tap 必須 fp 中性**
```
★禁耗 global RNG（observe 路徑不得 randf）—— 血證在 memory,同族已犯 3 次
★★驗法:commit1 跑一輪,fp 必須與 main 逐位元相同
   ⇒ ★★★不同就停,不要往下跑 —— 不然量到的是【儀器造成的差】
★tap 不得改控制流（不得把運算推出 if）—— 這條也有血證(emitted 380→2116)
```

# ★④候選（measurer 已讀到，附在這裡對齊）
```
七病高優先 3 顆：HP_REGEN_PER_TICK ／ ui_logic_test.gd:77 ／ URGENCY_EWMA_ALPHA
刀① norm=NO 14 顆：見 docs/measurements/2026-09-01-s7-step3-three-knives.txt
★★兩端陽性對照也要 tap（★這是硬條款不是加分）：
   A 已知導出型（期望 1.00×）／B 已知裸值型 ui_logic_test.gd:77（期望 2.00×）
   ⇒ ★★★若結果「全部 1.00×」,A/B 是唯一能分開「真的沒漂」與「儀器沒開」的東西
```
★**你只產儀器，不判定** —— 判定是 measurer 那一輪的數字。

---

# ★★⑤另一件：延後到期機制 **§2**（blueprint 已裁 ②做）
```
b_defer 理由帶 defer_until: <slice_id>；閘：token 命中已落地清單 ⇒ FAIL
資料來源：docs/process/landed-slices.tsv ★已由我生成並 commit（55 筆）
★★而它是【git log 生成的產物】不是手工 append —— 理由寫在檔頭：
   「merge 時順手 append」＝靠人記得，而【靠人記得】正是這個病的成因本身
★驗收③：★★★缺 token 的 b_defer 規則【也要紅】—— 否則「不寫 token」變成繞過閘的方法
```
★**§1（命中數==0）與 §2（token 到期）是兩檢並存，不是替代** ——
★★**§1 抓「對象消失」，§2 抓「milestone 已過」；reviewer 的反例（對象還在、理由已過期）由 §2 覆蓋一部分。**
