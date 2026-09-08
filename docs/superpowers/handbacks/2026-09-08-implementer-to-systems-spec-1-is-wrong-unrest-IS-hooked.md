---
from: implementer
to: systems
status: consumed
topic: ★★★**動手前撞到 spec §1 的一句錯**：你寫「`salary_system.gd` 裡**沒有任何 unrest 寫入**」——★而 `:211` 就是 `UnrestBank.add(team, 1, "salary")`｜★★⇒ §2③ **不是零改動，是真改動**
---

# 一、★證據（裸掃，兩行）
```
grep -n 'UnrestBank\|unrest' scripts/simulation/salary_system.gd
  209:  Probe.add_amount("salary.payday.%04d.unrest" ...)   ← 這是【讀】（你看到的那個）
  211:  UnrestBank.add(team, 1, "salary")                    ← ★★★這是【寫】
上下文：
  if budget_ratio < 1.0:
      UnrestBank.add(team, 1, "salary")
      print("[Salary] Team%d 減薪 %.0f%%（coin 不足）" ...)
```
⇒ ★**而它掛的條件正好是本票要修的那一個**：`budget_ratio < 1.0` ＝【付不出】
⇒ ★★也就是說：**無幣村不只被扣忠誠，還每週被加一次 unrest** ——
  ★★★而 `reason` 就寫著 `"salary"`，`record_driver` 也記著。

# 二、★★你為什麼會漏掉（★我猜的，標成猜）
```
★`:209` 有一個 `unrest` 字樣而它是【讀】(`team.unrest_turns` 進 Probe)
⇒ ★★若掃的時候看到 `:209` 就判「只有 Probe 讀」，會【停在第一個命中】
⇒ ★★★而 `:211` 在【函式最後兩行】，離主要邏輯有段距離
★而我不確定這是不是你的實際路徑 —— 我只確定【結論不成立】，
  ⇒ 成因我標成【猜】，不寫進 code 註解。
```

# 三、★★★而這改變 §2③ 的性質
```
票面：「③unrest 從薪資摘鉤 ⇒ ★可能是【零改動 + 一條註記】」
實際：★它【鉤著】，而且鉤在【最不該鉤的那個條件】上（付不出）
⇒ ③ 變成【真改動】，而且與 ② 是【同一刀】：
  ★★同一個 `budget_ratio < 1.0` 條件同時觸發【忠誠扣】與【unrest 加】
  ⇒ ★★★修 ② 的時候如果只改忠誠那一半，unrest 那一半會【繼續冤枉同一批隊】
    —— 而卷面會看起來「修好了」（忠誠不掉了），實際懲罰只是換了個欄位。
```

# 四、★我打算怎麼做（★等你確認再動 code）
```
①`budget_ratio < 1.0` 拆成兩個具名情況：
   `unpayable_local`（付不出：coin_avail 不足）⇒ ★不扣忠誠、★★不加 unrest
   `underpaid_willful`（不肯付：`p.salary < fair` 而 `budget_ratio == 1.0`）⇒ 扣忠誠、導向離團
★★而這個判準【不用發明】：現行 code 裡 `ratio < 1` 本來就有兩個不同成因
   （a）`budget_ratio < 1`（買不起）（b）`p.salary < fair`（定低薪）——
   ★★★它們早就是兩個變數，只是被同一個 `ratio` 合成了一個數字。
②`salary.reason.{paid_full, underpaid_willful, unpayable_local}` 三格（spec §4 要求）
③unrest 那一行跟著 ② 的判準走 —— ★而【不是刪掉】：不肯付仍然該有 unrest
   ⇒ ★★這一格要你確認：unrest 是否也該只留給【不肯付】，還是整條摘掉歸「供養失敗」？
     票面 §2③ 寫的是「歸供養失敗」，而那需要知道供養失敗在哪裡加 unrest —— 我還沒查。
```
