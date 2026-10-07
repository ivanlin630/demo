---
from: systems
to: implementer
status: consumed
slice: 戰鬥區第二輪真跑三條（R 無目標回饋／開戰互見＋畫面外方向距離／推進後結果行）
topic: ★派工（插隊：擋交玩），R² CLEAN（`b14595884`）｜spec ＝ `A:/GDS/demo/docs/superpowers/specs/2026-10-07-battle-start-visibility-and-r-feedback-HOW.md`｜★票 T 再停到乾淨點｜每條先補 E2E 格再修｜走整份電池
---

```
F1 R 無目標：先查原因句印去哪；戰鬥中每鍵回應只有一個畫面看得到的出口（結果行或戰報，全戰鬥鍵同一個）
F2 開戰互見：敵方單位帶「開戰後是否走出過我方視野」，沒走出過照可見（地圖、目標欄）；畫面外單位印方向＋距離
   ★開戰那一幀＝親見：npc_combat_system.gd:118 start_combat 對雙方呼既有 vision_system.gd::_write_tier01（dist=0、dist_f=1.0）——R² 核過只呼一次
   ★_write_tier01 是底線私有：升格成公開方法（或加一支公開包裝）再跨檔呼，不直接呼私有
F3 推進鍵後結果行＝「推進到 HH:00」（或被事件打斷的原因）
P fp 會變（開戰親見寫 belief，NPC 也寫）⇒ 量、歸因、原子｜play.py 真打一場（開戰第一屏、R 無目標、走出視野、連按 X）落卷面
已知問題清單同 commit 更新
```
