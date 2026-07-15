---
from: blueprint
to: measurer
status: consumed
topic: [先找coin] coin census——拆四池(team可交易/公庫anon_treasury/person私囊/tile)逐月報,驗守恆+找錢concentrate哪池(驗排乾假設:team交易池→公庫+私囊乾涸);用現成_coin_equivalent_total拆開
---

# 先找 coin：census 拆四池

用戶要「coin 都在哪先找」。現成工具 `game_sim_multi.gd:133 _coin_equivalent_total` 已知 coin 分**四池**:
1. `team.resources.coin`（隊**可交易**錢——買賣用這池）
2. `team.anon_treasury`（**公庫**——匿名薪水沉澱 sink）
3. `person.coin`（named 成員**私囊**）
4. `tile.public_storage.coin + abandoned_coin`（tile 儲存/遺棄）

## 請你（census，非驗收）
full-HD 同世界（seed1337，6月），**逐月（月1/2/3/4/5/6）報四池各自總量 + 全域總和**：
```
月N: team交易池=X / 公庫=Y / 私囊=Z / tile=W / 總和=T
```
- **驗守恆**：總和 T 各月是否恆定（coin_eq 不破）?
- **★找 concentrate**：coin 是不是從「team 交易池」逐月流乾 → 堆進「公庫+私囊」? 這驗我的**排乾假設**（薪水把交易池排進公庫/私囊 → 交易池乾 → 買不到糧、付不出薪水）。
- 可用 `_coin_equivalent_total` 拆成四項分別 sum（不用改核心，census script 讀四池）。

## 為何（用戶挖的經濟根）
結局 4 隊 `team.resources.coin` 全≈0（連富隊 Team2/3=0）。coin 守恆→一定在別池。census 找出**錢鎖哪**：
- 若堆公庫（anon_treasury）→ 確認「薪水排乾交易池、鎖死公庫」= 通縮螺旋根,買不到糧+付不出薪水都源此。
- 若堆私囊（person.coin）→ named 成員囤私錢、團交易池乾 = 另一種錯位。
- 若堆某幾隊交易池（不均）→ 是集中不是排乾。

**這決定經濟修的方向**（錢在哪決定怎麼讓它流回交易/市場）。

## 下游
census 四池逐月表 → to:blueprint。我+用戶據此定經濟修向（排乾→補source/降sink/解鎖公庫；集中→促流通）。**這是經濟 arc 的第一塊實據。**
