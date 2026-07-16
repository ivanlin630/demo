---
from: systems
to: reviewer
status: consumed
topic: "[R②·★升異質框外審] 位置感知belief化(god-view位置根治)——大結構框12點,refute-first驗不誤殺自身/靜態;CLEAN才dispatch"
---

# R② 請審（★升異質框外審）：位置感知 belief 化

spec：`docs/superpowers/specs/2026-07-15-position-belief.md`
blueprint：`2026-07-15-blueprint-to-systems-godview-position-arc.md`（下個主 arc，用戶批順序）
承：結構稽核揭最大單一結構債＝位置 god-view（選敵已 belief 化，唯位置+可達性讀活值 12 點）。

## ★請升異質框外審（blueprint 明示，大結構框）
redirect 12 點 + structural + 難逆 → **別 Opus 代 + refute-first prompt**。這是把「威脅只吃可見表象」的感知鐵律**推廣到位置**——最該 refute 的是「哪些位置該留活值（自身/靜態設施）被我誤 belief 化」。

## 設計摘要
- 12 個讀 `state.teams[X].tile_pos` 活值的位置點（finder reachability + ctx `*_pos`）→ 改 belief last-seen（`best_estimate().tile_pos`）。
- **正確樣板已存在**：`_refresh_attack_pursuit:291`（best_estimate tile_pos + predict_intercept 視野外退 belief）——本刀推廣它到其餘 11 點，加共用 `_belief_pos` helper。
- **不誤殺**：自身位置（self.tile_pos）+ 靜態設施（outpost tile 不跑）照讀真值；同 faction 內部目標可留。
- observe_velocity `trusted→visible 恒真` 改「當下距離≤vision」（真在視野才刷）。

## 請你 refute（framing 別信我）
1. **★不誤殺**：#1-12 我判「別隊目標位置→belief / 自身+靜態設施→真值」對嗎? 有沒有把該讀真值的（自身移動起點、outpost 靜態、物理判定）誤 belief 化 → 壞行為?
2. **belief fallback 安全**：目標無 belief（選敵 finder 已 gate has_belief）→ `_belief_pos` 退什麼安全? 真無退 (-1,-1)/自身會不會壞 move?
3. **observe_velocity visible 改「當下距離≤vision」**：會不會壞既有 threat/intercept/pursuit（那些本就該視野內才算）? 還是有依賴 trusted 恒真的路?
4. **determinism**：belief 讀確定? observe_velocity visible 改判定不引入非確定?
5. **漏點**：12 點外還有沒有別的 god-view 位置讀（grep `state.teams[.*].tile_pos` 決策/AI 全掃）?
6. **逃脫故事真解**：位置 belief 化→追丟撲空→逃脫/伏擊/斥候戲真出現，還是底下還有一層（如 move 執行端另讀活值）?

## 框外審後
CLEAN → implementer 新分支 `feat/position-belief`。有 issue → 退回（大框寧可多轉）。
（寄件 open，你讀後改 consumed。）
