---
from: implementer
to: systems
status: consumed
topic: "[recovery-r2 決策+送料層 DONE(7/8綠)·執行層 build-sustain blocker 呈 HOW 裁·feat/recovery-r2 commit bdb2876f]facility_roi survival-bounded + _try_invest_side 雙 survival bound + material convoy deposit(convoy_kind=invest DELIVER→TileBank.deposit 入村 public_storage)全實作+7/8 綠(三態/survival-bound/純函式/森投/山不投/領主絕境不投/deliver deposit)。★★驗執行端 red(呈報、非 fixture):dispatched=1+料到村 45 但 build_fired=0/farming 0→0。深追 root:invest-target 村(小森 ROI+)必 food-insecure→覓食(PRIO_SURVIVAL 80)壓過領主 build 令(PRIO_DISPATCH 50)→料永不蓋;Catch-22:ROI+ 需小 pop(森養不起多人)、小 pop(≤FORAGE_VIABLE_POP 15)恒覓食;_trigger_survival:4309-4315 只護『已在蓋』短工期產糧設施, survival 選項集 rank_survival 不含『建設產糧設施』→飢餓村從不 survival-發起蓋 delivered farming(spec §2B 預警的手不聽腦執行層 blocker)。建議 HOW fix:擴 _is_food_facility_short 前例→料備妥產糧設施建設=survival-tier self-rescue(survival-發起非只 in-progress 保護)=決策引擎/emergent-balance 屬 systems/blueprint 裁。請裁 fix 方向→我實作收尾 ★驗執行端。constitution 74/headless 0-new(決策+送料 gate-clean)。"
branch: feat/recovery-r2
commit: bdb2876f
---

# recovery-r2 決策+送料層 DONE（7/8 綠）· 執行層 build-sustain blocker 呈 HOW 裁

feat/recovery-r2 commit `bdb2876f`（WIP、已 push）。**決策層 + material-delivery 全實作 + 綠**；**執行層最後一哩（村真蓋）撞 survival>dispatch 優先權 blocker**，屬決策引擎/balance = HOW，呈你裁。

## DONE + 綠（7/8）
| 件 | 狀態 |
|---|---|
| `MarginalEconomy.facility_roi(est, facility, next_lvl, upgrade_cost_value)` | survival-bounded（`net_after>=0`→full `PLANNING_HORIZON`=90；`net_after<0`→window=`food_est/−net_after`，food_est NEUTRAL 0→山地仍赤字 window0→roi=−cost 自我區辨、**治 HORIZON 自打臉**）。純算術零 god-view（收 float cost_value、不吃 state）。 |
| `VillageEstimate` +`food_est` NEUTRAL 0 | survival-window 用（只緊 net_after<0 案；net_after>=0 走 full horizon 與 food_est 無關→三態由 net_after sign 定）。 |
| `_try_invest_side` | 領主評 holding 村 `facility_roi`（belief est 結構防線）、roi>0 送料。★**雙 survival bound**：村端 ROI + 領主端 source-floor（留守 `CONVOY_MIN_PARENT_POP` + 絕境`food_days<DESPERATION`先自救 + 有料不掏空）。 |
| material-delivery | reuse `_dispatch_convoy` 母體 + **新 `convoy_kind="invest"` DELIVER 分支** → `TileBank.deposit` 料入 target 村 `public_storage`（非 `_resolve_market_at_outpost` 賣）。reuse convoy transit/merge-back 生命週期（避 R1 subteam 三坑）。 |
| tap | `invest.roi` / `invest.material_delivered` / `village.build_fired`（§6）。 |
| 測試 | **7/8 PASS**：facility_roi 三態（森 75>0/山 −60<0）/ survival-bound 機制 / 純函式(god-view) / 森投 dispatch / 山不投 / 領主絕境不投 / **invest convoy deliver deposit 入村公庫 0→45**。 |
| constitution / headless | **PASS 74 / 0-new**（決策+送料層 gate-clean）。 |

## ★★驗執行端 red（blocker、呈報·非 fixture 問題）
全 pipeline 測試：`dispatched=1 + 料到村 45（vtile public_storage 46）` **但 `build_fired=0 / farming 0→0`**——料到村公庫但村**從不蓋**。

### root（runtime trace 逐 tick 坐實）
1. **invest-target 村必 food-insecure**：`facility_roi>0` 要求「farming L1 令 net_after>=0（deficit→surplus）」→ 只小 pop 森村成立（`pop18` 森 farming L1 仍 net<0→roi 負→領主不投）。
2. **小 food-insecure 村恒覓食**：`FORAGE_VIABLE_POP=15` → pop≤15 覓食 applicable；food_days<security(4) → survival 進場 → **覓食走 `PRIO_SURVIVAL`=80**。
3. **領主 build 令被壓**：`_evaluate_infrastructure` 令居民就地擴建走 `_subteam_upgrade_facility`→`TaskArbiter.transition(village, BUILD, PRIO_DISPATCH=50)`；**50 < 80 → 下一 tick survival 覓食覆蓋 → 建設令不 stick**（trace：build_fired 曇花一現後 `_tick_construction` active_team=null 恒 stall cticks 卡 72）。
4. **Catch-22**：ROI+ 需小 pop（森養不起多人）↔ 小 pop 恒覓食（survival 壓 build）→ **delivered 料永不蓋**。
5. `_trigger_survival:4309-4315` 只護**已在蓋**的短工期產糧設施（`_is_food_facility_short`）；survival 選項集 `rank_survival` **不含「建設產糧設施」** → 飢餓村**從不 survival-發起**蓋 delivered farming。= spec §2B 明警的「料到但建設不 fire=手不聽腦執行層 blocker」。

### 建議 HOW fix（呈你/blueprint 裁）
**擴 `_is_food_facility_short` 前例：料備妥（村公庫夠 upgrade_cost material）+ 產糧設施 + 短工期 → 建設=survival-tier self-rescue**（survival-**發起**，非只 in-progress 保護）——即把「蓋 delivered farming」納 `rank_survival` 選項集 @`PRIO_SURVIVAL`，令飢餓村自救走「建永久產能」勝「覓食臨時填」。
- 理由：建 farming 是比覓食更優的求生（永久 vs 臨時），已有 `_is_food_facility_short` 求生語意前例（只差發起 vs 保護）。
- ★屬決策引擎 survival 選項集 + emergent-balance（飢餓村改自救建設非覓食＝廣域行為位移）= **systems HOW + blueprint 意圖**，故不擅自改、呈裁。
- 非 crank：util=真求生價值（永久產能 > 臨時覓食），非 boost 逼 fire。

## 路
1. **你/blueprint 裁 fix 方向**（survival-tier food-facility-build-when-material-ready，或你更佳解）。
2. → 我實作收尾（村真蓋→farming 0→1→inflow 真升，全 pipeline 綠）+ determinism + 重跑 gates。
3. → measurer 量三態+雙 bound + deficit→surplus→breed → QA → merge。

決策+送料地基 KEEP（已 push、reviewable）。HOLD-warm 待裁。
