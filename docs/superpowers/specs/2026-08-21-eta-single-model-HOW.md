# HOW spec：ETA 與真實移動成本合成單一模型

slice: eta-single-model
date: 2026-08-21 ／ owner: systems ／ 起因：`last-step-freeze` 診斷（implementer）

## §1 前提（實測坐實）

**「porter 相鄰卻不走最後一步」的真相 ＝ 它一直在走，只是【一格要走 144 tick】**
（判斷週期遠短於 144 ⇒ 每個取樣點看起來都「沒動」）。

★ **真缺陷 ＝ 同一件事有兩套獨立模型，而且系統性低估 3×**：

| | 公式 | 吃哪些因素 |
|---|---|---|
| **T3 預算來源** `PathSystem.eta_ticks`（`path_system:158-160`） | `path_cost × BASE_MOVE_TICKS / (1−fatigue)` | ★**只有疲勞** |
| **真實走一格** `MovementSystem._move_cost`（`movement_system:170-193`） | `BASE / (隊速×地形×疲勞×超載×車輛)`，**clamp `[BASE/3, BASE×3]`** | 隊速組成、地形、**超載**、車輛 |

**★porter 永遠超載**：`BASE_CARRY = 10/人`，`pop=1` 卻背 30–200
⇒ **每一趟 convoy 都吃 MAX clamp（144 ＝ 3×BASE）**。

### ★★致命的算術（餘裕恰好為零，是巧合）
```
MAX_MOVE_TICKS = 3 × BASE      （clamp 上限）
eta_ticks      = BASE × 格數    （只吃疲勞，看不到超載）
T3 預算        = MULT(3.0) × eta = 3 × BASE × 格數 = 【真實路程時間本身】
```
⇒ **餘裕恰好為 0**：任何一點延遲（LOD 視窗／決策 cadence／地形／rehome 後多走的距離）
**都會在最後一格上超支** ∴ **三筆 stranded「卡在相鄰格」不是巧合——那正是預算用罄的位置。**

### ★爆炸半徑（我窮盡查過，**是好消息**）
`eta_ticks` **全樹只有一個 production 消費端**：
`_estimate_eta_to`（`faction_ai:5226`）→ **只被 `faction_ai:2867` 的 `_stamp_return_eta` 呼叫**
⇒ **這個低估是 convoy-scoped，不是全世界的決策都在吃它。**

## §2 設計：**單一模型**
**`eta_ticks` 改用與 `_move_cost` 相同的速度模型與 clamp。**

⛔ **明令禁止的替代方案**：**把 `RETURN_ABANDON_ETA_MULT` 調大來補**——
那是**用常數 paper over 一個模型分歧**，症狀會消失、**兩套模型仍然不同步**，
下一個吃 ETA 的消費端照樣被坑。（同 `feedback_genuine_value_not_crank`。）

★ **這是今天第 N 次同族**：**兩個理論上該同步、物理上分開的東西**
（specimen 選樣清單凍結／fate 以隊伍消失推論／trip 以 id 為鍵／七份 `_next_team_id`／四種 person 出生口）。
**修法一律是「收斂成一個」，不是「讓兩邊各自校準」。**

## §3 gate
1. ★**單一源**：`grep` 證明**沒有第二個算「走一格要多久」的地方**（**負斷言、窮盡、禁 `head`**）。
2. **算術對照床**：同一 team／同一 path，`eta_ticks` 與「逐格 `_move_cost` 累加」**誤差 ≤5%**
   （**超載、地形、車輛三種情境各驗一次**）。
3. ★**T3 餘裕恢復**：修後 `budget / 真實路程時間` **≈ MULT（3.0）**，**不再是 1.0**。
4. **stranded 大幅下降**：warring 同床同 seed，`convoy.stranded.timeout` **應顯著減少**
   ★ **但不預設歸零** —— 母隊滅團／真不可達仍該 stranded。**若歸零反而要查 T3 是不是變成永不觸發。**
5. **det×3 穩定**；`fp` **會變 ＝ intended-change**（convoy 行為改變）；憲法 ≤74；headless 0-new。
6. ★**taps**：`convoy.eta_vs_actual`（預估／實走比值）—— **讓「兩套模型是否同步」變成可持續觀測的量**，
   不是修完就忘。

## §4 不做
- **不改 `_move_cost` 本身**（它是對的那一邊）。
- **不改 `MAX_MOVE_TICKS` / `BASE_CARRY`**（超載懲罰是設計，不是 bug）。
- **不併 porter164「貨沒交割」那條** —— implementer 本輪**沒有重現**（`deliver=2/settled=2/零 bail`），
  **另一條因果，不塞進來**。
