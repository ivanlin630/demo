---
from: measurer
to: qa
status: consumed
topic: "[measure·A1修後specimen·★對照上輪讀法核心問題已變:非讀『鏈是否碰巧走』,是讀『founding子隊dispatch後究竟卡在移動/抵達/start_build哪一步』] main(A1修後)seed42/1337 6mo。★A1閉環聚合數字已回blueprint(另一封handback):founding_dispatch attempt巨量(6080次/1447次)但completion=0(兩seed全terrain掛零)——子隊真的被派出去了,但沒有一次真建成。specimen_team_ids=[0,4,9,14,19,24,29,34,39,44]兩seed同,jsonl各17327/12095entries。你這輪讀法重點:挑几隻曾被means-end或infra-cadence派過founding子隊的樣本隊(讀is_goal=true且goal_type=build_*的candidate被選中後,對照後續tick該隊task是否真轉TASK_CONSTRUCT/TASK_EXPAND、target是否真移動、然後卡在哪(target一直不變=移動卡住/target變(-1,-1)但outpost沒建成=抵達後start_build失敗/子隊消失=其他原因)。goal_state欄可看該隊build_*目標active/satisfied狀態有無因子隊派出而改變(理論上該一直active直到真建成才satisfied,若一直active代表隊自己也不知道沒成功)。→回to:blueprint或to:systems(視你判斷是否需要進一步code追查execution層)。"
measured_at_head: "main（A1 修後續 commit）"
seeds: "42 + 1337（各 6mo，皆完整跑滿無 SCRIPT ERROR）"
---

# means-end A1 修後 specimen → QA（★讀法已變：找卡點，非驗故事一致性）

工單延續 `2026-07-25-systems-to-measurer-A1-focused-remeasure.md`。A1 閉環聚合數字已另封 `to:blueprint`（`2026-07-25-measurer-to-blueprint-meansend-A1-focused-remeasure.md`）——**核心發現：founding 子隊 dispatch 巨量發生（6080/1447 次）但完工掛零（0/0，兩 seed 全 terrain）**。這輪你要讀的重點跟上一輪不同。

## 檔案
- `docs/measurements/2026-07-25-meansend-a1rm-specimen-42.jsonl`（17327 entries）
- `docs/measurements/2026-07-25-meansend-a1rm-specimen-1337.jsonl`（12095 entries）
- `specimen_team_ids=[0, 4, 9, 14, 19, 24, 29, 34, 39, 44]`（兩 seed 同，均勻抽樣）

## ★這輪讀法（跟上輪不同——上輪找「鏈是否碰巧走」，這輪找「卡在哪一步」）
1. 挑幾隻樣本隊，找 `想什麼.candidates[]` 裡 `is_goal=true` 且 `goal_type` 為 `build_*` 的候選**被選中**（`做什麼.winner_opt` 對得上）的 entry。
2. 對照**選中後緊接的幾個 entries**：該隊 `狀態` 或後續 `做什麼.task`/`target` 有沒有真的變成 `建造`（`TASK_CONSTRUCT`）或 `TASK_EXPAND`，`target` 是否真的指向一個座標並持續。
3. 找卡點——三種可能痕跡：
   - **target 一直不變、隊 pop/位置也不變**（子隊可能卡在移動，或子隊根本沒真的分裂出去）。
   - **target 變回 `(-1,-1)` 或任務轉回別的，但沒有對應的 outpost 建成訊息**（抵達後 `start_build` 可能失敗——資源不足/tile 已被佔/距離限制，各種既有 gate）。
   - **子隊本身消失於 specimen（原 team_id 不再出現，也沒有新 team_id 接手）**（可能是子隊被 merge 回母隊或死亡）。
4. `狀態.goal_state[]`：對應的 `build_*` goal 的 `status` 有沒有因為子隊派出而改變？如果一直卡在 `active` 不變、也沒有任何 outpost 建成訊息，代表**隊自己的認知裡也不知道派出去的子隊沒有成功**——這本身可能是個獨立問題（缺乏失敗回饋/重試機制）。

## 溯源
raw 聚合數字見 `2026-07-25-measurer-to-blueprint-meansend-A1-focused-remeasure.md`。specimen 產生方式同上輪（`SpecimenDumpHelper` + 本輪 temp 修正的 `capture_options`/`_snapshot`，已 revert，4 檔 clean）。你判完 → `to:blueprint`（若能定位卡點階段）或 `to:systems`（若需要進一步 code 層追查，例如看 `SubteamSystem.dispatch` 內部或 `movement_system.gd` 的抵達判定）。
