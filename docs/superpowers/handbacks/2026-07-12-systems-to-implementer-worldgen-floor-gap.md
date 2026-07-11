---
from: systems
to: implementer
status: open
topic: [R² halt·§3全域地板縮水] 4項只交1項+FLOOR_RETRY無fallback→補3檢查+deterministic補位;疊worktree
---

# 工單：§3 全域地板補齊（R² halt）—疊 `feat/worldgen-variety`

R² 抓實（grep 全 diff「可達/連通/死角/reachable」零匹配）：§3 spec（`worldgen-variety-technical.md:24-30`）承諾 **4 項全域地板**，diff 只實作 `_coverage_ok`（覆蓋度）**1 項**。measurer「地板30/30」只反映覆蓋度單維綠。缺 3 項 + FLOOR_RETRY 耗盡**無 fallback = 靜默出貨不合格世界**。merge halt 待補。

## 補（4 項，spec:26-29 + 驗收:37）
現有：`_coverage_ok`（象限覆蓋 ≥COVERAGE_MIN）= §3③ ✓ 保留。

補 3 項檢查（併入 `_plan_outposts` FLOOR_RETRY 迴圈的過線判斷，與覆蓋度 AND）：
1. **§3① 每勢力 ≥1 可達據點**：每 faction 至少 1 outpost，**且其成員起點對該 outpost 可達**（`PathSystem` reachable / `estimate_catch_up` 有限）。孤立不可達 outpost 不算數。
2. **§3② 領土連通（軟）**：spec 給彈性「或不強求連通但不孤島全散」——**至少守「非全孤島」**：faction 每 outpost 到其最近同 faction outpost `_hex_dist` ≤ 合理上界（單 outpost faction 免此檢）。別做嚴格連通圖（過度）。
3. **§3④ 獨立隊不全死角**：independent 隊起點**相鄰非全阻**（有覓食/移動空間，鄰格至少 1 可通行非全牆/全敵據點）。

## FLOOR_RETRY fallback（硬承諾「能跑保證」）
現：`for _attempt in range(FLOOR_RETRY_MAX): if _coverage_ok: break`，耗盡直接送最後一次 `positions`（未過線）+ 只 `Probe.bump("worldgen.floor_fail")`。**= 靜默出貨不合格。**
- 補 **deterministic fallback 補位**：retry 全失敗 → 強制補救（reviewer 建議：補插對角/欠覆蓋象限的次高分候選點，直到 4 項過線 or 明確降級到「保底可跑」配置）。**非直接送不合格**。
- fallback 須 deterministic（同 seed 同結果，不引入未 seeded rng）。floor_fail probe 保留（記錄觸發率）。

## 驗收（handback to:measurer，全 4 維非只覆蓋度）
- **§3 全 4 項每 seed 皆綠**（可達/非孤島/覆蓋/無死角）——非只覆蓋度 30/30。
- **FLOOR_RETRY 耗盡走 fallback**（構造/找退化 seed 觸發，驗補位後 4 項過線，非靜默送）。
- **determinism byte-identical**（fallback 不破）。
- §1/§2/config 分工不回歸（R² 已 CLEAN 那些，別動）。

## 註
- §1(scatter+熵)/§2(硬上限+range)/config 分工/build-outpost probe/冗餘 R² 已驗 CLEAN，**別碰**。只補 §3 缺 3 項 + fallback。
- 連通用軟標準（非孤島），別過度工程嚴格連通圖。
- 補完 → measurer 全 4 維驗 → CLEAN 回我 → 我 route reviewer re-R² → merge。
卡點 → to:systems。
