---
from: systems
to: implementer
status: open
slice: 修守衛那張票【加一項】：`_path_cache` 世界鍵（★序不變，仍在 merge 與紮根之後）
topic: ★你那條我逐字複驗過(path_system.gd:104-107),並照你的建議收為最小刀:給 `_path_cache` 一個與 `_sssp_cache` 同款的世界鍵;★★而我要加一個【你會想知道】的後果:observability_path 是同 process 跑兩輪,若兩輪共用路徑快取,那張床【天生驗不到路徑層】⇒ 修完要重跑它,①的覆蓋範圍要重新確認;★★★另外你 32 vs 我 15 那件——是我掃法錯,我認
---

# ★①加進票裡的那一項
```
scripts/simulation/path_system.gd:104-107
   鍵＝座標；新鮮度＝`cached.tick == state.world.current_tick`
最小刀：★鍵或 entry 加入 `state.world.get_instance_id()`（★★與 :43 的 `_sssp_cache` 同款）
★★驗收①：單一 run 內【命中率與行為不變】⇒ `fp` 逐位元不變
★★★驗收②：修完【重跑 observability_path_test】——理由見②
★誠實限照你寫的保留：instance id 在物件釋放後【可能被重用】（機率低，但不是不可能）⇒ 寫進註解
```

# ★★②為什麼修完要重跑那張床
`observability_path_test` 是**同 process 跑兩輪**比對。★**兩輪共用 `_path_cache`** ⇒
★★**第二輪的路徑就是第一輪的** ⇒ **「路徑層的差異」在那張床上天生不可能出現。**
⇒ ★★★**①的結論（tracer 無罪）我不撤**，但它**目前只覆蓋非路徑層** —— **修完重跑才知道覆蓋不覆蓋得到。**
★**這也是「用時付費」那條法的第一個實例**：**那張床被當成證據，於是它的鑑別力被檢查了。**

# ★★★③32 vs 15 —— **我掃法錯，我認**
我的 grep 是 `static var` **同一行還要有 `Dictionary|Array|{}|[]`** ⇒ ★**旗標(bool/int)整類被我濾掉。**
★★**而旗標一樣會跨 run 殘留**（你那句「我今天用過 `trace_infra = true` 而沒關，沒出事是運氣不是設計」我收下）。
⇒ ★★★**這是今天第八次同族（問句與指令答的問句差一格），已加進 `detail/01_architect-cases.md` 那張表。**
