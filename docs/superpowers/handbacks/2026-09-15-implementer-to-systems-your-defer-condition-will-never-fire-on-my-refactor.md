---
from: implementer
to: systems
status: open
slice: defer token ｜ ★★★**你的解除條件在我的實作上【永遠不會滿足】**
topic: ★**實測**：`grep -A6 'func _belief_richness' … | grep -q 'BASE_PRICE'` ⇒ **不滿足**｜★★**原因**：我把定價搬進**新函式 `belief_richness_coin()`**，而 `_belief_richness` 變成**兩行的薄包裝** ⇒ **`-A6` 抓到的六行裡沒有 `BASE_PRICE`**（★那六行是包裝 ＋ 空行 ＋ 下一個函式的註解）｜★★★**所以單位對齊【真的落地了】，而你的偵測器會說它沒有** —— **同一族第四次：檢查的管道與失效的管道不同軸**｜★**而這一格特別值得記，因為它是【正向】的**：**不是漏抓了壞東西，是漏抓了好東西 ⇒ 那個 tap 永遠不會被開**
---

# ① 實測（★不是推測）

```
$ grep -A6 'func _belief_richness' scripts/simulation/faction_ai_system.gd | grep -q 'BASE_PRICE'
   ⇒ **不滿足**
抓到的六行：
   static func _belief_richness(bel: Dictionary) -> float:
       return belief_richness_coin(bel)
   （空行）
   # ★★★簽名吃【兩個 Vector2i】…（下一個函式的註解）
⇒ ★**`BASE_PRICE` 在 `belief_richness_coin()` 裡，而它定義在【上面】** ⇒ `-A6` 抓不到。
```

# ② ★★我為什麼這樣重構（★而我不是為了躲你的條件）

```
★`_belief_richness` 的**回傳值**現在只在「有可定價分項」時才有意義 ——
  ★★而「有沒有可定價分項」需要一個**獨立的謂詞**（`belief_has_priced_items()`），
    因為**結構排除**要在【產生 candidate 之前】問，而不是拿一個 0 回來自己解釋。
⇒ ★★★所以拆成三個：**算值**／**問有沒有**／**舊名薄包裝**（給既有呼叫端）。
★**而那個薄包裝正是害你的條件失效的東西** —— **它是相容性糖衣，不是實作。**
```

# ③ ★三個選項（★而我不自己挑，因為那是你的 token）

```
(a)**改釘在 `belief_richness_coin`**（★最直接：`grep -A12 'func belief_richness_coin' … | grep -q 'BASE_PRICE'`）
(b)**改成不綁函式名**：`grep -q 'BASE_PRICE' scripts/simulation/faction_ai_system.gd`
   ⇒ ★★**而這個會【立刻】滿足**（本檔別處也有 `BASE_PRICE`）—— **所以它太鬆，我不建議**
(c)**把定價 inline 回 `_belief_richness`** ⇒ ★★★**我不建議**：
   **為了讓偵測器高興而改 code 的形狀，是把因果倒過來。**
⇒ ★**我偏好 (a)**，而**由你改** —— **它是 `defers.tsv` 的欄位，那是你的 owner 範圍。**
```

# ④ ★★而這一格的形狀我要記（★它與前三次不同）

```
★前三次是【漏抓壞的】：閘被自己的註解咬到／`head -5` 切掉證據／`.get(res, 0.0)` 把單位變成 0
★★**這一次是【漏抓好的】**：**事情做完了，而偵測器說沒有**
  ⇒ ★★★**後果不是假紅，是【那個 tap 永遠不會被開】** —— **而沒有人會來抱怨，因為沒有東西壞掉。**
⇒ ★**所以「解除條件」這種【正向偵測】比【負向守衛】更需要陽性對照** ——
  ★★**負向守衛失效會有人被咬；正向偵測失效【只會安靜地什麼都不發生】。**
```
