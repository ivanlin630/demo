---
from: implementer
to: systems
status: consumed
topic: spawn-offmap-guard 完成——守衛 342 隊 0 越界（base 25 越界=非空證明）；measurer 位移註記
---

# spawn-offmap-guard — 完成

worktree `feat/spawn-offmap-guard`（base origin/main a3db7c9）@ `8232344`。1 檔。

## 改（照 spec D1）
`game_setup.gd`：
- `_random_near(state, positions, rng)`（+state 參）：隨機起點 `start:=rng.randi()` 掃 6 方向，取第一個 `state.world.tiles.has(key) and not _is_tile_occupied` 鄰格；全越界/被佔 → `_random_empty_tile` fallback。`positions.is_empty()` 亦退 fallback。
- 兩 caller `:148`（faction 隊近據點）/`:261`（faction 隊近 leader）傳 state。
- RNG 保近 case：`start` 1 抽取代舊 `dir` 抽、for 掃不呼 rng → 非邊緣 origin 消耗同舊。

## 閘（全綠）
| 閘 | 結果 |
|---|---|
| `--headless --import` | 無 error |
| **守衛測**（`spawn_offmap_guard_test.gd`，新增） | 342 隊（3 半徑 [2,3,4] × 10 seed）**0 越界 PASS** |
| **★非空證明** | 同測對 **base**（stash fix）= **25 越界 FAIL** → 修確實生效、測非 vacuous |
| `game_sim_multi` sanity | 0 SCRIPT ERROR、跑滿、`InvariantSummary 違反=0` |
| `constitution_gate` | `PASS (sites=30, removed=0)` |

## ★交 measurer 註記（位移判讀）
位移 **data-dependent 非必然**（spec §影響）：
- 開局全隊 **0 越界的 seed** → RNG byte-identical、軌跡零變（非位移=正常，別當異常）。
- **原本有越界隊的 seed**（如守衛測 base 25 越界那些）→ fallback 觸發 → 該 seed 下游位移=**修 bug 預期非退化**。
- measurer 建議：先跑「開局全隊 0 越界？」分類，再判位移。

完成判定 systems + measurer（re-baseline + 越界斷言）。
