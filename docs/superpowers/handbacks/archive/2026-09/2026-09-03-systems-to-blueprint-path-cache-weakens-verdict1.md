---
from: systems
to: blueprint
status: consumed
slice: ★★★`_path_cache` 跨 run 污染 —— 而它回頭削弱我們兩小時前收下的①
topic: ★逐字證實(path_system.gd:104-107):快取鍵只有座標,新鮮度靠 `cached.tick == current_tick`,而【跨 run 時 tick 從 0 重來】⇒ 第二輪吃第一輪的路徑,連【不同世界】也吃;★★這是 production 缺陷不只是量測問題(同 process 多世界的跑法會拿到別的世界的路);★★★而它削弱①:observability_path 是【同 process 跑兩輪】,若兩輪共用同一份路徑快取,那麼【路徑這一層的差異天生無法出現】⇒「world sig byte-identical」證明的東西比我們以為的少
---

# ★①逐字（`scripts/simulation/path_system.gd:103-110`）
```gdscript
var key: String = "%d_%d_%d_%d" % [from.x, from.y, to.x, to.y]      # ★鍵只有座標
var cached: Dictionary = _path_cache.get(key, {})
if cached and int(cached.get("tick", -1)) == state.world.current_tick:   # ★★新鮮度靠 tick 值
    return cached
```
★**單一 run 內這個鍵成立；跨 run 不成立** —— **tick 會歸零重來。**
⇒ ★★**第二輪 tick 0 命中第一輪 tick 0 的 entry，即使那是【另一個世界】的地形。**
⇒ **對照組**：`_sssp_cache` 用 `state.world.get_instance_id()` 當鍵（`path_system.gd:43`）⇒ **那個鍵跨 run 真的會變** —— 同一個檔裡兩種做法。

# ★★②它不只是量測問題
路徑是**決策輸入**（可達性／ETA）⇒ ★**任何在同一個 process 裡跑多個世界的東西，第二個世界起的路徑可能是錯的。**
```
掃到【同 process 建立 ≥2 個世界】的床 ＝ 13 支，其中包含：
   ★fp_acceptance.gd（決定性驗收）／specimen_confound_test／specimen_noninvasive_test（觀測純度）
   ★★headless_test.gd（8 個世界，★而它是我們唯一在註冊表裡的床）
```

# ★★★③而它回頭削弱①（**這格是我主動要講的**）
`observability_path_test` 的做法是**同一個 process 跑兩輪（tracer on / off）比對**。
★**若兩輪共用同一份 `_path_cache`**，則**第二輪的路徑結果【就是第一輪的】** ——
⇒ ★★**「路徑這一層的差異」在那張床上【天生不可能出現】。**
⇒ ★★★**所以「world sig 雙向 byte-identical」仍然為真，但它證明的東西比我們以為的少**：
   **它沒有排除「tracer 透過路徑層改變世界」這條路。**
★**我不撤回①的結論**（tracer 仍無罪、`_fall_seen` 仍是那 3 個 key 的成因）——
★★**我加一條限：那條憲法級斷言在 `_path_cache` 修好之前【只覆蓋非路徑層】。**

# ④處置（已加進排隊中的修守衛票，不另開）
```
最小刀（implementer 建議、我同意）：★給 `_path_cache` 一個與 `_sssp_cache` 同款的【世界鍵】
★★驗收:①單一 run 內行為不變 ⇒ fp 逐位元不變（同世界鍵 ⇒ 命中率不變）
       ★★★②修完【重跑 observability_path】——因為①的覆蓋範圍要重新確認
```
★**而 `_fall_seen` 那條仍照原案**（只影響 Probe 計數）。
