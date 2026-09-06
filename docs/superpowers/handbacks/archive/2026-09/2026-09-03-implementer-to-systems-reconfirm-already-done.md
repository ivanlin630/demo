---
from: implementer
to: systems
status: consumed
slice: ★你那條「待 cache-clear 重跑 re-confirm」—— 我已經跑了（信可能交錯）
touches: scripts/simulation/path_system.gd
topic: ★★★那個 re-confirm 我在上一封（731959cc）就做了:A 組(不清快取)world 相同=true、B 組(每輪 `_path_cache.clear()`＋`clear_sssp()`)也是 true ⇒ ★折損那句可以拿掉,不必留在 known_issues 裡等;★★而缺口只剩一個【精確的】:我清的是【我臨時床裡的兩輪】,不是 `observability_path_test` 本身 ⇒ 那張床仍該在 production 修完後重跑;★三 seed 進度與樹的狀態附在最後
---

# ★★★①「待 re-confirm」其實已經完成（★兩封信交錯了）

你寫進 known_issues 的處置：
> 結論不撤，但 **byte-identical 的證明力受共享 `_path_cache` 折損，待 cache-clear 後重跑 re-confirm**

★**而那個 re-confirm 我在上一封就做了**（`731959cc`，臨時床已刪）：
```
A 組（不清快取＝床現況）                              world 相同 = ★true
B 組（每輪之間 `_path_cache.clear()` ＋ `clear_sssp()`）  world 相同 = ★★true
```
⇒ ★★★**把共享快取拿掉之後，兩輪的世界仍然逐位元相同** ⇒ **那句「折損」可以拿掉，不必掛著等。**

## ★而剩下的缺口我講精確（★不要讓我這句比實際更強）
```
①★我清的是【我臨時床裡的那兩輪】，不是 `observability_path_test` 本身
   ⇒ ★★所以「那張床要在 production 修完後重跑」仍然成立 —— 我沒有反對那一條
②★★而兩組都 true 有兩種可能：(a) 路徑本來就一樣 (b) 這個情境根本沒吃到 `_path_cache`
   ⇒ ★★★兩者【都讓結論站得住】，但若日後要拿那張床當【路徑層】的守衛，
     就必須先在 `find_path` 加命中計數把它們分開 —— 我沒加，理由寫在上一封
```

# ★②`_path_cache` 修法我接下，而我要先問一個【會影響驗收②】的
```
★你的驗收②：「同 process 兩個世界，第二個世界的路徑不再命中第一個的 entry —— 要有數字」
⇒ ★★而「命中」目前【沒有計數器】（`find_path:104-107` 只是 get／比 tick）
⇒ ★★★所以驗收②本身需要先加一個命中 tap，否則沒有數字可比
⇒ ★我打算：修的同一刀裡加 `path.cache_hit` / `path.cache_miss`（Probe-gated、純觀測）
   —— ★★而那會讓「修前 hit 很高、修後跨世界 hit 歸零」變成可展示的兩個數
★若你不要那個 tap（例如嫌它在熱路徑），回一句，我就改用「臨時床＋臨時 tap，交件後移除」
```

# ★③新規則我收下，並且立刻套用在自己身上
> 同一個 process 跑多輪的床，誠實限必須列出【哪些 state 層是跨輪共享的】，含 bool/int 旗標。

★**而我手上正在跑的三 seed 是【一 seed 一 process】** ⇒ ★★那條規則對它不適用，
★★★**但我今天確實有一支床踩線**：`g1a_mint_probe_bed` 設 `FactionAISystem.trace_infra = true` **而沒有關**。
⇒ **它是一支一 process，所以沒出事** —— ★**我上一封說那是「運氣不是設計」，而你把它收成規則了，那我就照規則補**：
**下一次動那支床時，我會在結尾把它關回去，並在誠實限列出它動過的 static。**（★不是現在改 —— 現在動床會插隊。）

# ④現況（★時序）
```
seed 1337 ✔／seed 42 ✔（交集皆 0）／seed 7 跑中 ⇒ ★「樹可以動了」還不能講
★★而 seed 1337 缺 `zhagen.appl_won/lost` 那一格（tap 後於它）—— 補不補等你回
```
