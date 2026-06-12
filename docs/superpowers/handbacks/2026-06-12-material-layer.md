# Hand Back: B 期材料層

Plan: `docs/superpowers/plans/2026-06-12-material-layer.md`
Spec: `docs/superpowers/specs/2026-06-12-material-layer-design.md`
Branch: `feat/material-layer`（6 commits，未 merge）

## 實作摘要

| 檔案 | 變更 |
|---|---|
| `world_generator.gd` | herb 生成（forest 30% 2-6 / 藥草林 5% 10-20，入 resource_cap）；野馬草原 plains 3% 4-8 |
| `harvest_system.gd` | `_regen_herb`（月 +1 至 cap）；野馬再生 cap 富點 8；日捕改進 `public_storage["horses"]`，日上限 1 + stable_level（限 civilian） |
| `resource_system.gd` | PUBLIC_RESOURCES 加 horses；`_collect_from_tile` 排除 wild_horses（活物）；horses 草料 0.5 food/日（不限 pop） |
| `outpost_system.gd` | storage cap horses 同 mounts；stable `allowed_outpost` 加 military；`produce_stable_day` 重寫：military 限定 horses+草料→mounts 訓練，廢 civilian food→mounts |
| `manufacturing_system.gd` | wagons 配方（horses 1 + mat 6 + tools 1，工坊組）；新 `apothecary_level` 組（herb 2 → medicine）；TARGET_PER_POP 加 wagons/medicine/horses |
| `interaction_system.gd` | BASE_PRICE / TARGET_PER_POP 加 horses 15 / medicine 12 |
| `encounter_system.gd` | `apply_mount_loot` 加 horses 同公式 loot |
| `faction_ai_system.gd` | 選址多中心（leader + faction 全 outpost，任一 center dist 2-5）+ SITE_RES_BONUS（本格+鄰6格）+ `[Site]` 選址 log |
| `headless_test.gd` | 新增 Material Task1a–5c 測試 10 個；既有 mounts 日捕/stable 測試改 horses 語意 |
| `game_sim_multi.gd` | 加 `[MaterialStats]` 總量統計（驗收用） |

## 與 spec 的差異

- **野馬草原富點標記**：plan 寫「wild_horses 維持不入 cap」，但再生 cap 8 需要持久標記 → 用 `resource_cap["wild_horses"]=8`（僅 `_regen_wild_horses` 讀取；generic collect 已排除活物，無 leak）。一般野馬點不入 cap。
- wagons 未加 BASE_PRICE（plan 只要求 horses/medicine）→ wagons 目前不可貿易，待定價。

## 驗證

- headless_test：`=== DONE ===`，無 SCRIPT ERROR，全 assert 通過
- game_sim_test：`ALL INVARIANTS PASSED (violations=0)`
- game_sim_multi 4 配置（各數千 tick）無崩潰：
  - **coin 等值守恆 delta 0**（4 配置 0.00；tyrant 顯示 -0.00 = float 累加噪音 <0.005）
  - **horses 捕獲 > 0**：`[Horse] 捕野馬` ×12；MaterialStats horses = 1/1/9/1
  - **herb 採集 > 0**：game_sim_test 配置 herb 持有 6.5（herb 只能採集取得）
  - **選址落資源點旁**：`[Site]` ×578，周邊資源含 herb/wild_horses/ore_*（如 `選址 (7,3) score=217 周邊資源={ore_iron:146, ore_silver:106, herb:3}`）
  - **mounts 訓練 = 0 — 預期**：軍鎮三鏈（military outpost + stable + horses 公庫）模擬窗內未成形
  - medicine 場上總量來自配置 seed（`[Treat]` 有消耗）；apothecary 模擬窗內未被 NPC 蓋成 → 量產未觸發。wagons 0（居民團 horses 原料鏈未成形）

## 連動風險

- `_test_production_requires_resident` tile 改 military（stable 訓練限 military；mint 生產 gate 不看 type）— 已修
- 既有 mounts 日捕/stable 測試改 horses 語意 — 已修
- Treat（治療）系統消耗 medicine：apothecary 量產後治療強度會上升，平衡需觀察
- horses 草料 0.5/日新增 food 壓力：馬鎮（高捕獲點）food 消耗上升

## 待主 session 確認

- 生成率（herb 30%/5%、野馬草原 3%）與日捕率全為 TEST VALUE，正式需 tune
- 馬鎮 food 壓力觀察（spec 預期行為，需長窗模擬確認不致崩潰）
- wagons 定價 + 是否入貿易
- mounts 訓練鏈長窗驗證（需軍鎮 + stable 成形場景，建議後續加 scripted 驗證場景或延長模擬窗）
