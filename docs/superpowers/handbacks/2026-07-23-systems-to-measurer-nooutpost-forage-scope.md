---
from: systems
to: measurer
status: consumed
topic: "[measure-first·no-outpost-starving 主體確認 + subsistence forage rate 設計 inputs·blueprint 裁(a)後] blueprint 裁 no-outpost 隊可 forage tile 植物糧到 subsistence 率(無設施=低效存活非=0)。spec 前 measure-first 兩組:①主體確認:end-state 絕境隊(food_days<3)分類——no-outpost(lv=0,蹲在有 food pool 的 tile)/ settled-on-productive-tile / forest-real-cost(pop>regen) / settled-left-home(GATE-A) 各佔%(可 reuse fooddiag 既有 per-team lv/terrain/food 資料)→確認 no-outpost 是絕境主體 + 量 GATE-A 少數 share。②subsistence rate 設計 inputs:no-outpost 隊在 food-rich tile 現食入(hunt/forage trickle)/day vs burn(pop×FOOD_PER_PERSON_PER_DAY)→gap;+★對照組 with-outpost 隊在同型 tile 的 _collect_from_tile food 收成/day(設 subsistence < 此=settlement 仍值)。fix locus=resource_system:57-61 no-outpost 分支(現只 hunt_small_game,加 tile.resources.food subsistence forage)。main HEAD 最新(含 re-scope commit)seed42/1337。★別下 fix 結論,數字 to:systems 我定 rate+spec。"
---

# measure-first：no-outpost-starving 主體確認 + subsistence forage rate inputs

blueprint 裁 (a)：no-outpost 隊可 forage tile 植物糧到 **subsistence 率**（無設施=低效存活非=0；`resource_system:57` 現「無據點零被動食物、只狩獵」是純技術 gap）。**spec 前 measure-first**：

## ① 主體確認（no-outpost 是絕境主體嗎 + GATE-A 少數 share）
- end-state 絕境隊（food_days<3）**分類佔%**：
  - **no-outpost**（lv=0，蹲在有 food pool 的 tile）← 疑主體
  - settled-on-productive-tile（有 outpost 但仍餓？）
  - **forest real-cost**（pop>local regen）
  - **settled-left-home**（GATE-A：有 productive home outpost 但離家）← 量此少數 share
- 可 **reuse fooddiag 既有 per-team lv/terrain/food 資料**（別重跑大 sim 若夠）。

## ② subsistence rate 設計 inputs
- no-outpost 隊在 **food-rich tile** 現食入（hunt/forage trickle）**/day** vs **burn**（pop × FOOD_PER_PERSON_PER_DAY）→ **gap**（差多少才活）。
- ★**對照組**：**with-outpost** 隊在同型 tile 的 `_collect_from_tile` food 收成 **/day**（→ 設 subsistence rate **< 此**，保 settlement 仍值 = 從 subsistence 升 surplus/specialization）。
- （fix locus = `resource_system:57-61` no-outpost 分支，現只 `hunt_small_game`，將加 `tile.resources.food` subsistence forage；你量的 rate 定 spec 數值。）

## 跑法
main HEAD 最新（含 re-scope commit）seed 42/1337。**★別下 fix 結論**——數字 to:systems，我定 subsistence rate + spec。
