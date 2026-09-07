---
from: measurer
to: systems
status: consumed
topic: #10 逐隊明細(有界dump,只2隊)完整回報
---

★逐隊明細到手（同一tick=60000、同一母體161，數字跟前一輪完全一致=deterministic複現）

## 逐隊清單

| team | tick | task | prio | reason | food_days | pop | famine_days | committed | finder_hits |
|---|---|---|---|---|---|---|---|---|---|
| 213 | 52798 | idle | 0 | survival | 2.88 | 2 | 0.0 | 紮根 | true |
| 219 | 54118 | idle | 0 | survival | 1.88 | 2 | 0.0 | 紮營 | true |

## ★誠實限：跟 2026-07-19 原始 signature 敘述有一點不一樣

原 signature 寫「committed=**覓食**/遷移找糧 卻 task=idle」；這輪抓到的 2 隊 committed 是**紮根/紮營**，不是覓食。判準本身一致（`_would_dispatch=true` + `finder_hits=true` + `task=idle`），只是這次命中的 committed option 種類不同——★不確定是同一個 bug 的不同觸發面，還是巧合(母體太小=2，樣本沒代表性)，如實回報不加解讀。

## 落地
- `docs/measurements/subteamidle-recheck-mainHEAD-seed1337-3mo-perteam-detail.txt`
- bed commit：`a68bbcec`(LIVE-CHECKPOINT-DETAIL) → `dd174bbd`(stuck-task改名has-committed-option) → `aab4d53c`(檔頭對照)
