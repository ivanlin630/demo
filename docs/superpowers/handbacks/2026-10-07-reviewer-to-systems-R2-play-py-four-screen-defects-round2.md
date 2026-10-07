---
from: reviewer
to: systems
status: open
slice: play.py 真跑四個畫面缺陷＋E2E 補四格
topic: R② 第二輪＝ **ISSUES，一列**｜D1/D2 CLEAN(逐字對上要求)｜D4：「配發時跳過全域鍵」只解決了【分配】那一半,沒解決【派送】那一半——`_handle_interact_mode`自己的A-Z分支(:1879)今天不管有沒有列出,只要是A-Z就不會落回主match block的KEY_X/KEY_G邏輯,「全域鍵永遠全域語意」需要這支函式自己也認得「這是保留的全域鍵」並轉呼同一段邏輯,不是只靠配發表排除就自動成立
---

# 0 審了哪棵樹

`origin/main` ＝ `4002a4fd6`。

# 1 D1／D2——CLEAN

```
D1：點名text_ui_main.gd:288的source欄+text_ui_view.gd:246無debug閘,逐字對上我上輪要求
D2：沿用_page_skylight_fields宣告式清單+有寫入者值0照印的邊界格,逐字對上要求,也引了:1475-1478
  跟:1515-1526兩個既有先例當佐證,做得比我要求的更完整
```

# 2 D4——分配端修了,派送端的洞還在

## 架構核對：_interact_mode開著時,主match block的KEY_X/KEY_G邏輯今天【到不了】

```
_input()(:374-425)：_interact_mode為true時,:405-407 `_handle_interact_mode(keycode); return`
  ⇒ 直接return,不會往下走到:426開始的`match event.keycode:`
主match block(:465,474,476)：KEY_SPACE推進一天／KEY_X推進一小時／KEY_G開數字輸入——
  這些邏輯★只存在於這個match block裡★,而這個match block在_interact_mode開著時永遠不會執行
_handle_interact_mode自己的A-Z分支(:1879)：`if keycode>=KEY_A and keycode<=KEY_Z:`
  今天是【無條件】攔截——不管這個字母是不是forced_interaction列出的回應,都進這個分支,
  列出了就dispatch回應,沒列出就印LETTER_NO_RESPONSE_MSG,★從不會去呼main match block裡
  KEY_X/KEY_G真正該做的事(推進時間／開輸入模式)
```

## 這代表「配發時跳過全域鍵」這句話還不夠

```
新文字：「強制回應的字母配發時跳過全域鍵(字表一處)⇒全域鍵永遠是全域語意,#10成立」
⇒ 這句話確保的是：X／G【不會被分配成某個forced_interaction回應選項的字母】——這個部分做到了,
  配發表排除X/G之後,:1883的`li<fr_k.size()`永遠不會在X/G上命中一個真回應
⇒ ★但「沒有命中真回應」在今天的code裡,下一步是印LETTER_NO_RESPONSE_MSG(:1887-1888),
  不是「轉去執行KEY_X的全域語意」——這兩件事是不同的程式碼路徑,配發表排除只保證了
  第一件(不會誤觸回應),沒有保證第二件(會正確觸發全域語意)
⇒ 「全域鍵永遠是全域語意」這個結論,今天的架構下【還需要_handle_interact_mode自己認得
  「這把鍵是保留的全域鍵」】,然後呼叫跟main match block KEY_X/KEY_G【同一段邏輯】
  (不是另外抄一份,同一支函式兩處呼,否則又是本票一直在修的「兩份各自漂」那個病)
```

## 處置

```
補一句明確指到實作點：_handle_interact_mode的A-Z分支(:1879)最前面要加一個檢查——
  若keycode在那份「全域鍵字表」裡,不進forced_interaction swallow,改呼main match block
  KEY_X/KEY_G那段邏輯用的【同一支函式】(目前那段邏輯是inline寫在match裡,可能要先抽成
  一支共用函式,兩處都呼它)——而不是只改配發表就假設它會自動接上
★★而這不只是_handle_interact_mode一支：如果_handle_intel_mode/_handle_recruit_mode/
  其他有submode的handler也各自有自己的A-Z swallow,同樣的洞要逐一查,我這輪只核了
  _handle_interact_mode(D4原始file:line指到的那支),其餘沒時間逐一核,請實作端自己查一次
  有幾支submode handler做了同樣的事
```

# 3 判決

```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {"claim": "D4：強制回應字母配發時跳過全域鍵⇒全域鍵永遠是全域語意,#10成立",
     "file_line": "text_ui_main.gd:405-407(_interact_mode時main match block到不了)；:465,474,476(KEY_SPACE/X/G的全域邏輯只在main match block)；:1879-1888(A-Z分支無條件攔截,沒列出時印LETTER_NO_RESPONSE_MSG而不是轉呼全域邏輯)",
     "truth": "配發表排除全域鍵只解決了『不會誤配給回應選項』,沒解決『按下時真的執行全域語意』——這兩件事是不同的程式碼路徑;_handle_interact_mode的A-Z分支要自己認得保留字並轉呼main match block同一段邏輯(建議抽共用函式),不是靠配發表自動接上;且要查其餘submode handler是否有同樣的A-Z swallow"}
  ],
  "note": "D1/D2 CLEAN可以先定案。D4補完那句落地指令,或確認已經有別的機制讓main match block的邏輯被重用,再一起交。" }
```
