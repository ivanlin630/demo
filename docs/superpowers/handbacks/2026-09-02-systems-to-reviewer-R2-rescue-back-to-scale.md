---
from: systems
to: reviewer
status: open
slice: 自救建田導回設施仲裁（#35 修法）
tier: R2
topic: ★藍圖裁(b)導回 `_pick_facility` 同秤,拒「佔用有界」——急症走秤不走走廊;★★★而我查出這【不是新實驗,是恢復既定範式】:`_pick_facility:5147` 的註解自己寫著「S4：移除飢餓 override——S2 survival-crush 已讓餓隊 farming score 主導」,而 `SURVIVAL_CRUSH=5.0` 就在 `_facility_score` 裡 ⇒ 同一個病 S4 治過一次,`_food_rescue_eval` 是漏網的第二條走廊;★要你打:導回後「續蓋 in-progress」那半會不會被誤殺
---

# ★①背景（藍圖已裁，不用審）
**急症走【秤】不走【走廊】**：繞過仲裁的特權通道 ＝ 補丁閘 ＝ **秤缺急迫項的補償貼**。
「餓死是急症」的**正確表達位置是秤上的 survival need 權重**。
★**佔用有界【不另立】**（同秤下持續蓋田自然被高 util 項目取代，持守／沉沒照常秤）。
★★**我的顧慮被反轉成驗收**：**導回後若餓死出現 ＝ 秤缺急迫項的證據 ⇒ 開「修秤」票，禁回頭開走廊。**

# ★★★②而我查出這不是新實驗 —— **是恢復既定範式**
```
`faction_ai_system.gd:5147`（`_pick_facility` 內註解，原文）：
   「S4：移除飢餓 override —— S2 survival-crush 已讓餓隊 farming score 主導(S2 gate 驗…)」
`:5241  const SURVIVAL_CRUSH: float = 5.0`  ／ `_facility_score`：「餓→農田 score 壓過發展設施，urgency² 軟連續」
⇒ ★★同一個病【S4 已經治過一次】：那次移除的是【飢餓 override】
⇒ ★★★而 `_food_rescue_eval` 是【漏網的第二條走廊】—— 它從不經過 `_pick_facility`（零參照）
```
★**所以驗收的預期很明確**：**餓死不該出現**（秤上已有 `SURVIVAL_CRUSH`）；
★★**若出現 ⇒ 那是 `SURVIVAL_CRUSH = 5.0`（TEST VALUE）調不夠的證據** ⇒ **修秤，不是回頭開走廊。**

# ★★③形狀
```
★`_food_rescue_eval` 保留【它判斷「該不該救」的那半】（food_days／burn／faction_owns 等前置）
★★而它決定【蓋哪個設施】的那半 ⇒ 改呼 `_pick_facility`（同秤、同 argmax）
★★★關鍵：★不要「先算好 facility 再送去驗證」—— 那是換一個名字的走廊
   ⇒ 由 `_pick_facility` 回傳的 winner 才是要蓋的東西，即使它不是 farming
```

# ★★★④要你重點打的一件
```
`_food_rescue_eval` 有一段【in-progress 續蓋】：「自己正在蓋短工期產糧設施 → viable（sustain）」
⇒ ★導回同秤之後，那個「續蓋」還走不走得通？
   ★★若 `_pick_facility` 只看【未建設施】(它的 argmax 是「未建設施中最高者」)，
      那【已經在蓋的那座】根本不在候選裡 ⇒ ★★★續蓋會被誤殺，而症狀會是「蓋到一半換目標」
⇒ ★這一格我【沒有查完】—— 請你查 `_pick_facility` 對 in-progress 的處理，
   並判：續蓋該走秤、還是它本來就不是「選設施」而是「繼續現有工程」（後者可能不該進本刀）
```

# ⑤驗收
```
①★餓隊床：導回後【餓死不該出現】——★★而若出現，那是【證據】不是【失敗】：開修秤票，禁回頭開走廊
②★★mint 排得進去嗎：g1a 那條 baseline 行應轉綠（★而若仍紅，要說出是哪一格擋住）
③★★★`fp` 會變（行為修正）⇒ 差在哪要說得出來；★特別要印「自救路的 facility 選擇改變了幾次、改成什麼」
④續蓋不被誤殺（見④）——★若 reviewer 判它不在本刀，這條改成「續蓋次數不變」的回歸斷言
```
