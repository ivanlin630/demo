---
from: systems
to: implementer
status: open
slice: C1 票① agent 動詞補課（player_reachable: yes）
topic: ★DISPATCH（用戶裁「由我玩」＋R² CLEAN）｜★★★三個【R² 查出來、我原本會弄錯】的重點:①事件流【已經有函式,只接了 GUI 沒接 agent】—— 併入本票 ②撤單要先抽函式,而抽的時候【只包 escrow-release】,`FailureMemory.record` 不能共用（玩家撤單≠失敗,共用會讓 AI 折價自己下一輪）③附身語意 R² 已查完寫死（`state.player_id` 是唯一開關）
---

# 開票：`docs/superpowers/specs/2026-09-10-agent-verbs-c1-ticket1-HOW.md`

用戶要**親手玩**，並追加「**UI 需有所有資訊，否則又像之前一樣我會很沮喪**」。
★**範圍釘死在 agent/REPL 層** —— GUI 五分頁與文字版走查是**票②**，**別讓票①長大**。

# ① 做什麼

```
①市場四件套：看板 / 掛買單 / 掛賣單 / 撤單   ★接既有 order_system，不要新寫市場邏輯
②附身 / 離身                                 ★語意已寫死（見③）
③時間控制                                     ★不在 sim_runner 加狀態，推進留呼叫端
④每個動詞【一條自檢腳本】                     ★斷言【世界真的變了】,不是「呼叫沒報錯」
⑤★★事件流 wrapper（R² 併入本票，見下）
⑥★★★資訊完整性對帳表（用戶追加，落地成檔案）
```

# ② ★★撤單的陷阱（R² 點名，我寫死在票裡）

```
現況：★沒有 cancel_order／remove_order；移除/過期邏輯【內嵌在 tick_team_orders(:191-230) 的迴圈裡】
⇒ 第一步是【把那段抽成獨立函式】(過期迴圈與手動撤單都呼叫它)
★★★而抽的時候：
   :204-220  escrow 釋放進 pending_claims        ← ★【必須共用】(不共用＝貨瞬移,違守恆)
   :225-227  FailureMemory.record("order_abandoned_buy") ← ★★【不能共用】
⇒ 過期＝執行失敗（該折價）；★主動撤單＝玩家的決定（不是失敗）
⇒ ★★★原樣搬過去共用的話,【玩家取消自己的訂單,會讓 AI 以為這條路失敗了而折價下一輪決策】。
⇒ 共用函式【只包 escrow-release】；`FailureMemory.record` 留在過期迴圈自己的分支。
```

# ③ 附身語意（R² 查完，不用你猜）

```
world_state.gd:101  var player_id: int = -1                    ← ★唯一開關
world_state.gd:752  控制隊由 player_id 【反查】(leader 或具名成員都算)
⇒ 附身 ＝ 設 state.player_id 為目標人物 id ／ 離身 ＝ 還原成【附身前記下的那個】
★不發明第三種語意。
```

# ④ ★★★事件流：機制蓋好了，只接了 GUI（P9 病歷的活教材）

```
player_api_mapper.gd:792   map_global_messages(state, n := 10)
唯一呼叫點 ui/sim_bridge.gd:154   ← ★GUI 在用
player_query_api.gd 裡      ★★零呼叫    ← agent/REPL 層完全碰不到
⇒ ★★★補一支【薄 wrapper】（形狀同 get_storage_panel／query_outpost_panel）,併入本票不另開。
```

# ⑤ 資訊完整性對帳表：★兩個【各自可驗證】的斷言，不要合成一份

```
①`DecisionContext` 的 119 個 var 欄位 × 玩家讀不讀得到 ⇒ 逐格打勾（★119 列全在）
   對照面是【公開查詢動詞 14 支】（★R² 訂正：18 個 func 裡 4 個是私有輔助）
②★★另一個獨立小節：「§5 邊界文字裡明列、但【不對應任何 ctx 欄位】的項目」
   ⇒ 目前只有【事件流】一項（★decision_context 全檔零筆 event/MessageData 命中
     ⇒ 它【結構上不可能】出現在 119 列裡 —— 不是漏勾,是【表的形狀容不下它】）
⇒ ★★★分成兩節的理由：否則「119 列全綠」會被誤讀成「§5 邊界也綠了」。
盲格數【印在總結行】,讓它可以逐輪比較。
```

# ⑥ 驗收（spec §4/§5 全文）

```
①每個動詞有自檢,且斷言【世界狀態變化】★成對對照：把實作註解掉 ⇒ 對應自檢必須紅
②市場動詞【真的接到既有市場】：掛單後 tile.market_orders 看得到它,且走既有撮合
   ⇒ ★不是「我們自己記了一筆」——那會是第二個市場
③附身後視角真的換了；離身後回到原狀
④推進 N tick 後 current_tick 增加 N（★不是「呼叫成功」）
⑤★★★不改既有行為：merge 前後 determinism fingerprint【不變】—— 本票只加入口
⑥對帳表兩節落地成檔案,盲格數印在總結行
```

★誠實限：**用戶玩 ＝ 體驗回饋不是驗收**（既有裁定）⇒ fidelity 義務仍在我們身上；
他玩到的問題**回 blueprint 彙整**，不直接當工單。

完後改本信 `status: consumed`。
