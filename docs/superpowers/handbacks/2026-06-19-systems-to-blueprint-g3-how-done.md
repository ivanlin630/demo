---
from: systems
to: blueprint
status: consumed
topic: G3 §10 HOW 解完（accessor-seam-first + 4 子 spec）
ruling: FYI 收到，無 WHAT 待決。accessor-seam-first(BeliefSystem)→multi-claim 做法對(框架債單一源 de-risk)。inquiry_system 查 OUT 範圍＝你 HOW。子 spec feel(源類型基準排序/識破門檻手感)開時回呈我磨。
---

# 回覆：G3 §10 HOW 解完

G3 HOW 設計落 `specs/2026-06-19-g3-info-decision-how-design`，§10 全裁。

**承重 + 策略**：team_intel 被 **11 檔直讀** → 直接換 multi-claim schema 會波及全部。HOW 主軸 = **`BeliefSystem` accessor seam 先行**（11 reader 改走 accessor，行為保留）→ **再**換 multi-claim 儲存（藏 accessor 後）。schema 改不波及 reader = de-risk（框架債單一源原則）。

**拆 4 子 spec**（依賴序）：G3a accessor seam → G3b multi-claim 儲存（停 confidence-max 覆蓋、改 append、best+uncertainty、上限/LOD）→ G3c 可信度(類型×身份信任 RelationGraph `trust` 邊×跳數×時效)+技能識破(信假/生疑/裁決)+觀察吃技能 → G3d 決策讀 belief+查證迴路(不確定→scout)。

**G2/G1 鉤已備**：RelationGraph(trust 邊,G2a merged)、message(G1 merged)、目標讀殘缺情報(G2/G1d 已起頭)。

**無 WHAT 阻塞**。技能分級閾值/可信度權重/claim 上限 = TEST VALUE，平衡 pass 調。子 spec 開時若有 feel（如各源類型基準排序、識破門檻手感）回呈你磨。先寫 G3a plan（accessor，行為保留，最 de-risk）。

heads-up：已有 `inquiry_system.gd`（你 §2 列「主動獲取資訊」OUT）——我會先查它現狀確認沒搶跑被動 belief 範圍。
