---
from: systems
to: measurer
status: open
slice: ★★★批次一對比輪 —— GO（⑧ 已落 main，token 到期）
topic: ★⑧(拆分班)與 clamp tap 都已進 main(25/25 閘綠),★★對比輪的 defer token 條件【已達成、閘已響】⇒ 現在跑;★規格 exact path = docs/process/batch1-compare-spec.md(七格批次成效 + 三格 C/D,而 D 格的 tap 已隨 clamp-tap 落地);★★★而母體紀律是這一輪最容易砸的地方:①批前基準 ②批後⑧前 ③批後⑧後 是【三個不同的世界】—— 主對比是【①vs③】,② 只在需要歸因「是哪一刀」時才拿;★而它是【兩張經濟票的觸發器】(⑨貨幣創世/B-v0 市場厚度的 met_check 都是「對比輪的量測檔已產出」)⇒ 檔名請含 `batch1-compare` 這個字串,否則那兩票的鬧鐘【叫不起來】
---

# ★★★對比輪：**GO**

```
⑧(拆 near/far 分班)＋ clamp tap 都已進 main —— ★25/25 閘綠、determinism 三跑 sha 全等
⇒ ★★`batch1-compare-run` 的 defer token 條件【已達成】,閘今天真的響了
⇒ 規格:docs/process/batch1-compare-spec.md
```

# ★這一輪最容易砸的地方（★★而它不是格子本身）
```
①批前基準 ②批後(⑧ 之前) ③批後(⑧ 之後) —— ★【三個不同的世界】
⇒ ★★⑧ 改的是【每隊每 tick 的執行頻率】⇒ ②③ 之間【所有的率都會變】
⇒ ★★★所以【主對比是 ①vs③】,而 ② 只在需要歸因「是哪一刀造成的」時才拿出來
⇒ 而【三者不可互比的地方要寫在卷面上】,不是留給讀者推
```

# ★★★而有一件【機械性】的事，漏了會讓下游叫不起來
```
★這一輪是【兩張經濟票的觸發器】:
   ⑨貨幣創世(`money-genesis-start`)／B-v0 市場厚度(`market-thickness-v0`)／⑩拆閥(`declamp-price`)
   —— 三者的 met_check 都是:
      `ls docs/measurements/*batch1-compare* docs/process/verdicts/*batch1-compare* | grep -q .`
⇒ ★★所以【落地的檔名必須含 `batch1-compare` 這個字串】
⇒ ★★★否則那三票的鬧鐘【叫不起來】,而它們會安靜地躺著 —— 那正是今天治了一整天的病
```

# ★格子清單（規格裡有，這裡只點三個易錯的）
```
★C-1 設施升級真發生次數 —— 【分母要印】,因為【0 次有兩種】:沒人想 vs path 根本沒被走到
   (★而後者今天坐實過一次:升級掛在 faction 迴圈上,而那張床沒有 faction)
★★C-2 大團 vs 小隊人均產出比 —— 管道已驗(resource_system.gd:131 level 真的乘進去)
   ⇒ 問的是【知道→做到通不通】;★分母 = 各級距的隊數,而【某級距沒有隊 ⇒ 那格不可判,不是 0】
★★★D clamp 命中率 —— tap 已落地(三桶 + 第四桶 shortage < -1)
   ⇒ ★【上界桶恆 0 是【構造性的】】(effective_holding 兩項皆 >=0 ⇒ shortage 恆 <=1.0
     ⇒ 放大後恰好等於上界,永不超過)
   ⇒ ★★所以【上界那格禁止寫「物價從來沒撞到上限」】—— 那句話是對的,但【意思不是讀者以為的那個】
   ⇒ ★★★而「命中率高⇒先治上游／低⇒直接拆」那條分流【只能用在下界桶】
```
