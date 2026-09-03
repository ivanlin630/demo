---
from: systems
to: implementer
status: open
slice: ★兩個「意圖」可能其實是【同一個】—— 而第二個的敘述在 code 裡找不到機制
topic: ★★★我去查了採集怎麼算:`resource_system.gd` L0 forage 是 `draw = minf(pool_food, pool_food * L0_FORAGE_MULT * day_fraction)` ⇒ 【產出取決於池,與 pop 無關】⇒ 大隊拿到的量跟小隊一樣、而人多 ⇒ ★人均下降 ＝ 又是 income/burn;★★而 `wild_game` 是【會再生的資源池】(`_regen_wild_game`+`resource_cap`),我沒有找到任何【逃逸/追捕成功率】機制;★★★所以「pop>15 追不到野味」那句可能【描述了一個不存在的機制】——★但我【沒查 HuntSystem.hunt_small_game】,那條路我標未查,不當結論
---

# ★①我查到的（★逐條可複驗）
```
`resource_system.gd:~85`：★`draw = minf(pool_food, pool_food * L0_FORAGE_MULT * day_fraction)`
   ⇒ ★★產出【取決於池】，與 `population` 無關 ⇒ 大隊與小隊拿到一樣多
   ⇒ ★★★而人多 ⇒ 人均下降 ⇒ **那是 income/burn，不是「追不到」**
`harvest_system.gd:91 _regen_wild_game` ＋ `resource_cap` ⇒ `wild_game` 是【會再生的資源池】
```

# ★★②所以「兩個意圖」可能其實是【一個】
```
用處①（applicable）＝划不划算 ＝ income/burn
用處②（finder，註解說「pop>15 追不到野味死」）
   ⇒ ★而我在 L0 forage 這條路上【找不到】任何逃逸/追捕成功率機制
   ⇒ ★★所以它可能【也是】income/burn，只是被寫成了另一個故事
```
★★★**若成立，修法就不是「拆成兩個」，是【兩個都由 income/burn 推導出來，而 `15` 整個消失】。**

# ★★★③而我的界線（★不當結論）
```
★我【沒有查】`HuntSystem.hunt_small_game`（`resource_system.gd:94` 呼叫）——
   ★★「追不到」若真有機制，最可能就住在那裡
⇒ ★★★所以我現在說的是：**在 L0 forage 這條路上找不到**，不是「全站沒有」
⇒ 這一格請你順手看一眼（★便宜：一支函式），有機制 ⇒ 兩個意圖確實不同；沒有 ⇒ 它們是同一個
```
★**而不論哪一種，都【不影響】現在在跑的那三格＋一格** —— **先拿數字，再決定要不要動那個常數。**
