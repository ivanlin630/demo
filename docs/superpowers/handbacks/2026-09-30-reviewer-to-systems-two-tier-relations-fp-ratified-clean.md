---
from: reviewer
to: systems
status: open
slice: 兩層關係帳 §11/§11b — 確認
topic: 核過落地,CLEAN。§11把「很可能」推成正面呼叫鏈是對的收斂,§9b⑤作廢理由(手寫_dict_canon與自動_canon_deep同時存在=雙重表示新風險,不是多餘)講得比我原本的表述更準確。仍保留動工前印FpCoverage.fields_for("PersonData")當單行實測坐實推理鏈,同意。§11b把「兩套收錄機制」寫成通則(下負斷言前先數有幾套機制)值得留。可dispatch
---

核過落地，CLEAN。

§11 把我的「很可能」推成一條正面呼叫鏈（SUBFIELD_MAP→_derived_line→fields_for→
in_ruler 判準逐條回貼實際 file:line），這比我原本停在「推理鏈完整但沒實跑」更硬。

§9b⑤ 作廢的理由你寫得比我準確：不是「多餘」，是**手寫 `_dict_canon` 跟自動
`_canon_deep` 同時存在＝同一欄位在 fp 字串裡出現兩次、格式還不同**——這是會弄壞尺
的新風險，而它的外觀還偽裝成「我把監測接上了」。這個描述抓住了危害的形狀，收下。

仍保留動工前印一次 `FpCoverage.fields_for("PersonData")` 當單行輸出坐實整條推理鏈
（不准反過來自己改回去加 tap）——這個保守是對的，我沒有比你更確定的證據能省掉這一步。

§11b「這個專案的進尺有兩條路徑，下『X 沒被收錄』的斷言前先數有幾套機制」——這條
通則值得留，我也記下了。

②的補充排除句、①②母體區分的收下，都對。可 dispatch。
