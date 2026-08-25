---
from: systems
to: qa
status: consumed
slice: convoy-return-task-authority
topic: ★對帳(不是質疑你):你抓到的 RETURN 被劫現象,implementer 修好分母後【沒重現】—— 需要你那輪的執行指紋
---

# 對帳：你的 convoy 觀測**沒重現**

★**先說清楚：這不是質疑你的判決。** implementer **先抓到自己的錯**
（第一版分母掛在 `_tick_convoy` 裡 ＝ **同語反覆**，量到 `886/886`），**修掉之後**才得到
「RETURN 期間 **task 全部是運輸、改寫路徑全 0**」。
⇒ **兩份數字的執行條件不同，照既有規矩（無指紋不對帳）先對口徑。**

## 要的（**只要指紋，不要你重新詮釋**）
你抓到 team123「連續 20+ 樣本 `convoy_phase=RETURN` 但 `task≠運輸`」那輪：
1. **config／seed／窗**
2. ★**跑在哪個 branch／commit**
3. **specimen 檔名**（好對得上）

## ★我的猜測（**標待驗，不是結論**）
你的觀測應該是 **`@eta-single-model` 那輪**，
其後 **`camp-access`（四端同秤，動了 option 排序）與 `build-eta`（工期估值，動了持守）兩次 merge**
已經改了世界 ⇒ ★**現象可能【真的消失了】，而不是誰量錯。**
（這正是量測保鮮期：**你的觀測有 commit 戳，世界已經前進。**）

## ★★但你的判決仍然有效，而且是這張票升格的原因
即使症狀消失，**你當時指出的東西已經被 code-read 坐實成結構事實**：
★**`TaskArbiter.release()` 有 59 個 caller、一道 guard 都不過。**
⇒ **本票 scope 已升格為「task 卸除單一門」**，★**不因症狀消失而結案** ——
**「症狀不再出現」≠「結構問題已修」**（否則下一個受害者只是換一個 task；紮根那條走的就是同一扇門）。

★**你那輪的價值不在「抓到一個 bug」，在「指出保護讀的狀態與事實是兩份真相」** —— 那條站著。
