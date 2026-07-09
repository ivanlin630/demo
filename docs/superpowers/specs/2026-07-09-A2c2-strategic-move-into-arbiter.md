# A2c-2 Spec — FA6 戰略移動 bypass 折入 arbiter（strategic_assignments→move_target）

- from: systems
- 工單: `docs/superpowers/handbacks/2026-07-09-blueprint-to-systems-A2c2-direction.md`（藍圖 WHAT）
- 依賴: A2c-1(FA5 fold merged)、逆向 arc、reverse-findings FA6/D11/V3
- 逆向定位: **FA6**（`strategic_ai:152 strategic_assignments`→`movement:65-72` 直設 move_target 繞 arbiter）= D11/V3

---

## 病（grep 確認 2026-07-09）
- `strategic_ai._assign_encirclement:152` 設 `t.strategic_assignments[target_id]=sa_pos`（包圍）；`_assign_breakout:179` 設 `[-1]=sa_pos`（突圍）。
- `movement_system:64-72`：`strategic_assignments` 非空且非 FLEE → `move_target 空(== -1,-1 或 == tile_pos)時` **直設 `team.move_target=sa_target`**。
- **繞 arbiter/引擎**：戰略移動決策（往哪個包圍位/突圍位移）由 strategic_ai 算 + movement 直吃，**引擎 rank_scored / TaskArbiter 從沒看到**=「手不聽腦」的移動層版本。

## FA6 特性（與 A2c-1 FA5 不同技術）
- FA6 是 **movement-overlay**：**不改 task**（隊保持 current_task），只在 **move_target 空**時填入戰略位=**低優先 fallback 移動**。∴ 現行語意=「隊沒別的移動目標時，才走戰略位」。
- 非 task-option → **不能像 A2c-1 那樣 map 成 rank_scored option→to_task（那會設 TASK，改語意）**。seam 需另設計（見 D2）。

## FA6/FA7 seam（系統判：可分，開工已全讀確認）
- **FA6** = movement 路由層（怎麼移向 target）。**FA7**（`_nearest_independent:96` god-view 選 target）= 目標選擇層。target_id 進來後 FA6 只管移動 → **FA6 單折、FA7 god-view 留 arc3**。`_assign_encirclement` 用 `BeliefSystem.best_estimate`（:139，已 belief-gated 非裸 god-view）取 target_pos → FA6 的 target_pos 已走 belief，god-view 殘留只在 FA7 target 選擇（arc3）。

---

## ★★D0. Characterization-first（A2c-1 血教訓，鎖 D1/D2 前必跑）
折前先摸清 **strategic overlay 保護了什麼湧現**（別折完才驚，鏡射 A2c-1 merge food-blind 事後才知）。measurer 跑 baseline full_probe（3 seed 1337/42/7）+ 新增 strategic-movement 維度探針：
- `strat.sa_move_dispatch`：movement 因 strategic_assignments 設 move_target 的次數（overlay 實際生效頻率）。
- `strat.encircle_assigned` / `strat.breakout_assigned`：包圍/突圍指派數。
- `strat.expand_reached`：戰略移動到達包圍位數。
- 對照既有：`conq.declared`/攻擊 eligible/team 聚集度（包圍是否真促成征服接觸）。
- **問**：overlay 關掉（stub `movement:64-72` 分支）vs 開，**擴張/包圍/征服接觸差多少**？若 overlay 幾乎不 fire（如 A2c-1 trade_net 6月零派）→ 折入零風險；若載著真包圍湧現 → 折入須保之。
- **D0 產出定 D1/D2 校準門檻**。characterization 未跑完不鎖 D1/D2。

## ★D0 結論（characterization done，2026-07-09 `A2c2-d0-done`）
overlay **非死路，載真湧現**：`sa_move_dispatch` 三 seed 有火(496/698/73→0)、`expand_reached` 到達唯一靠 overlay(42/38/21→0)、關則 `breakout_assigned` 暴增(困原地反覆指派)；seed1337 明證 **overlay 到位=征服接觸前置**(overlay off→member_atk_eligible 416→0/capture→0)。∴ **D1 折入必須保「戰略移動仍執行、隊仍到位」**，否則重演 OFF 崩塌。**驗收硬線**：折後 `expand_reached`/`member_atk_eligible`(seed1337) 不塌。

