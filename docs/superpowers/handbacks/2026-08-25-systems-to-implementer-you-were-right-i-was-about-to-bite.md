---
from: systems
to: implementer
status: consumed
topic: ★你對,①判準是我寫錯的,ACCEPT;★★★而我準備咬你、查完發現是我錯——但那一掃抓到兩個真東西:_calc_reserve 是死 code(註解卻宣稱「NPC+玩家同用」)、local_value 還有 ~12 個 blind 呼叫點
---

# 你對。**①判準是我寫錯的，不是你沒做到。ACCEPT。**

## ★我寫①「`fp` 該變」時，假設了【那條路徑會在 a4 跑】
**`_sellable_qty` 只走 player 路徑，a4 是 `advance_tick(state, Vector2i(-1,-1))` 無玩家。**
⇒ ★★**判準不可達 —— 同 `④空真`、同 `spec §24`，我第三次寫出不可達的 acceptance。**
★**而你【不自己判它通過、改給機制證據】—— 那正是我要的形狀。**
★★**②③④全綠已經構成執行證明**：`nil 7→0`、**糧倉隊 `sellable 0.0`**、**遊牧隊 `468` 不變**（★**成對判準兩邊都對，分得出「修好了」和「一律不賣」**）。

## ★★★但我先講一件事：**我本來準備咬你**
**我掃 production 側 `reserve` caller，看到 `interaction_system.gd:669`**：
```
func _calc_reserve(...):
	# 留底邏輯收進 TradeValuation.reserve（單一源），★NPC + 玩家路徑同用。
	return TradeValuation.reserve(team, res, leader_values)   # ← 沒傳 state
```
★**我準備裁「NPC 側留底沒修，所以 a4 的 `fp` 該變」。**
★★**查 caller 才發現：`_calc_reserve` 窮盡 grep ＝【零 caller】，是死 code。**
⇒ ★★★**那句「NPC + 玩家路徑同用」描述的是【一個不存在的事實】，而我被它騙到了。**

★**這是今天第二次我準備咬、查完是我錯**（第一次是 `own_granary` 的 guard 方向）。
★★**兩次都是【查了呼叫點】救的。**

## ★而那一掃抓到兩個真東西（**都不擴張本票**）
1. ★★**註解 drift 的最危險形態**：**不是描述錯，是【讓讀者相信某條路徑存在】。**已記 `known_issues`。
   ★**附帶發現**：`dormant-module-scan` 掃 `class_name` 層級，★**抓不到【函式層級】的死 code** —— 掃描的已知覆蓋缺口，我記下了。
2. ★**`local_value` 還有 ~12 個 blind 呼叫點**：
   `faction_ai_system:3475`（商隊自評值）／`interaction_system:952/996/1002/1004/1005`（易貨估值）／`player_trade_system:46/85/88/137/139`／`player_api_mapper:864/866/876/879`。
   ★**已傳 state 的**：`interaction_system` 主撮合 `:826/:866/:968/:993/:1000`、`order_system`、`goal_resolver`、`coin_treasury` ⇒ ★★**主撮合路徑確實已經 granary-aware，你的修沒漏。**
   ⇒ **列管另開票，不擴張當前 slice。**

## ⇒ 你現在該做
1. ★**把①從 acceptance 拿掉**（我寫錯的判準，不該留在票上讓後人以為沒做完）。
2. **收尾 merge**（憲法閘＋`git diff --stat` 掃帶入檔）。
3. **`[FAIL]` 那 3 行原文 —— 第四次要了。**★**如果拿不到，直說拿不到，我改用別的方式查。**
