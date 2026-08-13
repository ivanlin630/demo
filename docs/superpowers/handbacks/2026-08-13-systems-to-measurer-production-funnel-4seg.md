---
from: systems
to: measurer
status: consumed
topic: "[production funnel 四段細分(blueprint addendum、細分①世界糧帳切面成產能鏈、同數據不重跑、用戶戳中42據點能生產故『生產≈0』太強)·假說銳化:產能可能在、~60%流浪團沒插上插頭(team18 兩月生產task 0/從未進駐/貿易56%覓食5%=在據點旁餓死流浪團、有倉團全活)·★四段各給%→根自然現形(禁預設哪段、可能多段並發):①佔據率=42據點(民0.7軍0.3、35%獨立)幾個有團真進駐(is_resident_static=TAG_PRODUCE+站自家/同faction outpost)vs 幾個空置;分母=團數多少無據點流浪(60%?)·★systems ①佔據結構grounding:流浪→producer 兩路(a)紮營 found 新據點=applicable food_days<desperation_threshold AND has_farmable_tile AND not has_own_outpost + _find_unowned_farmable_tile≠-1(要有未佔農地)→查紮營 fire 幾次/_find_unowned_farmable_tile 幾次-1(無未佔農地=據點滿/世界擠)/camp util 輸給貿易覓食幾次(b)settle-at-existing=subteam TASK_SETTLE→抵達→_convert_to_resident→查 TASK_SETTLE dispatch 幾次/抵達幾次·②生產fire率=進駐(resident)團生產task(TASK_PRODUCE)真跑幾成 vs idle/被打斷(labor pool fill、manufacture.noop_no_worker 等既有tap)③盈餘率=村日產出(採集+manufacture)−自吃(pop×0.8)=正/負?逐resident村淨值④流通率=盈餘上市場否(村surplus→賣單?vs 村自吃飽不賣→流浪團有錢[team18 coin17]買不到=分配斷、buyfood util高winner但市場成交少[1400t只5單位])·★禁預設哪段·量完四段%+三守恆切面(糧帳生死線/力平衡棘輪/時鐘比)→systems consolidate 定哪段(進駐決策/task assignment/產率/分配)斷→blueprint 帶用戶生存經濟基座arc·★先修temp-diag編譯錯(faction_ai:2490)·地基KEEP"
---

# production funnel 四段細分（細分①世界糧帳切面成產能鏈）

blueprint addendum（用戶戳中 42 據點能生產、「生產≈0」太強）。假說銳化：**產能可能在、~60% 流浪團沒插上插頭**（team18 生產task 0/從未進駐/在據點旁餓死；有倉團全活）。四段各給%→根自然現形（禁預設哪段、可能多段並發）：

## ①佔據率
42 據點幾個有團真進駐（`is_resident_static`=TAG_PRODUCE+站自家/同faction outpost）vs 空置；分母=團數多少無據點流浪（60%?）。
- ★**systems ①佔據結構 grounding**（流浪→producer 兩路）：
  - (a) **紮營** found 新據點：applicable `food_days<desperation_threshold AND has_farmable_tile AND not has_own_outpost` + `_find_unowned_farmable_tile≠-1`（**要有未佔農地**）→ 查紮營 fire 幾次 / `_find_unowned_farmable_tile` 幾次-1（**無未佔農地=據點滿/世界擠**）/ camp util 輸給貿易覓食幾次。
  - (b) **settle-at-existing**：subteam `TASK_SETTLE`→抵達→`_convert_to_resident`→ 查 TASK_SETTLE dispatch 幾次/抵達幾次。

## ②生產fire率
進駐(resident)團 `TASK_PRODUCE` 真跑幾成 vs idle/被打斷（labor pool fill、`manufacture.noop_no_worker` 等既有 tap）。

## ③盈餘率
村日產出（採集+manufacture）−自吃（pop×0.8）= 正/負？逐 resident 村淨值。

## ④流通率
盈餘上市場否（村 surplus→賣單？vs 村自吃飽不賣→流浪團有錢[team18 coin17]買不到=分配斷、buyfood util 高 winner 但市場成交少[1400t 只 5 單位]）。

★禁預設哪段。量完四段% + 三守恆切面（糧帳生死線/力平衡棘輪/時鐘比）→ systems consolidate 定哪段（進駐決策/task assignment/產率/分配）斷 → blueprint 帶用戶生存經濟基座 arc。★先修 temp-diag 編譯錯（faction_ai:2490）。地基 KEEP。
