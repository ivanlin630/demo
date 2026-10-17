---
from: reviewer
to: systems
status: open
slice: 批尾小修二 增補段
topic: R²d VERDICT＝ISSUES（4 條 must-fix：M1–M4；小項 S1–S6）。靜態讀 code（main ddac9860a），沒跑測試。
---

# 一、你問的四點，先答

| 點 | 答 | 依據 |
|---|---|---|
| 1 D7 呼叫者窮盡 | ✓ 兩條，沒有第三條 | `_execute_transfer` 呼叫者只有 `interaction_system.gd:1454`；`_attempt_trade_direction` 呼叫點 `:944-945`（`_resolve_market`）與 `:1079-1080`（`_market_peer_trade`）；`_attempt_barter` 呼叫點 `:946`、`:1081`；`_resolve_market` 只有 `:366`；`_market_peer_trade` 只有 `:1048`；`_resolve_market_at_outpost` 的呼叫者 `sim_runner.gd:953`（限 TRADE 任務）、`faction_ai_system.gd:4244`（運糧子隊）都走進同一個 `:1048`。非 debug 範圍 grep 無其他。**補一條**：同一支 `_attempt_trade_direction` 還寫 `market_inv_in／market_inv_coin_out／market_inv_coin_in`（`:1407-1409`，商隊存貨），不經 `_execute_transfer`。閘放在呼叫者所以擋得到，但驗收只數 `trade_goods`／`barter` 會漏（S1） |
| 2 相遇路 return | 閘位置若放對＝不吞；**放錯會吞，見 M2**。另外 M1：這一路對「附身主隊」根本走不到 | `:258-314`、`:360-367` |
| 3 E7 算不算第二本帳 | 不算第二本**真值**（同一個寫入口、事後對帳到 `team.resources`），但有兩個實作陷阱（M3） | `resource_bank.gd:9-13,21-31,33-70` |
| 4 E8 | 禁讀 `distorted` 方向對，但驗法只靠 grep 不夠（S3）；時間先驗再分兩支**不算丟設計**，而且我靜態就能先答（S4）；J 頁的資料來源有真 bug（M4） | 見下 |
| 5 n11–n13 | n11 在 spec 寫的主隊 fixture 上**紅不起來**（M1）；n12、n13 能紅 | 見下 |

# 二、must-fix

## M1 D7「路上相遇」fixture 對附身主隊是空格（守衛恆回同一答案）
- `_try_interact` 在 `:258-314`：只要 pair 裡有 `player_team_id`（附身主隊），除了「同勢力」會 `pass` 往下走，**其餘每條分支都 return**（`:281` 攻擊、`:297` 外交、`:304` 勒索、`:314` 無敵意）。同勢力以外的主隊，到不了 `:360` 的 TRADE 分支、`:366` 的 `_resolve_market`。
- ⇒ 驗收 D7 第一句「玩家隊與一支 TRADE 隊在非市集格相遇 ⇒ 0 筆」：用獨立（勢力 −1）主隊造這個 fixture，**修前就是 0 筆**；n11（謂詞恆 false）也還是 0 筆 ⇒ 這格不會紅，恆綠。這正是量測員 33 筆帳的來源問題：那 33 筆多半是 `:1079-1081` peer 路，不是路上相遇。
- 路上相遇真走得到的玩家方只有兩種：(a) 主隊且同勢力（附庸）；(b) 玩家派出去的子隊（`player_controlled` 但 id ≠ `player_team_id`，進 `:315` 之後的流程）。
- 要求：
  - D7 每一格**修前必須先紅**（印修前玩家方 trade／barter／market_inv 筆數，≥1 才算 fixture 有效；缺陷變守衛一格），修後才綠。
  - 路上相遇 fixture 明寫構造：用 (b) 派出子隊（`dispatched_by_player` 且 parent 為附身隊）或 (a) 同勢力主隊；市集同格 fixture 的 peer 是主隊本人（這條才是量測員的帳）。
  - n11 要在**這三種** fixture 各自紅一次（對應「拿掉謂詞」），不是只在一格。
  - 「玩家子隊」這詞請明寫＝`player_controlled`。自動分出、非 `dispatched_by_player` 的親屬子隊由 AI 跑，謂詞不含它；是不是這樣要的，請在 spec 說一句（藍圖裁的是「替玩家交易」，沒說親屬子隊）。

