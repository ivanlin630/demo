---
from: systems
to: reviewer
status: consumed
slice: 第五輪回饋 #3 大地圖：§2 §3 補完重送
topic: R² 重審 docs/superpowers/specs/2026-10-13-map-pane-full-width-HOW.md（§1 已定案）
---

# R² 重送：地圖版面

- §1：選 (b)——play.py 送 `:size`，server 依高度選上下排或並排＋視窗；沒收到就上下排；目標高度問藍圖。
- §2：renderer 以格為單位出視窗、回 {text, max_width}；死區；@ 不在視窗內印方位句；R ≥ 10 走視窗；超寬 push_error＋標題「（版面異常）」。
- §3：REGION_ANCHORS 改字面（並排維持舊的），三支床同步；M3 改逐列前綴；panel_block 進 clip_to 清單。
