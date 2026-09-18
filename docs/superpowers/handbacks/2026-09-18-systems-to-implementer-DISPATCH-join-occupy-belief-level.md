---
from: systems
to: implementer
status: consumed
slice: 求居／佔村流量改讀 belief 等級（`feat/join-occupy-belief-level`）
topic: ★**派工**：R² CLEAN｜spec `docs/superpowers/specs/2026-09-18-join-occupy-flow-reads-belief-level-HOW.md`｜★★**排在凍結那票之後**（★你手上順序：相位線 merge 中 → 凍結 → 本票）｜★★★**我擔心的那格 1-c，reviewer 幫我查掉了**：`gather()` **本身不呼叫 `harvest_tile_known`**（0 次）⇒ **不是 `_find_occupy_target` 那個坑，fixture 不會被 production 覆蓋**｜★**而他仍建議加「把城放視野外」的保險**（成本幾乎 0）—— **我採納：做**
---

# 一、做什麼（只換資料來源，不動公式）

```
decision_context.gd:806-824（gather 內）
  現在：閘過了之後 state.world.tiles.get(<belief 位置>).outpost_level ← ★live
  改成：讀 BeliefSystem.known_outposts 子記錄的 level／owner_id      ← ★★觀察當時的值
  ★terrain 維持 live（地形不會變）—— ★★不要一起改
  ★★★找不到子記錄（沒看過那座城）⇒ 那一項流量 ＝ 0／不成立，**不得退回 live**
```

# 二、★★1-c 那一格（我原本怕它做不出來，而 reviewer 查掉了）

```
我怕的：fixture 設好「城升級了、而觀察者沒再看過」⇒ 被 production 自己重新 harvest 蓋掉
★reviewer 查的：gather() 本身【不呼叫】harvest_tile_known（0 次）⇒ 不是上一票那個坑
★★而他仍建議：把城放【視野外】當保險，成本幾乎 0 ⇒ ★我採納，請照做
```
★★★**理由**：**「這次不會被覆蓋」與「這次不可能被覆蓋」是兩件事** ——
**保險讓它變成後者，而它只花一行。**

# 三、★預先聲明已寫在 spec §3（世界級要印的數）
```
我預測：那兩條 flow【有值的次數】會變少
★幾乎沒變 ⇒ 是關於世界的發現（見過隊 ⇒ 幾乎總是也看過它的城），記一筆
★★變成 0 ⇒ 修過頭 or 子記錄在世界裡幾乎不存在 ⇒ **停下來回報，別自己補**
```

# 四、老規矩
自家 6 處用**內容錨**不要用行號（★我上一票寫行號寫錯過）；`@bed-kind`；到場點名 ＋ expect；
★**sha 對帳那一行繼續帶**；★★**而這條 branch 我 merge 完會在信裡明寫「已 merge 到 <sha>，後續請開新的」**（今天擱淺那顆的教訓）。
