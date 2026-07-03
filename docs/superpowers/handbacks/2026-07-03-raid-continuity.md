# Hand Back: 斷① 打草穀 + 入勢力不換腦 enforce

Spec：`docs/superpowers/specs/2026-07-03-raid-continuity-identity-weight-design.md`
Plan：`docs/superpowers/plans/2026-07-03-raid-continuity-identity-weight.md`
Branch：`feat/raid-continuity-identity-weight`

## 實作摘要

### `scripts/simulation/faction_ai_system.gd`
- **Task 1A `_is_prosperity_candidate`**：刪「faction 成員非 leader → false」，只留 `parent_team_id != -1 → false`。faction 成員（非子隊）現過 prosperity 候選＝打草穀。`state` 參數改 `_state`（不再讀 state）避未用警告。
- **Task 1B `find_prosperity_prey` ③own 因子**：believed-owned prey 的 `war_capability` 減免收緊為只給 `can_bear_war`＝faction leader（`leader_team_id == team_id`）或獨立隊（`fid == -1`）；**非 leader 成員 day-op 對 believed-owned 恆 `WAR_COST_BASE`**（幾乎不中選）。註解寫明 stakes 歸屬語意（誰扛得起戰爭後果誰減免，非身分切路徑）。
- **Task 1B/驗收探針**：`_evaluate_prosperity_attack` 的 believed-owned 攻擊哨從「僅獨立隊」擴為獨立/成員分計（`conq.indep_atk_believed_owned` vs 新 `conq.member_atk_believed_owned`）。
- **Task 2.1 `_evaluate_independent_strategy`**：刪 `if team.faction_id != -1: return` 早退（不換腦，個人戰略層對每個 leader 永遠跑）。`can_found` gate 加 `team.faction_id == -1 and ...`＝成員 can_found=false（雙保險不重複建國）。成員征服 intent 照 defer prosperity（打草穀路）。
- **Task 2.2 `evaluate_all` solo 迴圈**：新增 `else` 分支——faction 成員（非子隊）也呼 `_evaluate_independent_strategy`（戰略 intent 層），**不呼 `_evaluate_solo`**（個人日常全域留後續 F-D 矩陣格，避與 `_assign_tasks` 派工互搏）。

### `scripts/debug/headless_test.gd`
- **`_test_r1b_war_capability_relief` 更新**：case B 攻擊者設為 faction **leader**（`leader_team_id=0`）→ 仍得減免選富屬村（新語意）。新增 case C：同 established+HEGEMON 但攻擊者為**非 leader 成員**（leader=team5）→ 無減免 → 避富屬村選貧獨立（斷①B 核心 enforce 覆蓋）。
- **新增 `_test_raid_continuity_member`**：(A) 成員過候選/子隊擋/獨立過；(B1) 無 directive → 成員 raid 設得進；(B2) faction directive 在（成員非 idle）→ `_evaluate_prosperity_attack` idle-guard 壓個人 raid（task 不變）。已註冊入 main 序列。

## 驗收結果

### 回歸（已完成）
- **headless**：`=== DONE ===`，0 SCRIPT ERROR；唯一 FAIL＝`[FAIL] 弱目標未加入攻擊 goal`＝pre-existing 容忍。新增/改動測全 `[OK]`。
- **coin_eq**：headless 內 `[CoinAudit] 200-tick 全池` delta 守恆 assert 過（絕值 <0.5）。
- **InvariantAudit**：headless 全 `_test_invariant_*`（population/faction/subteam/roster 雙向+反向/cohort）過＝0 違反。
- **framework_validation**：**PASS=7 DORMANT=0**（S1 立國/S2a feud/S2b vendetta/S3 scout/S4 ambush/S5 mint/S6 order 全 PASS）。

### 長窗 6 月（LW_SEED=1337 LW_MONTHS=6 LW_DIAG=1）
- **無崩潰**，跑滿 43200 tick，`=== longwindow_bed DONE ===`。
- **月線 sanity**：teams 103→81→52→41→41→41（早期 die-off 後穩定，非崩零非爆炸）；found faction=1。
- **asm 三帶（Task2）**：created=6、**completed=2（>0，糧正狼同化達標 ✓）**、interrupted=5（escaped3/released2/death0/scatter0）。completed 均耗 19 天。裁：interrupted 碾 completed = 結構性斷鏈（隊死/散/逃），非本波範疇。
- **③ 管住**：`indep_atk_believed_owned=0`（獨立攻 believed-owned 歸零 ✓）。
- **⚠ T32 型月曲線未直接顯化（sampling gap，非失敗）**：本 seed 代表隊 4 隻（Team32/36/34/29）**全程 fid=-1**（無一入 faction），故「入 faction 狼 raid 不歸零」的月曲線無法在此樣本點驗。全跑 prosperity attack 僅 5 次（皆 day1 faction-leader 隊），其餘 wolf raid 為 survival loot（surv.loot_dispatch 主導），世界早期塌進生存模式。Team32（野心0.92武力）GateWait 卡 6 月 raid=0 但 **fid=-1＝獨立路徑 gate**（found in-flight/prey viable=0/scout），**非本波 faction-member 問題**。faction-member 打草穀機制由 unit test `_test_raid_continuity_member` B1 直證（成員 idle→raid 設得進）。

