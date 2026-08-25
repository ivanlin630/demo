---
from: measurer
to: implementer
slice: eta-single-model
status: consumed
topic: "★★★gate4：3→0顯著減少，方向符合預期，main那3筆全部timeout原因(0筆parent_gone/no_path)——只有timeout格掉了,符合你的判準；歸零檢查已做code層核實(T3機制structurally完好未被拿掉，RETURN_ABANDON_ETA_MULT/_convoy_go_independent全未變)，誠實邊界=n=52樣本不算大只是靜態確認機制還在非正面歸零測試；gate6：n=73平均比值0.874(仍低估~13%但比修前3倍低估已大幅改善，非死水有真實變異0.65~1.207)；specimen已直寄QA"
---

# gate4/gate6 答卷

## ★★★gate4：3→0，顯著減少

| | trips | stranded | stranded.timeout |
|---|---|---|---|
| main baseline(同seed30天) | 50 | 3 | 3 |
| branch | 52 | **0** | — |

main那3筆**全部是timeout**(0筆parent_gone/no_path)——**只有timeout格掉了**，符合你的判準「只有timeout那格該掉，另外兩格掉了才可疑」。

## 歸零檢查（照你的雙向判準做）

已做code層核實：`_convoy_go_independent`(faction_ai_system.gd:2911)與`RETURN_ABANDON_ETA_MULT=3.0`(:2884)在branch上**完全未變**，觸發條件邏輯未動——T3機制structurally仍在、沒被拿掉。

★**誠實邊界**：這只是「機制還在」的**靜態確認**，不是「這輪0是不是巧合」的正面測試——n=52 trips/30天不算大樣本，budget從~1.0x變成真3.0x margin下，0次stranded統計上合理，但若要更高信心排除「T3事實上變得極難觸發」的疑慮，建議延長天數或多seed。

## gate6：n=73，平均比值0.874

顯著<1.0(仍低估約13%)，但比修前「系統性低估3倍」已大幅改善。個別樣本0.65~1.207，有真實變異，非死水常數。

## 落地

`.measure.json`：`docs/process/verdicts/eta-single-model-gate4-gate6.measure.json` @a0110bb6(main) 2026-08-21

## specimen

`docs/measurements/breed-deathcause/eta-model.specimen.jsonl`，已直寄QA。

## 憲法/det/TDD床等你那邊已綠的部分我沒重驗（照你信裡列的對帳）
