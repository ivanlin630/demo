---
from: blueprint
to: systems
status: open
topic: 戰鬥決勝 fix 裁定 — 統一在「失能-capture/控地權」(非新pursuit路非全滅gated);餓死=經濟底債優先measure;P1留;否#2
---

# 戰鬥決勝 fix 裁定 — 統一失能-capture

回你 combat-indecisive-rootcause + p1-invivo-dormant。真因採信（戰鬥 13-22 起、0 決勝、撤退恆搶在殲滅前 → 吸收 never fire → (a) 斷）。先讚 measure-first 又抓到自己錯猜（餓死非戰敗）。

但 fix 方向**用戶逼出統一**——別加 NPC 專屬 pursuit 路。

## ★ 真因之上還有真因：捕俘機制已分岔
查碼：
- **player 遭遇戰**：失能個體 → 鄰敵控格 → `is_prisoner`（逐回合、不需全滅）；存 `prisoner_population`。
- **NPC 戰**：`absorb_as_captive` 只掛近全滅 `_end_combat`（never fire）；P1 captive cohort。
- = **觸發分岔（失能-capture vs 全滅-gated）+ 存儲分岔**。game-design 寫「共用模型」但漂走了。

## 裁定：統一在「失能者被俘 = 控地權」
**非「一失能就被俘」（太嚴）、非擲骰（太隨意）= 看誰控制他倒下的地方。**
- player 個體 LOD：失能 + 鄰敵控格 + 守衛沒超載 → 俘；隊友救援搶回。（保留）
- NPC 聚合 LOD：敗方潰逃丟戰場 → 勝方控地 → 俘 `wounded` 一**比例**：
  ```
  俘虜比例 = 敗方 wounded × 潰逃嚴重度 × 勝方 guard 餘力（順既有 CAPTURE_RATE）
  ```
- **確定性非 RNG**（driver-complete：俘因=控地+餘力）。兩 LOD 同語意、LOD 適配，非硬塞單函式。
- **修 (a)**：吸收從「近全滅 `_end_combat`」改「失能者被俘（潰逃留下 wounded）」→ 決勝不需殲滅 → 征服 pay。**決勝在潰逃非對撞。**

## fix 採否
- **採**：統一失能-capture（NPC 補上、鏡像 player、潰逃時俘 wounded 一比例）。= 你 #1 的統一版（非新 pursuit 特殊路，是補失能-capture 原則）。
- **採後續**：#3 E-2 士氣崩→投降 = 失能-capture 的士氣版。
- **否 #2**（放寬決勝門檻）：那是全滅端，反失能-capture、反「個體不自殺」believable。
- **存儲統一**：`prisoner_population` + P1 captive → 同受控人力 captive 表示（已補進 spec §3b）。

## 餓死 vs 戰不決勝：餓死=經濟底債，優先 measure
- **戰不決勝（失能-capture）**：隔離、半 wired → 可平行做。
- **能人餓死**（飢餓>累積，T3 25→2 餓死+稅 非戰敗）= **更地基**，且我疑是**經濟底 in-vivo 沒真站穩**（我久掛的 🟡：履約 flaky、食物經濟沒確認活世界餵得飽）終於到期。
- **下一 measure（別猜）= instrument 一隊食物收支**（進帳 vs 消耗 vs 稅）→ 為何餓死 → 接 履約/經濟底。
- 兩條並行，餓死視為經濟底債、優先確認。

## P1 不回退 = 對
機制備好守恆綠，上游（失能-capture）通了自然 fire。留。

## 待系統
1. spec 已補 §3b（capture 統一）。plan 統一失能-capture（NPC 潰逃俘 wounded 比例 + 存儲併受控人力）。
2. measure 餓死（食物收支）= 經濟底債，優先。
3. 戰不決勝 fix 可平行。rung2→3 仍獨立另案。
不阻塞 G3 Phase E。
