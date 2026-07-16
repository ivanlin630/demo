---
from: systems
to: implementer
status: consumed
topic: [S1 rev3 修] 補 3 常數宣告(parse 錯 halt)+ 清死碼——reviewer premise_contradiction
---

# 修：S1 rev3 常數未宣告 + 死碼

reviewer② halt（`reviewer-to-systems-s1-rev3-absolute-verdict`，premise_contradiction=true）：rev3 `_apply_pursuit`（`:573`）用 `PURSUIT_CRUELTY_K`/`PURSUIT_GREED_K`/`PURSUIT_KILL_CAP` **三常數全檔無宣告** → identifier not declared → **過不了 parse**（跑不動）。設計方向 reviewer 確認對，唯常數缺失擋審。

## 改（2 件）
1. **★補 3 常數宣告**（`npc_combat_system.gd` const 區，值照 spec §S1 rev3 TEST VALUE）：
```gdscript
const PURSUIT_CRUELTY_K: float = 2.0
const PURSUIT_GREED_K:   float = 0.8
const PURSUIT_KILL_CAP:  int   = 3
```
2. **清死碼**（reviewer issue②，一併）：
   - 刪 `_pursuit_carry` 宣告（`:49`）——rev3 撤累積器，現無讀寫者。
   - 刪舊 rev1 四常數 `PURSUIT_CRUELTY_W`/`PURSUIT_GREED_W`/`PURSUIT_FACTOR_MIN`/`PURSUIT_FACTOR_MAX`（`:7-10`）——rev3 無引用。
   - `PURSUIT_RATE`（`:5`）：rev3 straggler_kill 不再乘它——**grep 確認別處是否仍用**，無用則刪，有用則留。

## 保（reviewer 已驗，別動）
- `_cas_carry` erase（`:327-328`/`:485-486`）✓ 已補 §D4 債，保留。
- `mini(pursuit_loss, loser.population)` 防超殺✓、呼叫點不重入 annihilation✓。

## gate
`--import` 過（parse 綠=首要）→ multi-sanity/constitution/determinism → handback to:measurer（三端+loss_sum）。**merge 閘=reviewer 再過一輪 diff CLEAN + measurer 三端**。
