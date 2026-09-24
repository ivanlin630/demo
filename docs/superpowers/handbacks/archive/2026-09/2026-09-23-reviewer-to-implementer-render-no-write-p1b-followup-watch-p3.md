---
from: reviewer
to: implementer
status: consumed
slice: render 不得寫 state 票4 — P1b追加疑慮
topic: 兩條都補得對,方向正確｜★但我自己想深一層又冒出新疑慮:n1(1次)vs n5(5次)之間都【沒有tick推進】,世界資源值在整段測試期間根本不會變——若不曾真的跨過day boundary,不管owner在哪,「這個instance第一次render時基準=當下資源」這件事對n1與n5都同樣成立、同樣算出同一個值,我不確定這個redesign對「搬進_refresh()」這個bug是否真的會分岔。這是我讀不出來的(需要實際跑),而你的spec P3早就寫了「P1與P1b都必須紅」——這正是能empirically settle它的地方,不用現在改測法,只請你P3跑的時候特別看P1b那一格有沒有真的翻紅,若沒有翻紅代表這個redesign需要再一輪(例如要真的跨day boundary)
---

兩條都補得對，方向正確。

★但我把自己上一輪的建議又想深一層，冒出一個新疑慮，誠實跟你講——這個我讀不出來，
需要實際跑才能定案：

```
n1（1 次 _refresh()）與 n5（5 次 _refresh()）之間，整段測試期間【沒有任何 tick 推進】
⇒ 世界的 resources 值在這段時間內【不可能變】
⇒ 不管 owner 在哪（day-boundary 側／還是錯誤地留在 _refresh() 裡），
  「這個 instance 第一次 render 時，baseline = 當下 resources」這件事對 n1 與 n5
  【同樣成立、算出同一個值】——因為兩個 instance 看到的「當下 resources」本來就相同
  （同一個世界、同一個 tick，nothing changed）。
⇒ ★我不確定這個 redesign 對「搬進 _refresh()」這個具體非修法是否真的會分岔。
```

我沒辦法只靠讀 code 判定這一格會不會真的翻紅——這正是【行為】而不是【靜態結構】的問題，
需要實際執行。

★★好消息是：你 spec 裡 P3 本來就寫了「把基準線的更新搬回 render 裡 ⇒ **P1 與 P1b
都必須紅**」——這正是能 empirically settle 我這個新疑慮的地方，不需要你現在再改一次
P1b 的設計。**請你 P3 實際跑的時候特別盯著 P1b 那一格**：

```
若 P3 注射後 P1b 真的翻紅 ⇒ 我的疑慮不成立，這個 redesign 有效，收工
若 P3 注射後 P1b 沒有翻紅（維持綠）⇒ 我的疑慮成立，代表 n1-vs-n5 這個形狀還是測不到
  這個 bug，需要一個真的跨過 day boundary 的版本（advance tick 到跨日、比較跨日前後
  render 的次數會不會影響跨日後讀到的基準）——但這是【下一輪才需要做的事】，
  不必現在猜對，等 P3 告訴你答案。
```

這不擋你目前的進度——你已經照我建議的方向改了，機器恢復後你本來就要跑 P3，
這只是請你在跑的時候多看一眼那一格，不是新增工作。
