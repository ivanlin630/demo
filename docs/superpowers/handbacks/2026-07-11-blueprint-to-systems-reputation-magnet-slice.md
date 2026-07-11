---
from: blueprint
to: systems
status: consumed
topic: [裁定+工單] 名聲歸附=β分軸+分階段;先建中slice測磁鐵(閉環3+2),gossip傳播defer
---

# 藍圖裁：名聲歸附 β 分軸 + 分階段先測磁鐵

用戶裁（2026-07-11）：**β 分軸 + 分階段（中 slice 先測磁鐵，gossip defer）**。出 spec。

## 裁定
1. **β 分二軸**：`known_reputations`（情報信任，不動）+ 新 **`protector_rep`**（道德/保護名聲，歸附決策讀此）。理由：情報準不準 ≠ 值不值得投奔，混一欄語意撞（過框架內冗餘 lens）。
2. **分階段**：本 slice 只建**閉環 3（決策讀名聲）+ 閉環 2（道德事件喂名聲）**，用現有 rep 波動 + 直接經歷先測「磁鐵發不發得動」。**閉環 1（gossip 傳聞傳播）defer** 到磁鐵證有效再投。

## 本 slice 建什麼（中）
- **新 `protector_rep` 軸**：per-observer 主觀（比照 `known_reputations` per-team 結構），與情報信任分開。
- **閉環 2 — 道德事件喂 `protector_rep`**：`relation_edges`(protect/gratitude→漲、betray/killed→跌) 接進更新。護人→名聲漲、背叛→跌。**本 slice 只吃直接經歷/既有事件源**（gossip 傳播 defer）。
- **閉環 3 — 決策讀名聲**：`join_drive`/`FLEE(survival)` weight × `protector_rep[host]`——高名聲 host → 投靠翻贏逃（trace 場景 E：逃 1.0 vs 投靠 0.82，掛名聲後高名聲 host 該翻盤）。投靠 finder 偏好高 `protector_rep` 保護傘。

## 測什麼（measurer，磁鐵驗收）
核心假設驗證：**弱隊會不會湧向高 `protector_rep` 保護傘、長出聯邦？**
- 磁鐵發動（高名聲 host 吸到投靠、聯邦成形）→ **回 blueprint → 投資閉環 1 gossip**（讓名聲遠播、放大磁鐵）。
- 磁鐵不動（就算 rep 高、投靠仍輸逃/其他）→ **別浪費 gossip 大工**，回 blueprint 重估（可能 weight 量級要調、或別的卡點）。
- 附觀察：高名聲仁君 vs 低名聲暴君 是否分化出「自願聯邦 vs 征服帝國」兩路。

## 守則
- **主觀非全知**：讀 per-observer `protector_rep`，禁讀全域真值。
- 決策走 rank_scored 真 term；**`protector_rep` vs `known_reputations` 語意須明確分**（reviewer 冗餘 lens 驗這點，正是 β 的理由）。
- 複用既有（relation_edges 事件源、known_reputations 結構 pattern），禁重造。
- 不動征服平衡（暴君照征，仁君靠名聲拉投靠）。

## 流程
- spec → **R②**（新軸 + 決策改，審設計 + 冗餘 lens）。前提 file:line 坐實（characterize 表），R① 免。
- implementer 疊 worktree → measurer 測磁鐵 → 數字 to:blueprint 判「磁鐵動不動」。
- 決策統一 win 仍在同 worktree，一起 merge 時機另議。
- **a/b/c 續按住**——磁鐵若動，consolidation 靠名聲歸附活。

出 spec。
