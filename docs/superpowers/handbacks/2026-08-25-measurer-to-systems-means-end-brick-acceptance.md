---
from: measurer
to: systems
slice: means-end-brick
status: open
topic: "★B型驗收：①②③⑤全PASS(facility桶13/material桶30都非空不重疊；depth分佈1=25/2=9/3=5/4=4出現深度≥2；no_means桶=[gem,herb,horses,material,ore_iron]零製造品；food正確走rate形狀)；④是【空真vacuously true】非驗證通過——AcquisitionPaths窮盡grep0個production caller,模組尚未接進任何決策路徑,造不出會被違反的場景；falsifier未分類清單=空PASS(陽性對照ledger=59481/probe=799雙非零)"
---

# B型驗收：四條乾淨PASS，一條是空真

## ★前提：AcquisitionPaths目前0個production caller

窮盡grep`scripts/`(排除`debug/`)：`AcquisitionPaths`只被`headless_test.gd`單元測試呼叫，caller總數=**0**。這個模組尚未接進任何production決策路徑——這件事直接決定④怎麼判讀。

## ①facility桶13/material桶30，都非空不重疊：PASS

兩桶都非空，結構性不重疊(逐筆驗證每個path只認1個kind值)。

## ②依賴鏈深度分佈：PASS，主結果

`depth=1:25 / depth=2:9 / depth=3:5 / depth=4:4`——43筆path裡18筆(42%)深度≥2，遞迴是常態不是孤例，資料驅動(`weapon_melee_high→ore_steel→ore_iron→material`這條鏈天然produces depth4)。

## ③無手段可取得桶：PASS，乾淨的空

`means_end.no_means`母體=21，成員=`[gem, herb, horses, material, ore_iron]`——全是原料級資源，**沒有一個manufactured resource落在這個桶裡**。

## ④stock『有手段但不進flow_utility輸入』：空真，非驗證通過

`stock_sources()`每筆path都顯式帶`value_compared:false`(acquisition_paths.gd:90)，設計是對的。★★**但因為模組0個caller，目前沒有任何呼叫路徑會把它的輸出餵進`flow_utility`**——這條判準現在是【空真】(vacuously true)，不是「驗證通過」，是「還沒有機會違反」。我造不出會變紅的場景，因為連「會被違反的路徑」都還不存在。這正是你要的「若造不出就回報」。

## ⑤food不退化：PASS

`shape_of('food')='rate'`，不在`SHAPE_TABLE`裡，正確走`REGEN_RATE`導出路徑。

## falsifier：未分類清單=空，PASS

陽性對照`ledger=59481`/`probe=799`雙非零，儀器確實在跑；執行證明`manufacture.rate_via_authority=87`非零。掃到8種真的會增加的資源，全部有分類，未分類清單空。★本輪只跑30天`peaceful_economy`單一config，manufactured類只掃到1種(該config活動量小)，若要更完整覆蓋建議之後也在`warring_states`或更長天數跑一輪，供你裁。

## 無手段終止tap有沒有帶資源名：PASS

`Probe.bump("means_end.no_means." + res)`——tap key本身就帶資源名，不是裸counter。

## 落地

`.measure.json`：`docs/process/verdicts/means-end-brick-acceptance.measure.json`
`reports`：`docs/measurements/breed-deathcause/means-end-acceptance.txt` + `means-end-falsifier-30d.txt`

## L3聲明

新增`scripts/debug/means_end_acceptance_bed.gd`(純新debug script，直接呼叫`AcquisitionPaths.for_resource()`掃描，不改動任何production code)。
