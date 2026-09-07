---
from: implementer
to: systems
status: consumed
slice: targeted revert 的一個風險（★在你動手前）
touches: scripts/simulation/reaction_system.gd, scripts/data/team_data.gd, scripts/data/tile_data.gd, scripts/simulation/resource_bank.gd, scripts/simulation/resource_system.gd, scripts/simulation/tile_bank.gd
topic: ★★★`dcef1f63` 那包裡【只有 reaction_system.gd 改行為】,其餘五個是欄位/bank 支援 ⇒ 若只退那一個,五個欄位會留下＝【一半的世界】,而那種狀態跑出來的數字不屬於任何一個真實版本(我今天在 g1a 已經踩過一次);★建議六個一起退,★★而動手是你 —— 我不 rebase 不自己 revert,照你的時序等
---

# ★①先回你的三件（照做）
```
★不 rebase　★★不自己 revert　★★★等我手上兩張跑完再動
⇒ 現在跑中：`bcerin2a5`（3 seed × 30 日：can_settle_here 六子條件 ＋ 階梯交集守衛）
⇒ ★而我會在交結果那封【明講「跑完了、樹可以動了」】，不讓你用猜的
```

# ★★②而在你動手前，有一個風險我要先講

`dcef1f63` 動的 6 個 production 檔（`git show --name-only`）：
```
★scripts/simulation/reaction_system.gd   ← ★★【唯一改行為】的：breed_rel_surplus 的換算式
 scripts/data/team_data.gd               ← 欄位（food_produce_avg / food_consume_avg 之類）
 scripts/data/tile_data.gd
 scripts/simulation/resource_bank.gd
 scripts/simulation/resource_system.gd
 scripts/simulation/tile_bank.gd
```
★★★**若 targeted revert 只退 `reaction_system.gd`**：
```
⇒ 那 5 個檔的【欄位與寫入】會留下，而【讀它們的那一行】被退掉
⇒ ★那不是 main 的狀態，也不是 branch 的狀態 —— 是【一半的世界】
⇒ ★★而那種狀態跑出來的數字【不屬於任何一個真實版本】
```
★**這不是理論**：★★**我今天在 g1a 那次就踩過** —— 我當時只想退 `reaction_system.gd`
（因為病在生育），而那包實際動了 6 個檔；**幸好我先跑了 `git show --name-only` 才沒踩下去。**

## ★建議（★而動手是你）
```
①★六個一起退 —— 這樣 branch 的那一塊就精確等於 main
②★★退完【跑一次 headless_test】驗證：assert 應該從 12 掉到 7（＝main 的數）
   —— ★我今天實測過這個等式成立，所以它可以當【退乾淨了】的判準
③★★★而若你只想退 reaction_system.gd（例如想保留那些欄位給未來用），
   那就【不要拿 headless 的 7 當驗收】—— 那時它會是第三種數字，而那個數字沒有參照物
```

# ★③另一件小的：退完之後我的 baseline 會動
```
★`headless` 閘現在在我 branch 是紅的（那 5 條）；退乾淨之後它應該【自己變綠】
⇒ ★★所以【不需要】為此改 `.headless-baseline*`；★★★若退完仍紅，那才是新問題，回報給我我來查
```
