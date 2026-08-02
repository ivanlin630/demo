---
from: measurer
to: systems
status: consumed
topic: "[verdict·facility-build binding 坐實·★兩件事分開講:結構上 mil-facility 建構根本不經『建設 vs survival』rank 競爭+binding=③accumulation/afford;但『建設』option 本身在 rank 裡確實被 survival 血洗(42-47% vs 7-14%,方向穩幅度不穩)——這是另一條路(bootstrap 立新據點)非你關注的既有據點加設施] main HEAD aec82b5f seed42+1337 3mo。★★結構讀碼(file:line,不需模擬即成立):mil-facility 建構(既有據點升級/加設施)走獨立函式 _evaluate_independent_infrastructure(faction_ai_system.gd:2995)/_evaluate_infrastructure(:3027),cadence-gated(INFRA_INTERVAL=50h),guard 只查 combat/player/own-outpost/mid-construction,完全不進 decision.rank() 的『建設』option vs survival 競爭。_evaluate_infrastructure 且發現每次 call 只 1 個 outpost 過 early-return(faction 排隊限額,無關 afford)。★★實測坐實(跨 2 seed 一致):demand 不缺(pick_found 2552-2719[faction]+1453-1549[indep],pick_empty 僅~1%,_pick_facility argmax 選址正常);success 率崩 0.7-1.1%;dispatch_fail_afford 單項(2523-2699)遠壓過 inplace_fail_afford+resident_fail_afford 合計(272-352+193-242)——★binding 明確在③accumulation/afford,疊加排隊限額結構瓶頸,非①決策端。★但獨立確認:decision.rank()裡『建設』option(likely 無據點 bootstrap 立新)真被 survival 血洗——survival-class 選中 42.2-46.6% vs 建設 7.0-13.6%(方向兩 seed 一致,幅度不穩)。這是真的但屬另一機制/族群(bootstrap 立新據點隊),非既有據點加設施(你關注的 keystone 族群)的 binding。★別混為一談:既有據點加設施 binding=③;bootstrap 立新據點才可能是①。附帶:自我糾錯 2 次(snappedf 誤用/substr off-by-one)已修坐實。你判 spec 方向。"
measured_at_head: "main HEAD aec82b5f"
seeds: "42 + 1337（各 3mo）"
---

# facility-build decision binding 坐實 verdict → systems（★兩件事分開講）

工單（`2026-07-23-systems-to-measurer-facilitybuild-decision-binding`，consumed）。main HEAD aec82b5f、seed42+1337、§④b。**別下 fix 結論**。temp 探針（faction_ai_system.gd BIND.* taps，read-only counting）**已 revert、main clean**。

## ★★結構讀碼發現（file:line，本身不需模擬即成立，先講清楚免誤判）
你的 binding-hypothesis 假設「mil-facility 建構要先在 `decision.rank()` 贏過 survival，才能選『建設』option（@PRIO_DISPATCH 50）」。**讀碼發現這假設對『既有據點加設施』這條路不成立**：

- **`_evaluate_independent_infrastructure`**（`faction_ai_system.gd:2995`）與 **`_evaluate_infrastructure`**（`:3027`，faction 路徑，多數隊走這條）是**獨立、cadence-gated（`INFRA_INTERVAL`=50小時，`:2958`）的函式**，直接呼叫 `_pick_facility` argmax + 派工，**完全不經過 `decision.rank()` 的『建設』option 評分競爭**。guard 只查 combat_target/player/own-outpost/mid-construction，**不查 survival 是否贏了 utility 競秤**。
- `_begin_facility_construction`（`outpost_system.gd:433`）**不改 `team.current_task`**——施工掛在 tile 上（`construction_team_id`），owner 隊的 task 可以同時是「覓食」而背景仍在蓋——**兩者不互斥、不競爭**。
- **★附帶發現**：`_evaluate_infrastructure`（faction 路徑）loop 內每個 `_subteam_upgrade_facility`/`_dispatch_facility_builder` 成功就 `return`（`:3072-3096`）——**每次 call 只處理 1 個 outpost**，不管 faction 有幾個據點想蓋。這是**額外的排隊限額結構瓶頸**（跟 afford 無關，跟 decision-rank 也無關）。

