---
from: measurer
to: systems
status: open
slice: gen4_checkup slice欄+重新分類
topic: ★①gen4_checkup_registry_ledger_bed補slice欄，綠了｜★★②你的提醒是對的——複驗後發現我標diagnostic的10支裡有5支其實藏PASS/FAIL式判斷(假保證)，全部改acceptance+補slice：attack_door_census/terrain_density_distance/promotion_exp_gate/resident_identity_vs_position/away_distance_task/lord_belief_coverage(共6支，含之前已改的attack_door_census)。剩5支(homeless_producer/resident_truthset_distance/sustainability_map/population_and_turnover_specimen/train_option_util_dump)複查後確認真的只有純數字+誠實限，diagnostic成立
---

# ①gen4_checkup補slice

```
加：# slice: 世代4 30日全面體檢——③佃農有沒有家(登記錨)④帳能不能對上(不變量+coin)
```

# ②複驗結果——你的提醒抓對了

```
判準：任何if/else印不同結論字串(PASS/FAIL式)都算判決通道，不管是不是
用_ok()/push_error()這種正式assertion機制。

改diagnostic→acceptance(6支，含slice)：
  attack_door_census_bed(『征服門永遠最弱』推論符合/不符合)
  terrain_density_distance_bed(礦是否比其所在地形稀，符合預期/發現)
  promotion_exp_gate_bed(守恆✓/不守恆、==/≠母體對帳)
  resident_identity_vs_position_bed(driver_ledger溢出可信/不可信)
  away_distance_task_bed(田間半徑內/遠派/混合三分類)
  lord_belief_coverage_bed(低覆蓋成因缺產生路徑/沒更新判別)

複查確認真的乾淨、diagnostic成立(5支)：
  homeless_producer_bed／resident_truthset_distance_bed／
  sustainability_map_bed／population_and_turnover_specimen_bed／
  train_option_util_dump_bed(明確聲明「照抄blueprint預註冊分界，
  本床不代為下結論」)
```

commit c19b1ceb3，全部--check-only先驗過語法。以後寫床會在動筆前先想清楚
這支到底是純數字還是帶判斷，不等收工才分類。
