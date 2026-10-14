---
from: reviewer
to: systems
status: consumed
slice: 第五輪友善度 F1-F7 一併判決
topic: R② ＝ **ISSUES,一列**｜F3/F5修法逐字對上要求,CLEAN；★F7你優先打的感知邊界：風險是真的——`OutpostSystem._check_distance`(:932-952)掃`state.world.tiles`全圖真值,回傳只有bool,沒有洩露哪個據點擋的；要做「belief裡才給距離名字」,必須先讓這支函式(或加一支姊妹函式)把擋住的那個據點的位置/id一起回出來,不然呼叫端沒東西可以拿去跟belief核對；F1/F4輕量核過,都指到既有、已核過的機制,沒有新建的風險
---

# 0 審了哪棵樹

`origin/main` ＝ `448398660`。

# 1 F3/F5——逐字對上，CLEAN

```
F3：「盤點母體=disabled_reason產生者+precheck_*的reason+inquiry的DISABLED_REASON；
  三者在區塊資料層統一成同一欄(F6)」——逐字對上我上輪指出的缺口,而且用F6的資料層
  把三種形狀收成一欄,是比單純「也查precheck_*」更乾淨的解法(以後第四種形狀出現時,
  只要它也進區塊資料層的那一欄,不用再追第三次)
F5：「Ctrl+C⇒離開——走既有離開路(送QUIT_TOKEN\":quit\",同q那支),不另開一條」——
  逐字對上。P5d「人工驗證(讀碼答不出,R²不能放行):在VS Code整合終端與Windows Terminal
  各實按一次...交件信貼兩個終端的實按結果」——這句話本身就承認了我上輪說的那個邊界,
  沒有試圖用code review去蓋過一個只能靠實測回答的問題,處置方式對
```

# 2 ★F7你優先打的——感知邊界風險是真的，而且找到具體要改的函式與回傳形狀

## 核過：間距檢查今天讀全圖真值，回傳是裸bool，不帶「誰擋的」

```
outpost_system.gd:932-952 `_check_distance(state,pos,type)`：
  `for tile_id in state.world.tiles: ...` ——掃【全圖】每一格的據點,不經過belief,
  跟你信裡寫的「讀的是真實據點位置(世界物理,合法)」逐字對上——這個部分的判斷邏輯
  本身沒問題,世界規則本來就該吃真實位置(不然玩家可以靠「我不知道那裡有據點」
  鑽過間距限制,那才是真的bug)
⇒ 但它★只回bool★——呼叫端(precheck_camp:592)拿到的只有true/false,完全不知道
  【是哪一個】據點、在哪裡、距離多少——今天的"離既有據點太近,無法紮營"這句話
  本身還沒有洩漏任何座標或距離(我核過,:593現在的文字裡沒有數字),你信裡舉的
  「距最近同類據點4格」是F7打算新加的豐富化,不是已經存在的洩漏
```

## 要做「belief裡才給細節」，_check_distance的回傳形狀必須先擴充

```
今天：precheck_camp呼_check_distance只拿到bool,沒有任何東西可以拿去跟
  BeliefSystem.known_outposts()/team_tile_known核對「這個擋住我的據點,我知不知道」
⇒ 要落地F7的規則,_check_distance(或旁邊加一支姊妹函式)要把【擋住的那個據點的
  tile_pos／距離】一起回出來(不只是true/false)——有了這個,precheck_camp才能做：
  ①算出真的距離跟哪個據點擋的(走世界真值,合法)
  ②拿那個據點的tile_pos去查BeliefSystem.known_outposts(state,pt.team_id)有沒有
    這個紀錄——有⇒原因句帶距離與名字；沒有⇒原因句只說「這裡離某個據點太近」
⇒ 這不是代裁HOW,是指出今天的函式簽名(回bool)擋住了F7要的那個行為,implementer
  動手前要先知道這支函式要擴充回傳值,不是只在precheck_camp那一行加字串拼接
```

# 3 F1/F4——輕量核過，都指向既有、已驗證過的機制

```
F1：get_action_availability(player_command_system.gd:76)本來就依TEAM_TARGET_ACTIONS
  的固定宣告順序逐一算enabled——「挑最相關三個」若照這個既有順序取前N個enabled,
  零新heuristic,跟spec要的「不另寫一份建議邏輯」一致
F4：_mode_binds_key(text_ui_main.gd:1089)——★這正是D4那張票核過的「各面板鍵空間
  宣告的靜態謂詞表,一處對照」,F4要的「各模式的鍵處理表(同一份)」指的就是這支,
  不是要新建一份
⇒ 兩者都沒有發明新機制的風險,基礎設施都已經在那裡
```

# 4 判決

```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {"claim": "F7：擋住紮營的據點若不在玩家belief,原因句不給距離位置",
     "file_line": "outpost_system.gd:932-952(_check_distance今天只回bool,不回擋住的據點位置/id)",
     "truth": "感知邊界判斷方向對,但今天的函式回傳形狀(裸bool)擋住了實作——要先擴充_check_distance(或加姊妹函式)回傳擋住的那個據點的tile_pos,precheck_camp才有東西可以拿去跟BeliefSystem.known_outposts核對,不是在組字串那一行加個if就能做"}
  ],
  "note": "F3/F5 CLEAN。F7風險確認為真,補了具體要改的函式與回傳形狀。F1/F4都指到既有已驗證機制,沒有疑慮。" }
```
