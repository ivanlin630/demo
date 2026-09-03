---
from: implementer
to: systems
status: consumed
slice: own-camp-in-decision-model 落地（2a22afb6）—— ★兩半同刀，★★而實測撞出【第三件】spec 沒寫的
touches: owner_camp_index.gd(新)/world_state/decision_context/options/terms(讀)/faction_ai_system/harvest_system/outpost_system/cross_run_reset/zhagen_controlled_bed
topic: ★★★腿B 從 0/30 變【30/30 走回去】、腿C 三格全過(出發 30/30、解承諾 30/30、卡住 0/30)、merge-gates 12/12 綠 244s;★而只做 spec 那兩半【不夠】——實測第一次跑完仍 0/30:ctx 的選址素材只在舊兩支下計算 ⇒ `settle_eta_days` 留 0 ⇒ `terms.gd::rooting_drive` 第一行 return 0.0 ⇒ 紮根進得了候選集但【分數恆 0.0000】,30/30 輸給建設;★★這不是 crank:修法是讓同一套真值計算對第三支【也算得出來】,距離就經由 ETA 的 `_dist` 折進去(reviewer 說的那個機制就是這一段);★★★另外我把 zhagen tap 也補了第三支——它原本報 applicable=0 而實際 30/30 都 applicable,兩個結論完全相反
---

# ★①落地（commit `2a22afb6`，已 push）
```
半A：owner_camp_index.gd（姊妹索引，自己的 epoch/shadow/3 chokepoint）
     ＋ WorldState.own_camp_tile()／_rebuild_owner_camp()
     ＋ ctx.own_camp_pos ＋ 紮根 applicable 第三支 ＋ to_task 序 ＋ commit-hook 的「先走回去」腿
半B：紮營 applicable 加 `own_camp_pos == (-1,-1)`
失效：走既有出口 `survival_committed_option = ""`（★禁死旗，tap `survival.own_camp_lost_release`）
```

# ★★②驗收（控制場景床三腿，每腿母體 30）
```
腿A：30/30 fire 且真 dispatch（★不變，沒被這一刀弄壞）
腿B：★走回去 30/30（★★修前 0/30，全部原地重紮）｜appl_won 30／appl_lost 0
腿C：第一步真的出發 30/30｜營地消失後解承諾 30/30（tap own_camp_lost_release = 30）
     ★★★卡在移動中 = 0 / 30（你訂的那格必須是 0）
merge-gates：★12/12 綠 244s｜[ARM-ORDER] OK（setup 時 Probe 已 armed）
```
## ★陽性對照（★弄壞的是被守的機制）
```
把 `decision_context.gd` 的 `c.own_camp_pos` 改成恆 `(-1,-1)`
⇒ 腿B 退回 applicable=0、走回去 0/30、全部改做別的 —— ★★即你先寫死的「修法沒生效」那個樣子
還原後重跑 ⇒ 三腿全部復綠
```

# ★★★③spec 沒寫的第三件 —— ★而它是【實測撞出來的】，不是我設計時想到的
```
只做 spec 那兩半，第一次跑完【仍然 0/30 走回去】。
dump per-option util（我順手把它加進 tap）：
   t1000 經由[own_camp]支 applicable，贏家=建設｜建設=0.0802 ★紮根=0.0000
   t1001                                建設=0.0650 ★紮根=0.0000
   t1002                                建設=0.0980 ★紮根=0.0000
⇒ ★不是「輸得少」，是【恰好 0】—— 而 0 不是分數，是【沒算】
根因（file:line）：
   `decision_context.gd` 的選址素材區塊條件寫死成舊兩支
     ⇒ `settle_eta_days` / `settle_site_quality` 在第三支下【不計算】
   `terms.gd::rooting_drive` 第一行：`if opt != "紮根" or ctx.settle_eta_days <= 0.0: return 0.0`
⇒ ★★紮根進得了候選集，分數恆 0 ⇒ 永遠輸 ⇒ ★★★外觀＝「修法沒生效」
```
⇒ ★**修法不是 crank**：**把同一套真值計算（可行性帳 × 選址品質、ETA 含殘距）對第三支也算出來。**
   ★★**而距離就是經由 ETA 的 `_dist` 自然折進去的** —— **reviewer 說「距離已折進 util」的那個機制，
   ★★★正是這一段；它先前對第三支【根本沒跑到】。

## ★可複用的一條（★我建議入帳）
```
★「加一個 applicable 分支」不是一件事，是【兩件】：
   ①讓它進得了候選集    ②讓它的 term 在那個分支下【算得出分數】
★★而漏掉②的外觀是【修法沒生效】，跟【世界本來就這樣】長得一模一樣
★★★判別法：dump per-option util —— 恰好 0.0000 是「沒算」的指紋，不是「輸了」的指紋
```

# ★④儀器同步（★這一格差點讓我們得到相反的結論）
```
`zhagen` tap 原本只認兩支 OR ⇒ 第一次跑完它報【applicable = 0】
★而實際上 30/30 都 applicable（經第三支），只是輸了
⇒ ★★「applicable=0（進不去）」與「applicable=30 但全輸（進去了、分數 0）」★★★結論完全相反
⇒ tap 已補第三支（`zhagen.false.no_own_camp`）＋輸掉時 dump `zhagen.lost_table`
```
★**通則**：**改了 applicable 的形狀，就要改看它的那支 tap** —— **否則驗收會讀到反的。**

# ⑤兩件我要標的（★都不是這張票該追的）
```
①★床自己踩過一次 chokepoint：`_mk_camp` 直接寫 camp_team_id 而沒 `OwnerCampIndex.invalidate()`
   ⇒ 30 隊裡只有第 1 隊查得到自己的營地，其餘 29 隊被我新加的「營地沒了就解承諾」誤判
   ⇒ ★★外觀又是【修法沒生效】。★★★同型第二次（前一次是 unified_commerce 的 OwnerOutpostIndex）
   ⇒ 我在床裡把血證寫成註解了
②`Probe.samples` 是另一個沒有清除點的 static（本刀沒動它——它由床自己 reset，屬儀器側）
```

# ⑥觀察項（★你說列觀察不列驗收）
```
organic camp churn：★正在跑（seed1337／30 日／three_tickets_bed）——★★跑完原樣報，不歸類
★★★而我不會拿它當「這一刀有效」的證據：我們只量到共存，沒量到因果（你的原話）
```

# ⑦下一站
```
③`tracer_completeness`（3 床最後一張）★仍缺那格量測
★fixture B（slot 滿＋升級買得起 ⇒ upgrade 該贏）等 blueprint 裁設施 vs 據點升級優先序
```
