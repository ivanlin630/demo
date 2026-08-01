---
from: systems
to: implementer
status: consumed
topic: "[REDO·means-end S3·material 缺口鏈補 build-closure frontier(閉環到採)·★must-fix② 憲法守住+tile-resolver 拆兩類+belief store 全 PASS 別動·只補『到 forest tile 後建 outpost』frontier·我 dispatch 含糊澄清非你錯·branch 續 feat/means-end-s3-location] S3 我 systems 收驗:★must-fix② 憲法守住(find_nearest_terrain_tile 純 terrain # gate-ok/find_nearest_known_tile 讀 team_tile_known belief/兩類分流正確/belief-reachable/tie-break tile_id 禁 randf)=PASS 別動。★但 material 缺口鏈**未閉環**:只到『移動到 forest tile』(TASK_MIGRATE),缺『到了建 outpost』frontier→隊到 forest 後 own-outpost.terrain 仍非 forest(隊站 forest tile 但沒在那建據點)→反覆生移動 candidate(d=0 到自己 tile)卡住,未閉環到採 material=arc 核心價值(隊真到 forest 建據點採料)沒實現。我 dispatch 含糊(『移動 candidate』vs『建 outpost 接既有最小』並存)→你保守只做移動=非你錯,我澄清。★REDO 只補一塊(其餘 PASS 別動):material 缺口鏈(_resolve_resource_prereq 採@地形手段)加**build-closure frontier**——隊**已在**目標地形 tile(move_target 到達/team.tile_pos==forest tile)且該 tile 無 own outpost→生『建 outpost 那裡』candidate:to_task 接既有建 outpost 機械(OutpostSystem.start_build on current forest tile,或既有『建設』option to_task=TASK_BUILD target=team.tile_pos——隊已移到 forest→in-place build 正好建 forest outpost)。→湧現順序閉環:缺料→移動到 forest(frontier1)→到了→建 outpost(frontier2,前置=在 forest tile 滿才 applicable)→own-outpost.terrain==forest→採 satisfied。★unowned 過濾:build-closure 若目標 forest tile 已被別隊擁有→start_build『目標格已有據點』return false=既有機械自然擋(S3 不需額外 unowned belief 查,建失敗自然 fall through;真需 unowned 優選=S4/whole measure 後精修,非 S3 blocker)。★委派(派子隊 build)仍 S5 別提前,S3 隊自己 build。TDD 補:①隊在 forest tile 無 outpost→build-closure candidate 出現②隊建成 forest outpost→own.terrain==forest→採 satisfied 無 move/build candidate(閉環)③determinism byte-identical(build candidate 純狀態,tie-break)④must-fix②/既有 TDD 全 regression 綠。閘:constitution_gate 74 removed=0(build-closure 無新 god-view/RNG)+headless 0-new+determinism。完成→to:systems 收驗+S3 R²(完整含閉環)。★whole-system-first:只補 build-closure 閉環 material 缺口;人力/設施 facility/子目標/折現/委派=S4-S6 別提前。"
branch: feat/means-end-s3-location
---

# REDO：S3 material 缺口鏈補 build-closure frontier（閉環到採）

## systems 收驗結果
- ★**must-fix② 憲法守住 = PASS 別動**：`find_nearest_terrain_tile`（純 terrain `# gate-ok`）/ `find_nearest_known_tile`（讀 team_tile_known belief）/ 兩類分流正確 / belief-reachable / tie-break tile_id 禁 randf。tile-resolver + belief store 全乾淨。
- ★**material 缺口鏈未閉環**（要補）：只到「移動到 forest tile」（TASK_MIGRATE），**缺「到了建 outpost」frontier** → 隊到 forest 後 own-outpost.terrain 仍非 forest（隊站 forest tile 但沒在那建據點）→ 反覆生移動 candidate（d=0 到自己 tile）**卡住**，未閉環到採 material。arc 核心價值（隊真到 forest 建據點採料）沒實現。
- **我 dispatch 含糊**（「移動 candidate」vs「建 outpost 接既有最小」並存）→ 你保守只做移動 = **非你錯，我澄清**。

## REDO 只補一塊（其餘 PASS 別動）
material 缺口鏈（`_resolve_resource_prereq` 採@地形手段）加 **build-closure frontier**：
- 隊**已在**目標地形 tile（`team.tile_pos == forest tile` / move 到達）且該 tile 無 own outpost → 生「**建 outpost 那裡**」candidate。
- `to_task` 接既有建 outpost 機械：`OutpostSystem.start_build` on current forest tile，或既有「建設」option `to_task=TASK_BUILD target=team.tile_pos`（隊已移到 forest → in-place build 正好建 forest outpost）。
- → **湧現順序閉環**：缺料 → 移動到 forest（frontier1）→ 到了 → 建 outpost（frontier2，前置=在 forest tile 滿才 applicable）→ own-outpost.terrain==forest → **採 satisfied**。

## unowned + 委派邊界
- **unowned 過濾**：build-closure 若目標 forest tile 已被別隊擁有 → `start_build`「目標格已有據點」return false = **既有機械自然擋**（S3 不需額外 unowned belief 查，建失敗自然 fall through；真需 unowned 優選 = S4/whole measure 後精修，非 S3 blocker）。
- **委派**（派子隊 build）仍 S5 別提前，S3 隊自己 build。

## TDD 補 + 閘
1. 隊在 forest tile 無 outpost → build-closure candidate 出現。
2. 隊建成 forest outpost → own.terrain==forest → 採 satisfied（無 move/build candidate ＝ 閉環）。
3. determinism byte-identical（build candidate 純狀態，tie-break）。
4. must-fix②/既有 TDD 全 regression 綠。
- `constitution_gate` 74 removed=0（build-closure 無新 god-view/RNG）+ headless 0-new + determinism。

## 完成
→ `to:systems` 收驗 + S3 R²（完整含閉環）。★whole-system-first：只補 build-closure；人力/設施 facility/子目標/折現/委派 = S4-S6 別提前。
