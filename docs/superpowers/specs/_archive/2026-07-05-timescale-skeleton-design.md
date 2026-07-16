# TimeScale 骨架 + ×5→1（time-scale wave slice A）— Design

> 藍圖 `2026-07-05-time-skeleton-anchors` 5 錨。稽核全表 `specs/2026-07-05-time-constant-audit.md`。
> **本 slice = 骨架 + 移動連動 + ×5→1 + 3 時間不變量**。cadence 語意化(③)/後勤(④)/CI/gen 重校=後續 slice。
> ⚠ **行為大變**：移動 48→240 tick/hex（5× 慢）→ 世界節奏劇變、跨格物流糧耗 5×。seeded hash 必變、gen 需重校（後續）、④後勤 measure 併跑。**藍圖已明示骨架先動、④並行**。

## 錨（藍圖定，釘死）
- ① 移動 1 world-hex = `BASE_ACTION_TICKS(10) × ENCOUNTER_MAP_SCALE(24) = 240 tick = 1 天`。×5 拿掉。= invariant #2 錨，禁再塞倍率。
- ② 遭遇戰地圖尺度 = 24（不變）。
- ⑤ 觀看組（TICKS_PER_SECOND/TURN/DUMP/SECONDS 橋）不動——倍速靠 GUI 不碰物理。

## Task 1 — TimeScale 單源類（新 `scripts/simulation/time_scale.gd`）

`class_name TimeScale`，全 static const，**時間量唯一權威源**：
```
TICK_PER_DAY = 240              # 根（承 world_state，或 world_state 改引 TimeScale）
BASE_ACTION_TICKS = 10          # 遭遇戰動作粒度（第二根，承 encounter）
ENCOUNTER_MAP_SCALE = 24        # 錨②
MOVE_TICKS_PER_HEX = BASE_ACTION_TICKS * ENCOUNTER_MAP_SCALE   # = 240 錨①（連動,非獨立塞）
# 語意天數 helper：
static func days(n) -> int: return n * TICK_PER_DAY
static func hours(n) -> int: return n * TICK_PER_DAY / 24
```
- `world_state.gd` 的 `TICKS_PER_*` 家族**保留為 re-export**（`const TICKS_PER_DAY = TimeScale.TICK_PER_DAY`）避免全域改引用爆炸；新碼一律用 TimeScale。或 TimeScale 引 world_state（擇一單向，避免循環）——實作定方向，釘「單一權威」。

## Task 2 — ×5→1（移動連動還原）

- **刪 `WORLD_SPEED_MULT`**（movement:4）+ 唯一讀站（`BASE_MOVE_TICKS` 導出式）改 `BASE_MOVE_TICKS = TimeScale.MOVE_TICKS_PER_HEX`(=240)。
- `MIN/MAX_MOVE_TICKS`（÷3/×3=80/720）連動自動跟。
- **下游自動跟（導出者，免手改）**：path ETA（path_system:154/207 ×BASE_MOVE）、founding/trade timeout 距離估。
- **手校痕跡下游（本 slice 不改，標記給④/gen）**：`FOOD_PER_PERSON/MOUNT_PER_DAY`(÷24 痕)、`FATIGUE_*_PER_DAY`(×24 痕)——per-day 率本身不因移速變，但**跨格旅途糧耗 5× 增**=④後勤 measure 對象。本 slice 留原值，④數據回來配補給機制一起校。

## Task 3 — 3 時間不變量入 `invariants.md`（新 family，同意圖/belief/state）

```
凡時間量      必從 TimeScale 骨架導出（禁裸硬編 tick）
凡移動        大地圖格 = 遭遇戰動作 × 遭遇戰地圖尺度（連動,不准倍率打破）  ← 錨①②
凡延遲/timeout/cadence  以語意單位（TimeScale.days(N)/hours(N)，非裸 720）
```
- 標「enforce 起步」（本 slice 立骨架+移動連動；cadence 裸字面收編=slice B；CI 掃=slice C）。
- headless `_test` 時間不變式 assert（`headless_test:3362-3376`）對齊新骨架（MOVE_TICKS_PER_HEX=240 等）。

## 硬約束
- 觀看組（⑤）零改。
- world_state `TICKS_PER_*` 語意不變（240/天等）——本 slice 只動**移動格耗**（48→240）+ 立 TimeScale 單源，不動 cadence/後勤數值（那些 slice B/④）。
- 移動連動：`MOVE_TICKS_PER_HEX` 只能是 `BASE_ACTION×MAP_SCALE`，禁另塞係數（invariant #2）。

## 驗收
1. headless 無 SCRIPT ERROR + DONE；時間不變式 assert 過（對齊 240/hex）。
2. **seeded hash 必變（移速 5× 慢=預期）**——附前後 final 摘要（teams/factions/pop 量級；**預期跨格物流變差、可能糧壓**=④ measure 對象，非本 slice fail 條件，但量級不可崩到全滅）。
3. framework PASS=7；coin_eq delta=0（守恆不受時間影響）。
4. `WORLD_SPEED_MULT` grep 零殘（全刪）；`MOVE_TICKS_PER_HEX` 走 TimeScale 連動式。
5. lod_perf_bed 可跑（移速變不影響 perf 儀器）。

## 檔案 scope
新：`scripts/simulation/time_scale.gd`。
改：`movement_system.gd`（刪 WORLD_SPEED_MULT+BASE_MOVE 走 TimeScale）、`world_state.gd`（TICKS_PER_* re-export or TimeScale 引它，定單向）、`encounter_system.gd`（BASE_ACTION_TICKS/MAP_SCALE 若移入 TimeScale 則 re-export）、`invariants.md`（3 不變量）、`headless_test.gd`（assert 對齊）。
**勿碰**：cadence 常數值（slice B）、FOOD/FATIGUE 值（④/gen）、觀看組、interaction/faction 決策邏輯。

## 後續 slice（本 spec 不含，依賴此）
- **B cadence 語意化**（③框架：戰略天/戰術時/反應事件/行軍降天級+事件；裸 720/360/240→TimeScale.days）。
- **④後勤帳 measure**（併三平行 measure，數據回藍圖裁補給）→ 食物/carry 機制。
- **C CI 掃裸 tick/倍率 + checklist**。
- **gen 重校**（照 240/hex）+ R7 全環對照 + QA 充足性重跑。
