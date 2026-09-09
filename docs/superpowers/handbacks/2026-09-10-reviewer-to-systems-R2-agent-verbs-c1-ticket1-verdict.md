---
from: reviewer
to: systems
status: open
slice: C1 票① agent 動詞補課
topic: R² 判決 — item1 找到真的漏(事件流已有現成函式,只是沒接到agent層)；item2 CLEAN；item3 補一個共用陷阱；兩個盲區都查完給你答案
---

# R² 判決：`2026-09-10-agent-verbs-c1-ticket1-HOW.md`

## 判決：非 CLEAN——item1「太小」那半你猜對了，而且比猜想更具體：東西已經蓋好了，只是沒接給 agent

## item 1（119 母體對不對）：對，但不夠——查到「事件流」不只是理論缺口，是【已存在卻沒接給你這層】的功能

先驗數字：`grep -c "^var " decision_context.gd` = **119**，對得上。
`player_query_api.gd` 的 `^func` 有 18 個，但其中 4 個是私有輔助
（`_check_player`／`_check_player_with_team`／`_build_available_actions`／`_action_label`）——
**真正的公開查詢動詞是 14 支，不是 18**。這個數字要訂正，不影響你的結論方向，
但既然今天連續兩次栽在「掃了全部」卻漏算，這個也記一筆修正。

**太小那半，查到比你猜的更具體**：`decision_context.gd` 全檔零筆 `event`／`Event`／`MessageData` 命中
——決策引擎【從來不讀】事件流，這點你母體選擇的理由本身反而印證了：
它不需要事件流來做決策，所以事件流結構上【不可能出現在 119 列裡】,
不是漏勾，是【這張表的形狀就容不下它】。

**但事件流本身不是空想的需求——它已經有一支函式在做**：
```
player_api_mapper.gd:792  static func map_global_messages(state, n:=10) -> Array
唯一呼叫點：ui/sim_bridge.gd:154   ← ★GUI 層在用
player_query_api.gd 裡：零呼叫    ← ★agent/REPL 層完全碰不到它
```
這正是 P9 那個病例的活教材：機制蓋好了（`map_global_messages` 是真的、有資料），
但**只接了 GUI，沒接 agent**——而這張票的範圍正是「agent/REPL 層」。

**要求：把 `player_query_api.gd` 補一個薄薄的 wrapper 呼叫 `map_global_messages`
（同 `get_storage_panel`／`query_outpost_panel` 那幾支 wrapper 的形狀），
併入本票，不是另開票**——理由跟前一張票（`_find_unowned_farmable_tile`）一樣：
同一張票的標題（資訊完整）已經涵蓋它，拆開只會製造「119 列打勾全綠，但事件流仍然碰不到」的假完整。

**★★對 §5⑥落地成檔的表要求做一個結構性補丁**：119 列的表【裝不下】事件流這一項，
不是因為漏勾，是因為它的母體單位是「ctx 欄位」而事件流不是 ctx 欄位。
建議在 §5⑥的檔案裡**加一個獨立小節**（不是併進 119 列的表格裡）：
「§5 邊界文字裡明列、但不對應任何 ctx 欄位的項目」——目前查到的只有事件流一項，
逐項列出它的來源函式／有沒有接到 agent 層／缺的話補哪個 wrapper。
這樣「119 列全在」跟「§5 邊界文字全兌現」是兩個各自可驗證的斷言，不會因為前者綠了
就誤以為後者也綠了。

「太大」那半（119 裡混決策端內部 util 分數如 `rescue_build_util`／`idle_employ_value`）：
不卡本票——這是顯示/legibility 問題（原始數字要不要翻譯成人話），
你 §5 邊界已經寫明「顯示問題不是資料問題」，這批票只保證有查詢路徑能讀到，
不保證每個數字對玩家都好懂，可以留給票②（GUI）處理怎麼呈現。

## item 2（時間控制留呼叫端）：CLEAN，不會讓 REPL 端變不可測——已有現成先例

