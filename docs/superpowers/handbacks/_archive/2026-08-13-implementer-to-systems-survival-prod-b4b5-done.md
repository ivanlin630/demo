---
from: implementer
to: systems
status: consumed
topic: "[slice B4+B5 DONE·feat/survival-prod-b4b5 B4=46342d41 B5=203aab2c]生存產出層(堵安家後採糧硬零/material 排擠 food=已 settled 餓死根)·B4 settle→invalidate labor cache:_convert_to_resident body 末(覆蓋所有呼叫端 DRY)+establish_crude_camp 成功後 立即 LaborSystem.ensure_fresh(只提早刷 cadence 非改分配)·B5 food need 隨飢餓升:NeedOracle._self_use food 分支×famine_escalation=1+max(0,(SAFE_DAYS5−food_days)/5)×FAMINE_GAIN2.0、SAFE_DAYS=FORAGE_FLOOR_DAYS 既有錨、thread state 進 _self_use(感知鐵律讀自家 food_days)·★驗:survival_prod_test ALL PASS(B4 同 tick labor_mult(gather:food)=1.0>0 非等3天;B5 bounded 兩象限 食飽 food_days≥5→need=base×1 照舊採礦/瀕餓 food_days=0→base×3/半飽 2.5→介於連續)+need_oracle_test regression 更新 PASS+headless 0-new+constitution 75+determinism 3-run byte-identical(peaceful 48554984)·B4 determinism 收斂(只早刷)、B5 fp intended-change(need→labor→gather 有意改)·★measurer 量測請求(綠才 merge):B4 新居民首3天採糧非硬零+B5 飢餓村勞力回糧/吃飽村照舊 bounded 兩象限 machine-demonstrate+FAMINE_GAIN bounded-verify·請 merge-gate 硬讀→measurer bounded 量測→綠 merge→dispatch A1(camp_marginal)"
branch: feat/survival-prod-b4b5
commits: B4=46342d41 B5=203aab2c
---

# slice B4+B5 DONE — 生存產出層（堵「安家後採糧硬零 / material 排擠 food」= 已 settled 餓死根）

feat/survival-prod-b4b5（B4 `46342d41` + B5 `203aab2c`；off main HEAD d9a05cff；已 push）。

## B4 settle→invalidate labor cache（明確 bug 小修）
**根**：`labor_alloc` 3 天 cadence → 新居民落腳首 3 天採糧硬零（fresh tile labor_alloc 空→labor_mult=0）。
**fix**：settle 成功點立即 `LaborSystem.ensure_fresh(state, tile)`——`_convert_to_resident` body 末（★覆蓋所有呼叫端含 relocate settle=DRY、免逐 caller）+ `establish_crude_camp` 成功後。**只提早刷既有 cadence、非改分配邏輯**（fresh tile labor_alloc 空 → ensure_fresh guard 失敗 → rebalance → gather:food fill>0 → 同 tick 採糧非零）。

## B5 food need 隨飢餓升（NeedOracle 單點、勿平行）
**根**：`_self_use` food 分支純靜態零讀 famine → material/供應鏈 need 排擠 gather:food labor。
**fix**（單點）：
```
food_days = effective_food(state,team) / max(pop×FOOD_PER_PERSON_PER_DAY, ε)   # ★感知鐵律=自家 food_days
famine_escalation = 1 + max(0,(SAFE_DAYS−food_days)/SAFE_DAYS) × FAMINE_NEED_GAIN
return base × famine_escalation
```
- `SAFE_DAYS = FORAGE_FLOOR_DAYS`（5、**既有錨非新 knob**）、`FAMINE_NEED_GAIN = 2.0`（TEST VALUE bounded、measurer 校）。
- thread `state` 進 `_self_use`（need_keep 呼叫端補 state）。飢餓團 gather:food weight（labor need_keep+demand）升 → rebalance 多分採糧。

## 命門守
感知鐵律（B5 讀自家 food_days 自知肚餓、非 god-view；B4 無決策讀）、零新 RNG、bounded（食飽=1 不動 / 瀕餓=1+GAIN）、禁 crank（SAFE_DAYS 導既有錨）、統一非補丁（NeedOracle 單點）。

## 驗（全綠）
| 閘 | 結果 |
|---|---|
| `survival_prod_test` | **ALL PASS**：B4 同 tick `labor_mult(gather:food)=1.0>0`（非等 3 天硬零）；B5 bounded 兩象限（食飽 food_days≥5→need=base×1 照舊採礦 / 瀕餓 food_days=0→base×3 / 半飽 2.5→介於連續 escalation / 飢餓 need>食飽） |
| `need_oracle_test` | **ALL PASS**（regression：state thread 更新、食飽 escalation=1 保原 S1 語意） |
| headless | **0-new** |
| constitution_gate | **PASS sites=75** |
| determinism | **3-run byte-identical**（peaceful 1000t FP `48554984`；純算術無新 randf） |

B4 determinism 收斂（只早刷 cadence、結果同）；B5 **fp intended-change**（need→labor→gather 行為有意改、非 byte-identical）。

## ★measurer 量測請求（交 measurer、綠才 merge）
- **B4**：新居民首 3 天採糧**非硬零**（realistic settle bed）。
- **B5**：**飢餓村勞力回糧 + 吃飽村照舊** bounded 兩象限 machine-demonstrate + `FAMINE_NEED_GAIN` bounded-verify（非 fire-crank、食飽端=1 不動）。
- determinism/regression/constitution 綠（已達）。

## 路
1. **你 merge-gate 硬讀**（B4 只早刷 cadence 無外溢 + B5 感知鐵律/bounded/單點/無新 knob）。
2. → measurer bounded 量測（B4 採糧非零 + B5 兩象限）→ 綠 merge → 你 dispatch A1（camp_marginal）。地基 KEEP。

（perf/F2 disk flag 續。）
