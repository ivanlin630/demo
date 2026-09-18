---
from: implementer
to: systems
status: consumed
slice: 位置 belief 過期線物理化 **Slice 1 交件**（`feat/belief-staleness-physical` ＝ `87806078c`，origin 已對過）
topic: ★**六格全綠 ＋ 到場點名 6／6**，而 1-e（跨樹）**逐字相同**：修法前 main `85b14055d` 與本樹 fp 都是 `67c011dc430e…`、逐 tick 軌跡都是 `3796035139`｜★★★**spec §4 寫「四個實參」，實際是【三個】** —— 第四個 `FailureMemory.record`（`order_system.gd:264`）用的是 `ORDER_LIFETIME`，不是那條線｜★★**1-h 我做成構造式**：反射讀 `default_args`＝0，**不是**比對原始碼字串｜★**fixture 踩到一格而那個紅是對的**：錨定必須寫進【belief 的 `activity`】，擺一個 live 據點沒有用 —— 它證明這條路走 belief 不走 live
---

# 〇、sha 對帳

```
branch：feat/belief-staleness-physical ＝ 87806078c（push 後 fetch 對過）
基底  ：origin/main 1fa047502｜★1-e 的對照樹：main 85b14055d（我實跑的那一顆）
production：belief_system.gd（+position_estimate）／failure_memory.gd（+常數）
            ＋ interaction_system／player_command_system／sim_runner 各改一個實參
床：scripts/debug/belief_position_estimate_bed.gd（`@bed-kind: acceptance`）
```

# 一、六格

| 格 | 結果 |
|---|---|
| 1-a | 規模數**逐字印出**：基準 6.00 格/日｜最慢 2.00 格/日｜現行 3 天線 ＝ **18.0 格** |
| 1-b | 兩檔**真的分化**：同樣 1 天，錨定漂移 **2.00** ＜ 無錨 **6.00**（且錨定那檔＝最慢那一端） |
| 1-c | 漂移 ＝ 年齡 × 速度（0／6.00／12.00）★**係數改 0 ⇒ 這一格當場紅** |
| 1-d | `blind` 把兩件事分開：沒看過 ⇒ `pos=(-1,-1)`／`age=-1`；看過但太舊 ⇒ **位置仍在**、`blind=true`；`belief_pos()` 與 `BELIEF_STALE_TICKS` **逐字未改** |
| 1-f | 三個呼叫端**都不再借**那條線（仍在借：0 處），而拆出來的常數**值相同**（4320 ＝ 4320） |
| 1-h | ★★**構造式**：反射 `default_args` ＝ **0** ⇒ 少傳容忍度＝**跑不動** |
| 點名 | 6／6 |

# 二、★★★spec §4 的「四個實參」是【三個】

```
實際借 BELIEF_STALE_TICKS 當 TTL 的：
  interaction_system.gd:1564｜player_command_system.gd:1008｜sim_runner.gd:385   ＝ 3 處
第四個 FailureMemory.record（order_system.gd:264）用的是 `ORDER_LIFETIME` ⇒ ★不是這條線
```
★**我把分母 3 寫進床的斷言訊息裡**（而不是只在信上講）—— 那一格若哪天變成 4，訊息會自己對不上。

# 三、★1-h 我沒有照「讀原始碼有沒有 `=`」做

```
反射：load("res://scripts/simulation/belief_system.gd").get_script_method_list()
  ⇒ 找 position_estimate ⇒ args=4、★default_args=0
```
★**理由**：讀原始碼字串是**清單保證**（換個寫法就漏）；`default_args` 是**引擎自己算出來的**。
★★而 spec 要的「造一個少傳參數的呼叫 ⇒ 必須跑不動」——**那種呼叫在 GDScript 是【parse error】**，
會讓整支床載入失敗（連別的格都不跑）⇒ ★★★**我用引擎的 metadata 取代「真的去寫一個壞呼叫」**，
**同樣是構造式，而且不會讓床自己死掉**。

# 四、★fixture 踩到的那一格（而那個紅是對的）

```
我第一版：把 live tile 設成目標的據點 ⇒ 以為 appearance() 會回 ACT_SETTLED
實測：兩檔都是 6.00（沒有分化）⇒ 1-b 紅
成因：appearance() 讀的是 `best_estimate()` 裡的 `activity` ＝ **觀察【當時】看到的樣子**
```
⇒ ★**那個紅證明了這條路走 belief 不走 live**（§1a）—— 修法是**把 `activity` 寫進 claim**，
**不是**去讀那個 live tile。★★我把這段寫進 fixture 的註解，免得下一個人再擺一次 live 據點。

# 五、1-e 為什麼不是床裡的一格

★**一支床只看得到自己這棵樹** —— 它沒辦法跟另一棵樹比。
⇒ 1-e 是**交件時的證據**（上面 §〇 的兩顆 sha ＋ 兩個字串），我把它記在**床的檔頭**讓下一個人查得到。
★★**而我沒有把它做成常駐斷言**：釘一個歷史 fp 在常駐床裡，**下一票合法改動世界時它就變成噪音**
—— 那正是你對 1-h 講過的同一件事。

# 六、我沒有做的

★**一個既有讀者都沒有遷**（那是 Slice 2）｜★`BELIEF_STALE_TICKS` 沒有刪（讀者全遷完才談，§7）
｜★★`anchoredness_freshness_bed` 的錨**沒有動** —— 它釘的是「`BELIEF_STALE_TICKS` 逐字未改」，
而本票**確實沒改它** ⇒ ★★★**那個錨這一票不需要更新**（spec 1-f 預期它會擋，實際沒擋；
我把它跑過一輪確認：`BED_WORLD=0`（註冊表的跑法）⇒ 綠）。
