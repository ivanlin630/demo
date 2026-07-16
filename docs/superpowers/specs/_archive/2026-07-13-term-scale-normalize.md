# Term-scale Normalize（S2.7）— 優先序移 coeff、base term 正規化中性執行品質（systems HOW）

> 藍圖裁 A(`normalize-decision-A`)：校準既有 term 量級納入重構。**優先序全移到 coeff/urgency，base term 正規化成可比的「執行品質」中性尺度**。先於 S3/S4。

## 動機
9 option 結構性 0 選中，診斷全落 base-util 競爭（非 coeff-lockout/gate 稀有）。真根：**優先序被 baked 進 base-term scale**（survival_pressure ×4=0-12），舊 subset-routing 隔離比較故沒暴露；統一 rank 首次公平比→高-scale term 支配。與重構「coeff/urgency 載優先序」**雙重編碼**。

## 核心不變量（重構後的乾淨模型）
```
util(option) = weight(term, 人格) × eval(term, ctx, opt) × coeff(需求對齊)
                [人格 0~1.5]         [執行品質 0~1]         [需求優先 0.15~1]
```
- **eval（base term）= 「這 option 執行得多好 / 這機會多好」，值域正規化 [0,1]，剝除急迫度/優先序**（急迫度移 coeff）。
- **weight = 人格染色**（不動，已在 [0,~1.5]）。
- **coeff = 需求優先序**（S2 已建，urgency 載「現在多需要」）。
- 三因子皆可比值域 → 統一 rank 公平；優先序**只**由 coeff 表達（survival 該壓過別的=靠 coeff 高、非 base ×4）。

## 優先序保全（剝 base urgency 後，coeff 撐得住嗎）— worked example（R② 代入真公式訂正）
餓隊(food=0)：survival urgency≈1→覓食(survival-aligned,alignment=0.9)coeff≈0.9475；訓練(survival affinity=0→alignment=0)coeff≈0.475。
- 覓食 util = weight(1.0)×base(1.0)×coeff(0.9475) ≈ **0.95**
- 訓練 util = weight(0.5)×base(0.5)×coeff(0.475) ≈ **0.14** → 覓食 **≈6.65×** 壓過。**survival 仍支配**（靠 coeff 非 base ×4）。✓
邊界半餓隊(food=3,urgency=0.4)：覓食≈0.664 vs 貿易(merchant 最佳)≈0.414 → 仍贏 1.6×；food=4(urgency=0.2)：覓食≈0.57 vs 貿易≈0.40 → 1.4×。**margin 隨 food 改善平滑遞減、非斷崖反轉**（graduated priority=重構本意，無「半餓隊跑去貿易」regression）。✓
飽隊(food=10)：survival urgency≈0→覓食 coeff≈FLOOR；esteem urgency 高→訓練 coeff≈1 → 訓練贏。✓

## Per-term 正規化（eval 改；剝 urgency 保 quality；值域 [0,1]）

