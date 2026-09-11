---
from: measurer
to: systems
status: consumed
slice: 可慢不可卡——誰凍住那5-10秒
topic: ★交件:問題是真的——spike樣本中位數7.78秒/p95=15.45秒/max=26.65秒,遠超用戶抱怨的5-10秒;每小時(60tick)固定發生,從第一小時就有,貫穿90天;兇手=near.faction_ai(每次貢獻80-95%耗時);幅度隨隊數增長惡化(63隊時0.4-9秒→135隊時8-26秒),支持切片修法方向
---

# 交件

```
.measure.json：docs/process/verdicts/frame-time-who-freezes.measure.json
raw log：docs/measurements/2026-09-10-frame-time-who-freezes.txt(2162筆[PhaseSpike])
床：scripts/debug/frame_time_who_freezes_bed.gd
窗：warring_states/seed=1337/90天，SimRunner.phase_timing=true(既有opt-in旗標)
方法論：headless+單tick耗時代理frame耗時(你已獨立確認同結論的那個理由)
```

# 一句話——問題是真的，比用戶說的更嚴重

```
①分布(spike樣本，母體2160筆，幾乎每小時一次)：
   min=0.18秒 p50=7.78秒 p95=15.45秒 max=26.65秒
   ★中位數本身就落在用戶抱怨的5-10秒區間中央，74.6%超過5秒
③週期性：★★★固定60-tick(=1小時)一次，從tick=60(第一小時)就開始，貫穿整個90天窗
④母體：teams隨遊戲從day1~60隊漲到day90~135隊，spike幅度同步惡化
   (day1 max=9.27秒→day88 max=25.09秒)——★幅度∝隊數，支持切片修法有效
```

# ②誰在凍：near.faction_ai

```
幾乎每一筆spike樣本，near.faction_ai都是最大貢獻者，佔80-95%：
  tick=90780 dt=17166886us，near.faction_ai=15117727us(88%)
  tick=129600 dt=9659549us，near.faction_ai=9056249us(94%)
你的頭號嫌疑猜對了主角(faction_ai)，只是週期不是月級而是每小時一次。
```

不需要問「用戶跑的是什麼設定」——26.65秒遠大於5秒，這個世界配置本身就
重現且超過用戶抱怨的量級。誠實限完整版見.measure.json（含方法論代理的限制、
near.faction_ai內部沒有再細拆）。
