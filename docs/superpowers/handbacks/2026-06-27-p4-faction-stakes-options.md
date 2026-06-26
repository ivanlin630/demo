# Hand Back: P4 頂層 stakes options（徵收/外交）

## 實作摘要
- `scripts/simulation/decision/decision_context.gd`：移除 `faction_directive: String`；加 `const STAKES_SET=["攻擊","徵收","外交"]` + `faction_stakes: Array` + `faction_tribute_target(_pos)`/`faction_diplo_target(_pos)`。gather 改掃 STAKES_SET ∩ f.goals 填 `faction_stakes`，各 stake 設 target（攻擊/外交→`_nearest_independent`、徵收→`_richest_member` 並 `== team.team_id` 排自身）。
- `scripts/simulation/decision/terms.gd`：加 `const STAKES_DRIVE_BASE=0.3`；`faction_duty` eval 泛化為 match 攻擊/徵收/外交（各認對應 stake+target）；`attack_drive` 改讀 `"攻擊" not in ctx.faction_stakes`（等價舊 `faction_directive != "攻擊"`）；加 `levy_drive`/`diplo_drive` eval（×`_duty_factor`）；加 `levy`(貪婪.5+好戰.3)/`diplo`(義氣.5+計謀.3) weight。
- `scripts/simulation/decision/options.gd`：攻擊 applicable 改 `"攻擊" in ctx.faction_stakes`（**Task1 內就改**，見差異段）；REGISTRY 加 `徵收`/`外交` row；applicable 加 徵收/外交 守衛；to_task 加 徵收→TASK_TRIBUTE(_richest_member,排自身)/外交→TASK_DIPLOMACY(_nearest_independent)，皆不設 combat_target（非戰）。
- `scripts/debug/headless_test.gd`：P3 `_test_p3_faction_duty_term` 內 `ctx.faction_directive="攻擊"`→`ctx.faction_stakes=["攻擊"]`；加 `_mk_richer_member` helper + `_test_p4_stakes_terms`/`_test_p4_stakes_options`/`_test_p4_stakes_believability` 並註冊。
- `scripts/debug/p3_war_scenario.gd`：diag print `ctx.faction_directive`→`str(ctx.faction_stakes)`。
- `docs/invariants.md`：混合協調段更新 stakes 集合=攻擊/徵收/外交、各染色映射、target finder（含徵收排自身）、立國=leader-level/掠奪=日常個體/結盟⊂外交、危時 survival 碾壓對三 stake 皆然。

## 與 plan 差異
- **options.gd 攻擊 applicable（line 59）`faction_directive`→`faction_stakes` 同步併入 Task 1（plan 排 Task 2）**：因 Task 1 移除 `faction_directive` field 後 options.gd 此行立即 runtime 報 `Invalid get index 'faction_directive'`，`applicable` 中 攻擊 永不入候選 → P3 攻擊立即回歸。為守「P3 不回歸」最高約束、保每 commit 綠，把這一行 sync 提前到 Task 1 commit。語意等價，無行為改動。
- Task 3 的 believability test commit 為空：三個 P4 test 函式因共用 `_mk_richer_member` helper，於 Task 1 一次加入 headless_test.gd 並已隨 Task 1 commit。Task 3 無新增 test 程式碼可 commit（測已在樹中且綠），故未產生額外 commit。

