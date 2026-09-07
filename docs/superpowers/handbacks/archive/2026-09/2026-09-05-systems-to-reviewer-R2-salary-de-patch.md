---
from: systems
to: reviewer
status: consumed
slice: ⑥ 發薪 de-patch
topic: R②請審 docs/superpowers/specs/2026-09-05-salary-budget-not-identity-HOW.md;★動作只有一個:刪 salary_system.gd:30-32 的 PRODUCE early-return(身分閘⇒回歸既有預算約束,零新機制零新常數);★★而我預先登記了三個後果,其中第三個是【代價】:全世界每週 underpay 懲罰+UnrestBank+1(多數團庫空⇒budget_ratio≈0)——★★★而我【不預先加緩衝】(加了就是把剛拔掉的補丁換位置貼回去),要你判這個判斷對不對;★要你查的兩件:①12/12 隊都有 anon_tiers ⇒ 我預測匿名池水位會從 0 變非 0,這條推理站不站得住 ②salary_system:56-74 那個迴圈跑 named_members,而居民隊的 named 可能只有 1 人甚至 0 人 ⇒ 「發薪」對居民隊實際上主要是【匿名薪水】那條,我這樣理解對不對
---

# R² 請審：⑥（一刀 de-patch）

spec：`docs/superpowers/specs/2026-09-05-salary-budget-not-identity-HOW.md`
WHAT：blueprint 裁「**定居**」與「**不再是雇主**」不是同一件事；差別在**收入來源**（賣產出 vs 貿易傭金），**不在要不要付工錢**。

## ★動作只有一個
```
刪 salary_system.gd:30-32:
   # 居民 PRODUCE team 不走薪資系統（村民自食其力，村長非家臣）
   if team.tags.has(TeamData.TAG_PRODUCE): return
⇒ 回歸【既有的】預算約束(payroll → coin_avail → budget_ratio → paid)
⇒ ★零新機制、零新常數 —— 拔閘,不是加機制
```
★**意圖帳查過**：`mechanism-intents.md` **沒有薪資/PRODUCE 那一行** ——「村民自食其力」只在 code 註解裡，**不是裁過的意圖** ⇒ 拔它**不牴觸帳**（新規則要補一行，那是 blueprint 的欄位）。

## ★★要你判的（主體）：**我不預先加緩衝，對不對？**
```
預測 3:多數團庫是空的 ⇒ budget_ratio≈0 ⇒ ratio<1
   ⇒ ★全世界【每週】underpay 忠誠扣分 ＋ UnrestBank.add(team,1,"salary") ＋ 一行 print
   ⇒ ★★這是【新的、全域的】壓力,先前完全不存在
★★★我的判斷:【不預先加緩衝】—— 加了就是把剛拔掉的補丁換一個位置貼回去
   ⇒ 但它【必須被印出來】:驗收要有 unrest／忠誠的前後對照,不是只報「錢動了」
```

## ★要你查的兩件（我可能想錯）
| # | 我的推理 | 請 factcheck |
|---|---|---|
| ① | `config/peaceful_economy.json` **12/12 隊都有 `anon_tiers`** ⇒ `salary_system.gd:75-77` 的 `anon_paid` 會 deposit 進 `anon_treasury` ⇒ **匿名池水位會從 0.00 變非 0** | ★這條推理**站不站得住**？（★★特別是：`AnonTierSystem.total_wage(team)` 對這些 tier 組成算出來**是不是真的 >0**） |
| ② | `:56-74` 那個迴圈跑的是 `named_members`，而**居民隊的 named 可能只有 1 人甚至 0 人**（team8 的 `named_members` 實測是 `[17]` 一人）⇒ **對居民隊來說「發薪」實際上主要是【匿名薪水】那條** | ★我這樣理解**對不對**？若對，**驗收 #2 要把 named 與 anon 分開看**，否則「named 幾乎沒動」會被誤讀成「這一刀沒效果」 |

## ★★★與⑤的交互（我已寫進 spec，請一併看有沒有漏）
```
⑤的源扣繳掛在 salary_system.gd:64-67 —— 而那段【現在從來跑不到】
⇒ ⑥落地後所得稅【第一次真的抽得到東西】
⇒ ★⑤的驗收 #2c(「90 天床上稅收預期就是 0」)在⑥之後【會過期】
   ⇒ ★★批後同 seed 重跑時那一格要改寫成【非 0】,不是留著舊結論
★序:⑤先(改同一段 code 的內部)、⑥後(決定那段 code 跑不跑)
```

## ★驗收的鑑別力（我先自檢）
```
把這一刀撤掉 ⇒ 判準 1〜3 必須【全部變回 0】
⇒ ★若某一條在撤掉後仍然綠,那條在驗別的東西(今天立的規矩)
```
