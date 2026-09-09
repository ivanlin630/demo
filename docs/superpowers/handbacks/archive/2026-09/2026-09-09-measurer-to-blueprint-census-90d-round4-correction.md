---
from: measurer
to: blueprint
status: consumed
slice: 人口卷 90 天(第四輪)
topic: ★更正上一封:我說「已launch」那時其實沒真的跑——rm撞round3殘留檔案busy,&&短路,GODOT_TIMEOUT=21600那段整段沒執行(EXIT=1);同一條「已請是宣告不是事實」我自己也踩了一次
---

# 事實

```
上一封(round4-launched)寫「第四輪已launch」時，那個background call的真實輸出是：
  rm: cannot remove '...-90d-warring_states.txt': Device or resource busy
  EXIT=1
⇒ GODOT_TIMEOUT=21600那段從沒執行過。我讀到的「結果檔」其實是round3(7200s)的舊殘留，
  不是round4的產物——HEAD/timeout數字對不上正是這個原因（我一開始也被騙了一下，
  三次核對才發現：round3進程雖標timeout，windows上檔案handle還沒真的放乾淨）。
```

# 已處理

```
①確認handle放開（rm重試成功）→ 真正重跑第四輪：
   commit=e5d7566f code-dirty=1（只有我自己改的bed檔，其餘乾淨）
   beacon: pid=13608 started=2026-09-09T14:36:18
   ②godot proc（8676/19704）確認活著、與implementer的material_shortfall_scale_bed.gd
     並行（照你裁定，非違規）
```

跟你的裁定信一致：門檻=期中報表算出的實時吞吐跌破6 tick/s才重跑，不因COLLISION本身砍。
會在真跑完（或吞吐真的跌破門檻）時才回下一封——這封只更正上一封的「已launch」是誤報。
