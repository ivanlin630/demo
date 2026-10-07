---
from: reviewer
to: systems
status: open
slice: 友善度 F7 收 R²：_check_distance 拆一支來源兩個出口
topic: R② ＝ **ISSUES,一列**｜★你自己加的那條(不准先挑最近再問)——核過邏輯逐字對上要避免的那個情境,方向正確；但找到一個參數對不上的技術缺口：`known_outpost_at`要求owner_id,而`_distance_blockers`的條目形狀{tile_pos,dist,rule}裡沒有這個欄位,照現在這個形狀實際上呼不了known_outpost_at
---

# 0 審了哪棵樹

`origin/main` ＝ `3c1bbb786`。

# 1 ★你自己加的那條——邏輯核對正確，避開了真正的風險

```
裁法：逐筆問known_outpost_at(不是先挑最近再問)；有已知⇒用已知裡最近一筆;全未知⇒
  只說「離某個據點太近」
⇒ 核對：這個順序(先問全部→篩已知→在已知子集裡挑最近)正確避開了你自己點名的那個情境——
  「最近那筆未知、次近那筆已知」時,不會因為演算法在第一步就鎖定全域最近的那一筆而
  放棄回報次近的已知那筆;你描述的風險場景跟裁法的執行順序對得上,沒有邏輯漏洞
```

# 2 找到一個技術缺口：known_outpost_at要owner_id，_distance_blockers的條目形狀沒有它

```
belief_system.gd:545-550 `known_outpost_at(state,observer_id,pos,owner_id)`：
  迴圈比對`rec["tile_pos"]==pos and int(rec["owner_id"])==owner_id`——★必須同時給
  pos跟owner_id兩個條件都對上才算「已知」,這支函式是為「我看過那個位置上、屬於那支隊
  的據點嗎」設計的(:540-544自己的註解),不是「這個位置上有沒有據點」這種owner無關的查詢
⇒ 全repo零個既有呼叫點(git grep確認),它今天還沒被任何production code用過
spec描述的`_distance_blockers`條目形狀是{tile_pos,dist,rule}——★沒有owner_id這一欄
⇒ precheck_camp要呼`known_outpost_at(state,玩家隊,b.tile_pos,???)`時,第四個參數
  owner_id沒有東西可以傳——照現在這個條目形狀,這支呼叫實際上寫不出來
```

## 處置（指出缺口，不代裁要新函式還是擴充欄位）

```
最省事的修法：_distance_blockers掃描時(它本來就在讀真實tile判斷outpost_level!=0)
  順手多讀一個`t.outpost_owner`,把它塞進條目(變成{tile_pos,dist,rule,owner_id})——
  這不是新讀取,是同一次掃描多存一個已經在手上的值;owner_id本身是真值(世界物理),
  跟距離判斷一樣合法,不是這裡要擋的那個洩漏(要擋的是【距離／座標】,不是【這格存不存在
  據點】這件事本身在判斷邏輯裡被讀到)
⇒ 不建議另寫一支owner無關的belief查詢——那是重複一份跟known_outpost_at幾乎一樣的
  邏輯(這個專案這學期已經多次踩過「同一件事兩份实作會漂」那個病),擴充blocker條目的
  欄位是比較小的改動
```

# 3 判決

```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {"claim": "precheck_camp逐筆問known_outpost_at,決定給不給距離名字",
     "file_line": "belief_system.gd:545-550(known_outpost_at要求pos+owner_id同時比對,零既有呼叫點)；_distance_blockers條目形狀{tile_pos,dist,rule}(規劃中,沒有owner_id欄位)",
     "truth": "known_outpost_at的簽名需要owner_id,但_distance_blockers的條目形狀沒有這一欄,照現在規劃的形狀呼叫端寫不出這個呼叫;修法是讓_distance_blockers掃描時順手多存一個已經讀到的t.outpost_owner,不必新寫一支owner無關的belief查詢"}
  ],
  "note": "你自己加的『不准先挑最近再問』那條邏輯核對正確。唯一的缺口是條目形狀少了一欄,補上就能呼叫既有的known_outpost_at,不需要新函式。" }
```
