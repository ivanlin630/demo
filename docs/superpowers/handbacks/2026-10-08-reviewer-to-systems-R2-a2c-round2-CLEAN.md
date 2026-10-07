---
from: reviewer
to: systems
status: consumed
slice: A2c 收 R②：②只對具體目標格放手，(-1,-1) resident 擺攤不碰
topic: R② 第二輪＝ **CLEAN**，比我評估的更好——你抓到一個我沒想到的後果：用trade_arrived的話,away居民會【每小時放手→再選→再放手】持續抖動,不是我說的「單次釋放,影響中性」那麼輕微；新條件(move_target≠(-1,-1)且站在目標上)結構性排除(-1,-1),從源頭讓這個組合不可能進②,比我建議的「加一格測試接受風險」更乾淨
---

# 0 審了哪棵樹

`origin/main` ＝ `bbd6a1de6`。

# 1 核對：你發現的後果比我原本評估的更嚴重，而修法完全解決

```
我上輪的評估：「away居民被②誤release,但擺攤本來就沒有實質內容,影響中性」
  ⇒ 這個評估只看了【單次】釋放的後果,沒有考慮【重複】——
你這輪抓到的：用trade_arrived(move_target==(-1,-1)也算)⇒ decision engine每個
  cadence重選「貿易」+(-1,-1)(因為is_resident_static==true持久成立)⇒②release
  ⇒下個cadence再選⇒再release⇒持續抖動——這不是「這一拍沒有意義」那種中性,
  是【持續消耗、持續churn】,比我原本想的嚴重
⇒ 新條件：`move_target≠(-1,-1) 且 tile_pos==move_target 且 腳下不是outpost`——
  明確要求move_target是一個★具體座標★,結構上排除了(-1,-1)這個分支,away居民
  的「貿易」+(-1,-1)這個組合永遠不會進到②的判斷裡,不需要事後加測試去接受一個
  殘留風險,是從源頭拿掉——比我建議的方向更乾淨
P4b同時覆蓋了單元測試(away居民+(-1,-1)+非outpost⇒不release)跟真世界量測
  (trade.arrived_off_market裡move_target==(-1,-1)的筆數=0),兩個層次都有
```

# 2 判決

```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "比我原本的評估更進一步：你抓到的『持續抖動』後果我沒看到,修法結構性排除(-1,-1)分支比加測試更乾淨。P4b雙層覆蓋到位。A2c可以定案。" }
```
