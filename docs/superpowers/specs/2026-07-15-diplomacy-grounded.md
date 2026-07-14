# Spec：求和/外交 grounded（look-before-leap + 求和 order_task seam，mirage 家族收尾）

status: draft（待 reviewer R② CLEAN → dispatch implementer）
owner: systems
premise_verified: seam + reject_cooldown file:line 坐實
blueprint_intent: `2026-07-15-blueprint-to-systems-grounded-diplomacy-drive.md`（社交 mirage 家族最後兩尾）
governing: `game-design.md §決策模型 v2`（慾望配現實）+ `invariants.md`（感知鐵律 / 身分=權重）

## 一句話
結構稽核揭 grounded-ness **只剩求和/外交兩尾未補**（社交/外交類=需對方同意才有效果，同買糧/併入 mirage）。修＝①**look-before-leap**（applicable 讀既存 `diplomacy_reject_cooldown`，被拒不再纏，鏡射 A-2）②**求和 order_task seam bug**（`_try_diplomacy` 硬寫 `propose_alliance` 丟棄 order_task→求和變求盟語意錯）。

## 真根坐實（patch-gate-first）
- **seam**：`interaction_system.gd:409-410 _try_diplomacy` → `handle_diplomacy_message(..., "propose_alliance")` **硬寫 action**，無視 `to_task` 傳的 `order_task=TRIBUTE_OFFER`（求和=向威脅源求和/納貢息兵）。∴ 求和實際送 propose_alliance（求盟），語意錯 + 與外交重複。
- **reject_cooldown 已存但 applicable 沒讀**：`_try_diplomacy:413`/`_send_diplomacy_message:179` 拒後寫 `initiator.diplomacy_reject_cooldown[target]`；但 `options.gd:136 外交` / `:160 求和` applicable **零讀此 cooldown** → 被拒後下 cadence 又選、又送、又被拒＝纏 loop（同 A-2 前的併入病）。

## Fix 1：look-before-leap（求和/外交 讀 reject_cooldown）
`decision_context.gd` gather：對求和 target（threat_id）/外交 target（faction_diplo_target），查 `team.diplomacy_reject_cooldown.get(target, 0)` 是否 > current_tick。加 flag（如 `diplo_target_on_cooldown`）。
- `options.gd:136 外交` applicable：加 `and not <外交 target on cooldown>`。
- `options.gd:160 求和` applicable：加 `and not <求和 target on cooldown>`。
- 效果：對象剛拒過→不入候選→fall through（迎戰/FLEE/其他）；cooldown 過期可再試（撲空 emergent 精神，非永久）。**honest**：讀自隊 cooldown 記憶（真發生的拒絕），非 god-view 猜對方意向。

## Fix 2：求和 order_task seam（求和走求和，非求盟）
`interaction_system.gd _try_diplomacy`：**依 order_task 路由 action**，非硬寫 propose_alliance：
- 求和（order_task=TRIBUTE_OFFER，跨 faction 向威脅源息兵）→ 送對應的**息兵/納貢求和** action 給 `handle_diplomacy_message`（非 propose_alliance）。
- 外交/結盟 directive → propose_alliance（現行）。
- **★implementer 先驗**：`handle_diplomacy_message` 的 `match action` 有沒有「求和/息兵/offer_tribute」case（現見 propose_alliance/demand_tribute…）。
  - **有** → `_try_diplomacy` 路由 order_task→該 action，求和真息兵。
  - **無**（求和無 resolver，等於一直是 mislabeled 求盟）→ **停下報 systems**：這是「求和是不是獨立行為 vs 該併外交」的 WHAT，flag blueprint（別自建新息兵機制或自刪求和，那超 grounded scope）。
- **不誤傷外交/結盟**（走 propose_alliance 那條不動）。

## invariant 守
- **感知鐵律**：look-before-leap 讀自隊 reject_cooldown 記憶（真拒絕），非 god-view 猜對方。
- **慾望配現實**：求和/外交做不成不當慾望目標＝正向落地。
- **determinism**：純讀 cooldown + 路由，零 randf。
- **憲法**：Fix1 加 applicable gate（無新 try_set）；Fix2 改既有 resolver 的 action 路由（無新 mutation site）。

## 驗收法（★中性世界，confound 已修，故事 QA）
1. **look-before-leap 生效**：求和/外交 target 在 reject_cooldown 內→specimen trace candidates **不出現**該 option；cooldown 過期才再入。被拒不再纏 loop。
2. **求和真息兵（非求盟）**：求和 winner→送息兵/求和 action（非 propose_alliance）；trace/log 見正確 action。（若 handler 缺→implementer 報 systems，本項待 blueprint）。
3. **不回歸**：determinism byte-identical；憲法 sites 不變；外交/結盟不誤傷；A/B/A-2/掠奪不動。
4. **中性世界判**（擾動世界綠不認）。

## dispatch 註（R② CLEAN 後）
- 新分支 `feat/diplomacy-grounded`，base 最新 main。
- R②：look-before-leap 讀 cooldown 對 target（求和=threat_id/外交=faction_diplo_target）鏡射正確？seam 路由是否真讓求和走求和（不誤傷結盟）？求和 handler 缺的 flag 路徑對？
- 完成判定 = systems + reviewer/QA + measurer 中性驗。implementer：Fix2 先驗 handler 存否，缺則 flag（不自建/不自刪，超 scope）。
