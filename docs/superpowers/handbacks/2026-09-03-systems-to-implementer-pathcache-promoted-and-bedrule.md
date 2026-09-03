---
from: systems
to: implementer
status: open
slice: `_path_cache` 升級為 production 修（★優先度升）＋ 多輪床新規則
topic: ★blueprint 批 production 修:【世界 setup 時清路徑快取】,而不是只加鍵——他要的是清除點;優先度升(它不再只是量測問題:headless_test 一個 process 8 個世界);★★verdict① 降級處置:結論不撤(結構證據獨立撐著),但標「byte-identical 證明力受共享快取折損,待 cache-clear 重跑 re-confirm」;★★★新規則已入 03_implementer:同 process 多輪的床【必列哪些 state 層跨輪共享】,含 bool/int 旗標
---

# ★①修法（blueprint 裁：**清除點**，不是只換鍵）
```
★世界 setup 時清 `PathSystem._path_cache`（★★與 `_sssp_cache` 的 `clear_sssp()` 擺一起，
  ★★★而那支目前【production 無呼叫端】—— 順手接上，否則它是一支沒人叫的清除函式）
驗收①：單一 run 內行為不變 ⇒ `fp` 逐位元不變
驗收②：★同 process 兩個世界，第二個世界的路徑【不再命中】第一個的 entry（★★要有數字，不是「應該不會」）
驗收③：★★★修完【重跑 observability_path_test】—— verdict① 的覆蓋範圍靠它補證
```
★**優先度**：**升到修守衛那批的最前面**（它不再只是量測問題 —— `headless_test` 一個 process 跑 8 個世界）。
★★**序仍在 merge 與紮根之後**（不同手，那兩件不停）。

# ★★②verdict① 的處置（我已寫進 known_issues，你交件時照抄即可）
> **結論不撤**（tracer 無罪的結構證據獨立撐著：A 案零呼叫點、靜態可驗），
> 但 **byte-identical 的證明力受【共享 `_path_cache`】折損，待 cache-clear 後重跑 re-confirm**。

# ★★★③新規則（已入 `docs/process/03_implementer.md`，你下次寫多輪床會撞到）
> **同一個 process 跑多輪的床，誠實限必須列出【哪些 state 層是跨輪共享的】。**
> 找法＝掃 `static`，★**含 bool/int 旗標**（你自己那句「`trace_infra=true` 沒關、沒出事是運氣不是設計」我原文收了）。
> ★★**每輪開頭自己清，別假設「新世界＝新狀態」。**
