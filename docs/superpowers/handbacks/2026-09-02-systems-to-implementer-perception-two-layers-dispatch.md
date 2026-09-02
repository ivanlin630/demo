---
from: systems
to: implementer
status: open
slice: perception-two-layers（外觀層 belief 欄位）
topic: ★R② 過(issues 皆解,而 reviewer 給的解法比我 spec 的好):★★current_task【不要做 per-task 查表】——改用真正觀察得到的底層信號當根(combat_target 只在 start_combat 真開打才設,而 TASK_ATTACK 在趕路時就已經是那個值,兩者不同義);★★★訂正我先前對你說錯的一句:erase_teams【有】懸空引用清理迴圈(:558-566 清 combat_target/social_target/order_target_id),我說「沒有任何清理契約」是錯的,它是【不完整】不是【不存在】;★另:我順手把 combat_target 納管 single-writer,而它有一個旁路要你順手改
---

# ★①R② 過 —— **而他給的解法比我 spec 的好，照他的做**
```
★我 spec：current_task → 投影函式（task 列舉 → 外觀類別）
★★他指出：30+ 個 TASK_*，★【每一格都是一次偷渡意圖的機會】
★★★他的解：★不要從 task 列舉出發 —— 用【真正觀察得到的底層信號】當決策樹的根
   血證（我複驗過）：
     npc_combat_system.gd:110-111  start_combat() 裡才 set_combat_target(...)  ←★真的開打才設
     而 current_task == TASK_ATTACK ★在還在趕路時就已經是那個值
   ⇒ ★★兩者【不同義】：一個是「正在打」，一個是「打算打」
⇒ ★★★所以外觀層要讀的是【前者】。★而這比投影表強的地方是：
   你【根本不去讀那個混著意圖的欄位】—— 防線又回到「拿不到」而不是「記得別讀」
```
★**`combat_target` 拆兩欄（`in_combat` ／ `combat_target_est`）reviewer 確認方向對、不建議合併** ⇒ 照拆。
★★**其餘外觀信號同一原則**：找「真的發生了才會變的那個狀態」，**不要找「打算做什麼」的欄位**。
★★★**你找不到對應底層信號的那些外觀類別 ⇒ 歸【不明】** —— 不要為了補滿類別去讀 task。

# ★★②零雜訊：**合法（R② 確認）**，而 RNG 我數錯了
```
★我 spec 只點名 vision_system 的 randi_range(resource_scale)
★★reviewer 查到【兩處】：population_est 的 randf_range 也算
⇒ ★★★所以「新欄位不加雜訊 ⇒ 零額外 RNG 消耗」這個結論不變，
   但【現況耗幾顆】我報少了一顆，你以那兩顆為準
```

# ★★★③訂正我對你說錯的一句話
我上一封寫：「`erase_teams` **沒有任何**『懸空引用清理』契約」。★**錯的。**
```
world_state.gd:558-566（erase_teams 內）：
  「其他隊指向任一 dead tid 的 ref 單趟全清」⇒ 已清 combat_target / social_target / order_target_id
⇒ ★★所以它【有】契約,只是【不完整】(orders 是你今天補上的,relations/relation_edges 仍缺)
⇒ ★★★「不存在」與「不完整」差很多 —— 前者要建制度,後者是補漏。★我說成前者是誇大。
```

# ★④順手要你改一行（★我納管了 `combat_target`）
```
★single-writer 閘現在管兩個欄位（faction_id / combat_target）,白名單已建、陽性對照跑過
★★而 world_state.gd:564 `o.combat_target = -1` 是【旁路】——
   而 :362 的註解白紙黑字寫著「所有 team.combat_target= 直寫改走此/clear_combat_target」
   ⇒ ★★★註解宣稱單寫者，而它不是。今天第三個同形（faction_id / 訂單 owner 驅動 / 這個）
⇒ 改走 `clear_combat_target(o)`（★零行為：setter 就是 assign -1）
   ★改完把白名單那一行拿掉（我留了註記），★★並確認閘仍 PASS
```
