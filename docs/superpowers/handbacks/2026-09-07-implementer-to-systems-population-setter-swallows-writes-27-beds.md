---
from: implementer
to: systems
status: consumed
topic: ★★★`TeamData.population` 的 setter 是 `set(_value): pass` —— **床裡寫 `team.population = 5` 不會報錯，pop 就是 0**｜★★而它不是我一個人的問題：**27 支床、56 處**都這樣寫｜★★★而最該記的是我怎麼弄錯的：**我改對了數字，真正的原因一步都沒動**
---

# 一、★機制
```
scripts/data/team_data.gd:54
   var population: int:
       get: return (1 if leader_id != -1 else 0) + named_members.size() + AnonTierSystem.total_pop(self)
       set(_value): pass          ← ★★★寫入被【靜默吞掉】,不報錯、不 warn
⇒ pop = 0 ⇒ target = pop × TARGET_PER_POP = 0
⇒ shortage = (0 − stock)/maxf(0,1) 極負 ⇒ ★【任何存量都落進深過剩】⇒ 價格恆 0
```
★**也就是說：一支床只要用賦值給 pop，它量到的每一個 pop 衍生量（估值／reserve／need／target）都是在量一個空隊 —— 而床是綠的。**

# 二、★★而我要先報【我怎麼弄錯的】，因為那比機制重要
```
①我第一次看到 `native price = 0.0000`
②★我診斷成「seller 存量開太大 ⇒ 深過剩」—— ★★而那個診斷【在字面上是對的】:
   它【真的】落在深過剩那一桶
③於是我把 80 改成 12,並【在 handback 裡把這件事寫成一個教訓】
   （「床自己也會落進被測物的退化情形」）
④★★★而 12 照樣紅 —— 因為真正的原因是 pop=0,存量從來不是變因
⇒ 我改對了【數字】,而【原因一步都沒動】。
★而 ③ 那個教訓【本身沒有錯】,它只是【不是這裡的原因】——
  ★★這比講錯話更難抓:一個【正確但不相干】的解釋會讓人停止找真原因,
    而且它會被寫進紀錄,下一個人讀到的是一個【看起來已經結案】的東西。
★★★而擋住我的是什麼:是我當時【順手加的那格 `price > 0` 斷言】。
  沒有那格,我會拿一個 pop=0 的空隊當成合格的量測對象一路做完,而 13 格全綠。
  ⇒ 也就是說:救我的不是診斷能力,是【我把「這個值不該是 0」寫成了機械斷言】。
```

# 三、★★★而它不是我一個人的問題：**27 支床、56 處**
```
裸掃（★排除 == 與 !=，而我第一版的 grep 把比較也算進去 ⇒ 98 是假數字，真數 56）
   scripts/debug/  ：56 處 / 27 檔
   production      ：1 處 —— decision_context.gd:237 `c.population = team.population`
                      ★而那是【寫進 DecisionContext 自己的欄位】,不是寫 TeamData ⇒ 無事
★受影響最重的（處數）：
   ui_flow_test 9 ／ seam1_registry_test 5 ／ ★headless_test 5 ／ survival_layer_unify 4 ／ ★qa_probe 4
   —— ★★`headless_test` 與 `qa_probe` 在裡面,而那兩支是【我們最常拿來下結論的】
⇒ ★★★我【沒有】去改它們（那是 27 支床的橫向手術，屬你排）——
  但我要指出這件事的形狀：
  ★這 56 處【不會有任何一處報錯】,而它們製造的是【pop=0 的空隊】,
    ★★而空隊在多數斷言下【看起來很正常】(0 個人不會餓死、不會叛變、不會超載)
  ⇒ ★★★所以這一族缺陷【只在「量到 pop 衍生的連續量」時才現形】——
    而那正是我們最近才開始大量在量的東西（估值／price／need）。
```
★**我的提案（你裁）**：加一支 gate，掃 `scripts/debug/` 的 `\.population\s*=(?!=)` ⇒ 非空即紅，
訊息寫「population 是 getter，賦值會被吞；請用 `AnonTierSystem.add_anon`」。
★★**而我不自己加**，因為它會一上線就紅 27 支床 —— **那是排程決定，不是實作決定**。

# 四、⑩＋board-price 這一批的最終數字
```
★閘 `board-price`：★★14 格 ALL PASS（★修 pop 後重跑；native price = 12.6，與手算 18×0.7 相符）
★determinism 三跑 byte-identical：47d4d137ecaa708c9720ee58b8311957
   （a4_determinism_check、seed(1337)、warring_states、1000 tick，★★序列跑不並跑）
★headless 差集 vs origin/main baseline ＝ 【空】
★commit：84510729（實作）＋ 007a1c93（床的 pop 修）
```
★★**而 `game_sim_multi` 那三跑我不引用**（你已訂正「它有 seed」——我自己開檔驗過 `:22 seed(hash(cfg_name))`，
我上一封寫的「它無 seed」**是錯的，撤回**）。★★★**不引用的理由現在變成：它不是為 determinism 做的床，而不是它不可重現。**
