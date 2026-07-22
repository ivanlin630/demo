# spec：facility dispatch afford buffer ×1.5 → 一致化（Gate B cheap 獨立項）

> 層級：L3（1 行 const，behavior-sensitive tuning）。off LOCAL main。blueprint 授權查證+調（cheap 不等）。
> 來源：weapon afford 診斷——`_dispatch_facility_builder:2780` 要 owner `avail ≥ cost×1.5`（weaponsmith material 80→需 120），但 **in-place 路 `_can_afford`（outpost:447）用 exact cost（80）**=不一致。mil 隊 hold 54-80、常 roaming（走 dispatch 路）→ 卡 120 建不了 weaponsmith。

## 根（code fact，★reviewer R² 訂正 framing）
- **★×1.5 非 anomaly，是 3 站一致 dispatch convention**（reviewer 訂正我原「vs in-place anomaly」framing 錯）：dispatch 路（派移動 subteam，`_fund_subteam_cost` 撥料）owner 需 1.5× cost=funds 1× + 留 0.5× buffer，**語意=資助一支要走的 subteam**（≠ in-place internal 就地扣款）。in-place `_can_afford` exact 是**不同語意**（同格自建），非「該一致」。
- **但這 dispatch buffer = choke point**（作者 `98a0a8f7` 認：非神聖 buffer）：weaponsmith material 80 → dispatch 需 120，roaming mil 隊 hold 54-80 → 卡建不了。**降 buffer 解 choke**（非「修 anomaly」）。

## 修（降 dispatch buffer，★連姊妹站 2637+2780 同 const）
新 const，**兩 dispatch 站同用**（保持 dispatch convention 一致，reviewer 訂正：只改 2780=新不一致）：
```gdscript
const FACILITY_DISPATCH_AFFORD_MULT: float = 1.1   # TEST VALUE — dispatch 路 afford buffer(資助移動 subteam；原 1.5 是 choke,降解 mil weaponsmith 卡建；1.1 留小 fund-transfer buffer 防途損/rounding/owner-depletion,measurer tune)
```
- **`_dispatch_facility_builder:2780`**（`cost[k]*1.5` → `*FACILITY_DISPATCH_AFFORD_MULT`）。
- **★`_dispatch_upgrader:2637`**（姊妹站，同 vault+private ×1.5 → 同 const）——**必連改**（reviewer：只改 2780 自拆一致化）。
- **`2551`（新據點 strict-private）= 另案不碰**（reviewer 標，不同語意）。
- **1.1 有 fund-transfer 語意支撐**（dispatch 資助移動 subteam，留小 buffer 防 owner 撥完 depletion；reviewer defensible）。
- **★仍是 trade-primary 次要**（blueprint ②）：只降 dispatch 門檻，mil 仍需**有** material（54-80 靠買才夠）→ material 貿易流（另軌 measure）才是主。別誤當主 fix。

## 驗收
- **TDD**：①owner avail=90 cost=80 → ×1.1(88) pass（原 ×1.5 120 fail）②avail=80 cost=80 → ×1.1(88) fail（恰足不夠小 buffer）③avail=88 → pass ④**姊妹站 `_dispatch_upgrader` 同 const 同行為**（別漏改）。
- **gate** PASS / **headless** 0 new / **determinism** 2 跑 byte-identical（無 RNG）。
- **★measure（→measurer，帶 §④b 樣本；長跑→QA）**：facility-build-by-type（weaponsmith/outpost-upgrade dispatch 成功率↑?）+ **★owner-depletion 稽核**（降 buffer 後 owner 撥料是否 depletion→thrash/餓？reviewer 要驗）+ doom-delta + 無回歸。**與 material 貿易流 measure 分開**（別 conflate；此驗「降 buffer 讓有料隊建得成 + 無 owner-depletion 副作用」，那驗「無料隊買得到」）。

## 排序
cheap 獨立（blueprint 授權不等）。R²（一致化理由/1.1 vs 1.0 buffer/無 RNG/與 trade 主線分工）→ dispatch。
