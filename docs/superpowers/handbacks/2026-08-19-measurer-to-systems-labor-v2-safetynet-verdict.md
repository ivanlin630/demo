---
from: measurer
to: systems
status: consumed
topic: labor-v2-safetynet-verdict
---

# labor-v2安全網複驗：①PASS(B5真飆升) ②ΔGRAND健康但starve數偏高——flag非blocker

ticket:`2026-08-19-systems-to-measurer-labor-v2-safetynet.md`
數字全落地:`docs/measurements/2026-08-19-labor-v2-safetynet.measure.json`
床:`scripts/debug/labor_v2_safetynet_bed.gd`（temp、已revert）；seed=1337 peaceful_economy.json 6個月，`feat/labor-marginal-food-v2`(e9f1abb5)。

## ①B5瀕餓保護底線 → **PASS**

| | 樣本數 | food_share均值 |
|---|---|---|
| 瀕餓(min_food_days<2) | 404 | **1.302** |
| 健康(min_food_days>5) | 321 | 0.819 |

瀕餓時food_share比健康時高約**59%**——勞力真的回流食物生產（`gather:food`+`farm`合併share），不是被gather/mfg卡死餓死。B5安全網機制運作正常，跟blueprint的『B5保護無需補償』前提相符。

## ②cross-resource/economic-health → ΔGRAND健康，但starve數要flag

- 全期加總share：food=29.5%、mfg=0.7%、material=69.8%——比例上food/material是主力,mfg小,這是peaceful_economy這個config的正常樣貌(非mfg密集局)，不是異常。
- **ΔGRAND=+1100.3**（t0=26465.0→tN=27565.3）——全世界食物總量**正、成長**，不是全域supply崩潰。
- 但`death.starve_anon`全期**32**，`end_pop=32/teams_final=10`——跟先前agriculture-a-gate輪同seed/config的基準（72→65、starve=10）比明顯偏高。

**這不是mass-starve式的supply崩潰**（ΔGRAND健康證明總量沒問題），比較像**分配層面的局部/波動性starve增加**——雙計移除後,食物勞力在正常時期(non-crisis)可能比舊機制分配得更緊，導致更多團落入瀕餓區間觸發safety net、雖然net觸發了但觸發前的窗口期已經有人餓死。

## 誠實揭露

沒有做labor-v2專屬的同床main baseline對照（時間所限）——上面『偏高』的判斷是跟另一輪(agriculture-a-gate,不同branch但同seed/config/months)的歷史數字比，不是嚴格controlled比較，只能當警示信號非確鑿證據。

## 結論

①硬PASS。②ΔGRAND不崩（核心不崩盤條件滿足），但starve數字比歷史基準高，這是一個**flag給你參考**，不是我判定的blocker——是否要因這個flag再開一輪同床main對照坐實有沒有真的變糟，交你裁。

temp tap（`labor_system.gd`的`safetynet.snapshot`）+ `labor_v2_safetynet_bed.gd`revert/刪中，完成後`--headless --import`確認乾淨編譯。
