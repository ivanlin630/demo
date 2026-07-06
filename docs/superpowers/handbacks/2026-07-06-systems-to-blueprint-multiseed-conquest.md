---
from: systems
to: blueprint
status: consumed
topic: 多seed征服measure完整圖(8seed×6月post-序6)——★prosperity_reached=0全seed(劫掠→出征階梯卡死=readiness太重,你seq5標的param recalibrate信號);2/8凍死(龜縮);6/8死亡潮重(attr56-68%腰斬);capture走faction-attack在4seed活;征服未全死只prosperity鏈死;要你裁gen方向
---

# 多 seed 征服可達性 measure — 完整圖交回

8 seed × 6 月（post-序6 完整征服圖，你等的）。數據 dump `scratchpad/multiseed_conquest.json`。

## 三發現（對你 seq5-judgment 的信號）

### ① ★階梯卡死：prosperity_reached = 0 全 8 seed
你 seq5-judgment 定：「長 seed 弱隊走通劫掠→積累→真出征？通=健康暫時0噪音；**卡死(掠奪=天花板沒隊爬到出征)=readiness 太重→param recalibrate**」。
- **測出=卡死**：`conq.prosperity_reached=0` **全 8 seed × 6 月**。loot 活（surv.loot_dispatch 5-26）但**沒一隊爬到 prosperity 出征**。
- = 你標的「readiness 太重」信號坐實。**gen/param territory**（readiness threshold），非改引擎。

### ② 但征服未全死：capture 走別路在半數 seed 活
- `capture.total` seed88=5/100=11/314=8/1337=1；`capture.by_attack`=1（88/100/314）。established=1-3（100=3/314=2/555=2）。
- → 征服**經 faction-attack/loot-combat 發生**（非 prosperity 鏈）。所以「征服可達」部分成立，只**prosperity 個體出征鏈死**。CONQUER intent 多 seed 有（隊想征服，但走不到 prosperity 出征，改別路 or 死）。

### ③ 2/8 凍死 + 6/8 死亡潮重
- **★凍死 2 seed**（7/2024）：teams/pop/intent 6 月全靜（55/58 flat）、零死零征服零 loot=**龜縮 fail mode**。
- **死亡潮 6 seed**：attr 56-68%、teams 57→22-31、pop 400→115-178 腰斬。churn 有但**多經死亡非征服**（DEFEND/RICH intent 主 + loot + 少 capture）。est 低(0-3)。

## 系統判讀（你裁 gen 方向）
- **階梯卡死=真問題**（你 gen-timing 標「卡死→序7 前可能處理」）：readiness gate 讓征服隊全改 loot、沒隊出征 → 建議 **readiness threshold recalibrate**（降門檻讓 ready 隊爬到出征）。**param 非引擎**（合孿生條）。
- **2 凍死 + 6 死亡潮**：兩極（靜死 or 腰斬），中間「有動有起落不腰斬」的健康帶少 → 疑 **承載力/food gen 參數**（死亡潮=餓死？凍死=無張力）也要動。=完整圖的 gen 重校對象。
- **征服非全死**（capture 走 faction-attack）→ 世界非全靜，但 prosperity 個體出征這條戲缺。

## 要你裁
1. **readiness recalibrate 時序**：(a) 序7 前處理（你 gen-timing 標卡死可能序7前）(b) arc 溶完 bundle？我傾向數據夠明（8 seed 全 0）可先調 readiness，但你 seq5「別拿殘缺圖調」現已完整圖=可調。
2. **gen 重校範圍**：只 readiness，還是連承載力/food（2 凍死 6 死亡潮=兩極）？這是你平衡意圖 + 完整圖判。
3. 我這邊：你給方向（降 readiness 多少/food 調否）我可 spec 一個 gen-recalibrate slice（param only，config/常數，合孿生條），或你要先自己看數據。

**不擋序7/序8/audit 脊椎**。gen 是平行 param 軌。
