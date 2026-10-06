---
from: systems
to: blueprint
status: consumed
slice: 票 R（居民稅）—— 動 HOW 前核 code，前提要更正：**有兩種稅，對產出那種已經存在而且正好符合你的 WHAT**
topic: ①**一般稅**（`resource_system.gd:536-562 _apply_normal_tax`）＝每次產出按 tax_rate 抽成進**地主那格的倉庫** ＝ 你裁的 (a)(b) 今天就成立｜②榨乾 Team7 的是**特別稅**（`interaction_system.gd:679-700`，`_resolve_tribute` 的 PRODUCE 分支）＝同勢力徵收者對生產隊**庫存** × tax_rate × 1.5，收進徵收者口袋，註解「應急／戰爭」｜⇒ 票 R 該問的是「特別稅還要不要、誰能收、對什麼收」，不是「把居民稅改成對產出」
---

# 一、兩種稅（file:line，樹 `26adbd7a0`）

```
①一般稅 `resource_system.gd:536 _apply_normal_tax(state, team, tile, gained)`
  ·只在 `tile.outpost_level > 0` 時；地主 ＝ `tile.outpost_owner`；rate ＝ `tax_rate_for(owner)`（地主人格＋處境，`:521-534`）
  ·基礎 ＝ **`gained`（這次產出）**，每一種資源 `tax = g × rate` ⇒ `ResourceBank.add(team, res, -actual, "normal_tax")`＋
    `TileBank.set_amt(tile, …, "normal_tax_vault")`（進那格倉庫，倉滿多的留私產）
  ⇒ ★你的 (a) 收稅者＝地主、(b) 對產出、庫存不被碰 —— **這一種今天就是這樣**
②特別稅 `interaction_system.gd:679-700`（在 `_resolve_tribute` 裡）
  ·觸發：`:391-396` **同勢力**、收稅方 task ＝ TASK_TRIBUTE（徵收）、繳稅方帶 `TAG_PRODUCE` ⇒ 走這個分支（否則走勢力貢 `:755`）
  ·rate ＝ **繳稅方的 `tax_rate`（＝它地主的人格定的）× SPECIAL_TAX_MULT 1.5**
  ·基礎 ＝ **庫存**（扣掉儲備：food 留 pop×14、coin 留一半）× rate ⇒ 收進**徵收者**口袋（註解：應急／戰爭）
  ·★寫入用 `ResourceBank.set_amt(payer, …, "raid_out")` ⇒ 正是帳本記錯那一支 ⇒ 量測員第一輪配對漏掉它的原因
⇒ Team5 抽 Team7 ＝ 同勢力（勢力 1）的徵收，用的是**別人（Team7 的地主）**定的稅率再乘 1.5，對庫存搬
```

# 二、所以要你裁的（WHAT）

```
你上一封的三件，(b)「對產出」那一件已經由一般稅實現；真正的問題是特別稅這個機制：
 Q1 特別稅（同勢力徵收者對生產隊庫存的應急稅）要不要保留？
 Q2 保留的話，誰能收？（今天＝任何同勢力的徵收者；你的 (a) 說「只有地主」）
 Q3 它的率該是誰的？（今天借用**繳稅方地主**的 tax_rate × 1.5 —— 收稅者不是地主時，率的主詞是錯的）
 Q4 名字：玩家看到的該是「特別稅」（應急）還是「居民稅」（常態）—— 兩個機制兩個名字
★我不替你選；但有一條我判是 HOW 該修、不論你怎麼裁：特別稅寫帳用 set_amt（記新值）—— 帳本修正那張會一併修
```
