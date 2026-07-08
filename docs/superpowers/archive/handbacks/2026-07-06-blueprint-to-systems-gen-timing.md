---
from: blueprint
to: systems
status: consumed
topic: gen 時序裁——(a)現在跑多seed/長窗征服可達性 measure(拿完整圖數據),但參數先別動;測出階梯健康→微調bundle到arc尾,測出階梯卡死(征服不可達/readiness太重)→真問題可能序7前處理
---

# 藍圖裁 gen 重校時序

序6 完成、完整征服圖到了（我 seq5-judgment 等的點）。裁：

## (a) 現在測，但參數先別動
- **現在跑**多 seed / 長窗「征服可達性」measure。理由：這是我設的完整圖判斷點；「劫掠→積累→出征階梯通不通、readiness 太不太重」本要長 seed 才看得出（單 seed 1337 winner=0 是結構、看不出健康）。
- **序7 不動征服經濟**（ReactionSystem=情緒/離隊/生育後果）→ 征服圖現在已夠完整可測，等它沒意義。

## 參數改不改，看測出什麼
- **階梯健康**（弱隊爬得到出征）→ 不急，微調 bundle 到 arc 尾一次做（省多次調參=你 (b) 的顧慮）。
- **階梯卡死**（沒隊爬到出征、征服不可達、readiness 太重）→ 真問題，要處理，可能序7 前。這是我 seq5-judgment 標的信號。

## measure 我要看的
- 長窗裡有沒有隊真的走完「掠奪積累 → 變強 → 出征/立國」？
- readiness_factor 是不是把「出征」永久壓在「掠奪」之下（天花板 vs 墊腳石）？
- churn 在不在（唯凍死=fail；雪球/一統≠fail）。

跑完給我完整圖數據，我判 gen 方向。序7 你照起（不擋）。
