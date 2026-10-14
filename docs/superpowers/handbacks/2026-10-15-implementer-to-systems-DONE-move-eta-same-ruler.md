---
from: implementer
to: systems
status: consumed
slice: 移動預計時間＝物理同一把尺（spec 2026-10-13-move-eta-same-ruler-HOW）
topic: 請 merge fix/move-eta-same-ruler 9723d7656（已併 main 8425044a2）｜全電池釘死 9723d7656：130 支全綠（BATTERY_RC=0，總時 4439s）｜E1–E5 估算＝實走 tick 精確、world-fp 不動｜★疲勞 0% 判成 (d) 的一種，但修它會動 world-fp ⇒ 沒修，等你裁
---

# DONE：移動預計時間＝物理同一把尺

## 電池
- detached worktree `.worktrees/mm2neg` 釘死 `9723d7656`：130 支全綠（BATTERY_RC=0，總時 4439s），run-id `1606-20261015-013445`。
- 原始輸出：`docs/measurements/2026-10-15-move-eta/battery-9723d7656.txt`（main，隨本信同 commit）。
- 同資料夾：`move-eta-bed.txt`（床全文，9723d7656 clean）、`neg-n1.txt`、`neg-n2.txt`（同 sha 加一處負對照改動）、`battery-d6f6a6610.txt`（第一輪，紅 bed-arm）。

## commit（branch fix/move-eta-same-ruler）
| sha | 內容 |
|---|---|
| c0cb3b31c | 估算器：`MovementSystem.run_window`（process 與估算器共用的單窗口算術）、`estimate_travel_ticks`（影子 pos／acc 逐窗跑，每步呼 `next_step_pure`，不呼 `_step_team`）、`belief_known_tiles`、`move_cost_at_pure(…, known)`；`PathSystem.find_path_belief`（不讀寫 `_path_cache`）；`DayNightSystem.period_at／speed_mult_at` static；`move_to` 句子改讀估算器（「預計／至少／預計超過／算不出」） |
| 819b5dad1 | 抵達句「抵達 (q,r)（走了 N 分鐘）」：SimBridge 在逐 tick 推進迴圈裡記抵達 tick（不放 TeamData／WorldState：放進去會進 world-fp 或撞 derived_excludes 棘輪）；multi_hop 床 P1／P2 改比前綴 |
| e699ba094 | `scripts/debug/move_eta_bed.gd`（acceptance，16 格點名） |
| da2a724b8 | docs/team.md 移動段改寫；known_issues AI 估路程那條回填低估量 |
| 09cf716ba | 併 origin/main（附身隊三件；無衝突） |
| d6f6a6610 | 註冊表登 `move-eta` |
| 7ca0ef53f | 床建世界改走 `MeasureBedHelper.arm_and_setup(cfg, false)`（第一輪電池 d6f6a6610 紅 bed-arm 一支，run-id 2443-20261015-000426；其餘 129 支綠）；E7 不再自己 arm |
| 9723d7656 | 再併 origin/main（docs only） |

## 床（move_eta，16／16 到場、errors 0）
| 格 | 佈置 | 估算 | 實走 |
|---|---|---|---|
| E1 陽性對照 | 10:00 整點、平原兩格 | 840 | 840 |
| E2a／E2b | 整點後 1 分／前 1 分 | 839／841 | 839／841 |
| E3a／E3b | 20:50／21:10 下令（跨 21:36 入夜） | 670／710 | 670／710 |
| E4 | 森林帶、起始 acc 100 | 1305 | 1305 |
| E5 | 6 格、等代價路多、跨夜 | 2280 | 2280 |
- E6：同一趟逐 tick／SimBridge 60 一塊／37 一塊 ⇒ 抵達 tick 都 1440、N 都 799＝估算 799；畫面抵達句讀 bridge 那筆。
- E8：視野外一格是山 ⇒ 句子「至少 2279 分鐘」＝那格當平原的估算；真實已知會是 2519（不洩露迷霧）；實走 2519 ⇒ 下界成立。
- E9：估算前後 `_path_cache` 大小差 0；跑估算與不跑估算的世界，真移動逐格相同。
- SRC：超載 839→1439，兩者都＝實走；結構 grep：process 與估算器都呼 `run_window`、檔內步進迴圈只有一份。
- R 殘差（只印、不放寬）：R1 起始疲勞 0.80 ⇒ 估算 2279、實走 1679（−26.3%，路上疲勞回到 0.40）；R2 糧吃掉變輕 0%；R3 中途加 20 人 0%。
- AI 舊估算（`_estimate_eta_to`）：21:50 平原兩格 480 對實走 670 ⇒ 低估 28.4%（已回填 known_issues；這是一格的數，不是分佈）。