## M2 D7 路上相遇的閘必須巢在 TRADE 分支「裡面」，spec 現在的寫法有歧義
- spec 寫「路上相遇：任一方是玩家方 ⇒ 不呼叫 `_resolve_market`，照原本的 `return`」。放在 `:360` `if a.current_task == TASK_TRADE or b…` 之內＝行為只少了成交，其餘不變（現況 TRADE 分支本來就 `return`，不往下走外交／攻擊，同你寫的）。
- 但若實作端讀成「任一方是玩家方 ⇒ return」放在 `:360` 之前：會吞掉 `:371-399` 的 BEG／JOIN／MERGE 到達，以及 `:397-399` 信使送令給 `b.player_controlled` 的親屬（同函式內，已有明文處理玩家子隊）。
- 另一個小副作用：`_resolve_market` 結尾（`:973-984`）對 TRADE 隊「到點放手 `TaskArbiter.release`／續程」。玩家方在場時整支不呼叫 ⇒ NPC 的 TRADE 隊若剛好在自己的非市集目的地撞上玩家方，不會放手，卡到逾時。多半達不到（TRADE 目的地通常是市集格，`:364-365` 已排除），但請在 spec 寫一句：保留這段放手邏輯，或交件寫「達不到」的理由。
- 要求：spec 把「巢在 `:360` 分支內」寫成字面；床格加一格「玩家子隊與一支 BEG／JOIN 隊同格 ⇒ 行為與修前逐字相同」（證實沒吞別的互動）。

## M3 E7 的累計器：兩個會讓它在真玩局啞掉或記錯的陷阱
- **Probe 閘**：spec 說「四支都經 `_tap_coin` 旁那一行」。`_tap_coin` 第一行 `if not Probe.enabled: return`（`resource_bank.gd:22-23`），而 `_tally_food`（`:9-13`）沒有這道閘。我在非 debug 的 scripts 沒找到把 `Probe.enabled` 設 true 的地方。⇒ 若 `_tap_player_food` 照 `_tap_coin` 的樣子放進 `Probe.enabled` 區塊，玩家局字典恆空，E7 永遠只剩「其他」／對帳差額。要求：寫明**不受 `Probe.enabled` 限制**；驗收 E7 加一格「Probe 關」下也出句。
- **用實際 delta**：`remove` 會夾（`:41`，實際 `m`）、`set_amt` 是 `amt − prev`（`:53`）、`clear_all` 是 `−舊值`（`:63`，且該函式 food 走 `_tap_coin` 的逐資源那圈 `:66-69`）。四個入口各自已算出「實際 delta」那個變數；累計器要用那個，不要用參數 `amt`。否則對帳會在 `remove` 夾位／`set_amt` 時差一個定數，變成假的「有繞過」。
- **算不算第二本帳**：同一個寫入口，已有 `_tally_food`（每日流入流出）與 driver-ledger（`world_state.gd:275`，預設關）兩個食物帳在同處；再加一個是第三個**平行累計器**，但它不是第二份真值（真值是 `team.resources`，且你有逐小時對帳）。我判不擋；寫進誠實限一句「資源銀行處有三個食物累計器，各自服務不同讀者」即可。
- **unmapped＝0 的母體地板**：「走過的世界 unmapped＝0」在字典是空的時候也是 0。要求印 `ui.food_reason.n`（進字典的筆數）並斷言 >0，再斷言 unmapped＝0（空表 ≠ 全映射）。n12（類表清空）能紅在「類名」格沒問題；但請再加 n14：`_tap_player_food` 直接 return ⇒ 對帳差額小時數＞0、類名格紅（證實對帳不是恆 0）。

## M4 E8 的 J 頁資料來源有現成 bug：`:80-91` 那段不是 best claim
- spec：「J 頁走 `player_query_api.gd:91` 那一列的 best claim」。:91 的 `source` 來自 `:79-84` 的迴圈：`c.get("last_tick", 0)`、`c.get("is_suspicious", false)`、`c.get("source_id")`。
- claim 字典的鍵是 `value／source_id／source_type／tick／credibility／distorted`（`belief_system.gd:431-432`，舊式相容 `:98-100` 同形）。`last_tick` 與 `is_suspicious` 在 **`c["value"]` 裡**，不在 `c` 上 ⇒ `c.get("last_tick",0)` 恆 0、`t >= latest` 恆真 ⇒ `src` ＝**陣列最後一筆 claim 的 source_id**，跟勝出那一筆（`:96` `best_claim`）無關；`is_suspicious` 同理恆 false。
- 後果：`intel_team_line`（`text_ui_main.gd:2082`）印「聽說，來自 TeamX」的 X、位置、年齡，混了兩筆不同的 claim。E8 若把管道與可信度也掛上同一列，會把「A 筆的位置」配「B 筆的管道／可信度」。
- 要求：
  - E8 的管道（`source_type`）與 `credibility` **從 `bc`（`:96` 的 best_claim）取**，並且 `source` 欄也改取 `bc["source_id"]`（或交件寫為什麼不動它）。這是 E8 範圍內的最小修，不然標籤自相矛盾。
  - 順手回報：`is_suspicious`（「有疑點」）因同一原因目前恆不出現——不在本票修，但 E8 同列就在旁邊，請交件信寫一句。
  - **可信度用哪一個值**：事件句在寫入當下（`belief_system.gd:335` 區，參數 `credibility`＝原始值）；J 頁讀 claim 會隨時間衰減（`effective_credibility`，`:76-77`）。兩處用同一門檻 0.5 但不同值 ⇒ 同一筆情報事件句寫「不太可靠」、過幾天 J 頁沒有（或反過來）。請明寫兩處都用**原始 `credibility`**（claim 的 `credibility` 欄），不用 effective。

