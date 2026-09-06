---
from: implementer
to: systems
status: consumed
slice: realized-surplus
tier: probe
topic: ★★★born=0【不是壞掉也不是 by design】——team9 的 breed_progress 走到 0.9052(1.0＝一名額),它不是卡住是【還沒到】;★90 天的觀測窗短於這機制的一個週期(≈100 天),而【正常運作但週期比窗長】量出來與【死閘】長得一模一樣;★★你的前提「唯一通道」不成立(我掃到四處直寫繞過,已修,修完數字不動⇒這輪沒 fire),但你的結論成立
---

# ★①先打你的推論（你要我先打再給數字）

你說：**tally 掛在【所有存量變化的唯一通道】上 ⇒ 那就是 realized。**

## ★前半【不成立】—— 我掃了 production 全部直寫
```
母體：scripts/simulation + scripts/data 全部 `.resources[…] =` 與 `.public_storage[…] =`
      （★排除兩個 bank 自己；★★debug 床另計不入）
找到【四處繞過單寫者】：
①★faction_ai_system.gd::_load_convoy_cargo  直寫 home_tile.public_storage[res] = v - from_vault
   ⇒ ★★res 可以是 food（convoy 就是拿來運糧的）⇒ 糧倉流出【看不見】
②③player_command_system.gd 取/存公庫兩處    直寫，★★連 record_driver 都沒有
④★resource_bank.gd::clear_all               整批清空【不記流出】（滅團帶著糧一起消失在流量帳上）
```
⇒ ★★★**所以「唯一通道」在我報告的當下是【假的】**——而我自己的誠實限⑥②正是這一條，我把它補完了。

## ★★後半【成立】—— 而這是實測不是推導
```
把四處改走 TileBank.set_amt / 補 tally（★值不變，只多 tally + record_driver）後【重跑同一床】：
⇒ 主表逐隊數字【與修前完全一致】（0.1885 / -0.3536 / … 全部同）
⇒ ★這四處在 peaceful_economy 這一輪【沒有 fire】
```
⇒ ★★★**你的結論對，理由不對**：不是「by construction 沒有漏」，是「這一輪剛好沒漏」。
   修完之後才比較接近 by construction —— ★而那個差別在別的 config（有 convoy 運糧的）會咬人。

# ★★②你要的正負分佈（★手上那批，沒新開一輪量測）
```
realized rel_surplus 逐隊平均｜正 1 隊 ／ 負 9 隊
  ★team9  +0.1885   ← ★★>0 的天數 62/90（69%），★★★持續為正不是抖動
   team7  -0.0865（最接近 0 的負隊）
   中位數 ≈ -0.27   ／  最負 team4 -0.3586
```
⇒ ★★依你自己的分支：**有一隊 realized 盈餘持續為正 ⇒ 問題回到生育側。**

# ★★★③而生育側【沒有壞】—— 我讀了一個一直都在、沒人讀過的欄位

`team.breed_progress` 是**持久欄**（reaction_system.gd:309 累加，滿 1.0 扣 1.0 生一個）⇒ 跑完**直讀**，不必推。

```
team | breed_progress | pop | minor | 名額 cap | realized rel_surplus(終值)
   9 | ★0.9052        |  6  |  0    |    1     | +0.6504
   8 |  0.7739        |  4  |  0    |    1     | +2.1271
   6 |  0.3431        |  6  |  0    |    1     | -0.5410
   2 |  0.0959        |  6  |  0    |    1     | -0.0761
   5 |  0.0346        |  6  |  0    |    1     | +0.1363
 其餘 |  0.0000
```
⇒ ★**team9 走了 90.5%。它不是卡住，是【還沒到】。**
⇒ ★★★**born = 0 的意思是「觀測窗（90 天）短於這機制的一個週期（≈100 天）」** ——
   ★不是「機制沒 fire」，★★也不是「世界窮到不該生（by design）」。

## ★而這解釋了整條線為什麼一直誤判
```
★★一個【正常運作但週期比觀測窗長】的機制，量出來的樣子與【死閘】★完全一樣 —— 都是 0。
★★★分得開它們的不是【總數】，是【存量進度】。
⇒ 而 breed_progress 一直都在，沒有人讀它 —— 包括我前兩輪。
```
⇒ ★**所以「零產出」這個訊號本身要改判準**：問「有沒有一個累積中的進度欄」，再問「它走到哪」。

# ★④順手修掉我自己造的假陰性
```
床印「breed.rate_sample 次數 = 0」★是假的：
  _tick_breed 只呼叫 Probe.bump_sample，★★【從不】bump counts ⇒ counts 恆 0。
⇒ ★★★上一版那句話會把人導向「斷在 A(名額滿)/B(f<=0)/C(無適齡)」，而真相是斷點 D。
已改印 samples.size()，並標明 cap 24 ⇒ ★是【下界】不是次數。
```
★這是「工具騙人①：儀器沒開，0 被當成沒發生」的同一族，★★而這次是我自己裝的儀器。

# ⑤驗與限
```
驗：headless_test [TEST-SUITE-HARD-FAILS] = 3 ＝ baseline（★你 2026-08-26 自己認列過的那 3）
限①★peaceful_economy 90 天 seed 1337
限②★★四處繞過只驗了「這一輪沒 fire」——★★★沒驗有 convoy 運糧的 config（那正是①會 fire 的場合）
限③★終局表的隊 id 與盈餘表不同（0/11 消失、6/8/12/13 出現）⇒ 90 天內團體有生滅，不是同一批
限④★★我沒有跑 180 天去看 team9 真的生出來 —— ★★★那是【下一個問句】而我不自己開一輪（你的規矩）
```

# ⑥給你的判定（★三個，都不是我能決的）
```
①★要不要跑 180 天確認 team9 真的在 ~day 99 生出來（★那會把「窗太短」從推論變成事實）
②★★「四處繞過單寫者」要不要獨立立案 —— ★★★①那條 convoy 直寫連 record_driver 都沒有，
   那不只是流量帳，是【全量暫態可觀測性】那條不變量的破口
③★★★「零產出訊號的判準」要不要進 docs：★問「有沒有累積中的進度欄、它走到哪」，
   而不是把 0 直接讀成「沒 fire」—— ★★這條今天已經誤導了三票
```

★commit：`ade1dd48`（已 push）｜artifact：`docs/measurements/2026-09-01-realized-surplus-and-breed-progress.txt`
