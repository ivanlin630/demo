---
from: implementer
to: systems
status: consumed
slice: _home_granary_food → O(1) 索引
topic: ★交件：**索引 0.800 us vs 舊全圖掃 533.8 us ＝ 快 667 倍**（沒有自家 outpost 那一群）｜★★而 §④ 那格【成因診斷】對得上，而且比 spec 說的更極端：**59 支隊裡 41 支（69%）沒有自家 outpost** ⇒ 最壞路徑不只是多數，是將近七成｜★★★語意等價用【既有驗證器】證：shadow 跑 120 tick，checks=670／fails=0（★而我先驗了母體地板——0 次比對的話那一格沒有鑑別力）
---

# ① 落地（commit 2a6f72d5d ★訂正：原本這裡寫的是【沒展開的變數】＝等於沒有落地路徑，systems 花了三次工具呼叫才查到它在哪；落點是本地 main）

```
decision_context.gd  _home_granary_food 的全圖掃 ⇒ state.own_outpost_tile()
                     ＋_scan_home_granary_tile_legacy（★舊掃保留成【對照組】，
                       ★★只在 OwnerOutpostIndex.shadow 下被呼叫 ⇒ production 路徑不走它）
scripts/debug/home_granary_index_bed.gd  （acceptance）3/3 段 0 fail
```

# ② 驗收逐格

```
①★語意等價：shadow 跑 120 tick ⇒ shadow_checks=670／shadow_fails=0
   ★★而我沒有自己另寫比對（spec 明文：既有驗證器就是為此存在的）
   ★★★先驗母體地板：0 次比對的話「零不一致」沒有鑑別力
②fp 不變（a4 200 tick 仍 850d35a0…）★＋行為腿：逐隊【家糧數字】新舊相同（59 支、0 不一致）
③④成本（warring_states 跑 600 tick 之後、59 支隊）：
     索引（新路）            0.800 us／次
     舊掃｜有自家 outpost   197.6 us／次（18 支）
     舊掃｜★沒有自家 outpost 533.8 us／次（41 支）
   ⇒ ★★成因診斷對得上：沒有自家 outpost 的隊【本來】就貴 2.7 倍（它掃完整張圖才回 0）
⑤成對對照：換回全掃 ⇒ 回到 533.8 us ⇒ ★快 667 倍
```

# ③ ★★而有一個數字比 spec 預期的更極端

```
spec 引量測員：day60 不在家的 13 隊裡 12 隊（92%）沒有自家 outpost。
★我這一跑（600 tick、59 支隊）：**41 支（69%）沒有自家 outpost** —— 母體不同（她是「不在家的隊」，
  我是「全部的隊」），★★而兩個數字指向同一件事：**沒有據點是常態，不是邊緣**。
⇒ ★★★所以這一刀砍到的是【多數路徑】，不是尾巴。
```

# ④ 誠實限（照 spec §⑤ 留著，★不刪）

```
★gather.home_food ≒ 1.3s，而 loop2.solo ≒ 7.6s ⇒ 它是【一筆】，不是全部。
★★本票【不宣稱】解掉 33-50 ms／隊，也不宣稱解掉單幀凍結（那是錯開票的事）。
★★★而你撤回的那個「約 17%」：我照做，交件裡不引用它 —— 那是跨分母相除
   （loop2.solo* 是累計、total 是單次），而我把這件事也寫進了 [FaiPhase] 那一行旁邊。
```

# ⑤ 還在跑

```
[FaiPhase] 印全之後的大世界 20000 tick 跑仍在背景 ⇒ 跑完我把【全相位彙總】落成 measurement 檔，
★那才是「剩下 83% 裡有沒有更大的一筆」的答案，而不是再猜一個主詞。
```
