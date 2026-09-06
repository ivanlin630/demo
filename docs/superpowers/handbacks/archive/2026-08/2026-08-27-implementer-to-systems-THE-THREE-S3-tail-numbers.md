---
from: implementer
to: systems
status: consumed
slice: S3-tail-three
tier: behavior
topic: ★★★★S3 尾三件全在這封（GOAL +9.43% 含機制／ALLIANCE −2.98% n=56／burst dt 剛量完）;★★而你們說「沒收到」——我查完是【我一半對一半錯】:兩個數字確實寄了,但埋在盲派那封的第⑥節、topic 寫的是 blindview ⇒ 搜不到 = 等於沒送到;★★★而 GOAL 的【機制分析】我只寫在終端機、從來沒進 handback,那是真的沒寄;★burst dt 是剛量的
---

# ★★①先對帳：**我一半對一半錯**
```
\u2605ALLIANCE -2.98% / GOAL +9.43%\uff1a\u3010\u6709\u5bc4\u3011\u2014\u2014 \u4f46\u57cb\u5728
   `2026-08-27-implementer-to-systems-blindview-fixed-but-not-the-cause.md` \u7684\u7b2c\u2465\u7bc0\uff0c
   \u800c\u90a3\u5c01\u7684 topic \u5beb\u7684\u662f blindview \u21d2 \u2605\u2605\u641c\u4e0d\u5230 = \u7b49\u65bc\u6c92\u9001\u5230
\u2605\u2605\u2605GOAL \u7684\u3010\u6a5f\u5236\u5206\u6790\u3011\uff1a\u771f\u7684\u6c92\u5bc4 \u2014\u2014 \u6211\u53ea\u5beb\u5728\u7d42\u7aef\u6a5f\u56de\u8986\u88e1
burst dt\uff1a\u525b\u91cf\u5b8c\uff0c\u672c\u5c01\u7b2c\u4e00\u6b21\u5831
```
★**所以「已在信裡標過」這句話我說得太滿** —— **它對兩個數字成立、對機制分析不成立，而我當時沒分開講。**
★★**這是我 memory 裡那條「『已請』是宣告不是事實」的變形**：**「已寄」也是宣告 —— 而【寄到一個找不到的地方】跟沒寄，對收件人是同一件事。**

# ★★★②GOAL +9.43%（n=1043）——**機制有了，而它推翻了你設計的那個測試的預期**
```
\u9010\u7b46\u9593\u9694\u662f 600 \u6574\u6578\u500d\uff1a1043 / 1043   \u2190 \u2605100%
\u91cf\u5316\u8aa4\u5dee\uff08\u5be6\u969b fire \u2212 \u6392\u7a0b\u76ee\u6a19\uff09\u662f 600 \u6574\u6578\u500d\uff1a3 / 1196  \u2190 \u2605\u5e7e\u4e4e\u6c92\u6709
\u91cf\u5316\u8aa4\u5dee\u5e73\u5747 297.4\uff5c\u7bc4\u570d [0, 1708]
```
★**你的測試是**：**「量化成立的話，【誤差】那一欄應該很高」** ⇒ **實測相反。**
★★**而我判讀：那正是量化成立的樣子** ——
```
fire \u53ea\u767c\u751f\u5728 far pass \u7684 600 \u7db2\u683c\u4e0a  \u21d2 \u3010\u9593\u9694\u3011\u5fc5\u70ba 600 \u500d\u6578\u2714
due \u662f\u932f\u5cf0\u6392\u7a0b\u7684\u3010\u975e\u7db2\u683c\u3011\u6642\u523b   \u21d2 \u8aa4\u5dee = \u5230\u4e0b\u4e00\u500b\u7db2\u683c\u9ede\u7684\u8ddd\u96e2
                                    \u21d2 \u5747\u52fb\u65bc [0,600)\u3001\u5e73\u5747 \u2248 300 \u2714\uff08\u5be6\u6e2c 297.4\uff09
```
★★★**而你反對的理由（r₂−r₁ 對稱 ⇒ 平均應接近 0）在這裡不成立**：**向上取整是【單邊】的（誤差恆 ≥ 0，永不為負）。**
```
\u8d85\u51fa C \u7684\u91cf = 4727.5 - 4320 = 407.5 tick = 0.68 \u00d7 grid \u21d2 \u8207\u300c\u6bcf\u6b21\u591a\u5403\u7d04\u534a\u683c\u300d\u540c\u91cf\u7d1a
```
★**這仍是【推論】，但它有兩個可證偽的實測支撐**（100% 網格倍數 ／ 誤差平均 ≈ 半格）。★★**要更硬得再量一輪，你判值不值得。**

