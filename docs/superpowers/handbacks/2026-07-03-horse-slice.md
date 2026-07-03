# Hand Back: 馬經濟最小 slice

> Plan `docs/superpowers/plans/2026-07-03-horse-slice.md` / Spec §B。branch `feat/horse-slice`。

## 實作摘要

消費端全在（movement 騎乘/速度/carry、encounter loot、`_equip_envoy_mounts`、`_auto_withdraw_mounts`、`_absorb_public_storage` 貿易接入）但世界 mounts=0 全 dormant。本 slice 建**可靠來源**喚醒。

- **`scripts/simulation/world_generator.gd`** — 產馬帶：`_apply_horse_band()` 在 per-tile rng 流之後 draw（不擾既有 seeded 期望），挑一條 `tile_pos.x` 帶（seeded），帶內 plains 依 `HORSE_BAND_DENSITY` 撒 `resource_cap["mounts"]`（集中成帶=戰略不對稱,非均撒）。保底一格。另撒「一般」`wild_horses`(1-3,<4 非富點,不入 `resource_cap`)= 純 AI 建廄誘因訊號（faction_ai stable 需求偏好讀 `_nearby_resource(wild_horses)>0`）。
- **`scripts/simulation/outpost_system.gd`** — `produce_stable_day` 拆兩路互斥 by tile：產馬帶(`resource_cap["mounts"]>0`)= 良質牧地 `_breed_stable_mounts`（直接繁育,不需捕獲 horses,含 civilian ranch）；否則 military = `_train_stable_mounts`（舊路徑,公庫 horses→mounts,原碼原樣抽函數）。皆入公庫、耗草料(守恆錨)。**僅動此函數,佔村軌同檔他函數未碰。**
- **`scripts/simulation/order_system.gd`** — `mounts` 入 `_ORDER_ELIGIBLE_RES` → 賣盤/套利泛用鏈承載（`local_value` 45 pre-existing in trade_valuation）。
- **`scripts/debug/headless_test.gd`** — +3 test：產馬帶生成集中(Task1)、繁育不需 horses(Task2)、mounts 貿易一單流通守恆(Task3)。
- **`scripts/debug/horse_slice_proof.gd`**（新增 debug）— deterministic 源證明。

## 驗證證據

**deterministic 源證明**（`horse_slice_proof.gd`,warring_states seed 1337）：
```
產馬帶 tiles=45
30 天 stable 繁育 → 公庫 mounts=30（breed path,無 horses）
owner 出征 auto-withdraw → resources mounts=10（pop20×0.5）
envoy 無馬 speed=0.70 → 全騎乘 speed=2.07（×2.96 ≈ 3× 信使速）✓
ALL PASS
```

**回歸閘**：
- headless：`=== DONE ===`,全 HorseSlice test OK,唯 1 pre-existing `[FAIL] 使用目標未加入戰略 goal`(與馬無關,plan 容忍)。
- framework_validation：**7/7 PASS DORMANT=0**。
- game_sim_multi：4 config `coin_eq delta=0.00`（守恆乾淨;mounts 非 coin 池,同 ore 採集產出非守恆）。

**emergent longwindow**（warring_states seed 1337, 6mo）：
- 世界 mounts>0 ✓（AI 建 stable → `[Stable] Outpost(4,12) 訓練戰馬 +1`）。
- 產馬帶 breed 湧現：初跑帶無 wild_horses → AI 無誘因、stable 落非帶 → breed 未湧現。**已補建廄誘因訊號**後複跑確認（見下 TEST VALUE / 待確認）。

## TEST VALUE 清單（正式平衡待調）

| 常數 | 檔 | 值 |
|---|---|---|
| `HORSE_BAND_HALF_WIDTH` | world_generator | 2 |
| `HORSE_BAND_DENSITY` | world_generator | 0.55 |
| `HORSE_BAND_CAP_MIN/MAX` | world_generator | 6 / 12 |
| `HORSE_BAND_SIGNAL_WILD_MIN/MAX` | world_generator | 1 / 3 |
| `STABLE_BREED_PER_DAY` | outpost_system | [0.5, 1.1, 2.2] |

## 連動風險

- **誘因結盟軌（裁2,faction_ai `_dispatch_envoy`/diplomatic/interaction）**：envoy timeout 降 = 本軌(馬源)×該軌(envoy dispatch) 複合。本 slice 只證 envoy **配馬即 ×2.96 速**（deterministic）；「default 跑 envoy timeout 前後對照」需兩軌整合後量（該軌未 merge 於此 branch）。無檔案衝突（本軌未碰 faction_ai/diplomatic/interaction）。
- **佔村軌（同 `outpost_system.gd`）**：僅動 `produce_stable_day`+新增兩私有 `_breed/_train_stable_mounts`;未碰佔村函數。merge 時注意同檔但不同函數。
- **harvest_system**（未碰,他人所有）：帶內「一般」wild_horses 走既有 `_regen_wild_horses`(cap 3)/鄰格捕獲鏈 = 附帶餵鄰隊 horses,預期行為。

## 待主 session 確認

1. **建廄誘因訊號手法**：帶撒 wild_horses(1-3) 純為驅 AI（faction_ai:2841 讀 wild_horses）。更乾淨=擴 faction_ai stable 偏好直讀 `resource_cap["mounts"]`（1 行,但屬他軌檔）→ 若系統要,可退掉訊號 wild_horses、改該處。現法零跨軌檔改。
2. **breed 湧現複跑結果**：lw6b（補訊號後）跑完數字補回本檔（若仍未湧現,建議 scenario config 於帶內預置 stable outpost 保底,或調 density/AI 偏好權重）。
3. `horse_slice_proof.gd` 去留（deterministic 源回歸證,可留作閘或清掉）。
