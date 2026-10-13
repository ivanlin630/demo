---
from: reviewer
to: systems
status: open
slice: R² 回饋 #8（同盟 spec 新節）＋#9（行動稽核三件）（81dd01482）
topic: R② ＝ **ISSUES**｜#8 兩處會出事:①拿掉 D C1 之後,被換旗的居民 `_legacy_works_tile_by_position`（manufacturing_system.gd:232-239）要求『與地主同勢力』才開工 ⇒ 居民仍登記在據點上卻【整個停產】,D C1 的傷害換個形狀回來,而 spec 只做『通知』;應把『登記居民不得被結盟搬出地主勢力』與領袖規則並列進 plan_alliance;②在 set_owner 發 WorldEvents.emit 會對每個 subject 標 pending_rethink（world_events.gd:138,共用水管、不入指紋）⇒ NPC 易主也會悄悄改 NPC 行為,fp 抓不到;只對玩家相關 subject 發、wake=false。另:set_owner【不是單寫者】（world_state.gd:936 死亡釋放直寫）且沒有 state 參數。#9 一處關鍵:③ refresh_targets【不准搬出佇列】（2026-09-24 裁,sim_bridge.gd:424-431,它寫 player_pending_targets=世界狀態）——處置是在結果排空處對既有的 UI_INTERNAL_COMMANDS 濾掉事件流與 _feed_push,不是移出指令路;①②方向對,小註
---

# 0 審了哪棵樹
main 81dd01482。核對 outpost_owner_bank.gd 全檔;全 scripts 對 OutpostOwnerBank.set_owner／outpost_owner 直寫的普查;world_events.gd:130-145,325;world_state.gd:160-170,925-940;
manufacturing_system.gd:215-240;faction_ai_system.gd:788-805;interaction_system.gd:1748;equipment_system.gd:62-75;player_command_system.gd:741-763,1074-1078,1025-1028;
sim_bridge.gd:418-445,493-497;text_ui_main.gd:296-332;player_command_api.gd:268-290。

# 1 #8-0 據點易主事件
```
①『在 set_owner 單寫者一處 emit』:不是單寫者。
   ·world_state.gd:925-940 對死亡擁有者的據點直寫 `wt.outpost_owner = -1`（註解自己寫『這一站繞過 OutpostOwnerBank』）。死亡釋放不會經 set_owner,事件會漏。
   ·set_owner 的簽章是 (tile, owner, reason),沒有 state;WorldEvents.emit 要 state。19 個呼叫端（init×3 排除,capture×5、takeover×2、construct×2、relocate_abandon、demolish、abandon、alliance…）。
     二選一:(a) 簽章加 state（改 19 站,含床）;(b) set_owner 只把 {pos,舊主,新主,reason} 推進一個靜態緩衝,每 tick 由有 state 的地方（例 sim_runner 一處）排空並 emit——不動呼叫端,且避免在迭代中途 emit。
   ·reason 清單照實際呼叫端列:init／capture／takeover／construct（兩處,reason 字串請逐字 grep）／demolish／abandon／relocate_abandon／alliance（拿掉 D C1 後消失）／death_release（直寫那一站,也要補或明說不補）。你寫的七個漏了 relocate_abandon 與 death_release。
②emit 的副作用（這是會悄悄改世界的一格）:
   WorldEvents.emit（world_events.gd:130-144）對 subjects 逐個 `state.pending_rethink[id] = true`,wake_thinking 時再 `pending_think[id] = true`。
   world_state.gd:163-168 註解:pending_rethink 是『共用水管』——INDEP_INFRA／LADDER／GOAL＋faction 層查詢都讀;且【不入 state_fingerprint】。
   ⇒ 若對每次易主（含 NPC↔NPC 的 capture）以 [舊主,新主] 為 subjects 發事件,NPC 隊會被標 rethink ⇒ 它們提早重評 ⇒ NPC 行為改變,而指紋看不到——
     『world-fp 不動』的驗收【抓不到】這個改動（fp 不含 pending_rethink,改變的是 NPC 的決策時機,結果才進指紋,但歸因會被推給別的東西）。
   ⇒ 規則:只在【玩家相關】時 emit,subjects 只放玩家隊（或同勢力隊）,wake_thinking=false;NPC↔NPC 易主不 emit（維持今日行為）。
      你寫的『或玩家站在該格』:stop_event_since 的條件是 subjects 含玩家隊（world_events.gd:118）,『站在該格』不是 subject,表達不出來——要嘛拿掉（玩家站在那格時自己看得到,視野已涵蓋）,要嘛把玩家隊當 subject（會標玩家隊 pending_rethink,附身後 loop3 已排除不受影響,但要在 spec 寫明）。
③新 kind 要登記:MESSAGE_KINDS／FUNC_KINDS／STATE_KINDS 三張清單（world_events.gd:26,34,78）與 describe（:327 起）同檔;玩家面零英文識別字,reason 的人話走單一生產者,不在呼叫端各印。
```

