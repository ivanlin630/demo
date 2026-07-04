# 設施改制 B 期（材料層：藥草 + 馬鏈）— Design

> 日期：2026-06-12
> 議題：A 期設施框架就位但兩條產線缺原料：藥坊 dormant（無 herb）、馬廄憑空生馬（food→mounts 魔法）。B 期補材料層：herb 圖塊 + 野馬→馴馬→戰馬鏈 + wagons 合成 + medicine 配方。

## 不變量

- 圖塊資源 = local 可觀察（地利評分既有接口 `_facility_terrain_fit` 直接吃新資源）
- 馬不憑空出現：戰馬 ← 馴馬 ← 野馬 ← 野馬群圖塊（全鏈守恆轉換）
- herb / horses / 馴化產物 = 可再生鏈，不碰有限資源守恆原則
- 速度加成只看「戰馬」（既有 mounts 欄位語意收窄，movement 邏輯不動）

## 1. 新圖塊資源

| 資源 | 生成 | 再生 |
|---|---|---|
| **herb（藥草）** | forest 30% tile 帶 2-6；**藥草林**（高產點）：forest 5% 帶 10-20 | 每月 +1（cap = 初始值），仿 wild_horses 模式 |
| **野馬群（wild_horses 擴充）** | 既有 plains 1% 1-2 不變；**野馬草原**（高產點）：plains 3% 帶 4-8 | 既有每月 5% +1，cap 由 3 → 富點 8 |

`world_generator._apply_resources` 加生成；`harvest_system` 加 `_regen_herb`（同 `_regen_wild_horses` 模式）。

herb 走標準採集（植物，`_collect_from_tile` 自然涵蓋）→ 居民團 `team.resources["herb"]`。
**順手修**：`_collect_from_tile` 排除 `wild_horses`（活物不該被 0.01 比例「採」成碎數 — 既有潛在 leak，audit 確認）。

## 2. 馬鏈（野馬 → 馴馬 → 戰馬）

新資源 `horses`（馴馬）。`mounts` 語意收窄 = **戰馬**（速度加成、騎兵）。

```
野馬群圖塊 --outpost 鄰格日捕--> public_storage["horses"]（改：原本進 "mounts"）
                                     ↓ 民用馬廄（馴化已含在捕獲，馬廄加速捕獲量）
horses + 草料 --軍用馬廄訓練--> mounts（戰馬）
horses 1 + material 6 + tools 1 --工坊配方--> wagons（馬車）
```

| 環節 | 改動 |
|---|---|
| 日捕 | `_collect_wild_horses_by_outposts` 產出改進 `public_storage["horses"]`；**有民用馬廄的 outpost 捕獲量 ×(1+stable_level)**（馬廄=馴馬設施），無馬廄每日最多 1 匹 |
| 軍用馬廄 | `stable` 的 `allowed_outpost` 改 `["civilian", "military"]`；產出按 outpost type 分流：civilian = 捕獲加成（上行）；military = `horses + 草料 → mounts`（產率沿用 0.3/0.7/1.0 匹/日，改吃 horses 庫存，無 horses 不產）|
| 馬車 | 工坊 RECIPE_GROUPS 加 `{ "out": "wagons", "in": { "horses": 1, "material": 6, "tools": 1 } }` |
| 草料 | horses 也吃 0.5 food/day（同 mounts，`get_effective_*` 不含 horses — 馴馬不拉速度）|
| PUBLIC_RESOURCES | 加 `"horses"`（公庫資源，storage cap 同 mounts 邏輯）|
| 戰利品 | mounts loot 既有；horses 加入同公式（kill_ratio 比例）|
| 既有 stable food→mounts 魔法 | **廢除** |

## 3. medicine 鏈

藥坊 RECIPE_GROUPS（A 期已建 group key `apothecary_level`，B 期填配方）：

```gdscript
"apothecary_level": [
    { "out": "medicine", "rate_const": "MEDICINE_RATE", "in": { "herb": 2.0 } },
],
```

地利已接：`_facility_terrain_fit` 藥坊「鄰格 herb > 0 → ×3」A 期寫好，B 期 herb 上線即活。

## 4. 地利評分連動（A 期接口直接吃）

- 馬廄 terrain_fit：「平原 + 鄰格 wild_horses ×3」既有 → 野馬草原高產點自然變馬鎮選址
- 藥坊：藥草林 → 藥鄉
- = 高產點圖塊 → 專業化村莊的地理錨點（A 期設計目的的材料面落地）

## 5. 選址改制：周邊常識 + 滾動拓殖

現況問題：`_evaluate_new_outpost_location` score 不看特殊資源（藥草林對選址 = 0 分）+ 只以 leader 所在為圓心。

| 改 | 內容 |
|---|---|
| **資源權重** | 候選格本格+鄰 6 格掃特殊資源加分：herb +30/格、wild_horses +25、ore_iron +20、ore_gold/silver +35（TEST VALUE）|
| **多中心評估** | 圓心從「leader 所在」改「faction 每個 outpost」（同 A 期設施評估範圍邏輯）|
| **dist 2-5 保留** | 「居住地周邊地理常識」— 非全知，住附近自然知道 |

湧現：**踏腳石拓殖鏈** — 蓋 A 村 → 從 A 村看到 5 格內藥草林 → 蓋 B 村 →… 勢力沿資源點滾動擴張，遠處富點要擴張過去才「發現」。行為上等效漸進探索，不開 tile 迷霧大坑（真迷霧歸「偵察+傳聞」future spec，known_issues 已記）。

## 測試

1. world_gen：herb 生成於 forest（30% 一般 / 5% 高產）；野馬草原 plains 3% 4-8
2. herb 月再生 +1 至 cap；wild_horses 富點 cap 8
3. `_collect_from_tile` 不採 wild_horses（排除清單）；herb 正常採進 team
4. 日捕產出進 `public_storage["horses"]`；無馬廄 cap 1/日；civilian stable Lv2 → ×3
5. 軍用馬廄：horses + 草料 → mounts；horses = 0 → 不產；civilian outpost 不跑訓練配方
6. 工坊 wagons 配方：horses/material/tools 扣帳正確
7. horses 吃草料 0.5/day；不進 speed 計算
8. 藥坊：herb 2 → medicine；無 herb 不產
9. mounts/horses 戰利品 loot 比例
10. 選址資源權重：候選格鄰藥草林 → score 顯著高於同條件無資源格
11. 多中心選址：非 leader 所在的 outpost 周邊富點也進候選
12. multi 90 天：herb 被採 > 0、horses 捕獲 > 0、（若軍鎮成形）mounts 訓練 > 0、藥坊建造 ≥ 0（地利出現即評分 > 0）、新據點選址落在資源點旁的比例

## 風險

- `public_storage["mounts"]` 既有存量（mount-public-storage spec 產物）語意變戰馬 — multi 重跑自然重建，無 migration 需求（無存檔系統）
- horses 草料 + mounts 草料雙重消耗 → 馬鎮 food 壓力大增，依賴農田/貿易（設計意圖，但貧窮線問題會放大）
- 軍用馬廄需軍屯居民（生產人力 gate）→ 戰馬產線成形依賴 residency + tools 鏈 + 軍屯三者就緒，90 天 multi 可能看不到 mounts 訓練（記預期）
- 高產點生成機率 / 再生率 / 捕獲率 全 TEST VALUE
- `stable` 雙態（civilian 捕獲加成 / military 訓練）同一 level key — 邏輯分流在產出函數，注意測試覆蓋兩態
