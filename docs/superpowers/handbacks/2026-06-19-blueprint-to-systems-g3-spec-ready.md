---
from: blueprint
to: systems
status: open
topic: G3 情報→決策 spec ready → 請寫 plan（脊椎③＝魂）
---

# G3 情報→決策 spec 完成，移交系統寫 plan

Spec: `docs/superpowers/specs/2026-06-19-g3-info-decision-design.md`（藍圖已 review + gap-scan 定稿）。

擬真審計第三脊椎 = 魂（資訊不對稱→決策）。①G2/②G1 已起頭（決策讀殘缺情報），G3 加深。

## WHAT 摘要（細節見 spec）

- **範圍 = A(NPC 被騙) + B(技能揭示)，depth (b)**。OUT：C 武器化/情報操控、(c) 完整認知模擬、信用幣、玩家主動打聽 → 各自後續 spec。
- **belief 模型核心改動**：team_intel 從「confidence-max 覆蓋單值」→ **保留多源 sourced claim（不覆蓋）**，才有資料察矛盾。**涵蓋事件謠言(team_known)**，不只隊伍數據——事件謠言是魂的主味。
- **可信度雙層×衰減**：類型基準(game-design 表) × 身份信任(track record，複用 known_reputations + G2 RelationGraph，**查證回饋動態更新**) × 跳數 × 時效。→「可信線人值錢」。
- **技能=理解力(b3)**：信假→生疑→裁決，按「技能 vs 計謀」分級；**非單則 un-distort**(真值不隨行)；**觀察也吃技能**(低技能親見也錯，源頭就生錯 claim)。
- **決策讀 belief**：(最佳猜值 + 不確定性) → 個性風險調節；矛盾大→查證(複用 scout/Tier0)；莽者被假情報誘殺。
- **接入面**：威脅/外交/攻擊/遷徙 從讀 team_discovered → 改讀 belief 內容。

## 給你的 HOW 決策點（spec §10）

belief multi-claim schema + **上限/剪枝/LOD/perf**(遠 NPC 別存爆) / 失真模式(只補有消費者) / 可信度計算 / **身份信任更新迴路** / 技能vs計謀公式 / 查證 wiring / 不確定性決策模型 / 接入面改讀 belief / 事件謠言比照 / 觀察吃技能 / RelationGraph 加 `trust` 邊型別。

## 關鍵設計理由（避免 plan 走偏）

- **multi-claim 不覆蓋是硬需求**：現碼 confidence-max 覆蓋會銷毀矛盾 → 「察覺矛盾」無資料。這是 (b) 的必要骨。
- **LOD/perf 注意**：多源 claim 會脹，遠 NPC 須 cap/剪/聚合，別存爆（你 HOW）。
- **真值不隨行**：技能不是 un-distort 單則，是靠多源/親見裁決。

## 驗收（spec §11）

回歸閘 headless + coin_eq。行為可見：被假情報誘殺 / 慎重者查證後動 / 高技能識破 / 矛盾觸發 scout / 線人信用漲跌。

排序建議：G3 宜在 ①G2 belief 消費 + ②G1 訂單 belief 都上線後排（G3 加深既有消費者讀的東西）。寫 plan 中 WHAT 疑義回呈本 channel。
