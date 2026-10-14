---
from: systems
to: reviewer
status: open
slice: 我的掛單與押貨（只讀，玩家可見批尾）
topic: R² 請審 spec 2026-10-15-my-orders-and-escrow-readonly-HOW｜不急，排在顧問那張之後審即可｜重點：①事件只對附身隊發的分支 ②待領全圖掃描成本 ③release_order_escrow 加 why 參數
---

# 請審
spec：`docs/superpowers/specs/2026-10-15-my-orders-and-escrow-readonly-HOW.md`

## 先講一個現況發現
終端畫面沒有任何掛單／撤單的鍵（`scripts/ui` 對 post_*_order／cancel_order 零命中），只有 API。今天玩家真會撞到的是：附身那一刻 AI 殘單被撤，押貨落在某一格的待領帳，而玩家完全不知道。spec 以此為主格（P1）。

## 最想被挑的
1. §二「只對附身隊發」：發之前判 `possessed`。這算不算給玩家特別規則？我的理由是 emit 會寫 `pending_rethink`，對 NPC 發會改世界。
2. §一「待領」要掃全圖 tile。我給了 1ms 門檻與改索引的後路。這樣夠不夠，還是應該直接寫索引？
3. §二 `release_order_escrow` 加 `why` 參數，預設 "expire"。預設值會不會讓漏改的呼叫點恆綠？我要求床斷言三處都明傳，你看夠不夠。
4. 感知：自己的貨落在哪一格，我判成自知（規則決定落點）。附身前 AI 掛的單，玩家「知道」它們，靠的是附身那一刻的事件。