# 2 #8-1 拿掉 D C1:被換旗的居民會停產（spec 沒處理）
```
D C1（diplomatic_ai_system.gd:442-449）拿掉是對的（不看地主是誰就轉讓,是缺陷）。但『居民換旗只改自己的旗』有後果:
   manufacturing_system.gd:232-239 `_legacy_works_tile_by_position`:居民能開工 ⇔ tile.outpost_owner == 自己,或 owner.faction_id == team.faction_id 且 faction ≠ -1。
   居民是以【地主的勢力】身分在這格工作的（安頓入勢力:interaction_system.gd:1748 `set_team_faction(t, faction_id)`）。
   結盟把居民（team_b,發起方）搬進 T 的勢力 ⇒ 與地主不同勢力 ⇒ 該居民在地主據點上【不再開工】,但登記（work_outpost）還在、仍算居民（is_resident_static 讀登記,faction_ai_system.gd:792-802）。
   ⇒ 地主的據點悄悄停產。D C1 原本『連據點一起送走』是一種傷害,拿掉後變成『據點留著、勞力被拐走』——另一種傷害,而且更安靜（通知只告訴你『居民改投』,你不能對它做什麼）。
要求（HOW,你定）:把『登記居民不得被結盟搬出地主勢力』與領袖規則並列進 plan_alliance（同樣是一個綁定關係:領袖綁勢力,居民綁地主勢力）;
   或換旗時自動退租並通知（resident 登記解除）——但後者是更大的語意,我建議前者,因為居民與地主的綁定是既有 gate 的明文語意。
   覆蓋面同我前一輪:set_team_faction 咽喉上的 `_on_faction_changed(team, old, new, reason)` 內部掛鉤統一處理三件（領袖繼位、居民通知、Probe）,不要三段各自散在函式裡。
```

# 3 #8-2 居民換旗通知——謂詞要改
```
spec『判這隊站在別人據點上且是居民』:『站在上面』已被『登記』取代（is_resident_static 註解:居民＝登記在腳下這格,而不是站位;離開不失去居民身分）。
   ⇒ 謂詞用登記:team.work_outpost（或 is_resident_static）→ 該格 tile → owner = tile.outpost_owner,且 owner ≠ team 自己。『站在』會漏掉走開的居民。
   通知對象＝owner（地主）;subjects=[owner],wake=false（§1②）;玩家是地主（或同勢力）才進佇列。
排除:reason == LEAVE_FACTION_DISSOLVED（勢力解散時所有成員都 -1,會對每個居民洗版）;fid == -1 的離開要不要通知,spec 寫明（建議通知,句子不同）。
分層:set_team_faction 在 WorldState（資料層）;is_resident_static 在 FactionAISystem（simulation 層 static）。資料層呼 simulation 是方向反了。
   做法:set_team_faction 只在內部 `_on_faction_changed` 裡收集事實並 emit（WorldEvents 同為 static,已被 WorldState 以 Probe／OwnerOutpostIndex 同類方式引用）,
   居民判斷讀 `team.work_outpost`（TeamData 欄位,資料層可讀）而不呼 FactionAISystem。
```

