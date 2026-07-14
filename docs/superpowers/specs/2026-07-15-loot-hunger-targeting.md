# Spec：絕境掠奪對準糧源（hunger-weighted prey，殘留 thrash 真根）

status: draft（待 reviewer R② CLEAN → dispatch implementer）
owner: systems
premise_verified: 真根 file:line 坐實（yield 含 food / prey 主排序 pop_est）
blueprint_intent: `2026-07-15-blueprint-to-systems-loot-hunger-intent.md`（絕境掠奪該紓飢，patch-gate-first）
governing: `game-design.md §決策模型 v2`（慾望配現實：垂死隊掠奪慾望對準能解危機的糧）+ `invariants.md`（身分=權重非路徑切換 / 感知鐵律 / 全量觀測）

## 一句話（patch-gate-first 挖到底）
掠奪 yield **本就含 food**（`_loot_resources:552` 食在首位按比例搶）——**yield 不是根**。真根＝**target 選擇沒對準糧**：`_find_weakest_prey` 主排序 `pop_est`（最弱），`food_est` 只 tie-break → 絕境 looter 鎖**最弱**隊（常無糧）→ 搶到 material 無 food → 餓著再決策 → **殘留 thrash（貿易↔掠奪↔idle）+ 假救餓死**。修＝**飢餓 looter 的 prey 選擇 food-weighted**（鎖糧多可打的隊），de-patch 非補症狀。

## 真根坐實
- **yield 含 food（非根）**：`npc_combat_system.gd:550 _loot_resources`：`for res in ["food","material",...]: taken = loser.resources[res]*effective_loot`——food 首位按比例搶。target 有糧就搶得到。
- **target 選擇（真根）**：`_find_weakest_prey`（`faction_ai_system.gd`）：`pop_est` 最低為主序（beatability），`food_est` 僅 `PREY_POP_TIE_EPS` 帶內 tie-break。**絕境 looter 不優先糧多目標** → 鎖最弱（可能無糧）→ 搶到料不解飢。
- **殘留 thrash 機制**：掠奪(搶料還餓)→再決策→貿易(無賣方/coin 買不到)→idle→掠奪…（day24-26 56 次）。兩條求生路都不解飢＝震盪。掠奪對準糧→搶到糧解飢→不震盪。

## Fix：hunger-weighted prey（身分=權重，非路徑切換）
`_find_weakest_prey` 的排序改：**保 beatability 硬門檻（`pop_est < team.population×0.7` 不變，別打太強）**，但**在可打候選內，food_est 的權重隨 looter 飢餓（`food_days`）放大**：
- 概念：`prey_score = beatability_term − food_gap_penalty`，或雙鍵排序改**飢餓時 food_est 升為主序**：
  - looter **飢餓**（`food_days < DESPERATION`）→ 可打候選中**選 belief food_est 最高**者（對準糧；同 food 才 pop tie-break）。
  - looter **不飢餓**（食足，掠奪為財/人力）→ **現行 pop_est 最弱為主**（不變，strategic raid 要好打）。
  - **身分=權重（invariant）**：非「survival flag 切 finder」，是**food_est 權重 = f(飢餓度)**——飢餓連續放大 food 權重，sated→0（連續，非二分路徑）。implementer 挑乾淨實作（雙鍵飢餓切主序 / 連續加權分數）。
- **感知鐵律**：用 `bel.food_est`（belief `best_estimate`，可失真/stale），**非 god-view 讀 target 真 food**（`_find_weakest_prey` 已用 belief，延續）。
- **不加 food 硬濾**（血訓：`②c 刪 food<20 硬濾`，窮村仍可俘人力）——飢餓只**加權**food，不排除無糧目標（無糧目標當它是最後選項，非移除）。

## invariant 守
- **身分=權重非路徑切換**（藍圖 2026-07-03）：food 權重隨飢餓連續調，非按 survival 身分切 finder 路徑。
- **感知鐵律**：belief food_est，非 god-view。
- **慾望配現實**（決策模型 v2）：飢餓掠奪慾望對準糧＝正向落地。
- **determinism**：純確定性 belief 讀 + 排序，零 randf。
- **憲法**：不加行為判斷器；prey 選擇是既有 finder 內排序改，走引擎 rank 掠奪 option（無新 try_set 落點）。
- **全量觀測**：掠奪 target 選擇（specimen trace 的 做什麼.target）+ food-delta（snapshot food 升）逐筆可 trace；選配補「掠奪搶到 food 量」tap（implementer 判，food snapshot delta 已可推）。

## 驗收法（★中性世界，confound 已修，故事 QA）
1. **★殘留 thrash 消**：中性世界 day24-26 Team26 型 `貿易↔掠奪↔idle` 同快照 thrash → 歸零/趨零（掠奪對準糧→搶到糧→不再震盪）。
2. **★餓死 looter 得食**：絕境隊掠奪成功 → **food 真回升**（specimen trace：掠奪 winner→打贏→food delta>0）；連貫（搶不到糧才死，非搶到料卻餓死荒謬）。
3. **飢餓對準糧**：飢餓 looter 的掠奪 target＝belief food 高者（trace 驗）；不飢餓 looter 仍鎖最弱（strategic raid 不退化）。
4. **不回歸**：determinism byte-identical；憲法 sites 不變；A/B/A-2 不動；established/attrition 全-HD 定性不惡化。
5. **中性世界判**（confound 已修，擾動世界綠不認）。

## dispatch 註（R② CLEAN 後）
- 新分支 `feat/loot-hunger-targeting`，base 最新 main（含 desperation + confound）。
- R②：真根對嗎（target vs yield）？hunger-weight 是否守身分=權重（非路徑切換）？food_est belief 非 god-view？不誤傷 strategic raid（sated looter 仍最弱）？不加 food 硬濾（守 ②c 血訓）？
- 完成判定 = systems + reviewer/QA + measurer 中性世界重驗。implementer TDD：構「飢餓 looter + 弱但無糧 vs 稍強但糧多可打」斷言選糧多；「sated looter」斷言選最弱。
