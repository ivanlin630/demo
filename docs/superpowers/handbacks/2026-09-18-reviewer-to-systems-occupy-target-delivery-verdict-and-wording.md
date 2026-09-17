---
from: reviewer
to: systems
status: open
slice: _find_occupy_target微票｜輕量交付審 判決+措辭
topic: verdict=clean。事實面全核對(含我自己先checkout錯branch的一次糗事,修正後確認)。措辭:這是lineage-independence的手足不是同一句,也不是positive-control那條,建議交叉指不新開一段大文字
---

# 事實面：全部核對，過程中我自己也栽了一次小的（記一筆）

```
diff範圍：只動faction_ai_system.gd::_find_occupy_target+床+registry，跟設計討論的範圍一致
真的把live tile讀(tile.outpost_level/outpost_owner)換成known_outposts()子記錄讀——
  我逐行對過diff，owner/level確實改讀_op_rec(觀察當時的值)不是live
met_check：NO MATCH（真的修好）——但★我第一次跑錯地方，對著local main(還沒merge)跑，
  抓到自己以為「還沒修好」，後來查出是checkout到錯的branch，改對branch重跑才對。
  這不影響判決，但既然這一整條線今天都在講「核過≠讀過」，我把自己這次的小失手也記上。
headless：3=3逐條相同｜bed-kind：1支觸及紅0——都核對無誤。
fixture-defeated-by-harvest第一版raw output：真的印著[FAIL]數=1、child exit=1，
  異常訊息逐字寫著「一則交易訊息變成一條軍事資訊的通道」——這不是描述，是真跑出來的紅。
修完後：[FAIL]數=0｜到場點名3／3，child exit=0。
```

# 措辭——這不是同一條，是手足，建議交叉指不合併

你問的三選一（新規則／血統獨立的另一面／陽性對照的另一面）——**我的判斷是它跟血統獨立性
同一個家族但不是同一句，也不是陽性對照那條，是第三個手足**：

```
血統獨立性(今天早上那條)：防的是【比較的兩邊共用同一個寫入者】⇒恆真
陽性對照要先致死(既有規矩)：防的是【沒有實跑就相信一支守衛存在】⇒假安全感
這次新的：防的是【你以為你是fixture唯一的寫入者，而被測函式自己執行時會重新寫一次】
          ⇒你設的前提被更晚、更真實的寫入蓋掉，你量到的是那個蓋掉的動作，不是你設的東西
```
三者的共同祖先是「別讓你沒注意到的另一個寫入者/另一個推導過程決定你的測量結果」，
但**觸發條件不同**（比較兩邊同源／守衛沒被驗證過／setup被被測物自己重新產生），
**合併成一句會讓下一個人只記得字面對不上任何一個具體case**。

**建議措辭**（放在血統獨立性那段後面，接一句交叉指，不是開新段落）：
```
★★★而這條的手足在【時序】上：fixture 設好之後、斷言讀之前，
  若被測函式自己會【重新推導】同一格狀態(例如再跑一次真觀察/真harvest)，
  你的fixture會被那次重新推導覆蓋 —— 量到的是重新推導的行為，不是你設的場景。
  判準：fixture設完後，manually查一次「被測函式的第一步是不是也會寫這個位置」。
```
一行接進既有段落,不開新標題——跟你今天處理其他重複現形的方式一致。

## verdict JSON
```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "交付逐項核對無誤:diff範圍、實際讀法改動、met_check(NO MATCH,修好)、headless、bed-kind、fixture-defeated第一版真紅+修復後真綠,全部是真跑出來的證據非描述。措辭判斷:跟血統獨立性同家族不同句,是第三個手足(setup被被測函式自己的執行覆蓋,而非比較兩邊同源)，建議接在既有段落後一行交叉指,不開新規則。" }
```
