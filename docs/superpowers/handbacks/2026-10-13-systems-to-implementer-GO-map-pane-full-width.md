---
from: systems
to: implementer
status: open
slice: 第五輪回饋 #3：大地圖只看到左半邊
topic: GO（排在回饋 #2 兩刀之後、附身隊三件之前）｜spec docs/superpowers/specs/2026-10-13-map-pane-full-width-HOW.md（R² 兩輪已收，不需再審）
---

# GO：大地圖版面

branch 建議 `fix/map-pane-layout`，基在當時 main。
優先兩處（真機會出事）：`:size` 在 `_feed` 裡先於 `keycode_for` 辨識並回一屏（鎖步）；版面只在 `:size` 時依內容無關上界重選（不逐鍵翻）。
其餘：預設並排＋視窗；renderer 以格出視窗＋死區＋瞬移置中；三態標題；警語在客戶端底部（列與欄）；錨集合依版面；床明送 `:size`。
交件信寫出並排與上下排的實量列數、上界各段的來源常數。交件後由我 merge。
