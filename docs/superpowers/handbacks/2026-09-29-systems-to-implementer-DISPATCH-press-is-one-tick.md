---
from: systems
to: implementer
status: consumed
consumed-by: docs/superpowers/handbacks/2026-09-30-implementer-to-systems-press-is-one-tick-done-7-controls-red.md（三件全做、7 支負對照全紅、電池 86／86）
consumed-note: ★P5（world-fp 會變）的預測【不成立】而我沒有動基準值 —— 理由寫在回信 §③。
slice: #8 按一下＝做一顆 tick ＋ X／Space 吸附（★先於 #7）
topic: ★派工。spec = docs/superpowers/specs/2026-09-29-press-is-one-tick-and-snap-HOW.md｜R² CLEAN（6647c5392，他把單一咽喉窮盡掃過、沒有第 37 條路）｜★★★兩個【寫死不讓你選】：hook 掛在 `SimBridge.command_player()`；tick 一律呼 `_bridge.get_current_tick()`
---

# 一、讀

```
spec：docs/superpowers/specs/2026-09-29-press-is-one-tick-and-snap-HOW.md
上游裁定：2026-09-29-blueprint-to-systems-RULING-press-is-do-one-tick-and-snap-to-hour-day.md（consumed）
  ★先讀它的「一、用戶討論」——用戶逐字「玩家的介面就是按啥做啥」，那是這張票的全部理由
R² 判決：2026-09-29-reviewer-to-systems-press-is-one-tick-verdict-clean.md（consumed）
```

# ★★二、兩個【我寫死、不讓你選】的地方

```
①★hook 掛在 `SimBridge.command_player()` 裡，**不在 UI 的 36 個呼叫點上**
   if not is_advancing(): request_advance(1)
   ⇒ 一個位置涵蓋 36 個；★★而以後新增的【第 37 個呼叫點自動有這個行為】
     （貼 36 次的版本會漏掉第 37 個，而且不會有人發現）
   ★R² 窮盡掃過 `sim_bridge.gd` 對 `_state.*` 的直接寫入：整檔只有兩處
     （`command_player()` 內部的 `pending_commands.append` ＝ 被掛鉤的本體、
      `set_player_input()` 的 `player_state[k]=v` ＝ 已排除）
   ★★他還特別追了一條他記得曾被列為第三入口的 `refresh_interaction_targets()`
     —— 它現在的實作就是 `command_player("refresh_targets", {})` ⇒ **已經 route 進去，不是繞過**
   ⇒ ★★★**沒有第 37 條路。** 涵蓋主張成立。
②★tick 一律呼 **`_bridge.get_current_tick()`**（`sim_bridge.gd:147`，live 讀 `_state.world.current_tick`）
   ★★**不得用 `_cached_snapshot` 裡那一份 tick**（它只在 `_refresh()` 才更新）
   ⇒ R² 指出那份**正是最自然會誤用的來源** ⇒ 所以我把方法名寫死，不讓你選。
```

# 三、做什麼

```
①每道令入列後自動 `request_advance(1)`（例外：`is_advancing()` 為真時不加推進）
②X／Space 改吸附：n = C - (tick % C)；★餘 0 ⇒ n = C（推整段，不是 0）
   ★★C 只准引用 `WorldState.TICKS_PER_HOUR`／`TICKS_PER_DAY`，不准寫 60／1440
③頁腳「待執行 N 道」保留、重播語意不變
```

# 四、驗收（spec §4）

```
P1 按一道【會成功】的令 ⇒ current_tick 恰 +1、結果句出現、頁腳 0
   ｜★陽性對照（blueprint 指定）：拿掉 request_advance(1) ⇒ 必紅
   ｜★★母體地板：先斷言那道令真的成功（ok=true）—— 失敗的令也會 +1，兩者長得一樣
P2 吸附兩向（含★站在邊界 ⇒ +C 不是原地）；斷言讀常數，不得寫 60／1440
P3 ★濫按床：同分鐘對同 NPC 連發 20 次 demand_tribute／propose_alliance／recruit_anon
   ⇒ 對方回應合理、world-fp 對照不崩、守恆不破
   ★★母體要印：20 次各自的 ok／msg ＋ 冷卻欄位的值
     （否則「沒有崩」在一個【20 次全被擋在最前面】的世界裡沒有資訊量）
   ★★★而「20 次之後對方該怎樣算合理」是 WHAT ⇒ 床印母體，判斷回 blueprint，不要自己裁
P4 例外成立：`is_advancing()` 為真時按令不額外推進｜負對照：拿掉該判斷 ⇒ 必紅
P5 ★world-fp **會變是預期內的**（改的是推進時機）⇒ 基準值與改動同一顆 commit 落地
   ★★★**不要照抄上一張票的 P5**（那張是「文字不進 fp ⇒ 逐字不變」，方向相反而兩者都對）
P6 ui-flow 綠；merge 前全電池 BATTERY_RC=0
```

# ★五、與 #7 的關係

```
#8 先。#7 的①③（面板人話／未知 id 不吞／生命週期三點）不受影響，你已在做的留著。
★#7 的②（鎖面板＋去重）在 #8 之後簡化成「按了就結算」；
★★#7 的 P4（按 T 變拒絕）要在 #8 落地【之後】再量 ——
  否則你量的是一個即將被換掉的時序（accept 會在下一顆 tick 就套用）。
⇒ 那兩格我會在 #8 merge 後重寫 spec 再派。
```
