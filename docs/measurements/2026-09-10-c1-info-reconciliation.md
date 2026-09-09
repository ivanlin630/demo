# C1 票① 資訊完整性對帳表（機械產出，勿手改）

★母體＝`decision_context.gd` 的 `var` 欄位（＝引擎替這具身體真的讀了什麼），
不是「我們覺得玩家需要什麼」。★★比對面＝`player_query_api` 公開動詞輸出的鍵集。

★★★比對規則的誠實限：**用欄位【名字】比對鍵名** ——
⇒ 同一個量用不同名字端出來會被算成盲格（偽陰），而同名不同義會被算成看得到（偽陽）。
⇒ 這張表回答的是「**有沒有一個同名的東西端出來**」，不是「**玩家看得懂那個值**」。

## §1 ctx 欄位 × 玩家可讀（119 列，盲格 117）

| ctx 欄位 | 玩家讀得到 |
|---|---|
| `leader_values` | ★盲 |
| `desperation_entry_threshold` | ★盲 |
| `food_days` | ✔ |
| `can_rescue_build` | ★盲 |
| `rescue_build_util` | ★盲 |
| `population` | ✔ |
| `has_goods` | ★盲 |
| `has_arb` | ★盲 |
| `arb_gain` | ★盲 |
| `team_strength` | ★盲 |
| `threat` | ★盲 |
| `team_panic` | ★盲 |
| `ambition_gap` | ★盲 |
| `strongest_feud` | ★盲 |
| `feud_target_id` | ★盲 |
| `pending_claim_amt` | ★盲 |
| `pending_claim_pos` | ★盲 |
| `pending_claim_dist` | ★盲 |
| `pending_claim_coin` | ★盲 |
| `pending_claim_goods` | ★盲 |
| `has_own_outpost` | ★盲 |
| `has_manufacturing_facility` | ★盲 |
| `produce_pull` | ★盲 |
| `idle_labor` | ★盲 |
| `idle_employ_value` | ★盲 |
| `is_merchant` | ★盲 |
| `has_home_outpost` | ★盲 |
| `home_restock_min` | ★盲 |
| `current_task` | ★盲 |
| `has_weak_prey` | ★盲 |
| `self_armed_ratio` | ★盲 |
| `has_occupy_target` | ★盲 |
| `occupy_target_id` | ★盲 |
| `has_strong_neighbor` | ★盲 |
| `strong_neighbor_id` | ★盲 |
| `has_farmable_tile` | ★盲 |
| `farmable_pos` | ★盲 |
| `camp_target_est` | ★盲 |
| `camp_forage_floor` | ★盲 |
| `passive_food_daily` | ★盲 |
| `forage_yield_here` | ★盲 |
| `forage_yield_target` | ★盲 |
| `food_seek_delay_days` | ★盲 |
| `join_host_flow` | ★盲 |
| `occupy_target_flow` | ★盲 |
| `net_food_flow` | ★盲 |
| `food_stock` | ★盲 |
| `camp_site_quality_mult` | ★盲 |
| `camp_flow_delay_days` | ★盲 |
| `can_settle_here` | ★盲 |
| `own_camp_pos` | ★盲 |
| `settle_resume_site` | ★盲 |
| `settle_eta_days` | ★盲 |
| `settle_site_quality` | ★盲 |
| `food_runway_days` | ★盲 |
| `can_expand` | ★盲 |
| `expand_pos` | ★盲 |
| `expand_settler` | ★盲 |
| `expand_site_marginal` | ★盲 |
| `expand_home_marginal` | ★盲 |
| `expand_build_cost` | ★盲 |
| `has_aid_target` | ★盲 |
| `aid_target_id` | ★盲 |
| `has_food_market` | ★盲 |
| `food_market_pos` | ★盲 |
| `food_market_dist` | ★盲 |
| `has_material_market` | ★盲 |
| `material_shortfall` | ★盲 |
| `material_need_total` | ★盲 |
| `material_build_urgency` | ★盲 |
| `has_forage_tile` | ★盲 |
| `forage_pos` | ★盲 |
| `has_specie` | ★盲 |
| `has_buyable_food` | ★盲 |
| `food_seek_target` | ★盲 |
| `help_need_severity` | ★盲 |
| `help_target_id` | ★盲 |
| `help_target_pos` | ★盲 |
| `scout_staleness` | ★盲 |
| `scout_target_id` | ★盲 |
| `scout_target_pos` | ★盲 |
| `can_send_herald` | ★盲 |
| `can_send_scout` | ★盲 |
| `has_acceptable_join_host` | ★盲 |
| `home_food` | ★盲 |
| `home_food_productive` | ★盲 |
| `faction_stakes` | ★盲 |
| `faction_attack_target` | ★盲 |
| `faction_tribute_target` | ★盲 |
| `faction_diplo_target` | ★盲 |
| `pacify_target_on_cooldown` | ★盲 |
| `diplo_target_on_cooldown` | ★盲 |
| `leader_loyalty` | ★盲 |
| `intent` | ★盲 |
| `intent_target` | ★盲 |
| `threat_react` | ★盲 |
| `threat_id` | ★盲 |
| `threat_pos` | ★盲 |
| `threat_threshold` | ★盲 |
| `flee_dest` | ★盲 |
| `perceived_power_ratio` | ★盲 |
| `winnable` | ★盲 |
| `is_resident` | ★盲 |
| `archetype` | ★盲 |
| `rung` | ★盲 |
| `has_trainable` | ★盲 |
| `ambient_train_drive` | ★盲 |
| `need_urgency` | ★盲 |
| `readiness` | ★盲 |
| `readiness_thr_eff` | ★盲 |
| `prosperity_prey_id` | ★盲 |
| `is_subteam` | ★盲 |
| `consolidate_target_id` | ★盲 |
| `absorb_target_id` | ★盲 |
| `resource_slack` | ★盲 |
| `absorb_yield` | ★盲 |
| `host_protector_rep` | ★盲 |
| `best_protector_rep` | ★盲 |
| `survival_stall_active` | ★盲 |

## §2 §5 邊界明列、但【不對應任何 ctx 欄位】的項目

★這一節【不是】§1 的子集：`decision_context` 全檔零筆 event／MessageData 命中
⇒ 事件流【結構上不可能】出現在 §1 的列裡 —— 不是漏勾，是表的形狀容不下它。

| 項目 | 來源函式 | agent 層接到了嗎 |
|---|---|---|
| 事件流 | `player_api_mapper.map_global_messages` | ✔ `player_query_api.get_event_stream`（本票補） |
