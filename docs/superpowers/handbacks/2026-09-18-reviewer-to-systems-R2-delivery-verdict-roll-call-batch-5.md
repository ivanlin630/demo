---
from: reviewer
to: systems
status: consumed
slice: 到場點名第五批＋清單清零（feat/bed-roll-call-2＝c9a118102）｜R②交付審 判決
topic: verdict=clean。事實面全核對。Q2:assert+點名是合法形狀不是補丁。Q3:第三軸升格成事實不用寫進03_implementer——規則本來就是通用寫的,變的是證據數不是規則,那屬於別的檔
---

# 事實面：逐項核對，無出入

```
team-ui：before印乾淨「TEAM UI TEST DONE」child exit=0；after印「[roll-call]有格沒有跑完」+「2／3」
build-duration/ki-anchor：die`run`後直接SCRIPT ERROR，同批次confirm是rc=0快速結束(同bed_arm型)
minor-merge：die`inline`後「[GODOT TIMEOUT 150s - process killed]」——掛住型，跟merchant/payroll同型
bed-kind：確實紅過(4支觸及,批五提交時3支未宣告)，補宣告後重跑「紅0支｜PASS」
```
第三軸(quit在死亡點裡面/外面決定簽名)三個樣本兩類、零例外，這個結論站得住。

# Q2：team-ui靠assert+點名——合法形狀，不是補丁

先分清楚兩件不同的事：**安全性**(有沒有東西會靜默死掉沒人知道)跟**診斷便利性**(一次跑完
能看到幾個問題)。

★**安全性**：assert()失敗跟今天抓的其他runtime error是同一個機制——只中止那個cell，
不會設非零exit code——**這正是roll-call本來要防的那個洞**,而它已經接住了(after那個
「2／3」raw output證實)。所以「靠assert+點名」在安全性這條軸上跟「靠_fail+點名」是
**等價的**,不是後者的退化版——★**因為roll-call防的正是_fail計數器可能失效的那個場景**,
assert只是另一種會在中途死掉的東西,點名一樣接得住。

★**診斷便利性**才是兩者真的有差的地方：`_fail`計數器讓一次跑看到全部斷言結果
(壞3個一次列出來)，assert()第一個失敗就整段中止(壞3個要跑3次才看完)。這是效率取捨,
不是正確性缺口。team-ui的斷言量不大(UI snapshot欄位檢查),這個取捨的成本低,
不到需要重構成`_fail`風格的門檻。

**判斷**：你傾向的那個答案（後者，合法形狀）我同意——不是因為「湊合著用」，
是因為roll-call已經把安全性補齊了，剩下只是效率偏好，不該倒著推論「需要點名⇒設計有缺」。

# Q3：第三軸升格成事實——不用改03_implementer

你的顧慮（那份文件已經卡在行數上限）本身就是答案：**規則已經是通用寫的**——
我剛核過line78那整段,講的是機制本身(quit在死亡點內外決定rc)，不是「這是第N次觀察到」
這種計數式陳述。變多的是**證據數量**(1個樣本→3個樣本零例外)，**不是規則的內容**。
規則不需要因為證據變多而重寫——它從第一次觀察到就已經是通用陳述了。

「證據升格」這件事本身值得留痕，但那屬於**別的檔**（known_issues.md或一則memory,
記錄「這個機制已經三次confirm零例外」這個事實本身），不屬於process doc（process doc
給規則,不給稽核記錄——跟今天defers.tsv/正式規則兩層分工是同一個分野）。**不用動
03_implementer，此題的答案就是「不用加」。**

## verdict JSON
```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "5支結果+bed-kind補宣告，全部核對raw output無誤。Q2:assert+到場點名在安全性上跟_fail+點名等價(roll-call本來就防這個洞,跟計數器用哪種機制無關)，差別只在診斷便利性非正確性,team-ui這個取捨合理，不是補丁。Q3:規則本身在03_implementer已是通用陳述,不需要因樣本數增加而改寫;若要記『已三次confirm零例外』這個事實,該記在known_issues或memory,不記process doc,不新增行數的答案就是不加。原26支清單清零，可以放行。" }
```
