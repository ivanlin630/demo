# Hand Back: 統一統領決策 v2（means-end 意圖驅動）

承 plan `2026-06-28-commander-decision-unify-v2.md` / spec `2026-06-28-commander-decision-unify-design.md`。
3 Task 全做，TDD（測先 → 實作 → 全綠）。北極星「凡 named 意圖必有可解釋驅動」於統領層第一處落實。

## 實作摘要（改檔，每檔一行）
- `scripts/data/faction_data.gd`：加 `intent`（{type,target_id,why} 承諾追蹤）+ `goal_drivers`（goal→{intent,why,mode} 每令 driver）兩欄。
- `scripts/simulation/faction_ai_system.gd`：
  - 加 `INTENTS`（征服/致富/防衛/守成）/`ACTIONS`（攻擊/徵收/外交 + 真 affordance）const + `COMMANDER_COMMITMENT_BONUS=0.15`。
  - 加 `_select_intent`/`_score_intents`（人格×belief×viability×hysteresis argmax）、`_conquest_viable`（belief 敵力 vs 我力+補力餘裕）、`_decompose_needs`（深度1 主行動前提）、`_precond_met`（force_ge_target/can_reach/has_richer_member）、`_match_fillers`（補力←結盟/徵收 util 抽）、`_emit_goal`（append + 記 driver）。
  - `_update_goals` 整段 means-end 重構：survival override → 立國 gate → 意圖選 → 戰爭基金 sub-need → 分解+filler+emit。**刪掠奪 append**（team P1）。
- `scripts/simulation/decision/terms.gd`：revert `FACTION_DUTY_DRIVE_LESSER`（刪 const，徵收/外交 drive 回 `FACTION_DUTY_DRIVE`=1.5 與攻擊同級）。
- `scripts/debug/headless_test.gd`：加 `_test_cmd_intent_select` / `_test_cmd_means_end_emit` / `_test_cmd_viability_hysteresis` + helper（`_select_intent_for`/`_setup_conquer_faction`）。
- `scripts/debug/commander_directive_measure.gd`：擴量——每令印 intent+why+mode，斷言無因令=0。
- `docs/invariants.md`：「隊目標單一 owner」+「混合協調」段補統領 means-end 流程 + war-priority revert。

Commit：Task1 `6181cdd`、Task2 `8dd6dc9`、Task3 `2e08527`。

## 驗收證據

**measure 重跑（4/2 無因令 → means-end 單意圖協同令、每令有 driver）**：
| persona | 意圖 | f.goals | driver |
|---|---|---|---|
| 好戰霸主 | 征服 | [攻擊] | 攻擊:intent=征服 why=主手段取target mode=combat |
| 貪婪商霸 | 致富 | [徵收,外交] | 徵收:致富/levy・外交:致富/ally |
| 溫和守成 | 防衛 | [徵收] | 徵收:防衛/fund_war |
| 野心謀略 | 致富 | [徵收,外交] | 致富/levy・ally |
| 均衡 | 致富 | [徵收,外交] | 致富/levy・ally |

**無因令總數=0**（北極星滿足；baseline 為 4/2 同發無 driver）。

**viability（unit test `_test_cmd_viability_hysteresis`）**：
- 敵 belief 顯強（armed 50，我湊不出）→ intent ≠ 征服、不發攻擊令（退防衛/守成，不打不贏）。✅
- force_deficit（leader 獨力不足 + 攻擊 task member 補力）→ 征服 viable，主令攻擊 + **補力肢（外交 ally）**，driver why 含「補力」。✅ 輔助肢從人格餘裕抽（非替主手段）。
- hysteresis：committed 征服 + 情勢不變 → 連評不翻。✅
- 緊急徵收 override：food<emergency → `["徵收"]` driver mode=survival、獨佔 return。✅

**P3 war scenario（不數跟戰，看可解釋+viable）**：征服 leader 發 `["攻擊","徵收"]`（攻擊主手段 + 徵收籌餉肢），成員按人格響應（忠誠好戰 util1.7／忠誠溫和 1.4／中庸 1.2 皆參戰）；B 場景（和平）無攻擊令。`DONE` 無 ERROR。

**headless 全綠**（含既有 P2b1 survival/P3/P4 路徑、Fief Task3b 戰爭基金）：`=== DONE ===` 無 SCRIPT ERROR。

**framework S1-S6**：全 7 PASS、0 dormant（S1 立國=1、S2a feud=1、S2b vendetta=1、S3 scout、S4 ambush、S5 mint、S6 order）。

**coin_eq 守恆**：game_sim_multi 4 配置 delta=0.00（game_sim_test/tyrant/merchant/warzone）。

