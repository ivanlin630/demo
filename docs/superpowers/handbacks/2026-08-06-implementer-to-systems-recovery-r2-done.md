---
from: implementer
to: systems
status: consumed
topic: "[recovery-r2 收尾 DONE·全 pipeline 綠 10/10·feat/recovery-r2 commit 6db4d90c]build-as-survival self-rescue(spec §2B.1、blueprint 裁 YES genuine)解呈報的 Catch-22(飢餓村覓食 PRIO_SURVIVAL 壓過 build 令→delivered 料永不蓋)。新 survival option『自救建田』:util=1.0(求生基線)+食安價值 frac(genuine、非死常數);viable gate=料備妥+建工期<餓死窗(P(survive_to_harvest));★★anti-crank=建工期≥餓死窗→viable=false→不蓋→落覓食(可能餓死+料浪費=失敗案必留、禁 always-win crank);scope 硬限僅 FOOD_FACILITIES+料已備。_decide_unified 選中→起建 construction+try_set(BUILD,PRIO_SURVIVAL,'unified')同層 self-replace 換覓食(否則 zombie construction 無工人)。★★★全 pipeline 真 advance_tick:facility_roi>0 送料→deposit 入村公庫→村自救建田(勝覓食)→_can_afford 過→build 真 fire→farming 0→1 真升完工。驗全綠:recovery_r2_test 10/10+constitution 74+headless 0-new+determinism 3-run 84D6A6C8 byte-identical(behavior 變新 MD5≠R1、3-run 穩=零 RNG leak)。請 R²(merge-gate 核 build_util genuine 非 crank+失敗案保留+料到真蓋執行端走 precondition gate)→measurer 量(森村早投真蓋 inflow 翻正 breed/山不投/領主絕境不投/晚投料浪費=三態+雙 bound+timing 湧現)→QA→merge。地基 KEEP。"
branch: feat/recovery-r2
commit: 6db4d90c
---

# recovery-r2 收尾 DONE — build-as-survival self-rescue（全 pipeline 綠 10/10）

feat/recovery-r2 commit `6db4d90c`（已 push）。你的 HOW fix（spec §2B.1、blueprint 裁 YES genuine util）解了我呈報的 ★★驗執行端 Catch-22（飢餓 invest-target 村覓食 `PRIO_SURVIVAL` 壓過 build 令 → delivered 料永不蓋）。全 pipeline 綠。

## fix 實作（build-as-survival、延伸 protect→initiate 前例）
| 件 | 內容 |
|---|---|
| `_food_rescue_eval(state, team)` | 純評估（無副作用、供 ctx）：料備妥產糧設施自救建設 `{viable, facility, util}`。**util = 1.0（求生基線、同覓食）+ 食安價值 frac**（farming 增產/每日食耗覆蓋率、`_food_facility_gain` 鏡射 `_inflow_est`）→ 蓋得完時穩越覓食（permanent 產能 > 臨時填）。 |
| ★viable gate | 料備妥（`_can_afford` 公庫+私產 ≥ upgrade_cost）+ **建工期 < 餓死窗**（P(survive_to_harvest)：`build_eta_days = ticks/pop/TICKS_PER_DAY(240)` vs `food_days`）。 |
| ★★anti-crank（乙教訓、blueprint 硬性） | **建工期 ≥ 餓死窗（快餓死）→ viable=false → 不蓋 → 落覓食**（可能餓死+料浪費＝genuine 失敗案必留、**禁 crank always-win**）。scope 硬限僅 `FOOD_FACILITIES`+料已備 means-end build→food。 |
| option 整合 | `DecisionOptions` REGISTRY「自救建田」+ `SURVIVAL_OPTION_SET`(PRIO_SURVIVAL) + `PASSIVE_SURVIVAL_SET` + `NeedHierarchy.AFFINITY[0.8,0,0,0,0.2]`（生存主導 layer0 → coeff 隨食急迫追蹤、同覓食生存層）+ `DecisionTerms` `food_rescue_build`。 |
| 初始化+sustain | `_decide_unified` 選中「自救建田」→ `_ensure_rescue_build_started`（`_subteam_upgrade_facility` 起建 construction）+ **`try_set(BUILD, PRIO_SURVIVAL, "unified")` 同層 self-replace 換掉覓食@80**（否則起建了但 task 卡覓食＝zombie construction 無工人）。in-progress branch viable → commitment 慣性 sustain 至完工。 |

## ★★★驗執行端（真 advance_tick pipeline、reviewer ⑥）
領主 `facility_roi>0` 送料 → convoy `TileBank.deposit` 入村 public_storage → 村飢餓**自救建田（勝覓食）** → `_can_afford`(公庫有料)過 → **build 真 fire → farming 0→1 真升 + 完工**（cticks 72→0）。trace 坐實：vopt=自救建田、vtask=建設、cticks 遞減。

## 驗（全綠）
| 閘 | 結果 |
|---|---|
| `recovery_r2_test` | **10/10 PASS**（facility_roi 三態 / survival-bound / 純函式(god-view) / 森投 / 山不投 / 領主絕境不投(雙 bound) / deliver deposit / 自救建田 viable util 1.48>1.0 / **★★anti-crank 快餓死不蓋** / **★★★全 pipeline farming 0→1**） |
| constitution_gate | **PASS sites=74 removed=0** |
| headless | **0-new**（Team23建設×2 / 弱目標 / p2a 0.41 / 197 / rung 皆 pre-existing baseline） |
| determinism | 3-run `84D6A6C885DACB10F9177333FF23E54A` **byte-identical**（GODOT_TIMEOUT=1200、seed1337 1mo；behavior 變→新 MD5≠R1 FCE1BAC4＝invest+自救建田 warring 有 fire；**3-run 穩=零 RNG leak**） |

## 守
god-view 結構防線（facility_roi 全 belief est、`_food_rescue_eval` 讀自家 tile=自知非 god-view）/ 零死常數（build_util = genuine 食安價值×P(survive)、facility_roi 真回收）/ 真成本（領主出料 + 村出勞力）/ determinism 3-run 穩 / constitution 74。

## 路
1. **你 R²**（merge-gate 核：build_util genuine 非 crank + 失敗案保留（anti-crank 測坐實）+ 料到真蓋執行端走真 `_can_afford` precondition gate + 雙 survival bound + god-view 防線）。
2. → measurer 量（森村早投真蓋 inflow 翻正 deficit→surplus→breed / 山不投 / 領主絕境不投 / **晚投料浪費**（convoy 慢/遠→村死前料到不了＝genuine 失敗）＝三態 + 雙 bound + timing 湧現）。
3. → QA 故事判 → merge。R3 遷村後續。地基 KEEP。

## 順帶（供你入 memory / 折 invariants）
- 新不變量候選：**build-as-survival**（料備妥產糧設施 + 建工期<餓死窗 → 蓋田=survival-tier self-rescue 勝覓食；蓋不完→覓食＝失敗案留）。
- convoy material-delivery 觀察：material weight=1.0（food 0.1 的 10×）→ 2-porter invest convoy 超載 →速度 clamp MAX_MOVE_TICKS(3×)；遠村送料慢（~1.8 game-day/3hex）＝晚投浪費風險真實（timing 三態的成因、measurer 可量）。非阻塞、reuse proven convoy 如常。
