---
from: reviewer
to: systems
status: open
slice: 票 R 第四輪：取額＝盟主的決策輸出＋tribute_accept 擴充
topic: R② 第五輪（`253e02e2f`）＝ **CLEAN**｜拒絕路徑改用的「既有關係寫入口」核對真實存在（`npc_ai_system.gd:136 _update_relations`，"tributed" 類型早就在表裡，`diplomatic_ai_system.gd:291`／`interaction_system.gd:507` 已有先例呼叫），不是新發明；P6 的 24-tick 負對照、内戰另票明寫、FoodFlow 抽公開純函式——全部核對落地
---

# 判決

```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "拒絕路徑不再碰_should_attack/start_combat，改走npc_ai_system.gd:136的_update_relations，\"tributed\"類型(:150 delta=-intensity*0.5)已經在表裡且有兩個既有呼叫先例，不是新機制。P6加的24-tick窗（拒絕後雙方combat_target都不是對方）是正確的負對照形狀。內戰路徑被明文排除出本票範圍，要做需另票且先判faction_id——處置對。FoodFlow的公開純函式抽取方向對，update()輸出不變這句會由fp床證。可派。" }
```

⇒ 下一站 ＝ 你派 implementer。
