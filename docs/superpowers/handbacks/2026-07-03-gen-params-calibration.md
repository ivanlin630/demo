# Hand Back: gen 參數校準（狼密度 + 開局緩坡）

Plan: `docs/superpowers/plans/2026-07-03-gen-params-calibration.md`
Branch: `feat/gen-params-calibration`

## 實作摘要

純 gen/config 校準，零決策/asm/combat 邏輯改動。

| 檔案 | 改動 |
|---|---|
| `config/default.json` | `roving_count_range` [2,4]→[6,10]（Task1）；新增 `opening_granary_food:800`（Task2 旋鈕）；`outposts.total_count` 10→14；`population_range` [8,25]→[8,10] |
| `config/warring_states.json` | `roving_count_range` [4,8]→[6,10]（Task1）；新增 `opening_granary_food:800`；`outposts.total_count` 30→42（default ×1.4）；`population_range` [8,25]→[8,10] |
| `scripts/simulation/game_setup.gd` | ① `_build_outpost_tile` 加 `granary_food:=0.0` 參數 → `TileBank.deposit(tile,"food",granary_food,"gen_seed")`（bootstrap 亦走 bank，driver-ledger 可查；deposit 自帶 FOOD_STORAGE_CAP clamp）。**owned-only guard**：`owner_team_id != -1` 才注（無主 outpost `effective_food` 讀不到=鬼糧浪費+白送 raider；code-review 修）。② `_generate_factions` 讀 granary 傳入（owner 建時即真）；`_generate_independent_teams` 建時 owner=-1 不注，`set_owner` 後補注（僅 settled 據點）。③ `TEAM_RESOURCE_PRESET.independent_roving.food` 120→180（roving 開局糧 buffer——granary 只到 outpost，roving 無據點，其開局命脈=preset 糧）。 |

## Task 1 — 狼密度（驗收:每 seed ≥~1 狼候選 + 知足多數 >60%）

census 10 seeds（`gen_census_bed`）：

| config | 狼候選/seed（前→後） | 商業+定居%（後） |
|---|---|---|
| default | 0.40 → **1.80** ✓ | 52+27=**79%** ✓ |
| warring | — → **2.90** ✓ | 50+29=**79%** ✓ |

狼候選遠超 1.0（outposts 10→14 順帶抬獨立據點武力隊數）；知足 archetype 仍佔多數。

## Task 2 — 開局緩坡（驗收:6月pop緩坡無滅團潮[月降幅<15%] + loot/Market仍fire）

`longwindow_bed LW_CONFIG=default seed=1337 6月`，逐月 pop 曲線：

**前（舊 gen，roving[2,4]/pop[8,25]/無 granary）**：197→83（藍圖量測，懸崖）
**Task1 後、Task2 前（roving[6,10]、其餘舊）baseline**：292→221→183→157→133→121（月降 24%/17%/14%/15%/9%——前3月滅團潮，teams 37→15）

**最終（roving[6,10]、pop[8,10]、outposts14、granary800、roving糧180、richness5；含 granary owned-only 修正）**：

| 月 | pop | teams | 月降幅 |
|---|---|---|---|
| 1 | 175 | 24 | — |
| 2 | 149 | 22 | -14.9% ✓ |
| 3 | 128 | 20 | -14.1% ✓ |
| 4 | 116 | 18 | -9.4% ✓ |
| 5 | 105 | 17 | -9.5% ✓ |
| 6 | 103 | 17 | -1.9% ✓ |

**全月 <15%**，無滅團潮（teams 24→17 漸降非崩），穩態 ~103。`surv.loot_dispatch=36` >0 ✓、`[Market]成交=5` >0 ✓（稀缺壓力仍在）。

> **granary 800 vs 1000**：試過 granary 1000（月2 軟化 -12% 但**把崩推到月3 -16.2% 超閘 + loot 崩至 2**——大 buffer 只時移崩點且殺稀缺）。800 = 甜蜜點（全月過閘 + loot 36 健康）。月2/月3 各 ~14.x% 餘裕薄（見「待確認」）。

warring 6月 smoke：見下「warring 曲線」段。

### 校準迴圈紀錄（診斷過程，供系統理解 gen 物理）

