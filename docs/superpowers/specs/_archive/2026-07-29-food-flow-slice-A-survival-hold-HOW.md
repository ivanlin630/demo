---
type: spec
owner: systems
topic: 糧流感知 SLICE A（存活持守，消費者①）HOW 架構
status: ready-for-R2
---

# HOW 架構 spec：糧流感知 SLICE A（存活持守 + safe_ratio×persist 講死）

> R① 收窄後（blueprint 規模誠實化 3 slice）：**SLICE A = 消費者①存活持守**，最小 + release 相關 + **根治 team14 nuance**（持守 release 暫緩那個「hold 撐 food=0 才放」）。當前 tile、inflow=harvest-only（打獵 EV 延後 B）。★persist×safe_ratio 交互**HOW 講死**（剛出過 world regression=PROGRESSIVE_HOLD attrition→0，R² 硬檢）。

## 1. scope（SLICE A only）
- **當前 tile 存活持守**：隊在當前位置的糧流 → safe_ratio → 調制 persist_strength（committed hold 該撐還是塌）。
- **inflow = 可持續 harvest-only**（自家 outpost tile 被動產+當前 tile 可持續採，★**延後打獵 EV 到 SLICE B**）。
- **不做**（延後）：打獵 EV 估算器（B）、假設 tile inflow 投影器（B）、遠征 ETA（B）、多 site 派遣閘（B）、在家前瞻（C）、人口 hook（排除，日 cadence 夠）。

## 2. 糧流感官（SLICE A 版，每隊）
- `net = inflow − burn`；`runway = 現有 food 存量 / max(−net, ε)`（net 負才有意義 runway；net 正=不缺糧 runway=∞）。
- **inflow = 可持續 harvest-only**：自家 outpost 被動產（resource_system:63-76 真 collection：outpost_mult×pop_mult×skill）+ 當前 tile 可持續採（非耗盡型）。★**內生-only**，外生（施捨/貿易/掠奪）不算（解「賭施捨/過去猜未來」）。
- **burn**：現成（resource_system:126 每日 cadence 結算 pop×FOOD_PER_PERSON）。
- **★每日算 1 次 + 快取**（非每 tick；接既有日 cadence，staleness≤1 日可接受）。存 `team.food_runway` 快取欄。

## 3. safe_ratio（只對有 ETA 的 progressive-hold task）
- `safe_ratio = runway / ETA_days`（撐得到完成否）。runway ≥ ETA → safe（做得完）；runway < ETA → 危（撐不到）。
- **★只對有真 ETA_days 的 task**：`TASK_BUILD`（persist_strength:51-61 `_progress()` 真 ticks ETA=`ticks_left/pop_per_tick`）。
- **★5 種無 ETA task（CONSTRUCT/UPGRADE/EXPAND/SETTLE/MIGRATE）排除 safe_ratio 調制**（它們只沉沒 proxy 無法反推「還要多久」）→ 走**原 persist_strength**（safe_ratio 不介入，維持 Slice 1-4 行為）。

## 4. ★persist × safe_ratio 交互（HOW 講死，R² 硬檢）
### (a) 調制公式形狀 = 乘法縮放（連續，非硬門檻塌）
```
persist_effective = persist_strength × safe_factor(safe_ratio, 人格)
```
★**選乘法縮放（連續）非硬門檻塌**——理由：PROGRESSIVE_HOLD 初版硬擋全 committed → attrition→0 向凍的 world regression 血證，**硬塌=向凍**；乘法連續降避免全體同時塌。
### (b) safe_factor（safe_ratio → [0,1]，人格餘裕）
```
safe_factor = clamp( (safe_ratio − ratio_floor(人格)) / (ratio_safe − ratio_floor(人格)) , 0, 1 )
```
- `safe_ratio ≥ ratio_safe`（糧充裕）→ factor=1 → persist 全維持（committed 黏著）。
- `safe_ratio ≤ ratio_floor`（糧見底）→ factor=0 → persist_effective=0 → 放手 committed 去求生。
- **★人格餘裕（team14 nuance 根治）**：`ratio_floor(人格)` 人格加權——**務實/機會人格 ratio_floor 高**（早放手、留安全餘裕）；**固執/恆心人格 ratio_floor 低**（撐到接近見底才放=edge-riding 戲保住）。team14「hold 撐 food=0」= 固執人格 ratio_floor≈0 的極端；務實人格 ratio_floor 高則提前放（解 nuance「無安全餘裕」，人格分化非全體撐到 0）。
### (c) 5 種無 ETA task：排除（走原 persist，safe_ratio 不調）
### (d) 抖動抑制
- safe_ratio 每日 cadence 算（非每 tick）＝天然抑抖。
- + safe_factor **hysteresis**（跨 ratio_floor/ratio_safe 用遲滯帶，避 runway 邊界震盪 → persist 抖）。

## 5. 憲法對齊
- **utility weigh 非 scripted**：safe_ratio 調 persist=util 權重，非寫死決策 edge。
- **人格 WEIGH 不 GATE**：人格調 ratio_floor=連續門檻位置，非硬類別閘（唯 safe_factor=0 見底放手是全人格通用求生地板）。
- **內生-only**：inflow 禁算外生（不預測施捨/貿易）。
- **非硬鎖（latch/regression 反例）**：乘法連續縮放、危機仍打斷、世界不凍。
- **★接 tap 全量觀測**：food_runway/safe_ratio/safe_factor/persist_effective 接 Probe tap（禁耗 RNG，feedback_observer_no_global_rng）。

## 6. 開放參數（TEST VALUE，量測調）
`ratio_safe`、`ratio_floor(人格)` mapping、hysteresis 帶寬。

## 7. TDD + 驗
- safe_ratio/safe_factor 公式單測（runway vs ETA、人格 ratio_floor 分化、乘法縮放、5 task 排除）。
- **★team14 nuance 根治驗**：務實人格隊 runway 下坡時**提前放手**（safe_ratio 到 ratio_floor 就塌、非撐 food=0）；固執人格隊撐久但**有人格餘裕差異**（非全體撐到 0）。
- **★★世界不凍**（latch/regression 反例，硬回歸）：specimen-off seed1337/42 teams/pop churn、attrition 兩者皆活（乘法縮放沒做出向凍）。
- 危機仍打斷（≥THREAT/CRISIS_FLOOR 在 persist 前，不受 safe_ratio 影響）。
- 閘：headless 0-new + gate 74 + determinism 3跑 byte-identical（觀測禁 RNG）。

## 8. 交付
→ R²（★硬檢 persist×safe_ratio 講死：乘法非硬塌避 regression、5 task 排除、人格餘裕分化、抖動抑制、世界不凍）→ implementer → measurer specimen-off（★用既有中性 SpecimenDumpHelper）→ QA team14 根治故事稽核。SLICE B/C 續。
