---
from: reviewer
to: systems
status: consumed
topic: "[R②判決·CLEAN] Fix F pursuit vision-gate——premise(pipeline序/無off-by-one)+三態邏輯+determinism全驗證,兩項非阻擋advisory;可dispatch(position-belief slice最後merge-blocker)"
---

# R② 判決：Fix F `_refresh_attack_pursuit` vision-gate

verdict: **clean**
premise_contradiction: false

## premise 驗證（要害驗，你要求證的那條）

`git show feat/position-belief:scripts/simulation/faction_ai_system.gd` 確認 `_refresh_attack_pursuit`（:277-293）與 main HEAD 讀到的版本 byte-identical——A-E 確實未動它，Fix F 是真缺口非重複修。

pipeline 序：`git diff main feat/position-belief -- scripts/simulation/sim_runner.gd` 零變更，用 main 版核對即代表分支現況。`:184 _step1b_update_vision(near)` → `:216 _step6b_faction_ai(near)`；`:238 vision(far)` → `:257 faction_ai(far)`；`:133 _step1_advance_time` 已先 +1 於整個 near/far 迴圈之前。**vision 皆在 faction_ai 之前同 tick 跑，無 off-by-one**——你的「證某路徑 faction_ai 讀在 vision 前＝premise_contradiction」假設不成立，gate 訊號 `last_tick==current_tick` 站得住。

## 設計驗證

- **三態邏輯**：①可見（live 攔截）②斷視線+belief 新（last-seen 撲空）③斷視線+過期/無 tile_pos（release 放棄）——`git show feat/position-belief:scripts/simulation/belief_system.gd` 核對 `belief_pos`（`:122-139`）已用同款 staleness pattern（`now - last_tick > BELIEF_STALE_TICKS`），Fix F 沿用一致寫法。
- **態③非 scope creep，同意你的判斷**：態②引入「追 last-seen」後若無態③，stale target 會讓 `TASK_ATTACK`/`TASK_LOOT` 永久卡住無 re-eval（`prosperity_target_id` 不會自然清空）——這是態②引入的新 ghost-chase 風險，態③是必要收尾，非額外功能。
- **gate 語意分工（`last_tick==current_tick` vs `belief_pos` 3天 staleness）合理**：攔截需要「現在看得到」比「大致知道在哪」嚴格，兩種 gate 服務不同精度需求，分工正確。
- **憲法/determinism**：零新 try_set（改 move_target 來源 + 既有 release 路徑）；belief 讀純確定性；`seen_now` 分支才呼 `predict_intercept`/`observe_velocity`，randf 時機同 Fix C 語意——驗收「同 seed 兩跑 bit-identical」措辭正確延續 R②#8 裁定。

## 兩項 advisory（非阻擋，供 implementer 參考）

1. **態①的比對式簡化成 no-op**：`predicted if predicted != prey.tile_pos else prey.tile_pos` 兩分支結果恆等於 `predicted`（不像原碼 `:293` 的 `else last_pos` 有真正意義的替代）。語意上無害——因為已被外層 `last_tick==current_tick` gate 保證這一刻「真可見」，`predict_intercept` 內部即使退活值也站得住（在視線內用活值合法）。但寫法容易誤導閱讀者以為有防護邏輯，建議直接寫 `team.move_target = predicted`，更誠實。
2. **理論邊角**：`_find_weakest_prey`（`faction_ai_system.gd:3311-3332`）沒有排除同 faction 目標（迭代 `team_discovered` 無 faction_id 過濾），若 `prosperity_target_id` 曾經是同 faction 隊（理論可能，非本刀範圍），Fix F 用純 `BeliefSystem.best_estimate` 而非 `belief_pos` 的通道分流，同僚可能無 belief claim 而提早進態③。這是**既有 finder 的 pre-existing 特性、非 Fix F 引入**，不要求本刀處理，僅供記錄（若真發生，效果是「提早放棄攻擊」而非危險行為，可接受的保守退化）。

## 結論
premise 站得住（無 off-by-one）、三態設計健全、態③非 scope creep、determinism/憲法皆守。**CLEAN → 可直接 dispatch implementer**（position-belief slice 最後一個 merge-blocker）。
