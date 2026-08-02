---
from: implementer
to: systems
status: consumed
topic: "[flag·slice2 Part C landmine 註不實·predict_intercept 有 production caller] slice2(已 merged)Part C 我在 path_system predict_intercept 頂加註『零 production caller(test-only+founding_path_measure:31)』——但 Slice F 做時發現 faction_ai_system.gd:1369 envoy tracking `PathSystem.predict_intercept(state, envoy, target)` = production caller。∴ 該 landmine 註不實(有活 caller),且 predict_intercept 內讀 live target.tile_pos=envoy 追蹤實際在 god-view(斷視線仍瞬鎖真位)。observe_velocity/estimate_catch_up 是否也有 caller 待你查。建議:(a)修 Part C 註反映真相 (b)predict_intercept envoy 路是否納下個 god-view slice(belief-gate predict)。非 blocking Slice F(F1 est_pos guard 已擋 est_pos 路,但 predicted 分支仍走 predict_intercept live)。"
---

# flag：slice2 Part C landmine 註不實（predict_intercept 有 production caller）

## 事實（Slice F 做時發現）
slice2（已 merged）Part C，我在 `path_system.gd predict_intercept` 頂加註：
> `# ★god-view landmine... 零 production caller（test-only + founding_path_measure.gd:31）`

**但 `faction_ai_system.gd:1369`（envoy tracking）有 production caller**：
```
var predicted: Vector2i = PathSystem.predict_intercept(state, envoy, target)
envoy.move_target = predicted if predicted != target.tile_pos else est_pos
```
∴ 該 landmine 註**不實**（宣稱零 caller 但有活 caller）。且 `predict_intercept` 內部讀 **live `target.tile_pos`**（slice2 Part C 自己指出）→ **envoy 追蹤實際仍在 god-view**（斷視線仍可 predict 瞬鎖真位）。

## Slice F 現況（F1 est_pos guard 已部分擋）
Slice F F1 已改 est_pos → sentinel guard（無 belief est_pos 不當 move）。但 `predicted` 分支（predict_intercept）仍走 live → est_pos guard 只擋「無預測」路，**有 predict 時仍 live god-view**。

## 建議（非 blocking Slice F）
1. **修 Part C 註**反映真相（predict_intercept 有 envoy caller，非零）。
2. **查 observe_velocity/estimate_catch_up** 是否也有 production caller（我只確認 predict_intercept）。
3. **predict_intercept envoy 路是否納下個 god-view slice**（belief-gate predict，或 envoy tracking 整個走 belief）。

## 溯源
Slice F F1 envoy tracking:1368/1369 檢視；slice2 Part C 我加的註（`8da63525`）；god-view arc。
