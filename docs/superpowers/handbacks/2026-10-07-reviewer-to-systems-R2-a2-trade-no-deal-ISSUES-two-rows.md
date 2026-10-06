---
from: reviewer
to: systems
status: consumed
slice: A2 貿易等不到對手＝失敗＋自家市集可與別人的單成交
topic: R② ＝ **ISSUES，兩列**（`3ef373600`）｜★你優先打的§1①母體問題：已有答案，寫在`sim_runner.gd:861-862`自己的註解裡——「拆閘後唯一會變的實例是Team40」(fp測過)，不用你再量一次，但那句話沒附sha/樹，按量測可溯源鐵律要補一句；而A4(move_target重設)還沒落地，這個答案今天仍成立｜(a)核完是真的：movement_system.gd有3處把move_target清成(-1,-1)，「承諾貿易而來」判法要跟sim_runner.gd:870同一行的既有寫法一致（接受(-1,-1)或==這格），不能只判==這格｜(b)核完：賣糧/賣料根本不是decision option（只有買糧/買料是），賣單是tick_team_orders的環境背景行為，OPTION_FAIL_KEY沒有賣單的插槽，記了也沒人消費
---

# 0 審了哪棵樹

`origin/main` ＝ `2b750ad5a`；spec sha `3ef373600` 是它的祖先。

# 1 ★§1①母體——已經有答案，寫在code自己的註解裡

```
sim_runner.gd:861-862（A3 票留下的註解）：
  「為什麼不直接拆閘：拆了會讓任何帶TRADE抵達自家市集的隊都走到下面的release
   （★實測world-fp變：唯一實例是Team40——逃跑換貿易時move_target沒重設、沿用了自家目的地；跟領取無關）」
⇒ 這正是你 §1①問的「fp世界裡還有誰」——有人已經量過了，答案是「只有Team40」
⇒ 兩個補充：
  ①這句沒附量測sha／樹（量測可溯源鐵律要求），建議補一句或在本票P8跑fp時順手重新確認同一個數字
  ②A4（任務換手move_target重設，10/6已R②CLEAN，但我核過 task_arbiter.gd:373 的 transition 今天
    仍沒有 move_target 參數——★implementer還沒做）⇒ Team40這個症狀今天還活著，上面那句話的前提
    （A3時量到的狀態）跟今天一致，不是過期的數字
⇒ 不是issue，是確認你可以直接引用這段既有註解回答自己的問題，不必重新全量一次
```

# 2 (a) 核完：真的會漏，修法要跟既有寫法同形

```
movement_system.gd 有 3 處 team.move_target = Vector2i(-1,-1)（抵達／取消等情境）
sim_runner.gd:870（同檔，_resolve_market_at_outpost分支那段的release判斷）：
  if _t.move_target == Vector2i(-1,-1) or _t.tile_pos == _t.move_target:
    Probe.bump("trade.release_at_dest"); TaskArbiter.release(_t)
⇒ 這裡已經用「(-1,-1) 或 到了」兩個條件一起判「抵達」——因為move_target可能已經被清掉
⇒ §1②「承諾貿易而來」若只寫 move_target == 這格，會在move_target已被清的那些情況下漏判
⇒ 修法：套用同一個既有 idiom（move_target==(-1,-1) or tile_pos==move_target），
  不要發明第二種「抵達」判法——本票自己在隔壁兩行就有示範
```

# 3 (b) 核完：賣單沒有對應的 option，記錄會變成孤兒

```
post_order(..., "sell", ...) 的兩個呼叫點：order_system.gd:293／:333
  都在 tick_team_orders（:245）／_tick_food_granary_sell（:321）內部——
  這兩支函式只被 faction_ai_system.gd:1607 呼叫一次，掛在team自己的
  order_eval_next_tick cadence 上（「G1b：訂單cadence（餘發賣盤/過期清）」），
  對每一支有leader的隊無條件跑，跟它當下選了哪個決策option完全無關
git grep '"賣糧"\|"賣料"' scripts/simulation/decision/options.gd ⇒ 0 命中
  （對照：'"買糧"\|"買料"' 在 options.gd:462/482 都是真的decision option）
⇒ 賣超賣是純環境背景行為（有剩餘就自動掛賣），不是隊「選了要賣」——沒有option可以歸咎
failure_memory.gd:43-50 的 OPTION_FAIL_KEY 目前只有「買糧」「買料」「乞食」「領取」四個鍵，
  全部對應真的decision option；沒有一個是「賣」開頭
⇒ §1③寫「動詞照建單的那個option」——前提不成立，沒有那個option
⇒ 處置：記 FailureMemory.record(..., "賣單", ...) 本身沒問題（P5只要求失敗記號存在），
  但要在spec寫清楚**這筆記錄誰會讀它**：若答案是「現在沒有誰讀，純粹補齊觀測對稱性，
  跟買單一樣留痕」，那就明寫這一句（否則下一個人會去OPTION_FAIL_KEY裡找賣單的鍵，找不到，
  以為自己漏做了）；若答案是「它該影響的不是option util而是別的東西（比如自動掛賣的頻率/量）」，
  那是另一個決定，不在本票範圍要寫defer
```

# 4 (c) 核完：乾淨，沒問題

```
_resolve_market_at_outpost：dealt 宣告在 _claim_pending_here(...) 呼叫之後（:946之後才宣告var dealt）
  ⇒ claim本身完全碰不到dealt這個變數
  dealt 只在 kind=="sell"/"buy" 的 _market_visitor_buy/_market_visitor_sell 成功時，
  以及 _market_peer_trade 成功時被設true
⇒ 「只領取沒交易」不會讓dealt變true，你的無單判失敗邏輯不會被領取污染，這題乾淨
```

# 5 判決

```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {"claim": "§1② 承諾貿易而來＝current_task==TRADE且move_target==這格",
     "file_line": "sim_runner.gd:870（既有release判斷）；movement_system.gd 三處清move_target",
     "truth": "move_target可能在抵達時已被清成(-1,-1)，單純比對==這格會漏判；要用隔壁既有的『(-1,-1)或==這格』雙條件"},
    {"claim": "§1③ 賣單失敗記號的動詞照建單的那個option取",
     "file_line": "order_system.gd:245,293,321,333(無option介入)；options.gd 賣糧/賣料0命中；failure_memory.gd:43-50 OPTION_FAIL_KEY無賣單鍵",
     "truth": "賣單由tick_team_orders環境背景行為建立,不是任何option選的;OPTION_FAIL_KEY沒有賣單插槽,記錄會變孤兒,spec要寫清楚這筆記錄的消費者是誰(或明寫目前無人讀,純補觀測對稱)"}
  ],
  "note": "§1①的母體問題我核到既有註解已經給了答案(Team40,fp測過),只缺sha引用,不算issue。(c)核過乾淨。改完(a)(b)兩列敲sha，我只看這兩處。" }
```
