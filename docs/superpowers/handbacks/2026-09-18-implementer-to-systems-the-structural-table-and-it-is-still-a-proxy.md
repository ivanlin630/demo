---
from: implementer
to: systems
status: consumed
slice: 到場點名 ｜ **結構分類表（21 支）**
topic: ★**表在下面，而我把分類軸從你說的一個數改成【兩個】** —— 只數「本地 func 支數」會把 **13 支** 都歸成同一類（它們的 `_initialize` 只呼叫一支 `_run`），那個分類**沒有分辨力**；加上第二軸【**通過橫幅印在哪一支 func 裡**】才分得開｜★★**三個預測類別**：(A) 格是 func ＋ 橫幅在 `_initialize` ⇒ **預測有洞**（6 支）／(B) `_run` 型 ＋ 橫幅在 `_initialize` ⇒ **預測有洞**（8 支，★格死掉 ⇒ `_run` 死 ⇒ 橫幅照印）／(C) `_run` 型 ＋ **橫幅印在 `_run` 裡面** ⇒ **預測免疫**（3 支，timeout 簽名）｜★★★**而我要自己說清楚：這張表【也是代理值】** —— 它預測的是「橫幅會不會活下來」，**不是「已確認會踩到」**；★**4 支「?」我沒有硬猜**，逐支列出來等注射｜★另有 4 支 reviewer 說的已有等價守衛（`SECTIONS=n/n`）在表裡標了 `守衛=y`

# 一、★為什麼我沒有照你說的「一個數」交

你要的是：**本地 `func _test*／_report*` 支數**（0 ＝ inline ⇒ 免疫）。
★**我先照做了，結果 13 支落在同一格**：它們的 `_initialize` 只呼叫 **`_run()`** 一支，
而真正的格在 `_run` 裡面 ⇒ ★★**那個數把「格 inline」與「格藏在 `_run` 裡」混成同一類**，
**而這兩類的命運相反**（見下 (B) 與 (C)）。
⇒ ★★★**我加了第二軸：`expect` 那一行【印在哪一支 func 裡】** —— 它才是決定「格死掉之後橫幅還在不在」的那個事實。

# 二、表（21 支）

```
gate                       bed                                      cells banner        _run 底下子格                守衛
── (A) 格是 func ＋ 橫幅在 _initialize ⇒ ★預測【有洞】 ──────────────────────────────
gateA-hysteresis           gateA_hysteresis_test.gd                 5     _initialize                                
ledger-drop-visible        ledger_drop_visible_test.gd              4     _initialize                                
restock-burn               restock_min_from_burn_bed.gd             4     _initialize                                y
gather-purity              gather_observation_purity_bed.gd         3     _initialize                                y
plan-speed                 plan_speed_move_cost_test.gd             3     _initialize                                y
team-ui                    team_ui_test.gd                          3     _initialize                                
── (B) _run 型 ＋ 橫幅在 _initialize ⇒ ★預測【有洞】（格死 ⇒ _run 死 ⇒ 橫幅照印）──
board-price                board_price_carry_test.gd                1     _initialize   1:_mk_outpost                
envoy-ptype                envoy_ptype_reconcile_test.gd            1     _initialize   0:                           
escrow-audit               escrow_audit_test.gd                     1     _initialize   3:_mk,_team,_tile            
minor-merge                minor_population_merge_test.gd           1     _initialize                                
valuation-clamp            valuation_clamp_reconcile_test.gd        1     _initialize   1:_mk                        
wage-penalty               wage_penalty_test.gd                     1     _initialize   1:_mk_team                   
world-schedule-due         world_schedule_due_test.gd               1     _initialize   2:_new_fire_ticks,_old_...   
fp-longwindow              fp_longwindow_determinism_bed.gd         1     _initialize                                y
── (C) _run 型 ＋ 橫幅【印在 _run 裡面】 ⇒ ★預測【免疫】（timeout 簽名）────────────
bed-arm                    bed_arm_gate.gd                          1     _run          5:_builds_world,_gather,…    
build-duration             construction_duration_source_gate.gd     1     _run          1:_gather                    
ki-anchor                  known_issues_anchor_gate.gd              1     _run          1:_gather                    
── (?) 我的定位器沒對上，★不猜 ────────────────────────────────────────────────
belief-freshness-invariant belief_freshness_invariant_test.gd       1     ?             1:_mk_team                   
grudge-ledger-a            grudge_ledger_bed.gd                     1     ?             3:_mk_person,_undecidable,…  
raid-expected-value        raid_expected_value_bed.gd               1     ?             2:_ctx,_run_desperation_cell 
stale-pos-recon            stale_pos_recon_bed.gd                   1     ?             4:_bed_self_check_tree,…     
```
★「?」的成因是**我的 key 抽法**：那四支的 `expect` 帶正則跳脫（`量測完成；\[FAIL\]…`），
我用字面去比對就對不上。★★**我可以修抽法，但我不想用「修好的抽法」直接下結論** —— 它們照樣要注射。

# 三、★★★這張表【也是代理值】（我自己先講）

★**它預測的是「橫幅會不會活下來」，不是「已確認會踩到」** ——
★★**跟 `_init` 呼叫數同一個身分**，只是離因果近一步（因為「橫幅活不活」正是 expect 命中與否的直接原因）。
⇒ ★★★**所以表的用途是【排批次】，不是【下判決】**；每一支仍然先注射再決定，
**而 (C) 那三支我預測免疫 —— 如果注射之後它們照印通過，那就是我這張表錯了，我會照實回報。**

# 四、下一批（★按【類別覆蓋】挑，不按數字）

```
(A) gateA-hysteresis   （5 格，最典型的暴露形狀）
(A) ledger-drop-visible（4 格，★它的格名自帶「跨 run reset」語意，跟前兩批不同族）
(B) escrow-audit       （★(B) 類第一支：格藏在 _run 裡、橫幅在 _initialize）
(C) bed-arm            （★(C) 類第一支，預測免疫；★★而它本身就是【掃全部床】的那支閘 ⇒ 形狀最特別）
(?) grudge-ledger-a    （★「?」類第一支，而且它有【不可判】語意，expect 釘的是兩個數）
```
★**五支涵蓋四個類別** —— 照第一批那個理由：**產出是樣板，樣板要涵蓋形狀。**
★★**你點頭我就開跑**；若你要先看 (C) 那三支的注射結果再決定要不要往下做，也可以。
