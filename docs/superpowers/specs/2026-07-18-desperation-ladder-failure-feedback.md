# Spec：絕境階梯失敗回饋（② 重做，v2 grounded on ①-merged main）

> **★v2 重寫（異質 R² 5 blocking 修，2026-07-18）**：v1 建在**已被我 merge-①-only 排除的 branch amplifier 狀態**上=stale。坐實 main(HEAD=1132bf0c)實況：**無 famine-amplifier**（`grep famine_severity`=0）；真正 live 的絕境 boost = **`SURVIVAL_BOOST_FLOOR/MAX`**（`decision_engine.gd:9-10,40-41`：food_days<FLOOR 時 survival-class util += MAX×(FLOOR−food_days)/FLOOR，**集體等量、order-preserving**——同 QA 揭的 latch 病:floats 全 survival 選項但不換序）。∴ ② = **在既有 SURVIVAL_BOOST 上加失敗回饋（唯一能換序=產階梯的機制）**，非「保留 amplifier」。
> **序**：off ①-merged main（1132bf0c）branch。

## 根（QA raw trace + systems 坐實）
- QA FAIL：7 隊卡 survival 單一格 33+天、每 cadence 正確重選、action 從未 resolve、**無失敗回饋 escalate**。
- 機制：`SURVIVAL_BOOST`（集體等量）+ 選項間 base 人格 weight gap（`terms.gd weight()/eval()`，約 0.1-0.5）→ 最高 base-weight 那格恆贏，深餓只集體浮高不換序。**產階梯 progression 的唯一路 = 失敗回饋降/排除 stalled 格 → argmax 換次格。**

## 設計（HOW，5 findings 全修）

### 核心：stall → 硬排除 stalled 格（bounded window，reject_cooldown idiom）
**採硬排除（bounded-duration）非軟降權**（R² finding-1）：軟降權要跟 `SURVIVAL_BOOST`(max 2.5) + `COMMITMENT_BONUS`(0.3) 打量級混戰、且需 decay 排程易 ping-pong；**硬排除 X 一個 bounded window**（鏡射 `diplomatic_ai_system.gd:139` / `team_data.gd:140` reject_cooldown idiom）乾淨、好推理、天然有 expiry。
- stall 成立 → `survival_stall_cooldown[option] = current_tick + STALL_EXCLUDE_WINDOW` → cooldown 內該 option **applicable()=false**（退出候選）→ argmax 自然選次高 base-weight applicable 格。

### ★★CRITICAL-placement 修（v3，measurer organic 揭 stall_exclude=0）：stall 掛**單一源全 5 路**，非 _trigger_survival 窄路
- **v2 錯（我第4次放錯路）**：v2 說掛 `_trigger_survival:3370`——但該 func :3219 有 `if uses_unified(team) or team.parent_team_id == -1: return`=**只非 unified 子隊到得了**。**latch 隊 QA 說 reason=unified**（走 `_decide_unified`）+ solo 走 `_evaluate_solo` → **全碰不到** → organic `stall_exclude=0` 一次沒 fire。
- **修=同 ① 單一源**：survival option 在 **5 路** commit（ⓘ 就是 ① 收的那 5 個 `priority_for(opt)` try_set 站：`_decide_unified:1554` / `_decide_subteam:1774` / `_try_join_target:1795` / `_evaluate_solo:1896` / `_trigger_survival:3370`）。**stall STAMP 掛這 5 站**（每站 try_set 成功 + `opt in SURVIVAL_OPTION_SET` → 蓋章），非只 _trigger_survival。抽**共用 helper**（`_stamp_survival_commit(team, opt, ctx)`）5 站各呼一次（鏡射 priority_for 單一源）。
- **蓋章讀真 option 字串**（非 current_option——非統一路沒設，`faction_ai:3357`;且 current_task 無法分辨 掠奪/佔村 皆 TASK_ATTACK）：`survival_committed_option/tick/food`。
- **★★reuse 各站既有 ctx，禁額外 `DecisionContext.gather()`（v2 impl seed42 0→8 regression 根：:3360 額外 gather 耗 RNG 岔世界，[[feedback_observer_no_global_rng]]）**：每站決策時已 gather 過 ctx，helper 收該 ctx 參數，**不自己再 gather**。stall DETECT（relief 判定）也 reuse 決策 entry 的 ctx，零額外 RNG 消耗。
- **EXCLUDE 已單一源**（registry `applicable()` cooldown 檢=所有 rank 路共用，這半對）。只 STAMP+DETECT 要從 _trigger_survival 移到單一源。

