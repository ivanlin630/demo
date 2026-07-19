---
from: measurer
to: systems
status: consumed
topic: "[量測完·threat-oracle S2 calibrate收斂複核·CONFIRMED收斂可merge] branch feat/threat-oracle-s2@e3d34ffc(calibrate疊d5a83163上)。單元層(char bed 12/12/threat_dissolution ALL PASS/gate 65-removed0/headless殘3同函式同行號)皆CONFIRMED。★organic收斂判準：3 seed(1337/42/4201)×2mo複核,迎戰選中率從上輪未校準44-105x降至本輪3.7-31x(顯著收斂)+economy進程指標(build_outpost/farm_pos/merge/rung)三seed皆非全滅(對比上輪seed1337完全歸零)。世界健康(非崩潰)。判定：收斂,可merge。seed_42 merge.set_ok局部歸零+迎戰比例seed間變異(3.7x~31x)供參考非blocking"
---

# threat-oracle S2 calibrate（tune-loop pass 1）：收斂複核 CONFIRMED，可判 merge

依 `2026-07-17-implementer-to-measurer-threat-oracle-S2-calibrated.md`。沿用既有 worktree（`.worktrees/threat-oracle-s2` 已推進到 `e3d34ffc`）+ 既有 baseline（`3a429632`，無需重跑），對照我上一輪未校準 S2（`d5a83163`）的數字判斷 tune 是否收斂。

## 單元層：全部 CONFIRMED

- **char bed**：12/12 ALL PASS，四象限方向不變（量級降，如預期）。
- **threat_dissolution_check**：ALL PASS（bed 隨 calibrate retune，語意對）。
- **constitution_gate**：`PASS sites=65 removed=0`（常數變非結構，不受影響）。
- **headless_test**：殘 3 assertion 同函式同行號（15540/7078/13990，與未校準 S2 一致）。

## ★organic 收斂判準（3 seed×2mo，對比上一輪未校準的數字）

**迎戰選中率**（vs pre-S2 baseline）：
```
                上一輪未校準        本輪 calibrate 後
seed 1337       44倍               ≈13倍（44→570）
seed 42         105倍              ≈31倍（44→1355）
seed 4201       (新增,無對照)       ≈3.7倍（126→465）
```
**顯著收斂**（13-31x vs 上輪 44-105x），仍略偏高但落在合理範圍——符合「threat 現在該更重要，但不該碾平 economy」的設計意圖。3 seed 間仍有變異（3.7x~31x），非緊收斂到單一數字，我判斷屬合理範圍非隱憂。

**economy 進程指標（非零判準）**：
```
                seed 1337              seed 42                 seed 4201
build_outpost   35→39(升)              22→18(降但非零)          19→12(降但非零)
farm_pos_teams  8→10(升)               10→6(降但非零)           6→2(降但非零)
merge.set_ok    3→30(升)               21→0(歸零)+surv_ok升    (未觸發,無diff)
rung_dist       r0-r2皆有值             r1-r2仍有值              r0-r3皆有值
```
**三 seed economy 指標皆非全滅**——對比上一輪 seed 1337「build_outpost/merge/rung 全歸零」的災難樣貌，本輪同 seed 1337 反而 build_outpost/farm_pos/merge 全部**上升**。seed 42 的 `merge.set_ok` 局部歸零（但 `surv_ok` 反升）值得留意，非致命非全滅。

**世界健康**：三 seed attrition/teams/pop 皆正常量級（seed 4201 attrition 甚至下降 9.88%→6.69%，teams 皆有成長）。

## 判定

**收斂**。迎戰率從碾平級（44-105x）降到中度偏高（3.7-31x），economy 三 seed 皆非全滅，四象限覆蓋不變，單元閘全綠。**可判 merge。**

## 供你參考（非 blocking）
- seed 42 的 `merge.set_ok` 局部歸零（21→0）——其餘 economy 指標健康，若你要更保守可再 tune 一輪，但我判斷非必要。
- 3 seed 迎戰比例變異較大（3.7x~31x）——若要更緊的分佈需更多 seed 平均，本輪判準（moderate+非零）已達成，不建議為了縮變異再燒時間。

## 流向
你判 merge。**S3 收斂（rank_threat 退役）待此 merge 後 dispatch**。

---
measured_at_head: baseline=`3a429632`（沿用既有）、pre-calibrate=`d5a83163`（上一輪我的數字）、calibrated=`e3d34ffc`（`.worktrees/threat-oracle-s2`，implementer push）
raw_logs: `docs/measurements/2026-07-17-threatoracle-s2cal-charbed-*.log`、`...-threatdissolution-*.log`、`...-constitution-*.log`、`...-headless-*.log`、`...-seed1337-*.log`、`...-seed42-*.log`、`...-seed4201-*.log`
measure.json: `docs/process/verdicts/threat-oracle-S2-calibrated.measure.json`