**world_sim 2yr**：24 月跑完 `=== world_sim DONE ===`、InvariantViolation=0、SCRIPT ERROR=0。**FactionAI 主動攻擊=0 次**（此 seed 僅 1 派系立國後旋即解散）→ 征服稀有（無打不贏令 spam）；意圖穩定（無 flip-flop 訊息）。

## 與 plan 差異
1. **ACTIONS 只掛消費端認得的 token**（攻擊/徵收/外交）。spec schema 列了「貿易/建設」行動，但它們**非 faction stakes**（成員自走 trade/manufacture fallback，`STAKES_SET` 不含），掛上去會是 orphan token 驅不動任何東西。故 致富意圖的真 affordance = 徵收(levy) + 外交(ally)，不發貿易/建設令。守 spec「只真 affordance、不掛孤兒」。
2. **戰爭基金（war-chest levy）保留**為跨意圖 sub-need（material 枯 + 野心/好戰高 → 徵收 fund_war，附 driver）。原 `_update_goals` 有此經濟行為（既有 test `_test_special_tax_war_trigger` 守），純 intent-gate 會 regress treasury 維持。folded 進 means-end 並附 driver，非無因令。
3. **force_ge_target 用嚴格「leader 獨力 armed」**（不含補力餘裕），與 intent-level viability（`_conquest_viable` 含餘裕）分開——這正是 means-end：intent 認為「有救兵能贏」故選征服，子需求現算「我獨力不足」故開補力肢。兩者刻意不同閾。

## 連動風險（主 session 決定是否補修）
- **掠奪從統領移除**：`_update_goals` 不再 append「掠奪」；`_assign_tasks` 仍有 `"掠奪" in f.goals` 分支（now dead，因永不 set）。掠奪走 team P1 option（unified 隊個體決）。`_assign_tasks`/`_assign_member_tasks` 的掠奪分支可清，但留著無害（永不觸發）——未清，待主 session 裁。
- **緊急徵收邊界**：survival override 在意圖前 `return`，獨佔 goals。與既有 `effective_emergency`（survival/honor 調）同公式，行為不變。
- **war-priority 移除**：徵收/外交 duty 量級從 1.0 → 1.5（與攻擊齊）。單意圖後成員一次只服務一意圖子命令，理論無同級矛盾；P3 場景證成員仍全參攻擊（util 主手段 > 補肢）。但若未來出現「攻擊 + 補力外交」雙令且某成員義氣極高，可能選外交肢而非攻擊——這是 means-end 設計（補力肢=feature，義氣 leader 派系本就偏結盟），非 bug，但屬行為改變，主 session 留意。
- **strategic_ai 未碰**：`f.strategic_goals`（expand/defend/trade_net 另層）原樣，與 `f.goals`/`f.intent` 並存。兩層語義不同（strategic=長期 G2b，goals=每 cadence directive），無衝突但雙軌——非本塊 scope。

## 待主 session 確認
- **viability 量級**：`_conquest_viable` 複用 `ATTACK_STRENGTH_RATIO`(0.8)；補力餘裕只算「member 已在 TASK_ATTACK」的 armed（既有邏輯）。**這偏保守**——尚未集結的潛在援軍不計，故 viability 可能低估、征服更稀有。world_sim 此 seed 0 次征服或反映此（亦可能 seed 派系太少）。若主 session 要征服更常見，可放寬補力餘裕估計（算可徵召 member）。標 TEST VALUE。
- **`COMMANDER_COMMITMENT_BONUS`=0.15**：hysteresis 量級，TEST VALUE，未經長跑 tune。
- **欺敵孤兒洞**：`can_reach` 失敗（target 有盟擋）→ 對應「擋敵盟」子需求需欺敵 filler=孤兒（無真 affordance）→ `_decompose_needs` 不開該 need（`_: pass`）。已標 anchored-pre-player；欺敵 arc 建好後此 need 自動有 filler。本塊不硬塞假 affordance。✅ 守 spec。
- **means-end 是否真跑出湧現 viable scheme（非退化查表）**：force_deficit 路徑證「主令攻擊 + filler 現算補力肢（ally vs levy util 比較選 ally）」=真分解非查表。但**力足時退化成單令**（好戰霸主 setup 力足 → 只 [攻擊] 無補肢，因 force_ge_target 已滿足無 open need）——這是正解（不需補力就不發補力肢），非退化 bug。湧現協同只在「力不足但 viable」窗口出現。world_sim 未捕捉到此窗口（派系太少/太短命），unit test 與 P3 場景捕捉到。**believability 疑慮**：真實長跑中此窗口多不多、玩家看不看得到，待真人玩測或更多派系的 world_sim seed 驗證——誠實標記為不確定。
