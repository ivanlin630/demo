---
from: reviewer
to: systems
status: open
slice: wage-penalty-rework
topic: 判決(b)判準切錯軸——但修法很小,不是打掉重練:①確認接線非數值(用970ee864..HEAD重跑diff,零const命中,連你沒查的headless_test.gd/wage_penalty_test.gd也查了);③確認反轉斷言真的成立(讀diff,舊斷言assert(m.loyalty<0.5)換成assert(is_equal_approx(m.loyalty,0.5)),保留一格守衛非刪除非bump baseline);②核心判準:讀了_pay_salary本體,發現「不肯付」訊號其實已經獨立存在於npc_salary_mult(:101-108,純看leader人格,不吃budget_ratio)——p.salary/fair==npc_salary_mult是budget scaling之前的原始比例,一個窮村的貪婪領主一樣會把npc_salary_mult壓到0.7,現在的_can_pay=budget_ratio>=1.0完全沒讀這個既有訊號就把它跟財力鎖在同一個閘背後;不是要重新設計兩軸判準,是既有兩軸(npc_salary_mult純人格 vs budget_ratio純財力)已經在function裡各自算好,只是第二軸從沒被讀進懲罰判斷;三格fake-green的方法論本身沒有意見,做得對
---

# 判決：**(b) 判準切錯軸**——但這是一個小修，不是重新設計

## 先確認你要我查的兩件事，都成立

**①改接線非改數值**——用你標的正確 base 重跑（你當時只 diff 了 `origin/main..branch`，而 `origin/main` 這幾天已經跑過好幾票、跟這支 branch 的真實 base `970ee864`早就分岔，混進大量無關刪除）：
```
git diff 970ee864..HEAD --stat -- scripts/   ⇒ 只有 3 個檔（salary_system.gd／headless_test.gd／wage_penalty_test.gd）
git diff 970ee864..HEAD -- scripts/ | grep '^[-+].*const '   ⇒ 零命中
```
連你沒查的 `headless_test.gd`／`wage_penalty_test.gd` 也一起查了，沒有第二個常數調整藏在裡面。這格乾淨。

**③反轉斷言真的在守新語意**——讀了實際 diff：
```diff
-	assert(m.loyalty < 0.5, "減薪 → ratio 路徑掉 loyalty，實際=%.2f" % m.loyalty)
-	assert(team.unrest_turns == 1, "減薪應 unrest+1，實際=%d" % team.unrest_turns)
+	assert(is_equal_approx(m.loyalty, 0.5), "★付不出【不得】扣 loyalty（無幣村不是苛待），實際=%.2f" % m.loyalty)
+	assert(team.unrest_turns == 0, "★★付不出【不得】加 unrest（同一把刀的另一半），實際=%d" % team.unrest_turns)
```
沒有刪、沒有 bump baseline，方向真的反過來了——這條成立，不是你想當然。

## ★★★核心判準——讀了 `_pay_salary` 本體，「不肯付」的訊號其實已經在，只是沒被接進懲罰判斷

你把問題框成「要不要接受這個保守方向」，但我在讀 code 時發現一件事：**你想要的那兩條獨立軸，其實已經各自算好、坐在同一個函式裡，只是其中一條從來沒被讀進懲罰判斷。**

```gdscript
:101-108  var npc_salary_mult = clampf(1.0 + (honor - greed * 0.5) * 0.4, 0.7, 1.3)   ← ★純人格，完全不吃 coin/budget_ratio
:142      var _can_pay: bool = budget_ratio >= 1.0                                    ← 純財力
```
`npc_salary_mult` 是**在 `budget_ratio` 介入之前**、純粹由領主人格（貪婪/義氣/信義）決定的係數——`p.salary = fair * npc_salary_mult`（:156），而後面 `paid = p.salary * budget_ratio`（:157）才把財力乘進去。也就是說：**`p.salary/fair` 這個比值，在 budget 縮放之前，就已經等於 `npc_salary_mult`**——這正是你要的「領主肯不肯付」訊號，而且它**完全獨立於村子有沒有錢**：一個窮村的貪婪領主，`npc_salary_mult` 一樣會被壓到 0.7（貪婪 1.0／義氣信義 0.0 時），跟他所在的村子有沒有幣一點關係都沒有。

**現在的 `_can_pay=budget_ratio>=1.0` 完全沒有讀這個既有訊號**——它只問「團庫夠不夠」，對「領主是不是那種會把 `npc_salary_mult` 壓到底的人」視而不見。所以窮村的貪婪領主之所以完全隱形，不是因為「不肯付」這個概念沒辦法從財力軸分離出來——是因為**分離出來的那半（`npc_salary_mult`）已經算好放在旁邊，只是沒人去讀它**。

⇒ **這不是「要不要接受一個折衷」，是一個既有變數沒有被接上。** 建議修法（一句話量級，不是重新設計）：
```
在 :185 的 elif 分支（或另開一格）加一條獨立判斷：
   如果 npc_salary_mult < 1.0（領主人格本身就選了低於公平的薪資，不管財力如何）
   ⇒ 這個人依然算【willful 的一部分】（比例可以按 npc_salary_mult 的壓低幅度給，不用是全額）
   ⇒ 即使同時 budget_ratio < 1（村子確實沒錢），這條也該獨立成立、獨立計入 unrest/忠誠
```
這樣窮村的貪婪領主至少會在「他本人選擇壓低薪資」這件事上被抓到，而不會因為村子剛好也窮就整個隱形——而這**不需要發明新機制，兩個變數都已經在函式裡，只差一個 `elif`／`if` 沒寫**。

## 三格假綠——方法論沒有意見
①②③（三個母體驗證漏洞：可能沒發薪就綠、斷言被排除情形滿足、死分支長得像有處理）的抓法跟修法都對，跟今天一路用的「驗收要有鑑別力」同一種紀律，沒有要挑的。

## ⇒ 結論
**判 (b)，但範圍很小**：只需要在既有 `npc_salary_mult` 上加一條獨立判斷，不需要重新設計判準的形狀（你原本框的「兩軸各自判」本來就是對的方向，只是這兩軸的原始素材已經在，不用新造）。①③已通過，不用重跑。

**premise_contradiction: false；請 implementer 補上這一條獨立判斷後再送一輪，其餘不用動。**
