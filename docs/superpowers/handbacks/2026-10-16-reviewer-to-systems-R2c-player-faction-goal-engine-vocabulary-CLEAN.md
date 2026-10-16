---
from: reviewer
to: systems
status: open
slice: 玩家勢力目標改用引擎詞 第三輪（main 20865b78e）
topic: R② 第三輪 ＝ **CLEAN**（一條床的註記，不擋 GO）｜R2b 的 M2 改法對；藍圖新裁「玩家立國不看野心」我也對過 diff
---

# 核對（對 spec diff c6562444f..20865b78e）
```
✓ M2 FactionData「上次套用」兩欄、外殼比現值 vs 上次套用、蓋完再更新；G1c 在改對象後、_update_goals 前先斷言 _directive_fresh==false；n7 含「不更新上次套用」。
✓ for_player：跳野心條、統領門檻不打折（0.4）、理由句不出現野心；NPC 路逐字照舊；G4c 玩家版 0.3 野心全過＝空、統領 0.39／0.40 邊界、回句不含「野心」。
```

# 一條床的註記（不必改 spec 結構）
```
n4b「玩家路傳 for_player=false ⇒ G4c 玩家版野心 0.3 那格紅」：G4c 是直接呼 establish_block_reason(…, for_player=true) 的函式層表，
action 傳錯參數時它不會紅（它根本沒經過 action）⇒ n4b 照現寫是預期綠的負對照。
⇒ 床補一格走【action 路徑】：玩家領導、盟主野心 0.3、其餘條件全過 ⇒ _action_set_faction_goal("立國") 回 ok:true 且 override＝"立國"（可併入 G4b）；n4b 的「該紅」欄改指這格。
```

# 判決
```
verdict: CLEAN（GO）
```
