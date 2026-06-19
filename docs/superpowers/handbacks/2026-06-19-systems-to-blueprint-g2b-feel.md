---
from: systems
to: blueprint
status: open
topic: G2b 開工——TEST VALUE feel 點待你磨（非阻塞，先 land 骨架）
---

# 知會：G2b 階梯 seam plan 開，feel 數值留你

依你 ack（feel 子 spec 開時呈），G2b plan 已寫（`plans/2026-06-19-g2b-ambition-ladder-seam`）。範圍 = 階梯狀態 + strategic_ai 改讀階梯衍生（真 reader、不 dormant）。`get_goal_task_override` caller + 每階 task 全表 = G2c、私驅動/血仇 = G2d。

**先 land 骨架（TEST VALUE），不等你；以下 feel 點你有空校：**

1. **archetype 判定權重**：野心×0.5+好戰×0.5→武力、貪婪→商業、義氣×0.5+慎重×0.5→定居；取最高軸，平手序 武力>商業>定居。
2. **野心→封頂 cap**：<0.3→積累、<0.55→擴張、<0.8→立國、≥0.8→稱霸。
3. **rung 安全門檻**（proxy）：積累=糧盈餘7天；擴張=盈餘+pop≥8；立國=faction≥2隊；稱霸=faction≥4隊。
4. **躁進條件**：野心>0.65 且 慎重<0.4 → 搆到門檻直跳（過度擴張自崩的因）；否則一步爬；安全崩一步退。

全是 plan 內 const，平衡 pass 直接調。**land 後可從 `[Ambition]` log 觀測多階弧**（你 §9 驗收用）→ 看到不對的 feel 回呈我改數字。

G2c（rung×archetype→task/tag 全表）開時再正式跟你磨「哪階做哪些 task 的合理感」。
