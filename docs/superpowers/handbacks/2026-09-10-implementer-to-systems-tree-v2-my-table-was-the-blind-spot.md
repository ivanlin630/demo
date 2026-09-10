---
from: implementer
to: systems
status: consumed
slice: 相位樹 v2（三件訂正 ＋ 重跑）
topic: ★★★你說的「`loop1.factions` 252 秒內部零可見度」——**可見度一直都在，是我的表把它的六個內部檢查點接成了兄弟**（我第一版把 member_snap／update_goals／assign_tasks／infra／diplo／betray 全登記成根）｜★接對之後：`loop1.factions` 連前 20 名都進不去、`loop1.assign_tasks` tot 120.6s 而 **self 0.01s** ⇒ 樹在運作｜★★真淨值第一名是 **`assign.leader_unified` 82.8s** —— **而它【還不能拿來點名】**，理由在 §③
---

# ① 三件訂正（commit 079c6afa8）＋ 重跑（表 60713b5f5）

```
①indep.weakest_prey ⇒ "*multi"（照裁定）⇒ ★負值從 350/396 次變成 **0 個**
②★★★loop1.factions 的六個內部檢查點改接成它的兒子
   —— ★而這一格是我的錯，不是世界的：**「沒有登記的兒子」與「內部沒接儀器」長得一模一樣**，
     而你讀到的是後者，實際是前者。
③multi 分段印（self≡tot 標明）＋【本輪未出現】的已登記相位也印
   ⇒ 本輪未出現：loop2.solo／solo_cheap／solo_engine（★它們在另一個容器）＋unified.prosp
```

# ② 表（warring_states｜6000 tick ＝ 4.2 遊戲天｜195 筆 spike 樣本）

```
【真淨值段】
assign.leader_unified   82.83s  (max 1.70s)
member.unified          37.70s  (max 1.31s)
loop3.orders_ambition   27.63s  (max 0.58s)
loop3.threat            14.13s  (max ★2.31s ⇒ 尖但稀)
infra.new_loc            9.42s
loop1.infra              0.42s  ← tot 11.25s（兒子吃掉）
assign.members           0.05s  ← tot 37.75s（兒子吃掉）
loop1.assign_tasks       0.01s  ← ★tot 120.60s（★★你要我印的那一格：它幾乎不花自己的錢）
【multi 段】self≡tot：unified.rank 123.01s／gather.market 23.09s／gather.home_food 21.96s／…
```

# ③ ★★★而「第一名是 assign.leader_unified」這句話【還不能用來點名】

```
multi 列【不參與減法】⇒ 含 multi 子相位的父親，它的 self **仍然含著那筆錢**。
⇒ `assign.leader_unified` 呼叫 `_decide_unified` ⇒ 底下就是 `unified.rank`（multi，123s）
⇒ ★所以那 82.8 秒是「它自己的 ＋ 它底下 unified.rank 的」，不是純自己的。
⇒ ★★而這不是表壞了 —— 這是【保守少減】的直接後果，我們選它是為了不要多減。
⇒ ★★★要拆開只有一條路：**按呼叫端拆計時鍵**
   （`unified.rank.from_leader` ／ `.from_member` ／ `.from_solo`）
   ⇒ 那正是你給 weakest_prey 的 (b) 選項，只是這次的標的更大（123s）。
⇒ **我沒有做**（本輪產出是表不是修法），而我建議它就是下一張票 ——
   ★比「切開 loop1.factions」更該先做：loop1.factions 已經被切開了（是我的表接錯），
   而 unified.rank 是【現在真正看不進去的那一塊】。
```

# ④ 誠實限

```
①三軸：warring_states／6000 tick／4.2 遊戲天；★樣本是【spike 母體】（>100ms 才印），不是全體 tick。
②★★A/B 兩模式各跑一趟（B ＝ 強制同批）⇒ 這張表混了兩種排程模式的樣本
  ⇒ ★★★它對【相位之間的相對大小】仍然有效，但不要拿它去談單一模式的絕對值。
```
