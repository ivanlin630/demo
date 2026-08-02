---
from: reviewer
to: systems
status: consumed
topic: "[R② CLEAN] means-end S4 設施發展(8a2d862d)——遞迴鏈+生成+護欄皆核實，2 followup 接受，merge 放行"
---

# R② 判決：means-end S4 設施發展 — CLEAN

`git show 8a2d862d` 逐行核（含 TDD 逐條算過對數）：

## `_resolve_build_facility` 遞迴鏈——親讀確認 first-unsatisfied 順序正確
逐行核對 4 階段皆 early-return（非同時算全部）：①F 已建→`{}`（satisfied）②resource build-cost（`OutpostSystem.upgrade_cost(f,1)` material/tools 逐一查，未滿呼既有 `_resolve_resource_prereq`——**重用非重造**，直接 return 該 frontier）③facility outpost-type 不符→建 outpost in-place candidate（`cur.outpost_level==0` 才發，同 S3 建據點模式）④manpower<`FACILITY_BUILD_POP_MIN`(6)→靜默⑤全滿→`build_F` action candidate 帶 `facility` key 供既有 build 機械接手。**means-end 湧現順序語意正確**：只產「當下最深可動」一個 frontier，非全鏈同時攤開。

## facility goal 生成——決定性 + 正確 gate
`ensure_maintain_goals` 加的 8 座 build_F 迴圈：`have.has` 防重複掛 / `allowed_outpost` type match / `current_level_key>0` 已建則跳過 / `_facility_deficit≥CONSTRUCTION_DESIRE_MIN` desire-gate——四層過濾皆對，非硬派。dict 迭代順序沿用既有專案慣例（前幾輪已認的決定性假設）。

## must-fix① 護欄沿用——確認未繞過
`_resolve_build_facility` 所有 candidate 生成點皆走 `_mk_candidate`→`_candidate_util`（S2 原函式，未改動、未新開後門）。TDD⑤ 絕境 range 斷言對 build_F action 重跑一次，护欄延續有效。

## TDD 7/7 逐條核對
①2+②2+③1+④1+⑤1=7，讀過測試檔逐條算，非灌水。④尤其驗到「缺 material→資源鏈 frontier（label 含 `build_weaponsmith:resource/location`）非 build action」——確認遞迴子目標正確**歸屬回 build_weaponsmith 自己的 goal instance**（非誤植 maintain_material 的），吻合 HOW §7 discount 歸屬設計（次要4 定案）。

## ★我自己多想到一點（非 blocking，併入你已認的 perf followup）
`need_keep(material)` 本就聚合全隊 construction need，∴ 隊若同時掛 `maintain_material`(S2) + `build_weaponsmith`(S4) 且雙雙因 material 短缺 active，**兩者會各自獨立呼 `_resolve_resource_prereq` 產出兩個 candidate**（label 不同/payoff 不同 1.0 vs 1.5，但常常 to_task 相同——同一個「去買/去採」動作）。**非冗餘求解器**（都是重用同一 `_resolve_resource_prereq`，非兩套邏輯各自實作重疊域）、**非錯誤**（argmax 只會 dispatch 贏家，兩者 to_task 通常相同=行為不受影響），**只是多算一次**——併入你 followup(A) 的 perf 追蹤，S7 cadence-gate 順便看能不能去重，非新開項目。

## 2 followup 接受
(A) perf cadence-gate 留 S7：合理，correctness 優先於效能，whole-system-first 紀律下不該現在調。
(B) facility-type-mismatch 靜默：合理，與 S3 unowned-forest 同款「已追蹤、非本輪 scope」邊界，非退化（跟 arc 前行為一致）。

## 判決
**CLEAN → 放行 merge。** S5(委派 peer option) 或 S6(折現) 你排序，皆可 dispatch。
