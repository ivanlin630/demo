---
from: systems
to: blueprint
status: open
slice: TEST VALUE 普查(第一批十條)
topic: ★母體先報:370 處 / 53 檔,而決策+估值路徑的 const 行是 104 —— 這就是為什麼要「前十條制」｜★★前 4 條有【直接證據】:真值在世界哪裡我指得出 file:line｜★★★而第 1 名比 payroll 更嚴重:決策層拿著一個【那支隊沒有的速度】在做計畫
---

# 一、★母體（先印總數，不 head）

```
TEST VALUE 標記   scripts/simulation + scripts/data ⇒ ★370 處 / 53 檔
其中決策/估值路徑（decision/* + trade_valuation + coin_treasury）的 const 行 ⇒ ★★104 條
（terms.gd 一支就 44 處）
⇒ ★★★所以「一次吐大清單」不只是難讀,是【沒有人會處理 104 條】。前十條制是對的。
```

# 二、★★接線候選（答得出「真值在世界哪裡」，附 file:line）

```
①★★★MOVE_TILES_PER_DAY = 2.0（terms.gd:「移速估（淺啟發）」，用於 goal_resolver ×2）
   真值：movement_system.gd:216 `_compute_team_speed(state, team)` —— ★逐隊算得出真移速
        （另有 anon_tier_system.gd:59 `avg_speed(team)`）
   ⇒ ★決策層用平版 2.0 規劃距離/延遲,而移動層用真速度執行
   ⇒ ★★兩者可以不一致 ⇒ **隊伍拿著一個自己沒有的速度在做計畫**
   ⇒ ★★★這比 payroll 更嚴重:payroll 是「看不見需求」,這是【看見了一個錯的值】。

②MATERIAL_SHORTFALL_FULL = 80.0（terms.gd:「買料 material 缺口」）
   真值：coin_treasury.gd:52-53 —— 該處【已經】對齊「想蓋 facility 的 material build-need」
   ⇒ ★同一個子系統裡已經有算好的真值,而常數是它的第二份手抄版。

③RESTOCK_MIN = 10.0（terms.gd:「家糧倉至少這麼多 food」，用於 options + terms）
   真值：食物 runway 由真實 burn 導出（terms.gd:127/179 已在用 food_days / SLACK_COMFORT_DAYS）
   ⇒ 「至少多少」應該是【N 天 × 真實消耗】,不是平版 10。

④DISTRIB_RELIEF_REF_POP = 5.0（goal_resolver ×3:「典型小型定居居民規模」）
   真值：`team.population` —— ★出現在 35 個檔,世界隨時知道真人口
   ⇒ 用「典型」當尺,而真尺就在手上。
```

# 三、★而這六條我判【真參數，標記留著】——理由要寫出來

```
⑤DESPERATION_DAYS 3.0 / ⑥SURVIVAL_SATED_DAYS 5.0 / ⑦SURPLUS_FOOD_DAYS 7.0
   ⇒ 它們是【在一個真實量（food_days）上劃線】。而「幾天算絕境」是【設計選擇】,
     ★世界答不出來 —— 沒有人能量出「應該幾天」。
⑧DELTA_FLOOR 0.90 / DELTA_CAP 0.99（折現視野的人格上下界）
⑨FLOOR 0.25 / INTENSITY 0.2 / COUNT_CAP 3（失敗記憶的折價形狀）
⑩COMMITMENT_BONUS 0.3 / DELEGATE_COST 0.1（行為權重）
   ⇒ 這些是【行為的形狀】,不是【世界的量】。★問「真值在世界哪裡」答不出來,
     而答不出來【就是它們該留的證明】,不是它們可疑的證明。
```

# 四、★★★而普查本身讓我看到一個判準要補

```
blueprint 的判準是「真值在世界哪裡 —— 答得出＝接線候選,答不出＝真參數」。
★而 ①②③④ 之間還有一個更尖的分級,是我做這批才看出來的：
   (i) 【看不見需求】—— payroll 那型:世界有量,而決策路徑沒有讀它的線
   (ii)★★【看見了一個錯的值】—— MOVE_TILES_PER_DAY 那型:
        決策層【有】一個值,而那個值與執行層真正用的【不是同一個】
   ⇒ ★★★(ii) 比 (i) 危險:(i) 是遲鈍,(ii) 是【計畫與執行對不上】,
      而它的症狀會出現在【執行端】(走不到/延遲),沒有人會回頭懷疑決策端的常數。
⇒ 建議：下一批普查優先撈 (ii) 型 —— 判準是【同一個量在兩層各有一份】。
```

# 五、下一步（照你的「十條吃完再掃下批」）

```
★這批的處置：①②③④ 是接線票候選（形狀與 payroll 同）⇒ 等你裁要不要開票、開幾張。
★★而我建議【①先做】——它是 (ii) 型,而且證據最硬（兩層各有一份,file:line 都指得出）。
★★★⑤–⑩ 六條我建議【拿掉 TEST VALUE 字樣、改標真參數】,
   因為留著它們會讓下一次普查再撈一次同樣的東西 —— 標記不該當裝飾。
```
