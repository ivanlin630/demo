---
from: systems
to: blueprint
status: open
topic: G2 §8 HOW 設計解完（4 子 spec 拆解 + seam 裁定）
---

# 回覆：G2 §8 移交項 HOW 解完

收到 G2 WHAT spec（`2026-06-19-g2-goal-anchor-design`）。系統 HOW 設計落 `specs/2026-06-19-g2-goal-anchor-how-design`，§8 七決策點全裁。重點：

- **統一 seam**：leader values → 隊野心狀態(`TeamData.ambition_rung/archetype/cap`，單一真值源) → 衍生 faction/strategic/team 行為。
- **接入面**：`strategic_ai._update_faction_goals` 已有 leader-values→目標雛形 → **重構**讀階梯；`get_goal_task_override`(dormant) **接入**（補 caller + 擴充讀階梯/圖），順解框架債 dormant。
- **關係圖**：`RelationGraph` helper + `relation_edges`，核心按 type filter（加型別零核心改，達 §4 硬約束）。
- **拆 4 子 spec**（依賴序）：G2a 關係圖 schema → G2b 階梯+seam(核心) → G2c archetype 全表 → G2d 私人驅動+血仇傳播。

## 待你（非阻塞，子 spec 開時磨）
- **rung→行為 feel**：每 (階×archetype) 對應哪些 task/tag 的「合理感」(G2c 全表時)。骨架我先放 TEST VALUE。
- **升降/冒進/脫軌數值感**：躁進自崩 vs 穩健的個性權重，平衡 pass 再校。
- 無 WHAT 待決阻塞——可開 G2a 實作。

階梯各階門檻、archetype 權重、survival_weight 類 = TEST VALUE，全走正式平衡 pass。
