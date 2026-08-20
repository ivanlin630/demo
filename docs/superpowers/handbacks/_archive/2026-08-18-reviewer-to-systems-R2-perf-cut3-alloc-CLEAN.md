---
from: reviewer
to: systems
status: consumed
topic: "[R②判決=CLEAN] perf刀3=alloc-churn sweep HOW——①負斷言親自重跑count非信字面:grep FactionAISystem.new()全scripts/simulation/確認41處總數精確吻合,分檔count options.gd15/goal_resolver.gd7/need_oracle.gd4/decision_context.gd4=30精確吻合,這輪spec的wc-先-宣稱真的做了(逐項數字對得上,非約略估);②instance state僅2欄(_last_site_sig:3548/_last_dispatch_fail:3550)親讀確認,往下追每個usage site所在函式:_log_dispatch_fail(:3552-3556使用_last_dispatch_fail)+_last_site_sig用法所在函式(:4068-4069,親讀上下文confirmed是_evaluate_new_outpost_location選址評分函式,含candidates.sort_custom/MIN_BUILD_SCORE等——這正是我這session稍早F1那輪親自審過的同一個函式,site-selection dispatch類無誤)——兩處usage全部落在claimed的dispatch類函式內,零一處出現在hot-path finder函式裡,負斷言坐實;★finder statelessness鏈安全額外抽驗:親讀_find_own_outpost(9×最高頻finder,:4972-4977)完整body確認是純函式——只吃(state,team)、loop state.world.tiles、比對outpost_owner、return tile_pos,零呼叫任何其他instance method、零觸碰self/instance欄位,連間接鏈都不存在,最高頻的那個finder靜態化零風險,親驗比spec自己聲稱的更乾淨;③補丁閘static-ize同刀A純refactor④無新常數⑤感知鐵律finder邏輯不變皆合理;止損準則(quantify落噪聲→perf arc收官banked刀A)呼應這session已建立的量測誠實紀律(禁預設payoff、UNTESTABLE照實報同精神);判決=CLEAN→dispatch"
---

# R②判決：perf 刀3=alloc-churn sweep HOW — CLEAN

## ①負斷言親自重跑，非信字面——數字精確吻合

grep `FactionAISystem.new()` 全 `scripts/simulation/` 確認 **41 處**總數精確吻合；分檔 count `options.gd 15`/`goal_resolver.gd 7`/`need_oracle.gd 4`/`decision_context.gd 4` = **30** 精確吻合。這輪 spec 的「wc 先宣稱」真的做了——逐項數字對得上，非約略估計。

## ②instance state 僅 2 欄——追到每個 usage 落點確認全在 claimed 的 dispatch 類函式內

親讀確認 `_last_site_sig`（`:3548`）/`_last_dispatch_fail`（`:3550`），往下追每個 usage site 所在函式：
- `_log_dispatch_fail`（`:3552-3556`，使用 `_last_dispatch_fail`）
- `_last_site_sig` 用法所在函式（`:4068-4069`，親讀上下文確認是 `_evaluate_new_outpost_location` 選址評分函式，含 `candidates.sort_custom`/`MIN_BUILD_SCORE` 等——這正是我這 session 稍早 F1 那輪親自審過的同一個函式，site-selection dispatch 類無誤）

兩處 usage 全部落在 claimed 的 dispatch 類函式內，**零一處出現在 hot-path finder 函式裡**，負斷言坐實。

## ★finder statelessness 鏈安全——額外抽驗最高頻 finder

親讀 `_find_own_outpost`（9× 最高頻 finder，`:4972-4977`）完整 body 確認是**純函式**——只吃 `(state, team)`、loop `state.world.tiles`、比對 `outpost_owner`、return `tile_pos`，**零呼叫任何其他 instance method、零觸碰 `self`/instance 欄位**，連間接鏈都不存在。最高頻的那個 finder 靜態化零風險，親驗比 spec 自己聲稱的更乾淨（spec 只講「窮盡驗負斷言」，我親自對最高頻那個做了完整 body 讀取確認）。

## ③④⑤其餘
補丁閘 static-ize 同刀A 純 refactor；無新常數；感知鐵律 finder 邏輯不變，皆合理。止損準則（quantify 落噪聲→perf arc 收官 banked 刀A）呼應這 session 已建立的量測誠實紀律（禁預設 payoff、UNTESTABLE 照實報同精神），非阻塞觀察。

## 判決
**CLEAN → dispatch。**
