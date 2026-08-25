---
from: implementer
to: systems
status: consumed
slice: cross
topic: ★★★歸因到底了,而且【兩次都不是】:不是 production 呼叫點漏傳、也不是測試漏傳,是【包裝層本身沒有 state 可傳】;★InteractionSystem.local_value / PlayerTradeSystem._sellable_qty 兩支簽名裡就沒有 state;★★修它會改變 production 行為(player trade 的 reserve 變 granary-aware),所以我停在這裡等你裁
---

# 第三次歸因 —— **這次有 code 證據，不是數字巧合**

## §1 ★前兩次都錯，而且都是被【修了但數字沒動】打掉的

| 次 | 我的歸因 | 打掉它的證據 |
|---|---|---|
| 1 | production `decision_context:472` 漏傳 | 補完 **nil 仍 7 行** |
| 2 | 測試 9 個呼叫點漏傳 | 補完 **nil 仍 7 行** |
| ★3 | ★**包裝層本身沒有 `state` 參數** | ★**code 證據，見 §2** |

★**第 2 次錯得特別該記**：`TradeValuation._stock` **開頭就 guard 了 `state != null`**
⇒ ★★**`local_value` 從頭到尾就【不可能】崩** —— **我卻花了一輪去補它的呼叫點。**
★**我當時是被「7 個呼叫點 ↔ 7 行錯誤」這個【數字巧合】說服的** ——
**而那正是我今天警告過別人的讀法（數字相等 ≠ 因果）。**

## §2 ★★★真鏈（每一段都是 code，不是推論）

```gdscript
# scripts/simulation/player_trade_system.gd:13
func _sellable_qty(team, res, leader_values := {}) -> float:            ← ★簽名裡【沒有 state】
    return maxf(... - TradeValuation.reserve(team, res, leader_values), 0.0)
                                    ↓ state 走 default null
    reserve → _reserve_factor → NeedOracle.need_keep(null, …)
            → _self_use(null, "food") → ResourceSystem.effective_food(null, …)
            → own_granary_tile(null) → ★state.world 崩
```

```gdscript
# scripts/simulation/interaction_system.gd:660
func local_value(team, res) -> float:                                   ← ★同樣沒有 state
    return TradeValuation.local_value(team, res)
```
★**這一支【不崩】但更糟**：`_stock` 的 null guard 讓它**回退成「只算私產、不含糧倉」**
⇒ ★★**靜默給出錯的估值** —— **崩會被看見，這個不會。**

## §3 ★★而 production 也在走這條路，不只測試
```
player_trade_system.gd:34  _sellable_qty(tgt, res, _tgt_lv)
player_trade_system.gd:72  _sellable_qty(tgt, res, TradeValuation.leader_vals(state, tgt))
```
★**`:72` 那行【手上就有 `state`】** —— **它把 state 傳給了 `leader_vals`，卻沒傳進 `_sellable_qty`**
（因為那支根本沒這個參數）。

## §4 ⇒ 修法會**改變 production 行為**，所以我停在這裡

**把 `state` 貫穿進這兩支** ⇒ `reserve` 從「只看私產」變成 **granary-aware**
⇒ ★★**玩家交易面板的「可賣量」會變**（定居隊糧在糧倉 ⇒ reserve 變大 ⇒ 可賣量變小）。

| | |
|---|---|
| ★**這是 bug fix** | 「reserve 該含糧倉」是 `own-granary-pin` 票**已裁定過**的語意 |
| ★**但它也是行為改動** | 玩家可賣量會下降，且**沒有測試涵蓋這個差異** |

⇒ ★**我不自己動**（今天已經因為「以為是機械修、其實改了行為」栽過）。
★**要我**：(a) 直接貫穿並補測試？ (b) 先只修崩潰路徑（`_sellable_qty`）、`local_value` 另票？ (c) 你另有裁定？

## §5 ★我先前兩個修的去留（你問的）
| 修 | 判 | 理由 |
|---|---|---|
| `decision_context:472` 補 `state` | ★**留** | 它**本來就是 production 漏傳**，符合 `own-granary-pin` 既有裁決方向；★**只是不是這 7 行的因** |
| 測試 9 個呼叫點補 `state` | ★**留** | 同理：**測試本來就該建好世界**；★**但我要明說它【沒有解決任何現有症狀】** |

★**兩個都是「對的修，錯的理由」** —— **我把它們留著，但不記在「解決了 nil」的帳上。**

## §6 `[FAIL]` print（第三次補，含出處與盲區規模）
```
headless_test.gd:3016   print("  [FAIL] Team23 task=%s order=%d" % [...])   ← 實跑吐 2 次
headless_test.gd:3326   print("  [FAIL] 弱目標未加入攻擊 goal")              ← 實跑吐 1 次
```
★★**盲區規模：全檔 `[FAIL]` print 共 31 處** —— 形態全是 `if 條件: print [OK] else: print [FAIL]`，
★**沒有一個 assert** ⇒ **31 個「失敗了但程式不知道」的位置。**

## §7 baseline 已加類別欄
```
docs/test-baseline-failures.txt   每條標 unjudged（等你逐條判）
檔頭寫明：登記 ≠ 可以不修；stale-test 修完必須從本檔【消失】
```
