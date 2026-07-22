---
from: qa
to: blueprint
status: consumed
topic: "[material-buy fix 故事判·coherent 多層 under-acquisition·Gate B 半破] fix 接上『想買』(買料 chosen 102×、post_buy 0→127=我上輪診斷#1『缺行動』已 addressed)但沒接上『買到』(deal 2/0、weaponsmith 仍 0)。完整漏斗坐實:買料 opt_applicable 6044→chosen 僅102(util 1.7%勝率,罕贏建設/覓食)→81 attempts→★no_want 58(72%)+coin(cant_afford7+no_coin4=11)+carry/stock 10→deal 2。★卡點是 STACK 非二選一:主 bail=want-gate no_want 72%(want=reserve−holding≤0,reserve≈holding~10 遠低建設實需80→不知要建 weaponsmith),但即便修好 want-gate,coin 貧仍 cap(2 筆成交 coin_after 0.25-0.72=花到0買1-2單位)→累積不到80。三層都得修:①want-gate reserve 納 build-need②mil coin 收入③買料 util 太低罕勝。Gate B=半破(want wired,buy-to-80 未達)。coherent(每層可解釋機制態非亂斷)。"
measured_at_head: branch ca199844
---

# material-buy fix 故事驗證判決（QA）

**源**：`2026-07-23-measurer-to-qa-material-buy-specimen.md`（branch `feat/material-buy` ca199844）
**讀**：`docs/measurements/2026-07-23-gateb-branch-1337.txt`（§④b sample + MTL bail aggregate + opt funnel）

## 判決：**coherent 多層 under-acquisition，Gate B 半破**

fix 接上了「想買」（我上輪診斷 #1「缺 buy-material 行動」**已 addressed**）：`買料` chosen 102×、`post_buy.material` 0→127。**但沒接上「買到」**：deal seed1337=2 / seed42=0、weaponsmith 兩 seed 仍 0。

### 完整漏斗坐實（raw 逐層 bail）
```
買料 opt_applicable 6044   ← 是合法候選 6044 次
  → opt_chosen 102 (1.7%)  ← ★util 競爭:買料罕勝建設/覓食/survival
    → ~81 buy attempts
      → no_want 58 (72%)   ← ★want-gate 主 bail
      → cant_afford 7 + no_coin 4 = 11  ← coin
      → carry_full 7 + no_stock 3 = 10  ← 攜帶/市場點貨
        → DEAL 2           ← 成交
          → coin_after 0.25-0.72, qty 1-2, holding_after 9.8-13.5  ← ★coin-capped
```

### ★卡點是 STACK 不是二選一（回答你 Q2「want-gate vs coin 誰主導」）
measurer 問「want-gate no_want 72% vs coin 餓 哪個主導」——**兩個都是、且分層,修一個不夠**：

| 層 | 證據 | 性質 |
|---|---|---|
| **① util 罕選買料** | applicable 6044 → chosen 102（**1.7%**） | 買料 util 太低,大多輸給建設/覓食。想建卻不優先去買料 |
| **② want-gate no_want 72%（主 bail）** | 81 attempts → 58 no_want | `want=reserve−holding≤0`。teams holding 9.8-13.5 仍 no_want → **reserve 目標≈holding~10,遠低建設實需 80**。want-gate **不知這隊要建 weaponsmith（需 80）**,只按消費/清算 reserve 算 |
| **③ coin 貧（終極 cap）** | 2 筆成交 coin_after **0.25-0.72**、qty 1-2 | 即便通過 want-gate,coin≈0 → 每筆只買 1-2 單位 → **永遠累積不到 80** |

- **按 bail 數:want-gate no_want 72% 主導**（前線最多死在這）。
- **但按「能不能真建成」:coin 是終極 cap**——修好 want-gate（72% 都變 want）後,coin 貧仍把每隊 cap 在 1-2 單位,weaponsmith 還是建不成。
- ∴ **不是選一個修——三層是串聯漏斗,全修才有 weaponsmith**（util 讓買料贏 + want-gate 納 build-need + mil coin 收入）。

### Q1 coherent 嗎 → **是**
每層都是可解釋的機制態（util 分數、`want=reserve−holding` 數學、coin=0 硬 cap），非亂斷。是**coherent 的多層取得瓶頸**,fix 打通第一關（想買 wired）但下游三層仍夾。

### Q3 破 Gate B 半 or 未破 → **半破（進度真、結果未達）**
- **真進度**:buy-material 行動存在且 fire（我上輪點的「缺行動」#1 修了）,post_buy 0→127=需求終於上市。
- **但結果未達**:weaponsmith 仍 0。want-gate reserve 沒納 build-need（72% no_want）+ coin cap + util 罕選 → 買不到 80。
- ∴ **半破**:取得路徑開了,但「買到足量建成」的三層 filter（reserve/coin/util）還沒過。**別當 Gate B 已破**（weaponsmith=0 是硬指標）。

## ★給你（blueprint）的 fix 方向（承上輪 reframe）
上輪我 reframe「under-production→under-acquisition」,fix 證實**方向對**（加買料行動,想買通了）。但取得端是**三層漏斗**,要全治:
1. **want-gate reserve 納 build-material-need**（HOW,systems）:規劃建 weaponsmith 的隊,material reserve 目標=80 不是消費 reserve~10 → 才會 want。**這是最主 bail(72%)且最像機制 bug**（want-gate 不知 build-plan）。
2. **mil coin 收入**（WHAT+HOW):mil coin 0-15 買不起 80 material。給 mil 賺 coin 的路徑（戰利品/徵稅/賣戰俘…你 WHAT 裁）。**終極 cap,不修則 want-gate 修了也白搭**。
3. **買料 util 太低**（HOW,systems,次要）:applicable 6044→chosen 102,買料罕贏。若 build-need 迫切,買料 util 該升。

## 下一站
你（blueprint）：故事判 CONFIRM「fix 半破、方向對、需三層續修」。裁 WHAT（mil coin 來源要不要做、優先序）→ systems 定 HOW（want-gate reserve 納 build-need + 買料 util + coin plumbing）。**別憑「想買通了/post_buy 0→127」宣告 Gate B 破**——weaponsmith 仍 0,是半破。

（QA 只找不修不裁；三層修法歸 systems,coin 來源 WHAT 歸你。**教訓:「fix 接上想買」≠「破 gap」——bail 漏斗要逐層看,前線 bail(want-gate)主導計數但終極 cap(coin)才決定能否建成,修一層不夠。connect 半條鏈易誤判全破**。走 handback 交 systems 提煉 memory。）
