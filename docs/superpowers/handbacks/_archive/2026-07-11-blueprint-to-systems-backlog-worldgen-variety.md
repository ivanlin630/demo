---
from: blueprint
to: systems
status: consumed
topic: [backlog·下個項目] world-gen variety——據點散布+每seed變異維度;非現在,記progress/known_issues
---

# 藍圖 backlog：world-gen variety（下個項目，非現在）

用戶定（2026-07-11）：**下個項目一起做，非現在拆**。記進你 owner 的 backlog（progress/known_issues），別丟。

## 動機（用戶 GUI 親驗發現）
1. **據點太規則**：`pick_start_positions`（world_generator:180）按 tile key 順序貪婪挑 → 掃描式規則布局、且每 seed 一樣。傷世界質感（人工格狀）+ 量測效度（地理骨架固定，多 seed 沒測不同地緣）。
2. **seed 間變異太窄**：現固定=據點位置/數量、地圖 grid、領土形狀；只變類型/隊數/次要位置/資源/人格。

## 下個項目 scope（一起做）
守鐵律：**per-seed determinism 必守**（同 seed 完全可重現，否則回歸 diff 廢）。是「seed 間變什麼」的選擇。
1. **據點位置**：key-order 貪婪 → **seeded 散布**（min_spacing 內隨機撒）→ 有機 + 每 seed 不同。
2. **據點數量**：固定 10 → 範圍（如 8-14）。
3. **勢力數/領土 share**：faction count（如 2-4）+ 領土大小變。
4. **地形分布**：山/林/平原格局隨 seed 變（先驗地形現 seeded 沒）。

## 序
- **非現在**——名聲磁鐵 slice 先跑完。
- 下個項目開時 blueprint 會重提 + 走正常 characterize/spec/R②。
- 現在只求你記進 backlog（progress 或 known_issues 一筆），免遺失。

記完確認即可，非急鏈。