## ⚠️ BLOCKER：P3 war_scenario 跟戰 2/4（baseline 3/4）— 待主 session 裁定
- **現象**：`p3_war_scenario.gd` 跟戰隊數 = **2/4**（baseline 期望 3/4）。忠誠好戰→攻擊、中庸→攻擊（仍參戰），**忠誠溫和 member 改選 `外交`（baseline 為 攻擊）**，叛逆→建設（不參戰，同 baseline）。
- **根因（非攻擊 option 回歸）**：scenario 的真實 `_update_goals` 對該好戰霸主派系設 `f.goals = ["徵收","外交","攻擊","掠奪"]`（一向如此）。P3 時只把 `攻擊` 抽成 member stake，徵收/外交/掠奪對 member 惰性。P4 後 `外交` 成 live option：忠誠溫和 member（好戰0.1、殘忍0.1、義氣/計謀取 default 0.5）→ `weight("attack")=0.33` vs `weight("diplo")=0.60`，faction_duty 項對兩 option 等值，故個人染色決勝 → 理性選外交。**攻擊 option 本身行為未變**（只攻擊一 stake 時等價）；是新增的競爭 option 改變了該 member 的選擇。
- **判斷**：依實作指令 #5「若跟戰數變 → 停，記錄，別硬改」，**未** 動 `_update_goals`/攻擊語意/option 權重去湊 3/4。此 2/4 在當前設計下是「可信」的（溫和成員偏好外交），但與 plan 寫死的 3/4 baseline 不符。
- **可能解法（待主 session 選，皆 plan-scope 外，我沒做）**：
  1. 接受 2/4 為新 baseline（承認外交競爭=可信湧現），更新 war_scenario 期望值。
  2. 調 war_scenario：給溫和 member 明確低義氣/低外交傾向，使其仍選攻擊（改測資料非改 code）。
  3. 設計層：stakes 間優先序（攻擊 directive 在場時壓低同隊 member 的外交 applicable），但這碰「多 stakes 排序」=願景債，需藍圖/系統裁。

## P3/守恆/world_sim 驗證
- **headless_test.gd**：`=== DONE ===` 無殘留 SCRIPT ERROR。P3 全綠（faction_duty term OK、attack option OK `soldier→ATTACK rebel→建設 peace→建設`、war believability `starving→覓食`）。P4 全綠（stakes terms OK、stakes options OK `levier→徵收 envoy→外交 rebel→建設`、believability OK `ug=0.199 um=0.067 starving→覓食`）。P2/buyfood 等既有測未見失敗。
- **framework_validation**：S1-S6 全 PASS（PASS=7 DORMANT=0）。
- **game_sim_multi（coin_eq）**：4 config 全 delta=0.00（game_sim_test/tyrant/merchant/warzone）。徵收/外交 stakes 湧現（tyrant 配置 unified member `task=徵收`、`Diplomacy propose_trade`），economy team 多數仍 貿易/生產（無 over-coordination）。
- **world_sim（2yr）**：跑到 月 24（tick=172800）DONE，無崩潰，InvariantViolation=0、SCRIPT ERROR=0。經濟隊 T4 全程 貿易（無被拉去 stakes），存活 2 隊。

## 連動風險
- **faction_stakes 重構**：所有讀舊 `faction_directive` 的點需走 `faction_stakes`。已 grep 全庫，live code 僅 options.gd 一處，已改；其餘皆 docs（spec/plan/handback 歷史，不動）。
- **徵收對自身**：gather（`_rt == team.team_id → -1`）+ to_task（`rt == team.team_id → IDLE`）雙重排除，因 `_richest_member` 未排自身。
- **多 stakes 排序抖動**：同隊同時有多 stake 時，member 在 攻擊/徵收/外交 間以個人染色決選（無 stake 間優先序）。即上述 BLOCKER 的一般化——派系同時下多 directive 時 member 分流，可能與「集中打一仗」的協同直覺不符。
- **掠奪在 f.goals 但非 stake**：`_update_goals` 仍會放 `掠奪` 進 f.goals，但 STAKES_SET 不含，member 不經 faction_duty 響應掠奪（維持日常個體語意，符 ruling）。

## 待主 session 確認
- **BLOCKER 跟戰 2/4 的處置**（上三選一或其他）。這是本 handback 最高優先。
- `levy`/`diplo` weight 與 `STAKES_DRIVE_BASE` 量級是否合理（目前 mirror attack：weight 0.2 base + 主軸.5 + 副軸.3；drive base 0.3）。
- 立國/結盟/大徵收後續是否要做（本塊明確不做：立國=leader-level、結盟⊂外交、大徵收=徵收）。
