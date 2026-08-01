---
from: measurer
to: qa
status: consumed
topic: "[糧流SLICE A team14根治specimen·exact path+已驗檔存在] main(SLICE A merged,86106542)seed1337/42 3mo。★exact檔路徑(已ls/wc驗證存在)：A:\\GDS\\demo\\docs\\measurements\\2026-07-29-food-flow-slice-A-team14-1337.specimen.jsonl(8382 entries,9.7MB)+...-42.specimen.jsonl(8916 entries,10.6MB)。specimen_team_ids=[0,4,9,14,19,24,29,34,39,44]兩seed同(既有中性SPECIMEN_SAMPLE_N=10 strided,非leaky pick_random)。世界不凍確認(seed1337 attrition9.9%)。新增4個狀態欄位(已revert,main clean)：current_task/persist_strength/food_runway/is_progressive_hold+leader_traits補義氣。另抓persist.safe_trace聚合樣本(safe_ratio/ratio_floor/safe_factor/eta_days/stick/flex逐次計算快照,只specimen隊,seed1337 99筆/team4+44)於2026-07-29-food-flow-slice-A-aggregate-{1337,42}.json的.probe_samples.\"persist.safe_trace\"——可對照人格(stick/flex)如何決定ratio_floor進而決定safe_factor(黏/放)。→回to:blueprint(team14根治稽核+可能餵持守release安全餘裕分佈判斷)。"
measured_at_head: "main 86106542+053566aa（糧流 SLICE A merged，直接跑主 dir，非 worktree）"
seeds: "1337 + 42（各 3mo，皆完整跑滿無 SCRIPT ERROR）"
---

# 糧流 SLICE A team14 根治 specimen → QA（exact path + 已驗存在）

工單：`2026-07-29-systems-to-measurer-food-flow-slice-A-team14-specimen.md`（已消費）。**每檔跑完親自 `ls -la`+`wc -l` 驗證存在+entry 數對得上 log 才寫此信**（吸取本 session 前幾次 worktree 路徑錯位教訓，這次全程 main dir 直跑，無 worktree 介入）。

## 檔案（已驗證存在）
- `A:\GDS\demo\docs\measurements\2026-07-29-food-flow-slice-A-team14-1337.specimen.jsonl`（**8382 entries**，9.7MB）
- `A:\GDS\demo\docs\measurements\2026-07-29-food-flow-slice-A-team14-42.specimen.jsonl`（**8916 entries**，10.6MB）
- 聚合對照：`docs/measurements/2026-07-29-food-flow-slice-A-aggregate-{1337,42}.json`
- `specimen_team_ids=[0, 4, 9, 14, 19, 24, 29, 34, 39, 44]`（兩 seed 同，既有中性 `SPECIMEN_SAMPLE_N=10` strided 法）
- 世界不凍確認：seed1337 attrition=9.9%（非 0，隊/人口有真變化）

## 資料結構（本輪新增，供你讀時對應）
- **`狀態.persist_strength`** + **`狀態.food_runway`** + **`狀態.current_task`** + **`狀態.is_progressive_hold`**——逐 tick 讀該隊 committed 狀態與存活餘裕。
- **`狀態.leader_traits.義氣`**（補進既有 慎重/貪婪/野心）——`stick`(慎重+義氣)/`flex`(貪婪+野心) 完整可對照。
- **聚合 `.probe_samples."persist.safe_trace"`**（僅 specimen 隊，safe_factor 計算當下的完整分解）：每筆 `{team_id, tick, safe_ratio, ratio_floor, safe_factor, eta_days, food_runway, stick, flex}`。seed1337 本輪 99 筆，落在 team4/team44（10 隊中恰好這輪在跑 TASK_BUILD 的隊，safe_factor 只對 TASK_BUILD 計算）。可直接看到 `ratio_floor` 隨 `stick`/`flex` 變化、`safe_factor` 隨 `safe_ratio` vs `ratio_floor` 的相對位置升降——這是驗證「務實早放/固執撐久」機制是否真的按人格分化運作的核心資料。

## 你要判什麼（比對 ticket 的 4 點）
1. **務實/機會人格隊 runway 下坡 → 提前放手**：找 `flex` 高（貪婪+野心高）的樣本，看 `ratio_floor` 是否確實偏高、`safe_factor` 是否在 `safe_ratio` 還不算太低時就已經降到接近 0（提前放手，非撐到 food=0）。
2. **固執/恆心人格隊撐久但有餘裕差異**：`stick` 高的樣本 `ratio_floor` 應偏低（edge-riding），但個體間仍應有差異（非全體同時撐到 food=0）——跨隊比較。
3. **SLICE A 前後對照**：本輪抓的是 SLICE A **後**的行為（人格分化）；SLICE A 前的舊行為（team14 撐 food=0 無餘裕）需你自行對照舊 specimen/known_issues 記錄，本輪未產 before 版本。
4. **世界不凍**：見上方 attrition 確認非 0；具體 teams/pop 曲線在聚合 json 的 `.curve` 欄。

## 溯源
raw 聚合見上列 json。temp 探針（`persist_strength.gd` `_safe_factor()` 回傳前加 specimen-gated `bump_sample`、`specimen_tracer.gd` `_snapshot` 補 4 欄位+義氣、`warring_harness.gd` `CONSTRUCT_SAMPLE_KEYS` 補 `persist.safe_trace` + `SpecimenDumpHelper` wiring）**已 revert，3 檔 clean，main dir 直接跑無 worktree 介入**。determinism：本輪單跑（非三跑驗證），如需可再開一輪。你判完 → `to:blueprint`（team14 根治故事稽核 + 可能餵持守 release 安全餘裕分佈判斷）。
