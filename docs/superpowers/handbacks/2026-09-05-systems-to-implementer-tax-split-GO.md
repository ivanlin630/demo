---
from: systems
to: implementer
status: consumed
slice: ⑤ 團內稅分軌 —— GO
topic: ★R² CLEAN + blueprint 裁【照做】,spec 已按實測改寫:docs/superpowers/specs/2026-09-05-income-tax-split-HOW.md;★★驗收#2【作廢】——前置量測回來 member_tax 90天=0.00 且 salary_named=0.00/次數0 ⇒ 0 vs 0 是母體塌陷不是通過;成因坐實=salary_system.gd:31 TAG_PRODUCE early-return,這張床 12 隊【100% 帶 TAG_PRODUCE】,連收尾兩個無條件 print 都 0 次;★★★取代它的是【針對性測試】(構造一支非 PRODUCE 隊驗扣繳/守恆/人格梯度/反向斷言),而 90 天床上的稅收【預期就是 0】要寫進卷面不能留白;★本票價值=語意訂正+架構就位,禁被讀成「解決了團庫沒錢」;★★另有一條硬禁令 §5b:不准為解卡開緊急沒收特例走廊
---

# ⑤ GO

spec：`docs/superpowers/specs/2026-09-05-income-tax-split-HOW.md`（R² CLEAN；blueprint 裁**照做**）

## ★動作（三段）
```
A 廢:collect_member_tax 整支 + caller(faction_ai_system.gd:1168)
     + 常數 MEMBER_TAX_K/K2/MIN/MAX/PERSONAL_COIN_FLOOR + 介面註解(faction_ai_system.gd:4267)
B 掛:所得稅【源扣繳】於 salary_system.gd:64-67 —— ★稅額【從未離開團庫】
     rate = clampf(greed*K - prudence*K2, 0.0, MAX)   ←★人格同形,★★下界改 0.0
     net  = paid * (1.0 - rate)
   ＋★payroll 用 net(named 部分乘 (1-rate);★anon 不乘,它不課稅)
   ＋★★忠誠 ratio 讀【名義】,:65 一行不動(稅不混進 underpay 懲罰)
C 匿名半邊【一行不動】(salary_system.gd:75-77)
```

## ★★驗收 #2 我作廢了 —— 而理由你要知道
```
前置量測回來:member_tax 90 天總額 = 0.00 ／ ★salary_named 也 = 0.00、次數 0
⇒ ★★「新舊稅收對照」變成 0 vs 0 —— 那是【母體塌陷】不是【通過】
★★★成因坐實(不是推測):salary_system.gd:31 TAG_PRODUCE early-return
   而 peaceful_economy 這張床【12 隊全數 100% 帶 TAG_PRODUCE】
   ⇒ 連 _pay_salary 收尾那兩個【無條件】print 都 0 次 ⇒ 函式本體【從未跑到】
```

## ★★★取代它的驗收（#2b／#2c，spec 裡已寫）
```
#2b 針對性測試:構造【一支非 PRODUCE 隊】(有 team.coin、有 named_members、有技能⇒fair>0)
    ①扣繳後 person.coin = paid×(1-rate)
    ②team.coin 的流出 = net(★稅額從未離開團庫)
    ③CoinAudit = 0
    ④★人格梯度【真的存在】:貪婪 leader vs 慎重 leader 的 rate 不同
       —— ★★不是兩邊都貼在 clamp 上界(那看起來像有梯度,實際沒有)
    ⑤★★★反向斷言:team.coin=0 且成員持有私產時,【不存在】把存量拉回團庫的機制
#2c ★90 天床上的稅收【預期就是 0】⇒ 要在卷面【寫成預期 0 並附理由】
    ★★留白會被讀成「沒量」,而 0 會被讀成「壞掉」—— 兩個都不對
```

## ★兩條硬的
1. **§5b 禁令**（blueprint 釘，用戶法的直接延伸）：**不准為解 `team.coin=0` 卡死開任何「緊急沒收／特赦沒收」特例走廊** —— 具體禁止：**不得新增「當 `team.coin < X` 時直接抽 named 成員 `p.coin`」這類路徑**（不論掛哪一支、條件寫得多嚴）。
2. **§4 1b**：`unified_commerce_test.gd:263-292` `_test_combo_taxed_buyer_deals` —— **改測，不刪**（正向改測扣繳增量 ＋ 反向斷言）。★`:239` `_test_member_tax_conservation` 也改測所得稅守恆。

## ★★★而這張票的價值，我先寫死（免得驗收時互相解釋）
```
★這張床上【新制一樣收 0】—— 不是修好稅制,是把一個收 0 的換成另一個收 0 的
⇒ 價值 = 【語意訂正 ＋ 架構就位】:錢開始流的那天,稅制已經是【對的形狀】
⇒ ★★禁止把 ⑤ 讀成「解決了團庫沒錢」;真正的 binding constraint 是 B 議程
★誠實限:只測了 peaceful_economy;100% PRODUCE 可能是【該 scenario 的設計特徵】(村莊經濟),
   warring_states 隊型組成可能截然不同 ⇒ ★★★本結論【未驗 scenario-general】,不要寫成通則
```

## ★別忘了新規矩（今天立的）
```
①寫反向斷言 = 【兩個動作】:寫測試 + 往 docs/process/merge-gates.tsv 加一行(expect 要是【斷言】不是完成標記)
②commit 一律帶 pathspec(裸 git commit 吃整個 index ⇒ 會收走別人的半成品,今天同型三次)
```
