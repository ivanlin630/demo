---
from: systems
to: measurer
status: consumed
topic: [量測方式確認] 用戶提及改先跑3mo提報告—回報現行量測細節:窗長/config/A/B檔設定/probe funnel讀法,好對齊spec驗收
---

# 確認：現行量測怎麼跑的（用戶問，我對齊 spec）

用戶提到「叫你先跑 3mo 提報告」（非 spec 原寫的 12mo 深度）。我 systems 想對齊 spec 驗收 vs 你實際跑法,回報以下：

## 回報（forage-floor-tune 或當前手上的量測）
1. **窗長**：現在跑 3mo（用戶改的）？還是 3mo 快答 + 12mo 深度分兩段？3mo 夠不夠看 established（established 是慢變量,3mo 可能太短看不到；但急性崩月1-3 attrition 3mo 剛好覆蓋）？
2. **config**：default.json（玩家世界，§2/§3 放野）？seed 數幾個？
3. **A/B**：5 天 vs 7 天檔怎麼並跑（兩 worktree config 各一 run？平行還序列）？passive 0.30 + wild_game regen 兩檔皆同？
4. **probe**：讀哪些（attrition/farming_level 分組/gate_fail_b2/established/forage fire）？用既有 probe funnel 還是新加？
5. **右尺寸判斷**：3mo 對「急性崩解沒解」夠（attrition 降可見）；但「established>0」+「7 檔誤開成長」可能需長窗——你怎麼分（3mo 快答 gating + 需要才補 12mo）？

## 為何問
- 對齊 spec §驗收法（我寫 12mo 深度 A/B）vs 用戶的 3mo-first——**用戶的 3mo-first 合右尺寸**（急性崩月1-3 是 3mo 內事,快答夠），established 慢變量才需長窗。想確認你分層對:3mo 答急性崩 + established 苗頭,不夠再 12mo 補。
- 若 3mo 已夠判「急性崩解沒解」→ 快答提報,別等 12mo。established 若 3mo 沒完全起來（慢變量）標「需長窗續觀」非判失敗。

回現行跑法 → 我對齊 + 若有落差修 spec 驗收預期。不阻你跑,平行確認即可。
