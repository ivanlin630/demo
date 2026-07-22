# spec：facility dispatch afford buffer ×1.5 → 一致化（Gate B cheap 獨立項）

> 層級：L3（1 行 const，behavior-sensitive tuning）。off LOCAL main。blueprint 授權查證+調（cheap 不等）。
> 來源：weapon afford 診斷——`_dispatch_facility_builder:2780` 要 owner `avail ≥ cost×1.5`（weaponsmith material 80→需 120），但 **in-place 路 `_can_afford`（outpost:447）用 exact cost（80）**=不一致。mil 隊 hold 54-80、常 roaming（走 dispatch 路）→ 卡 120 建不了 weaponsmith。

## 根（code fact）
- **dispatch 路**（`_dispatch_facility_builder:2780`）：`if avail < cost[k]*1.5: return false`——owner 需 1.5× cost（funds 1× 給 subteam + 留 0.5× buffer）。**★×1.5 undocumented**（無註解說明為何）。
- **in-place 路**（`_begin_facility_construction`→`_can_afford`）：**exact cost（×1.0）**，deduct 後 owner 可到 0。
- ∴ dispatch 的 0.5× buffer = **與 in-place 不一致的 anomaly**；對 roaming mil 隊（多走 dispatch）= 額外 50% 門檻卡建。

## 修（一致化 + named const TEST VALUE）
`_dispatch_facility_builder`：`cost[k]*1.5` → `cost[k]*FACILITY_DISPATCH_AFFORD_MULT`，新 const：
```gdscript
const FACILITY_DISPATCH_AFFORD_MULT: float = 1.1   # TEST VALUE — dispatch 路 afford buffer（原 1.5 undocumented,與 in-place exact 不一致→降；1.1 留小 buffer 給 subteam 攜料途損/rounding,非 0.5× 大 buffer）
```
- **1.1 非 1.0**：留小 buffer（subteam 攜料途中無損耗，但保守留 10% 防 rounding/邊界）——measurer 可 tune。
- **★仍是 trade-primary 的次要項**（blueprint ②）：這只降 dispatch 門檻，mil 隊仍需**有** material（54-80 隊靠買才夠 80）→ material 貿易流（另軌 measure）才是主。此項讓「有料的 mil 隊別被 ×1.5 多卡」。

## 驗收
- **TDD**：owner avail=90、cost=80 → 原 ×1.5(120) fail / 新 ×1.1(88) fail(90≥88 pass)... 校準：avail=90 cost=80 → 88 → pass（原 120 fail）。owner avail=80 cost=80 → ×1.1(88) fail（保守，恰足不夠 buffer）；avail=88 → pass。
- **gate** PASS / **headless** 0 new / **determinism** 2 跑 byte-identical（無 RNG）。
- **★measure（→measurer，帶 §④b 樣本；長跑→QA）**：facility-build-by-type（weaponsmith dispatch 成功率↑?）+ doom-delta + 無回歸。**與 material 貿易流 measure 分開**（別 conflate；此驗「降 buffer 讓有料隊建得成」，那驗「無料隊買得到」）。

## 排序
cheap 獨立（blueprint 授權不等）。R²（一致化理由/1.1 vs 1.0 buffer/無 RNG/與 trade 主線分工）→ dispatch。
