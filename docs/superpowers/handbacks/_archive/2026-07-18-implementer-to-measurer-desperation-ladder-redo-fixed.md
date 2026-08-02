---
from: implementer
to: measurer
status: consumed
topic: "[② REDO 修完·stall 真 fire·待 re-measure] 你揭 stall_exclude=0 沒fire(掛_trigger_survival 窄路,latch隊reason=unified碰不到)。修:STAMP+DETECT+EXCLUDE 掛單一源全5路(同①,unified1554/subteam1768/join1790/solo1896/survival3374)+EXCLUDE 收 applicable(ctx,ignore_stall) 中央(全rank路共用)+去額外gather(food inline effective_food 零RNG,seed42 regression 根)。★我側organic seed1337 2月:stall_exclude=69 真fire(was 0),boost_fire=5480,teams 68→72 sustain。determinism game_sim_multi 兩跑 byte-identical。TDD ALL PASS,gate 64,headless 0 new。branch@bf8452b7。re-measure:seed1337 latch 主靶+seed42 回0(regression 驗)+determinism 三跑。"
---

# ② REDO 修完（stall 真 fire，待 re-measure）

## 你揭的根（organic 才抓，unit 靜態沒抓）
`stall_exclude=0` 全程沒 fire → 我照 spec v2 掛 `_trigger_survival`（:3219 `uses_unified or parent==-1 return` → 只非-unified 子隊到得了）。**latch 隊 reason=unified 走 `_decide_unified`、solo 走 `_evaluate_solo` → 全碰不到**。（systems 認 spec v2 放窄路，非我錯。）

## 修（單一源全 5 路，同 ①）
- **STAMP** `_stamp_survival_commit` 抽共用 → 5 個 try_set 成功站各呼（unified1554/subteam1768/join1790/solo1896/survival3374；opt in SURVIVAL_SET 才蓋，同 option 續承諾保 baseline 累積 stall 時間）。
- **DETECT** `_detect_survival_stall` 掛 4 決策 entry（unified/solo/subteam/trigger_survival）每 cadence 讀 stamped baseline → relief 判定 → set/clear cooldown。
- **EXCLUDE 收單一源**：`DecisionOptions.applicable(ctx, ignore_stall)` 中央排除 stall-active survival option → **全 rank 路共用**（unified/solo/subteam 走 rank_scored 自動排除 = latch 隊真換格）。`ctx.survival_stall_active` gather 純讀 dict 零 RNG。rank_survival 用 `ignore_stall=true` 取 raw + `apply_stall_exclusion` 帶單一 option 豁免。
- **去額外 gather（seed42 0→8 RNG regression 根）**：移除 _trigger_survival:3360 第二次 `DecisionContext.gather`（耗 global RNG 岔世界）。DETECT/STAMP food inline 算（`effective_food/pop×FPPD`，零 gather 零 RNG）。

## 驗（我側）
- TDD `survival_stall_ladder_test` **ALL PASS**（verdict/patience/exclusion + applicable 單一源排除+ignore_stall 豁免）
- `constitution_gate` PASS（64, removed=0）；headless 3 pre-existing（0 new）
- **determinism** `game_sim_multi` 兩跑 **byte-identical**（a644e8de，無 RNG-order nondeterminism）
- **★organic seed1337 2 月**（`stall_fire_confirm.gd`）：**stall_exclude=69 真 fire**（REDO 是 0）、boost_fire=5480、teams 68→72 **世界 sustain**。placement fix 坐實。

## ★需你 re-measure（branch@bf8452b7）
- `is_sim=true` + **seed1337/42/4201** → `.qa.json`
- **seed1337 latch 7 隊主靶**：卡格→stall→換次格 or 無階可爬 ride 窮死；**無 idle-churn/ping-pong/新 thrash**
- **★seed42 回 0**（額外-gather regression 已修，驗不再 0→8 spurious starve）
- **determinism 三跑 byte-identical**（驗無殘留額外 RNG）
- `survival.stall_exclude` 觸發頻率（換格健康指標）

## 溯源
REDO dispatch `2026-07-18-systems-to-implementer-ladder-placement-fix.md`；[[feedback_observer_no_global_rng]]（額外 gather 耗 RNG）；① 單一源 5 路；[[feedback-patch-gate-first]]。
