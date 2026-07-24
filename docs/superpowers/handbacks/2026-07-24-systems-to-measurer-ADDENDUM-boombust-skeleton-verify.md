---
from: systems
to: measurer
status: consumed
topic: "[ADDENDUM 給前一封 material-supply measure·設計訂正(lumbercamp/boom-bust 非 no-facility)·加 Q3 boom-bust 骨架驗證·同一 run 折入·骨架我已 code-verify] 訂正:material 供給設計改=伐木場(開採加速器)+森林初始庫存 boom+重採耗竭 regen 慢回=boom-bust(非上封『不加設施』,blueprint 誤讀用戶已訂正)。★我 code-verify 骨架(blueprint 這次對):forest material cap/初始=[80,220]/tile(world_generator:10,cap=resources.duplicate:101=初始即 boom 存量)、regen 12/day 補到 cap(resource_system:93,不 day_fraction 縮放)、harvest gain ∝ current pool(_collect_from_tile:12 proportional→pool 降 harvest 自動變慢=self-damping)、VALVE.material_harvest probe 已在(你本 session 早裝)。★★加 Q3(決策關鍵,同 run 折入):trace forest tile material pool 隨時間在 active harvest 下——(a)pool 真耗竭嗎?還是 12/day regen+proportional self-damping 讓它黏 cap 附近=bust 感覺不到?(b)初始庫存實際分布(80-220 range 撒出來多少)=boom 多大(c)重採下 time-to-deplete + regen 回補要多久=慢不慢。交付=★耗竭骨架現行有沒有『有感 boom-bust』還是 regen 太快/harvest 太 self-damping→定 blueprint 要不要動 regen。★Q1 aggregate 重frame=供給兩件:初始 boom 存量(Σforest cap 80-220)+regen tail(Σforest 12/day),分開報非單一 steady。Q2 valve reachability(BUY/EXPAND)不變。同 run(a728fe90,seed1337/42),piggyback order-noise 月率不變。→回 to:systems。"
branch: main (a728fe90)
---

# ADDENDUM：material-supply measure 設計訂正 + Q3 boom-bust 骨架驗證

**接前一封** `2026-07-24-systems-to-measurer-material-supply-aggregate-and-valve-reachability.md`（同一 run，別重跑）。

## 設計訂正（blueprint 誤讀用戶已改）
material 供給 ≠「不加設施」。**改 = 伐木場（開採加速器，forest-only）+ 森林初始庫存 boom + 重採耗竭 regen 慢回 = boom-bust**。material = 開採非耕作（育林不 coherent，砍更快 + 耗竭代價 coherent）。

## ★骨架我已 code-verify（blueprint 這次對，我逐行驗過）
- forest material **cap/初始 = [80,220]/tile**（`world_generator.gd:10`；`resource_cap = resources.duplicate()` :101 → cap = 初始值 = boom 存量）。
- regen **12/day 補到 cap**（`resource_system.gd:93`，material 不 day_fraction 縮放）。
- harvest **gain ∝ current pool**（`_collect_from_tile:12`，proportional → pool 降 harvest 自動變慢 = **self-damping**，不易清零）。
- **VALVE.material_harvest probe 已在**（你本 session 早裝，`_collect_from_tile:22`）。

## ★★Q3（新增，決策關鍵，同 run 折入）：boom-bust 骨架驗證
trace 代表性 forest tile 的 material pool 隨時間（active harvest 下）：
- **(a) pool 真耗竭嗎？** 還是 12/day regen + proportional self-damping 讓它黏 cap 附近 = **bust 感覺不到**？
- **(b) 初始庫存實際分布**（80-220 撒出來多少）= boom 多大。
- **(c) 重採下 time-to-deplete + regen 回補時間** = 慢不慢。
- **★交付**：現行耗竭骨架有沒有『有感 boom-bust』，還是 regen 太快 / harvest 太 self-damping → **定 blueprint 要不要動 regen**（他明說 measure 後回報他再裁 regen 動不動）。

## Q1 重 frame + Q2 不變
- **Q1 aggregate = 兩件分開報**：①初始 boom 存量（Σ forest cap 80-220）②regen tail（Σ forest 12/day）。非單一 steady-state 數。
- **Q2 valve reachability**（BUY/EXPAND 缺料 plains 隊哪個最可達）**不變**。
- 同 run（a728fe90，seed 1337/42），piggyback order-noise 月率不變。→ 回 `to:systems`。
