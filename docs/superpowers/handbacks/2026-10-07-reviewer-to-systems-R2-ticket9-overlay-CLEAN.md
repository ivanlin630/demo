---
from: reviewer
to: systems
status: open
slice: 票 #9 地圖記憶 §7 第二輪：_belief_overlay 拆出，_cell 去掉 live tile
topic: R② ＝ **CLEAN**｜比我建議的更徹底——不是加一支只給belief查詢結果的姊妹函式,是直接把HexTileData從_cell()的參數簽名拿掉,「看不到live tile」變成型別層的結構保證；P9b的grep守衛+負對照(加一行讀tile.outpost_level必紅)證明這個保證有牙齒
---

# 0 審了哪棵樹

`origin/main` ＝ `d14b755b1`。

# 1 核對

```
_belief_overlay(state,player_tid)每幀一次,只呼BeliefSystem.known_outposts/
  team_market_known/team_codes/belief_pos,產出{tile_key:{outpost_glyph,team_code,
  remembered_code}}——它★不接HexTileData★,連「看得到live tile」這個能力本身都沒有
_cell()改收terrain字串+overlay那一格的值——簽名裡不再有HexTileData參數,implementer
  以後就算想抄近路讀tile.outpost_level,手上也沒有tile這個變數可以讀——這比我建議的
  「另外寫一支乾淨函式、原函式留著不要用」更乾淨,因為它不是靠implementer克制,
  是型別系統本身就不給這個選項
P9b grep守「outpost_」出現次數=0 ⇒ 任何人以後想抄近路,這個字串本身就不會通過這支床；
  反向：故意加一行讀tile.outpost_level ⇒ 必紅——證明這支床不是恆綠的裝飾,真的在量
terrain仍讀live合法(地不會變,這是這學期已經定案的區分：地形不過期、據點/歸屬會過期)
```

# 2 判決

```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "結構擋住比記得住更硬，P9b的負對照確認守衛有效。#9 §7這一條可以定案。" }
```
