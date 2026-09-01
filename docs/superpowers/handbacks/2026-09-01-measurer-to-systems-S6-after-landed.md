---
from: measurer
to: systems
status: consumed
slice: S6-after
tier: measure
topic: ★★★★★S6 after腿落地(after=53ee4c68 vs before=1af956fa，四輪機械檢查全過)——peaceful母體穩定(12→12)七項多在±10%內，訊息送達/建設數列n太小不當真訊號；warring per-team-day：決策-15.8%/送達+21.7%/建設嘗試+11.2%(n可信)/建設停滯-19.2%(n可信)/建設開工與完工n太小(9→11/8→12)僅供參考；補了一段建設嘗試/開工/停滯/完工/取消(讀既有production tap，零新tap，before/after同版本床才能對齊)；照實報形狀不下決策端對不對的判斷
---

# ★①機械檢查：四輪全過

after(53ee4c68)/before補建設版(1af956fa)各兩床，[BedSelfCheck]effective_window皆100%，無提早結束。

# ★★②peaceful_economy：母體穩定(12→12)，多在±10%內

```
決策+8.6%／訊息發出-4.6%／建設嘗試-21.7%(n=18→14)／建設停滯-21.9%(n=588→459，較可信)
```
訊息送達/建設開工完工那幾項n太小(<30)，不當真訊號。

# ★★★③warring_states：per-team-day為主軸(隊數94→114)

```
決策次數     -15.8%
訊息送達     +21.7%
建設嘗試     +11.2%（raw 611→824，n可信）
建設停滯     -19.2%（raw 3632→3560，n可信）
建設開工      +0.8%（raw 9→11，n極小僅供參考）
建設完工     +23.7%（raw 8→12，n極小僅供參考）
建設逾時取消  before未發生(n=0)→after n=1（噪音層級）
```

# ★★★★④照你要求：只報形狀，不下決策端對不對的判斷

建設嘗試沒有隨工期變慢而減少(反而+11.2%)，停滯量下降(-19.2%)——這個形狀跟直覺預期(工期變慢⇒更多工地卡在進行中)方向相反，但我沒有判斷這代表決策端跟上了還是沒跟上，那是behavior因果，照你的話是blueprint的事。

完整數字：`docs/process/verdicts/S6-after.measure.json`
原始log：`docs/measurements/s6after-qty-{peaceful_economy,warring_states}-30d.txt`、`docs/measurements/s6before-construction-qty-{peaceful_economy,warring_states}-30d.txt`
