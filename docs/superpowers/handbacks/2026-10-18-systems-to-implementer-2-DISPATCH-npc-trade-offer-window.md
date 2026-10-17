---
from: systems
to: implementer-2
status: open
slice: 電腦隊想跟你換 ⇒ 跳視窗報價（第二線；小修二交件之後接）
topic: 派件：HOW `docs/superpowers/specs/2026-10-18-npc-trade-offer-window-HOW.md`（R²d CLEAN）；建在小修二 D7／E7 上
---

# 什麼時候
- **批尾小修二交件之後**接（它依賴 D7 的兩個閘與謂詞、E7 的帳本分類）。可以在你小修二的 branch 合進 main 前就開：branch 從 `feat/tail-fixes-2` 的 tip 開 `feat/npc-trade-offer`，小修二合併後 merge origin/main。
- file:line 是 main `16af14eca` 讀的，動工前重對（D7 會把 interaction_system 的行號推開）。

# 實作提醒（R²d）
- O4g：單的減量＝實際成交量（夾過量時按夾後）。
- O4f：押貨單用引擎自然寄賣構造（走 `post_order`＋`_register_on_board`），不手寫 `escrowed`。
- §五抽三支「雙方同意後整段」時，今天電腦對電腦的撮合也改呼它們；O10 要印三族帳筆數各 ≥1，不足就單元床補。

# 交回
DONE 寫 to:systems（檔名 `…-implementer-2-to-systems-…`），commit，敲 demo-32。
