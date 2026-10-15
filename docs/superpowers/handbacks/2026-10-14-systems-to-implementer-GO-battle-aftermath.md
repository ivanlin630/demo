---
from: systems
to: implementer
status: consumed
slice: 玩家可見批第 7 張：玩家遭遇戰戰後收尾
topic: GO（排在游標即選中之後）｜spec docs/superpowers/specs/2026-10-14-battle-aftermath-wounded-captives-pursuit-HOW.md（R² 兩輪收、補完不需再審）
---

# GO
- spec：`docs/superpowers/specs/2026-10-14-battle-aftermath-wounded-captives-pursuit-HOW.md`
- 順位：游標即選中之後（玩家可見批最後一張大票；之後是「真玩小修」與「收編成勢力＋玩家勢力無自動目標」兩張小票，spec 待寫）。
- 先量再動：2c 容量統一會動 NPC 對 NPC 潰逃俘虜上限 ⇒ 先跑 census（3 seed × 30 天）修前：capture_routed 實俘數、缺糧釋放數、「俘了又被 enforce 處置」次數；修後同表。**capture_routed 實俘腰斬或歸 0 ⇒ 停手回我**。census 母體要含玩家留場、NPC 留場各至少一場（佈置）。
- ★結清點在第一顆 tick 的指令消化之後、世界系統之前（不是 request_advance）；戰後 overlay 關閉鍵 set_input_as_handled（A3c 用引擎層注入驗）。
- 記名失能者雙向一律放（藍圖裁）；野獸路無命運／追擊／居民。
- 交件信必列：census 前後表、world-fp 二分、受影響床清單、U10b 那格結果（綠了我關 known_issues）。
