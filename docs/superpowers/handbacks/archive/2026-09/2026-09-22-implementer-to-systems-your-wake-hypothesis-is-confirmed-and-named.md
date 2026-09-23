---
from: implementer
to: systems
status: consumed
slice: `solo_think` 那 34.7% —— **你的假設成立，而且有名字了**
topic: ★★★**`woke_only` 441 次【全部】在 pass tick、非 pass 【0 次】；`due_only` 反過來（pass 6／非 pass 1132）** ⇒ **相位錯開是好的，是事件喚醒把它們拉到同一個 tick**｜★★**emit 端 12 種事件 100% 落在 pass tick**，而 `intel_arrived` **5386 次佔 94%**｜★**這是 2 天 smoke，但它是【次數】不是【時間】⇒ 不受 CPU 競爭影響 ⇒ 可以引用**（12 天 × 兩顆種子正在跑）｜★★★**而 `pending_source` 回的 `cur` 不是語意來源**（`world_events.gd:100` 恆回 `cur`）—— 我把它標死在卷面上，沒當答案用
---

# 一、★★★卷面（2 天 smoke，seed 1337；★次數不受 CPU 競爭影響）

```
類別             pass tick    非 pass tick    pass 佔比
due_only                 6           1132       0.53%   ← ★相位【確實散開了】
woke_only              441              0     100.00%   ← ★★★全部在 pass tick
both                     1              0     100.00%
skip                   719          67704       1.05%
合計                  1167          68836            ← ★母體（含 skip ⇒ 比率有分母）
★真正往下跑思考：pass 448 ／ 非 pass 1132 ⇒ pass 佔 28.35%
  ★★對照：pass tick 只佔全部 tick 的 1.67%（1／60）⇒ **17 倍過度代表**
```

# 二、★★誰把它們叫起來的（★emit 端，★★不是 `pending_source`）

```
事件 kind                 pass     非 pass   pass 佔比
intel_arrived             5386          0    100.00%   ← ★★★佔全部 emit 的 94%
order_buy                  181          0    100.00%
order_sell                  36          0    100.00%
rung_changed                21          0    100.00%
combat_engaged / start   13 / 13        0    100.00%
tribute / extortion / betrayed / famine_crossed / aid_given / construction_abandoned
                         12/7/6/5/3/2    0    100.00%
⇒ ★**12 種、一種不漏，全部 100% 在 pass tick** —— 因為**會 emit 的系統全都跑在那個 pass 裡**
```

# 三、★★★機制（★四步，每一步都有 file:line）

```
① 全世界的系統跑在 `sim_runner.gd` 的 `% NEAR_CADENCE == 0` 區塊裡（＝ pass tick）
② 它們 emit 事件 ⇒ `world_events.gd:71` `state.pending_rethink[id] = true`
③ `_step6b1_solo_think(state)` 在那個區塊【外面】、**緊接的下一行**（`sim_runner.gd:411`）
   —— ★而註解自己寫著它【故意】不在閘裡（為了讓相位 offset 不被取樣格吃掉）
④ `faction_ai_system.gd:8080-8082`：`_woke = WorldEvents.is_pending(...)`，
   `if not _due and not _woke: continue` ⇒ ★**被喚醒的隊不等自己的相位，當場就想**
⇒ ★★★**②③④ 發生在【同一個 tick】** ⇒ 相位錯開對「被喚醒」那條路**完全無效**
⇒ ★而 `if _due:` 才重排下次（8091）⇒ **被喚醒跑掉的那次不會推進相位**
```

# 四、★這修正了什麼

```
★你的假設原話是「pass 產生事件 ⇒ **同一 tick 全體被喚醒**」
⇒ ★★**方向完全正確，而【全體】要收窄**：2 天裡 pass tick 上平均被喚醒 **9.2 隊／pass**
   （441 ÷ 48 個 pass tick），不是全部 ~100 隊。
⇒ ★★★所以它不是「全體同時醒」，是**一小撮隊、每個 pass tick 都醒**。
★而時間上 `solo_think` 佔 34.7% ⇒ 那 9.2 隊每次思考**不便宜**（12 天卷面：448,355 us／pass）
   ⇒ ★但「每次多貴」這一格我**還沒量**（本床只數次數）。
```

# 五、落地與在飛

```
tap＋床：`feat/pass-phase-bed` @ `<見下一封>`（★tap 動到 production：
   `faction_ai_system.gd`（四格 + 母體完整）、`world_events.gd`（只補 pass/nonpass 這一維，
   ★沿用既有的 `t0.emit.<kind>`，沒有另造第二套計數）
★★★12 天 × 兩顆種子**正在跑**（過 `godot-busy` 守衛）⇒ **這是【在飛】不是【已完成】**
★而 2 天 smoke 的【次數】我敢引用，理由寫在上面：次數不受 CPU 競爭影響、時間才會
```
