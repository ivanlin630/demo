---
from: implementer
to: systems
status: consumed
slice: S4a-t0-inventory
tier: infra
topic: ★★★★★票的前提要訂正：單一入口【已經存在】(world_events.gd 的 WorldEvents，附封閉母體 all_kinds()=30);★★而「7 檔 35 處」是【對 *_next_tick 賦值】的母體不是【喚醒】的——19 走 CadenceStagger／11 排未來／真正叫醒的只有 1 處(faction_ai:458);★★★對帳：30 種宣告全部有來源、0 死、WHAT 六類全中;★而我報過兩個假陽性，都寫進產出檔頭
---

# ★★★★★①前提訂正（★先講，因為 S4b 會建在它上面）
> 票：**「喚醒散在 7 檔 35 處，【沒有單一入口】。」**

★**我重跑枚舉後的訂正**：
```
36 \u8655 / 7 \u6a94 = \u3010\u5c0d *_next_tick \u8ce6\u503c\u3011\u7684\u6bcd\u9ad4\uff08\u4f60\u8aaa 35\uff0c\u6211\u91cf\u5230 36\uff0c\u5dee 1\uff09
  19  = CadenceStagger.next_tick(...)      \u2190 \u6392\u672a\u4f86
  11  = current_tick + CADENCE             \u2190 \u6392\u672a\u4f86
   1  = 0                                  \u2190 \u672a\u6392\u7a0b\u54e8\u5175
\u2605  1  = current_tick\uff08\u5f8c\u9762\u4ec0\u9ebc\u90fd\u6c92\u52a0\uff09  \u2190 \u2605\u2605\u771f\u6b63\u7684\u3010\u53eb\u9192\u3011\uff1afaction_ai_system.gd:458
```
★★**而【單一入口已經存在】**：`scripts/simulation/world_events.gd`
```
WorldEvents.all_kinds() = MESSAGE_KINDS 18 + FUNC_KINDS 9 + STATE_KINDS 3 = \u26053018
\u2605\u2605\u800c\u5b83\u5df2\u7d93\u6709 T0 \u5c0d\u5e33\u6e2c\u8a66\uff1ascripts/debug/t0_event_bus_test.gd
```
⇒ ★★★**所以 S4b 不是「建一個單一真值」，是【把散落的 1 處收進既有的那一個】** ——
**而那是完全不同的工作量與風險。★我不替你改 S4b 的 scope，只把事實放上桌。**

## ★而 `FUNC_KINDS` 是 9 不是 10
**我第一次目測算成 10** —— **逐塊重數才對上（18/9/3 = 30）。★數字用數的不用看的。**

# ★★②對帳（★封閉母體，可重跑）
```
\u5ba3\u544a 30 \u7a2e \u21d2 \u2605\u5168\u90e8\u6709\u4f86\u6e90\uff5c0 \u6b7b\uff5c0 \u672a\u5ba3\u544a
\u4f86\u6e90\u5206\u4f48\uff1a\u76f4\u547c emit 12 \u7a2e\uff5c\u7d93\u8a0a\u606f\u5c64 16 \u7a2e\uff5c\u5b57\u4e32\u4e32\u63a5 2 \u7a2e\uff08order_buy/sell\uff09
```
★**WHAT 點名六類【全部有來源】，逐條 file:line**（你要的下限，缺一即 FAIL）：
```
\u88ab\u8972     combat_engaged  @npc_combat_system.gd:107
\u8de8\u9913\u7dda   famine_crossed  @resource_system.gd:215
\u52de\u529b\u5371\u6a5f  labor_crisis    @labor_system.gd:27
\u95dc\u9375\u60c5\u5831  intel_arrived   @belief_system.gd:208
\u9818\u8896\u6b7b    leader_death    @event_system.gd:32
\u76ee\u775a\u6ec5\u5718  team_extinct    @faction_ai_system.gd:3784
```

# ★★★③而我報過兩個假陽性 —— **都寫進產出檔頭，不是只寫在信裡**
```
\u2460\u7b2c\u4e00\u7248 regex \u8981\u6c42 emit \u7684 kind \u662f\u3010\u5b57\u4e32\u5b57\u9762\u91cf\u3011
   \u21d2 18 \u500b MESSAGE_KINDS \u5168\u88ab\u5224\u300c\u6c92\u6709 emit\u300d
   \u2605\u771f\u76f8\uff1a\u5b83\u5011\u8d70 message_system.gd:58 \u7684 WorldEvents.emit(state, type, ...)\uff08type \u662f\u8b8a\u6578\uff09
\u2461\u4fee\u597d\u5f8c order_buy/order_sell \u4ecd\u5224\u300c\u7121\u4f86\u6e90\u300d
   \u2605\u771f\u76f8\uff1aorder_system.gd:54 \u7528\u3010\u5b57\u4e32\u4e32\u63a5\u3011"order_" + kind
```
★★**兩次都是【枚舉的形狀配不上機制】** —— **而抓到它們的是「未宣告」那一欄**：
**`order_` 出現在【emit 了但沒宣告】那一桶 ⇒ ★★★對帳式自己把不一致頂出來，不是我看出來的。**
★**這也回答了你今天問過的「為什麼要兩邊都列」** —— **單邊清單看不出這種錯。**

# ★④四桶的現況與我【還沒做完】的部分
```
(a) \u5df2\u559a\u9192   = 30 \u7a2e\u5ba3\u544a\u4e8b\u4ef6\uff08\u5168\u6709\u4f86\u6e90\uff09\uff0b faction_ai:458 \u90a3 1 \u8655 ad-hoc
(b) \u8a72\u559a\u9192\u4f46\u6c92\u6709 \u2605\u672a\u5b8c\uff1a\u547d\u540d\u679a\u8209\u7684 36 \u8655\uff08_detect_/_crisis/_stall/_latch\uff09\u9084\u6c92\u9010\u9846\u5c0d\u7167 30 \u7a2e
(c) \u4e0d\u662f T0   \u2605\u672a\u505a\uff08\u8981\u9010\u9846\u56de\u7b54\u300c\u82e5\u4e0d\u559a\u9192\uff0c\u6700\u58de\u60c5\u6cc1\u662f\u4ec0\u9ebc\u300d\uff09
(d) untraceable \u2605\u672a\u505a
```
★★**我沒有把 (b)(c)(d) 硬湊出來** —— **它們需要逐顆判 36 處，而那是下一輪的活。**
★**要我現在做完，說一聲；★★或你先看這份前提訂正要不要改 S4b 的形狀，再決定我做不做 (b)(c)(d)。**

## 落地 exact path
```
A:\GDS\demo\.worktrees\old-growth\docs\measurements\2026-08-27-s4a-t0-wake-inventory.txt
commit c82d1cfc
```
