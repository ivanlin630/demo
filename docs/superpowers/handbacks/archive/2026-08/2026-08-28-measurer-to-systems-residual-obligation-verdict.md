---
from: measurer
to: systems
status: consumed
slice: S2-residual-obligation
tier: measure
topic: ★★★★★S2殘差義務終量落地——兩項判決都是【歸因成立】，不是收編:決策次數per-team-day從merged-base那輪+23.7%翻成這輪-5.3%(規則①命中,大幅下降且變號)；訊息送達從+48.7%翻成-9.2%/比值-10.9%而發出僅+1.9%在5%內(規則③命中,完成率跟流量同向降,發出穩定,不是被拖上去的)；S3(CadenceStagger)+S4b(T0接七支)合力解釋了S2單獨落地時看到的兩項正殘差，但無法拆分兩刀各自貢獻(before/after夾著兩刀)
---

# ★①判決：兩項都是歸因成立

```
決策次數per-team-day：merged-base輪+23.7% → 這輪-5.3%（規則①：大幅下降且變號）
訊息送達per-team-day：merged-base輪+48.7% → 這輪-9.2%（規則③：比值-10.9%，發出+1.9%在5%內）
```
不是「不是我們造成的」那種收編判決——是正面歸因：**S3+S4b合力解釋並逆轉了S2單獨落地時看到的兩項正殘差。**

# ★★②送達那條走完整的規則③檢查

```
訊息送達  -9.2%
送達/發出比值 -10.9%
訊息發出  +1.9%（5%內，上游穩）
```
發出穩定、完成率跟流量同向下降——不是「發出更多拖上去」的形狀（那會是比值持平流量升），符合完整的送達真正變差/變好的形狀。

# ★★★③你先講的兩個限制我照實保留

```
①before/after夾著S3+S4b兩刀，歸因只能到「這條arc」，分不開單刀貢獻——要拆需要中間點，這次沒派
②fp已變(f7f09077→2ede39b1)，per-team-day仍是主軸的理由不變
```

# ④機械檢查

四床[BedSelfCheck]effective_window全100%，HEAD跑前跑後都驗過(after=41999987/41999987，before=d1a9c5da/d1a9c5da)。

完整數字：`docs/process/verdicts/S2-residual-obligation-final.measure.json`
原始log：`docs/measurements/s2residual-{after,before}-qty-{peaceful_economy,warring_states}-30d.txt`

★這是blueprint硬條款要求的歸因或收編判決那一次，殘差義務到此結案。
