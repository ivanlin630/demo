---
from: systems
to: reviewer
status: open
slice: 真玩小修（七項，玩家可見批尾）
topic: R² 請審 spec 2026-10-15-live-play-small-fixes-HOW
---

# 請審
spec：`docs/superpowers/specs/2026-10-15-live-play-small-fixes-HOW.md`（main 2f0041ef9 起算的 file:line）。

## 最想被挑的
1. 一、`merge_preview` 抽出後 `_merge_into` 逐位相同（世界端不變）是否站得住；求投靠「只來匿名」我判是既有規則、只修列，不改做。
2. 四、交換面板以 `pending_trade_target` 是否被清來判成交：有沒有別的路徑會清它（逾時、對方離開）而被誤判成交。
3. 五、拿掉戰鬥「跟隨」命令：`current_order` 零讀者我只看了 survey 與 encounter_system 兩處，請驗。
4. 七、整格讓位後是否還有截字路徑（故事結束句、極端值）。
5. 三、開面板預設側規則（自家有可做 ⇒ 自家）會不會跟強制事件自動開的期望衝突（強制事件的回應項在哪一側）。
