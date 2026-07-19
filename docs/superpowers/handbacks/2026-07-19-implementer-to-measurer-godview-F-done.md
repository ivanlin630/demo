---
from: implementer
to: measurer
status: consumed
topic: "[god-view Slice F done·F2 byte-identical 確認·F1 待 doom-delta measure] F1 fallback→sentinel+guard 4 site(scout/envoy-dispatch/envoy-track/encircle;inquiry:64 不改)。F2 刪 8 死 *_pos 欄(exhaustive grep 零消費者)。★F2 byte-identical 硬證:base(a5495461)==F2-only==full(F1+F2)==mine-2x 全 b2452128(死欄刪零行為變)+determinism 2跑 byte-identical。F1 在 game_sim_multi 沒 fire(隊互見有 belief)→行為變只在 belief-loss 情境→你 organic 量 doom-delta。char bed 5/5,gate 64。branch feat/godview-slice-F@20d4ce97 off local main a5495461。measure seed1337/42/4201 is_sim=true→.qa.json,★track doom-delta(穩定/爬)。"
---

# god-view Slice F done（F2 byte-identical 確認，F1 待 doom-delta measure）

## F1：fallback-to-live → sentinel + per-site guard（4 site）
缺 belief tile_pos → `.get("tile_pos", Vector2i(-1,-1))`（禁默認 live 真位=god-view 回潮）+ 用 pos 前 guard：
- **scout** `_commit_conquest_attack:313`：scout_pos (-1,-1) → `return false`（不 scout）。
- **envoy dispatch** `_dispatch_envoy:1284`：target_pos (-1,-1) → `return false`（無位不派）。
- **envoy tracking** `:1368`：est_pos (-1,-1) → 保持現 move_target（predicted/est_pos/現位，不設 -1/live）。
- **encircle** `strategic_ai _assign_encirclement:139`：target_pos (-1,-1) → `return`（不設 sa_pos）。
- **inquiry_system:64 不改**（R² 判 legit intel-construction）。

## F2：刪 8 死 *_pos 欄（exhaustive grep 零 production 消費者）
def+fill 刪：weak_prey_pos/occupy_target_pos/strong_neighbor_pos/aid_target_pos/faction_attack_target_pos/faction_tribute_target_pos/faction_diplo_target_pos/intent_target_pos。保留 farmable/forage/food_market/threat_pos。intent 段 rewrite 保 intent_target 賦值；移 vendetta test write。

## ★驗（我側，F2 byte-identical 硬證）
- **F2 byte-identical**：`game_sim_multi` hash **base(a5495461) == F2-only(base+F2) == full(F1+F2) == mine-2x = `b2452128`**（四者全同）→ **死欄刪零行為變確認**（無隱藏消費者；符 spec「若非 byte-identical=有消費者」→ 是 byte-identical）。
- **determinism**：mine 2 跑 byte-identical。
- **F1 在 game_sim_multi 沒 fire**（seed 內隊互見→有 belief→guard 不觸）→ F1 行為變**只在 belief-loss 情境**（敵脫視/未偵）→ 你 organic 才量得到。
- char bed `godview_f_test` **5/5 PASS**（scout/envoy/encircle 無 belief→不 dispatch/不設 assignment；測試對舊 live-fallback 會 fail=捕行為變）。gate PASS(64, removed=0)。

## ★需你 measure（branch@20d4ce97，off local main a5495461）
- `is_sim=true` + seed1337/42/4201 → `.qa.json`
- **★track doom-delta**（blueprint 判準）：F1 缺 belief 不瞎追 live → 加 fog cost。**穩定=fog 成本可接受 / 爬=propagation 弱需補**。
- 驗：scout/envoy/encircle 在 belief-loss 時不再瞎追 live 真位（god-view 殲滅↓）；世界不因 fog 塌（doom 穩定）。
- F2 你也可跑 determinism 三跑 byte-identical 複核（我已 4-way 同）。

## 溯源
dispatch `2026-07-19-systems-to-implementer-godview-slice-F.md`；spec F1/F2；doom-delta 判準；[[project_unification_matrix]] god-view arc。
