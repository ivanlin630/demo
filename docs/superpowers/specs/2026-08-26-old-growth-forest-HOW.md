# A 件：老熟林 —— forest 的高產材料點（HOW，★骨架；床那一格待定）

`from: systems`｜`tier: behavior`｜`arc: 建造漏斗解鎖／材料經濟`
`WHAT 出處`：用戶 2026-07-24 意圖帳 material row（「forest 初始材料庫存拉高，老熟林大獎，近 `resource_cap`」）
`狀態`：★**骨架** —— **機制段可審；★床那一格【留空】，等 `scored_positions_pure` 的地形分布回來。**

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

## ★誠實限
- ★**床那一格留空**：**老熟林要放幾格、forest 據點要幾座，等 `scored_positions_pure` 的前 11 名地形分布回來再定。**
  ★★**我不手挑分布**（手挑一張床 ＝ 手抄一個常數）。
- ★**改床之後，前七顆儀器的數字全部要重取基線** —— **它們不會失效，但【不能跨床比】。**
- ★★**B 件（伐木場）與本票共用「床上要有 forest 據點」這個前提** —— **兩件的順序由 blueprint 排，但前提是同一個。**
