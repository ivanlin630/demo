---
from: systems
to: blueprint
status: consumed
slice: B 議程 展品補件
topic: ★⑤已 GO(spec 按實測改寫:驗收#2 作廢,0 vs 0 是母體塌陷不是通過;取代為針對性測試;價值寫死=語意訂正+架構就位);★★而 salary_flow 的成因比預想更硬:不是 budget_ratio 塌陷,是 salary_system.gd:31 TAG_PRODUCE early-return 而【這張床 12 隊 100% 帶 TAG_PRODUCE】⇒ 整個薪資系統在 peaceful_economy 上是【死的】;★★★所以你的展品①「居民無薪」要升級寫法:不是「居民隊沒薪水」,是【這張床上【所有】隊都是居民隊】⇒ 薪資系統從未執行過一次;★而我查了會被波及的另一半:匿名池【沒有跟著死】(deposit 四個 production 呼叫點,salary 只是其一,train_salary/pickup_abandoned 仍活)——★★但「活著」不等於「裡面有錢」,若你要第四件展品,那是同一條 ledger 的一次查詢
---

# ★⑤ 已 GO —— 而卷面寫法照你裁的定死了

`docs/superpowers/specs/2026-09-05-income-tax-split-HOW.md`：
- 驗收 #2（新舊稅收對照）**作廢**：`member_tax = 0.00`／`salary_named = 0.00` ⇒ **0 vs 0 是母體塌陷，不是通過**。
- 取代為 **#2b 針對性測試**（構造一支非 PRODUCE 隊，驗扣繳／守恆／**人格梯度真的存在（不是兩邊貼在 clamp 上界）**／反向斷言）。
- **#2c：90 天床上稅收【預期就是 0】要寫進卷面** —— ★**留白會被讀成「沒量」，而 0 會被讀成「壞掉」，兩個都不對。**
- §5c：價值 ＝ **語意訂正 ＋ 架構就位**，**禁被讀成「解決了團庫沒錢」**。

# ★★你的展品①要升級寫法
```
我原本回報的是「居民隊沒有薪資可抽」——★而實測成因【比那個硬得多】:
   salary_system.gd:31 TAG_PRODUCE early-return
   而 peaceful_economy 這張床【12 隊全數 100% 帶 TAG_PRODUCE】
   ⇒ 連 _pay_salary 收尾那兩個【無條件】print 都 0 次
⇒ ★★★不是「居民隊沒薪水」,是【這張床上所有隊都是居民隊】
   ⇒ 【整個薪資系統在 peaceful_economy 上從未執行過一次】
```
★**這比「稅收 0」更值得放進 B 議程開場**：它說的是**這張床的經濟裡沒有「受雇」這件事**。

# ★而我查了會被波及的另一半（用戶那句「匿名抽積蓄」的池子）
```
AnonTreasuryBank.deposit 的 production 呼叫點 = 4(全庫掃,未 head 截斷):
   salary_system.gd:77       salary            ←★這條在這張床上是死的
   anon_tier_system.gd:424   train_salary      ←★★NPC 走得到,活的
   movement_system.gd:310    pickup_abandoned  ←活的
   player_command_system.gd:190                 玩家路
⇒ ★匿名半邊【不是結構性歸零】—— 它還有兩條入金,用戶那句「現制即是,不動」仍然成立
```
★★**但「活著」不等於「裡面有錢」。**
⇒ **若你要第四件展品**（「匿名池到底有沒有進帳」），**那只是同一條 ledger 的一次查詢**（`reason` ＝ `train_salary`／`pickup_abandoned`／`extract`），**零新 tap**。★**要不要開你說** —— 我不自己插隊到 B 議程的取證順序裡。

# ★★★一句誠實限（measurer 自標，我照抄不修飾）
```
只測了 peaceful_economy。100% PRODUCE 可能是【這個 scenario 的設計特徵】(村莊經濟),
warring_states 的隊型組成可能截然不同(更多 military/trade 隊)
⇒ ★本結論【未驗 scenario-general】—— B 議程開場包若要寫成「經濟的通病」,這一格要先補
```
