---
from: reviewer
to: systems
status: open
slice: delist-prepare
topic: R②判決:premise_contradiction:true——★★★最重大發現:今天稍早已merge的flee-to-safety(c50c0ca0)明確靠「備戰」當退化fallback(退化目標=TASK_PREPARE,既有option不必新建),下架備戰會讓那個機制失去唯一的威脅回應保底,重演flee-to-safety自己剛修好的「恐懼被guard吞掉」病;這是兩個blueprint裁決互相打架,不是HOW層小補丁能吃掉的,建議先回blueprint裁決衝突再繼續;①負斷言部分翻車:TASK_PREPARE const的13處確實乾淨,但字串字面"備戰"另外命中terms.gd:27-29(PREP_A/B/K三常數)+terms.gd:326-333(util計算函式gate在opt=="備戰"),這些不在spec§2的五項清單裡,會變成孤兒死碼;存檔路徑查過,這codebase沒有game-save/load機制,那格顧慮可以放下;②prep.*tap移除同意,幽靈counter比失去觀測點更糟
---

# 判決：`premise_contradiction: true`（在flee-to-safety衝突那格），其餘 `issues`

## ★★★最重大發現——**「備戰」是今天已 merge 的 flee-to-safety 唯一的威脅回應保底，下架它會重演那票自己剛修好的病**

查了 git log，`flee-to-safety` 已經 merge（`c50c0ca0 merge flee-to-safety 三顆`）——那張票的 spec 明寫：「**退化目標：`team_data.gd:20 TASK_PREPARE = 備戰`，且 `options.gd:397/503` 已是既有 option ⇒ 不必新建 task**」，且該票的 R②（就是我審的）確認過「備戰 applicable 只需 `threat_react >= threat_threshold`，不需要 destination」——**這正是為什麼「找不到安全處的 FLEE」會自然退到「備戰」：兩者共用同一個廣義威脅閘，FLEE 找不到目的地變不 applicable 時，備戰通常還在候選池裡接住**。

★**若「備戰」現在被整個下架，這個接住機制就不存在了**——威脅存在、找不到安全處（自家據點/盟友都不在附近或過期）、又不符合迎戰資格（例如 `is_resident`）的隊，會落回「求和」或乾脆掉進 mundane 選項——**這正是 blueprint 自己在 flee-to-safety 那票立的鐵律「恐懼必有出口，禁被 guard 吞掉」要防的那個病，只是這次是被【下架備戰】製造出來，不是被 applicability gate 製造出來**。

⇒ **這不是我能在 HOW 層幫你吃掉的衝突**——這是**兩個 blueprint 裁決互相打架**：「備戰的真身是動員軸，不該是持續 task」（這票）vs「備戰是 flee 找不到安全處時的既有退化目標，不必新建」（flee-to-safety 票，已 merge）。★**建議在繼續本票之前，先把這個衝突具體地回報 blueprint**——不是問「要不要下架」（那已經裁過），是問：「下架備戰之後，flee-to-safety 找不到安全處時要退化去哪？是給 flee 補一個新的（非 task 型）退化出口，還是这個情境本身被判定為可接受的殘留？」**這個問題若不先問清楚，本票驗收⑥（流向讀數，讓引擎自然重分配）會把這個真空悄悄記成『正常的重新分配』，而它其實是一個新洞。**

## ①負斷言——**部分翻車，字串字面確實躲過了 const 搜索**

窮盡 grep：
```
TASK_PREPARE（const）：13 處 —— 跟你的清單一致，這部分成立
"備戰"（字串字面）：27 處，橫跨 15 個檔案 —— 比 const 引用多、範圍更廣
```
**多出來的字面引用裡，兩處是真正的 production 程式碼，不在你 spec §2 的五項清單裡**：
```
terms.gd:27-29   const PREP_A/PREP_B/PREP_K（備戰 util 公式的三個係數）
terms.gd:326-333 一支 util 計算函式：if opt != "備戰": return 0.0（用字串直接比對 option 名，不經 TASK_PREPARE）
```
**這是「備戰」這個 option（`options.gd` REGISTRY 裡以字串 `"備戰"` 為 key）跟「TASK_PREPARE」這個 task 常數是兩個不同的識別符**——你的清單掃的是後者，前者（決定這個 option 該給多少 util 分數的計算邏輯）完全沒被涵蓋。**若只移除 `options.gd:427-435` 的 REGISTRY entry，這兩處會變成孤兒死碼**（函式再也沒人呼叫，常數再也沒人讀）——不是引用會出錯，是留下沒人清理的殘骸。

⇒ **建議**：§2 補第⑥項：「`terms.gd:27-29`（`PREP_A/PREP_B/PREP_K`）與 `terms.gd:326-333`（util 計算函式本體）一併移除」。

★**存檔路徑那格**：查過，這個 codebase 沒有找到任何 game-save/load 的檔案序列化機制（`FileAccess`/`JSON` 相關命中只有 `game_setup.gd` 的世界生成 config 讀取跟 `observer_main.gd` 的觀察者工具，都不是「存檔恢復對局」）——這格顧慮可以放下，不用列入範圍。

## ②`prep.*` tap 移除——**同意，幽靈 counter 比失去觀測點更糟**

跟你今天已經記過的「工具騙人」同一族——留著永遠印 0 的 tap，會讓下一個人誤以為機制還在候選池裡只是沒贏，比誠實地讓它消失更誤導人。這個取捨你選對了。

## ③其餘（殘留檢查/流向讀數/解凍）——沒有問題

殘留狀態機械驗證（不是論證）、流向讀數照原樣報不解讀、解凍後才能 merge——都符合這個 session 一路建立的紀律，沒有要補的。

## ⇒ 要你補的
1. ★（最優先）：把「下架備戰會讓 flee-to-safety 失去退化出口」這個衝突回報 blueprint，先裁決 flee-to-safety 該怎麼辦，再繼續本票。
2. ①：spec §2 補第⑥項，移除 `terms.gd:27-29` 跟 `terms.gd:326-333`。
3. ②③不用補。

**premise_contradiction: true——本票在跟 flee-to-safety 的衝突解決之前不能算 CLEAN，這不是可以自己往下走的 issues（小）。**
