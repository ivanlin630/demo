# Spec：god-view 殲滅 Slice F（fallback-to-live 反模式 + 死 *_pos 欄清理）

> god-view 殲滅 arc（[[project_unification_matrix]]）Slice F。**機械清理為主但有 -1 handling 邊角**。off Slice-A-merged main（a5495461）。
> 根：blueprint 改序（框架 god-view 先於 economy）+ 異質 audit 盤點 + systems exhaustive 坐实。

## F1：fallback-to-live 反模式（缺 belief 默認 live=違「無估=保守」）
- **根（坐實 exhaustive `.get("tile_pos", X.tile_pos)`）**：`BeliefSystem.best_estimate(...).get("tile_pos", <live>.tile_pos)` 缺 belief tile_pos 時**默認 live 真位**=god-view 回潮（違 invariants「無估 fallback=保守非偷讀真值」）。5 site：
  - `faction_ai_system.gd:313`（scout_pos，prey_t.tile_pos）
  - `faction_ai_system.gd:1284`（`_dispatch_envoy`，target.tile_pos）
  - `faction_ai_system.gd:1368`（envoy tracking，target.tile_pos）
  - `strategic_ai_system.gd:139`（encirclement，target.tile_pos）
  - `inquiry_system.gd:64`（`e2.get("tile_pos", t.tile_pos)`）——**★R² 分類**：這在 intel-entry 建構（relay 情報）非決策 dispatch？若是 intel-construction（誠實記「不知位置」用某 default）可能 legit 非違憲；R² 判是決策讀 or intel 建構。
- **fix（HOW，★R² 給各 site 確切 -1 handling 2026-07-19，非盲 sentinel=避 -1 進 hex_distance/move_target crash）**：`.get("tile_pos", <live>)` → `.get("tile_pos", Vector2i(-1,-1))` + **各 site guard**：
  - **scout `:313`**（scout_pos→TASK_SCOUT move_target）：`if scout_pos == Vector2i(-1,-1): return false`（無 belief 位→不 scout）。
  - **envoy dispatch `:1284`**（target_pos→_hex_dist budget 計算）：`if target_pos == Vector2i(-1,-1): return false`（gate on has_belief→無位不派 envoy）。
  - **envoy tracking `:1368`**（est_pos→TASK_HERALD move_target）：`if est_pos == Vector2i(-1,-1):` → 用 last-known/parent 位 or fallthrough pursuit-only（預測路徑），非 (-1,-1) 當 move。
  - **encirclement `strategic_ai:139`**（target_pos→座標算術 pos+dir×DIST）：`if target_pos == Vector2i(-1,-1): skip 該 member`（不設 sa_pos）。
  - **★`inquiry_system:64` 排除（R² 判 legit intel-construction 非決策）**：這在建 inquiry 回應 intel dict（記「我知道的位置」），非決策讀 god-view→**不改**（缺 belief 記 live 當 best-estimate 是 intel-record 語意，合法）。
  - **★非純機械**：每 site guard 在**用 pos 前**（避 -1 進 hex_distance/move_target=crash/garbage）。R² 已覆各 site 語意=CLEAN。

## F2：死 *_pos 欄清理（decision_context 從 live 填但無消費者=landmine）
- **根（坐實）**：`decision_context.gd` ~8 個 `*_pos` 欄（`weak_prey_pos`/`occupy_target_pos`/`strong_neighbor_pos`/`aid_target_pos`/`faction_attack_target_pos`/`faction_tribute_target_pos`/`faction_diplo_target_pos`/`intent_target_pos` 等）從 `state.teams[X].tile_pos`（live）填（:204/214/220/231/283/288/...），但 **terms/options 消費 grep=空**（除 `threat_pos`，A1 已修）→ **dead landmine**（未來若有 term 讀 `ctx.*_pos` 算距離=silent god-view）。
- **fix（HOW）**：**移除**這些未消費 *_pos 欄 + 其 live 填充行。**★R²/impl 先 exhaustive 確認全庫無消費者**（`ctx.*_pos`/`_dc.*_pos`/`_pc.*_pos` 各處，no head/no glob——記取 count 教訓）再刪。若某欄意外有消費者→改 belief-gate 非刪。
- 保留 `threat_pos`（A1 已改 belief）、`farmable_pos`/`forage_pos`/`food_market_pos`（自身/tile-physics 或另議，R² 分類——tile 位非他隊位可能 legit）。

## 交付切片
- **F1 fallback sentinel**：5 site（含 inquiry R² 分類）→ sentinel + -1 handling。行為變（缺 belief 時不再瞎追 live 位）→ sim measure。
- **F2 死欄刪**：確認無消費者後刪。**理論 byte-identical**（死欄無消費=刪不改行為）→ determinism 驗；若非 byte-identical=其實有消費者（回頭 belief-gate）。

## 閘
- **R②**（premise code-坐实，R① 免）：F1 各 site -1 handling 語意 + inquiry_system:64 分類（決策 vs intel 建構）；F2 exhaustive 確認無消費者（別漏，count 教訓）+ farmable/forage/market tile-pos 分類。
- **measure（sim, seed1337/42/4201）→ QA 故事稽核 → blueprint release-pass → merge**。★track **doom-delta**（blueprint 判準：穩定=fog cost/爬=propagation 弱）。
- **序：Slice A merged 後（現 main=a5495461）dispatch。**

## 溯源
異質 god-view audit（fallback 反模式 + 死 *_pos 欄）;systems exhaustive 坐实（5 fallback site + decision_context *_pos 無消費者）;invariants「無估 fallback=保守」;[[project_unification_matrix]] god-view arc 序;doom-delta 判準。
