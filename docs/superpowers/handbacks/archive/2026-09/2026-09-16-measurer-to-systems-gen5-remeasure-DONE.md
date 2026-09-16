---
from: measurer
to: systems
status: consumed
slice: 世代5(2fb10d7c1)重量測——HOW spec交件
topic: ★四格+(4a)/(4b)全部有數：②舊走廊全窗=0/新機制真接管(3seed全PASS)、③④修好bug後PASS、①對照格(飽不打)極穩但正例格(餓有牙會打)10天×3seed=0次出現(母體太薄非驗證失敗)、(4a)(4b)先切171(163迎戰確定4a+8外交貿易確定4b)，450待implementer裝的分類tap
---

# 卷：`docs/process/verdicts/gen5-remeasure.measure.json`

```
②偵查三數：3個seed全部 recon.dispatch.ok>0 且 g3.scout_dispatch(舊走廊)=0 ⇒ 新機制真的接管
③先驗被取代：day0 fixture，修好本床自己的bug後 PASS（詳下）
④粒度桶1/2/3：嚴格單調、min>0、max<CAP ⇒ PASS（與scout_on_the_scale_bed既有讀數一致）
①處境攻擊成對反事實：對照格(飽且目標硬⇒仍不打)三個seed共424次檢查、0反例，極穩
                    正例格(餓且有牙⇒攻擊贏argmax)三個seed×10天=0次出現——母體太薄，非紅
(4a)(4b)：621次中171確定(163迎戰=4a｜8外交+貿易=4b)，450(五個survival-class)待你已裁的分類tap
```

# ★①正例格母體太薄——要不要繼續是你的判斷

10天×3seed、每7天抽樣，「food_days<絕境門檻 且 armed>0」這個交集至今沒出現過一次。
本卷沒拆解兩條件各自的出現頻率（沒加細分計數），所以答不出「窗太短」還是「兩條件本來就少同時成立」。
★禁止我自己猜——若這格對你/blueprint重要，下一票可以加細分計數或延長窗；若不重要，對照格已經夠力證明成對方法論站得住，這格可以留白。

# ★本卷自己出過一次假紅，如實記錄不是藏起來

第一輪3個seed的③-a全部FAIL——查出是本床fixture漏了一步(erase intel後沒補state1位置claim，
退化成真零情報=排除，不是先驗blind那格)，非世界問題。已修+1天窗重驗全綠，commit記錄都在
（`2cc55515a` 修法、`gen5-remeasure-fixcheck-raw.txt` 重驗log）。

# 已知限制都在卷裡，兩個特別標一下

- `[HOST] FreeMB`那行印錯了東西（進程靜態記憶體，非系統可用記憶體）——真正的跑前系統FreeMB查核是我另外用PowerShell查的(15276MB)，不在床輸出裡，下一個人別誤讀。
- raw log是UTF-16LE(PowerShell `*>`預設)，讀要`iconv -f UTF-16LE -t UTF-8`，不是CP950。

# 不做

沒調任何參數；沒跟世代4以前數字比。
