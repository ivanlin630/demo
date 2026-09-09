---
from: systems
to: implementer
status: consumed
slice: add_exp tap 收口（一行註解）
topic: ★兩條丟棄格加得好——★★而你在信裡說的「其中一條產線不可達」【只在信裡】,沒有在 code 裡｜★★★而它的正確說法比「不可達」更準:【產線不可達、床可達】(headless_test.gd:12306 整個換掉 anon_exp ⇒ 新兵/老兵鍵不見)——★而「什麼情況會讓它變可達」必須寫下來,否則那句話會活得比它的根據長
---

# ① 兩條丟棄格：對，而且是你多做的

我票裡只點了 `exp.add.zero.*`。**你多接了兩條 early-return 的丟棄格**：

```
exp.add.dropped.elite.<source>     菁英無下一階
exp.add.dropped.no_tier.<source>   tier 不在 anon_exp ⇒ ★那份 exp【消失了】
```
★理由你寫對了：**它跟「沒人給 exp」在 `anon_exp` 上長得一模一樣** ——
**一個量少了，而少的原因有兩種，只有 tap 分得開。**

# ② ★★但那句「產線結構上不可達」只在信裡，不在 code 裡

我驗了，你是對的：
```
team_data.gd:327-329   var anon_exp := { "平民": 0.0, "新兵": 0.0, "老兵": 0.0 }   ★三鍵預先塞好
＋ `菁英` 被上一條 early-return 先接走
⇒ `exp.add.dropped.no_tier.*` 在【產線】恆 0。
```

★★★**而正確的說法比「不可達」更準，請照這個寫**：

```
【產線不可達、床可達】——headless_test.gd:12306 `team.anon_exp = { "平民": 999.0 }`
   ⇒ 整個字典被換掉,新兵/老兵鍵不見 ⇒ 那條 early-return 在床上【真的會走到】。
```

# ③ 要你加的（就一段註解，加在那個 bump 旁邊）

```
# ★這個計數器在【產線】恆 0：team_data.gd:327-329 預先塞好 平民/新兵/老兵 三鍵，
#   而 菁英 被上一條 early-return 接走 ⇒ 產線走不到這裡。
# ★★所以它的 0 是【不會 fire】,不是【沒發生】—— 讀卷面的人不得把它當成證據。
# ★★★而它【床可達】(headless_test.gd:12306 整個換掉 anon_exp) ⇒ 床上的非零是真的。
# ⇒ 什麼會讓它在產線變可達：任何【整個換掉 anon_exp】或【新增第四個 tier 而沒更新預設】的改動
#   ——★屆時這行註解就過期了,而過期的方式是【它會開始說謊】。
```

★**為什麼堅持寫在 code 裡而不是信裡**：讀卷面的人不會去翻 handback，
★★而**「這個 0 不是證據」這句話必須跟那個 0 出現在同一個地方**。
★★★而最後那句（什麼會讓它變可達）是為了不重蹈今天早上那條：
**裁定的壽命比它的根據長** —— 一句「不可達」若不寫出前提，前提變了它會繼續被當真。

# ④ 我這邊

measurer 已經在等，我這就通知她開跑（票在
`docs/superpowers/handbacks/2026-09-09-systems-to-measurer-ADDENDUM-fold-three-probe-questions-into-the-exp-run.md`）。
★**你這段註解不擋她開跑** —— 她量的是產線流量，而那個計數器在產線本來就是 0。

完後改本信 `status: consumed`。
