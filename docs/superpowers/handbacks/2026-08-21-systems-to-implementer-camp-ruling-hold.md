---
from: systems
to: implementer
status: open
slice: camp-access
topic: 裁定已出(spec 已寫),走 R② 中先別動 code — 你「拒絕 merge、拒絕調參」的判斷我照收,兩點都不是你做錯
---

# 裁定回覆

**先講**：你**拒絕 merge、拒絕動 cap／δ／補償補丁**是對的。
「不得翻轉結論」那條界線你守住了，這封不是要你改做法。

**spec**：`docs/superpowers/specs/2026-08-21-camp-stay-brick-rollout-HOW.md`（**R② 審查中，CLEAN 才動工**）

## 裁定摘要

1. **駁回**「`TASK_CAMP` 納 `PROGRESSIVE_HOLD_TASKS`」——hold list 語意是「有終點會完成」，
   紮營 `faction_ai:4917` 瞬間完成無終點 ⇒ 塞進去 ＝ 永久 latch。
   且「該不該留下」該由**估值**答，不是**仲裁鎖**答（持守統一 arc 定案語意：util 偏重非硬鎖）。

2. ★**真根**：`terms.gd:113` 的 `survival_pressure`（覓食品質）**只是 `food_days` 的函數**
   ⇒ **在自家營地覓食 vs 在荒地覓食，util 完全相同** ⇒ 沒有任何估值把隊留在它剛蓋的營地上。
   **∴ 缺的不是「住下去」的新磚，是折現磚只鋪了 `camp_drive` 一端。**
   你的 `camp.abandoned=25 / l0_to_l1=0` 正好是這條的指紋。

3. **本刀 merge 條件**：baseline 語意（真實被動所得）**至少同時套到覓食**，讓兩者同尺。
   **cap 本刀不動**（要 measurer 的 saturation 實測才動刀，我不讓你憑我的假說去 de-patch）。

4. **headless 五條**：四條預測回綠；★`承諾(掠奪)→實際紮營` 那條**本刀修不掉**，
   屬承諾泛化磚 ⇒ **標 `known-blocked-by: 承諾泛化磚`，不准改測試、不准調參**。
   **四綠＋一條有主的紅 ＝ 可接受交付**；五全綠但靠調參 ＝ 不可接受。

## 你新加的 tap 我收下了
`camp.built` / `camp.abandoned` / `outpost.l0_to_l1` —— 這三顆讓 gate3 第一次可評，
**列為常設**（全量暫態可觀測性不變量）。
