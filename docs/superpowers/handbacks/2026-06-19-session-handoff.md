# Session 交接（2026-06-18~19）

> 給重啟後新 session。main @ `bd95d4a`，全綠（headless `=== DONE ===`、ui_flow errors:0、game_sim_multi coin_eq=0、全 invariant 0）。

## 這串會話做了什麼（全 merged）

### 1. 不變量架構根治（散落不變量債類全清）
- **anon cohort 統一模型**（Phase 1→4）：population/wounded/anon_combat_skill/anon_wage 全 computed getter（物理不可 drift）；anon 存 `anon_cohorts`（"tier|health"→count）；變動走 `AnonCohort`/`AnonTierSystem` 單一入口。
- **faction 雙向**：`WorldState.set_team_faction`/`clear_team_faction` 單一入口。
- **subteam 雙向**：`set_subteam_parent`/`detach_subteam`。
- **team erase 引用完整性**：`WorldState.erase_team(tid)` 單一 chokepoint 清光所有指向死隊的 ref；四條 erase 路徑統一走它；`InvariantAudit._check_no_dangling_team_id`。
- **team-ref 契約**（部分）：`require_team` for 維護集合元素（必活）；單欄位 target（combat_target/order_target_id/parent_team_id）保留 guard（tick 內瞬時懸空真實存在，guard 是 load-bearing）。詳見 `invariants.md` team ref 契約節 + [[project_anon_cohort_refactor]] memory。

### 2. 代碼健康（單一真值源）
- FOOD_PER_PERSON_PER_DAY / TIER_ORDER / tier 名 / TRAINING_CAP(dead) / VISION_RADIUS 收斂單一源。
- TASK_* enum 補齊 + 全引用（零裸 task 字串）。
- ResourceKeys/get_res helper **判 YAGNI 緩**（資源鍵無 value-drift、高 churn 低值）。

### 3. Q7 玩家流程（QA 抓的落差，全修 + 複驗）
- Q7-1 **choose_heir 致命 softlock** → forced-event 三聯單一源化（id 由 `get_forced_response_options` 算、mapper 導 label）+ choose_heir/aid_request。
- Q7-2 aid 施捨 / Q7-3 戰利品文字 UI / Q7-4 promote_anon（復用 generate_for_team）/ Q7-5 子隊任務 / Q7-6 faction gate。
- Q8 殘留 N-1（子隊面板引導 promote）/N-2（choose_heir 不吃 stale 候選）/N-3（camp/train 真 gate）。

### 4. Trade 單一源（trade-economy-review 問題 1/2/3）
- **問題3** `TradeValuation` 估值單一源（canonical 表取 interaction，天平==接受同源）。
- **問題1** reserve 單一源（`TradeValuation.reserve`，玩家全資源留底不刷光）。
- **問題2** NPC barter（缺幣互補 surplus 等值互換，coin_eq 中性）。

### 5. 文件整理
- `docs/notes/` 刪 3 過時（gap-analysis/api-completeness/integration-report 皆已實作或被取代），留 3 未實現想法。
- `*.log` + root PNG 入 gitignore。

## 待做（優先排序，給新 session 起手）

### trade-economy-review 剩餘（`docs/notes/trade-economy-review.md`）
- **問題4** 商隊套利視野窄（只 food/material 有 intel）— bug 性質
- **問題5** 靜態需求飽和（填到 target 就停→需求歸零，疑 trade 量低**最深根**）— 設計 brainstorm
- **問題6** coin 通縮/供給彈性 + **offer-board**（buy/sell offer 經 message 傳播）— 大提案

### known_issues 高優先（`docs/known_issues.md`）
- **P6 遭遇戰收斂**（E-1 弱隊殺不光對攻擊免疫/E-2 AI 死戰/E-3 玩家逃離）— 世界無法收斂，需 spec
- **戰俘處置**（capture 做了，處置全缺：賣/屠/招降/釋放/勞役）— 需 spec
- **Bug2 salary coin 無下限**（守恆破，新團赤字）— clamp + 欠薪後果，快

### 其他未實現想法（`docs/notes/`）
- **分層評估頻率**（5 層收斂 ~12 散亂 interval 常數，= 單一源延伸）
- **戰鬥接觸深度**（戰爭階段化/prey 威脅評估/第三方介入/戰報傳播，接 P6）

### 旁記
- `ui_logic_test.gd` 2 個 vision-dist FAIL = **pre-existing baseline**（已記 known_issues，勿當新 bug）。
- promote_anon 無 coin 成本（待議）。
- `scripts/debug/qa_probe.gd` 是 untracked QA 暫時工具。

## 工作流提醒（記憶已存，見 MEMORY.md）
- L1/L2 走 spec/plan→子 session；L3 主 session 可直改。**禁止東修西補，維持通用模型/單一真值源**（用戶核心偏好）。
- 本會話用 **Agent(isolation:worktree) 派實作子 agent** → 主 session 審 ff-merge 的節奏，運作良好。
- 確定性回歸閘：headless + coin_eq（**非** multi drift，game_sim_multi 已 seed 但仍 stochastic）。
- 別問用戶技術微決策（[[feedback_no_tech_microdecisions]]）；ctx ~90% 才提醒交接（[[feedback_ctx_90_handoff]]）。
