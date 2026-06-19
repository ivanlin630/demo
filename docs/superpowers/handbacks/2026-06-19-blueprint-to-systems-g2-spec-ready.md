---
from: blueprint
to: systems
status: consumed
topic: G2 目標錨 spec ready → 請寫 plan（脊椎①）
consumed_note: HOW 設計 + G2a(merged)/G2b(plan) 已落。G2c/d 待 G2b merge。
---

# G2 目標錨 spec 完成，移交系統寫 plan

Spec: `docs/superpowers/specs/2026-06-19-g2-goal-anchor-design.md`（藍圖已 review 定稿）。

擬真審計第一脊椎（行為的因果脊椎）。排序 ①G2 → ②G1 供應鏈 → ③G3 情報→決策 → ④Trait 縫。

## WHAT 摘要（細節見 spec）

- **leader 即錨**：隊無獨立目標，leader 人生=隊人生；統一現有三套脫節 goal（person.goals / get_goal_task_override dormant / faction.goals+strategic_goals）為單一鏈。
- **archetype 分岔野心階梯**：骨架 `生存→積累→擴張→立國→稱霸`；「類型」=leader value 側寫（野心/好戰→武力、貪婪→商業、義氣/慎重→定居），上層方法分岔；野心封頂高度、archetype 選向；tag drift 跟隨。
- **升降**：安全門檻為下限 + 個性決定冒進（躁進自崩 vs 鞏固強權）= 餵世界興衰。
- **私人驅動×階梯**：關係型目標烈度×個性 → 偏置或脫軌。
- **Graph 縫在此誕生**：扁平 `p.relations` → typed-edge 圖（硬約束：可擴充，admit 未來 kin/parent/spouse/master…；G2 只填 feud/killed/protect/gratitude + 血仇傳播）。
- **情報綁定**：目標決策只讀 team_intel/team_known（殘缺），禁上帝視角 → 可被假情報騙 → ③G3 上線即有消費者。
- **成員摩擦**：reuse check_goal_alignment + defect/split。

## 給你的 HOW 決策點（spec §8）

三套 goal 統一 seam / typed-edge schema（滿足可擴充硬約束）/ 階梯閾值（TEST VALUE）/ rung×archetype→TASK_*/tag 映射 / archetype 從 values 判定 / get_goal_task_override 接入 vs 重寫 / 個性公式。

## 驗收（spec §9）

回歸閘 headless+coin_eq（非 multi drift）。行為可見：多階弧 / 兩型勢力(自崩 vs 穩健) / 脫軌事件 / 情報誤判案例。

## 連帶

- 繼承統一（feat/leader-succession）已 land → G2 §3.1「換 leader→方向劇變」機器現成可用。
- 「誰接班=權力鬥爭」= G2 後續 refinement，**非本 spec**（現用既有 named 晉升即可）。

寫 plan 中有 WHAT 疑義走本 channel 回呈。
