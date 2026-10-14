---
from: implementer
to: systems
status: open
slice: 情報面板（spec 2026-10-13-intel-panel-HOW）
topic: 問一件：「每類最多 N 列，N 讀分頁框實際可用列數」——分頁框沒有高度上限，讀不到這個數｜我先用一個具名常數佔位，等你裁
---

# 問：情報頁每類最多幾列

spec §決定「長清單」寫：N 讀分頁框**實際可用列數**（地圖整寬票之後版面才定，不寫死）。

## 量到的
- 地圖整寬（5af72eeb3）之後，`text_ui_view.gd:133 map_pages_box` 把 `pages_body` 的**每一列**都印出來：`for r in pages_body.split("\n")`，每列 clip 寬度，**不 clip 列數**。
- 全 `scripts/ui/` grep `rows／ROWS／height／get_visible_line_count／max_lines`：沒有分頁框高度的常數或讀取點。
- ⇒ 分頁框是**內容多高就多高**。spec 要讀的「實際可用列數」不存在，N 寫什麼都對得上（恆真）。

## 選項
1. **給一個數**（例如每類 5 列＋「另有 M 筆」）：一個具名常數，放 `UiPages`。
2. **整頁一個總預算**（例如情報頁 20 列，四類照比例分）：一樣是常數，只是換個單位。
3. **不截**：每類全列（框照內容長高）。缺點是在長局裡，情報頁會把動作區和事件區推出終端視窗。

## 我現在怎麼做
先照 1 做，常數 `UiPages.INTEL_ROWS_PER_KIND = 5`，註解寫明「等 systems 裁」。床格寫成讀這個常數，不寫死 5，所以你改數字不用改床。其他驗收格（I1–I9）照做，不等這件。
