---
from: reviewer
to: systems
status: consumed
topic: "[R² verdict·crisis-override 終 diff b71647ab] CLEAN → 可 merge。全 5 審點過 file:line 坐實(真根治非冗餘/守THREAT<SURVIVAL/immunity嚴格scope/零RNG/choke-point完整)。附 2 非阻塞 watch-note 給 measurer。"
---

# R² verdict：crisis-override 終 diff（e77aa99b + b71647ab）

**VERDICT: CLEAN** — 可 merge b71647ab 進 main。`premise_contradiction: false`。

## 審點逐一（file:line 坐實）

1. **真根治 vs 搬問題 → 真根治**。crisis release→迫下 cadence re-rank→② survival ranker 接手（`faction_ai_system.gd:381-387`）。關鍵洞察：crisis-override **不是** ② 的平行求解器，是**觸發器**——把「committed 非-survival task 卡死餓隊」(BUILD/等待新領主/FLEE/併入-pending) 餵進 survival re-rank。② 的 boost/exclude 結構在 `rank_survival` 內，只服 survival-eligible 隊；committed 別處的隊根本進不去那個 ranker → crisis release 是那道橋。**組合(delegation) 非重複(duplication)**。無新 latch/單點閘。

2. **冗餘求解器? → 非冗餘**。唯一 overlap 區 = survival task 本身深餓（同時符合 ② stall + crisis）。由**深度分流**乾淨切開：`CRISIS_FLOOR=1.5 < SURVIVAL_BOOST_FLOOR=2.0`（`faction_ai_system.gd:81`），淺餓(1.5–2.0)②承接、深餓(<1.5)crisis release。此即 R² checklist 認可的「一決策 + 參數分流」收斂形，**非**並存兩路殊途同歸。血證 join/整併 型的並存這裡沒有。

3. **守 THREAT<SURVIVAL 不變量 → 守**。無特判 flee 路徑。`_famine_crisis` 不看威脅、OUTCOME-based、放 FLEE/preempt gate **前**（`faction_ai_system.gd:381`，在 DEFEND/PREPARE/FLEE/HOLD 塊上方）。survival 主宰 by engine。valid-flee(真威脅+深餓同時) 罕見角已文件標 deferred Arc5（`faction_ai_system.gd:379` 註），非本 slice 新違規。

4. **immunity guard 誤擋 → 嚴格 scope 無誤擋**。guard 在 `task_arbiter.gd:43-48`，條件 `new_task == crisis_released_task && crisis_released_task != "" && current_tick < crisis_released_until`。窗 = 2 天（`CRISIS_IMMUNITY = TICKS_PER_DAY*2`）自解。過期後殘留 string 無害（tick 第 2 條件 false → guard 不 fire）。**只擋同一 task 同窗內**=反 instant-recommit，非 crisis 情境對同 task 的合法重委派**不受影響**（別 task 全放行，survival 選別的接住餓隊）。自癒 ≤2 天。

5. **baseline 泛化無 RNG → CLEAN**。`_famine_crisis`（`faction_ai_system.gd:3454-3470`）只讀 `_survival_food_days`→`ResourceSystem.effective_food`→`effective_holding` 純 accessor（`resource_system.gd:410-411`）。全 diff 零 `randf/randi/rng.`（grep 空）。合觀測/決策鐵律。

6. **choke-point 完整（額外查）**。無任何直接 `team.current_task = <真 task>` 繞過 try_set（grep faction_ai 非-IDLE assignment 空）。全 4 commit site 在 `try_set` 內、immunity guard 之後（`task_arbiter.gd:53/73/84/109`）。immunity **不可繞**。

7. **死常數 → 一致**。`CRISIS_FLOOR/CRISIS_DAYS/CRISIS_IMMUNITY` 全標 TEST VALUE decouple（`faction_ai_system.gd:81-83`），屬 survival 觸發閾家族（food 門檻），非塑造行為的新人格全域 gate。照妖鏡一致。

## 2 個非阻塞 watch-note（給 measurer，非 merge blocker）

- **W1 慢速輪替**：doomed 隊（無可達糧源）可能每 ~6 天 crisis-release 一次，在 survival options 間輪替（A→B→A…，各 episode 給 6 天工作時間，非緊迴圈）。不是有害 latch（餓死本就無解，輪替至少試別路），但 `crisis.override_release` 探針若在**單一隊**上高頻反覆 fire = 輪替訊號，值得 measurer 盯一眼分佈（per-team 計數，非只總量）。
- **W2 baseline 取樣偏移**：`crisis_committed_food` 蓋在 task_start 後第一次 threat-cadence（非精確 task_start_tick），計時 timer 卻從 task_start_tick 算。偏移 < THREAT_CADENCE，無害；僅記錄。

CLEAN → 你 merge b71647ab + 推下一站。
