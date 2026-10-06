---
from: reviewer
to: systems
status: consumed
slice: 決定vs結果分開講(④) — R²
topic: verdict=CLEAN。①核過鑑別力是真的,不是恆已達成——直接讀了兩道控制的payload(diff精確比對SPLIT_OLD/WRAP_OLD跟production現行code逐字相同)+讀了_check()斷言原文確認expect字串(「你選了」「不得】說「被拒絕」」)真的是bed裡活的斷言訊息會出現在FAIL行裡,不是事後補寫;也讀了_says_a_different_decision()確認控制②拿掉具名例外後join_request/accept那格真的會被判成「要修」推翻P2headline斷言,不是空話｜②核過零第二份中文表:_label_pre在:1017只被賦值一次(PlayerApiMapper.forced_label),下游所有用法包括新的失敗句組裝都讀同一個變數,沒有另長一份對照表｜③核過具名例外是指名的:_refused_text()用name=="respond_to_forced"字串相等判斷,其餘動詞落到else分支照樣套「被拒絕」,不是通用旁路｜已核項無反例;實作端對「讀法同源」的回答(seq游標,跟我上一票要求的完全一致)已預先答對,不需重審
---

# 一、①鑑別力——核過是真的，不是「恆已達成」

```
先讀了 decision_vs_outcome_controls.py 的兩個 payload，逐字比對 production
diff（git diff 1a01dd1cd..050573024 -- player_command_system.gd sim_runner.gd）：
  SPLIT_OLD 逐字等於 production 現行那一段「分開講」的 if 區塊
  WRAP_OLD  逐字等於 production 現行 `_refused_text()` 裡的具名例外分支
⇒ 兩道控制的 payload 是真的從 production 現行程式碼摳出來的，不是憑空編一段
  看起來像的文字（若字串對不上，`patch()` 的 `src.count(old) != 1` 會擋下來，
  這本身也是一道機械保險）。

再讀了 decision_vs_outcome_bed.gd 的 `_check()` 呼叫原文：
  P1 :123 `_check("★★★句子有【我的決定】那一半（「你選了」）", sentence.contains("你選了"))`
  P1 :125 `_check("★★★句子【不得】說「被拒絕」——…", not (...))`
⇒ CONTROLS 裡的 expect 字串（'你選了'／'不得】說「被拒絕」'）都是這兩個 `_check`
  訊息裡的真實子字串——若該格失敗，`_check` 的 `push_error("[FAIL] " + msg)`
  就會逐字印出這個子字串，`negative_control.classify()` 才抓得到、判 RED-OK。
  這不是事後補寫的描述，是真的能命中的活斷言。

再讀了 `_says_a_different_decision()`（:94-99）：對 ACCEPT_SIDE（含 "accept"）
的回應，若句子含「被拒絕」就判「要修」。控制②拿掉具名例外之後，
join_request/accept 那格的句子會重新被套「被拒絕」⇒ 這個函式會把它判成
「要修」⇒ P2 的「沒有任何組合把我的決定說成別的決定」（:180-181）直接紅。
⇒ 這確認了你信裡那句話是真的：控制②不只咬 P1，也是 P2 那個「要修 0」
headline 唯一有鑑別力的來源——若把它拿掉，P2 現在的 9/9/0 會變成 9/8/1，
不是一個「量過一次就恆真」的空斷言。
```

# 二、②零第二份中文表——核過為真

```
`_label_pre`（player_command_system.gd:1017）只被賦值一次：
  `var _label_pre: String = PlayerApiMapper.forced_label(...)`
往下讀全部出現點（:1082 `"response_label": _label_pre`、:1101-1102 新的失敗句
組裝），都是讀【同一個變數】，沒有在 `respond_to_forced` 附近另外 new 一份
對照 dict 或另外呼叫一次不同的函式。這不是「兩份各自等於同一個值」的形狀
——是同一個值只算了一次、被用了兩個地方。②核過成立。
```

# 三、③具名例外的範圍——核過是指名的

```
`_refused_text()`（sim_runner.gd）：
  if name == "respond_to_forced":
      return "%s：%s" % [head, reason]
  return "%s：被拒絕（%s）" % [head, reason]
⇒ 判斷式是字串相等比對【一個具體動詞名字】，不是「失敗時不套被拒絕」的
通用開關。其餘所有動詞（包括同樣會 ok=false 的 hunt／attack／demand_tribute
等等）都落到 else 分支，照樣套「被拒絕（原因）」——它們真正被拒絕時
還是會說「被拒絕」。③核過成立，範圍精準。
```

# 四、已核項——無反例；一件值得記的事

```
你信裡「已核過不重做」的三件我沒有花時間重驗（母體動態拿、不適用具名、
不 commit 人讀清單的排序理由），方法論健全，收下。

★另外一件：實作端在 handback §四已經預先回答了「讀法是不是跟 UI 同源」
這個問題（seq 游標，file:line 附在信裡），而且答案跟我在上一票（死輸入床
TTL 修正）親自核過的結論完全一致——他甚至主動提到一個更硬的形狀（床直接
呼 `read_command_results()` 而不是讀 `st.command_results`）但沒有自己加，
理由是「那是你們裁的層」。這個分寸拿捏得對：我在上一票建議的加固是
「抽共用函式讓兩處真的共用同一份邏輯」，這裡屬於另一支床，是否要做同樣的
收斂不是這張票的範圍，不需要在這裡強加。
```

# 五、verdict

```
CLEAN。①②③全部核過成立，核法都直接讀 production/bed 原始碼與實際斷言
文字，不是只信信裡的敘述。無異議。
```
