---
from: implementer
to: systems
status: consumed
slice: 附身隊後續三件（甲 AI 不掛單／乙 挨餓停推進／丙 loop3 寫者分類）
topic: 請 merge fix/possessed-followups 443693bf0（已併 main 06a40cb3d）｜全電池釘死 443693bf0：129 支全綠（BATTERY_RC=0，總時 5720s）｜甲 >20% ⇒ 附身時撤；乙 ≤1 次／天 ⇒ 不節流；丙 三支入口修、四欄只列
---

# 附身隊三件：可以 merge

## 電池
- ★第一次釘 7b2864996（run-id 3053-20261014-201641）：129 支只紅 bed-kind 一支。`possessed_famine_stop_bed.gd` 宣告 acceptance，卻沒有 `slice:` 欄。443693bf0 補了一行註解，bed-kind 單跑 PASS（觸及 6 支、紅 0）。改完整套重跑：
- detached worktree `.worktrees/mm2neg` 釘死 `443693bf0`：129 支全綠（BATTERY_RC=0，總時 5720s），run-id `699-20261014-215229`。
- 原始輸出：`docs/measurements/2026-10-14-possessed-followups/battery-443693bf0.txt`（main，隨本信同 commit）。
- 其餘量測原始輸出：同目錄（fix/possessed-followups 上）。檔頭寫了截法與樹 sha。

## 分支 `fix/possessed-followups`（已推）
- c7df4d14b 甲本體＋床＋乙量測床 → 4dd8c2f4b 丙寫入觀察（TeamData 23 欄 setter，只計被觀察那一隊）＋甲殘單量測床
- → 6c7573105／8ff8ef83b 併 main（第二次是玩家子隊 merge 之後）→ 08a6a45cb 乙量測床修對照世界
- → 6a0337e20 甲撤單、乙停點、丙三支 return、兩張新床 → 7b2864996 到場點名、註冊表三行、team.md
- → 443693bf0 famine 床補 `slice:` 欄（第一次電池唯一紅格，見下）＋量測落檔

## 量測世界
- 全部跑在 08a6a45cb（＝main 06a40cb3d＋本分支量測床）。
- ★第一輪跑在併玩家子隊之前的樹，結果作廢重跑（玩家子隊在 loop3 多處加了 player_controlled 跳過，涵蓋附身隊本身）。兩輪數字相同，只交第二輪。

## 甲：AI 不替附身隊掛單＋附身時撤殘單
- `tick_team_orders`：到期清理／退貨照跑，之後 `team.possessed` ⇒ return（掛單三段不跑）。
- 殘單量測（`residual-orders-08a6a45cb.txt`，seed 1337／2，第 5／10／20／30 天，每支非玩家真隊當候選）：
  - 開局附身：玩家隊殘單 0 張。
  - 中途附身代理：每個時點有 1–3 隊押貨超過 20%，最高 99.8%（seed 2 第 5 天 T7：material 18/18）。押的全是 material（寄賣）。
  - ⇒ **>20% ⇒ 照 spec 改成附身時撤**：`WorldState.sync_possession` 的 false→true 邊呼 `OrderSystem.withdraw_on_possession`，逐張走 `release_order_escrow`（押貨落該格待領帳），不記失敗記憶。
  - ★誠實限：中途附身是代理（每支隊都當候選），不是玩家真的會挑的那支；扣住比例的分母小（1–18 單位）。
- `post_order` 全部呼叫端：

| 呼叫端 | 類 |
|---|---|
| order_system.gd:298 餘量賣盤 | 決策層（附身隊不跑） |
| order_system.gd:311 短缺買單 | 決策層（附身隊不跑） |
| order_system.gd:321 糧買單 | 決策層（附身隊不跑） |
| order_system.gd:338 `_tick_food_granary_sell` | 決策層（在 return 之後，附身隊不跑） |
| player_command_api.gd:163 `_post_order`（:153 買／:156 賣） | 玩家指令（照舊） |

- 到期退貨玩家看不看得到：scripts/ui、player_query_api、player_api_mapper 對 `active_orders`／`market_escrow`／`release_order_escrow` 零引用 ⇒ 看不到（玩家只有 player_command_api 的掛單／撤單）。照 spec 交你記 known_issues「掛單與 escrow 對玩家不可見」。
- 床 `possessed_orders_bed`（註冊表 `possessed-orders`）：A1／A1b 附身隊 0 張、NPC 對照 6 張；A2 押貨 10 ⇒ 附身那一刻單與押貨帳都撤、貨總量 400→400、對帳零違反；A3 玩家自己的賣單照常。

## 乙：開始挨餓 ⇒ 推進停下
- 先量（`famine-rate-08a6a45cb.txt`）：附身 30 天，seed 1337／2 × 待機／每天狩獵。

