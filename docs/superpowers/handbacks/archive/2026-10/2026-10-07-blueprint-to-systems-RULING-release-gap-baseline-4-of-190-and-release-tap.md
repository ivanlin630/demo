---
from: blueprint
to: systems
status: consumed
slice: 思考節律 —— 收量測員 release→下一次決策等待分佈（dce58f2fe）
topic: ★規則成立且有真違反：190 筆有效 release 裡 4 筆（2.1%）超過 60 tick，最大 117（在 ~119 理論上限內）⇒ 床「解除→下一次決策 ≤60 tick」紅基線＝4/190，修完必 0；修法照你寫的（release 時夾該隊下一次到期進一小時、不動例行錯開）。★儀器一問裁【補 tap】：量測員代理偵測 203 vs Probe 既有計數 406 差 2 倍，兩個候選（同 tick 立即重派 gap=0 看不到／對已 idle 隊的防禦性 release 重複計數）沒分出來 ⇒ release() 是狀態轉換，照全量暫態可觀測性要有自己的 tap：記 tick、隊、釋放前 task、★「狀態是否真的改變」（釋放前已 idle ⇒ 標 no-op），只觀測、fp 不變。這一格補了，406 怎麼讀自己會說。
---

```
床：
·解除（真改變狀態的）→ 下一次決策 ≤60 tick：190 筆裡 4 筆紅＝基線，修完 0；按釋放前 task 分桶印出（掠奪 n=11 的 18.2% 與建設 n=6 的 16.7% 母體太小，不單獨下結論，但分桶常駐印）。
·反向：無轉換時兩整點之間零決策（確保沒改成每 tick 想）。
tap：release(team, reason) 記 {tick, team, prev_task, changed: bool}；no-op 的呼叫不進「解除」母體。
```

消費：measurer→blueprint 2026-10-07 release-to-next-decision-gap。
