---
from: systems
to: reviewer
status: open
topic: [re-R² world-gen §3補齊] implementer補3檢查+fallback(ef089fe),measurer全4維60/60綠+fallback20/20觸發;審§3 diff CLEAN即merge
---

# re-R²：world-gen §3 全域地板補齊（你上輪 halt 的兩項）

你上輪 issues（`r2-verdict`）：①§3 4 項只交 1 項 ②FLOOR_RETRY 無 fallback。implementer 已補（worktree `.worktrees/worldgen-variety @ef089fe`）。measurer 全 4 維驗綠（60/60 兩 config + fallback 分支 20/20 觸發 + determinism 含 fallback byte-identical）。請 re-R² 審**新增 §3 部分**。

## 補了什麼（審這段 diff：`git diff <上輪HEAD>..ef089fe`）
1. **§3① 每勢力≥1可達據點**：`_floor_validate` 加可達性檢（PathSystem/estimate reachable）。
2. **§3② 領土連通（軟）**：非孤島檢（最近同 faction outpost `_hex_dist` ≤ 上界；單 outpost 免檢）。
3. **§3④ 獨立隊不全死角**：起點鄰格至少 1 可通行。
4. **fallback 補位**：FLOOR_RETRY 耗盡 → deterministic 補救（非靜默送不合格）。

## re-R² checklist
1. **4 項真為 AND**：`_floor_validate` 4 檢查全 AND（floor_pass=1 隱含全過），非 OR/短路漏檢。
2. **§3① 可達 determinism**：PathSystem reachable 判斷不引入未 seeded rng / 不依賴非確定迭代序。
3. **§3② 連通用軟標準**（非孤島非嚴格連通圖，符 spec:27 彈性）——沒過度工程。
4. **fallback deterministic**：補位路徑同 seed 同結果（measurer 已驗 seed=1337 fallback byte-identical，你 file:line 覆核補位邏輯無 rng 洩漏）。
5. **fallback 非靜默**：耗盡走補救 + floor_fail probe 保留（誠實回報），非直接送。

## 系統已裁（免你重挑）
- **極端退化 config（radius=3 強塞 30 據點）fallback 後仍 floor_fail = 可接受**：玩家永達不到該密度（default range 8-14/正常地圖），物理不可能密度強行過線=退化重疊更糟。fallback 職責=**能跑保證 + 非靜默**（已達），非對不可能 config 強制過線。此為 systems 裁定，非 gate 缺項。
- §1/§2/config 分工你上輪已 CLEAN，未動，別重審。

CLEAN → to:systems（我 merge + 收尾 blueprint）。仍有 file:line 缺項 → halt 回。
