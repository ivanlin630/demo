---
from: measurer
to: systems
status: open
topic: 三格新增(C-1/C-2/D)可行性回報——2格零新tap，1格需新tap
---

## C-1【設施升級真的發生幾次】—— ★零新tap，既有taps全套已在

查`faction_ai_system.gd:5375-5427`（2026-08-26 outpost-upgrade-path slice留下的三段分母，本來就是為了同一個問題設計的）：
- 分母①(本函式被走到幾次)：`upg.eval_entry`（per-day per-team，`Probe.bump_pt`）
- 分母②(有據點的隊)：直接讀`state.world.tiles`掃`outpost_level>0 and outpost_owner==team自己`，不需tap
- ③真的發生：`infra.stop.1_upgrade`（evaluate_upgrade真的成功dispatch的計數）

三段分母的意義（沒人想升級 vs path沒被走到）用①②③交叉讀就夠，全部既有。

## C-2【大團vs小隊人均產出比】—— ★零新tap，直接讀state即可

`team.food_produce_avg`（resource_system.gd:312-317）已經是**per-team EWMA**平滑後的產出速率，不需要新tap——直接周期性snapshot這個欄位，按population/outpost farming_level分組算比值即可。純觀測讀state，連ledger都不用開。

## D【物價clamp命中率】—— ★★需要新tap

`trade_valuation.gd:159-163`：
```gdscript
var shortage: float = (target - stock) / maxf(target, 1.0)
if res in SURVIVAL_GOODS and shortage > 0.5:
    shortage = 1.0 + (shortage - 0.5) * 6.0
var sr: float = clampf(shortage, -0.5, 4.0 if res in SURVIVAL_GOODS else 1.0)
```
既有`local_value.calls`只給呼叫次數（③未撞的分母夠了），但**沒有任何地方記錄「這次shortage被clamp下界/上界/沒撞」**——這三個互斥桶需要在clampf前後比較`shortage`（clamp前）vs `sr`（clamp後）才能分類，目前沒有這段邏輯也沒有對應tap。

★這格需要新tap，跨我production scope，需你或implementer加。建議形式（僅供參考，你們定）：
```gdscript
if Probe.enabled:
    if sr <= -0.5 + 1e-6: Probe.bump("valuation.clamp_lo")
    elif sr >= (4.0 if res in SURVIVAL_GOODS else 1.0) - 1e-6: Probe.bump("valuation.clamp_hi")
    else: Probe.bump("valuation.clamp_none")
```
三桶+`local_value.calls`互相對照即可驗證窮盡（三桶加總=calls）。

## 總結
| 格 | 需新tap? |
|---|---|
| C-1 設施升級 | 否，既有taps全套 |
| C-2 人均產出比 | 否，直讀state即可 |
| D clamp命中率 | ★是，需三桶新tap |

其餘七格(批次成效格)我之前跑過的床(member_tax/salary_flow/anon_pool)已覆蓋③⑤⑥；其餘④①②④⑦⑧我這輪沒逐一核對，若你要我先把「哪幾格床已經有、哪幾格床還沒寫」也列清楚，說一聲。
