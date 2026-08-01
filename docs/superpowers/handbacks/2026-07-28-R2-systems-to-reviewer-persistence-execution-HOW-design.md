---
from: systems
to: reviewer
status: consumed
topic: "[R²·持守統一執行層 HOW 完整設計審·異質框外(規模當真build如means-end別樂觀,R①已駁過度宣稱)·核心:persist_strength=人格加權(sunk+prospect)兩層寫回+try_set非危機加持守維度(危機tier不變)+latch反例避開(util偏置非硬鎖世界不凍)+83分類真改點少+4slice·spec=2026-07-28-persistence-decision-layer-HOW.md] HOW完整設計done。R①收窄後執行層真build設計。異質框外審設計對否(dispatch implementer前)。"
branch: main (spec only, 未實作)
---

# R²：持守統一執行層 HOW 完整設計審（dispatch implementer 前）

spec：`docs/superpowers/specs/2026-07-28-persistence-decision-layer-HOW.md`（完整設計 §4-9）。R①收窄後（決策層 bonus 家族 + 執行層真 build，危機/FLEE 排除）。

## 核心設計（審這些）
1. **persist_strength 公式**（§4）：`人格加權(sunk_cost + prospect)`，非 flat。progressive-only（開放式 FLEE=0）。clamp < 危機量級。
2. **兩層寫回通路**（§5）：決策層算→寫 `team.persist_strength` 新欄；執行層 try_set 讀；★新鮮度=隨進度事件更新（非只 cadence）。
3. **try_set 持守-aware**（§6）：**危機 axis（≥THREAT）原封不動整數 tier 守命**；**非危機**才加持守比較（`new_util > current_util + persist_strength`）。
4. **83 call site 分類**（§7）：真改點少（try_set 內部 + 決策層 5-6 寫回 + 進度更新），多數 release/call site 不動；行為面=全部（whole-system-first）。
5. **4 slice**（§8）：①決策層 bonus-collapse（增量可獨立驗）②執行層寫回+新鮮度③try_set 持守-aware④A1 手不聽腦收（persist 偏置非 latch）。
6. **憲法**（§9）：util weigh 非 gate、人格 weigh 非硬類別、非硬鎖（latch 反例避開）、危機 axis 留原樣。

## ★reviewer focus（refute，異質框外，規模當真 build 別樂觀）
1. **persist_strength 公式對否**：sunk+prospect+人格加權 真能表達「死硬完成者 vs 靈活轉換者」？progressive-only gate 邊界對否（哪些動作有 sunk 概念）？clamp<危機 真保背水一戰？
2. **★try_set 加維度不破現有仲裁**：危機 axis（≥THREAT）走原整數 tier、非危機才加持守——這切法真乾淨否？有沒有 tier 邊界 case（DISPATCH 50 vs THREAT 70 之間）持守誤介入危機？
3. **★latch 反例真避開**：persist 是 rank 偏置（util 比較）非 skip reeval 硬鎖——真的世界照演化、危機照打斷、不凍世界？（latch 血證：別又做出凍世界的東西）
4. **83 分類「真改點少」對否**：try_set 內部改 + call site 不逐個改——這假設成立否？有沒有 call site 傳的 PRIO 語意會被持守破壞？
5. **slice 切法**：Slice 1 決策層獨立可驗否（不動執行層）？Slice 4 A1 用 persist 偏置（非 latch）真能修 A1 stall（committed builder 被搶）否？
6. **規模誠實否**（means-end 血證+R① 已駁過度宣稱）：這設計真是「真 build」規模、沒又樂觀低估？

**CLEAN → plan（executing-plans）→ implementer（Slice 1 起，逐 slice R²）。** 有洞/翻設計某塊 → 回 `to:systems`（R① 翻回 blueprint 調 WHAT，R² 設計洞我改）。用異質模型 + 明確 refute。
