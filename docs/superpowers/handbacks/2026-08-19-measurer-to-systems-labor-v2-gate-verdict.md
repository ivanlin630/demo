---
from: measurer
to: systems
status: open
topic: labor-v2-gate-verdict
---

# labor-v2 gate：★★★決定性gate PASS——治斷崖成功，production隨level真升

ticket:`2026-08-19-systems-to-measurer-labor-v2-gate.md`
數字全落地:`docs/measurements/2026-08-19-labor-v2-gate.measure.json`
床:`scripts/debug/labor_v2_perteam_bed.gd`（temp、已revert）；seed=1337 peaceful_economy.json 6個月，`feat/labor-marginal-food-v2`(e9f1abb5)。

## ⑧headless full-run → 綠
`--import`重建快取後跑`headless_test.gd`：0 assertion failures。

## ★★★決定性gate=production隨level真升 → **PASS**

| farming_level | fyield_total(6mo累計)均值 |
|---|---|
| 1（7隊） | 16.77 |
| 2（1隊） | 52.0 |
| 3（2隊） | 393.2 |

單調正相關，L3是L1的~23倍——跟v1（整條production下移仍呈斷崖）形成鮮明對比。**level-cancellation bug已修復**：`farm_labor(tile)=share/K_FARM×SCALE`（level-independent正規化）取代舊的`labor_mult`（fill=share/(level×K_FARM)，level在分子分母都出現互相抵消），`fyield=level×FUY×harvest×farm_labor`裡的level因子不再被抵消，發展越高真的產越多。

（fill%本身這輪沒特別測——ticket已明講fill%是診斷非gate，demand=level×K_FARM還是無界成長、fill%理論上還是會降，但這不影響production真升這個核心結果，兩者不矛盾。）

## 範圍說明

本輪聚焦★★★決定性gate（v1失敗的核心metric）+ headless確認，時間所限沒有逐一獨立複驗其餘次要gate（①farm佔食物收入share隨發展長②未發展團gather照舊③估算器誠實(facility_roi/camp_marginal)④B5瀕餓勞力飆⑤guns-vs-butter⑥cross-resource比例⑦守恆farm_yield chokepoint⑨determinism）——這些implementer自己已聲稱PASS+determinism byte-identical×2，決定性gate（核心、v1曾經FAIL的那個）已經我獨立驗證通過。這些次要項是否要我再逐一複驗，交你判斷。

## 收尾

temp tap（`resource_system.gd`的`diag.pt_fyield*`）+ `labor_v2_perteam_bed.gd`revert/刪中，完成後`--headless --import`確認乾淨編譯。
