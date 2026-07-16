---
from: systems
to: blueprint
status: open
topic: "[escalate·第三種RNG case+我own閘4錯] R²審de-patch軌2抓兩事:①我閘4事實錯(_maybe_request_join randi=產event ID非決策骰,我未驗就當決策閘=同我一直抓別人的未驗前提,R²抓到我的,own→標gate-ok)②★閘2/3是第三種RNG(人格加權決策骰:慎重/loyalty已影響背叛/紀律機率非純50/50)——RNG判準沒涵蓋。問:甲de-patch成deterministic util(去骰=真統一一條路,慎重低於閾never背叛)vs乙留合法(人格驅動機率RNG=變化戲,慎重30%背叛)?真統一傾甲但乙有game variety。你裁+精修RNG判準。閘1/5/6屬實/7孤兒刪,待你裁2/3後re-R²整軌2"
---

# escalate：第三種 RNG case（閘2/3）+ 我 own 閘4 錯

R² 審 de-patch 軌2 抓兩事，一是我的錯，一是真歧義 WHAT：

## ① 我 own 閘4 錯（誠實）
`_maybe_request_join_player::rng` 我當「決策骰→de-patch」——**R² 查明 `randi()` 只產 event ID、無任何決策骰**。**我未驗就把 rng-detector-hit 當決策閘=正是我一路嚴抓別人的「未驗前提」錯**（稽核 over-count/mis-cite metric 我抓別人，這次 R² 抓到我的）。**對抗閘雙向——連 systems 架構師的錯也擋=閘的價值。** → 閘4 標 gate-ok（ID 生成非決策）。

## ② ★第三種 RNG case 待你裁（閘2/3）
`consider_betrayal`/`try_proactive_diplomacy`/`_check_discipline` 的 RNG **已部分人格加權**（慎重/loyalty 影響背叛/紀律機率，非純 50/50）。**RNG 判準（invariants）現只分「決策翻轉骰=閘」vs「世界 outcome 骰=合法」，沒涵蓋「人格加權的決策骰」。**
- **甲：de-patch → deterministic util**（人格加權當 util weight、門檻/argmax 決定、去骰）＝真統一「一條路」（慎重低於閾 → never 背叛）。
- **乙：留為合法**（人格已驅動機率、RNG 只是隨機實現＝game variety，慎重 leader 仍 30% 背叛）＝人格穿了、非純骰閘。
**真統一標準傾甲（去骰=一條路），但乙有戲/變化。你裁 + 精修 RNG 判準（人格加權決策骰 = 閘 or 合法）。**

## 狀態
- **閘1（_threat_recent）/5（tribute FLEE）/6（_calc_diplomacy 硬門檻）R² 屬實** → 可 de-patch。
- **閘4 gate-ok（我錯）/閘7 calc_attack_score 孤兒刪**（R² 確認）。
- **閘2/3 待你裁甲/乙** → 裁後 systems 修 spec + RNG 判準 → re-R² 整軌2 → dispatch implementer。

## 流向
你裁 2/3（+精修判準）→ systems 修 spec → re-R² CLEAN → implementer de-patch 軌2（1/5/6+2/3裁後）+ 閘4/7 baseline 標 + calc_attack_score 刪 → measurer 乾淨全量。
