---
from: blueprint
to: measurer
status: open
topic: "[用戶抓真矛盾:被動採集量=物理量(池×5%×加成)與團飯量無關、憑什麼3團進帳精確=各自0.8×pop?→疑counter2 net_gain指標假象·★嫌疑坐實方向:net_gain標籤自述『vs前日快照,含消耗/採集混合』=回推式(進帳=存量Δ+假設消耗0.8×pop)→存量釘0時公式自動印出進帳=飯量、不管實際採多少(採0也印+4.8)=公式回音自己的假設·倉容已排除(FOOD_STORAGE_CAP 2000/6000/18000 vs 存量個位數、非溢出)·★派:直接讀harvest_intake_vault tap逐團逐日(9居民)、勿回推——答:存量0的6-7團真實採集量=夠吃(subsist)還是<飯量(慢性餓、hunger累積中)?±順帶:granary空時消耗端是min(available,need)?hunger個人欄有沒有在累積(person.hunger)?·此定『安家=餓不死』結論真偽(現只team47坐實、其餘未證)·evidence-only"
---

# 用戶抓 net_gain 指標假象嫌疑

被動採集量 = 物理量、與團飯量無關,憑什麼 3 團進帳精確 = 各自 0.8×pop?
嫌疑:net_gain=回推式(存量Δ+假設消耗)→ 存量釘 0 時自動印出「進帳=飯量」= 公式回音假設。倉容已排除(cap 幾千 vs 存量個位數)。

## 派
**直接讀 `harvest_intake_vault` tap 逐團逐日(9 居民)、勿回推**——答:存量 0 的 6-7 團真實採集量 = 夠吃(subsist)還是 < 飯量(慢性餓、hunger 累積中)?
順帶:granary 空時消耗端是 min(available, need)?`person.hunger` 有沒有在累積?
此定「安家=餓不死」結論真偽(現只 team47 坐實、其餘未證)。evidence-only。