| 世界 | famine_crossed 總數（事件／輪詢） | 單日最多 | 挨餓天數 |
|---|---|---|---|
| 1337 待機 | 1／1（第 6 天） | 1 | 23.7 |
| 1337 狩獵（18/30 成功，入帳 70.9） | 0／0 | 0 | 0 |
| 2 待機 | 1／1（第 6 天） | 1 | 23.7 |
| 2 狩獵（20/30 成功，入帳 13.5） | 0／0 | 0 | 0 |

  - ⇒ 兩世界都 ≤1 次／天 ⇒ 照 spec 改、不節流。
  - ★兩個種子的待機列逐字相同：玩家隊待機、零進項 ⇒ 糧軌跡只由消耗決定（同世界的甲量測兩種子不同 ⇒ 種子有生效）。
  - ★對照世界第一版只在原地獵：開局格無獵物 ⇒ 30／30 失敗、零進項 ⇒ 不可判。改成腳下沒獵物先走到最近獵場（挑格讀格子真值，床扮玩家）；零進項會印「不可判」。
  - ★誠實限：狩獵世界糧從沒歸零 ⇒ 「糧在 0 附近震盪」那個情形兩世界都沒走到；由床 B3b 人造佈置驗（震盪兩次＝停兩次）。spec 的對照寫「每天下一次覓食」，附身隊沒有覓食指令，用狩獵代。
- 改法：`ADVANCE_STOP_KINDS` 加 `famine_crossed`；`describe` 專屬句「<隊>：存糧吃完，開始挨餓（再 N 天開始有人餓死）」，N 讀 `ResourceSystem.FAMINE_GRACE_DAYS`；停點註解補挨餓與量測出處。
- 床 `possessed_famine_stop_bed`（`possessed-famine-stop`）：
  - B1 停在 tick 96＝挨餓事件 tick 96；結果行「Team15：存糧吃完，開始挨餓（再 7 天開始有人餓死）」。
  - B2 別隊（T0）挨餓，那一天的停點只有 forced_event_arrived。
  - B3 挨餓中再按 X：不停在挨餓（那一輪被別的事件在 1135 tick 處擋下、kind 空——是 bridge 的其他停止條件，不是挨餓）。
  - B3b 一日量 8.0、每次餵 4.8×2 ⇒ 耗盡 2 次、停點 2 次。
  - ★B3b 第一版少數一次：玩家事件壽命一小時（sim_runner 清），事後掃匯流排第一筆早被清 ⇒ 改成每個 tick_step 之後記 seq。
- terminal E2E：電池綠（含 terminal-e2e）⇒ 沒有既有步驟因多停一次而改變。

## 丙：loop3 對附身隊還會寫的欄位
- 寫入觀察（`writers-prefix-08a6a45cb.txt`）：seed 1337／2 × 30 天 × lead（玩家當隊長）／member（玩家移入 NPC 隊當成員），共 4×43200 tick，遭遇 draw 0、換隊 0。
- 修後重跑（`writers-postfix-7b2864996.txt`）：同 4 個世界，修了的那四欄（decision_eval_next_tick、current_option、last_decision_tick、residency_eval_next_tick）兩情形都 0 次寫入。
  - 留下的：lead／member 都還寫 prosperity_target_id、occupying_outpost_since、mobilized_fraction、equip_order、armor_config、guard_ratio（各 1438），就是表裡「只列」與「照跑」那幾欄。
  - ★member 還寫 persist_strength 1476 次（修前 2914），值一次都沒變。`PersistStrength.compute` 會把結果寫回 `team.persist_strength`；`_decide_unified` 之外它有三個呼叫點：`select_strategic_intent`、`_evaluate_independent_strategy`、`_try_self_relocate`（faction_ai_system.gd:1828／2239／3156）。我沒逐一釘是哪一支。值不變、沒有東西因此改動，所以沒修，列在這裡。

