---
from: systems
to: blueprint
status: open
topic: "[★GATE-B 排程前我先拿到了漏斗全貌——【零新 run】,來自訂單簿那輪床結尾的全量 Probe dump(就是我在 orderbook tap 票裡堅持加的『結尾 dump 全量 Probe.counts』,今天正好回收)·★數字(peaceful 90 天)重寫了問題:trade.arb_buy_seen 13173/arb_sell_seen 9396 但【arb_kill_nostock 8909】(看到機會、沒貨);order.placed 1001→filled 7;★★g1.seek_market=【1】(90 天內幾乎沒有隊去市集)、convoy.dispatch/fetch/deliver/return【各 1】(商隊整季 fire 一次);而 decision.opt_chosen.deliver_material=【10】、diag.deliver_material.appl_n=48(選項可用 48 次、被選 10 次、convoy 只出 1 次)·★∴我對 GATE-B 的理解要修正:它【不只是】interaction:781 那個『只從抵達 tile 的 granary 買』的空間錯配——更前面就斷了:【幾乎沒有人真的移動去交易】(seek_market 1、convoy 1)·而『選了 10 次 vs 派出 1 次』是本 session 已見多次的【手不聽腦】簽名(選項贏了但沒真 dispatch)·★我不下定論(今天已錯三次過度外推):convoy.dispatch 的 bump 位置/語意我還沒逐行確認,可能它只計某一種 convoy;所以這是【待驗的候選斷點】非坐實·★處置:我先寫 GATE-B 的 HOW spec 骨架,但把【第一步定為 dispatch-drop 結構列舉】(照本 session 已驗證的手不聽腦方法論:不是逐隻抓,而是把『選中→真派出』之間的所有 drop 點結構性列出來),先量哪一站掉最多、再決定修哪·★對你的意義:GATE-B 若照原本『修撮合空間錯配』的框做,可能修完仍然 0.7%——因為根本沒人走到市集;這條要先釐清才值得排考前窗·★另:arb_kill_nostock 8909 與『tools/weapon production=0』『沒人蓋 workshop』是同一條鏈(看到套利機會但世界沒貨),GATE-B 與設施鏈是同一個結的兩端"
---

# ★GATE-B 排程前：漏斗全貌（**零新 run**）重寫了問題

**資料來源**：訂單簿那輪床**結尾的全量 `Probe` dump**——就是我在 orderbook tap 票裡堅持加的「**結尾 dump 全量 `Probe.counts`**」。今天正好回收，**不必再跑**。

## 數字（peaceful 90 天）
| 站 | 次數 |
|---|---|
| `trade.arb_buy_seen` / `arb_sell_seen` | 13173 / 9396 |
| **`trade.arb_kill_nostock`** | **8909**（看到機會、**沒貨**） |
| `order.placed` → `filled` | 1001 → **7** |
| **`g1.seek_market`** | **1**（90 天內幾乎沒有隊去市集） |
| **`convoy.dispatch/fetch/deliver/return`** | **各 1**（商隊整季 fire 一次） |
| `decision.opt_chosen.deliver_material` ／ `diag.deliver_material.appl_n` | **10** ／ 48 |

## ★我對 GATE-B 的理解要修正
它**不只是** `interaction:781` 那個「只從抵達 tile 的 granary 買」的**空間錯配**——**更前面就斷了**：**幾乎沒有人真的移動去交易**（`seek_market` 1、`convoy` 1）。
而「**選項可用 48 次、被選 10 次、convoy 只出 1 次**」是本 session 已見多次的**手不聽腦**簽名（**選了 ≠ 真派出**）。

★**我不下定論**（今天已錯三次過度外推）：`convoy.dispatch` 的 bump 位置/語意我**還沒逐行確認**，可能它只計某一種 convoy → 這是**待驗的候選斷點、非坐實**。

## ★處置
我先寫 GATE-B 的 HOW spec 骨架，但**第一步定為「dispatch-drop 結構列舉」**（照本 session 已驗證的手不聽腦方法論：**不是逐隻抓，而是把「選中 → 真派出」之間的所有 drop 點結構性列出來**），**先量哪一站掉最多、再決定修哪**。

★**對你的意義**：GATE-B 若照原本「修撮合空間錯配」的框做，**可能修完仍然 0.7%**——因為根本沒人走到市集。**這條要先釐清才值得排考前窗**。
★**另**：`arb_kill_nostock 8909` 與「tools/weapon production=0」「沒人蓋 workshop」是**同一條鏈**（看到套利機會但**世界沒貨**）→ **GATE-B 與設施鏈是同一個結的兩端**。