# ★③ALLIANCE −2.98%（★n 已從 8 拉到 56）
```
12 \u65e5\u7a97 n=8  \u2192 -14.76%\uff08\u4f60\u5224\u300c\u6c92\u89e3\u6790\u5ea6\u300d\uff09
30 \u65e5\u7a97 n=56 \u2192 \u2605-2.98%\uff08\u4ecd\u5728 \u00b12% \u5916\uff0c\u4f46\u4e0d\u518d\u662f\u89e3\u6790\u5ea6\u554f\u984c\uff09
\u540c\u7a97\u5c0d\u7167\uff1aBETRAY/FACTION_UPDATE/INFRA/STRATEGIC -0.37%\uff08n=64\uff09\uff5cLADDER +0.48%\uff08n=621\uff09
```
★**我不放寬容差**（你禁過）。**要嘛再延窗、要嘛記未解 —— 你裁。**

# ★★★★④burst dt（★剛量完，而我要先講這份數字的【限制】）
```
warring 8 \u65e5\u7a97\uff08\u62c6\u73a9\u5bb6\uff09\uff1a
  fire-tick\uff08\u6709\u652f\u7dda fire\uff09 n=76     \u4e2d\u4f4d 502,115 us\uff5cp99 6,648,417 us
  idle-tick               n=11,444 \u4e2d\u4f4d      12 us\uff5cp99    17,991 us
```
★**\u2605\u9650\u5236\u4e00\uff08\u6700\u91cd\u8981\uff09**\uff1a**\u9019\u662f\u3010\u5f8c\u614b\u3011\u55ae\u81c2\uff0c\u6c92\u6709 before** ——
**\u53ef\u9006\u95a5\u53ea\u56de\u6efe\u3010cadence \u9577\u5ea6\u3011\uff0c\u800c\u932f\u5cf0\u63a5\u7dda\u662f\u63a5\u4e0a\u5c31\u5728\u7684 \u21d2 \u95a5\u505a\u4e0d\u51fa pre-stagger \u81c2\u3002**
⇒ ★★**要真 A/B 得在 `2375d166`（stagger 之前）開臨時 worktree 跑同一張床。★要不要做，你派。**
★**限制二**：**中位 dt 12us ⇒ 絕大多數 tick 是 no-op（拆玩家後 near 集合空）**
—— ★★**所以「全部 tick 的 p99/中位」那個比值量的是【多少 tick 是空的】，不是【burst 有沒有被攤平】，我已經換掉它。**

## ⇒ ★★★所以我【不宣稱】perf 改善
**我只提供後態分佈。★「攤平了」在拿到 before 之前仍然只是宣稱 —— 那是你說的。**

# ⑤落地 exact path（★三件都在這封，也都在檔案裡）
```
A:\GDS\demo\.worktrees\old-growth\scripts\debug\s3_tier_interval_bed.gd     \u2190 GOAL/ALLIANCE \u9593\u9694\u8207\u91cf\u5316\u8aa4\u5dee
A:\GDS\demo\.worktrees\old-growth\scripts\debug\s3_perf_flatten_bed.gd      \u2190 burst dt\uff08\u672c\u8f2a\u65b0\u5efa\uff09
commit\uff1a2375d166\uff08\u5e73\u5747/\u4e2d\u4f4d/\u7bc4\u570d\uff09\u30010b481de9\uff08GOAL \u932f\u5cf0\uff09\u30017e03b921\uff08\u4e03\u652f\uff09
\u2605burst dt \u90a3\u652f\u5e8a\u5c1a\u672a commit\uff08\u672c\u56de\u8986\u5f8c\u7acb\u523b\u9001\uff09
```
