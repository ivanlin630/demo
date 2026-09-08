# HOW spec：賣方急迫度接上【真實的 coin 義務】（payroll-aware urgency）

owner: systems ｜ 2026-09-08 ｜ player_reachable: no ｜ 狀態：★R² CLEAN（issues 兩點已補）

## §1 病（file:line）

```
trade_valuation.gd:63   const URGENCY_COIN_COMFORT: float = 10.0   # TEST VALUE
trade_valuation.gd:123-126
    coin_urg = clampf(1.0 - team.resources.coin / (pop * URGENCY_COIN_COMFORT), 0.0, 1.0)
    return maxf(_food_urgency(team, state), coin_urg)
trade_valuation.gd:129-134
    discount = clampf(commerce*0.1 + _urgency(seller)*0.3 - (greed-0.5)*0.2, 0.0, 0.5)
    ask      = local_value(seller, res) * (1.0 - discount)
```
⇒ **「我需要多少 coin」＝【人均 10】—— 一個手抄的猜測。**
而世界有一個**算得出來、週期性、可預期**的義務：
```
salary_system.gd:130  payroll = named_payroll + anon_total
salary_system.gd:4    SALARY_INTERVAL = TICKS_PER_DAY * 7
```
★ 而 `trade_valuation.gd` / `order_system.gd` 提到 `salary|payroll` ＝ **0 處**。
⇒ **需求存在，而賣貨決策看不見。**

### ★為什麼這是「接線」不是「調參」
```
memory「估算器禁手抄物理」：估值必 (a) 物理同源推導 或 (b) 讀自身狀態；
  ★血統②【手抄物理常數】全禁,修法形狀＝【改接線非改數值】。
⇒ `pop × 10.0` 就是血統②。
⇒ ★★而 blueprint 已禁「調大 discount 常數」那條路（＝crank，人工製造成交）——同一條原則。
```

## §2 修法（兩處，零新常數）

### ①抽純函數（`salary_system.gd`）
```gdscript
static func estimated_payroll(state: WorldState, team: TeamData) -> float
```
- 內容＝現有 `:110-130` 的計算，**逐字搬**，不重寫公式。
- `_calc_fair_salary` 需改成 `static`（唯一的機械改動）。
- ★**純讀**：只有 `state.persons.get` / `p0.salary` / `values` / `AnonTierSystem.total_wage`。
  已查證三者皆無副作用。

### ②`_urgency` 的 coin 項改讀它（`trade_valuation.gd:123-126`）
```gdscript
var need: float = SalarySystem.estimated_payroll(state, team)
var coin_urg: float = 0.0
if need > 0.0:
    coin_urg = clampf(1.0 - float(team.resources.get("coin", 0)) / need, 0.0, 1.0)
```
★ `URGENCY_COIN_COMFORT` **退場**（連同 `:63` 那行常數一起刪，不要留著沒人用）。

## §3 ★★★鐵則（違反即 R² 退回）

```
★估值路徑【禁寫快取】。
  payroll 迴圈是 O(named_members),而 `_urgency` 在掛單決策裡被呼叫 ⇒ 會有人想快取。
  ⇒ ★★若把 payroll 寫進 team,那就是【讀路徑寫世界】——
     正是本專案今天剛花一整條線修掉的 gather 觀測純度缺陷。
  ⇒ 要嘛純算（先量成本再說）,要嘛由 SalarySystem 在【它自己的 advance 路徑】寫,估值端只讀。
★★perf：先量再優化。若 `estimated_payroll` 真的成為熱點,拿數字來,不要預先優化成一個寫入。
```

## §4 ★★驗收（主判準：**腦看得見了嗎**）

```
★主判準（成對，同世界同 seed，before/after）：
  ①【會動】：一支【payroll 缺口大】的隊（coin < payroll），其 coin_urg 接線後【顯著升高】
  ②【不亂動】：一支【coin 充足】的隊（coin ≥ payroll），其 coin_urg 接線後【仍為 0】
  ⇒ ★兩格都要有輸出。只寫①的對照,天生會漏掉②那一半（今天的血證）。

★★★③【值對】（R² 要求補）：造一支已知 named_members 與 anon_tiers 組成的隊,
  斷言 estimated_payroll ★逐位元等於【獨立算出的】 named_payroll + anon_total。
  ★★理由：①②只抓得住【方向錯】（公式反過來①就不會升）,
     而【方向對、公式錯】（漏了 anon_total、或稅率算兩次）★★★兩格會全綠。

★★次要觀察（★嚴禁當判準）：成交量、板厚、殺單數。
  理由：它們是【後果】。拿它們當判準的話,★★★任何讓成交變多的改動都會過關——
        包括 blueprint 已經禁掉的那條（調大 discount）。
  ⇒ 判準必須能分辨【機制對了】與【數字好看】。
```

## §5 ★誠實限（必須寫進卷面，不得省略）

```
①★payroll ≠ 全部的 coin 需求。
   建設、採購、升級、稅——這些 coin 需求接線後【仍然看不見】。
   ⇒ 本票把一個【手抄的假需求】換成一個【真實但不完整的需求】。
     那是進步（真的 > 手抄的）,★★而不是「coin 需求已經接好了」。
②★★payroll 為 0 的隊接線後 coin_urg ＝ 0 —— 那是【誠實】（確實沒有薪資義務）,
   ★★★而它是一個【行為改變】：這些隊接線後【永遠不會因缺 coin 而折價】,
   而接線前它們會（pop×10 對誰都成立）。量測時要看得見它,不要當成雜訊。
   ★★★而【哪些隊會受影響】必須【量】,不得用代理母體（R² 訂正）：
     我原本寫「純匿名村 / 零記名成員」—— ★而那是錯的代理：
     payroll = named_payroll + anon_total,而只要隊有 anon 人口且 anon_tiers 非空,
     anon_total 就 > 0 ⇒ payroll > 0 ⇒ coin_urg 依然會動。
     ★★真正 payroll 恆 0 要【同時】：無 named（或 named 技能全 0）【且】anon 工資為 0。
     ⇒ 量測要求：卷面報【estimated_payroll == 0 的隊佔比】,
       ★★★不得用「純匿名村」或任何結構描述代替它。
③★★★除零：`need > 0.0` 的守衛不是防禦性程式碼,它承載②的語意。
   ⇒ 不得改寫成 `maxf(need, 1.0)` 之類 —— 那會把「沒有義務」偽裝成「有一點義務」。
```

## §6 不做什麼

```
★不動 discount 的任何常數（COMMERCE/URGENCY/GREED/DISCOUNT_MAX 四個一個都不碰）
★★不加持有成本（腐敗/倉租）——blueprint 裁「先記帳,不急加」
★★★不碰 food 那條線（food 是【估值本身塌了】,與本票的機制無關）
```
