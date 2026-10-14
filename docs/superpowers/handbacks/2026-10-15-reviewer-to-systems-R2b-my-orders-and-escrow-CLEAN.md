---
from: reviewer
to: systems
status: open
slice: 我的掛單與押貨 第二輪（main 0b18d384e）
topic: R② 第二輪 ＝ **CLEAN**（一條床的註記，不擋 dispatch）｜M1–M3 與同版小項我都對過 spec 的實際文字，不是信的轉述
---

# 核對（對 spec diff b5d0a9253..0b18d384e）
```
✓ M1 判斷式＝owner_team == get_player_team_id()，寫明不用 .possessed 與原因（:1119 先於 :1120）；goods_claimed 同一式、放在建 dict 之前；owner 取 escrow／claim 條目的 owner_team（release_order_escrow 的 o 沒有隊欄位，這樣取是對的）。
   P1 明寫走真實 sync_possession 邊；n4（改回 .possessed ⇒ P1 事件格紅）是有效的注入式負對照。
✓ M2 E4 改看 pending_rethink、E5 同勢力 NPC 零則、n1 該紅欄改 E4＋E5。E5 在拿掉判斷時會因 _player_perceives ② 放行而出一則 ⇒ n1 在 E5 上真的會紅。
✓ M3 per-res 累積、款以 coin 為鍵、函式尾一則、兩格兩則不折疊；E3 單格佈置糧＋錢、斷言恰一則與兩種量。
✓ why 必填無預設；索引後路拿掉只記時間；payload 只放絕對 tick；檔頭 :55 同步改＋gate-ok；兩個新 kind 進 FUNC_KINDS＋KIND_LABEL＋describe；原因字中性；「起」＝最早一筆；CAP 改 8 個不同 (格,種類,資源)；E1 佈置避開同資源待領；範圍外兩條（款落格不發事件、附身連玩家自己的單一起撤）。
```

# 一條床的註記（實作端留意，不必改 spec 結構）
```
E4 的讀取時點：pending_rethink 在 tick 尾被 consume_and_clear 清空（world_events.gd:285-315），且同一 tick 內任何其他事件（戰鬥、饑荒…）都可能標到同一支 NPC 隊。
   · 「同 tick 內不含該 NPC 隊」若跑完整個 tick 再讀，讀到的是空的（綠得太容易，n1 也不會紅）；若有無關喚醒源，則會假紅。
   ⇒ 床的做法：佈置乾淨（pending_rethink.clear()）後【直接呼 OrderSystem.tick_team_orders】或 release_order_escrow，【當場】讀 pending_rethink；
     n1（拿掉判斷）時同一步必須讀到該隊被標，否則 E4 沒有咬到東西。交件信貼 n1 的實際紅燈輸出。
```

# 判決
```
verdict: CLEAN
dispatch 可進行；E4 的讀取時點交給實作端按上面做，交件信印出 n1／n4 的紅燈。
```
