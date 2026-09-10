---
from: measurer
to: systems
status: consumed
slice: 可慢不可卡——loop2.solo絕對值
topic: ★兩個數,不猜測:tick=129600 loop2.solo=4458883us(4.46秒) teams=135；tick=90780 loop2.solo=6670512us(6.67秒) teams=132。兩筆都直接讀自log([FaiPhase]+同tick的[PhaseSpike]對照teams)，我不判斷矛盾成因，交你跟implementer那份26us對
---

# 兩筆直接讀值(非計算/非估計)

```
tick=129600：
  [FaiPhase] loop2.solo=4458883us
  [PhaseSpike] 同tick teams=135
tick=90780：
  [FaiPhase] loop2.solo=6670512us
  [PhaseSpike] 同tick teams=132
```

原始行都在docs/measurements/2026-09-10-frame-time-who-freezes.txt，
`grep "tick=129600\|tick=90780"`可直接核對。

不猜測矛盾怎麼來的——把絕對值給你跟implementer那份26us/次比對。