## 負對照
| 對照 | 結果 |
|---|---|
| n1 `move_to` 改回 `eta_ticks(hex_dist)` | 紅 13：E1–E5、E6、E8×2、SRC×2、AI |
| n2 估算器沿凍結路徑（不每步重規劃） | 紅 1：E5「估算器影子路＝實走的路」 |

## 跟 spec 不一樣的地方（三件，請你看）
1. **n2 只能靠「影子路」那格紅，分鐘數紅不了。** spec 寫「估算器改沿凍結路徑 ⇒ E5 紅」。第一版床只比分鐘數，n2 跑出來 errors 0。我接著在開發中掃了一批佈置（平原、散布森林、單排森林、偽隨機森林 × 10 個距離 6 的目標，10:00 下令）。凍結路與每步重規劃的路分岔的有好幾個，但兩條路**走的分鐘數沒有一個不同**。★那批探索跑的輸出沒留檔，數字不當證據；有檔的證據是 `neg-n2.txt`：n2 下只有影子路那格紅，E5 的分鐘數格是綠的。原因：兩條都是 A* 最低代價路，地形總和一樣；窗口量化之後，森林在第幾步出現也沒改到分鐘數。⇒ 只比分鐘的話，n2 是一個永遠綠的守衛。我改成讓估算器回傳影子走過的格（`path` 欄），E5 加比「影子路＝實走的路」。n2 就紅在這一格。這是在估算器回傳上**加了一個欄位**（只有算得出時才有），process 不變。
2. **E5 的佈置是挑出來的。** `_astar` 用 `sort_custom`（不穩定排序）破同分，所以哪個佈置會分岔，事先算不出來。E5 先用 `_astar` 靜態把候選走一遍，挑第一個分岔的（結果是全平原、目標 +(3,3)）。挑不到就紅「★E5 佈置」。地板仍比**實走**的路，不是比預演。
3. **沒有「修前跑」。** 床呼新 API（`estimate_travel_ticks`、`run_window`），在修前樹上 parse 不過；玩家句的修前行為由 n1 代表（n1 把 `move_to` 換回修前那一行）。SRC 也是代替品：常數改不了 runtime，所以用「超載輸入變了估算要跟著變」加結構 grep。

## ★要你裁：疲勞 0% 是 (d) 的一種，修它會動 world-fp
E7 探針：玩家隊下令走 6 格，跑 12 小時，玩家隊有 12 次疲勞 pass：
```
t612 0→0 回復（已是 0）    t719 / t749 / t834 / t864 同
t923 0.0000→0.0040 耗力｜這段有跨格
t966 0.0040→0.0000 回復
t1078 / t1126 / t1159 / t1214 / t1282 回復（已是 0）
```
- 12 小時只跨了 1 格（一格約 6 小時）。
- `fatigue_exertion` 的 "moved" 讀 `moved_since_fatigue`；它只在**那一窗真的跨了格**時被設（sim_runner.gd:501–503 讀 MovementSystem 回的 `moved` 名單）。走在半路、還沒跨格的 pass 一律算 "rest"，按 0.48／天回復。一次耗力 +0.004，下一次 pass 就回到 0。
- UI「疲勞」讀 `PlayerApiMapper` 的 `int(team.fatigue×100)`，**不是**成員 stress ⇒ (c) 排除。
- 判讀：最接近 (d)「moved 類落不到」。不過相位本身沒錯開：跨格那一次確實落到了。問題在「moved＝跨格」這個定義，對每格要走好幾小時的行軍來說太窄。另外也帶一點 (a)：一次耗力 0.004，畫面顯示 0%。
- **沒修的理由**：spec 說 (d) 由本票修，但又說 process() 行為逐字不變、world-fp 不動。任何修法都讓所有 NPC 行軍時累積疲勞，world-fp 一定會變。修法有兩種：一種是「有 move_target 且這窗 acc 有累積就算 moved」，另一種是 TASK_TRAVEL 進 `FATIGUE_EXERT_TASKS`。兩種都動票 T 的分類，屬於設計選擇。請你裁要不要開、開在哪張。

## 要你知道的
- eta worktree 的 `index.lock` 兩次留著沒人清：一次 2026-10-14 21:54，一次 2026-10-15 00:04:06（第一輪電池在 mm2neg 開跑那一刻）。兩次刪之前 `tasklist | grep -ci git` 都是 0。我沒查出是誰建的，只記時間。
- world-fp：電池內 world-fp ✓（460s）、world-fp-ctrl ✓（917s）；併 main 前（改動已在、尚未 commit）在 eta worktree 單跑過一次，`final_fp = 4a8102dec551e5c21c86105da0c5c54a` 與註冊表 expect 逐字相同。
- 估算器每次 `move_to` 跑一遍 A*×路徑長（belief 地圖、不進快取）。只有玩家下令時才跑，per-tick 不付成本；沒量時間。
- `PathSystem.eta_ticks` 本體留著（AI `_estimate_eta_to` 在用），上面加了註解指向真尺；AI 遷移照 spec 屬深層批。
