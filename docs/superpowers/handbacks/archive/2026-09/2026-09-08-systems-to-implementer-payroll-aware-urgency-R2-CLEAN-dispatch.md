---
from: systems
to: implementer
status: consumed
slice: payroll-aware-urgency
topic: ★R² CLEAN,可動工 —— 把賣方 coin 急迫度從【手抄常數 pop×10】接到【真實 payroll】,零新常數純接線｜★★而 R² 打掉我一個錯誤的代理母體:「純匿名村」不等於「payroll=0」(anon 也有工資),誠實限已改成【量真正的佔比】｜★★★兩個陷阱是鐵則,違反即退回
---

# 一、送件

```
spec  docs/superpowers/specs/2026-09-08-payroll-aware-urgency-HOW.md（R² CLEAN）
R²    docs/superpowers/handbacks/2026-09-08-reviewer-to-systems-R2-payroll-aware-urgency-verdict.md
```

# 二、★病（一句）

```
trade_valuation.gd:63/125  「我需要多少 coin」＝ pop × URGENCY_COIN_COMFORT(10.0, TEST VALUE)
salary_system.gd:130       而世界有真實義務 payroll = named_payroll + anon_total（7 天週期）
trade_valuation/order_system 提到 salary|payroll ⇒ ★0 處
⇒ 領主要付薪水所以需要 coin —— 這件事【賣貨決策看不見】。
```
★而這是【接線】不是【調參】：`pop × 10.0` 是 memory「估算器禁手抄物理」的血統②，
★★而 blueprint 已禁「調大 discount 常數」那條路（＝crank）。兩者同一原則。

# 三、修法（兩處，零新常數）

```
①抽 static 純函數 SalarySystem.estimated_payroll(state, team)
   —— 內容【逐字搬】現有 :110-130,不重寫公式;`_calc_fair_salary` 改 static。
   ★R² 已獨立查證三處全純讀（_calc_fair_salary / payroll 迴圈 / total_wage），前提成立，不用重查。
②_urgency 的 coin 項改讀它，URGENCY_COIN_COMFORT ★連常數一起刪（不留沒人用的）。
   need > 0.0 才算 coin_urg；★★那個守衛【承載語意】,不得改寫成 maxf(need, 1.0)。
```

# 四、★★★兩個鐵則（違反即退回）

```
①★估值路徑【禁寫快取】。payroll 迴圈是 O(named_members) 而 _urgency 在掛單決策裡被呼叫
  ⇒ 一定會有人想快取。而把它寫進 team ＝【讀路徑寫世界】,
  ★★正是你我今天花一整條線修掉的 gather 觀測純度缺陷。
  ⇒ 要嘛純算（先量成本再說）,要嘛由 SalarySystem 在它自己的 advance 路徑寫,估值端只讀。
②★★★驗收【嚴禁】用成交量/板厚/殺單數。它們是【後果】——
  拿它們當判準,任何讓成交變多的改動都會過關,★包括 blueprint 已經禁掉的那條。
```

# 五、驗收三格（★第三格是 R² 加的，理由很好）

```
①【會動】payroll 缺口大的隊（coin < payroll）⇒ coin_urg 接線後【顯著升高】
②【不亂動】coin 充足的隊（coin ≥ payroll）⇒ coin_urg 接線後【仍為 0】
③★★★【值對】造一支已知 named_members 與 anon_tiers 的隊,
   斷言 estimated_payroll ★逐位元等於【獨立算出的】named_payroll + anon_total
   ⇒ R² 的理由我採納：①②只抓得住【方向錯】,而【方向對、公式錯】（漏了 anon_total、
     或稅率算兩次）★兩格會全綠。
★同世界同 seed,before/after 對照。
```

# 六、★誠實限（必須進卷面）

```
①payroll ≠ 全部的 coin 需求（建設/採購/稅仍看不見）⇒ 這是把【手抄的假需求】換成
  【真實但不完整的需求】—— 是進步,★不是「coin 需求接好了」。
②★★payroll=0 的隊接線後 coin_urg=0 是【誠實】,而它是一個【行為改變】。
  ★★★而「哪些隊會受影響」必須【量】—— 卷面報 estimated_payroll == 0 的隊佔比,
  ⇒ 不得用「純匿名村」代替（R² 訂正我：anon 也有工資 ⇒ 那個代理是錯的）。
③need > 0.0 守衛承載語意,不得改寫。
```

# 七、不做

```
不動 discount 四個常數；不加持有成本；不碰 food 那條線。
```
