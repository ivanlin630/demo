# Hand Back: combat_target chokepoint + BEG/JOIN 綁修（social_target 拆）

> plan = `plans/2026-07-02-combat-target-social-split.md`；spec = `specs/2026-07-02-combat-target-social-split-design.md`。
> branch = `feat/combat-target-split`（不 merge，等系統 session）。統一矩陣 F-S4 + F-I3 收。

## 實作摘要（每檔一行）

- `scripts/data/team_data.gd`：加 `social_target: int = -1`（社交互動目標，語意 ≠ combat_target）。
- `scripts/data/world_state.gd`：加 `set_combat_target`/`clear_combat_target` + `set_social_target`/`clear_social_target` chokepoint（mirror set_leader）；`erase_team` 續清懸空 social_target。
- `scripts/simulation/invariant_audit.gd`：`_check_no_dangling_team_id` 加 social_target dangling 檢。
- `scripts/simulation/decision/options.gd`：投靠/乞食 `to_task` 改設 `social_target` key（非 combat_target）。
- `scripts/simulation/faction_ai_system.gd`：unified(:1220) + survival(:2786) dispatch routing 分流 combat_target/social_target 經 chokepoint；player-投靠偵測改讀 social_target；SoloAI JOIN(:1496) 設 social_target。
- `scripts/simulation/interaction_system.gd`：BEG resolver 讀 social_target；**新 JOIN resolver**（`_resolve_join`，複用 merge_teams full absorb）；BEG/JOIN resolver **上移到 same_faction 塊之前**（見下「設計決策」）；`_clear_aid_task(state, beggar)` 清 social_target。
- `scripts/simulation/npc_combat_system.gd`：start_combat + 各結算 combat_target 直寫全遷 chokepoint（set/clear_combat_target）。
- `scripts/simulation/encounter_system.gd`：遭遇戰結算 combat_target 清遷 clear_combat_target。
- `scripts/simulation/player_command_system.gd` + `sim_runner.gd`：BEG cleanup 改清 social_target（BEG 現走 social_target，清 combat_target 會漏留 social_target 懸空）。
- `scripts/debug/headless_test.gd`：舊 `_test_beg_join_deadpath_probe`（斷言舊死路）→ 改寫 `_test_beg_join_social_resolve`（斷言 resolve 真跑 + combat_target 仍擋戰鬥中隊 + JOIN pop 守恆）；加 `_test_target_chokepoint`（chokepoint set/clear + erase 清 + audit dangling）；p2a 投靠斷言更新（social_target≠-1 且 combat_target==-1）。

## 與 spec 差異

- **BEG/JOIN resolver 上移至 same_faction 塊之前**（spec 未指定順序）。原因：`_find_aid_target`(:2911 same_faction +1000) / `_find_strong_neighbor` 多回同 faction 對象；resolver 若留在 same_faction 塊之後，同 faction BEG/JOIN 對子被 `same_faction: ... return`(:251) early-return 吃掉 → beg.resolve 結構性 0。上移後跨/同 faction 均 resolve（同 TRADE 跨勢力語意）。只**增加** resolution，不搶既有 same_faction handler（BEG/JOIN 不在該塊處理）。
- social_target 採 **chokepoint**（非輕量欄），與 combat_target 對稱（spec 開放細節「傾向一致」）。
- JOIN resolver 語意 = **全併入 host**（merge_teams full absorb，非 subteam；容量不足時 merge_teams 內部自然降為部分/subteam）。

## 驗收結果

- **headless**：63 OK / 0 SCRIPT ERROR / `=== DONE ===`。coin 全池守恆閘(200-tick sim CoinAudit delta==minted) 綠、InvariantAudit unit 綠。
- **framework S1-S6**：7/7 PASS、0 DORMANT。
- **BEG/JOIN 死路探針（warring seed, 1 月）**：join.resolve **0→4**（17 dispatch 中）、join.arrived_no_handler **0**（前為死路 marker）。死路消。
- **beg.resolve 探針為 stochastic**（warring seed 無 seed，[[reference_multi_sanity_unseeded]]）：此 run beg.dispatch=0（begging 未觸發），故 probe 未觀察到 beg.resolve。**BEG resolve 由 unit test 決定性驗**（見下）。
- 新 unit：`_test_beg_join_social_resolve`（**同 faction** beg.resolve>0 + **同 faction** join.resolve>0 + JOIN pop 守恆 + combat_target 仍擋戰鬥中隊 197）、`_test_target_chokepoint`（chokepoint set/clear + erase 清 + audit dangling）。同 faction 用例 = relocation 決定性保護測。

### 唯一 FAIL = pre-existing baseline（非本軌）
- `[FAIL] 弱目標未加入攻擊 goal`（IntelSystem 攻擊決策測）在 clean base(5a8ab9f) 已存在，非本改動引入。out of scope，未動。

## 連動風險

- `npc_combat_system`：combat_target 全遷 chokepoint（含 start_combat SET）。**與 capture 軌並行**碰同檔不同函數（capture 碰 absorb/casualty，本軌碰 combat_target 寫）→ 系統 merge 序解（plan 已標）。零戰鬥行為變（chokepoint = thin wrapper）。
- `interaction_system`：BEG/JOIN resolver 上移改變 resolver 順序。同 faction TASK_IDLE 自動併隊(:224)、TRIBUTE/HERALD/SETTLE/PACIFY 不受影響（BEG/JOIN task 不在該塊）。
- `faction_ai` dispatch：投靠/乞食現走 social_target；掠奪/攻擊仍 combat_target。掠奪(TASK_LOOT)/攻擊(TASK_ATTACK) combat_target 路徑零變。
- **JOIN 併隊潮**：warring seed 1 月 join.resolve=4（17 dispatch 中），投靠率受既有 means-end 匱乏 gate + 絕境 gate 限，未見暴增（teams 95 存活）。

## 待主 session 確認

- **invariants.md 更新（系統 owner）**：所有權域 Pattern B 剩餘清單「combat_target chokepoint（後 slice）」現已落地 → 應從 backlog 移除；Task §combat_target「戰鬥中 flag」語意可補「社交走 social_target」。known_issues F-S4 + F-I3 可標收。
- **progress.md 更新（系統 owner）**：下燒三軌之 combat_target/BEG-JOIN 軌完成。
- **建議後續**：
  1. `_resolve_join` 部分併隊（容量不足→subteam）時 joiner.social_target 未主動清（host 仍在→不懸空，非 bug）；可加清理更乾淨。
  2. BEG/JOIN player 版仍走既有 forced_event/`_accept_join_request` 路徑（未統一走新 NPC social resolver）；spec 允許，暫不動。
  3. pre-existing `弱目標未加入攻擊 goal` FAIL 需另軌查（非本軌）。
