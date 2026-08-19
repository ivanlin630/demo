# settlement §4b：三動機 + 擴張建點純邊際帳 + overflow 決策化（HOW / systems）

status: DRAFT→R²delta（2026-08-20）
owner: systems（HOW）← §4 WHAT 補定①②③（blueprint）+ §4 HOW `2026-08-20-settlement-S4-strategic-siting-HOW.md` §2/§5
前置：**§4a MERGED `f003ebe5`**（紮根入引擎、de-scaffold 77→75、commit-priority 解耦契約入 invariants）。

## §0 命門
- **★零新旋鈕**（WHAT 補定①）：擴張訊號**只讀既有** `ctx.idle_labor` / `MarginalEconomy._inflow_est` / farming 頂格 / 倉飽和 / 既有 `_dispatch_builder` 守衛。**唯一容許的新常數**=`POP_OVERFLOW_MARGIN`（機械保底門檻、TEST VALUE、R² 判 margin 優於純 delay）。
- **★執行面全複用**：`_evaluate_new_outpost_location`(faction_ai:4058、選址評分含離敵距離+`_last_site_sig` 去抖) + `_dispatch_builder`(:3617、派子隊施工、goal_resolver A1 既有 consumer)。**不新造 founding 路**。
- **感知鐵律**：候選地評估**沿用既有選址評分的 belief 語意**（terrain/地形=公共知識合法；「那裡有沒有別人」走既有 belief-filtered 路）、**不新增 god-view 讀取**。
- **禁硬門檻回潮**：擴張與否由 util（邊際帳）決定；applicable 只留物理可行性。
- **★commit priority 契約**（§4a 立 invariants）：擴點=**發展型**動作 → `priority` 欄標 `PRIO_DISPATCH`（可被 threat/survival 打斷）+ why-comment。

## §1 現況（grounded）
- **三動機現況**：①求生建家=`紮營`(L0、applicable **`not has_own_outpost`**)+`紮根`(L0→L1、§4a) 已在引擎；**②擴張建點=缺**（`紮營` 被 `not has_own_outpost` 擋死=**有家隊無法開第二據點**、size-matter arc 早記的 spread gap）；③軍事=不建（WHAT 補定②）。
- **執行面既有**：`_evaluate_new_outpost_location`→回 `{pos, score…}`；`_dispatch_builder(state, leader_team, pos, type, level)` 派子隊；`faction_ai:4307-4312` 已有「評估→派」既有樣板（獨立戰略層路）。
- **邊際量既有**：`ctx.idle_labor`(decision_context:37/229=`pool_of − Σdemand-cap`、只 PRODUCE)；`MarginalEconomy._inflow_est(est)`(marginal_economy:15、只吃 `VillageEstimate` struct=god-view 結構防線)；`VillageEstimate` 欄=terrain/outpost_level/farming_level/pop/harvest_factor/prod_skill/food_est。
- **overflow 機械源**：`population_system.check_overflow_for_team`(:24-41)=**無條件**（`overflow = population − cap > 0` 即 advisor 帶走 or `_create_overflow_team`）。

## §2 Task
### T1 新 engine option「擴點」（=②擴張動機、純邊際帳）
- **applicable（只物理可行性）**：`has_own_outpost`（有家）+ `_evaluate_new_outpost_location` 回有效 pos + 母隊 pop 足以派子隊（**沿用 `_dispatch_builder` 既有守衛/門檻、不新增**）+ 非玩家。
- **util=邊際帳（零新旋鈕）**：
  - **家內邊際**（再投一單位勞力的產出）：`ctx.idle_labor` 高 ⇒ 家內邊際 ≈0（閒勞力=沒地方用）；輔以家 tile `_inflow_est(家 est)` 的頂格程度（farming/facility 已滿→追加勞力無處去）。
  - **分點期望邊際**：`MarginalEconomy._inflow_est(候選地 est)`——`VillageEstimate` 由候選 tile 地理（terrain/harvest_factor）+ 擬派 settler 數（`_dispatch_builder` 既有配額）構造。
  - **建置成本**：母隊被抽走的 settler 產能（=settler 數 × 家內每手邊際）+ 工期期間分點零產出（既有 construction ticks）。
  - **`util ∝ max(0, 分點期望邊際 − 建置成本 − 家內邊際)`**；人格只 **modulate 既有權重**（野心/慎重、非另加線）。
- **to_task=delegate 既有路**：回 `{delegate:true, build_type, target:pos, settler:…}`（比照 goal_resolver `_mk_delegate_candidate` / faction_ai:3869 既有 `build_type` 分支）→ 由既有 `_dispatch_builder` 執行。**★zombie 教訓沿用**：任何世界寫入只在 try_set 成功後（§4a `_commit_settle_site` 同款；若 delegate 路本身在 dispatch 內寫則沿用既有、不新增 to_task 副作用）。
- **`priority`=`PRIO_DISPATCH`** + why-comment（§4a invariants 契約）。

### T2 overflow 決策化（margin-based 保底、碎裂機械源降級）
- `check_overflow_for_team` 觸發條件由 `population > cap` 改 **`population > cap × POP_OVERFLOW_MARGIN`**（TEST VALUE **1.15**）。
- 語意：**小超額留給決策層**（擴點 util 隨 `idle_labor`/cap 壓力升→主動開分點=有計畫擴張）；**只有滾到顯著超額**（決策層明顯沒接住）才機械介入；margin 隨 population 成長**最終必觸發**=無「決策永遠沒接住」死角（R² 判優於純時間 delay：純 delay 與溢出量級無關）。
- **不刪機械保底**（避免 pop 卡 cap 無出口）。

### T3 ③軍事要地=佔位不建（WHAT 補定②）
本 arc 不建 military-siting；既有選址評分已含離敵距離、不另加。

## §3 gate（measurer bounded）
1. **三動機分化 fire + bounded**：**無家團才建家**（紮營/紮根）、**倉/勞力飽和團才擴張**（擴點）；無家團不 fire 擴點、飽和團不亂建。
2. **★`overflow_split` 機械觸發 → 0**（決策化生效、保底未被觸發）+ **pop 不卡 cap**（保底仍在、極端情境仍 fire）。
3. **邊際帳零新常數**（code-read 驗：只有 `POP_OVERFLOW_MARGIN` 一個新 TEST VALUE）。
4. **★§4a deferred empirical（併本輪）**：①瀕餓 **isolated 邊界**（無 join host/無 forage tile）是否仍低 util 選紮根**餓死在工地** ②**壓境頻繁區**紮根隊的中斷-續建循環次數/平均完工時長 **vs 無威脅區**同款隊。
5. determinism（純算術）、constitution 75 不回升、headless 0-new、fp intended-change 標。

## §4 界外
§4c 反饋迴路（`site_failed`/`site_thrived` memory + `SITE_MEMORY_TTL_DAYS` 30 天線性衰減）=下一 slice（spec 已定公式、見 §4 HOW §5）。軍事選址本體/長程計劃脊椎=next arc。

序：R² delta → CLEAN → dispatch → gate（含 §4a deferred empirical）→ merge → §4c。地基 KEEP。
