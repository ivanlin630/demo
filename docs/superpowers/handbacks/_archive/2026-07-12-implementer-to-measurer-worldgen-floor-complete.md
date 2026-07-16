---
from: implementer
to: measurer
status: consumed
topic: [§3 全域地板補齊] 4 檢查 + deterministic fallback + §3②軟化 done → 全 4 維驗 + fallback 觸發 + 重 baseline
---

# world-gen §3 全域地板補齊 done（@ef089fe feat/worldgen-variety）

R² halt 補齊：§3 從「只覆蓋度 1 項」→ **4 檢查 + deterministic fallback**。

## 做了什麼
- retry 迴圈改包 **scatter+分配全程**（`_assemble_plan`）→ `_floor_validate` **4 檢查 AND**：
  - **①每勢力≥1可達**：faction outpost 非空 + tile 在生成地圖 + ≥1 可通行鄰（非孤立）。
  - **②領土非孤島（軟）**：faction ≥1 對同 faction outpost 相鄰（≤FLOOR_CONNECT_MAX=12）=非全散孤島→過；全互相孤立才 fail。**（軟化修：原「每 outpost 皆須≤上界」過嚴→warring 42據點/8勢力 非空間分配 floor_fail；spec §3② 本軟「非孤島全散」）**。
  - **③覆蓋度**：象限 ≥COVERAGE_MIN（既有保留）。
  - **④獨立隊不死角**：每 indep outpost 鄰格 ≥1 可通行。
- **deterministic fallback**：retry(FLOOR_RETRY_MAX=8) 耗盡 → `_floor_fallback` 補欠覆蓋象限次高分候選（`scored_positions_pure` 純評分無 rng=deterministic）→ 重驗，非靜默送不合格。

## 我驗
- `--import`/multi-sanity(coin_eq/inv=0)/constitution **綠**。
- **determinism**：warring seed 1337 兩跑 **byte-identical**（含 fallback 路徑=deterministic）。
- **floor_pass=1/fail=0**（warring seed 1337，4 檢查首試過；軟化前 fail=1 走 fallback）。
- build_outpost fire（新開局據點建設）。

## ★待你（gate，全 4 維非只覆蓋）
1. **§3 全 4 項每 seed 皆綠**（可達/非孤島/覆蓋/無死角）——default.json 多 seed + warring 皆驗 floor_pass。
2. **FLOOR_RETRY 耗盡走 fallback**：構造/找退化 seed（如極小 total 或擠角配置）觸發 fallback，驗補位後過線（非靜默送）。**我沒構造到退化 seed**（warring/default 都首試過）——你若要驗 fallback 分支，可調小 COVERAGE_MIN 反例 or 找退化 seed。
3. determinism byte-identical（含 fallback）。
4. §2 跨 seed 變（default.json）+ §4 重 baseline（世界結構變一次性重生標位移）。

worktree @ef089fe。§1/§2/config R² 已 CLEAN 未動；只補 §3。→ 你全 4 維綠 → 回 systems → route reviewer re-R² → merge。
