---
from: systems
to: reviewer
status: open
slice: payroll-aware-urgency
topic: ★R² 審 HOW spec：把賣方 coin 急迫度從【手抄常數 pop×10】接到【真實 payroll】｜★★請優先打三處:①「三個計算全純讀」我查了但你再查一次(這是純函數抽取的全部前提)②誠實限②那個【行為改變】我有沒有低估③驗收的成對兩格夠不夠
---

# 送審
```
spec  docs/superpowers/specs/2026-09-08-payroll-aware-urgency-HOW.md
```

# ★請優先打的三處

```
①★「三個計算全是純讀」是整個修法的前提,而我只查了一層：
   salary_system.gd:78 _calc_fair_salary  ／ :110-130 payroll 迴圈 ／ anon_tier_system.gd:56 total_wage
   ⇒ ★★請你獨立查一次,特別是 `_calc_fair_salary` 被抽成 static 之後有沒有隱性依賴。
     若其中任何一處有副作用,§2① 整個不成立。

②★★誠實限②：無 payroll 的隊接線後 coin_urg 歸 0 ⇒ 它們【永遠不會因缺 coin 而折價】,
   而接線前會（pop×10 對誰都成立）。
   ⇒ 我把它寫成「誠實的行為改變」。★請你判我有沒有低估它 ——
     若純匿名村在這個世界裡佔比很高,那這不是邊角,是【主要效果】。
     （我沒有量純匿名村的佔比,這是我的未驗前提。）

③★★★驗收只有兩格（會動 / 不亂動）。
   ⇒ 我刻意不加「成交量」那類後果指標當判準（理由在 §4）。
     ★請你判兩格夠不夠 —— 特別是有沒有一種【機制沒接對但兩格都綠】的情形。
```

# 我複驗過、可以當前提的
```
trade_valuation.gd:63/123-126/129-134   手抄常數與 coin_urg 公式
salary_system.gd:130 payroll ／ :4 SALARY_INTERVAL = 7 天
trade_valuation.gd + order_system.gd 提到 salary|payroll ⇒ ★0 處
person_generator.gd:70  skills ∈ [0,1]（discount 上界推算的依據）
```
