# A 件：老熟林 —— forest 的高產材料點（HOW，★骨架；床那一格待定）

`from: systems`｜`tier: behavior`｜`arc: 建造漏斗解鎖／材料經濟`
`WHAT 出處`：用戶 2026-07-24 意圖帳 material row（「forest 初始材料庫存拉高，老熟林大獎，近 `resource_cap`」）
`狀態`：★**床那一格【已填】**（2026-08-26）—— **床已照產生器的真路徑重擺，spec 可送 R²。**

## 病（★量出來的，不是設計臆測）
```
facility 路每輪都在開口：infra path 30 天 336 次、選得出要建什麼
→ ★被「真的沒有材料」擋掉 180 次（reject_cannot_afford，1.0× 無緩衝、無 utility ⇒ 物理）
→ built_in_place 全程只有 8
```
★**而材料的分布是**：**全圖 tile 池 14769，forest 69 格佔 10406（70%）**；
`RESOURCE_PROFILE`：`plains material [5,20]`／`mountain [30,100]`／★`forest [80,220]`。
⇒ ★★**材料在森林，而隊不在森林**（★**harvest 是 positional：採站著的那格**）。

## ★★★這張票【不會】自己解決那 180 次 —— 先寫死，免得又是一條不可達驗收
★**A 提高的是【森林的量】。若隊仍然不在森林，它一樣拿不到。**
⇒ ★★**A 的效果依賴「床上有 forest 據點」** —— **而那正是 blueprint 已裁的改床（「床沒長全」）。**
★★★**所以 A 的驗收【必須】在改床之後量，且【不可跨床比】。**

## 修法（★形狀取自同檔既有的「高產點」模式，不是新發明）
`world_generator.gd` 已經有這個形狀，**兩層 roll：先 roll 稀有的高產點，再 roll 一般**：
```gdscript
const HERB_RICH_CHANCE: float = 0.05     # 藥草林（高產點）
const HERB_FOREST_CHANCE: float = 0.30   # 一般
if rng.randf() < HERB_RICH_CHANCE:   tile.resources["herb"] = rng.randi_range(10, 20)
elif rng.randf() < HERB_FOREST_CHANCE: tile.resources["herb"] = rng.randi_range(2, 6)
```
⇒ ★**老熟林照同一個形狀做**：**forest 中一小比例帶顯著更高的 `material`，其餘照 `RESOURCE_PROFILE` 現值。**
★★**常數要【具名 ＋ `TEST VALUE`】**（同 `HERB_RICH_CHANCE`／`WILD_HORSE_RICH_CHANCE`），**禁裸魔數。**
★**比例與量級的數字【本骨架不定】** —— ★★**它們要能被 organic 分布或既有稀有度慣例支撐，不是我挑一個好看的。**

## ★★★一個必須寫進 spec 的機制後果（**它讓「大獎」不只是一次性禮物**）
`world_generator.gd:101`：**`tile.resource_cap = tile.resources.duplicate()`**
而 `resource_system.gd:128-135`：**再生以 `resource_cap` 為上限。**
⇒ ★**初始值【同時】就是那一格的月再生上限。**
⇒ ★★**拉高老熟林的初始 material ＝ 同時拉高它的再生上限** —— **它是一個【持續】的產地，不是一次性堆料。**
★★★**這一點要寫在 code 註解裡**（照「註解寫壞掉會長什麼樣」）：
**若日後有人把初始值與 cap 拆開，老熟林會安靜地退化成一次性禮物，而沒有任何測試會紅。**

## 驗收（★母體現在是活的 —— 這是它跟前兩次不同的地方）
1. ★**`reject_cannot_afford` 顯著下降**（現況基線 180／30 天，★**改床後要重新取基線**）
2. ★**`built_in_place` 上升**（現況 8）
3. ★★**對照組**：**老熟林比例設 0 ⇒ 世界應退回接近改床後的基線** —— ★★★**這條是防止「效果來自改床本身」的唯一辦法**
4. **`fp` 會變**（worldgen 改動 ⇒ 世界不同）—— ★**照那條判準：改動改到了實際引數/世界，該變**
5. **零裸魔數**：`estimator-lineage-scan.sh` 綠

## ★床（★已定，2026-08-26；★★數字沒有一個出自我）
**`peaceful_economy` 的 11 座 outpost 已照產生器【真路徑】重擺**
（`pick_start_positions`：score × `SCATTER_NOISE ±35%` ＋ `min_sep` 硬保，**不是 `scored_positions_pure` 那支 fallback**）：
```
新床：forest 7 ／ plains 4 ／ ★mountain 0      （舊床：plains 8 ／ mountain 3 ／ forest 0）
母體：plains 105（48.4%）／forest 62（28.6%）／mountain 50（23.0%）⇒ forest 偏好 2.23×
```
★**位置逐格取自產生器的回傳順序，地形是【位置的性質】** ——**「哪幾座變 forest」這個問題不存在。**
★★**`mountain = 0` 是真的不選**：**真路徑有 4 座 plains 進榜，卻一座 mountain 都沒有。**

### ★新基線（七顆儀器已在新床重取，對帳全綠）
```
decide.total 323→289 ｜ delegate.entry 51→12 ｜ attempt 39→12
wall.entry 196→186 ｜ reject_cannot_afford 180→163 ｜ ★accepted 16→23
```
★★**`reject_cannot_afford 163` 與 `accepted 23` 就是 A 件驗收的新基線** —— **母體是活的。**
★★★**但 `attempt 39→12` 與 `accepted 16→23` 方向相反，且【尚未經 QA 故事稽核】** ——
**本 spec 不引用它們的因果，只用它們當基線數字。**

## ★誠實限
- ★**食物產能下降是【預期】**（plains food 8.0／forest 3.0，而 plains 8 座 → 4 座）——
  ★★**`tile_food_init` 刻意不補償**：**補償 ＝ 為了讓床好看而手抄一個數字。**
  ⇒ **若後續餓死率上升，那是【床照世界造之後才看得見的真問題】，不是本票或改床做壞了。**
- ★**舊床基線標 `OLDBED` 留著，跨床不可比** —— **但兩張並排本身就是「床換了多少」的證據。**
- ★★**B 件（伐木場）與本票共用「床上要有 forest 據點」這個前提** —— **現在那個前提成立了（forest 7 座）。**
- ★★**B 件（伐木場）與本票共用「床上要有 forest 據點」這個前提** —— **兩件的順序由 blueprint 排，但前提是同一個。**
