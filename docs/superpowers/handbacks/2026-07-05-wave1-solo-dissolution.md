# Handback：wave1 序2 — solo 溶入引擎 + capability-grounded attack

**狀態：** 全 Task done，全驗綠。**channel：** open（待系統/藍圖判 QA-級漂移 + 連動風險）。

## 交付

`_evaluate_solo` 非-unified 手算 argmax 撕除 → `DecisionEngine.rank_scored`（鏡射 `_decide_unified`）；去 `_tag_weight` hard-gate；attack/loot **capability-grounded**（吃 self ARMED 事實）。融合非刪 + 反向（藍圖 tag-soft-ruling 三裁全落地）。

## 驗收結果（全綠）

| 驗 | 結果 |
|---|---|
| solo 融合驗 `solo_dissolution_check.gd` | **ALL PASS**：repertoire 9 反應各可達 + 反向 3 + unified 守恆 3 |
| threat 融合驗 `threat_dissolution_check.gd` | ALL PASS（共用 eval 未破 threat） |
| framework_validation | **PASS=7 DORMANT=0**（S3 scout 一度退化 DORMANT，已修，見下） |
| headless_test | DONE 無 SCRIPT ERROR 無 assert fail |
| 憲法閘 | PASS (sites=32, removed=0)；`_evaluate_solo` 指紋不變（dispatch 仍此 func）→ baseline 未動 |
| seeded warring | 48/8/1/382 → **52/8/1/380**（漂移允許，QA wave 級判） |

## capability-grounding 效果（反向證）

- **ctx.self_armed_ratio** = `_calc_own_armed(state,team) / pop`（equipped 戰力：named 裝備 + anon×armed_anon_ratio；**storage 武器不算**）。
- `loot_drive` / `_intent_fit(攻擊,掠奪)` × `capability_factor = clampf(self_armed_ratio / VIABLE_ARMED_RATIO)`。
- `find_prosperity_prey` weakness 改比 self ARMED（非 self POP）。
- **反向驗實證**：無牙商隊（self_armed=0）掠奪 util **0.000**（rank[0]=貿易，非劫匪化）；重甲商隊（armed）絕境掠奪進前列；軍隊 rank[0]=攻擊。**unified 守恆**：同情境 unified 商隊只差 armed → 有牙掠奪 util **0.480**、無牙 **0.000**（跨 solo/unified 路徑一致，貿易本業仍在 rank）。
- **VIABLE_ARMED_RATIO = 0.3**（TEST VALUE，待平衡校）；LOOT_DRIVE_BASE=1.0 未動。

## ★連動風險（呈報系統/藍圖）

1. **`_tag_weight` 是 solo/prosperity 隱形去衝突閘**（最大教訓）：舊 solo 靠 `_tag_weight=0` 讓 FORCE(untagged/軍隊) 隊 attack 分歸零 → 留 idle → `_evaluate_prosperity_attack`（loop3, idle-guard）接手 scout→打垮→capture 精算征服鏈。去 `_tag_weight` + engine 恆有「建設」option（`options.gd` 無 gate）→ solo 每 idle tick 必派 → **餓死 prosperity 路**（framework S3 `g3.scout_dispatch` 退化 DORMANT）。
   - **修**：`_evaluate_solo` 顯式讓位——FORCE 征服候選（`_is_prosperity_candidate` + `ARCHETYPE_FORCE` + prosperity cadence 到期）在到期 tick `return`，讓 loop3 prosperity 跑（精算鏈優先於 solo opportunistic loot/建設；對齊 spec「消兩條攻擊路徑」）。非到期 tick solo 照跑日常。
   - **呈報**：此讓位是**行為連動的補償閘**，非 plan 明列步驟。系統宜判：(a) 是否升級為「prosperity 前置到 loop2」（對齊既有 `_evaluate_independent_strategy` 前置 pattern，更徹底但漂移面大）；(b) `建設` option 恆 applicable 是否為框架債（任何 idle 隊永不真閒 → 餓死所有 loop3-idle-gated 路）。

2. **seeded 軍隊攻擊占用率 0% → 22.5%**（solo occupancy by tag，seed 1337/1200t）：融合+讓位使 FORCE 隊經 prosperity 穩定觸發攻擊（舊 solo argmax+commitment 較少中選）。世界未退化（teams 48→52、pop 380、established 1 穩）。**QA 判**：是否過度侵略。商隊 loot 恆 0%、seed 中無 solo 商隊（反向嚴格證在 harness，非 seeded occupancy）。

3. **獨立隊 standalone 外交流失**：舊 solo `DIPLOMACY = maxf(野心×0.4−好戰×0.2,0)` 給獨立隊野心-外交 dispatch。engine「外交」option applicable 需 `faction_stakes`（faction directive）→ 獨立隊無。獨立外交今走 `_evaluate_independent_strategy`（結盟/建國）+ threat「求和」。repertoire「外交」可達性由 harness（faction 語意）證，但**獨立隊 ambition-diplomacy 這條具體行為已無**。若藍圖要保 → 議加輕量 tag/intent context term（F-D5 另軌）。

4. **GOVERN vs 生產 平手**：慎重居家空庫 leader，`settle_fit(駐守=0.6)×weight(settle)` == `produce_need(0.6)×weight(settle)` → tiebreak(REGISTRY 序)取生產。三者皆居家發展（原意保）。GOVERN 專屬 edge 需 caution/tag context term。已記 headless 測放寬到居家集。

5. **紮營 desperation-gate**：engine「紮營」需 `food<DESPERATION`；舊 solo CAMP 無此閘。吃飽流亡團今走「建設」(bootstrap 據點=亦尋家)。絕境紮營可達性 harness 專證。

6. **self-armed helper 選擇**：用 `_calc_own_armed`（equipped）非 `threat_assessment.self_power`（pop×skill+storage weapon_factor）。→ 有武器但 `armed_anon_ratio=0`（未武裝）= 0 戰力（合 doctrine）。**副作用**：測試/scenario 用 storage 武器表達「武裝」者須改設 `armed_anon_ratio`（headless 3 測 + 已驗 framework S3 靠 prey score 其他項仍找得到 prey，未需改）。

## 支援性改動（非 plan 明列，記錄備查）

- `DecisionEngine.rank_scored_ctx(ctx, current_option="")`：ctx-taking 純打分 accessor（鏡射既有 `rank_threat(ctx)`）；`rank_scored(state,team)` 委派之。harness 手構 ctx 驗 rank 用。
- headless_test 4 legacy solo 測更新：stuck/commitment/bandit 補 tiles+belief+armed（引擎 belief/capability-gate 取代舊 ungated argmax）；govern/seek-home 放寬到居家/尋家集。

## TEST VALUE 待校
`VIABLE_ARMED_RATIO=0.3`、`LOOT_DRIVE_BASE=1.0`、`PROSPERITY_CADENCE*`（讓位頻率）——皆待 wave QA 平衡。
