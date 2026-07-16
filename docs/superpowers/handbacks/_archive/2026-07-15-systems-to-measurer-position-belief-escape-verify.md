---
from: systems
to: measurer
status: consumed
topic: "[量測·中性世界·逃脫故事] 位置belief化@bd6f97d2——★差異在斷視線case(in-sight=base是正確非inert);撲空率>0/staleness解loop/不誤殺"
---

# 量測：位置 belief 化 中性世界（逃脫故事＝payoff）

位置 belief 化主 arc 完。branch `feat/position-belief` @ **`bd6f97d2`**（核心 A-E + 測試遷移，headless 3+3、憲法 sites=29、TDD 8 綠、兩跑 bit-identical；worktree，push）。base=最新 main。systems 驗 diff：belief_pos（staleness+known_member_states+fallback 禁自身）、options 9 用、movement 2 用、_nearest_independent gate 全達成。

## ★關鍵 framing（別誤判 inert）
位置 belief 化**只在目標斷視線時改行為**——**目標在視野內→belief≈活值→行為同 base，這是正確非 inert**（看得見就追得到）。差異＝**斷視線的逃脫 case**（目標躲地形/繞路→belief 過時→追兵去 last-seen 撲空）。∴ seeded warring 短窗（1200 tick，目標多在視野、staleness=3天少觸）行為≈base＝**預期正確**，非方法錯。

## 要驗（★逃脫故事＝payoff，中性世界 confound 已修）
1. **★逃脫撲空（headline）**：追兵 move 到 target 的 **last-seen**（非活值現址）——需**斷視線+移動**的 case。若 seeded warring 短窗撞不到→**用較長窗 or 手構 pursuit-hiding 場景**（弱隊被追→躲森林/繞路斷視線→追兵去舊位撲空）。撲空率 > 0（現＝0 永遠精準攔截）。**這是 rare 行為，比照乞食/diplomacy 教訓：organic seed 撞不到→Tier1 手構場景 or code-verify wiring 真驅動**。
2. **staleness 解 loop**：駐村隊對「曾現後永離」的敵→belief 超 BELIEF_STALE_TICKS(3天)→視同未知→threat_react 歸零（非永久備戰/迎戰 loop）。
3. **不誤殺**：佔村打**村格**（outpost tile 靜態非空地）；徵收/同-faction 找到同僚（known_member_states）；自身位置照真值（移動起點正常）。
4. **無回歸**：兩跑 bit-identical（已初證）；憲法 sites=29；HOB obey%；sanity 零新增。

## 判定路徑（比照 diplomacy code-verify 模式）
- 逃脫故事在中性世界/場景真出現（撲空>0）→ 真生效 → QA 故事複判 → merge。
- seeded 短窗撞不到（inert-by-absence，rare 行為）→ **code-verify wiring 真驅動**（belief_pos 真接進 to_task/movement，斷視線邏輯對）+ Tier1 pursuit-hiding 場景一顆確認 → 帶誠實 caveat merge（同 diplomacy）。**doubt 才大構場景。**

## 下游
specimen trace/handback `to:blueprint`（逃脫故事出現否 + staleness + 不誤殺 + inert-by-absence 釐清）。全量一封信。

## 溯源
raw + measured_at_head `bd6f97d2`。中性世界判。
