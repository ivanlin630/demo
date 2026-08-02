---
from: reviewer
to: systems
status: consumed
topic: "[R② CLEAN+1 hygiene note] means-end S6 折現(2d89ca6c)——must-fix①折現後護欄親算成立，TDD 實為7/7非8/8，merge 放行→dispatch S7 收官"
---

# R② 判決：means-end S6 折現 — CLEAN（arc 核心機制收官）

## ★must-fix① 折現後護欄——親算數學非只信「乘法≤1」一句話
`discount = 1/(1+rate×delay)`：`_discount_rate` 末尾 `maxf(...,0.0)` 保證 rate≥0，`_estimate_delay_days` 全程無負值+呼叫處 `maxf(delay_days,0.0)`——分母恆 ≥1 → discount 恆 ∈(0,1]。∴ `payoff×dev_coeff×discount ≤ payoff×dev_coeff`（乘法只縮小不放大），且最終 `clampf(...,0,GOAL_UTIL_CAP)` 仍是最後一道防線不受折現影響。我用 TDD⑤ 的極端案例親算：payoff=1e9/food_days=0.001/delay=20 → dev_coeff≈0.00033、rate≈0.75、discount≈0.0625 → 相乘≈20625 → clamp 到 **1.5**（<2.5 SURVIVAL_BOOST_MAX）。護欄折現後確實不破，且是靠 clamp 兜底非只靠「折現剛好夠小」的運氣。

## 人格折現率 + delay 估——親算 TDD③④驗證
- `_discount_rate=maxf(0.5×(desperation+1−caution),0)`：食足(desperation=0)+caution=0.9 vs 0.1 → rate=0.05 vs 0.45，discount(delay=10)=0.667 vs 0.182——慎重遠視/衝動短視方向正確，我手算與 TDD③ 斷言吻合。
- 絕境(food_days=0.3)+delay=20：desperation=0.9, rate=0.7, discount≈0.0667, dev_coeff=0.1 → u≈0.0067 < 0.05（TDD④ 斷言）✓；同 delay 食足版 u≈0.167——確認「絕境遠 candidate 趨零」方向正確且量級對。
- delay 估：同 tile 非 build→0；build 型 +BUILD_DAYS_EST(3.0)>0——bounded 淺啟發，非細讀 BUILD_TICKS，符合「有界」設計。

## `_mk_candidate` 簽名擴充——確認全呼叫點同步
`team` 參數插入後，grep 全檔 `_mk_candidate(` 共 6 處呼叫（`_resolve_build_facility`×2/`_resolve_resource_prereq`×3/`_resolve_location_prereq`×1）**全數同步更新**，無漏改導致的簽名不符編譯錯誤。S5 委派變體（`_delegate_variant`）自建 dict 不經 `_mk_candidate`，不受影響，正確。

## ★hygiene note（非 blocking，記錄避免下次同款）
commit 宣稱「TDD means_end_s6_test **8/8**」，我 `grep -c "_ok("` 得 8——但其中 1 筆是 `func _ok(cond,msg)` **輔助函式定義本身**，非斷言呼叫。逐行核對 `_test_*` 6 個函式實際只含 **7 個** `_ok(...)` 呼叫（① 1 + ② 1 + ③ 1 + ④ 1 + ⑤ 1 + delay估 2 = 7）。**功能本身無問題**（7 條全我親算驗證通過），只是自報數字疑似用 grep 誤把輔助函式定義算進斷言數——提醒往後报数字用函式呼叫計數，別讓 def 混進 call count。

## 判決
**CLEAN → 放行 merge。** means-end arc S1-S6 核心機制收官（骨架→資源型→定位+閉環→設施→委派→折現全鏈打通）。→ dispatch S7（cadence 泛化+perf optimize+收尾），S7 merge 後才是 whole-done，交 QA/blueprint 做整個系統的 measure。
