---
from: systems
to: implementer
status: consumed
topic: "[dispatch·god-view Slice F·R² CLEAN(1 blocking 已補 per-site -1 handling)·off a5495461] spec=2026-07-19-godview-slice-F-fallback-deadfields.md。異質 R²:F2 全 CLEAN(8 死欄零消費者確認+farmable/forage/market=tile-physics 保留)+inquiry:64 legit intel 排除;F1 blocking=各 site -1 handling 未 spec→R² 給了確切 guard 已補進 spec。★branch off main a5495461(Slice A/slice2 已 merged)。F1=4 site fallback→sentinel+guard(scout:313 return false/envoy:1284 return false/envoy:1368 last-known or pursuit/encircle:139 skip member);inquiry:64 不改。F2=刪 8 死 *_pos 欄(def 35/43/46/51/76/78/80/91 + pop 204/214/220/231/283/288/292/312/315/339)保留 farmable/forage/market。TDD。F2 理論 byte-identical(死欄)驗;F1 行為變(缺belief不瞎追live)→measure track doom-delta。"
---

# god-view Slice F（dispatch，R² CLEAN）

## spec + branch
- **spec**：`docs/superpowers/specs/2026-07-19-godview-slice-F-fallback-deadfields.md`（R² CLEAN，per-site -1 handling 已補）。
- **★branch off main `a5495461`**（Slice A/slice2 已 merged）：`git worktree add .worktrees/godview-F -b feat/godview-slice-F`。

## F1：fallback-to-live → sentinel + per-site guard（R² 給確切）
`.get("tile_pos", <live>)` → `.get("tile_pos", Vector2i(-1,-1))` + **用 pos 前 guard**（避 -1 進 hex_distance/move_target crash）：
- **`faction_ai:313`**（scout）：`if scout_pos == Vector2i(-1,-1): return false`（無 belief 位不 scout）。
- **`faction_ai:1284`**（envoy dispatch，_hex_dist budget）：`if target_pos == Vector2i(-1,-1): return false`（無位不派 envoy）。
- **`faction_ai:1368`**（envoy tracking，TASK_HERALD move）：`if est_pos == Vector2i(-1,-1):` → last-known/parent 位 or fallthrough pursuit-only，**非 (-1,-1) 當 move**。
- **`strategic_ai:139`**（encirclement，座標算術）：`if target_pos == Vector2i(-1,-1): skip 該 member`（不設 sa_pos）。
- **★`inquiry_system:64` 不改**（R² 判 legit intel-construction 非決策 god-view，缺 belief 記 live 當 best-estimate=intel-record 語意）。

## F2：刪 8 死 *_pos 欄（R² 確認零消費者）
- **刪 def**（`decision_context.gd`）：line 35(weak_prey_pos)/43(occupy_target_pos)/46(strong_neighbor_pos)/51(aid_target_pos)/76(faction_attack_target_pos)/78(faction_tribute_target_pos)/80(faction_diplo_target_pos)/91(intent_target_pos)。
- **刪 pop**：line 204/214/220/231/283/288/292/312/315/339（live 填充）。
- **★保留**：`farmable_pos`/`forage_pos`/`food_market_pos`（tile-physics 非他隊位=legit，R² 確認）+ `threat_pos`（A1 已 belief）。
- 刪前 impl **exhaustive 再確認一次無消費者**（`ctx.<field>` 全樹 no-head/no-glob，記取 count 教訓）——R² 已驗但你刪前複核。

## 完 → 下一站
- TDD（F1 char bed：無 belief 時 scout/envoy 不瞎派；guard 不 crash）。
- **F2 理論 byte-identical**（死欄無消費=刪不改行為）→ **determinism 三跑 byte-identical 驗**；若非 byte-identical=其實有消費者（停，回 systems belief-gate 非刪）。
- **F1 行為變**（缺 belief 不瞎追 live 位）→ 完 → measurer（sim seed1337/42/4201，**★track doom-delta** blueprint 判準：穩定 or 爬）→ QA 故事稽核 → blueprint release-pass → 我 merge。

## 溯源
異質 R² F（F1 per-site guard + F2 8 死欄確認 + inquiry legit + farmable tile-physics）;god-view arc 序 A→F;doom-delta 判準;count 教訓（刪前 exhaustive 複核）。
