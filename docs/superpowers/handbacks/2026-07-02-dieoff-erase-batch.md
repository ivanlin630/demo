# Hand Back: die-off erase spike 批次化（實作→系統）

status: open
plan: `docs/superpowers/plans/2026-07-02-dieoff-erase-batch.md`
branch: `feat/dieoff-erase-batch`（未 merge，等主 session 確認）

## 實作摘要

| 檔案 | 變更 |
|---|---|
| `scripts/data/world_state.gd` | 新 `erase_teams(tids)` 批次 chokepoint：步1 母子/步2 faction 照原順序逐隊（語意/連鎖順序不變）；步3/4/4b 合一單趟（dead set Dictionary O(1) membership，一趟 teams + 一趟 known/discovered/intel，每 observer row 逐 dead tid erase）。`erase_team` 改薄 wrapper `erase_teams([tid])`，單點呼叫端（beast/encounter/subteam）零改動 |
| `scripts/simulation/faction_ai_system.gd` | 僅 `cleanup_extinct_teams`：遺財路由迴圈照舊逐隊（守恆），結尾一次 `erase_teams(routed)`；print 照舊逐隊印。scope guard 遵守（未碰 gate/prey/intent 函數） |
| `scripts/debug/dieoff_perf_bed.gd` | 新量測床（零 production 侵入）：每 tick wall-time + key-set 差集精確 erase K、月邊界累積全報告（防 timeout 砍尾）、K 分桶相關表。env `DIEOFF_SEED`/`DIEOFF_MONTHS` |
| `scripts/debug/scaling_bed.gd` | `_measure_dieoff` 改 loop vs batch 對照（前半逐隊 = 舊路徑複雜度、後半單次批次） |

## 驗證結果

### 1. seeded pointwise diff = CLEAN（最強驗證，過）
3 seeds（1337/42/7）× 3 月（21600 ticks each，attrition 58–64% = 大量 erase 實戰觸發）：
```
[same] seed=1337 逐點相同（零行為變）
[same] seed=42 逐點相同（零行為變）
[same] seed=7 逐點相同（零行為變）
total_diffs=0
```

### 2. 複雜度收斂（scaling_bed loop vs batch，同床直接對照）
| N | 逐隊 us/erase | 批次 us/erase | 加速 |
|---|---|---|---|
| 100 | 222.7 | 107.5 | 2.1× |
| 200 | 536.2 | 227.7 | 2.4× |
| 400 | 1306.3 | 436.2 | 3.0× |

差距隨 N 放大（loop per-erase 隨 N 線性膨脹、批次攤平），方向 = O(K·N)→單趟。

### 3. 回歸全綠
- headless：`=== DONE ===`、0 SCRIPT ERROR、僅 1 pre-existing FAIL（弱目標未加入攻擊 goal，plan 已標容忍）
- erase 語意測群全過：`_test_erase_team`、`_test_team_intel_prune_on_erase` 等
- framework：TC1/2/4/5/6/7 OK + TC3 documented SKIP（他域未決，非本軌）
- `[CoinAudit] delta=0.00`（遺財路由守恆不動）
- InvariantAudit 全 OK（population / faction 雙向 / subteam 雙向 / roster 雙向+反向）

## ⚠ 偏離處：真實 sim spike 未收斂（量測誠實呈報）

**plan TEST 目標「spike ≤ ~2× 中位」未達**。seed 1337 × 4 月（28800 ticks）before/after：

| 桶 | baseline avg | 修後 avg |
|---|---|---|
| K=0（無 erase） | 19,389 us | 20,369 us |
| K=1 | 375,147 us | 404,629 us |
| K=2-4 | 243,880 us | 250,669 us |

修前後同噪聲帶（print I/O 佔比大）。**原因（量到的，非理論）**：現行世界 N≤100 隊，erase 全掃 4 趟 ≈ 數百 us，只佔 die-off tick（~300-400ms）的 <1%。die-off tick 貴是因為**與 cadence/戰鬥結算工作同 tick 共置**（top spikes 全是 K=0 cadence tick，1.2–1.6s），非 erase sweep 本身。known_issues「★compute」條把 spike 歸因 erase O(K·N) 在現行尺度上不成立——複雜度項真實存在（scaling_bed 證實）、但在 N≤100 非主導項。

**結論**：本修 = 效能域不變量的**尺度保險**（N 放大時 erase 項不再隨 K·N 爆），非現行 spike 的止痛藥。現行 die-off/cadence tick spike 另有主導根因（cadence 共置成本），屬另案。

## 連動風險

- `erase_team` 語意/順序完全保留（wrapper），所有單點呼叫端不受影響；pointwise CLEAN 為證。
- `scaling_bed.gd` die-off 輸出格式變（loop|batch 兩欄）——與舊 baseline 數字對照時欄位不同名。
- 無已知其他連動風險。

## 待主 session 確認

1. **known_issues「★compute」條需改寫**：erase O(K·N) 已收（本軌），但「die-off spike」症狀未消——根因主導項是 cadence tick 共置成本（top spike 全 K=0、1.2–1.6s、max/median ~8600×），建議另開量測案定位（faction_ai cadence / print I/O / encounter 結算）。
2. 效能域不變量角度：「早晚期成本無延遲差」的現行最大違反者不是 erase，是 cadence spike 本身（早期 N 大時 1.6s vs 中位 184us）。優先序請系統裁。
3. dieoff_perf_bed 保留為常備量測床（後續 cadence spike 案可直接沿用）。
