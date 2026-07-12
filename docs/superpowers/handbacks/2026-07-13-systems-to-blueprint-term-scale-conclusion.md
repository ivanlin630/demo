---
from: systems
to: blueprint
status: open
topic: [零跑結論] term量級系統性落差確認(pre-existing);舊subset-routing隔離比較,統一rank首次揭;根=優先序baked進base-scale非coeff;推薦專屬normalize slice先於S3/S4
---

# 零跑結論：term 量級系統性落差 = 重構「順便揭露」的既有缺陷

## 確認：是既有問題，非本次重構造成（你假設②成立）

Code 審 `terms.gd` 各 term 典型輸入下量級（非只看公式）：

| bucket | option | base term 量級（典型輸入） | 註 |
|---|---|---|---|
| **survival** | 覓食 | `survival_pressure = 4×(3−food_days)` → **0～12** | food=0→12,dwarfs 一切 |
| survival | 買糧 | `buyfood = 1.2×(3−food_days)×dist` → **0～3.6** | ×1.2 vs 覓食 ×4 |
| survival | 乞食 | `beg = 1.2×0.5×(3−food)` → 0～1.8 | BEG_FLOOR 故意低 |
| survival | 併入 | `join = 1.2×max(hunger,threat)×magnet` → 0～3.6 | |
| **threat** | 迎戰 | `defend = 好·0.7+(1−threat)·0.2` → ~0.55 | |
| threat | 備戰 | `prepare = 慎·0.6+好·0.3` → ~0.45 | |
| threat | 求和 | `pacify = 貪·0.5+信·0.3−好·0.3` → ~0.25 | |
| threat | survival(FLEE) | `threat_pressure = threat+panic·0.5` → 0～1.5 | |
| **ambient** | 生產 | `produce 0.6×settle + ambition_drive` → ~0.6-0.7 | 兩 term |
| ambient | 建設 | `settle_fit 0.4×settle + ambition_drive` → ~0.6 | 兩 term |
| ambient | 駐守 | `settle_fit 0.6×settle` **單 term** → ~0.3 | 缺第二 term |
| ambient | 訓練 | `train = ambient(0.5)×weight` → ~0.25 | |
| ambient | 吸納 | `absorb ≈ 0.27×weight` → ~0.13 | |
| ambient | 貿易 | `economic(0.64)+intent_fit 致富(1.5×..)` → 0.6~1.7 | |

## 三個系統性落差（root）
1. **survival_pressure ×4 (0-12) 支配 survival bucket**：買糧(3.6)/乞食(0.9)/併入(1.8) 撞 覓食(12)恆輸。你點的買糧 coeff=0.90 卻 own_util 輸 10× → 就是 buyfood ×1.2 vs survival_pressure ×4 的尺度差（非 bug，是**兩 term 從沒同尺度**）。
2. **threat repertoire 全在 0.25-0.55**：備戰/求和 撞 迎戰(0.55)/FLEE(0-1.5)恆輸 → 威脅反應塌成只剩打/逃，備戰/求和 湧現不出。
3. **單-term option 結構性矮一截**：駐守(單 settle_fit 0.3) vs 生產/建設(settle_fit + ambition_drive) → 野心>0 時駐守恆輸。

## ★真根（架構層洞察）
**舊架構 subset-routing 隔離比較**：survival 走 `rank_survival`/PRIO_SURVIVAL 插隊、threat 走 `rank_threat` 子集、ambient 走 `rank_ambient` 子集——**各 bucket 內部 scale 各自 tuned，從沒跨 bucket 公平比過**（survival_pressure ×4 高是為壓過 survival bucket 內的貿易；threat 全 ~0.5 因只跟彼此比）。**這次重構的統一 rank_scored_ctx 首次把 23 option 湊同一鍋比 → 各 bucket 獨立 scale 的落差第一次爆出來**。

更深一層：**優先序被 baked 進 base-term scale**（survival_pressure ×4 = 「survival 該壓過別的」寫死在 base 量級）。但重構的 coeff/urgency **也**編碼優先序（survival urgency 高）。→ **雙重編碼 + base-scale 支配**。乾淨的重構模型應是：base term = 「這 option 執行得多好」(scale-neutral 0-1)、coeff = 「現在多需要它」(urgency 載優先序)、util=base×coeff。現況 base 把優先序也扛了 → coeff 加上去 = scale 亂。

## 判斷請求（scope=你裁）
這是重構「23 統一公平比較」價值主張的**未竟前提**——不校準 term scale，統一 rank 就被高-scale term 支配，9 option 結構性 0 = 重構自己的價值沒達到。三案：
- **A（推薦）**：專屬 **term-scale normalize slice**（S2.7 或 S3 前），原則=**優先序移到 coeff/urgency，base term 正規化到可比的「執行品質」scale**（保 survival 該壓過別的=靠 coeff 不靠 base ×4）。這是重構的缺件，此時動整個 term 架構順手做最有效率（你點的）。**但範圍不小**（~15 term 重定 scale + 保意圖優先序 + 全 organic 重驗）→需你批這算重構範圍內。
- **B**：只 lift 塌掉的變體（threat repertoire 備戰/求和、駐守補第二 term）局部校，全面 normalize 記 known-limit 後排。
- **C**：全記 known-limit，S3/S4 照走（但價值主張持續未達，9-zero 續存）。

**我推薦 A**：9-zero 是重構價值沒達的直接證據，normalize 是缺件非額外功能。但 A 動 ~15 term = 大工，需你 WHAT 批「校準既有 term 納入本次重構」。批 A→我出 normalize slice spec(優先序→coeff/base→neutral)→R②→dispatch。批 B/C 告知。

零跑至此（code 審 terms.gd 全量級,無跑 sim）。S3 暫不 dispatch（等你裁）。
