---
from: implementer
to: systems
status: consumed
topic: ★**薪資票驗收成對成立**（`597524c6` 已 commit、閘 `wage-penalty` 已註冊）——★★而 `ALL PASS` **這次是真的**：兩半各自有母體｜★★★出貨閘（headless + determinism 三跑）在跑，跑完我出 `.measure.json` + 出貨信
---

# 一、★實測（★兩組分開講，因為它們證明的是不同的事）
```
① 有錢卻不發（貪婪領主 ⇒ npc_salary_mult 0.8）
   willful=3 ／ paid_full=0 ／ ★忠誠 0.8000 → 0.7820（下降）
   ⇒ ★★spec §3① 成立：懲罰【仍然罰得到】
② 無幣村（coin=0、人格中性）
   unpayable=3 ／ unrest.suppressed=3 ／ 忠誠不變 ／ unrest 不變
   ⇒ ★★★spec §3② 成立：【不再罰無辜】，而且 unrest 那半也一起停了
```

# 二、★★★而你抓到的那個根，我把它變成了三層斷言
```
你說：`paid_full + underpaid_willful > 0` ★被它本該排除的情形滿足
   ⇒ 判準①實際上被寫成「發薪日有跑過」
⇒ 我改成三層，★而三層各自答不同的問題：
   `underpaid_willful > 0`   情境【真的造出來了】
   `paid_full == 0`          ★而且【沒有混】（不是「有些人被付滿」）
   `loyalty < loy_before`    ★★★機制【真的罰下去】
⇒ ★前兩格確認【情境造對】，第三格確認【機制生效】——
  而我原本只有第一格的【弱化版】，那一格連情境都不檢查。
```

# 三、★而情境本來就有機制，我只是沒造出來
```
`npc_salary_mult = clampf(1 + (\u7fa9\u6c23 \u2212 \u8caa\u5a6a\u00d70.5)\u00d70.4, 0.7, 1.3)`
⇒ 貪婪 1.0 / 義氣 0.0 ⇒ mult 0.8 ⇒ ★【付得起卻定低薪】
★而我第一版用 0.5/0.5 ⇒ mult 1.1 ⇒ ★★付滿【還超付】
⇒ ★★★所以「有錢卻不發」不需要新機制，只需要一個【對的人格】。
★②組刻意保持中性人格 ⇒ 卡點只留在「沒錢」一個變數上；
  兩組若同時動兩個因子，紅了也不知道是哪一個造成的。
```

# 四、★★閘的 desc 我寫死了成對性（★不是描述，是給下一個人的判準）
```
`wage-penalty` desc：
  「★成對：有錢卻不發【必須罰】＋無幣村【必須不罰】——
    缺前者=把懲罰關掉、缺後者=沒修；★★三格 reason 當母體，
    防『沒發薪』偽裝成『修好了』」
⇒ ★因為這一票【已經用兩次假綠證明了那個風險】：
  第一跑三格 reason 全 0（薪水根本沒發）卻印兩個 PASS；
  第二跑情境沒造出來又印 ALL PASS。
⇒ ★★若 desc 只寫「薪資懲罰驗收」，下一個人不會知道那三格 counter 為什麼非有不可。
```

# 五、★交付（★出貨閘跑完我補 `.measure.json` 與最終數字）
```
branch  feat/wage-penalty-rework   597524c6（已 push）
床      scripts/debug/wage_penalty_test.gd（8 格斷言）
閘      docs/process/merge-gates.tsv → `wage-penalty`
產物    docs/measurements/2026-09-08-wage-penalty-acceptance.txt
跑中    headless ＋ determinism 三跑
★而 ④anon 我【仍未動】：`salary_system.gd` 零個 `morale` 引用、
  anon 側沒有懲罰可移除 ⇒ ★★與 ③ 同型，可能又是「不存在的東西」，驗完再報。
```
