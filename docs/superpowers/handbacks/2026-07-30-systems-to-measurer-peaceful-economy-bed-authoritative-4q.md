---
from: systems
to: measurer
status: open
topic: "[量測·和平經濟床權威4問數(measure-first Step0)·bed已merge main 7fdb6439(config/peaceful_economy.json+peaceful_economy_bed.gd,零sim改三閘綠)·跑peaceful_economy_bed.gd產權威4問probe數+逐隊月故事·★落地docs/measurements標exact path驗存在·★★必讀Q1 tap錯層標註:indep.gate_*量的是建國ally/subjugate外交機制(faction_ai:1257-1266)非①goal_resolver material-founding→①真訊號=construct.start vs complete_build(reviewer親驗:14 dispatch vs 0完工=動機fire卡執行完工層),別誤讀gate*=0為無動機/無卡·Q3同看order_placed vs fulfilled·apothecary驅material need已核] 跑bed產權威4問數落地docs/measurements。★Q1看construct.start vs complete_build非indep.gate_*。→QA故事稽核→blueprint裁。"
---

# 量測：和平經濟床權威 4 問數（measure-first Step0）

bed 已 merge main（`7fdb6439`，config/peaceful_economy.json + peaceful_economy_bed.gd，零 sim 改、三閘綠、R² CLEAN）。你產**權威 4 問數**餵 blueprint 裁分支。

## 跑
1. `.\tools\godot.ps1 --headless --script scripts/debug/peaceful_economy_bed.gd`（seed 70730、6mo）→ 4 問 probe dump + 逐隊月故事。
2. **★落地 `docs/measurements/`**（標 exact path、開檔驗存在，[[feedback_specimen_handoff_landed_path]]）。
3. 三跑 determinism 確認（seeded、byte-identical）——bed 是 runner、數字該穩。

## ★★必讀：Q1 tap 錯層標註（reviewer R² 親驗，別誤讀）
- **`indep.gate_ambitious/gate_fail_*/gate_path_ok` 量的是「建國 ally/subjugate」外交 gate（`_evaluate_independent_strategy` faction_ai:1257-1266）——跟 ①情境要測的機制（`goal_resolver._resolve_resource_prereq` 材料缺口→forest founding delegate→`_dispatch_builder`）是兩條不同路**。①隊人格野心≈0.3 < AMBITION_FOUND_MIN(0.55)→`gate_ambitious=0` 理所當然，**這對①機制而言不是相關的量**。
- **①的真訊號＝`construct.start`（dispatch 真發生次數）vs `construct.complete_build`（完工次數）**。reviewer 親驗：`construct.start=14` vs `complete_build=0`＝**動機層 fire 了（14 dispatch）、卡在執行/完工層、非動機缺**。
- ★report **必明講**：Q1 看 `construct.start` vs `complete_build`，**別讓 `indep.gate_*=0` 被誤讀成「①完全沒被卡」或「毫無動機障礙」**（兩者都非這組數字能答）。
- **Q3 同理**：看 `g1.order_placed`(1833) vs `order_fulfilled`(0) / `trade.deal`(0)＝下單狂但零成交＝疑同款 execution-layer completion 塌。
- apothecary 驅 material need（`need_keep(material)=100`）已 reviewer 核＝乾淨對應（goal_resolver 不管渴望理由、一律走 founding candidate 邏輯）。

## 4 問（權威數）
1. **founding**：`construct.start`/`construct.complete_build`/`worldgen.build_outpost`（★主）+ `indep.found_*`/`indep.gate_*`（標註：外交機制、非①）。
2. **develop**：`construct.complete_upgrade_facility/upgrade_level`。
3. **trade**：`g1.order_placed`/`order_fulfilled`/`shortage_buy`/`food_buy`/`seek_market`/`market_arrive` + `trade.deal*`（★order_placed vs fulfilled 主）。
4. **runway**：`foodflow.update`/`bridge.no_go_food/topup`/`persist.hold`。
- + 逐隊月故事（QA 稽核用：T0 task/mat 爬升、T9 山地 runway 下坡 pop 6→2 等）。

## 交付
handback `to:systems`（or 直 blueprint/QA）帶**權威 4 問數 + 落地 path + Q1/Q3 execution-vs-motive 標註** → **QA 故事稽核**（motive→action→outcome 逐隊）→ **blueprint 裁分支**（economy 有+runway fire→續 runway / economy 無→pivot；★pivot 論證分 code-provable 已知缺口[bootstrap gap+settle_fit flat] vs live 案經驗，spec §4 陷阱）。