### CRITICAL-1 修 + design-2 修：stall 判定 = relief-magnitude 的 before/after，非 current_option、非瞬時
- **relief 取樣（design-2）**：`food_days` 是瞬時 stock ratio（`decision_context.gd:143`），禁瞬時比。**baseline vs after-N-days 單次 before/after**：committed 起 `survival_committed_food` baseline → N 天後看 `food_days − baseline`。
- **需最小 relief magnitude 才算「resolving」**（非「沒更低就算解」）：`food_days − baseline >= RELIEF_MIN` → resolving（重置 stall，X 在起作用留它）；否則（含 flatline 慢產不足）→ **stall 成立**（升級）。防單 tick blip 誤 reset（比 baseline 非比昨日）+ 防慢產 plateau 誤判 resolved。

### design-3 修：N（耐性）用既有人格 trait，禁虛構
- v1 用「堅忍」——`person_data.gd:31-41` leader_values **無堅忍**（有:慎重/求生欲/野心/好戰…）。虛構 trait→`.get("堅忍",0.5)`恆 default=偽全域常數（違「非死常數」）。
- **修**：`STALL_DAYS = STALL_BASE × patience_factor`，`patience_factor` 用**既有** `慎重`（謹慎者多撐一會才換）+（可選 `1−求生欲` 反向:高求生欲急著換）。只用 person_data 存在的 key。STALL_BASE=TEST VALUE（measurer 校）。

### design-5 修：單一 applicable option 的終局（別 release/idle churn）
- **問題**：若 X 是**唯一** applicable survival 格（無 aid_target 乞不了/無 farmable 紮不了/無 host 併不了）→ 硬排除 X → 無次格 → fall through `faction_ai:3396-3402`(try_hunt_predator→release→idle) → 下 cadence 重進又選 X → **release/idle churn = 比 latch 更糟**。
- **修**：stall 排除前檢「有無其他 applicable survival 格」——**無 → 豁免（不排除 X，讓它 ride 到窮死=intended fallback）**。有 → 才排除換格。（= 只在真有階可爬時才踢下當前格。）

### design-1 修：無 ping-pong（硬排除 + expiry-on-relief）
- 硬排除有 `STALL_EXCLUDE_WINDOW`（bounded）→ 不會永久鎖死。
- **expiry 規則明確**：window 到期 or **真找到 relief**（food_days 回升 ≥RELIEF_MIN）才清該 option 的 cooldown。**非計時器亂清**。
- A↔B ping-pong 防：切到 B 後，A 仍在 cooldown window 內（未到期未 relief）→ B stall 也排除 → 若 A/B 都 cooldown 且無第三格 → 落單一 option 豁免（design-5）→ ride 窮死，非無限 ping-pong。window 夠長（> STALL_DAYS）確保換格後 A 不會太快回來。
- 量級不用打混戰（硬排除非軟降權）→ 不需算贏 SURVIVAL_BOOST+COMMITMENT_BONUS。

## 交付切片
- **S1 stall 偵測**：`_trigger_survival:3370` 蓋章 committed option 字串+tick+food baseline；relief before/after 判定（RELIEF_MIN）。
- **S2 硬排除換格**：stall → survival_stall_cooldown → applicable()=false（cooldown 內）→ 單一 option 豁免檢 → argmax 換次格。
- 行為變（絕境隊真攀階梯）→ sim measure（**seed1337 latch 7 隊主靶**：卡格→stall→換格/或單一 option ride 窮死；無新 thrash/ping-pong/idle-churn）。

## 閘
- **R²（已跑 v1=5 blocking，本 v2 修完需**再 R² 確認 CLEAN**才 dispatch）**：重點覆核 stall-detection edge（relief blip/plateau）、單一 option 豁免、ping-pong、人格 trait 存在、硬排除 window vs STALL_DAYS 關係。
- **measure（sim, seed1337/42/4201）→ QA 故事稽核（seed1337 latch 隊:紮營 stall→改乞/投靠 或 無階可爬 ride 窮死;無 idle-churn/ping-pong）→ blueprint release-pass → merge**。
- 不跳 QA（QA 故事稽核正是抓出 latch 的）。

## 溯源
異質 Sonnet R² v1 5 blocking（famine-amplifier 不在 main/current_option 非統一路沒設/thrash-decay/relief 取樣/堅忍不存在/單一 option 終局）;systems 坐實 grep（famine_severity=0、SURVIVAL_BOOST:9-10、_trigger_survival:3357/3370）;既有 reject_cooldown idiom;[[project_desperation_economy]];[[feedback_symptom_vs_root_retry]]。
