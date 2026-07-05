# Hand Back: TimeScale 骨架 + ×5→1（time-scale wave slice A）

> spec：`docs/superpowers/specs/2026-07-05-timescale-skeleton-design.md`
> branch：`feat/timescale-skeleton`（base origin/main b71d54e）

## 實作摘要
- **新 `scripts/simulation/time_scale.gd`**：`class_name TimeScale` 時間量單一權威源。
  - `TICK_PER_DAY`←`WorldState.TICKS_PER_DAY`、`BASE_ACTION_TICKS`/`ENCOUNTER_MAP_SCALE`←`EncounterSystem`（承既有根）。
  - `MOVE_TICKS_PER_HEX = BASE_ACTION_TICKS × ENCOUNTER_MAP_SCALE = 240`（錨①連動）。`days(n)`/`hours(n)` 語意 helper。
- **`movement_system.gd`**：刪 `WORLD_SPEED_MULT`（÷5 拿掉）；`BASE_MOVE_TICKS = TimeScale.MOVE_TICKS_PER_HEX`（唯一讀站走連動式）。`MIN/MAX_MOVE_TICKS`（÷3/×3=80/720）自動跟。
- **`docs/invariants.md`**：`## Time` 下加「TimeScale 骨架三不變量」family（時間量導出/移動連動/語意單位）+ 錨①②⑤ + enforce 進度標記。
- **`headless_test.gd`**：TimeConstants 段加 8 條 TimeScale assert（連動/240/唯一讀站/helper）；`_test_eta_ticks` 240→1200（BASE_MOVE 48→240）。
- **`docs/tick_parameters.md` / `docs/progress.md`**：移動速度表/系統表反映 240/hex + WORLD_SPEED_MULT 刪除（避免 stale 假象）。

### 與 spec 差異
- **依賴方向裁定**：spec 給二擇一（world_state/encounter re-export ← TimeScale，或 TimeScale ← 既有根）。**選後者**（TimeScale 承既有根，單向 TimeScale→{WorldState,EncounterSystem}）——零 re-export、零 world_state/encounter 改動、無循環、無雙源 drift。既有 `WorldState.TICKS_PER_DAY`/`EncounterSystem.*` 全域引用零動。
- **`ENCOUNTER_MAP_SCALE` 承 `EncounterSystem.MAP_DIAMETER`**（=MAP_RADIUS×2=24），非另塞字面 24 → 遭遇戰地圖幾何單一源。

## 驗收證據
1. headless `=== DONE ===`、無 SCRIPT ERROR、`TimeConstants OK … MOVE/hex=240`（8 條 time assert 過）。
2. framework `PASS=7 DORMANT=0`；coin_eq delta=0.00（4 config：game_sim_test/tyrant/merchant/warzone）。
3. `WORLD_SPEED_MULT` grep 於 `scripts/` 零殘。
4. lod_perf_bed 跑到底（warring_states LOD，day 60，無崩）。
5. **seeded final 必變（移速 5× 慢=預期）**，量級未崩到全滅：

| config | before(48/hex) teams/persons/pop_final | after(240/hex) teams/persons/pop_final |
|---|---|---|
| game_sim_test | 11 / 23 / 56 | 2 / 28 / 4 |
| tyrant | 11 / 22 / 64 | 15 / 19 / 76 |
| merchant | 11 / 12 / 51（game_over @850t） | 11 / 12 / 52 |
| warzone | 7 / 29 / 33 | 10 / 36 / 41 |

- game_sim_test after 收斂到 2 隊 / anon-pop 4（named 28 存活、跑滿 21600t，非全滅）；merchant 由 before 早期 game_over 變 after 存活。皆屬移速劇變下的 emergence 重排，非崩潰。

## 連動風險（待主 session 裁）
- **④後勤糧耗**：跨格旅途 5× 長 → `FOOD_PER_PERSON/MOUNT_PER_DAY` per-day 率未動（本 slice 留原值，spec 指定），但**單趟跨格總糧耗 5× 增**。game_sim_test after 的 anon-pop 崩到 4 可能即此壓力早期顯化 → **④ measure 首要對象**，補給/carry 機制校準前勿當平衡定論。
- **path ETA / founding·trade timeout**：導出者（`path_system:154/207`、`faction_ai` founding timeout 距離估）自動跟 BASE_MOVE=240，**無手改**；但絕對 timeout 天數（如 CONSTRUCT_TRANSIT_TIMEOUT=10天）現對應 hex 距離縮 5× → 遠程建造/使節可能逾時率升 = ③cadence slice B / ④ 一併重校對象。
- **gen 重校**：世界生成間距/初始佈局按舊 48/hex 隱含節奏，240/hex 下跨格互動頻率降 → spec 列後續 slice（gen 重校照 240/hex）。
- **AI_ETA_LIMIT=1200 tick**：現 =5 hex plains（was 25 hex），AI 追擊/catch-up 可達範圍縮 → 若顯行為退化，屬 timeout 天數重校範疇（非本 slice）。

## 待主 session 確認
- **依賴方向**（TimeScale 承既有根 vs re-export）已裁「承既有根」，如系統偏好 TimeScale 為字面權威 + world_state/encounter re-export，可後續調（但需處理循環）。
- **docs/progress.md 屬系統 owner**：本 slice 為避免 stale 假象順手改了移動/path 兩行，請確認或回退。
- 後續 slice 依賴此：**B cadence 語意化**（720/360/240 裸字面→TimeScale.days）、**④後勤 measure**、**C CI 掃裸 tick/倍率**、**gen 重校 + R7 全環對照 + QA 重跑**。
