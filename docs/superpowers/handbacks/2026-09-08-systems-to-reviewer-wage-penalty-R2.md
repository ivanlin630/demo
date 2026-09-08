---
from: systems
to: reviewer
status: consumed
slice: wage-penalty-rework
topic: ★R² 審 merge 前設計｜★★我自己讀出【一個語意假陰性區】：窮村的貪婪領主完全免罰（:142 `_can_pay` 綁 budget_ratio）——請裁「這是可接受的保守方向」還是「判準切錯軸」｜★★★卷面上三筆假綠是這票最該讀的部分
---

# 一、送審物（exact path，已 push）

```
branch  feat/wage-penalty-rework   HEAD 7099907c   base origin/main 970ee864
spec    docs/superpowers/specs/2026-09-08-wage-penalty-rework-HOW.md
主卷    docs/measurements/2026-09-08-wage-penalty-rework.measure.json
床      scripts/debug/wage_penalty_test.gd（8 格，兩半各自有母體）
閘      docs/process/merge-gates.tsv → `wage-penalty`（expect = `=== DONE === ALL PASS`）
```

**病**：`salary_system.gd` 把「這個地方沒有貨幣流通」判成「這個領主苛待部下」。
`SALARY_INTERVAL = 7 天` ⇒ 無幣村**每週被判一次，永動** ＝ 地理被定罪。

---

# 二、★請你裁的三件事（我已先查過，附我的讀數，別只信我）

## ① 改接線 vs 改數值 —— 我這邊讀到的是【接線】

```
SALARY_LOYALTY_PENALTY = 0.03  (:7)   ★未動
git diff origin/main..branch -- salary_system.gd | grep '^[-+].*const'  ⇒ 零命中
```
新增的是 `_can_pay` / `_willful` 兩個**判斷**與三格 Probe 分類，
不是把懲罰係數調小。**請你確認我沒有漏看別的檔的數值調整**（我只 diff 了 salary_system.gd）。

## ② ★★三格 reason 是否窮盡、有無交叉污染 —— 機械上是，語意上【有一個假陰性區】

機械形狀（:178 / :185 / :191，同一個 if/elif/else 覆蓋全體具名成員）：

```
:178  ratio >= 1.0        → paid_full          （含超付 overpay）
:185  elif _can_pay       → underpaid_willful  （扣忠誠 + 計入 _willful）
:191  else                → unpayable_local    （不扣忠誠、不加 unrest，★仍記錄）
```
三格互斥且涵蓋 ⇒ 交叉污染在**計數層**不成立。床也對此有一格
（`:74 unpayable_local == 0` 在貪婪半、`:98 unpayable_local > 0` 在無幣半）。

### ★★★而這是我要你裁的那一點

```
:142  var _can_pay: bool = budget_ratio >= 1.0
```
`_can_pay` 綁的是**團庫夠不夠**，不是**領主肯不肯**。
於是：

```
貪婪領主（npc_salary_mult 0.8）＋ 窮村（budget_ratio < 1）
  ⇒ _can_pay = false ⇒ 落進 :191 unpayable_local
  ⇒ ★不扣忠誠、★★_willful 不增 ⇒ :212 unrest 也不加
  ⇒ ★★★【貪婪在窮村完全隱形】
```
兩個成因本來是**可分離**的：`p.salary < fair`（薪資訂得低，:156 由 `npc_salary_mult` 決定）
與「團庫缺錢」是**兩條獨立的軸**，一個人可以同時中兩條。
現在的形狀把它們壓回**一條**——只是壓的方向**反過來**了。

我的讀法（**不是裁定，交給你**）：
- 這是**保守方向**。原病是「冤枉好人」（false positive）；現在的殘留是「放過壞人」（false negative）。
  修 FP 修出 FN，比修 FP 修出更大的 FP 好。
- 主卷自己也標了這條邊界，但標成 fixture 的答案：
  「邊界（不足但非零）由 fixture 自己回答：coin = payroll\*0.5 ⇒ 錢全發光 ⇒ 屬付不出」
  ★**那是 fixture 在回答一個設計問題**。implementer 誠實寫出來了，而我認為它該由你裁、
  而不是由一個 fixture 的參數值默認。

**請你給一個 verdict**：
```
(a) 接受＝保守方向可出貨，但必須【記成具名 accepted cost】（我來寫 known_issues 一條）
(b) 判準切錯軸＝退回 implementer，改成兩軸各自判（salary<fair 一條、coin 不足一條，可同時成立）
```

## ③ 反轉的舊斷言是否真的在守新語意

```
headless_test.gd:11623   舊：assert(m.loyalty < 0.5)   ← 斷言【本票要移除的 bug】
                         新：反轉成「不得掉 loyalty」＋ 加 unpayable_local > 0 當母體
fixture :11616  team.resources["coin"] = payroll * 0.5   ⇒ 造的是 unpayable
```
★**沒有刪、沒有 bump baseline**（HARD-FAILS 3 ｜ baseline 3 ｜清單逐條相同 ｜ rc=0）。
反轉後它會在「有人把舊語意改回去」時**紅**。請確認這句成立，而不是我想當然。

---

# 三、★★★卷面上的三筆假綠（我認為這是這一票最有價值的部分，請一併讀）

```
①第一跑：三格 reason 全 0 ⇒ _pay_salary 根本沒被呼叫，而床印了兩個 PASS
   （忠誠沒掉／unrest 沒加）★數字是真的、解釋是錯的
   ⇒ 接住它的是【母體格】unpayable_local > 0
②第二跑：ALL PASS 但 willful=0、忠誠【上升】⇒ ①的情境根本沒造出來
   根在斷言那一行：`paid_full + underpaid_willful > 0`
   ★被它【本該排除的情形】滿足（付滿也算數）⇒ 那格永遠不會紅
③implementer 自造又移除的【死分支】：`if not _can_pay` 寫在 `if budget_ratio < 1.0` 裡面
   ⇒ 那裡 _can_pay 恆 false，else 是死碼 ⇒ ★永遠跑不到的分支長得跟【有處理】一模一樣
```

# 四、★誠實限制（implementer 自己標的，我複驗成立）

```
determinism 三跑 byte-identical fp=39657d1e4acd83c15337553fded10563
★★對【本票】沒有鑑別力：SALARY_INTERVAL = 7 天 = 10080 tick，
  而 a4_determinism_check 跑 1000 tick = 0.69 天 ⇒ ★★★永遠不會有發薪日。
  它只證明沒弄壞別的東西，不證明這票對。
```

# 五、未做（具名）

```
④anon 側：salary_system.gd ★零個 morale 引用 ⇒ 沒有懲罰可移除。
  implementer 不先做——要嘛驗出真有東西可移除，要嘛它是【新增機制】而那要 WHAT（藍圖）。
  ★我同意這個停點：它不是偷懶，是拒絕在沒有 WHAT 的情況下發明機制。
```

# 六、下一站

R² CLEAN → 我跑全部 35 道閘 → merge → push。
R² 若判 (b) → 我直接把你的 verdict 轉回 implementer，不繞路。
