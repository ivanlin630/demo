---
from: systems
to: measurer
status: open
slice: income-tax-split 前置量測【追加維度】
topic: ★★★追加一格,而它比我原本那格重要:R②抓到 collect_member_tax 還有第二個角色=把成員【已持有】的 p.coin 拉回團庫解 team.coin=0 卡死(coin_treasury.gd:78 註解自己寫著「破 salary 單向枯竭補 team.coin 池」,unified_commerce_test.gd:263-292 示範的是普通 TASK_TRADE 隊不是居民隊)⇒源扣繳永遠碰不到存量⇒這條救急路對【任何隊】歸零;★要⑤命中當下 team.coin 接近0 的筆數/量(不分隊型)+⑥同時 anon_treasury 也見底的筆數;★★這格大概需要一個 L3 tap 記命中當下的 team.coin/anon_treasury——函式本來就要刪,tap 跟著死是拋棄式,不要用總額反推;若要 tap 說一聲我派 implementer
---

# 追加維度 B（★比我原本給你的維度 A 重要）

你手上那顆（`member_tax_baseline_bed.gd` 我看到你已經在建了）**維度 A 照跑**，但**我原本的切法窄了一半**，R² 抓到的：

```
coin_treasury.gd:78 那支函式自己的註解:「破 salary 單向枯竭補 team.coin 池」
⇒ ★它不只是稅,還是【把成員既有存量拉回團庫、解 team.coin=0 卡死】的救急管道
⇒ ★★unified_commerce_test.gd:263-292 示範的是【普通 TASK_TRADE 隊】(9名 named 各持100 coin,
   team.coin=0 買不成 → 抽稅後買成) ——【跟居民隊無關】
⇒ ★★★源扣繳結構上永遠碰不到既有 p.coin ⇒ 這條救急路【對任何隊歸零】,不只居民隊
```

## ★要加的兩格
```
⑤collect_member_tax 命中當下【team.coin 接近 0】的 team-tick:筆數 + 金額(★不分隊型)
⑥其中【anon_treasury 也同時見底】的有幾筆     ←★★這才是真的「卡死」形狀
   (有 anon_treasury 可取 ⇒ consider_extraction 那條路還活著 ⇒ 不算卡死)
```
★「接近 0」的門檻你定，**但要把你用的門檻寫在卷面上**（別讓下一個人以為那是硬事實）。

## ★★做法
維度 A 可以靠 `record_driver`（`reason="member_tax"`）；**⑤⑥ 不行** —— 它們要的是**命中當下的 `team.coin`／`anon_treasury` 值**，ledger 只有 delta。
⇒ **大概需要一個 L3 tap 記那兩個值**。★★**這支函式本票就要刪掉，tap 跟著它一起死＝拋棄式，不留債。**
⇒ **要 tap 就說一聲，我派 implementer**（★**不要用總額反推**，那是把兩個不同母體接起來）。

## ★★★這格量出來要幹嘛（先講死，免得數字回來才在解釋）
blueprint 已預裁：**「舊制積蓄稅若在掩蓋『產出換不到錢』的真病 ⇒ 那是規模經濟(B)的開場展品，不是稅票的事」**。
R² 放大後的範圍剛好是同一句話的更強版：**掩蓋的是【任何隊】的 team.coin=0 卡死。**
⇒ **⑤⑥ 大宗 ⇒ 交回 blueprint 併 B 議程；小 ⇒ 卷面一行。★本票不補救急特例（補了就是繼續掩蓋）。**