### seeded warring 2 月（seed=7 代表，WARRING_MONTHS=2）
- **無崩潰**，`=== seeded_warring_bed DONE ===`。teams 87→77，factions 8 穩，established 2，found faction=2。
- **成員攻 believed-owned=0**：probe dict **無 `conq.member_atk_believed_owned` 鍵**（Probe.bump 首次才建鍵 → 缺席=0 次）＝**成員 day-op 零攻 believed-owned ✓**（斷①B enforce 生效）。`indep_atk_believed_owned=0` 亦然。
- **不 over-war（結構論證）**：attrition 56.1%（start618→end271）但**由 famine/survival 主導**（log 滿 [Famine]/[Death]/[Survival]；surv.loot_dispatch=242 >> conq.prosperity_reached=9）。member raid 結構上不會升 faction 戰爭——owned-attack=0 → 成員個人 raid 只打 believed-**獨立**弱村（打草穀），faction-vs-faction 走 directive（未變）。**未跑正式 baseline diff**（需動 main checkout，避免干擾設計 session）；如需精確 before/after attrition 數，建議主 session 用 `WARRING_BASELINE` 對照。

## 連動風險 / 待主 session 確認

### ★ 重大：spec/plan 的執行壓層「PRIO_FACTION(30) > PRIO_DISPATCH」語意反轉（實碼數值 30 < 50）
- **事實**：`task_arbiter.gd` `PRIO_DISPATCH=50`、`PRIO_FACTION=30`。try_set 為 `priority > task_priority` 才搶得動＝**數值大者高優先**。故 faction directive（`faction_goal` 攻擊/掠奪＝PRIO_FACTION=30，見 `_assign_tasks:1341/1346/1413`）**低於**成員個人 raid（prosperity attack＝PRIO_DISPATCH=50，見 `:300`）。spec §C／plan Task2.3／`invariants.md:249` 皆寫「PRIO_FACTION > PRIO_DISPATCH 壓個人 raid」＝**與實碼相反**。
- **實際 enforce 靠的是別的機制（behavior 正確、spec 標錯理由）**：`_evaluate_prosperity_attack:233` 的 **idle-guard**——`current_task != IDLE and not stuck and not scout → return`。tick 序：loop1 `_assign_tasks` 先下 directive（成員非 idle）→ loop3 成員 prosperity 早退＝raid 被壓。**directive 在→raid 不觸發**成立，但因 idle-guard 非優先權比較。`_test_raid_continuity_member` B2 驗此。
- **殘留 gap（新交互，本波啟用成員 raid 才浮現）**：反向 race——成員先跑 raid（idle 時，無 directive）設 ATTACK@50 → 同 tick/次 tick faction 新下 `faction_goal`@30 → `try_set(30)` 失敗（30<50）→ 成員續打自選 prey 不接新令，直到 raid release。raid 為短 op + directive 每 cadence 重發 → 會收斂，非凍結；且真「開戰」急件走 survival(80)/threat(70)/combat(100) 仍壓得動 raid。**判斷：可接受、非本波 blocker**，但：
  - **建議主 session**：(a) 修正 `invariants.md:249` 與 spec/plan 的「PRIO_FACTION > PRIO_DISPATCH」誤述（改記真 enforce = idle-guard + 急件高優先層）；或 (b) 若要 directive 硬壓個人 raid（含反向 race），需 systems 裁定是否調 `PRIO_FACTION` 數值或改 enforce 機制——**此為 owner 決策，實作未擅動優先權常數**。

### 其他
- **`_evaluate_solo` 未對成員開**：本波 scope 紀律只開戰略 intent 層給成員，個人日常全域（貿易/紮營/治理）仍走 faction `_assign_member_tasks`/`_decide_unified`。後續 F-D 矩陣格處理。
- **成員 `_evaluate_independent_strategy` 對成員零直接 dispatch**：conquest→`_set_solo`+defer prosperity；建國 can_found=false skip；致富/守成/防衛 不 dispatch。不與 `_assign_tasks` 撞 task。已確認。

## 偏離處
- 更新既有測 `_test_r1b_war_capability_relief`（case B 改用 leader、加 case C）＝對齊斷①B 改動的契約，非放寬（覆蓋更強）。屬 plan Task3「pointwise 預期 DIRTY」範疇。
