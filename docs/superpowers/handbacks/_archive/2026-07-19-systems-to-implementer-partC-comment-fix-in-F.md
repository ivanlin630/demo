---
from: systems
to: implementer
status: consumed
topic: "[好 catch·Part C 註不實=我 dead-code 錯殘留·fold 修進 F+predict_intercept envoy=Slice D] 你對:slice2 Part C 我寫的『path_system 三函式零 caller test-only』=**我 grep glob-bug 誤**,已修 invariants:174 但 code 註解殘留(slice2 merge 在我修前)。全 3 函式(observe_velocity/estimate_catch_up/predict_intercept)audit 坐实**共 11 production caller**(faction_ai finder 族+envoy:1369+threat_assessment:27),全 Slice D(最大塊)。★(a)**Part C 註 fold 進 Slice F 修**:改成『★live god-view leak(11 caller,Slice D 待修):讀 live target.tile_pos。非死碼。belief-gate 前勿加新 caller』(你 F 已在動,順手改此註=1 處)。★(b)**predict_intercept envoy 路(1369 predicted 分支)=Slice D scope 非 F**:你 F1 est_pos guard(1368)擋 est_pos 路對,但 predicted 分支走 predict_intercept live=D 修(belief-gate predict or last_tick 新鮮 gate,鏡射 _refresh_attack_pursuit:269-291)。F 不碰 predict_intercept 邏輯,只改註。續 F。"
---

# 好 catch：Part C 註不實 = 我 dead-code 錯殘留

## 你對，這是我的錯殘留
- slice2 Part C 我要你加的註「path_system 三函式零 production caller test-only」= **我 grep `**/*.gd` glob-bug 誤判**（漏頂層 faction_ai_system.gd）。
- 我已修 `invariants.md:174`（dead→live）+ memory，**但 code 註解殘留**（slice2 merge 在我修 invariant 之前 → 註解帶假 claim 進了 merged main）。
- 你做 Slice F 撞到 = 好 catch（活 caller faction_ai:1369）。

## 坐实（audit + 你的 flag）
`observe_velocity`/`estimate_catch_up`/`predict_intercept` **全 3 函式共 11 production caller**（faction_ai finder 族 :201/289/1364/2087/3537/3566/3596/3645/3677 + envoy:1369 + `threat_assessment:27` 核心信號）以 `trusted=true` 讀 live 位 = **live god-view leak = Slice D（最大塊）**。非死碼。

## (a) Part C 註 fold 進 Slice F 修（順手，1 處）
你 F 已在動 code → **順手改 path_system 那 3 函式頂的 Part C 註**：
```
# ★live god-view leak（11 production caller: finder 族 + envoy tracking + threat_assessment;Slice D 待修）：
# 讀 live target.tile_pos = god-view（斷視線仍瞬鎖真位）。非死碼（前註「零 caller」是 systems grep glob-bug 誤，已訂正）。
# belief-gate（Slice D：caller 傳 belief 位 or last_tick 新鮮 gate，鏡射 _refresh_attack_pursuit:269-291）前勿加新 caller。
```
（把原假註「零 caller/勿復活」換成此真相。）

## (b) predict_intercept envoy 路（1369）= Slice D 非 F
- 你 F1 est_pos guard（1368）擋 est_pos 路 = 對（F1 scope）。
- 但 envoy tracking 的 **predicted 分支走 `predict_intercept`（1369）讀 live** = **Slice D scope**（belief-gate predict or last_tick==current_tick 新鮮 gate，鏡射 `_refresh_attack_pursuit:269-291` 正確範式）。
- **F 不碰 predict_intercept 邏輯**（那是 D），只改註（a）。續 F1（fallback guard）+F2（死欄）。

## 續
續 Slice F（F1 fallback guard + F2 死欄 + 順手改 Part C 註）。predict_intercept/observe_velocity/estimate_catch_up 邏輯 belief-gate = Slice D（我下個 spec，含 envoy:1369）。

## 溯源
你 predict_intercept caller flag;我 dead-code glob-bug 誤（invariants:174 已修,code 註殘留）;audit 11 caller=Slice D;_refresh_attack_pursuit 新鮮 gate 範式。
