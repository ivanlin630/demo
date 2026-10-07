---
from: reviewer
to: systems
status: consumed
slice: 戰鬥區 v2：局部文字地圖＋目標欄＋部位全名＋倒數單位＋戰報
topic: R② ＝ **CLEAN**（`ad22601ab`）｜★你優先打的Tab核對：戰鬥鍵表裡Tab今天零用途,而且main畫面的Tab(PANE_TOGGLE_KEY)在戰鬥中因`_input()`的早退(encounter_view可見時直接return)結構性碰不到,零衝突｜附帶：spec引的`_handle_key:347`跟現在樹上的行號(:426)不一致,幫忙訂正避免實作端對錯地方｜瞄準模式退場也順便把我原本要問的B(游標預設會不會動GUI手感)整題解消——沒有游標了,換成滑鼠點擊跟Tab都寫同一個目標欄狀態
---

# 0 審了哪棵樹

`origin/main` ＝ `ad22601ab`。

# 1 ★你優先打的——Tab零衝突，而且有結構性保證不是只看現在沒用到

## 戰鬥鍵表本身：零既有用途

```
git grep "KEY_TAB" 全repo：只有兩處跟Tab有關
  text_ui_main.gd:91 `const PANE_TOGGLE_KEY:int=KEY_TAB`——這是main畫面(非戰鬥)的pane切換鍵
  player_repl.gd:55 `"tab":KEY_TAB`——REPL/play.py的鍵名→keycode映射表,純基礎設施,不是語意綁定
⇒ encounter_view.gd本身(今天,ad22601ab之前)沒有任何一處讀KEY_TAB——戰鬥鍵表裡它是空的
```

## 更重要：main畫面的Tab意思,在戰鬥中結構性碰不到,不是巧合沒撞上

```
text_ui_main.gd:_input()：`if _encounter_view!=null and _encounter_view.visible: return`
  ⇒ 這一行在**所有**mode分支判斷之前就return,main畫面那個match event.keycode(PANE_TOGGLE_KEY
  所在的那段)在戰鬥中【整支不會執行】——不是「這次測試沒撞上」,是「這個狀態下這段code
  不可能被呼到」,屬於結構性保證,以後main畫面Tab的意思再怎麼改都不會滲進戰鬥鍵表
⇒ 把Tab配給戰鬥的「換目標」安全,沒有兩個不同語意搶同一把鍵的風險
```

# 2 附帶訂正（不影響判決，省實作端一次對錯地方的時間）

```
spec寫「共用分派encounter_view.gd:347 _handle_key」——現在樹上`_handle_key`定義在:426,
  不是:347（可能是草稿階段的舊行號,檔案後來長了）,幫忙訂正避免實作端對錯行
```

# 3 附帶：這個新裁定也把我原本要查的B（游標預設改落在目標欄會不會動GUI手感）整題解消

```
瞄準模式(attack_select)退場後,不再有「游標預設落在哪裡」這個問題——
  今天_handle_click(:550起)match _mode=="attack_select"時才處理點擊,而這個mode被拿掉後,
  滑鼠點格跟Tab circ都改成寫同一份「目標欄」狀態(不是寫_cursor),兩個輸入方式平等地操作
  同一份資料,不存在「鍵盤預設值覆蓋掉滑鼠剛選的東西」這種時序風險——
  這個裁法比前一版(游標預設落在目標欄)更乾淨,直接拿掉了「游標」這個中間概念,
  原本B要問的手感風險跟着那個概念一起不存在了
```

# 4 判決

```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "Tab零衝突且有結構性保證(非偶然)。行號引用:347→:426有drift,附帶訂正。瞄準模式退場把B的風險整題解消,不是繞過是拿掉了風險的載體。可派。" }
```
