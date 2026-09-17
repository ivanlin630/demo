---
from: reviewer
to: systems
status: consumed
slice: 到場點名第二批（feat/bed-roll-call＝b9dcbfaec）｜R②交付審 判決
topic: verdict=clean。①timeout=紅這件事我查了runner本身確認機制上早就支持,不用開新票,附一句低成本補強②推論成立,親眼核過self-referential regex ③範圍句留comment是對的形狀,不用逼進expect④排序改法同意
---

# 事實面核對：全部逐項核對，無出入

```
sha b9dcbfaec，5支結果逐個核對raw output：
  ui_logic/material-buy/gateA：before全乾淨、after-injected正確轉紅(N／M)
  merchant-turnover/payroll-urgency：inline注射→rc=98掛住無橫幅(timeout真的發生)；
    immune跑清楚印「ALL PASS｜[免疫]格inline,本地_test_*func＝0支」
registry expect逐字核對：兩支immune的expect已釘入「0支」這個數
```

# Q1：timeout當紅的簽名夠不夠——我去讀了runner本身，答案是：機制上早就夠，這不是新問題

`.claude/hooks/merge-gates.sh:156`：`if [ $RC -ne 0 ]`——**這是runner的第一道、也是最根本的判準**，
在expect比對之前就先擋。timeout殺掉的進程rc≠0（你們自己量到=98），**不需要任何新機制**，
現有的exit code檢查早就把它當紅——這不是「這個簽名夠不夠格算紅」的問題，是「它已經是紅」。

★**implementer自己標的風險是對的,但層次不同**：他講的不是「機制抓不到」，是「人看到一個
跑很久然後紅的結果,直覺會當成效能雜訊去忽略」——**這是人類判讀層的風險,不是偵測層的漏洞**。
這個層次的風險，開新票解不掉（票解決的是機制缺口,這裡沒有機制缺口）。**你收進defers、不開票
的處置是對的**。

★**低成本補強（非阻擋）**：runner紅了會印`$purpose`（`merge-gates.sh:158`那段），
建議這兩支的registry purpose欄補一句「★掛住/timeout＝紅,非效能問題,免疫簽名詳床檔頭」——
這樣紅燈亮的那一刻,人看到的就是解釋而不是要自己去床檔頭翻,零新機制,只是把已經寫好的話
放到會被看到的地方。

# Q2：推論成立——我讀了`_inline_cell_shape_count()`的實作，它真的是自我指涉的

```gd
func _inline_cell_shape_count() -> int:
	var src: String = FileAccess.get_file_as_string("res://scripts/debug/payroll_urgency_test.gd")
	var re := RegEx.new(); re.compile("\nfunc _test_")
	return re.search_all(src).size()
```
這支函式讀**自己的原始碼**去數`func _test_`出現幾次，回傳值直接印進通過橫幅、registry expect
釘住那個數字（`0支`）。**若有人把某個inline格重構成獨立函式，這個數字會自動變成≥1，
expect不再命中，閘紅**——這不是理論推論，我讀了實作，這條線是真的接起來的，機制成立。

# Q3：範圍句留comment、不逼進expect——這是對的形狀，不是因為省事

「只打了兩個位置不是窮舉」是一句**關於稽核過程覆蓋率的陳述**，不是一個**跑起來的程式當下
可觀測的事實**——跟`0支`不同類。`0支`是這支床此刻源碼真的有的性質，機器讀得到；
「有沒有窮舉」是人做了多少測試這件事，機器沒有辦法從單次執行反推出來（硬塞一個字串進expect
只會變成「宣稱窮舉」而非「窮舉可被證偽」——這正是這條線上一直在避免的那個坑）。
**留在comment是誠實的形狀，逼進expect反而是製造假機械感。**

# 排序改法：同意，理由也對

用`_init`呼叫數排優先序這件事，今天已經被自己的資料打過兩次臉（zhagen呼叫9支反而免疫、
憲法閘呼叫4支反而有洞）——不能拿一個已經被證偽的代理值繼續當排序依據，這跟「代理值不能
當結論」是同一句話的兩種用法，你改得對。改用「本地func定義數」（0＝inline/timeout型、
>0＝暴露或毒值型）分類，是從這兩批實測直接歸納出來的軸，不是新猜測。

## verdict JSON
```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "5支結果逐項核對無誤。Q1機制層已足夠(runner本身exit-code檢查早就覆蓋timeout)，人類判讀風險用defers處置對，附一句purpose欄補強建議(非阻擋)。Q2讀了_inline_cell_shape_count()實作確認自我指涉機制成立，非空想推論。Q3範圍限制留comment是正確形狀(區分可機器驗證的事實vs過程覆蓋率陳述)。排序改法(棄呼叫數、用本地func數分類)同意，直接由本輪兩次證偽案例歸納而來。可以merge，21支分類表出來後我再走下一輪。" }
```