| 欄位／函式 | 寫者 file:line（fix/possessed-followups） | 30 天命中（寫／值變） | 類 | 理由（三問） | 處置 |
|---|---|---|---|---|---|
| decision_eval_next_tick、last_decision_tick、current_option、persist_strength（member） | `_decide_unified` 本體（faction_ai 入口；四個入口都匯進來） | member 各 1438／719（current_option 變 2–3 次：駐守→建設→maintain_tools） | 決策 | ③：current_option／承諾被引擎與 churn 讀；本體還跑承諾停滯偵測 | **修**：入口 `possessed` return（C1） |
| residency_eval_next_tick | `_evaluate_outpost_residency` | 20／20（兩情形皆有；這組世界玩家無自家據點 ⇒ 沒派） | 決策 | ①②：替玩家派子隊（帶走 2–5 人）或邀流亡 | **修**：入口 return（C2） |
| `CoinTreasury.consider_extraction` | coin_treasury.gd `consider_extraction` | 函式層 0（這組世界沒缺口） | 決策 | 金額＝缺口＋隊長人格 buffer ⇒ AI 評分；member 時 `leader_id==player_id` 那道門不生效 | **修**：`possessed` return（C3）；玩家有 extract_treasury |
| mobilized_fraction | `_update_mobilization` | 1438／178–375 | 決策 | ①：人格＋威脅決定抽多少勞力當兵（還觸發 labor 重算） | 只列（玩家有 set_armed_anon_ratio 武裝比例，兩者關係要裁） |
| equip_order | `_update_equip_order` | 1438／294–718 | 決策 | ①：配哪種武器 | 只列 |
| guard_ratio | `_update_guard_ratio` | 1438／178–375 | 決策 | ①③：人格＋威脅決定守衛比 | 只列 |
| armor_config | `_update_armor_config` | 1438／1（lead）、719（member） | 決策（無人格的預設配裝） | ①：穿上玩家沒選的甲 | 只列（玩家沒有配裝指令） |
| prosperity_target_id | `_refresh_attack_pursuit` 清值分支 | 1438／0 | 記帳（清理） | 值恆 -1 | 照跑 |
| 　同上設值分支＋pursuit 直寫 move_target | `_commit_conquest_attack`、`_evaluate_independent_strategy`、`_wire_threat_task`；pursuit 在 `prosperity_target_id == -1` 先 return | 值變 0 ⇒ 設值分支 0 次 | 不可達（這組世界） | — | — |
| occupying_outpost_since | `_evaluate_outpost_takeover` | 1438／0 | 物理（世界規則：駐留無主據點 3 天接管，gate-ok world-mechanic） | 不論誰操控都會發生 | 照跑 |
| previous_task、order_target_id、order_task、survival_committed_*、ambition_rung、pending_owner_change_tick、crisis_released_*、crisis_committed_*、FailureMemory.record | （求生／威脅／野心層／owner_contact／crisis 窗） | 兩情形 0 | 不可達（這組世界） | 併玩家子隊後 `_evaluate_survival`／`_evaluate_threat`／loop3 野心層對 player_controlled（含附身隊）跳過 | — |
| 讀碼另見、未觀察 | `_auto_withdraw_mounts`（出征時從自家據點公庫拉坐騎） | 未掛觀察 | 決策 | ①：替玩家拉坐騎 | 只列 |

- 「不可達」只對這組世界（2 種子 × 30 天 × 2 情形）成立；命中 0 不是證明。
- crisis 免疫窗（faction_ai:640-646 那段）的欄位命中 0。
- 床 `possessed_writers_bed`（`possessed-writers`）：C1 附身隊一天內 last_decision_tick 0→0、NPC 對照 0→1075；C2 NPC 對照派 2 支、附身隊 0；C3 NPC 對照公庫 500→290.7、附身隊 500 不動。

## 修前／負對照
- 修前（scripts/simulation＋scripts/data 回 main 241d070ec，床用新版）：possessed_orders 紅 4、possessed_famine_stop 紅 5、possessed_writers 紅 3（`bed-prefix-*.txt`）。
- 負對照（各拔一刀；`neg-n1…n6.txt`）：

| 拔哪刀 | 紅哪格 |
|---|---|
| n1 tick_team_orders 的 possessed return | A1、A1b、A2 末格 |
| n2 sync_possession 的撤單 | A2（撤下＋末格） |
| n3 ADVANCE_STOP_KINDS 拿掉 famine_crossed | B1 三格、B3 地板、B3b |
| n4 _decide_unified 的 return | C1 |
| n5 _evaluate_outpost_residency 的 return | C2 |
| n6 consider_extraction 的 return | C3 |

## 要你知道的
- 4dd8c2f4b 的寫入觀察在 TeamData 23 欄上加了 setter（只在 `team_id == mt_watch_tid` 時記，預設 -9999）。★電池註冊表裡沒有專門的效能閘（grep perf／hob／cost 只中 plan-speed、phase-tree-net-cost，都不是 per-tick 比對）⇒ setter 的成本【沒量】；要量請派量測員雙 checkout 比 per-tick。
- world-fp：電池內 world-fp ✓（597s）、world-fp-ctrl ✓（1245s）——基準沒換，世界逐位相同。
- known_issues 三筆（附身隊掛單／loop3 其餘寫者未分類／挨餓不停推進）我沒動，交你：甲、乙已修；丙剩「只列」那五項等你開票。另加一筆「掛單與 escrow 對玩家不可見」。

## 已消費的 GO
- `2026-10-13-systems-to-implementer-GO-possessed-team-followups.md`

## 下一輪
- 照你的序：移動預計時間（GO-move-eta-same-ruler）。
