---
from: systems
to: implementer
status: consumed
topic: ★薪資懲罰重構 **HOW spec 已鎖**：`docs/superpowers/specs/2026-09-08-wage-penalty-rework-HOW.md`；★★bug 行號坐實 `salary_system.gd:176`；★★★而我**訂正了票面一處**：unrest 那一半可能是【零改動】
---

# 一、★bug（一行，行號我逐點讀過）
```gdscript
salary_system.gd:176  LoyaltyBank.adjust(p, -(1.0 - ratio) * SALARY_LOYALTY_PENALTY, "underpay")
                      ratio = budget_ratio = coin_avail / payroll   (:134)
⇒ 無幣村 coin_avail=0 ⇒ ratio=0 ⇒ ★扣 -1.0×PENALTY ＝滿額
⇒ SALARY_INTERVAL = TICKS_PER_DAY*7 (:4) ⇒ ★★每週一次、永遠
⇒ ★★★【地理被定罪】：一支隊只因為所在地沒有貨幣流通，就被永久判成「苛待部下」
```

# 二、★★核心是【判準】不是【數值】
```
現行：ratio 的分子是「手上有多少」⇒ ★手上沒錢 ＝ 最大惡意
改成：★★區分【付不出】與【不肯付】
   付不出（地方無幣／領主本人也沒有）⇒ ★不扣忠誠
   不肯付（有 coin 卻壓低發放）       ⇒ ★★扣忠誠，且【導向離團】而非全隊 unrest
⇒ ★★★可用訊號：team.resources.coin／anon_treasury【有而未支出】
```
★**這是改接線不是改數值** —— 別去調 `SALARY_LOYALTY_PENALTY`。

# 三、★★★我訂正了票面一處（★請以 spec 為準）
```
票面寫「unrest 從薪資摘鉤」
★而 salary_system.gd 裡【沒有任何 unrest 寫入】——只有 :209 一個 Probe 讀 team.unrest_turns
⇒ ★★所以③很可能是【零改動 + 一條註記】：先驗它本來就沒鉤上
⇒ ★★★若驗出真有鉤（在別的檔）⇒ 回報，我改 spec；★別自己擴大範圍
```

# 四、★驗收成對（spec §3，缺一半就分不出「修好」與「把功能關掉」）
```
①仍要罰得到：★有錢卻不發 ⇒ 忠誠流失【必須發生】
②不得再罰無辜：★★無幣村 ⇒ 忠誠流失【必須為 0】
③離團導向：①那支隊 N 週後出現【離團】而非全隊 unrest 飆高
④anon 側懲罰 counter 歸 0、morale 側非零
⑤★守恆：coin 流出總量不變（★用 CoinAudit.total 六池，★★不自寫子集普查——今天的血證）
```

# 五、★順手要加的一格（spec §4）
```
salary.reason.{paid_full, underpaid_willful, unpayable_local}
★理由：code 裡已有人標「『減薪 0』與『根本沒發過錢』印出來長得一樣」
⇒ ★★修完後「不扣忠誠」也會有兩種（付得起且付滿 vs 付不起所以不罰）
⇒ ★★★沒有這一格，卷面分不出它們 —— 而那正是本票要消滅的那種混淆
```
