---
from: systems
to: measurer
status: open
topic: "[量測·後勤SLICE A convoy獨立驗三驗收線+return telemetry追蹤(R²要求非rubber-stamp)·convoy已merge main(f84fdd22 convoy+8721cc71 doc+fixture修4/4綠)·跑peaceful_economy_bed.gd產權威三驗收線:①convoy dispatch/fetch/deliver真+deposit granary②★order_fulfilled>0(整session為0的GATE-B撮合第一次活,材料真換手)③cargo真離賣方(ever_moved/material離inventory到granary)·★★return telemetry追蹤(R²未定論):convoy.return和平床=0——拉dispatch-tick時間戳或延長run天數確認是視窗太短(convoy還在途沒return完)非功能gap(warring convoy=59功能證);★落地docs/measurements標path驗存在+三跑determinism+不凍attrition非→0" 
---

# 量測：後勤 SLICE A convoy 獨立驗（三驗收線 + return telemetry 追蹤）

convoy 已 merge main（`f84fdd22` convoy + `8721cc71` doc/fixture 修，convoy_delivery_test 4/4 綠、gates 全綠）。你產**權威三驗收線**餵 QA/blueprint。

## 跑
`peaceful_economy_bed.gd`（seed 70730、6mo）→ 三驗收線 + trade funnel。三跑 determinism 確認。

## ★★三驗收線（blueprint WHAT 鎖，權威獨立驗）
1. **①convoy 真派真到真 deposit**：`convoy.dispatch/fetch/deliver>0` + 買方 tile granary material 從 0 升（deposit 真發生）。
2. **★②`order_fulfilled>0`**：material `g1.order_fulfilled` **從 0 起來**（整 session 為 0 的 GATE-B 撮合第一次活、材料真換手）。implementer 報 0→5，你獨立確認。
3. **③貨物理真離賣方**：賣方 material 真離 inventory 到市場（`ever_moved`、`cargo_delivered>0`）。

## ★★return telemetry 追蹤（R² 要求、非 rubber-stamp「已證」）
- `convoy.return` 和平床 telemetry=**0**（未定論）。implementer 說功能已證（merge/無 zombie/pop 守恆、warring convoy=59）。
- **★measurer 定論**：**拉 convoy dispatch-tick 時間戳 或 延長 run 天數**（如 12mo）→ 確認 `convoy.return` **=0 是視窗太短**（convoy 6mo 內還在途/剛 deliver 沒 return 完）**非功能 gap**。若延長後 return>0 → 視窗問題（OK）；若仍 0 且 pop 不守恆 → 功能 gap（回 systems）。

## 交付
handback（★落地 `docs/measurements/` 標 exact path 驗存在）帶三驗收線權威數 + return telemetry 定論（視窗 vs 功能）+ 不凍（attrition 非→0）+ 三跑 determinism → QA（故事稽核：surplus 隊真送貨、買方真收到）→ blueprint。**★這是整 session economy 弧線落地驗證（GATE-B 第一次活）。**
