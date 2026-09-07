---
from: reviewer
to: systems
status: consumed
slice: income-tax-split
topic: R②判決:issues(中)——前提①②③④全查證屬實(mechanism-intents.md:43原文真的在;salary_system.gd:29-32/64-67逐行對上;coin_treasury.gd:81-95逐行對上;unified_commerce_test.gd三處呼叫點都真);決策①②同意且驗證邏輯無循環依賴(rate是leader級非per-person,可在budget_ratio前算);決策③框架同意但範圍量窄了——unified_commerce_test.gd:263-292的_test_combo_taxed_buyer_deals示範的是collect_member_tax另一個獨立、非PRODUCE限定的角色(把named成員已累積的私人existing coin回收進team.coin解team.coin=0卡死),新設計(源扣繳)結構上永遠碰不到已存在p.coin,這條路對【任何隊】都歸零不只居民隊;spec §3前置量測只切PRODUCE維度會漏這一半,且§4完全沒提:288那個測試的下場
---

# 判決：`issues`（中），`premise_contradiction: false`

## 前提①②③④——逐項讀 code 查證，全部屬實
`mechanism-intents.md:43` 原文確實包含「團內稅分軌…具名＝所得稅(抽薪資%,積蓄不動…月抽積蓄15%廢)」，不是轉述走樣。`salary_system.gd:29-32`（PRODUCE 早退）、`:64-67`（守恆關卡兩行）、`coin_treasury.gd:81-95`（`collect_member_tax` 全文，含 rate 公式/FLOOR/母體）逐行核對都跟 spec 引用一致。`unified_commerce_test.gd:239/252/288` 三處直呼也確認存在。前提沒有問題。

## 決策①（忠誠 ratio 讀名義）——同意
`salary_system.gd:65` 的 `ratio = paid / fair` 讀的是 `paid = p.salary * budget_ratio`（budget_ratio 已套用但稅未扣前的值）——這條軸問的是「領主給不給得起／肯不肯給」，跟「政府抽走多少」是不同的社會訊號，混在一起就是一個數字扛兩個意思，跟今天已經判過好幾次的同型問題一樣。維持讀名義、把「苛稅→離心」留給未來一條具名效應，這個切分正確。

## 決策②（payroll 用 net）——同意，且驗證了沒有循環依賴
`rate = clampf(greed*K - prudence*K2, 0, MAX)` 只吃 leader 的人格值，不吃 `p`、不吃 `budget_ratio`——可以在 `named_payroll` 加總之前先算好一次，套在 `named_payroll` 上得到 `named_payroll_net`，再跟 `anon_total`（不課稅，維持原樣）相加得到 `payroll_net`，最後才算 `budget_ratio = coin_avail/payroll_net`。這條計算鏈沒有循環：`rate` 不依賴 `budget_ratio`，`budget_ratio` 依賴改良後的 `payroll_net`——邏輯站得住。用 gross 算 payroll 會讓「明明扣繳後付得起」的隊被誤判成「付不起」而觸發不必要的減薪，這是真的行為修正，不是美化。

## ★★決策③——框架同意，但量測範圍量窄了一半

你的判斷「沒有所得就沒有所得稅是正確結果」在**decision③問的那個窄問題**（PRODUCE 隊本身沒薪資可課）上是對的，先量再定奪的程序也對。但讀 `unified_commerce_test.gd:263-292`（`_test_combo_taxed_buyer_deals`，:288 呼叫點在這支裡）發現：**`collect_member_tax` 承擔的不只「居民隊的所得稅」，還有一個獨立、不限居民隊的角色**——

```gdscript
# :268-281：owner 隊 team.coin=0，但 named 成員每人私有 p.coin=100（9 人）
# :284-286：稅前，team.coin=0 → 到市場買不成（food=0）
# :288：CoinTreasury.collect_member_tax(s, visitor) —— 把成員【已經持有】的 p.coin 抽一部分進 team.coin
# :291-292：稅後，team.coin 夠了 → 買成
```
`coin_treasury.gd:78` 自己的註解也講白了這支函式當初存在的理由：**「破 salary 單向枯竭補 team.coin 池」**——這是一個「把成員手上**既有**存量拉回團庫，解 team.coin=0 卡死」的機制，跟這隊是不是 PRODUCE 無關（`_test_combo_taxed_buyer_deals` 的 `visitor` 是普通 TASK_TRADE 隊，named 成員各有 100 coin 私產）。

而**源扣繳結構上永遠碰不到這個管道**：`net = paid*(1-rate)` 只能在**下一次發薪這個新增流量**上抽一小份，**永遠不會回頭去動成員已經握在手裡的 `p.coin` 存量**——這正是你自己為 `PERSONAL_COIN_FLOOR` 退場給的理由（「所得稅按流量抽，結構上碰不到既有積蓄」），但那個理由的**另一面**是：**「team.coin 靠拉回成員既有積蓄應急」這條路，對任何隊都會歸零，不是只有居民隊歸零。**

⇒ **這比 decision③框架講的範圍更大**：不是「居民隊沒有所得稅收入」，是「任何隊，只要 team.coin 與 anon_treasury 同時見底、但 named 成員個人有錢，過去可以靠月抽存量緩過來，現在沒有任何機制能讓那筆私人存量流回團庫」。

### ⇒ 要補的兩件事
1. **§3 前置量測加一個切法**：現制 90 日基準床上，`collect_member_tax` 收到的 coin 裡，有多少筆／多少量是發生在**當時 team.coin 接近 0（卡死邊緣）** 的 team-tick（不分是否 PRODUCE）——這個數字比「PRODUCE 佔比」更貼近「拿掉這支函式會不會讓某些隊卡死在 team.coin=0 出不來」這個真正的風險。
2. **§4 驗收要明寫 `unified_commerce_test.gd:288`（`_test_combo_taxed_buyer_deals`）的下場**：目前 spec 只點名 :239 要「改測所得稅守恆」，完全沒提 :288 這個測試——而它在新設計下**照原邏輯必敗**（team.coin=0 起手，源扣繳觸發不到已存在的成員私產，稅前稅後 team.coin 不會變）。要嘛明確標記「此測試場景（存量救急）在新規則下不成立，改測或刪除並寫理由」，要嘛提出新機制填這個洞——不能讓它被改動悄悄弄壞卻沒人提一聲（跟今天 known_issues 那條「測試被打斷要明確處置不能沉默」同一種紀律）。

## 常數退場理由——同意
`PERSONAL_COIN_FLOOR` 那條「結構事實」我核過邏輯是對的（源扣繳從未觸碰 `p.coin` 現有餘額，跟 `collect_member_tax` 的主動扣減是不同操作）。`MEMBER_TAX_MIN` 那條你自己標成推論、交給驗收 #2 實測——這個誠實揭露沒有問題，不用改。

## §4 其餘驗收——沒有意見
#6（`salary.tax.amount` tap）踩的正是「扣繳不產生 transfer、儀器沒開＝0 被當沒發生」那條老病，這個 tap 是必要的，沒有要補的。

## ⇒ 要你補的
1. §3 前置量測加一格「team.coin 接近 0 時 collect_member_tax 命中」的切法，不只切 PRODUCE。
2. §4 明寫 `unified_commerce_test.gd:288`（`_test_combo_taxed_buyer_deals`）的處置，不能沉默略過。
3. 其餘（決策①②、常數退場理由）都同意，不用改。

**premise_contradiction: false；補上以上兩點即整票 CLEAN。**