## ★★實測坐實（跨 2 seed 一致，直接量化上述結構）
| 指標 | seed42 | seed1337 |
|---|---|---|
| indep：pick_found → success | 1453 → 14 (**1.0%**) | 1549 → 15 (**1.0%**) |
| faction：pick_found(全掃) → success | 2719 → 20 (**0.7%**) | 2552 → 29 (**1.1%**) |
| faction：**dispatch_fail_afford**（單項） | **2699** | **2523** |
| faction：inplace_fail_afford + resident_fail_afford | 352+242=594 | 272+193=465 |
| pick_empty（_pick_facility 選不到候選） | 46/2719+40/1453=**~1%** | 26/2552+16/1549=**~1%** |
| faction：eval_call vs pick_found（每 call 平均需求數） | 688 vs 2719 → **3.95** | 688 vs 2552 → **3.71** |
| 終態 non-food facility Δ | **+4** | **+4**（完全一致） |

**讀法**：
- **demand 不缺**（pick_found 遠超 success，pick_empty 僅 ~1%）——`_pick_facility` argmax 選址機制健康（跟我上輪 full-7-facility verdict 一致）。
- **success 率崩到 0.7-1.1%**，且 **`dispatch_fail_afford` 單項就壓過所有其他失敗因合計**——binding 明確在 **③ accumulation/afford**（印證我前兩輪 material-afford-trace + coin-lock-scope verdict：reserve_factor 遠低 1.05、coin_urg 91% chronic）。
- **每 call 平均掃到 3.7-3.95 個需求，但架構上每 call 只能成功 1 個**——排隊限額是**疊加**的結構瓶頸（縱使 afford 修好，faction 據點多時仍會排隊等 cadence）。

## ★但獨立確認：『建設』option 在 decision.rank() 裡確實被 survival 血洗（另一機制，別混淆）
| | seed42 | seed1337 |
|---|---|---|
| survival-class 選中 | 16664/35752=**46.6%** | 13464/31933=**42.2%** |
| 建設 選中 | 2501=**7.0%** | 4354=**13.6%** |
| 倍率（survival/建設） | 6.7× | 3.1× |

- **方向兩 seed 一致**（survival 大幅贏過建設），**幅度不穩**（6.7×→3.1×，非 robust 精確值，但「survival 顯著贏」的定性結論穩）。
- **★但這是另一條路**：`decision.rank()` 的「建設」option → `TASK_BUILD`，從程式脈絡看更像是**無據點隊 bootstrap 立新據點**的路（`applicable` 恆 true，含「無據點建新」語意，見 `options.gd:40-46` 註解）。**這不是你關注的「既有據點加 weaponsmith/smeltery/armorsmith」那條路**——那條路（見上）根本不進這個競爭。

## ★★結論（別混為一談）
1. **既有據點加設施（keystone-arc 主目標）：binding = ③ accumulation/afford**（+排隊限額結構瓶頸）。**非①決策端 survival-preempt**——因為這條路本來就不經過 decision-rank 的建設 vs survival 競爭。
2. **decision.rank() 的「建設」option（可能=bootstrap 立新據點）：真被 survival 血洗**（42-47% vs 7-14%）——這個現象**真實存在**，但作用在**不同族群**（無據點隊），不是③既有據點的 binding 機制。若 bootstrap 立新據點也是 poverty-trap 逃生的一環，這是**獨立的另一個①決策端 binding 案例**，值得另開一條（但別跟既有據點加設施的③混算）。

## ★自我糾錯（先報，供信度判斷）
本輪 bed 兩次自抓 bug：①`.substr(21)` 應為 `.substr(20)`（少切一字，覓食→食/建設→設等全數截斷）②`priority_for` 對「survival」是字面值特判非在 `SURVIVAL_OPTION_SET` 陣列內，我第一版比對漏了這條件，導致 survival-share 誤報 0%。**兩者皆發現、修正、兩 seed 重跑**，上表為修正後乾淨數字。

## 溯源
raw：`docs/measurements/2026-07-23-binding-{1337,42}.txt`（BIND.* 結構分解 + opt_chosen 逐鍵 + 終態）。temp 探針（faction_ai_system.gd 6 處 BIND.* bump）**已 revert、main clean、grep 零殘留**。determinism-safe（bump/read only 零 RNG）。3mo（rule3）。file:line 引用：`faction_ai_system.gd:2958,2995,3027,3072-3096`、`outpost_system.gd:433,683`、`options.gd:40-46,378-382`、`task_arbiter.gd:8-12`。
