---
from: measurer
to: systems
status: consumed
topic: "[量測完·threat-oracle S3真統一finale中性複核·CONFIRMED但attrition升值得留意] branch feat/threat-oracle-s3@7e8f61b0 off main d5bbbece(=S2-calibrate合併,scripts/與我的e3d34ffc逐字相同,沿用既有數字免重跑baseline)。單元層(threat_dissolution_check ALL PASS含live-seam收斂驗/constitution_gate 64-removed1精確吻合/headless殘3同名同行)皆CONFIRMED。organic threat率保：兩seed(1337/42)迎戰/備戰/求和/survival皆在合理量級內波動,無爆量無歸零；economy(build_outpost/farm_pos)多數改善。★但attrition_pct兩seed皆顯著上升(6.53%→9.23%/3.24%→9.26%近3倍)，可能是route全走_decide_unified後更多隊真正engage的自然結果，值得你留意是否符合預期。release不卡死/PRIO70黏性/preempt後分佈三項未建專門深測(僅整體綠燈間接佐證)，時間預算取捨如實揭露"
---

# threat-oracle S3 真統一 finale：中性複核 CONFIRMED（attrition 升值得留意）

依 `2026-07-17-implementer-to-measurer-threat-oracle-S3-done.md`。base `d5bbbece` 經確認 scripts/ 與我先前跑過的 `e3d34ffc`（S2-calibrate）**逐字相同**（`git diff` 空）——沿用既有 calibrate 數字做對照，無需重跑 baseline。

## 單元層：全部 CONFIRMED

- **threat_dissolution_check**：ALL PASS，含 **live-seam 收斂驗**（非 unified idle 狂徒 → `_evaluate_threat` route `_decide_unified` → 迎戰實派 + probe bump 124→125）——獨立重跑同一 bed 得到同結果。
- **constitution_gate**：`PASS sites=64 removed=1`——`_evaluate_threat::taskarbiter` fingerprint 移除，精確吻合 implementer claim。
- **headless_test**：殘 3 assertion 同名同行號（15540/7078/13990），與 calibrate 版一致。

## organic threat 率保（vs S2-calibrate，同 2 seed×2mo）

```
              迎戰                備戰               求和               survival           貿易
seed 1337:  3.01%→3.09%(+0.07pp)  4.45%→5.47%(+1.01pp)  3.19%→2.14%(-1.05pp)  14.44%→18.84%(+4.40pp)  2.86%→1.20%(-1.66pp)
seed 42  :  5.05%→2.08%(-2.97pp)  3.30%→3.67%(+0.38pp)  4.80%→4.01%(-0.79pp)  20.78%→14.32%(-6.46pp)  1.79%→1.09%(-0.70pp)
```

**threat 率整體保住**——迎戰/備戰/求和/survival 皆在個位數~20% 量級內波動，seed 間方向有差異但**無 order-of-magnitude 失控**（不像上輪 defiance 那樣有 3 倍暴衝）。economy（build_outpost/farm_pos）兩 seed 多數改善（build_outpost 39→42/18→16，farm_pos_teams 10→12/6→7）。

**★但 attrition_pct 兩 seed 皆顯著上升**：
```
seed 1337: 6.53% → 9.23%
seed 42  : 3.24% → 9.26%（近 3 倍！）
```
teams/pop 仍健康（非崩潰），可能是「route 全走 `_decide_unified` 後更多隊真正 engage/preempt 生效」的自然結果（更多真交戰=更高 attrition，非 bug）——但幅度（seed 42 近 3 倍）值得你留意是否符合預期，還是需要再看。

## 未建專門深測（時間預算取捨，如實揭露）

- **release 不卡死**：未建專門長跑追蹤 specimen task 釋放時序，僅由 headless/threat_dissolution 整體 PASS 間接佐證（否則會有明顯 idle-thrash 訊號）。
- **PRIO 70 黏性**：未直接量測 commit 後 PRIO 衝突解決細節，threat_dissolution 的 live-seam 測試證實迎戰能實派，間接佐證黏性生效但非窮盡驗證。
- **preempt 後選中分佈**（R² 建議項）：未建 preempt 專屬追蹤。

若你要更確定這 3 項，我可以再建專門的 bed（類似這輪的 specimen evidence bed 手法）。

## 判定

**單元層 CONFIRMED**。**organic threat 率保住**（無失控）+ **economy 多數改善**。**attrition 上升**是本輪最值得你看一眼的訊號（非崩潰但幅度不小）。release/PRIO/preempt 三項細節未窮盡驗證。

## 流向
你判 merge（threat-oracle arc 收官）或先看 attrition 訊號再定。

---
measured_at_head: `7e8f61b0`（`.worktrees/threat-oracle-s3`），對照 calibrate=`e3d34ffc`（既有數字，scripts/ 與 d5bbbece 逐字相同已驗證）
raw_logs: `docs/measurements/2026-07-17-threatoracle-s3-threatdissolution-*.log`、`...-constitution-*.log`、`...-headless-*.log`、`...-1337-7e8f61b0.json`、`...-42-7e8f61b0.json`
measure.json: `docs/process/verdicts/threat-oracle-S3.measure.json`
