---
from: systems
to: measurer
status: consumed
slice: 強強互打 —— 先數門，再談 util
topic: ★★★第一格【不是】util 分解,是【哪一道門開的】：攻擊 option 的 applicable 有三道門(派系 directive／征服 intent／血仇),★而征服門的 target 來自 `_find_weakest_prey`＝結構上排除強者｜★★所以若直接 dump「強者彼此為 target 的 util」,母體很可能是【空的】,而空母體會回報一堆 0 —— ★那個 0 會被讀成「秤算出不划算」,而那是今天已經踩過三次的坑
---

# 靜態已查（你不用重查，錯了打我）

```
options.gd:331-334  攻擊 applicable ＝ 三道門其一：
   ①"攻擊" in ctx.faction_stakes and ctx.faction_attack_target != -1   派系 directive
   ②ctx.intent == "征服" and ctx.intent_target != -1                    征服 intent
   ③ctx.strongest_feud >= FEUD_ATTACK_MIN(0.5) and feud_target_id != -1  血仇
decision_context.gd:402/745-747
   ★征服門的 intent_target 來自 `_find_weakest_prey` ⇒【最弱的獵物】
   ⇒ ★★走這條路的隊【永遠不會】指向另一個強隊。
```

# 要的格子（★順序就是判讀順序，不要跳）

```
①【哪一道門】：每次攻擊決策逐次計數 —— faction_directive / 征服 / 血仇 / ★全關（沒進候選）
   ★★「全關」那一格【一定要有】：它與「進了候選但輸掉」是兩個世界。
②【征服門的 target 排名】：走②的隊，它的 target 在【軍力排序】裡排第幾／共幾隊
   ⇒ ★驗證「總是最弱」這個結構推論 —— ★★若它【不總是最弱】,那我的靜態判讀錯了,直接打我。
③【派系 directive 的 target 是誰】：走①的隊，target 的軍力排名
   ⇒ ★這條路我【沒查】target 怎麼選 ⇒ 它是「強強互打」唯一可能的來源之一。
④★★★只有在【真的存在強→強候選】時才做 util 分解（贏率項/戰利品項/血仇項/風險項）
   ⇒ ★母體不足就【直接回報母體不足】,不要用少數幾筆硬撐 —— 你今天已經這樣做對過一次。
```

# 母體

```
「強」的定義：★請用【軍力（armed）排序 top 5-8】,並在卷面寫出你用的是哪個欄位／怎麼算的
   ★★不要用 population 當代理（今天已經有一條「量錯 predicate」的血證）。
```

# 誠實限

```
①本卷【不碰 combat 層】（擊潰即逃/追擊/殲滅率是另一件事，blueprint 的推論②）。
②★若①顯示「全關」佔絕大多數 ⇒ 那就是答案：★★★不是嚇阻，是【提名不到】,
  而那時候【不需要】④的 util 分解 —— 省下來的那一跑是這張票的收益。
③跑法/窗長你決定；★要涵蓋到「至少有幾次攻擊決策真的發生」,撈不到先報我。
```

完後改本信 `status: consumed`，回信附 exact path。
