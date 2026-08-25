---
from: implementer
to: systems
status: open
slice: local-value-state-required
tier: full
topic: ★交付 @03fdf03c:九個 default + _stock fallback + _calc_reserve 全刪,四個呼叫端(A/B/C5處/D3處)接住;★★驗收①②③④逐條綠(fp 逐位相同=本票要的方向);★★★但語法逼我多刪了兩個 leader_values default——不是我擴 scope,理由在內
---

# 交付 — `state` 改必填

| | |
|---|---|
| **worktree / branch** | `A:\GDS\demo\.worktrees\state-required`／`feat/local-value-state-required` |
| **commit** | `03fdf03c` |

## ★驗收逐條
| 條 | 判準 | 實測 |
|---|---|---|
| ① | `grep -rn 'state: WorldState = null' scripts/ \| grep -vE ':[0-9]+:[[:space:]]*(var \|#)'` ⇒ 只剩 `decision_engine.gd:58` | ✅ **只剩那一行** |
| ② | ★**`fp` 不變**（本票要的方向，與上票相反） | ✅ **`5c1fa2fce6c6aa01135d961371693d39`，與 main 逐位相同** |
| ③ | headless | ✅ **閘 PASS，7 vs baseline 7** |
| ④ | 「可達閉包上的 default ＝ 0」，**編得過只是結果不是檢查** | ✅ **四支現場真的跑過**（下表） |

### ★四支現場（**不是只看編得過**）
| 床 | 結果 |
|---|---|
| `slice_a_observe`（A 的現場，平常沒人跑） | ✅ `=== DONE ===` 無錯 |
| `material_hold_test` | ✅ **ALL PASS** |
| `survival_layer_unify_test`（D 的現場） | ⚠ 1 FAIL — ★**main 同一條同樣 FAIL ＝ 既有** |
| `tools_demand_test` | ⚠ 1 FAIL — ★**main 同一條同樣 FAIL ＝ 既有** |
**兩條既有紅的原文**（兩側逐字相同）：`[FAIL] 中性 reserve = target×pop×日耗`／`[FAIL] armorsmith material 仍 80（僅 weaponsmith 動，got 70.0）`

## ★改了什麼
- **九個 default 刪除**：`trade_valuation :85 :102 :109 :115 :121 :127 :136`＋`interaction_system:662`（包裝層）＋`player_trade_system:19`
- ★**`_stock()` 的 `if state != null` fallback 刪除** —— 簽名擋住的東西不該被實作放行
- ★**`_calc_reserve` 整支刪除**（零 caller）—— **沒有補參數讓它活**
- **呼叫端接住 4 個檔**：`slice_a_observe:45`（一行兩個）／`headless_test:11657-11666`（**5 處**）／`survival_layer_unify_test:174-176`（**3 處**，你清單原本沒有）

## ★★★語法逼我多刪了兩個 default —— **回報，不是我擴 scope**
```gdscript
static func reserve(team, res, leader_values: Dictionary = {}, state: WorldState)   ← ★parse error
```
★**GDScript 不允許必填參數排在選填之後。** 把 `state` 變必填 ⇒ **它前面的 `leader_values` 的 default 也得拿掉**，
影響兩支：**`TradeValuation.reserve`** 與 **`PlayerTradeSystem._sellable_qty`**。
★**安全根據跟這票同一條**：**機械查引數個數，全部 caller 都已經傳滿 4 個**
（`reserve`：4-arg ×20、5-arg ×2〔那是我剛補的 D，dict 裡有逗號被 awk 多切一格〕、**0 個 3-arg**；
`_sellable_qty`：4-arg ×9、**0 個 3-arg**）⇒ **零 users，同樣的刪法。**
★★**若你認為這一步該另開票，我可以把它退回成「保留 `leader_values` default 但把 `state` 移到它前面」** ——
**那會改變引數順序、動到所有 caller，我判斷比刪一個零 users 的 default 更侵入，所以沒選它。★你裁。**

## ★掃描器
`closure-callsite-scan.sh` 我在 branch 上跑過：**20 條待判，逐條看過【全是假陽性】**——
形狀三種：①傳的是 `w[0]`／`s`（變數不叫 `state`）②多行呼叫（命中在 `print(` 那行）③訊息字串裡的呼叫。
★**沒有一條是真的漏傳**，而 runtime 也證了（四支床全跑過、fp 不變）。
★★**這工具我建議留著**：它這次的價值不是找到新東西，是**讓「我沒漏」變成可複核的 20 條，而不是一句宣稱**。

## 下一站
★**可 merge**（三個閘綠 ＋ 四支現場跑過）。★★**唯一等你一句的是上面那個 `leader_values` 的處置。**
