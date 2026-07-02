# ③ asm 待遇做深 + ②b 飢餓下修搶糧 readiness + ②c 濾改分 — Design

> 藍圖裁定 `2026-07-03-blueprint-to-systems-chain-rulings-envoy` 裁②b/②c/斷③。
> 根據:長窗 asm created=6→completed=1/interrupted=5（revolt3/escape2）=**結構性斷**（完成那隻 24 天=不慢）;
> T36 readiness 恆 0.23<0.42 + score 0.27<0.30 = 餬口狼永不戰略 raid;prey「food<20」硬濾殺光餓世界目標。

## ③ asm 做深（受控人力 spec §5/§7 照做,非新發明）

### 現況病灶（manpower_system.gd 讀碼定位）
- 待遇=flat rate（厚待 +0.02/日、苛待 −0.015/日）,**不吃真實餵養**——spec §5「待遇逐時改」原意=待遇輸入驅動,現在是二元開關。
- `_flee_opportunity` = `guard < captive or readiness < 0.4`——**餓世界 holder readiness 恆低 → 機會恆真** → 低 morale captive 必逃。看守強度無決策、無成本。
- 無 guard-cap stakes（spec §7:關俘耗守衛→上限→逼決策別囤）。

### 修法（全連續信號,零新判斷器）
1. **餵養=真食物輸入（守恆）**：厚待 morale 增速 × 餵養質量因子——holder 對 captive 實際撥糧（captive 吃 `CAPTIVE_FOOD_RATE`/人/日,從 holder 有效糧扣,ResourceBank 路由）。糧足 → 全速 +0.02;糧半 → 半速;斷糧 → 厚待名存實亡（morale 掉,= 苛待效果）。**「厚待」不再是免費 flag——要真掏糧**（affordance 真實性 invariant）。
2. **看守強度=真決策**：`decide_treatment` 增看守權重輸出（guard allocation:holder 撥多少 anon 當看守,連續比例非開關）。`_flee_opportunity` 改連續:逃機率 ∝ `captive/(guard_allocated+1)` × (1−morale)——看守厚 → 難逃/難暴動;看守薄 → spec §7 stakes 真咬。看守 anon 不事生產（機會成本,經濟既有信號）。
3. **guard-cap**：可持有 captive 上限 ∝ 看守數（TEST VALUE 倍率）。超限 → 待遇決策強制處置（釋放/苛用,means-end 選）——**逼決策別囤**（spec §7 原文）。
4. **revolt 閾維持**（暴動該存在=戲）;但苛待+斷糧才快速逼近,厚待+真餵養軌跡不再中途被「機會逃」腰斬。
5. LOD 不變:anon 批次;named 個別（Phase 2,不在本波）。

## ②b 飢餓下修搶糧 readiness（只限 raid-for-food）+ score 稍寬

1. **readiness 門檻連續滑降**：`_evaluate_prosperity_attack` readiness 檢查改
   `threshold_eff = threshold × hunger_relief`,`hunger_relief = clampf(food_days / HUNGER_SLIDE_DAYS, RELIEF_FLOOR, 1.0)`（TEST VALUE:SLIDE_DAYS≈7、FLOOR≈0.4）——越餓門檻越低（餓兵搶糧豁出去）,糧足=原門檻。連續信號,零新閘。
2. **guard（藍圖原文）**：只降**補糧 raid**——faction 級開戰/campaign 路徑（commander directives/`can_expand` 擴張 intent/faction goal 攻擊）**維持正常 readiness**,不吃 hunger_relief。餓軍不發大戰。
3. **score 稍寬**：`ATTACK_SCORE_THRESHOLD` 0.30 → **0.25（TEST VALUE,seeded 校）**。驗收=「寬度夠生戲（T36 類 0.27 狼偶爾動手）+ 知足者仍蹲（archetype gate 本就擋 SETTLE/TRADE,不受影響）」。

## ②c prey「food<20」硬濾改計分

- `_find_weakest_prey` 刪 `food_est<20 → skip` 硬濾（窮村可選）。
- 富度差進分:弱點主排序不變（pop_est）,`food_est` 低者輕度降權非零分（fold 進比較或輕係數,TEST VALUE）——raid 收益=糧+人力+coin+裝備,窮村仍有人可俘。
- `find_prosperity_prey` 本就 richness 計分,不動。

## 硬約束
- 全連續信號、零新 classifier/判斷器;新 latch（無）;身分不切路徑。
- 守恆:餵養扣糧走 ResourceBank;captive 轉換全經 AnonTierSystem（現行不變）。
- 待遇 driver-complete:看守/餵養決策寫 treatment_history（provenance 現行 pattern 延伸）。

## 驗收
1. **asm 分流反轉**（longwindow 6 月）:completed/created 比顯著升（1/6 → 目標 ≥1/2 量級,TEST 目標）;interrupted 不歸零（暴動/逃=戲,苛待者仍炸）。
2. **餵養真實**:厚待 holder 糧消耗可見（captive 吃糧;斷糧厚待失效測試）。
3. **T36 類解鎖**:餬口 FORCE 狼（score 0.25-0.30 帶/低 readiness）長窗 raid>0;[GateWait] 殘量降。
4. **不 over-war**:知足者仍蹲（archetype gate）;faction campaign readiness 未鬆（guard ②驗:faction 攻擊路 readiness 檢查無 hunger_relief）。
5. **②c**:餓世界 prey viable>0（zoom diag prey 掃 food<20 殺數 → 0）。
6. 回歸:headless（1 FAIL pre-existing 容忍）+0 SCRIPT ERROR、framework 7/7、coin_eq delta=0、InvariantAudit 0。行為修=pointwise 預期 DIRTY,月線 sanity（隊數/attrition/found 不崩）。

## 檔案 scope
| 檔 | 動 |
|---|---|
| `manpower_system.gd` | ③ 餵養/看守/guard-cap/機會逃連續化 |
| `anon_tier_system.gd`（如需） | 看守 allocation 欄 |
| `faction_ai_system.gd` | ②b hunger_relief（僅 prosperity 路）+ score 0.25;②c _find_weakest_prey 濾改分 |
| `resource_system.gd`/`ResourceBank`（如需） | captive 餵養扣糧路由 |
| `headless_test.gd`/`longwindow_bed.gd` | 驗收測試+探針 |