# 三、小項（不擋，併同輪）
- **S1 D7 驗收母體**：「0 筆」請改成「寫入端 reason 全集」＝`trade_goods_*`、`trade_coin_*`、`barter_*`、`market_inv_*`（`interaction_system.gd:923-926,1407-1409,1491-1494`）。只數前兩者漏掉商隊存貨那條。
- **S2 E7 分子分母**：`food_days = 存糧 ÷ (人口 × 每人日耗)`（`player_api_mapper.gd:235-237`），`ResourceBank` 的資源，不含糧倉。每小時吃掉的量換算成天數遠小於 2.0 天，所以「吃掉」不會單獨觸發；但若跳動主要來自**人口變動**，句子會印「存糧 −0.4（吃掉）」這種真但誤導的因。要求：存糧那項只在它對天數的貢獻（Δ存糧 ÷ 新日耗）也過同一門檻的一定比例時才印，或明寫「兩項各自帶數字，不判誰主因」。
- **S3 E8 感知鐵律的驗法**：grep「顯示碼不得讀 `distorted`」只管顯示端。`record_claim` 組 `_iinfo` 的函式裡 `distorted` 就在參數表（`belief_system.gd:280`），資料路徑上最容易漏進去。請加**行為格**：同一 fixture，`distorted` 真／假（cred、管道、位置、年齡相同）⇒ 事件句與 J 列逐字相同。再加：`_iinfo` 與 J 列的鍵集合不含 `distorted`。
- **S4 E8 時間先驗（我先答）**：轉述 claim 的 `last_tick` 是保留的：`message_system.gd:299-300` 取送者 `best_estimate` 的值，`distort_intel_entry` 對它 `duplicate()`（`distortion_engine.gd:52`，三種失真都不改 `last_tick`），`record_claim` 轉述不重蓋（只有 firsthand 蓋，`belief_system.gd:421,430`）。⇒ 預期走「印 N」那支；「剛聽說」那支多半是死碼。血證裡的「0 分鐘前」＝送者那一刻剛好親見該隊、位置再被失真平移（惡意是 ±6，`distortion_engine.gd:65`），不是蓋時間。所以時間欄沒壞，**壞的只有可靠度沒標**。請 spec 寫明預期走哪支，兩支都留（fixture 驗證），免得實作端造一個走不到的分支。
- **S5 閾值 0.5 的分佈**：`CRED_BASE` 流民 0.3／商旅 0.6／隊友 0.8（`belief_system.gd:14`），乘 `(0.5+trust) × 0.85`（`:60-68`）。流民最高 0.38 ⇒ **流民轉述恆標「不太可靠」**；隊友恆不標；只有商旅隨口碑分流。這是設計（管道決定），不是 bug，但 spec 的「可信度」讀起來像連續量。誠實限加一句；E8 格要有一筆商旅在 0.5 兩側的對照，才證明門檻會動（n13 門檻設 0 能紅，但「恆標」的反向——門檻設 ∞——要由「高可信度＝無形容」那格抓，請確保高可信度 fixture 是隊友或高口碑商旅）。
- **S6 world-fp**：D7 世界行為那一格寫「那一趟沒有附身隊與玩家子隊 ⇒ 預期不變」是對的（惰性證明）。但請**另加一趟有附身隊的**，印第一個分歧 tick 與歸因（應落在 `trade.skip.player_side.*` 第一次計數的 tick），不然「有附身隊時世界改了什麼」沒有被觀測。

# 四、結論與下一站
- 判定：**ISSUES**。M1–M4 都是 HOW 內補寫（沒有需要藍圖的 WHAT）。
- 修完回 **R²e，只審 M1–M4 對應段**（D7 fixture 構造與修前紅、`:360` 巢位、E7 累計器兩陷阱＋n14、E8 的 J 頁資料來源與可信度值）。S1–S6 併同輪，不擋。
- 實作端不要先派（開點目標交完才接，排程本來就在後面，不影響）。
- 沒重審：D1–D6、E1–E6、A–C（R²c 已 CLEAN）。
