---
from: reviewer
to: systems
status: open
slice: recamp-estimate-disease
topic: R①判決:premise_contradiction:false(三條前提查完,方向成立、細節需訂正)——①後果集確實≈空(establish_crude_camp guard擋)但真正的病在候選產生端不在執行端;②util估值確認根本沒讀(非權重問題),而且我已追到唯一源頭;③bdad0174拿掉的是無關的絕境門檻,跟這個洞完全無關,修法不算回加門檻;★附:唯一修點在_find_unowned_farmable_tile一行,同源修好兩處
---

# 判決：`premise_contradiction: false`，三條前提逐條查完

## ①「站在自己 L0 營地上執行紮營，後果集≈空」——**成立，但要訂正「空在哪裡」**

讀了 `establish_crude_camp`（`faction_ai_system.gd:5538-5541`）：
```
if tile == null or tile.outpost_level > 0 or tile.outpost_owner != -1 or tile.camp_level > 0:
    return false
```
**若腳下 `camp_level>0`（自己已經紮過），這支函式直接 `return false`，零世界寫入**——確認「真的執行紮營」這件事在這個 tile 上是 no-op，前提①字面成立。

★**但這不是重點該擺的位置**——真正的病不在「執行時後果是空的」，是在**候選根本不該被生出來**：`_find_unowned_farmable_tile()`（`faction_ai_system.gd:5505-5531`）的 fallback 迴圈（②段，:5521-5530）第一個掃的方向就是 `Vector2i.ZERO`（腳下），而排除條件只寫：
```
if tile.outpost_level > 0 or tile.outpost_owner != -1: continue
```
**沒有排除 `camp_level > 0`**——而 `establish_crude_camp` 自己的註解明寫 L0 營地「不設 outpost_level、不 set_owner」（:5534-5535），所以自己已經紮的那格會通過這個排除條件，被當成「有效無主可耕地」回傳。**這就是為什麼「執行後果是空」擋不住「決策層每 tick 都選它」——候選在決策前就已經帶著一個非零、通常會贏的 util 分數進場，執行才發現是空的，為時已晚（一整個 tick 的 argmax 被它佔用，紮根選不到）。**

## ②「camp_drive 有沒有讀『這一格已經有自己的營地』」——**確認沒讀，是估值缺輸入，不是權重問題**

讀了 `terms.gd:214-239`（`camp_drive` 完整實作）：只讀 `ctx.camp_target_est`／`ctx.camp_site_quality_mult`／`ctx.camp_flow_delay_days`／population／daily_need，**沒有任何一處檢查目標 tile 是不是自己已經紮營的那格**。而 `ctx.camp_target_est`（`decision_context.gd:397-404`）的目標 tile 來源正是同一個 `_find_unowned_farmable_tile()`——**跟①同一個源頭**。

⇒ **blueprint 假說裡的「後者」（估值根本沒讀）成立，不是「權重問題」**——不用調 `camp_drive` 的公式或係數，因為它讀到的輸入（目標 tile 的估產）本身就是錯的（用了不該合格的 tile），不是它秤得不對。

## ③「`bdad0174` 具體拿掉了什麼」——**拿掉的是絕境門檻，跟這個洞完全無關，不是同一件事**

讀了那顆 commit 的 diff（`options.gd` 唯一改動）：
```diff
-  return ctx.food_days < ctx.desperation_entry_threshold and ctx.has_farmable_tile \
-      and not ctx.has_own_outpost,
+  return ctx.has_farmable_tile and not ctx.has_own_outpost,
```
**唯一拿掉的是 `ctx.food_days < ctx.desperation_entry_threshold`（瀕餓門檻），跟「這格是不是自己的營地」完全不相關——這個檢查此前此後都不存在，`bdad0174` 沒有動過它。**

★**這代表①的洞不是這次 de-patch 揭開的，是本來就在（只是被瀕餓門檻的副作用長期蓋住：能通過瀕餓門檻的隊通常還沒站穩自己的 L0 營地，兩個條件很少同時發生）。de-patch 拿掉瀕餓門檻之後，穩定隊（正是靠著自己 L0 營地才穩定的那些）第一次大量進場，這個一直存在的候選生成漏洞才第一次大量顯性化。**

⇒ **這對 blueprint「修估值、禁回加門檻」的硬約束是好消息，不是壞消息**：真正的修法（在 `_find_unowned_farmable_tile` 的排除條件加一句 `or tile.camp_level > 0`）**不是回加瀕餓門檻，是補一個此前從未存在過的、無關飢餓的 tile 合格性檢查**——這不會撤銷 `bdad0174` 的決定（絕境門檻仍然拿掉），也不是新的補丁閘（它修的是「這格算不算候選」的事實判斷，不是「值不值得選」的門檻）。

## ★附：唯一修點已經找到，同源修好兩處
`_find_unowned_farmable_tile()` 的 fallback 排除條件是①②兩條前提共用的唯一上游——`has_farmable_tile`／`camp_target_est`都源自它。在那一行加 `tile.camp_level > 0` 就同時讓「紮營」applicable 對自己已紮的格判 false、且 `camp_drive` 因 `camp_target_est` 變 null 直接返回 0（`terms.gd:216`已有 `camp_target_est == null → return 0.0`的分支）——**一個修點，兩處自動同步**，符合同源推導，不用另外改 `camp_drive` 本身。

**premise_contradiction: false——三條前提方向都對，可以寫 spec；建議 spec 把①的落點從「camp_drive 沒讀」改寫成「候選生成端（`_find_unowned_farmable_tile`）沒排除自己已紮的格」，並把修法釘死在那一行，implementer 不用重新找。**
