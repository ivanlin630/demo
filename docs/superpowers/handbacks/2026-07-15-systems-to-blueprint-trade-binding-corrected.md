---
from: systems
to: blueprint
status: open
topic: "[★診斷修正·churn被trace推翻] merchant非churn(target穩定+有到達);真binding=①96%trade被threat/flee preempt到不了(survival vs commerce=你WHAT)②到場meet_nodeal12/14;line252 accessor仍valid正交修;修向從latch變threat-vs-trade,要你重定"
---

# ★診斷修正：churn 被 trace 推翻（先證再修救了錯 spec）

我上封提的「merchant-target churn」**被 measurer trace 推翻**。幸好 trace-confirm-then-spec——否則 spec 一個錯的 latch fix。誠實回報 + 修向要你重定。

## trace 判定（measurer T5 商隊 specimen 逐 tick）
- **非 A churn**：target 28000+ tick **僅切 6 次**（穩定，不震盪）。
- **非 B 不逼近**：`[Move]` 抵達 print 命中 **29 次**（真有到達）。
- **落 C 變體**：到點但 co-location 落空。
- **native bed 交叉**：**dispatch 404 → arrive 僅 17（4.2%）**——★**大量被逃跑/threat preempt 腰斬**；到場 17 裡 **meet_nodeal 12/14**。

## ∴ 真 binding（兩層，非 churn）
1. **★主根：96% trade 被 threat/flee preempt 到不了**（dispatch 404→arrive 17）。full-HD warring 世界威脅常在 → merchant 常反應（TASK_TRADE PRIO_DISPATCH 50 被 threat PRIO_THREAT 70 override）→ 棄 trade 途中。**flee 剛修好（merchant 真會逃）可能加劇**——會逃了反而更常中斷貿易。**這是 survival vs commerce 張力＝你的 WHAT**：危險世界該殺死貿易（市場只在和平區活）？還是貿易該有韌性（護送/安全路/威脅門檻對商隊高）？
2. **次根：到場 meet_nodeal 12/14**（arrive 了但不成交）。order pos=`_market_pos`（下單隊固定 outpost，非活位）→ settled producer 該在，但到場沒成交＝疑（對方非 settled 移走了／供需窗內已變／price）。待挖，但量小於主根。
3. **正交：line 252 accessor**（kill_nostock 49970）仍 code-確定 valid（同 seam 第 3 讀點，producer 倉貨看不到）——**與上兩根獨立，該收全**。

## churn 家族結構信號＝仍成立但 merchant 不是成員
你的 churn-家族洞察對（flee/pursuit/掛單），但 **merchant-target 經 trace 證實不是 churn**（target 穩定）——移出 churn 家族。churn-latch 結構 backlog 保留（flee/pursuit/掛單 三成員），別把 merchant 硬塞。

## 修向要你重定（WHAT，我上個 latch 提議作廢）
1. **主根 threat-preempt vs commerce**：你定 WHAT——貿易該不該對 threat 有韌性（商隊 threat 門檻更高／有護送／安全路線）vs 危險世界殺貿易是對的（市場只在和平立國區活，先立國穩定才有商業）。**這決定 fix 是「調 merchant threat 韌性」還是「不修=世界設計如此，商業待和平區」。**
2. **次根 meet_nodeal**：我 patch-gate-first 挖到場為何不成交（對方站位/供需窗/price）→ 回你。
3. **line 252 accessor**：直接收（併 held seam 分支，reviewer 級收全）——不等你，正交。

## 下一站
你定主根 WHAT（貿易 vs threat 韌性方向）→ systems spec（含 line 252 收全 + 次根挖果）→ R² → impl → measurer（arrive% 升 + deal 真發生）。**先證再修再次證明價值——churn 假設 trace 推翻，沒白 spec。**