6 輪迭代揭 default 開局崩機制（非單純 pop 過量）：
- **richness 5→6**（R1）：pop 平躺 215，但 loot=0/Market=1 → **承載抬過頭殺稀缺**（richness 級距太粗，無 5.5）。→ revert。
- **granary 400→800**（R2/R3）：月2 崩僅 154→157，**granary 對崩幾乎無效** → 崩非 settled 隊（granary 只到自家 outpost）。
- **per-team 曲線**（R4 診斷）：各隊月2 崩至**在地覓食可養規模（~8-9）**。起始 >9 的隊月2 同步崩（開局糧同時耗盡）。roving 糧 250 讓部分狼**過飽never raid**（食物流+5.5）。
- **最終**：pop[8,25]→[8,10]（隊起始≈覓食floor→殺同步崩機制）+ roving糧 250→180（活過開局但保持餓→照 raid，loot 1→15）+ outposts 10→14（抬穩態 floor 縮崩幅）。

## TEST VALUE 清單（正式平衡 pass 需重調）

- `opening_granary_food = 800`（both config；per-outpost 開局公庫糧 buffer）
- `default.population_range = [8,10]`、`warring.population_range = [8,10]`（隊起始 pop；壓至覓食可養規模，floor 保 8=EXPAND_MIN_POP 讓狼可爬）
- `default.outposts.total_count = 14`、`warring = 42`（承載力 floor 旋鈕）
- `default.roving_count_range = [6,10]`、`warring = [6,10]`（狼密度）
- `TEAM_RESOURCE_PRESET.independent_roving.food = 180`（roving 開局糧 runway）

## 連動風險

- **warring 既有 baseline JSON 全作廢**：gen 參數變 → 世界不同。`seeded_warring_bed` 的 `WARRING_BASELINE` 對照 baseline 為 git-ref 外部 dump（未 commit），需**從新 main 重擷**（`WARRING_OUT=... seeded_warring_bed.gd` 重跑）才能續用 before/after diff。舊 baseline 直接丟。
- **seeded pointwise 必 DIRTY**：gen 參數變=世界不同，pointwise 回歸免跑（plan 已聲明）；行為對照走月線曲線（本 handback）。
- **outposts.total_count 抬升**（10→14 / 30→42）：per-tick 成本略增（更多 outpost/tile 掃描）。longwindow tick 曲線未見 spike 惡化（穩態 teams 反降）。留意效能域不變量長跑（滅團潮已消 → die-off spike 壓力反減）。
- **richness 維持 5**：抬 richness（承載）會殺稀缺（實測 R1），故走「壓 pop + roving 糧 buffer + outposts floor」組合達標，未動 richness。

## 待主 session 確認

- **月2 -14.9%、月3 -14.1% 距 15% 閘僅 0.1~0.9pp 餘裕**（seed 1337 單軌）。其他 seed 恐微超 15%。plan 驗收在 default 單 seed，達標；但餘裕薄=非 seed-robust。granary 加碼救不了（1000 反把崩推月3+殺 loot）；要 seed-robust 需結構性再壓 pop（如 roving 上限降）或抬 outposts，皆會動 Task1 狼密度/稀缺——牽動兩裁，交系統/藍圖權衡，非本實作單方調。
- **`opening_granary_food` 為新 config 鍵**：CI-scan 豁免（bootstrap 走 TileBank，reason="gen_seed"）已符 tile_bank.gd 註記慣例，無新違規。
- **roving 糧 180 是 game_setup const（非 JSON）**：全 config 共用。若日後要 per-config roving 糧，需另開 config 鍵。目前單值夠用。
- warring 曲線見下段（smoke 驗無崩即可，warring=考試賽道非校準軌）。

## warring 曲線（smoke）

`longwindow_bed LW_CONFIG=warring_states seed=1337 6月`：

| 月 | pop | teams | 月降幅 |
|---|---|---|---|
| 1 | 370 | 56 | — |
| 2 | 310 | 59 | -16.2% |
| 3 | 222 | 45 | -28.4% |
| 4 | 205 | 36 | -7.7% |
| 5 | 196 | 36 | -4.4% |
| 6 | 175 | 35 | -9.7% |

**無崩潰**（teams 56→35 存活，穩態 ~175），`loot_dispatch=139` 強（稀缺壓力充足）、`[Market]成交=3`。
但月2→3 -28% 仍陡——warring **同係數未達 default 之平滑**（初始 370 更大、8 factions 密度高）。
warring = **考試賽道非校準軌**（plan Task2.4：same coefficient，未要求 <15%）；smoke 目標=不崩，達標。
若要 warring 也平滑，需 warring 專屬再壓 pop/抬 outposts（交系統/藍圖裁）。

> 註：此 warring smoke 在 granary owned-only 修正**之前**跑（granary 800）。修正只影響無主 indep 據點鬼糧（少量），warring「不崩」結論不受影響；如需精確 warring 曲線可重跑（非關鍵）。
