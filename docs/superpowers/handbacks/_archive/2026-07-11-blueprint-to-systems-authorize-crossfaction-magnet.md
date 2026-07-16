---
from: blueprint
to: systems
status: consumed
topic: [授權] 跨faction最小版磁鐵測核心假設——finder改讀protector_rep,喂-讀pair對齊;不含S-B完整政治
---

# 藍圖授權：跨 faction 最小版磁鐵（選項 2 最小版）

用戶裁（2026-07-11）：**選 1 = 現在授權跨 faction 最小版磁鐵，測核心假設**（名聲驅動自願聯邦成不成形）。

## 建什麼（最小跨 faction 磁鐵）
1. **finder 改由 protector_rep 選 target**：新 `_find_best_protector`（投奔「戰場護過我 + protector_rep 高」的隊）取代 join 的 `_find_absorber` 容量選。**允許跨 faction**（放寬 `_find_absorber` faction 限 + resolver same_faction 限）。
2. **喂-讀 pair 對齊**（治 inert 根因）：§2 喂的（aided_in_battle→護我者 rep 漲）與 §3 讀的（join target）**同一組 = 「護過我的保護傘」**。現在喂-讀同 pair，rep 不再恆 0.5。
3. **決策**：`join_drive`/FLEE weight × `protector_rep[best_protector]`——高名聲保護傘 → 投靠翻贏逃（trace 場景 E）。

## 邊界（最小版，別越界建 S-B）
- **只做**：跨 faction 投奔高 protector_rep 保護傘 + finder/resolver 放寬 + 喂-讀對齊。
- **不做**（留 S-B）：叛離原勢力的政治後果、怨氣/忠誠演變、叛離/通牒。最小版只驗「弱隊會不會投奔仁君」，政治層 defer。

## 測（measurer，磁鐵驗收）
核心假設：**弱隊會不會湧向高 protector_rep 的（跨 faction）保護傘、長出自願聯邦？**
- 磁鐵動（護過弱鄰的高 rep 隊吸到投靠、聯邦成形）→ 回 blueprint → **S-B 完整政治值得建**（叛離/怨氣/忠誠疊上）。
- 磁鐵不動（rep 高仍投靠輸逃/其他）→ 回 blueprint 重估（weight 量級?別的卡點?），**省下 S-B 大工別瞎投**。
- 附：高名聲仁君 vs 低名聲暴君 分化出「自願聯邦 vs 征服帝國」兩路否。

## 守則
- 主觀 per-observer protector_rep，禁全域直讀。
- 決策走 rank_scored 真 term，過冗餘 lens（protector_rep vs known_reputations 語意分）。
- 不動征服平衡。複用既有（relation_edges 事件、known_reputations 結構）。

## 流程
- spec → **R②**（跨 faction finder + 決策改，審設計 + S-A/S-B 邊界守得住否）。
- implementer → measurer 測磁鐵 → 數字 to:blueprint。
- 決策統一 win 仍同 worktree。a/b/c 續按住。

出 spec。
