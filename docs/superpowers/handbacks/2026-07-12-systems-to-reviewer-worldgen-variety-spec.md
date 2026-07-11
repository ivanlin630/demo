---
from: systems
to: reviewer
status: consumed
topic: [R② 框內] world-gen variety 技術spec——評分/scatter熵護欄/全域地板/重baseline;審健全+冗餘lens
---

# 對抗② 審：world-gen variety 技術 spec

spec `specs/2026-07-12-worldgen-variety-technical.md`（design reviewer 對抗① CLEAN）。R① 已過。**R② 審具體 spec 健全 + 冗餘 lens。**

## 改什麼
`pick_start_positions` key-order 貪婪 → **seeded 評分+scatter**（資源價值×戰略，top-K rng 挑防 re-regularize）+ 據點數/勢力數/領土 seeded range + **全域結構地板**（每勢力≥1可達/連通/覆蓋/無死角，retry）+ 重 baseline。

## refute 靶
1. **★位置熵護欄真防 re-regularize（靶A）**：top-K rng 挑 or per-tile 噪聲——會不會 K 太小又退回 argmax 規則、或 K 太大失去「貼資源」意圖？熵 vs 資源貼合的平衡對嗎？
2. **全域地板 retry 會不會破 determinism**：retry 用同一 seeded rng 續抽 → 同 seed 仍 byte-identical？還是 retry 引入非確定性？
3. **全域地板 vs 放野失衡的界**：地板夾太緊→又規則化（獨霸/稀疏被地板擋掉）；太鬆→死角壞死。spec 的地板項（每勢力≥1/覆蓋/連通）會不會過度約束掉「放野」意圖？
4. **據點評分 term 冗餘 lens**：資源價值/戰略因子 vs 既有 tile 評分（如 `_find_forage_tile`/prosperity finder 的 richness）——新評分別跟既有撞語意？
5. **build-outpost dispatch>0（靶B）**：spec 列為 measurer 硬 gate + 罕則回報——這處置對嗎（留空地≠保證 build-outpost fire，是獨立 never-fire 風險）？
6. **重 baseline**：世界變→baseline 位移是一次性預期，spec 標「非迴歸」——程序對嗎？

verdict to:systems。CLEAN → dispatch implementer。
