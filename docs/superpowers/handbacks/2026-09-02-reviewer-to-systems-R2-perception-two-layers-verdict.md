---
from: reviewer
to: systems
status: open
slice: perception-two-layers（外觀層belief欄位）
topic: R②判決:issues——(a)找到具體解法:current_task投影別做per-task查表(30+個TASK_*,每格都有偷渡意圖風險),改用真正觀察得到的底層信號當決策樹根——查過combat_target只在npc_combat_system.gd:110-111 start_combat()真正開打時才被設,current_task==TASK_ATTACK在還在趕路時就已經是這個值,兩者不同義;combat_target拆兩欄的方向對,不建議合併;(b)零雜訊不等於god-view,確認合法,順帶查到寫入點其實已耗兩處RNG(population_est的randf_range也算,不只你點名的resource_scale那顆randi_range)
---

# 判決：`issues`，`premise_contradiction: false`

## ★★(a) `current_task` 外觀投影——**找到具體解法：別做 per-task 查表，用真正的觀察信號當樹根**

你要我逐格看投影表，但目前 spec 只有「5 類」的概念，沒有實際 TASK_* → 類別的對照表。我自己先列了全部 30+ 個 `TASK_*`常數，發現**逐格判斷「這格是外觀還是意圖」這個做法本身有結構性風險**：`TASK_TRIBUTE`（徵收）／`TASK_DIPLOMACY`（外交）／`TASK_SCOUT`（偵查）／`TASK_HERALD`（信使）這幾個，從外觀上看**全部長得一樣**（兩隊站在一起，或一隊在移動），差別完全在【意圖】，逐格查表逼著你要嘛把它們硬塞進同一類（表本身沒問題但麻煩），要嘛給每個一個專屬外觀類別（那就是把 TASK 列舉換皮直接塞回去，你自己已經否決過的形狀）。

★**真正危險、也是我認為最值得你重寫設計的一格是 `TASK_ATTACK`／`TASK_LOOT`／`TASK_DEFEND` 這三個**——我查了 `combat_target` 實際的寫入時機：
```
npc_combat_system.gd:106-111  start_combat()：真正交火時才 state.set_combat_target(atk, def_id)
```
**`current_task == TASK_ATTACK` 在隊伍還在趕路過去的路上就已經是這個值**（決策當下就設，不等抵達）；**`combat_target != -1` 只在真正開打那一刻才被設**——**這兩者不是同一件事**。若投影表寫「TASK_ATTACK → 交戰」，會讓一支還在半路上、敵人根本沒發現牠的隊伍，被外部觀察者「看到」牠正在打架——這才是最容易偷渡意圖的那一格，比 TRIBUTE/DIPLOMACY 那些更嚴重，因為那些頂多是「看不出差別」，這個是「還沒發生的事被看成正在發生」。

⇒ **建議的具體解法**：投影函式不要做 `match current_task: ...` 的 30+ 分支查表，改成**用真正可觀察的底層信號當決策樹**：
```
① combat_target != -1                     → 交戰（不管 current_task 是 ATTACK/LOOT/DEFEND 哪一個，外觀上看不出差別）
② move_target != 自身位置（正在移動中）    → 移動中
③ 站在自家/他人 outpost 且做 PRODUCE/MANUFACTURE/BUILD/CAMP/FORAGE 這類     → 勞作
④ 以上皆非（含 IDLE/REST/GOVERN/TRIBUTE/DIPLOMACY/SCOUT 等純co-location或純意圖類）→ 駐紮 或 不明（你們決定要不要細分）
```
**這樣 30+ 個 TASK_* 大多數不需要逐一分類**——它們會自然落進「①②③都不符合」的桶，而這正是誠實的結果（TRIBUTE 跟 DIPLOMACY 從外觀上本來就分不出來，硬要分開才是造假）。

★★**combat_target 拆兩欄——不建議合併，維持你的原設計**：`in_combat`（看得到在打）跟 `combat_target_est`（看得到打誰）拆開是對的，不要因為「看得到在打通常也看得到打誰」就合併——**兩者的可見半徑/清晰度未必相同**（看到煙塵/交戰跡象的距離，可能比看清楚是哪兩隊在打的距離更遠），拆開的成本很低（多一個欄位），合併的風險是**把一個較弱的斷言（有戰鬥發生）跟一個較強的斷言（知道對手是誰）綁死**，之後想放寬「能看到打但看不清對手」這個真實情境時會被綁架。

## (b) 零雜訊不等於 god-view——**確認合法，而且我查到寫入點的 RNG 消耗比你講的多一處**

`belief_pos`／`best_estimate` 的過期判定（`now - last_tick > BELIEF_STALE_TICKS`）是**整包 claim 一起判斷**，不是逐欄位——新欄位塞進同一個 `snap` dict，自動繼承同一個 staleness gate，不需要額外接線。★**這代表零雜訊的外觀欄位仍然受兩層限制**：①只有真的在視野內被觀察到才會寫入（跟 population_est 用同一次事件）②過期一樣變 unknown。**這兩層在，就不是 god-view**——god-view 的特徵是「無視距離、無視時效、不需要真的發生過一次觀察」，零雜訊只是「觀察到的那一刻很準」，跟「不需要觀察就知道」是兩回事。旗號/當下活動這類東西人眼本來就不太會看錯（你不會把「有人在種田」看成「有人在蓋房子」），跟人口估計、庫存估計那種真的需要用眼睛量的東西不同精度是合理的。

★**順帶查到**：你信裡只點名 `:127 randi_range(-1,1)`（resource_scale），但 `_write_tier01`（`vision_system.gd:100-131`）**同一個函式的 `:108-110` 就已經在用 `randf_range` 算 `population_est` 的雜訊**——這代表這個寫入點現在就已經消耗【兩處】RNG，不是一處。這不影響你的結論（新欄位零雜訊＝零新增 RNG 消耗），但你說「已經在耗 RNG」時，要記完整不是只記你剛好翻到的那一顆，措辭改成「這個寫入點本來就有 ≥2 處既有 RNG 消耗」比較準。

## ⇒ 要你補的
1. (a)：投影函式改成「底層可觀察信號決策樹」，不要 per-task 查表；`TASK_ATTACK/LOOT/DEFEND` 一律讀 `combat_target != -1` 判斷是否已經在打，不要讀 `current_task` 本身。
2. (a)：combat_target 拆兩欄維持原設計，不合併。
3. (b)：不用補，判斷正確；措辭訂正成「≥2 處既有 RNG 消耗」而非「已經在耗 RNG」這種聽起來只有一處的說法。

**premise_contradiction: false，(a) 的具體解法是實質要求（決定投影函式的整個架構形狀），處理過即可整票 CLEAN。**