```
sim_runner.gd:86  func advance_tick(state, player_pos) -> String
```
純函式、無隱藏內部計數，`headless_test.gd` 已經在用同一個函式跑 1000+ tick 的 loop 斷言
（CLAUDE.md 交付標準本身就要求這個）。REPL 端「推進 N tick」只是
`for i in N: SimRunner.advance_tick(state, ...)`，自檢腳本直接讀
`state.world.current_tick` 前後差 N 即可斷言——這個模式在這支 codebase 裡已經是
標準做法，不是新風險。你的切法（不在 sim_runner 加狀態）沒有讓它變難測，判斷對。

## item 3（撤單機制）：確認沒有獨立函式，但「共用既有移除路徑」現在還沒有東西可共用，而且要小心一個陷阱

查了 `order_system.gd` 全部 `^func`：沒有 `cancel_order`／`remove_order`。
移除/過期邏輯**現在是內嵌在 `tick_team_orders`（:191-230）的 for 迴圈裡**，
不是一支獨立可呼叫的函式——所以「共用既有移除路徑」目前**沒有東西可以共用**，
第一步是把這段**抽成一支獨立函式**，過期迴圈跟新的手動撤單都呼叫它，這才是「共用」的實際形狀，
你 spec 裡沒寫這一步是隱含的重構,建議明寫，免得實作者以為「共用」是字面上呼叫過期迴圈。

**★抽出來時要小心一個陷阱**：這段迴圈裡混了**兩種不同語意的副作用**——
```
:204-220  escrow 釋放進 pending_claims（★守恆機制,必須共用——不共用會違反「貨不得瞬移」）
:225-227  FailureMemory.record(..., "order_abandoned_buy")（★這是「被動失敗」信號,不能共用）
```
玩家主動撤單跟訂單自然過期是**不同的事件**：過期＝執行失敗（該折價，下輪別再撞），
主動撤單＝玩家的決定（不是失敗，不該讓下輪「買糧/買料」被誤判折價）。
若抽函式時把整段原樣搬過去共用，手動撤單會**意外觸發失敗記憶折價**——
一個玩家自己取消訂單的動作，卻讓 AI 以為「這條路失敗了」而折價自己下一輪的決策。
**要求**：抽出來的共用函式只包 escrow-release 那段（:204-220），
`FailureMemory.record` 那行留在過期迴圈自己的分支裡，手動撤單不呼叫它。

## 盲區①（附身/離身語意）：查完了，答案很乾淨，不用你猜

```
world_state.gd:101  var player_id: int = -1
world_state.gd:752  if t.leader_id == player_id or player_id in t.named_members: ...（控制隊解析）
```
既有語意單一且清楚：`player_id` 是唯一開關，控制隊由它反查（leader 或具名成員都算）。
⇒ **附身 = 把 `state.player_id` 設成目標人物 id；離身 = 還原成附身前記下的那個 id**。
不用發明第三種，你 spec 的「沿用既有語意」這句已經對——只是語意本身我幫你查完了，
可以直接寫進 spec，不用再留成問句。

## 盲區②（player_api_mapper.gd）：查完了，這正是挖出 item1 那個發現的地方

`player_api_mapper.gd` 是 `player_query_api.gd` 背後的組裝層——它的 mapper 函式大多已經被
現有 14 支查詢動詞包好了（`map_faction_panel`／`map_storage_panel`／`map_outpost_panel`／
`map_subteam_panel`／`map_trade_session` 各自對得上一支 query verb）。
**唯一一支確定沒被包的是 `map_global_messages`**（見 item1）。順手看了其他幾支
（`map_pending_targets`／`map_willing_members`／`map_forced_interaction`）——
它們是被 `get_player_snapshot`／`get_available_actions` 內部組合呼叫，不是孤兒，不用管。

## 其餘

CLEAN 只差：item1（補 `map_global_messages` 的 agent-layer wrapper + §5⑥ 表格結構補丁）、
item3（抽共用函式時把 escrow-release 跟 FailureMemory.record 拆開）。
盲區①②我已經幫你查完給答案，直接寫進 spec 不用再查。補完後不用再送 R²，直接 dispatch。
