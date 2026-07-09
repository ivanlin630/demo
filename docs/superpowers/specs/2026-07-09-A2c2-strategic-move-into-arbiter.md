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

## ★D1 定案 v2（候選 C：arbiter-owned 純移動覆蓋，task 不變）——rev2 reviewer 破候選 A 後改
**候選 A 廢**（reviewer rev1 破，2 阻塞同根=A 改 current_task）：
- A 改 task → `try_set` 內部仍比 task_priority（gate 只管呼叫時機、不改內部接受閘）→ nonidle_empty 隊(TASK_TRADE 抵達)仍被 PRIO_STRATEGIC<50 擋掉。
- A 改 task → `interaction_system:253` 同勢力 idle+idle 自發併隊（依賴 current_task==IDLE）**靜默停擺**（戰略行軍隊不再 IDLE）=湧現消失。
- 根：**原 overlay 不改 task、只填 move_target**；A 硬套 task 框架必破。

**候選 C = 把 move_target 的 write 從 `movement:65-72` 搬進 arbiter 擁有的純移動方法，task 完全不動**：
```gdscript
# task_arbiter.gd 新增（純移動覆蓋，不碰 current_task/task_priority）：
static func set_strategic_move(team: TeamData, pos: Vector2i) -> void:
    # arbiter 成戰略移動 move_target 唯一 owned write path（收 movement 直讀 bypass=D11/V3）。
    # 僅 move_target 空/抵達才覆蓋（保現行觸發顆粒），不動 task=IDLE 保留。
    if team.move_target == Vector2i(-1,-1) or team.move_target == team.tile_pos:
        team.move_target = pos
```
- **呼叫端**：`movement:65-72` 拆除直讀 strategic_assignments 分支；改由**faction member loop / strategic tick 後**呼 `TaskArbiter.set_strategic_move(team, sa_pos)`，`sa_pos` 選取**保突圍優先**（`has(-1)`→突圍 pos，否則正整數 key，鏡射舊 `movement:67-70`）。
- **task 不變**：隊 current_task 保持原值（IDLE 續 IDLE）→ `interaction:253` 自發併隊續 fire（阻塞2 解）。
- **無 task_priority 閘**：純 move_target set 不經 try_set → nonidle_empty 隊(抵達等結算)也被覆蓋（阻塞1 解，同舊 overlay）。
- **arbiter 權威**：strategic move_target 現經單一 arbiter-owned path（可集中 log/audit）=收 movement 直讀 bypass（D11/V3）。
- **★行為目標=逐位元不變**：同 gate（move_target 空/抵達）、同 tie-break（突圍優先）、同 sa_pos 值 → move_target 設值與舊 overlay identical → `expand_reached`/`member_atk`/`interaction:253` 全保。**folding=搬 write owner，非改行為** → 若真 byte-identical 則**無 player-visible 變、無需 blueprint sign-off**。

### 候選演進（參照）
候選 A（march task，reviewer 破：改 task 破 2 處）→ 候選 B（ctx+option，改 task 類別同疑慮）→ **候選 C（arbiter 純移動覆蓋 task 不變，選定）**。

## D1-old. seam 設計（movement-overlay→arbiter 權威，待 D0 定案微調）
**方向**：strategic_ai 續算 strategic_assignments（空間 affordance，合法=它是 spatial goal producer，非 task 權威）；**移動的執行**改經 arbiter/引擎，不由 movement 直吃。兩候選（D0 後選一）：

- **候選 A（低優先 march 任務）**：新增/複用低 PRIO 的「戰略移動」task（如 `TASK_MARCH` 或既有定位 task），strategic_assignments 存在時經 `TaskArbiter.try_set(PRIO_STRATEGIC<PRIO_DISPATCH)` 設之 → arbiter 仲裁（任何真 task/survival 壓過 = 保「move_target 空才走」語意）。movement 不再直讀 strategic_assignments，改讀 task 的 move_target。
- **候選 B（引擎 ctx input + 移動 fallback option）**：strategic_assignments 降為 `ctx.strategic_move_target`，引擎 rank_scored 加低 drive「戰略移動」option，winner 時 to_task 設 move_target（不改 task 類別、只設移動）。較貼近「不改 task」原語意但需引擎支援「純移動 output」。

系統傾向 **候選 A**（arbiter 是移動權威=正中 D11/V3「arbiter 成戰略移動唯一權威」；PRIO 低保 fallback 語意），但**待 D0 characterization 確認 overlay 語意細節**（如包圍多隊分向是否需保）再定。

## D2. 觸及檔（候選 C）
| 檔 | 改點 |
|---|---|
| `scripts/simulation/task_arbiter.gd` | +`set_strategic_move(team, pos)`（純移動覆蓋，move_target 空/抵達才寫，不動 task/priority） |
| `scripts/simulation/movement_system.gd` | 拆 :65-72 直讀 strategic_assignments 分支（move_target 改由 arbiter owned path 設） |
| faction member loop（`faction_ai` 或 strategic tick 後） | strategic_assignments 存在 → 選 sa_pos（突圍優先 tie-break）→ `TaskArbiter.set_strategic_move(team, sa_pos)` |
| `scripts/debug/warring_harness.gd` | strat.* PROBE_KEYS（D0 已立，複用） |

**不碰**：current_task（保 IDLE=候選 C 精髓）、FA7 god-view、strategic goal 產生、target 選擇、interaction:253（靠 task 不變自然保）。

**不碰**：FA7 `_nearest_independent` god-view（arc3）、strategic goal 產生（spatial affordance 合法）、FA5/FA8（別 slice）、target 選擇語意。

## 驗收線（藍圖判，A2c-1 模型）
1. **移動軌跡等價（候選 C 目標=byte-identical）**：`sa_move_dispatch`/`expand_reached`/`member_atk_eligible`(seed1337) 折後 ≈ baseline overlay-on（移動執行不塌，D0 鎖定風險）。
2. **★interaction:253 自發併隊不塌（reviewer rev1 阻塞2）**：同勢力 idle+idle 併隊觸發次數（或間接：同勢力隊數 vs 獨立隊收斂速度）折前/後不系統性下降——候選 C 靠 task 不變自然保，驗之。
3. **arbiter 一致**：折後 strategic move_target 經 arbiter owned path（D11/V3 收），HOB「手聽腦」不退。
4. 憲法/framework/sanity 綠。
5. 相關≠因果 + 3 seed：任何指標偏移先 characterize 真變 vs seed 噪音，別 ironclad。
6. **byte-identical 則無需 sign-off**；若實測有 player-visible 偏移 → 回 blueprint。

## 流程
D0 characterization（measurer 背景併行 3 seed）→ 讀數定 D1 候選 A/B → reviewer 審 seam → 下游（可 LG `--from-impl` 試水）。**D0 未出不鎖 D1/D2**。