| term (option) | 舊 eval | 新 eval（[0,1] 執行品質/機會） | 剝除的 urgency→去向 |
|---|---|---|---|
| `survival_pressure`(覓食) | `4×(3−food)` 0-12 | `1.0`（覓食=survival 預設可行行動；applicable 已 gate pop） | 飢餓→L_SURVIVAL coeff |
| `restock_need`(返家補給) | `1.5×(RESTOCK−food)` | `clampf(home_food/RESTOCK_MIN,0,1)`（家越滿返家越值） | 飢餓→coeff |
| `threat_pressure`(survival/FLEE) | `threat+panic×0.5` | `clampf(0.6+panic×0.4,0,1)`（逃跑可行+恐慌加成） | 威脅→L_SAFETY coeff |
| `buyfood_drive`(買糧) | `hunger×dist_disc` | `dist_disc`（近市集品質 0-1） | 飢餓→coeff |
| `beg_drive`(乞食) | `1.2×0.5×hunger` | `BEG_FLOOR_FACTOR`(0.5)（低品質最後手段=低 band 定值） | 飢餓→coeff |
| `camp_drive`(紮營) | `1.2×hunger` | `1.0`（可耕地已 gate） | 飢餓→coeff |
| `join_drive`(併入) | `1.2×max(hunger,threat)×magnet` | `clampf(0.5+best_protector_rep×REP_MAGNET_W×0.5,0,1)`（名聲磁鐵品質） | 飢餓/威脅→coeff |
| `occupy_drive`(佔村) | `1.2×(1 or 0.3)` | `1.0 if not has_own_outpost else 0.3`（要根據地品質） | — (已品質) |
| `loot_drive`(掠奪) | `1.0×cap` | `cap`（capability 0-1） | — |
| `absorb_drive`(吸納) | `1.2×slack×(0.3+0.7yield)×(0.5+0.5gap)` | 同式但 base 1.2→**1.0**（值域 [0,1]） | — |
| `economic_opp`(貿易) | `(0.8/0.2)×(1/0.3)×role` 0-0.8 | `clampf(舊/0.8,0,1)`（rescale 到 [0,1]） | — |
| `intent_fit` | `1.5×...` | `INTENT_FIT_DRIVE 1.5→1.0`（rescale；conq clampf 上限 1.5→1.0） | — |
| `prepare/defend/pacify_drive` | 0-0.7 人格 | **不動**（已在 [0,1] band，人格品質） | — |
| `produce_need/settle_fit/ambition_drive/train_drive/feud_pull` | 0.3-0.6 / 0-1 | **不動**（已在 band） | — |

**faction_duty（§7 例外）**：`FACTION_DUTY_DRIVE=1.5` **不正規化**——§7 明訂 faction_duty=社會權威層非個人需求，維持現況。這是**唯一刻意 scale-outlier**（授權軸非需求軸），標註於 code。攻擊/徵收/外交/歸建 的 duty term 保 1.5（授權壓過需求=服從母團）。measurer 驗服從不回歸。

## 駐守 affinity 併校（連帶）
診斷確認駐守 actual-heavy(0.5) 誤標（actual 就緒度後 rarely urgent→駐守恆低 coeff）。normalize 同時校 AFFINITY「駐守」→定居知足更近 esteem/survival：改 `[0.3,0.1,0.1,0.4,0.1]`（TEST VALUE，esteem 主=知足經營非 nation-striving）。organic 校。

## 拆分（sub-task，逐 bucket 驗回歸，早抓）
1. **T1 survival-class**：survival_pressure/restock_need/buyfood/beg/camp/join/occupy 正規化 + TDD(各 eval∈[0,1]) + organic(覓食/買糧/乞食/併入/紮營選中率↑、餓隊 survival 仍支配、TC2 survival-input 不回歸)。
2. **T2 threat-class**：threat_pressure 正規化(prepare/defend/pacify 不動) + TDD + organic(備戰/求和 湧現、FLEE/迎戰 不回歸)。
3. **T3 ambient/opportunity**：economic_opp/intent_fit/absorb rescale + 駐守 affinity 校 + TDD + organic(貿易/訓練/吸納/駐守 選中率↑、生產/建設 不回歸、TC7 collapse 複驗)。
4. **T4 整包驗**：per-option 分布(9-zero 是否全非零)+ determinism byte-identical + 融合閘 + 既有不變量(consolidation/combat/established 不回歸)。

## 驗收
- **9-option 非零**：貿易/備戰/求和/駐守/乞食/併入/吸納/訓練/買糧 per-option chosen>0（跨 seed）。
- **既有不回歸**：survival-dominance(餓→覓食)、threat(打/逃仍主但備戰/求和 出現)、faction 服從、consolidation/combat/established organic 不劣化。
- **determinism** byte-identical（純算術，零 randf）。
- **優先序純由 coeff**：自審 base term 無殘留 urgency 乘子（grep `food_days`/`3−`/`threshold−` 在 eval，除品質因子外應剝淨）。

## 風險（交 R② 審）
- **regression 面大**（~13 term 改值域）→逐 bucket organic 驗、早抓。
- **priority 保全**依賴 coeff 值域 [0.15,1] 撐得住 survival dominance（worked example 證 20×，但邊界 food 略低時 graduated=本意）。
- faction_duty outlier 打破「全 [0,1]」純度→但 §7 授權軸的刻意例外，非疏漏。
