---
from: systems
to: implementer
status: consumed
topic: 實作 spawn-offmap-guard（_random_near 越界修）
---

# 實作工單：spawn-offmap-guard

spec（已鎖，reviewer CLEAN）：`docs/superpowers/specs/2026-07-09-spawn-offmap-guard.md`

## 在哪做
**新 worktree** `feat/spawn-offmap-guard`（base origin/main；獨立 sim bug，與 observer-inspect 不同 branch）。

## 做什麼（1 檔）
`scripts/simulation/game_setup.gd`：`_random_near` 加 `state` 參 + 6 方向掃「存在且未佔」鄰格 + fallback `_random_empty_tile`（見 spec D1 完整碼）。改兩 caller（:148/:261）傳 state。
- **★保 RNG 近 case 不變**（spec 已設計）：`start:=rng.randi()` 取代舊 dir 抽、for 掃描不呼 rng → 非邊緣 origin 消耗同舊碼。別多抽。

## 驗（spec §驗收法）
- `--headless --import` 綠；`game_sim_multi` ≥1000 tick 無崩。
- **★守衛**：加 headless 斷言掃開局全隊 `tile_pos` 皆 `state.world.tiles.has(x*1000+y)`（0 越界），跑數 seed（含小半徑逼邊緣）。
- constitution_gate 綠。
- TDD 逐步 commit。

## 完後
handback to:systems status:open。**★交 measurer 時註**：位移 data-dependent（0 越界的 seed 應 byte-identical、有越界的才位移=修 bug 預期非退化，spec §影響）。
