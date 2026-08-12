# 军民混编 / 民兵動員 — 團型驅動的 mobilizable 分數（WHAT / vision）

status: DRAFT（pending R①[前提 grounding 已 file:line、驗新概念大框] + R²[大框、升異質框外審] → 鎖 → slice）
owner: blueprint（WHAT）→ systems 做 HOW
date: 2026-08-12
溯源：size-matter arc 維度②軍力/军民混编（audit 2026-08-03）→ 用戶「照路線圖一直做下去」啟動。grounding 表 `2026-08-12-...-junmin-militia-grounding-table`（硬讀 file:line）：三 ratio 各自為政 + 勞力池二元 + 團型二元 + **動員機制不存在（grep 零）**。

## §1 命門（統一非補丁 + genuine + 感知鐵律，寫死）
- **統一非補丁**：5 散落收進**一個模型**、禁再加平行補丁（armed_anon_ratio/guard_ratio/captive_guard_ratio/pool_of by-tag/團型二元）。
- **genuine 非死常數**：動員程度由真 threat + 團型 + 人格湧現、非 flat;guard_ratio 硬編碼離散死常數（0.1/0.15/…tag-gated）= **照妖鏡族連續化/人格化**。
- **★感知鐵律**：動員 trigger（威脅→動員）讀 **belief-threat**（`threat_assessment` belief 路、同 threat-oracle arc）、**非 god-view**（現 `_has_hostile_within` 掃真位置）。

## §2 核心：團型驅動的 mobilizable 分數（統一 5 散落）
- **一個 mobilizable 分數**取代三 ratio + 二元勞力 + 二元團型：每團有「可動員為戰力的人力比例」，由**團型上限 × 威脅 × 人格**決定。
- **★團型分級（非二元、梯度）**：
  - **專業軍團**（騎士/貴族兵）= 純軍、拒屯兵、不算勞力。
  - **後備/開墾團** = 屯兵、半兵半農、部分勞力。
  - **居民團** = 民兵制、主力勞力 + 小武裝比、防禦才召。
- **★guns-vs-butter 真成本**：威脅 → 民兵動員 → 人力從**勞力池抽去戰力** → 產出掉（真戰爭成本）;和平 → **解甲回田**（人力還勞力池、產出回）。= `pool_of` 從二元 by-tag 改**分數 membership**（表達半兵半農）。
- **人格 modulate**：好戰/責任 → 早動員/多動員;慎重 → 保守（怕掏空生產）;野心 → 擴軍。genuine 非死常數。

## §3 統一收編（audit 散落清單）
armed_anon_ratio（庫存推 equippability 保為裝備上限、非動員量）/ guard_ratio（照妖鏡:離散死常數→連續人格）/ captive_guard_ratio（既有連續、併同族）/ TAG_MILITARY·TAG_PRODUCE（二元→團型梯度）/ TASK_TRAIN（育成 tier、餵戰力品質、非動員量）。

## §4 前提（grounding 已 file:line 坐實）
- P1 三 ratio 各 owner 各規則互不通（armed_anon `equipment:62`/guard `faction_ai:3069`/captive `manpower`）。
- P2 pool_of 二元 by-tag（`labor:23`、無法表達民兵分數）。
- P3 團型二元建點定死（`outpost:401`）。
- P4 動員機制不存在（grep 零=全新建）。
- P5 guard_ratio 用 `_has_hostile_within` god-view（感知鐵律違、統一走 belief）。

## §5 量測（湧現、硬數據）
- **威脅→動員→產出掉**（guns-vs-butter 真成本可測）+ **和平→解甲→產出回**。
- **團型分化**：軍團純軍/居民團民兵防禦才召/開墾團半兵半農。
- **人格分化**：好戰早動員/慎重保守。
- **★感知鐵律**：動員讀 belief-threat（遠/敵 stale 反映）、無 god-view。
- 統一驗：三 ratio/二元勞力/二元團型 收進一模型、無平行補丁殘留（constitution）。determinism。
