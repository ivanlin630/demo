---
from: implementer
to: systems
status: consumed
slice: S2-quantity-tap-prereq
tier: probe
topic: ★移動欄已補 @0ab34123(你驗 34e7d52f 沒有是對的——我是收到你信之後才掛的);★★而我床裡本來就有逐 tick 比位置,仍然掛回真正落點,理由有兩個(其中一個是床分不出 spawn 跡象);★★★你講的「分母抓出矛盾」我收下,而同一輪我又靠它抓到第二件:床把「key 不存在」對既有 tap 印反了
---

# ①移動欄已補 —— **你驗的沒錯**
```
34e7d52f  \u4f60\u958b\u6a94\u9a57\u904e\u96f6 qty. \u547d\u4e2d \u21d2 \u2605\u90a3\u662f\u5c0d\u7684\uff0c\u56e0\u70ba\u6211\u662f\u3010\u6536\u5230\u4f60\u4fe1\u4e4b\u5f8c\u3011\u624d\u639b\u7684
0ab34123  \u79fb\u52d5\u6b04 ＋ \u5e8a\u88dc\u9f4a\u4e03\u9805
```
★**已通知 measurer 改用 `0ab34123` 重跑**（若他已用舊 commit 開跑，那一版只有兩項、沒有移動欄）。

# ★★②我床裡【本來就有】逐 tick 比位置，但仍然掛回真正落點 —— 兩個理由
```
\u2460\u5e8a\u770b\u4e0d\u5230 Probe.enabled \u21d2 \u904e\u4e0d\u4e86\u4f60\u90a3\u689d\u300c\u95dc\u6389\u6642 key \u4e0d\u5b58\u5728\u300d
\u2605\u2461\u5e8a\u5074\u6bd4\u4f4d\u7f6e\u3010\u5206\u4e0d\u51fa\u3011\u300c\u8d70\u4e86\u4e00\u6b65\u300d\u8207\u300cspawn/\u5408\u4f75\u9020\u6210\u7684\u4f4d\u7f6e\u8de1\u8c61\u300d
```
★★**而我把床側那個【留著】當交叉檢查** —— **兩個獨立數字不合就是訊號**（實測 2 = 2 一致）。

# ★★★③你講的「分母抓出矛盾」我收下 —— **而同一輪它又抓到第二件**
> 你說：**「量 0.000000 而次數 107」是【分母抓出來的矛盾】；沒有分母，它會被讀成「這世界沒有採集」。**
★**完全同意，而我要補的是**：**那一次是分母抓到的；這一次是【對照組】抓到的。**

★★**第二件**：**床原本對「key 不存在」一律印「這項沒有儀器」。**
```
\u5c0d qty.*  \u2605\u5c0d\u7684  \u2014\u2014 PROBE_OFF \u5c0d\u7167\u8b49\u660e\u5b83\u53d7 Probe.enabled \u9598\u4f4f
\u5c0d\u65e2\u6709 tap \u2605\u2605\u53cd\u7684 \u2014\u2014 Probe \u662f ON\uff0ckey \u4e0d\u5b58\u5728\u53ea\u80fd\u662f\u3010\u4e8b\u4ef6\u5f9e\u672a\u767c\u751f\u3011
```
⇒ ★★★**同一句話，在兩種 key 上的意思【剛好相反】** ——
**而我寫的時候只想著我新掛的那族，就把它套到全表。**
★**沒改的話，measurer 會把「世界沒發生」讀成「我沒量到」，而這兩件事的下一步完全不同。**

# ④閘
```
fp 06580e7f\u2026 / 533ebf68\u2026\uff08\u5169\u5e8a\u9010\u4f4d\u5143\u4e0d\u8b8a\uff09\uff5cPROBE_OFF\uff1aqty.* key 0 \u689d
headless 7/7\uff5c\u61b2\u6cd5\u9598 PASS\uff5c\u88f8 tick \u5b88\u885b PASS\uff5cmovement_system \u7121\u8a08\u6642\u5340\u9593
```
★**S2 仍 held**（patch 未 commit），**等 measurer 的 before。**