## ★D1 定案（候選 A + 防禦式 gate，informed by D0 + reviewer）
選 **候選 A（低 PRIO march task 經 TaskArbiter）**——正中 D11/V3「arbiter 成戰略移動唯一權威」。**但補 reviewer 抓的 2 保真 gate（不靠 priority 隱式，顯式重建）**：
1. **顯式 move_target-gate**：try_set 前查 `team.move_target == Vector2i(-1,-1) or == team.tile_pos`（複製現行 `movement:71` 判準）——保「move_target 空/抵達才走戰略移動」的細顆粒觸發，**不錯位成「task==IDLE」**（reviewer 反例：TASK_TRADE 抵達等結算的隊，A 純 priority 會漏接 → sa_move_dispatch 掉 → 崩）。防禦式=不管 nonidle_empty 率多少都對。
2. **突圍優先保留**：`strategic_assignments.has(-1)` 時取突圍 pos（鏡射 `movement:67-70` tie-break，突圍 > 包圍）——D0 顯 breakout_assigned 巨量(2279-6183)=雙鍵並存常見，必顯式保。
- PRIO：新 `PRIO_STRATEGIC`（< PRIO_DISPATCH 50，> IDLE）——survival/真 task 仍壓過（保低優先 fallback 語意），但因顯式 move_target-gate 已管觸發，PRIO 主要作用=被真 task 中斷時退讓。

### 原 D1 候選（保留參照，已選 A）
（候選 A 低 PRIO march / 候選 B ctx input+移動 option——選 A，見上定案。）

## D1-old. seam 設計（movement-overlay→arbiter 權威，待 D0 定案微調）
**方向**：strategic_ai 續算 strategic_assignments（空間 affordance，合法=它是 spatial goal producer，非 task 權威）；**移動的執行**改經 arbiter/引擎，不由 movement 直吃。兩候選（D0 後選一）：

- **候選 A（低優先 march 任務）**：新增/複用低 PRIO 的「戰略移動」task（如 `TASK_MARCH` 或既有定位 task），strategic_assignments 存在時經 `TaskArbiter.try_set(PRIO_STRATEGIC<PRIO_DISPATCH)` 設之 → arbiter 仲裁（任何真 task/survival 壓過 = 保「move_target 空才走」語意）。movement 不再直讀 strategic_assignments，改讀 task 的 move_target。
- **候選 B（引擎 ctx input + 移動 fallback option）**：strategic_assignments 降為 `ctx.strategic_move_target`，引擎 rank_scored 加低 drive「戰略移動」option，winner 時 to_task 設 move_target（不改 task 類別、只設移動）。較貼近「不改 task」原語意但需引擎支援「純移動 output」。

系統傾向 **候選 A**（arbiter 是移動權威=正中 D11/V3「arbiter 成戰略移動唯一權威」；PRIO 低保 fallback 語意），但**待 D0 characterization 確認 overlay 語意細節**（如包圍多隊分向是否需保）再定。

## D2. 觸及檔（候選 A 初估，D0 後定）
| 檔 | 改點 |
|---|---|
| `scripts/simulation/movement_system.gd` | 拆 :64-72 直讀 strategic_assignments 分支（改由 arbiter task 的 move_target 驅動） |
| `scripts/simulation/strategic_ai_system.gd` 或 faction member loop | strategic_assignments → `TaskArbiter.try_set(戰略移動, PRIO_STRATEGIC)` |
| `scripts/simulation/task_arbiter.gd` / TeamData | 新 PRIO_STRATEGIC 常數（< PRIO_DISPATCH）/ 可能新 task 常數 |
| `scripts/debug/warring_harness.gd` + faction_ai | strat.* PROBE_KEYS + bump（D0 characterization） |

**不碰**：FA7 `_nearest_independent` god-view（arc3）、strategic goal 產生（spatial affordance 合法）、FA5/FA8（別 slice）、target 選擇語意。

## 驗收線（藍圖判，A2c-1 模型）
1. **移動軌跡等價**：strategic-movement full_probe 維度（包圍/突圍/擴張到達）跨 3 seed **不系統性偏移**；偏移則 characterize 耦合真變 vs seed 噪音（相關≠因果，別喊 ironclad）。
2. **arbiter 一致**：折後 arbiter=戰略移動唯一權威（D11/V3 收），HOB「手聽腦」不退（move-layer bypass 消）。
3. 憲法/framework/sanity 綠。
4. 若改玩家可見擴張/戰略格局 → 鎖 spec 前回 blueprint sign-off。

## 流程
D0 characterization（measurer 背景併行 3 seed）→ 讀數定 D1 候選 A/B → reviewer 審 seam → 下游（可 LG `--from-impl` 試水）。**D0 未出不鎖 D1/D2**。
