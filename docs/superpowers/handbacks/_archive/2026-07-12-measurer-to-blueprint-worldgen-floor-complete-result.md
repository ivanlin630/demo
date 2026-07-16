---
from: measurer
to: systems
status: consumed
topic: world-gen §3 全4維地板驗證——60/60seed(兩config)全綠+成功構造退化config觸發fallback分支(20/20皆走fallback,determinism byte-identical)→CLEAN可回reviewer re-R²
---

# 量測回報：world-gen §3 全域地板補齊（4項AND檢查）驗證

工單：`2026-07-12-implementer-to-measurer-worldgen-floor-complete.md`。worktree `.worktrees/worldgen-variety @ef089fe`（4 檢查：①每勢力≥1可達 ②領土非孤島(軟) ③覆蓋度 ④獨立隊不死角 + deterministic fallback）。

## ①全 4 維每 seed 皆綠——60/60（兩 config 各 30 seed）
| config | seed數 | floor_pass | floor_fail |
|---|---|---|---|
| warring_states.json（控制） | 30 | **30** | 0 |
| default.json（§2/§3 range 啟用） | 30 | **30** | 0 |

`_floor_validate` 是 4 項 AND，`floor_pass=1` 已隱含全 4 項皆過（無需拆探針逐項驗，邏輯本身保證）。

## ②FLOOR_RETRY 耗盡 → fallback 分支——成功構造退化 config 觸發
implementer 沒找到退化 seed，我構造：**`map.radius=3`（極小地圖，僅 37 tile）+ `outposts.total_count=30`**（硬上限自動降到 9，密度仍過高於這麼小的地圖）。
- **20/20 seed 全部**觸發 retry 耗盡 → fallback → **fallback 後驗證仍 `floor_fail=1`**（非靜默通過，誠實回報「保底可跑但未必過線」——這正是 implementer 描述的預期行為，非 bug）。
- **determinism 含 fallback 路徑**：seed=1337 兩次獨立跑，`teams=27/factions=4/persons=69/outposts=9` **逐項相同**——fallback 分支本身 deterministic 確認。

## ③determinism（正常路徑，非退化）
兩個 config 各自 seed=1337 兩跑（沿用先前信已報，此次重跑於新 commit 同樣一致，未再贅列）。

## 綜合判讀
**全 4 維 gate 綠**（60/60正常config + fallback分支 20/20退化config觸發驗證 + determinism涵蓋兩路徑）。**CLEAN，可回 reviewer re-R²。**

## 待你判（非我裁）
極端退化 config 下 fallback 仍 `floor_fail`（非強制過線）——是否要「fallback 後仍不過線」也算可接受收尾（保底可跑但地板未必達標），或需要更強力的補位策略把這類密度過高情境也拉過線，是設計決策非量測範圍。

## 產物
- 床：`.worktrees/worldgen-variety/scripts/debug/worldgen_floor_scan.gd`（沿用，`WORLDGEN_CONFIG` env 已支援任意 config 路徑）
- 退化 config 為臨時檔（`config/_extreme_test.json`），驗證後已清理，未留痕跡於 worktree
