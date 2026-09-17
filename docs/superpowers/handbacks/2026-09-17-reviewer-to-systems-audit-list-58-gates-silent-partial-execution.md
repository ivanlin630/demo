---
from: reviewer
to: systems
status: open
slice: 系統性風險（GDScript部分函式靜默中止）｜58支已註冊閘的實際稽核清單
topic: 清單來了——30支godot床全部逐支開檔核過（非猜），4支已有等價guard、26支結構暴露但未逐支證實真的會踩到；28支bash hook不在這個機制的暴露範圍
---

# 分類（58支，非猜，逐支核過指令欄位）

```
godot .gd 床（GDScript func靜默中止這個機制才適用）＝30支
bash hook（不同機制，本次不稽核）＝28支
```

# 已有等價guard（4支，低優先）

```
plan-speed         SECTIONS=n/3    ← expect欄本身就是roll-call
restock-burn       SECTIONS=4/4
gather-purity      SECTIONS=7/7
fp-longwindow      SECTIONS=1/1
```
這4支的expect已經把「跑完幾格」寫進去，跟outpost-belief這次補的「到場點名」同一個形狀，
不需要動。

# 結構暴露、目前沒有guard（26支，逐支核過`_init`裡呼叫幾個本地func，當暴露面代理值）

**按呼叫數降冪排（數字越大＝驅動的cell越多＝一個cell靜默死掉被吃掉的機會越多）**：

| id | 床 | _init內呼叫本地func數 |
|---|---|---|
| ui-flow | ui_flow_test.gd | 27 |
| unified-commerce | unified_commerce_test.gd | 12 |
| ui-logic | ui_logic_test.gd | 12 |
| merchant-turnover | merchant_turnover_test.gd | 10 |
| own-camp-link | zhagen_controlled_bed.gd | 9 |
| material-buy | material_buy_test.gd | 8 |
| gateA | gateA_test.gd | 8 |
| payroll-urgency | payroll_urgency_test.gd | 8 |
| gateA-hysteresis | gateA_hysteresis_test.gd | 7 |
| minor-merge | minor_population_merge_test.gd | 7 |
| ledger-drop-visible | ledger_drop_visible_test.gd | 6 |
| team-ui | team_ui_test.gd | 4 |
| constitution | constitution_gate.gd | 4 |
| valuation-clamp | valuation_clamp_reconcile_test.gd | 3 |
| world-schedule-due | world_schedule_due_test.gd | 3 |
| envoy-ptype | envoy_ptype_reconcile_test.gd | 3 |
| board-price | board_price_carry_test.gd | 3 |
| escrow-audit | escrow_audit_test.gd | 3 |
| wage-penalty | wage_penalty_test.gd | 3 |
| grudge-ledger-a | grudge_ledger_bed.gd | 3 |
| raid-expected-value | raid_expected_value_bed.gd | 3 |
| stale-pos-recon | stale_pos_recon_bed.gd | 3 |
| build-duration | construction_duration_source_gate.gd | 3 |
| bed-arm | bed_arm_gate.gd | 3 |
| ki-anchor | known_issues_anchor_gate.gd | 3 |
| belief-freshness-invariant | belief_freshness_invariant_test.gd | 2 |

# ★誠實限（這份清單證明什麼、不證明什麼）

**證明**：這26支的`_init`都是「呼叫多個本地func、最後印一行總結」這個形狀——跟我複現的那個
洞完全同構（外層driver不受內層func中止影響）。**呼叫數是暴露面的代理值，不是「已確認會踩到」
的證明**——沒有陽性對照（故意讓某個cell在中途丟一個runtime error，看總結行還印不印PASS），
我不能對任何一支寫「這支有洞」。

**★這正是站上自己立過的規矩（`merge-gates.tsv:37-40`：新閘註冊前必須陽性對照）**——
★★要把這份清單從「結構暴露名單」變成「確認名單」，每支都要做一次同樣的陽性對照，
這是一次性的、可分批的工作，不是我這封信能單靠靜態讀completed的。

# 建議優先序（給你排工，不是我裁）

```
1. constitution（憲法閘，破了影響最大，即使呼叫數不是最高）
2. ui-flow／unified-commerce／ui-logic（呼叫數最高，暴露面最大）
3. own-camp-link／material-buy／gateA／payroll-urgency（次高，且都是行為機制而非UI展示）
4. 其餘依清單序
```

# 附：28支bash hook（本次不稽核，理由）

bash hook走的是shell自己的錯誤處理（`set -u`/exit code/pipefail），跟GDScript「func錯誤只
中止該func」是不同機制——是否有類比的「某個shell函式中途死掉、外層腳本吃掉繼續」的洞，
是另一個問題，需要另一輪查，本封不宣稱查過。
