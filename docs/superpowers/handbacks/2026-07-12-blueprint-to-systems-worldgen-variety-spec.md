---
from: blueprint
to: systems
status: consumed
topic: [spec 工單] world-gen variety——對抗①CLEAN,出技術spec(評分/scatter/範圍/全域地板/重baseline)
---

# systems 工單：world-gen variety 技術 spec

reviewer 對抗①終審 **CLEAN**（三約束落地確認）。design committed（`docs/superpowers/specs/2026-07-12-worldgen-variety-design.md`）。出技術 spec。

## WHAT（design doc 權威，摘要）
每 seed 開局世界更變化：①據點資源/戰略加權 seeded 散布（取代 `pick_start_positions` key-order）②據點數隨 seed 變 + 硬上限留空地 ③勢力數/領土隨 seed 變。放野失衡（獨霸/群雄/稀疏 OK）+ 全域結構地板（能跑）。守 per-seed determinism、地形不動（已 seeded）。

## 你出 spec 的 HOW
1. **據點評分 + scatter**：資源價值 + 戰略因子權重公式；**位置熵護欄**（top-N 隨機挑非純 argmax，或 per-seed 位置噪聲）——防 re-regularize（reviewer 靶A 硬條件）。
2. **範圍 TEST VALUE**：據點數（含硬上限比例＝留足空地）、勢力數、領土 share。
3. **全域結構地板實作**（reviewer 靶C）：每勢力≥1 可達據點 + 領土連通 check、散布覆蓋度下限（象限/包圍盒）、獨立隊不全死角。**放野內夾這層＝能跑不壞死。**
4. **重 baseline 程序**：改後 seeded_warring_bed 基線重生（世界變了，一次性預期位移）。

## 硬驗收 gate（spec 須納，measurer 驗）
- **determinism**：同 seed byte-identical（headless 自比）。
- **全域地板**：每 seed 每勢力≥1可達據點+連通、覆蓋度過線、無死角空轉隊。
- **★build-outpost dispatch>0**（reviewer 靶B 獨立項）：新開局下 build-outpost 決策路徑實測 fire（`faction_ai:3060`/`outpost_system:295-324` 機制在，但依 never-fire 教訓須驗）。**罕/不 fire → 回報 blueprint（另一個 never-fire 待查，非本 slice 保證留空地就等於可觀測）。**
- 質感（GUI 人驗）：布局有機、每 seed 明顯不同、聚落貼資源。
- framework/coin/憲法閘綠。

## 流程
- spec → **R②**（審具體 spec：評分/scatter/地板實作健全 + 冗餘 lens）。R① 已過（本輪）。
- implementer 疊 worktree → measurer（determinism 自比 + 全域地板 + build-outpost dispatch + 質感）→ 數字 to:blueprint。
- 複用既有（world_generator/game_setup rng、tile 評分可讀既有 resource），禁重造。

出技術 spec。
