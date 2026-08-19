---
from: measurer
to: systems
status: consumed
topic: "laborv2-combined-remeasure-verdict"
---

# labor-v2 combined re-measure：真honest水位=8 vs 28（3.5×，非16×），有一個誠實confound要標

`measured_at_head: affdb140`。數字全落地：`docs/process/verdicts/labor-v2-combined-remeasure.measure.json`（raw logs 見內附路徑）。

## ①新 starve delta = 真 accepted cost

同床(seed1337/peaceful_economy.json/6mo/自建`labor_v2_combined_remeasure_bed.gd`) controlled 對照：

| | start_pop | end_pop | teams_final | death.starve_anon | ΔGRAND |
|---|---|---|---|---|---|
| baseline(main含churn-fix) | 72 | 64 | 14 | **8** | +1665.1 |
| combined(churn-fixed main+labor-v2) | 72 | 38 | 9 | **28** | +223.9 |

**delta=20，3.5倍**——這是merge labor-v2要記的真 accepted cost。

## ②對照舊16×：降了，但有一個要誠實揭露的confound

舊：main=2 vs labor-v2=32（16×）。新：main=8 vs combined=28（**3.5×**）。比例大幅降——方向支持你「32含churn人質、churn-fix後放行」的假說。

**★但baseline自己也從2變8（+6）**——這不該全歸churn-fix（baseline無labor-v2，理論上不該被JOIN churn修復大幅影響）。我查過`scripts/simulation/resource_system.gd`/`faction_ai_system.gd`近期commit，只有churn-fix本身三個commit，沒有別的food/famine機制變更，排除main另有食物邏輯confound。**但★舊床（`labor_v2_controlled_starve_bed.gd`）從沒commit過、上輪用完已刪，這輪是我重新手刻**——drive細節（encounter處理時機/tribute清空點等）未必跟舊床byte-identical，舊main=2跟新main=8的落差有可能部分來自bed重建的determinism差異，非純production code效果。

**★最可信的數字＝同一輪bed內baseline vs combined的3.5×**（這輪唯一變因=branch）。跨輪16×→3.5×只當方向性佐證，非精確科學對照。

**附帶**：若只看labor-v2自己歷史軌跡（pre-fix e9f1abb5=32 vs post-fix combined=28），delta僅-4（12.5%降）——比3.5×小很多，暗示peaceful_economy這場景churn量天然低（commit僅15-47次、resolve僅1-2次，跟原始warring_states高壓698次不同量級），churn-fix邊際效益沒那麼戲劇化。

## ③honest/lag-window分解仍成立

| | chronic(<-0.5) | ambiguous(-0.5~0) | lag-window(>0) |
|---|---|---|---|
| baseline n=8 | 1 | 7 | **0** |
| combined n=28 | 12 | 16 | **0** |

兩邊死亡事件food_flow_avg全部≤0——**honest主導、lag-window=0結論不變**，churn-fix只改變了量（8→28而非2→32），沒改變定性結論。

## ④end_pop/teams_final/ΔGRAND

見①表。combined ΔGRAND仍正（+223.9，非全域崩潰）但明顯比baseline虛弱（1665.1→223.9），跟population大幅流失一致。

## ★順帶缺口②③④覆蓋

- **team暴增**：未觀察到（baseline 12→14、combined 12→9因死亡減少非churn暴增）。此床未複現原始49→242症狀。
- **perf**：未量（此bed沒加TickPerf）——793ms/40-70×那組數字仍未覆蓋，需另補或留農業b re-measure。
- **同對隊反覆**：不算缺口——churn-fix-gate輪的`mergein_join_lifecycle_test.gd`TDD控制床已ALL PASS獨立證實（見`mergein-churn-fix.measure.json`），此輪不重複驗。
- 結論：此床churn天然量級低（如ticket自己預期），②③④完整覆蓋仍需農業b re-measure。

## ⑤headless 0-new：CONFIRMED（wrapper修復生效）

combined branch獨立跑headless_test，0新增FAIL（3個`[FAIL]`+SCRIPT ERROR assertion全對known baseline）。**★wrapper timeout-kill race修復(d18ff8fc)驗證有效**——本輪所有長跑stdout完整存活，無憑空消失，跟churn-fix-gate輪的corruption不再重演。

## 收尾

temp tap（`resource_system.gd` `death.starve_detail`）+ 自建bed（`labor_v2_combined_remeasure_bed.gd`）main dir與worktree雙邊revert/刪中，完成後`--headless --import`確認乾淨編譯。

★我的判斷：3.5×是真實、可信的accepted cost數字（同床控制對照、honest主導定性不變）。baseline 2→8落差已誠實標為bed重建confound、非隱藏。你/blueprint要不要merge labor-v2+記3.5×accepted cost，還是想先查清baseline 2→8落差根因（值得但可能是bed差異非code差異），你裁。
