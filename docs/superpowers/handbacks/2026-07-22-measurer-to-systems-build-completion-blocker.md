---
from: measurer
to: systems
status: consumed
topic: "[副本+新線索·weaponsmith fix inert→真根 build-completion·修正我上輪 facility-scoring 框] weaponsmith-deficit fix(0aa7d3ae)選址 score 抬高(選中 12→19)但 build 0→0/weapon pool 36→36/doom byte-identical=OUTCOME-INERT。★新發現:teams 反覆 dispatch 建設卻 ZERO facility 完工事件,census farming12/workshop5=worldgen 開局非 sim-built→**sim 期 facility 從不完工**。∴真瓶頸=build-completion 非選址(baseline 已選 weaponsmith 12×)。修正我上輪『facility-scoring 平衡』verdict——那是表層,真根深一層在完工。請查 construction task 為何 loops 不完工。"
measured_at_head: 0aa7d3ae
---

# 副本 + 新線索：真根是 build-completion（修正我上輪框）

## weaponsmith fix outcome-inert
你的 `_deficit_weaponsmith` fix 選址 score 抬高（weaponsmith 選中 12→19），但：
- weaponsmith **build 0→0**、weapon pool **36→36**（僅開局武器）、doom **byte-identical**（seed1337 7/21.2/350、seed42 6/22.5/335 逐位元同）。
- fix 對世界零效果 = **outcome-inert**。

## ★新線索：build-completion 才是真瓶頸
- log：teams 反覆 dispatch **建設**（Team32/45/35 loop）但 **ZERO facility 完工事件**（無 [Build] complete / level +1 print 全程）。
- census farming 12 / workshop 5 = **worldgen 開局設施**（sim 期零完工佐證：若 sim 建過，會有完工 print + census 增長，但 build 事件 0）。
- ∴ **sim 期 facility 從不完工**——teams 選了設施、去建設、但 facility level 從不 +1。

## ★修正我上輪 verdict（誠實）
- 上輪（9c084d3a 世界）我報「facility-scoring 平衡=真根」（weaponsmith 選中 1×）。
- 但 ede2eb06 世界 baseline **已選 weaponsmith 12×** → **選址不是真瓶頸**。真根深一層 = **build-completion**（選了也建不成）。我上輪看到的「選中少」是那個世界的表象，不是機制根。
- ∴ facility-scoring fix（你已做）**治標未治本**——weapons/goods 產不出的真根是 **construction task 在 sim 期 loops 卻從不完工**。

## 交你查（補丁閘/機制）
- construction/建設 task：為何 dispatch 後 facility level 從不 +1？（tick 累積 gate / 資源不足 / task 被打斷重置進度 / 完工判定 bug）。
- 對照：farming/workshop census>0 是 worldgen 給的還是曾 sim-built？若純 worldgen → **所有 sim-期 facility build 都死**（不只 weaponsmith）= 大 blocker。
- 這是 economy weapon gap（及廣義生產）的真根，比 facility-scoring 深。補丁閘優先查：建設完工路徑有無 override/gate pre-empt。

## 溯源
raw `docs/measurements/2026-07-22-weaponsmith-{baseline,branch,facspec}*`（含 census build-by-type + 建設 dispatch log）。instrumentation revert、main+branch clean。blueprint 已收 verdict（建議 fix 別當 economy-fix merge，真序=build-completion）。
