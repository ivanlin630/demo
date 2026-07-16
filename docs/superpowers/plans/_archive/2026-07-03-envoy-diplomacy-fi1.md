# ②a 完整修：timeout + 信使外交 + F-I1 統一 — Plan

> Spec：`docs/superpowers/specs/2026-07-03-envoy-diplomacy-fi1-design.md`（先整份讀,含硬約束）。
> 順序:A timeout（保險網,獨立可驗）→ B/C 信使+resolver 統一 → D 探針 → 驗收。

## Task 1 — A. founding timeout（保險網）

**檔**:`faction_ai_system.gd`
1. in-flight guard（`_evaluate_independent_strategy` :1057-1059 found_ally/found_subjugate）加 timeout:
   `state.world.current_tick - team.task_start_tick > _founding_timeout(team)` → `TaskArbiter.release(team)` + `Probe.bump("indep.found_timeout")`。
2. `_founding_timeout`:`hex_dist(tile_pos, move_target) × 每格 tick 成本估 × FOUNDING_TIMEOUT_MULT`（TEST VALUE,建議 3.0 往返裕度）,下限 `2 × TICKS_PER_DAY`。非死常數（invariant「timeout 按距離/移速估」）。
3. headless 測:凍結場景（目標永不可達）→ timeout 後 release;正常場景不誤殺。

## Task 2 — B. 信使實體

**檔**:`faction_ai_system.gd`（dispatch）、`subteam_system.gd`、`team_data.gd`（提案欄）
1. 建國結盟 dispatch 改派信使:`SubteamSystem` 派出 pop=1-2 子隊,`TASK_HERALD` + `task_reason="envoy_proposal"`,提案 payload 權威存發起隊（`pending_proposal: Dictionary {type:"alliance", target_id, issued_tick, proposal_id}`,對齊 active_orders pattern）,信使帶 proposal_id ref。
2. 馬:母隊 resources 撥 mounts 至信使 pop×1（有幾配幾,無馬照走）。
3. 信使 move_target=目標 `best_estimate` 位,cadence 刷新（對齊 scout pattern）;**信使 task 自配 timeout**（同 Task 1 公式）——timeout → 信使歸隊/併回母隊（復用 merge_back）。
4. 冗餘:`ENVOY_REDUNDANCY`（TEST VALUE=1;建國提案=2）。同 proposal_id 首達生效後到 no-op。
5. 母隊派出信使後 **不再自己 TASK_DIPLOMACY 追**——母隊 release 回日常,等結果（提案 pending 期間不重發,timeout 清 pending+cooldown）。

## Task 3 — C. 送達 + belief 回覆 + F-I1 退役

**檔**:`interaction_system.gd`、`diplomatic_ai_system.gd`
1. interaction 同格 scan:信使（envoy_proposal）遇目標隊 → 送達:呼 `handle_diplomacy_message(state, 目標, 發起隊, "alliance")`（belief+人格公式）。
   - accept:兩獨立 → `create_faction`（強者 leader,沿 `_try_diplomacy` 現邏輯搬家）;發起方已有 faction → 招募 target（沿現邏輯）。
   - reject:發起方 `diplomacy_reject_cooldown[target]`（既有欄）+ 清 pending_proposal。
   - 送達後信使歸隊（merge_back or 解散併回）。
2. **`_try_diplomacy` 公式退役**:接受判定改委派 `handle_diplomacy_message`（刪 god-view `team_strength` 比較;同格偶遇=另一送達管道,決策公式同源）。faction 招募/建國後續動作保留。
3. grep 驗:diplomacy 決策路徑無 `team_strength` 呼叫殘留。

## Task 4 — D. 探針 + 驗收

1. 探針:`envoy.dispatched / envoy.delivered / envoy.accept / envoy.reject / envoy.timeout / envoy.target_dead / envoy.died`（全 Probe guard）。`longwindow_bed` 漏斗表加 founding 段。
2. **長窗解凍驗**:`LW_SEED=1337 LW_MONTHS=6 LW_DIAG=1` — T32/T34 不再跨月卡 found_ally（[WolfGate] task 佔用消失/輪轉）;T32 raid 曲線恢復。
3. **建國仍活**:framework S1 PASS;seeded warring `faction_found`/`found=` 計數 >0 非全 timeout（envoy.accept>0）。
4. 回歸:headless（1 FAIL pre-existing 容忍）+0 SCRIPT ERROR、framework 7/7 DORMANT=0、coin_eq delta=0、InvariantAudit 0。
5. **pointwise 預期 DIRTY**（行為修）:改用月線 sanity 對照（隊數/attrition/found 不崩,附前後表進 handback）。

## Handback

`docs/superpowers/handbacks/2026-07-03-envoy-diplomacy-fi1.md`:各 Task 結果、envoy 探針分佈（=藍圖要的 fail 分佈）、T32/T34 解凍證據、F-I1 退役 grep 證、TEST VALUE 清單、月線前後對照。

## 注意

- Godot `.\tools\godot.ps1`;長窗 `GODOT_TIMEOUT=5400` 背景;輸出**先落檔再篩**（勿管線 First/Last 賭表位置）。
- headless 基準 1 FAIL（弱目標未加入攻擊 goal）=pre-existing。
- **硬約束**:凡新 latch 配 timeout;禁身分路徑切換;judge 淨數 −1（F-I1 兩公式→一）;信使全用既有信號零新系統。
- G3 攔截/收買 hook **不做**（實體先行,藍圖明示）。
- 勿碰 R1 gate/prey score 語意、assimilate 行為（他波）。
