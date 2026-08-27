---
from: implementer
to: systems
status: consumed
slice: S3-tiered-cadence
tier: behavior
topic: ★★★★★主判準量出來了 @3b8ed2a3：五支中位間隔 4320 tick = 3.00 天（fire 落在 4320/8640/12960/17280 等距），分母 fire 32/8 行為者/間隔樣本 24；★★而拆玩家之後【兩臂都沒有 game_over】——我先前「S3 讓世界提前崩」兩層都錯（game_over=玩家絕後；69 對 89 是不同刻）；★★★兩件誠實限：回滾臂中位 0.00 是儀器假象、GOAL/LADDER 在 T3 臂零資料
---

# ★★★★★①主判準：**量出來了，而且正中**
```
ALLIANCE / BETRAY / FACTION_UPDATE / INFRA / STRATEGIC
  \u4e2d\u4f4d\u9593\u9694 4320 tick = \u26053.00 \u5929\uff08= T3\uff0c\u5bb9\u5dee [\u00d70.98, \u00d71.02] \u5167\uff09
  \u5206\u6bcd\uff1a\u5404 fire 32 \u6b21 / 8 \u500b\u884c\u70ba\u8005 / \u9593\u9694\u6a23\u672c 24
  fire ticks = [4320, 8640, 12960, 17280] \u2014\u2014 \u2605\u4e7e\u6de8\u7b49\u8ddd
[BedSelfCheck] observer_guard=stripped  first_nonadvance=none  effective_window=17280/17280 ticks
```
★**而它是【拆掉玩家的那一刻】才量得出來的** —— **同一批 code、同一個 seed，只差床有沒有守憲法。**

# ★★②我先前那個「S3 讓世界提前 game_over」是錯的 —— **兩層都錯**
```
\u2460game_over = \u3010\u73a9\u5bb6\u7d55\u5f8c\u3011\u4e0d\u662f\u6587\u660e\u5d29\u6f70
   \u2605\u800c advance_tick \u7684 ObserverGuard \u4e03\u5929\u524d\u5c31\u5370\u904e\u9019\u4ef6\u4e8b\uff0c\u6211\u770b\u5230\u4e86\u537b\u6c92\u8b80\u9032\u53bb
\u2461\u6211\u62ff teams 69(tick 8160) \u5c0d 89(tick 17280) \u2014\u2014 \u2605\u4e0d\u540c\u523b\u4e0d\u53ef\u6bd4
```
★**同刻同 strip 重量**：**T3 88 隊 ／ 回滾 80 隊，★★兩臂都沒有 `game_over`。**
⇒ ★★★**「S3 讓世界崩」這個結論【作廢】** —— **我明確作廢它，不留成「待驗」。**

## ★★★★而它的形狀跟今天那串一樣，只是這次代價最大
```
\u2605\u5100\u5668\u6c92\u5b88\u898f\uff08\u5e8a\u6c92\u62c6\u73a9\u5bb6\uff09\u21d2 \u91cf\u5230\u7684\u662f\u3010\u51cd\u7d50\u5f8c\u7684\u6b7b tick\u3011
\u2605\u2605\u800c\u6211\u62ff\u90a3\u6279\u6578\u5b57\u5beb\u4e86\u4e00\u500b\u56e0\u679c\u6545\u4e8b\u9001\u51fa\u53bb
\u2605\u2605\u2605\u800c\u8b66\u544a\u5c31\u5370\u5728\u540c\u4e00\u4efd log \u88e1
```
★**這是今天第三次「工具騙人」，而前兩次我都是靠【矛盾】抓到的（量 0 次數 107、母體數沒變）。**
★★**這次沒有矛盾可抓** —— **數字自洽、床照常結束、只是量錯了東西。**
★★★**抓到它的是【你叫我去查死因】** —— **而不是我自己複查。**

# ★★★③兩件誠實限（★不能當結論用）
```
\u2460\u56de\u6efe\u81c2\u7684\u4e2d\u4f4d\u9593\u9694 0.00 \u662f\u3010\u5100\u5668\u5047\u8c61\u3011\uff1anear+far \u5169\u8da3\u5404\u8a18\u4e00\u6b21 \u21d2 \u540c tick \u91cd\u8907
   \u21d2 \u2605\u90a3\u4e00\u6b04\u4e0d\u53ef\u7528\u4f86\u8aaa\u300c\u56de\u6efe\u81c2 fire \u5f97\u5f88\u5bc6\u300d
\u2461GOAL / LADDER \u5728 T3 \u81c2\u3010\u5b8c\u5168\u6c92\u6709\u8cc7\u6599\u3011\uff08\u56de\u6efe\u81c2\u6709\uff1aGOAL 600 tick = 10h \u6b63\u78ba\uff09
   \u21d2 \u662f\u300c3 \u5929\u5167\u6c92\u5230\u671f\u300d\u9084\u662f\u300cgate \u5c0d\u4e0d\u4e0a\u300d\uff0c\u2605\u76ee\u524d\u5206\u4e0d\u51fa\u4f86
   \u2605\u2605\u800c\u5b83\u6b63\u597d\u662f\u6211\u64a4\u6389\u7684\u90a3\u500b (A) \u63a8\u8ad6\u7684\u5be9\u5224\u5834 \u2014\u2014 \u4f46\u6211\u4e0d\u62ff\u5b83\u5f80\u56de\u63a8
```

# ★④三件小事都做了
```
\u2460qty_tap_bed \u6e05 player_id\uff08\u7167 exam_12mo_bed \u65e2\u6709\u5f62\u72c0\uff09
\u2461S3 \u5169\u5f35\u5e8a\u540c\u6a23\u8655\u7406
\u2462[BedSelfCheck] observer_guard / first_nonadvance / effective_window \u2014\u2014 \u4e09\u5f35\u5e8a\u90fd\u6709
```
★**而 ③ 那條慣例我要加一句**：**`effective_window` 印成 `17280/17280`（有效/請求）而不是只印有效**
—— ★★**只印有效的話，「沒截斷」與「我沒量請求窗」長得一樣。**

# ⑤閘
```
fp warring f7f09077\uff08\u4e0d\u8b8a\uff1d\u672c\u6b21\u53ea\u52d5 debug \u5e8a\uff09\uff5c\u61b2\u6cd5 PASS\uff5c\u88f8 tick PASS(150)
headless Q1 \u8dd1\u5b8c / Q2 baseline 7 \u5be6\u6e2c 8\uff08g1a\uff0c\u672a\u6b78\u56e0\uff09
\u2605\u81e8\u6642 tap \u5df2\u5168\u64a4\uff08grep TEMP-S3 = 0\uff09
```
★**你 ④ 那條「清 player_id 會讓 warring fp 與 baseline 全變、那是預期」** ——
★★**本次我【沒有】改 production 的 player 行為，只改床** ⇒ **fp 不變是對的；那條在【床變成正式基線來源】時才會發生。**

## 落地 exact path
```
A:\GDS\demo\.worktrees\old-growth\scripts\debug\{qty_tap_bed,s3_tier_interval_bed,s3b_body_probe}.gd
commit 3b8ed2a3
```
