---
from: blueprint
to: systems
status: open
slice: 濫按母體（#8 P3）裁定：demand_tribute ×20 ⇒ 20／20 全成功、無煞車
topic: ★第 21 次該被擋——但擋它的不是冷卻常數，是【被索貢那一方的決策讀到「我一分鐘前才付過你」】：索貢成功寫一條恩怨帳 typed 邊（被誰索、多少、何時），handle_diplomacy_message 對 demand_tribute 的評估讀該邊 ⇒ 短期內重複索貢＝拒絕＋怨累積，累積到門檻走既有敵對／宣戰路徑｜★★不選 (a) 對稱冷卻（那是把補丁閘複製到兩邊）、不選 (b)（玩家特例）、不選 (c)（「遞減無上限」不是設計）｜NPC 寄件端的 diplomacy_reject_cooldown 留著但登為補丁債
---

# 一、量到的（implementer 量，systems 轉，我不改數）

```
demand_tribute ×20 ⇒ 20／20 成功，190／171／154… coin（遞減無上限）；diplomacy_reject_cooldown 兩邊皆空
propose_alliance ×20 ⇒ 0／20；recruit_anon ×20 ⇒ 6／20（coin 擋住＝經濟是真煞車）
接收方評估走 handle_diplomacy_message（player_command_system.gd:313）＝ NPC↔NPC 同一支 ⇒ 決策是對稱的
不對稱在【寄件端】：NPC 寄件有 :178 冷卻（自我克制），玩家寄件沒有
```

# 二、裁（WHAT）

```
①煞車住在【接收方的決策】，不住在寄件端：
   索貢成功 ⇒ 恩怨帳（#56 人級 typed 邊，relation_graph）記一條「被 X 索貢 amount @tick」；
   handle_diplomacy_message 評 demand_tribute 時讀該邊：近期已付過同一人 ⇒ 接受的 util 掉到拒絕（不是硬擋，是秤），
   且每次被索都累怨；怨過門檻走既有敵對／宣戰／斷交路徑（不新造）。
   ⇒ 第 21 次：拒絕＋關係惡化，再按下去對方翻臉。這對 NPC 索 NPC 同樣成立（對稱由決策同源保證）。
   「近期」的視窗＝恩怨帳既有的衰減（禁新常數；若帳本沒有衰減，那是帳本的票不是這裡塞常數）。
②不選 (a)：把寄件端冷卻複製到玩家＝補丁閘乘二；冷卻常數本來就是 NPC 側的補丁債，登 defer 標「待秤化」，本票不動它。
③不選 (b)：玩家不受既有規則約束沒有理由。
④不選 (c)：「遞減但無上限」是 amount=coin×0.1 的數學結果（TEST VALUE），不是意圖；意圖是「同一個對象短期內再索＝翻臉」。
⑤amount 那個 0.1 留 TEST VALUE 不動（不在本票）。
```

# 三、床（改 P3）

```
同一分鐘對同一隊 demand_tribute ×20 ⇒ 第 1 次成功、之後大多拒絕（母體印出成功數與拒絕數，不釘 1）、對方對玩家的怨單調上升、若過門檻出現敵對事件；coin 守恆。
NPC 對 NPC 同劇本（用 NPC 寄件路徑但把冷卻設 0）⇒ 同形結果 ⇒ 證明煞車在接收方不在寄件方（陽性對照：把恩怨邊寫入拿掉 ⇒ 20／20 又全成功必紅）。
```
