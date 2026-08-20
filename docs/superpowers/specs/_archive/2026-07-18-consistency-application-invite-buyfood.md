# Spec：感知鐵律一致套用（3 點接既有 belief accessor）+ buy-food 失敗回饋

> **scope 坐實定案（systems git show HEAD 逐條驗 blueprint 感知稽核，2026-07-18）**：audit 過counted → 真 live 違憲 = **3 具體點**（threat-move / absorb / invite）。「系統根 path_system」=死碼（零 production caller，修無 live 效果）**排除**；「獵物 terms:266 讀真座標」=REFUTED（prey/攻擊已用 belief_pos/best_estimate）**排除**。meta-pattern reframe：belief-位置讀機制早存在且多數 path 已用（攻擊 `options:194`、prey `faction_ai:285`）→違憲=**3 條繞過既有 accessor 的漏網**→修=接回既有 belief accessor。純 consistency，小，無新機制無系統根重構。
> **序**：starvation fix（ebf4489b）merge **後** dispatch（branch off merged main，避衝突）。

## Part A：感知鐵律一致 slice（3 點，接既有 belief accessor）
所有位置/資源讀走既有 belief 機制（`BeliefSystem.belief_pos` / `BeliefSystem.best_estimate`），對齊已 belief 的攻擊/prey path。

### A1. threat DEFEND/求和 move target → belief
- **根（坐實）**：`decision_context.gd:192` `c.threat_pos = _ot.tile_pos`（live真值）→ `options.gd:294`(DEFEND to_task)/`:305`(求和 to_task) move target 讀 `_dc.threat_pos`。**與 FLEE(belief)+攻擊(`options.gd:194` `belief_pos` last-seen)不一致**。S1.5 已把 `perceived_power_ratio` 弄 belief-safe，位置沒收乾淨。
- **fix（HOW，鏡射攻擊:194）**：DEFEND/求和 move target 改 `BeliefSystem.belief_pos(state, team.team_id, _dc.threat_id)`（last-seen belief 位置）非 live `threat_pos`。
  - **R² 待定點**：`ctx.threat_pos` 是否有其他消費者（距離/gate 計算）——若有且需 live，只改 to_task 的 move target 讀 belief（局部）；若 threat_pos 僅供 move，直接 ctx:192 set belief_pos。impl grep threat_pos 全消費者，R² 覆核。

### A2. absorb_yield → belief-gate
- **根（坐實）**：`decision_context.gd:369-372` 讀 target `ResourceSystem.effective_food` + `population` 真值（可跨派系 god-view）。LIVE（terms.gd:214-218 併入 utility 消費）。
- **fix（HOW）**：absorb target 的 food+pop 走 belief（`best_estimate` 的資源/pop 估值欄）非真值。若 belief 無該 target 資源估→保守 fallback（未知=0 或降 util，不 god-view 直讀）。R² 覆核 belief schema 是否有資源估值欄；無則 A2 降級為「只 gate on 已 discovered + 用 last-seen 估」。

### A3. invite proximity gate
- **根（坐實）**：`faction_ai_system.gd:574` `_try_invite_nearby_exile` iterate team_discovered 累積名單、無距離 gate、瞬間 accept → 邀地圖另端流亡團 → 跨圖 settle walk 半路餓死（team19 源頭之一）。
- **fix（HOW，★R² A3 blocking 修 2026-07-18）**：邀請前距離 gate **用 belief 位置非 live**：`hex_distance(team.tile_pos, BeliefSystem.belief_pos(state, team.team_id, tid)) <= INVITE_RANGE`。**★禁用 `t.tile_pos`（live）**——用 live=修 god-view 卻讀 god-view=cosmetic（invite 照 live 觸發，但 belief-based 決策該拒→跨圖 settle 照發生;R² 血證）。INVITE_RANGE=TEST VALUE 對齊 VisionSystem.VISION_RADIUS/近距語義（measurer 校 seed1337）。超距（belief 位）不邀=感知鐵律一致（距離判定也走 belief，不自我矛盾）。（使者非瞬間=defer，belief 距離 gate 先解跨圖急症。）

## ~~Part B：buy-food 失敗回饋~~ → **移入 `desperation-ladder-failure-feedback` slice（2026-07-18）**
buy-food 失敗回饋 = 「survival action stall→失敗回饋」的**特例**。QA 揭 latch 是**全 survival action 通病**（紮營/返家補給/求和/買糧皆同），非只買糧 → **通用 action-stall 失敗回饋**收進 `2026-07-18-desperation-ladder-failure-feedback.md`（② 重做 slice）。buy-food 自動被通用機制涵蓋，**不單獨做**。此 slice 只留感知族（Part A + C）。

## Part C：死碼 landmine 標記（path_system，非違憲修）
- **根**：`path_system.gd` `observe_velocity`/`estimate_catch_up`/`predict_intercept`(172-246) 讀 live `target.tile_pos`=god-view，**零 production caller**（test-only + `founding_path_measure.gd:31`）。blueprint 鎖：未來 O(N²)「只掃附近」若復活它當 reachability=復活 god-view。
- **fix（HOW）**：三函式頂加註 `# ★god-view landmine（勿復活作決策/nearby-scan：讀 live target.tile_pos，非 belief last-seen。復活前須 belief-gate，見 invariants.md 感知鐵律 nearby-scan landmine）。零 production caller。`。**不改邏輯**（死碼，測試仍過）。durable 規則已入 `invariants.md`（此為 inline 指路）。

## 交付切片
- **Part A（感知一致）**：A1(threat-move→belief_pos，範式攻擊:194)/A2(absorb belief-gate)/A3(invite proximity)，皆行為變 → sim measure（threat-move 不再瞬追 live 位、跨派系 absorb 收斂、team19 不再跨圖 settle）。**★invariant 已 reconcile**（invariants.md 位置語義：他隊當前位置=belief last-seen，地形/reachability=物理真;A1 fix 對齊）。
- **Part C（landmine 標記）**：純註解，隨 Part A commit（碰 perception code 同 PR）。
- （~~Part B buy-food~~ 移 `desperation-ladder-failure-feedback` slice。）

## 閘
- **R②** 標準（premise 已 code-坐实，R① 免）：A1 threat_pos 其他消費者/A2 belief 資源 schema/A3 INVITE_RANGE 邊界/B cooldown 對稱性不誤鎖合法買糧。
- **measure（sim, seed1337/42/4201）→ QA 故事稽核 → blueprint release-pass → merge**。不跳 QA。
- **序：current starvation fix merge 後 dispatch。**

## 溯源
blueprint 感知稽核 audit;systems git show HEAD 逐條驗（re-scope handback `slice2-verified-rescope`:3 live 點 + path_system 死碼 + 獵物 refuted）;既有 belief_pos(options:194)/best_estimate(faction_ai:285) pattern reuse;[[project_desperation_economy]];[[feedback_structural_audit_complement]];既有 reject_cooldown pattern（Part B）。
