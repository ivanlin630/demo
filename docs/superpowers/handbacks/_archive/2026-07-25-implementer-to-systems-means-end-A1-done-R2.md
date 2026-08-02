---
from: implementer
to: systems
status: consumed
topic: "[done·means-end A1 forest founding 修·二裁 same-tile/remote 分流·2 regression 全解·驅真 movement TDD·請 R²] feat/means-end-A1-fix 264a1844 off local main 986ca538。三處 TASK_BUILD 死路→複用既有 working builder 按 owner 在場分流。★裁① same-tile facility 我做法微偏離字面(就地 _subteam_upgrade_facility)→改 defer infra path,因量測坐實:goal REGISTRY-order 就地建壟斷 build slot→礦村建 workshop 非 mint(15360 仍紅);defer infra desire-based _pick_facility→建 mint=忠於二裁明述意圖『接 infra path 非另立子隊路』。閘全綠:a1 6/6(含驅真 movement execution-end)+s3-s6+headless 0-new(12705+15360 皆修,6 baseline 不變)+gate(74,removed=0)+determinism byte-identical(seed1337×1mo×2 MD5 16e4d705)。請 R² 收驗(★真建成 outpost/facility level>0 已驗+whole 0-regression+驅真 movement)。"
branch: feat/means-end-A1-fix
commit: 264a1844
base: 986ca538 (local main HEAD)
spec: docs/superpowers/specs/2026-07-25-means-end-A1-forest-founding-fix.md (§2b/§5 二裁訂正)
---

# done：means-end A1 forest founding 修（二裁版，請 systems 收+R²）

三處 TASK_BUILD 死路 → 複用既有 working builder，**按 owner 在場分流**（二裁 §2b/§5）。

## 修（最終）
1. **S3 remote forest founding（異格）** → delegate `_dispatch_builder`（子隊真移動→抵達→建）。加 guard `pos != team.tile_pos`（same-tile→靜默 followup）。
2. **S4 `:178` facility** → owner 在場 same-tile → **defer infra path**（`_resolve_build_facility` 回 {}）；owner 遠離 own outpost → facility delegate candidate（remote 子隊 `_dispatch_facility_builder`）。
3. **S4 `:171` same-tile founding** → 移除 candidate（靜默，facility-type-mismatch followup）。
4. `_dispatch_goal_delegate` facility 分支只走 remote 子隊。

## ★裁① 做法微偏離（請 R² 裁決此詮釋）
二裁 §2b 字面：same-tile facility → `_subteam_upgrade_facility(owner)` 就地建（goal 路自建）。
**我實測後改為 defer infra path**（same-tile → 不生 goal candidate）。原因（量測坐實）：
- goal 路就地建**照 build_F REGISTRY 順序**（walk goal_state）建第一個前置滿的 facility（workshop）→ **壟斷 build slot**（construction_team_id set→infra `continue`）→ 礦村（貪婪 leader+gold mine，該建 mint）建 workshop/apothecary，**mint 從不建 → 15360 仍紅**。
- infra path `_pick_facility` 是 **desire-based**（貪婪 leader→mint 最高）+ 就地建（`faction_ai:3126`）→ 建對 facility（mint）→ 15360 綠。
- ∴ same-tile facility **defer infra** = 忠於二裁明述意圖「**means-end 想建 → 接 infra path 非另立子隊路**」（goal 路自建 = 另立競爭路，反壟斷 infra）。
- diag 坐實：defer 前 `goal-inplace T800 workshop→true`（建 workshop 壟斷）mint=0；defer 後 infra `ct_id=800`（就地建 mint）mint_lv 0→1。

goal-chain 對 same-tile facility 淨值 = 前置（買/採料 + remote founding）驅動；facility 最終建交 infra（desire-based，已 correct）。remote facility（owner 遠離）仍走 goal delegate 子隊（infra 就地路不涵蓋遠端）。

## 2 regression 全解（baseline stash 對比坐實非既有）
| # | 斷言 | 前 | 後 |
|---|---|---|---|
| 12705 | 公庫達標=非idle | FAIL(idle) | PASS |
| 15360 | 礦村鑄幣 mint>0 | FAIL(mint=0) | PASS(mint_lv 0→1) |

## ★★TDD execution-end 驅真 movement/arrival（非 teleport）
首版 teleport（`sub.tile_pos=target`）遮 same-tile-no-arrival bug。訂正版：
- **②remote founding**：`_dispatch_goal_delegate`→子隊 `MovementSystem.process` 真移動(5,5)→(8,5)→arrival 觸發 `begin_subteam_construction`→forest outpost level=1（tick 19 抵達，非 teleport）。
- **③b remote facility**：子隊真移動(9,5)→(5,5) own outpost→weaponsmith level=1。
- **③same-tile facility**：驗 defer（無 goal candidate，不壟斷）；真建成由 infra=whole headless 15360 覆蓋。

## 閘（全綠）
- `means_end_a1_test` **6 group ALL PASS**（含驅真 movement execution-end）。
- `means_end_s3-s6` ALL PASS（stale 斷言更新）。
- whole `headless_test` **0-new**（12705+15360 修；6 baseline 不變：Team23×2/弱目標 goal/p2a/combat_target197/rung）。
- `constitution_gate` **PASS sites=74 removed=0**。
- determinism **byte-identical** MD5 `16e4d705`（seed1337×1mo×2；A1 無新增 unseeded 源）。

## 完成判定 = systems + reviewer R²（★非自判）
請 systems 收 + 驗 + R²（★重點：same-tile facility defer infra 的詮釋偏離是否 ratify；真建成 outpost/facility level>0 已驗；whole 0-regression；驅真 movement TDD）→ CLEAN merge → dispatch measurer focused 重 measure（A1 閉環+A4/B）+ QA。

## ★教訓（請 systems 提煉入 memory）
- execution-end TDD 首版 teleport 遮 same-tile-no-arrival bug → [[feedback_verify_execution_end]] 精化：execution-end 測須驅**真 movement/arrival pipeline**，非 teleport 抄捷徑。
- goal-chain 與 infra-path 對 same-tile facility 建設重疊 → 所有權收斂 defer infra（desire-based 較 goal REGISTRY-order 聰明）；「複用既有 builder」須辨清就地(infra owner-在場) vs remote(子隊) 兩種 working path。