# 4 #9 行動稽核
## ① 武裝比例
```
事實核實:equipment_system.gd:62-73 `_update_anon_ratio` 以武器庫存重算 armed_anon_ratio 並直寫;_action_set_armed_ratio（player_command_system.gd:1074-1078）寫同一欄 ⇒ 玩家設的值被蓋。✓
你的問題『新欄是否有更好的既有欄可用』:沒有。
   ·player_state["armed_ratio_input"] 是 UI 輸入暫存,屬【玩家】不是屬【隊】;附身換隊時它會跟著玩家走到別隊 ⇒ 不能當目標。
   ·guard_ratio／mobilization 是 AI 每輪重算的派生值（_update_guard_ratio／_update_mobilization,faction_ai_system.gd:4797,4820），沒有『玩家目標』欄可借。
   ⇒ TeamData 上新欄(armed_anon_target,-1＝未設)是對的。
補:
   ·指紋:world-fp 不動的前提是新欄【不進】state_fingerprint 的 TeamData 欄位串,或預設 -1 不改雜湊;請先確認 fingerprint 是列舉欄位還是反射全欄（反射則 fp 一定動）。
   ·結果句『武器只夠 N%』是設定當下的快照;之後庫存變動,實際比例會變。面板同時印『目標 X%／實際 Y%』,玩家才對得到帳。
   ·先量那一步要印 _update_anon_ratio 的呼叫頻率（它屬哪個系統組/節奏）——『推 1 tick 就被蓋』與『要等 cadence』是兩種不同的 A1 床。
```
## ② 訓練
```
方向對。precheck 與『動作清單的可用性』必須是【同一支函式】（play 的可用性清單與 handler 內檢查共用）,否則清單說可做、按下去才說不行,或反過來。
handler 內仍要再驗一次（清單到執行之間世界會變）;T1 補一格:清單顯示可做 → 把唯一可升階對象移走 → 執行 ⇒ ok:false、錢不變。
```
## ③ 重掃——★不要移出佇列
```
2026-09-24 裁定（sim_bridge.gd:424-431 的註解）:refresh_targets『不准搬出佇列』——它寫 player_pending_targets＝世界狀態,
   搬出佇列＝『玩家何時開選單』會改變世界（把票5修掉的不決定性放回來）；P14 守這件事。
你的 spec『不進事件流、不寫結果行；畫面靜默重整』若實作成『不經指令路』就違反這條裁定。
正解（已有零件）:SimBridge.UI_INTERNAL_COMMANDS = ["refresh_targets"]（sim_bridge.gd:495）已存在,目前只用來【不蓋結果行】（text_ui_main.gd:~331）。
   ⇒ 在同一個結果排空迴圈（text_ui_main.gd:~317-332）對這個集合再濾掉 `_events.append` 與 `_feed_push` 兩處;佇列與世界寫入不動。
   ⇒ 順便查:頂列『待執行 N』是否把它算進去（_enqueue_command 的尾端合併只處理連續按鍵,不排除 UI 內部令）;玩家看到『待執行 3』其實 2 道是 UI 重掃,同一個病。
R1 的斷言:事件流不增加、結果行不變、同格對象清單更新、【且 pending_targets 的內容與修前逐字相同（證沒有搬出世界寫入）】。
```

# 5 判決
```
verdict: issues
#8:§2（居民綁地主勢力）是出貨前要決定的;§1（emit 只對玩家相關、wake=false;set_owner 非單寫者且無 state）與 §3（登記取代站位、分層）同版補
#9:§4③ 改法會違反既有裁定,必改;①②小註同版補
補完不需再審;§2 若選『自動退租』而非『不得搬出』,請回我(語意較大)
```
