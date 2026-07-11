---
from: systems
to: implementer
status: consumed
topic: [§2/§3 config啟用] worktree default.json 移除total_count/count顯設→觸發range;驗weights
---

# 工單：啟用 §2/§3（worktree default.json 移除顯設觸發 range）

blueprint 補完（`worldgen-s2s3-config`）：§1 達標，但 §2/§3 沒驗到——`default.json` 顯設 `total_count`/faction `count` 釘死，range 只在無顯設觸發。**遊戲 config（default.json）啟用放野。** 疊你 worktree `feat/worldgen-variety`。

## 改（worktree `config/default.json`）
1. **移除 `outposts.total_count`（現 14）** → 觸發 `rng.randi_range(OUTPOST_MIN, OUTPOST_MAX)`（§2）。硬上限 `OUTPOST_DENSITY_CAP` 仍守。
2. **移除 `factions.count`（現 3）** → 觸發 §3 faction count range。
3. **★驗 `factions.weights`（現 [3,2,1] 3 項）對 variable count 的處置**：count 變 2-4 時 weights 陣列長度須對得上——
   - 若 §3 code 已在 count 無顯設時**自生 weights**（依 seeded count）→ 移除 weights 顯設或確認 code 自生。
   - 若 code 讀固定 weights → count>len(weights) 會出錯/截斷。**確認機制,跑不順標回 systems**（別猜）。
   - `teams_per_faction_range [2,4]` 保留（那是每 faction 隊數,非 count）。

## 驗（handback to:measurer）
- **§2/§3 跨 seed 真變**：default.json 上，據點數（8-14 內）+ 勢力數（2-4 內）**每 seed 不同分布**（非固定 14/3）。
- **全域地板仍守**（放野退化不破：每勢力≥1可達/連通/覆蓋）+ 硬上限留空地（build-outpost 仍 fire）。
- **determinism byte-identical**（同 seed）。
- **控制 config（warring_states 等）不動**（釘死留為量測隔離基線）。

## 註
- 只改 default.json（遊戲 config）。**warring_states/tyrant/warzone 等控制/場景 config 顯設保留**（blueprint 裁：控制測試釘死=feature 非 bug）。
- config+§2/§3 code 一起在 worktree，merge 時一起入 main。
卡點 → to:systems。
