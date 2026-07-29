---
type: spec
owner: systems
topic: 糧流感知 SLICE B（派遣立國，消費者②）HOW 架構
status: ready-for-R2
---

# HOW 架構 spec：糧流感知 SLICE B（派遣立國 + 糧橋）

> R① 收窄後（規模誠實化，SLICE B=真新建非接線）：**消費者②派遣/離家隊過「糧橋」**，立國為極端示範。**解 A1 子隊餓死 viability**（真坐實 victim：子隊遠地跋涉 never-arrive/dissolved）。★5 塊 R① 揭的真新建都在本 slice（打獵 EV 估算器/tile 假設 inflow 投影器/遠征 ETA/多 site 派遣閘）——**規模當真 build 如 means-end 新子系統，內部再切 sub-slice**。

## 1. scope + 內部 sub-slice（★規模大，切細）
SLICE B 真新建 4 元件，建議內部 sub-slice（各自 R²+驗 target 真 fire）：
- **B1 糧橋核心 + 派遣閘（最小、解 A1 主 victim）**：出發配糧 + go/no-go（carry vs 需糧）+ 半路求生重算 + 橋斷撤。接**現有 dispatch call site**（settle/construct/expand/upgrade builder dispatch）。inflow 用 SLICE A 的 harvest-only（★暫不含打獵 EV、暫不含立國假設投影）。**這塊直接對 A1 子隊餓死 victim。**
- **B2 打獵 EV 估算器**（★純數學）：沿路內生打獵預期收穫，餵糧橋 inflow（延長橋長）。
- **B3 立國假設 inflow 投影器**（what-if）：立國候選地假設產量，餵「該不該去這立國」。
- **B4 多 site 派遣閘全接**（raid/trade 等其餘 dispatch）。
- ∴ **先 B1（真 A1 victim）→ 驗 target 真 fire → B2/B3/B4 增量**。每 sub-slice R²+cross-slice target 驗。

## 2. 糧橋（B1 核心，★R² ①②訂正）
派遣隊出發 → 抵達 → （立國：建成）全程糧收支：
- **出發 go/no-go（★測實際持有食物非 carry_capacity）**：`子隊實際糧 = sub.resources.food`（dispatch frac-split：`pop_count/parent.pop × parent.food`，subteam_system.gd:36-40）**+ B1 top-up 撥付**；`需糧 = burn × ETA_total`（去程+建程）。`子隊實際糧 ≥ 需糧 × safe_margin` → go；否則 **top-up 補足才 go**（母隊撥糧夠）或 no-go（母隊也不豐→別派餓死）。
  - ★**R² ①硬性**：`carry_capacity`（movement:137-140 重量上限 pop×10+mounts×15+wagons×40）**≠實際分到食物**；用 carry 當配糧=gate 空放行（重量上限≫實際持有）→ 子隊照樣餓死=修了等於沒修假陰性。**必測 `sub.resources.food`**。
  - ★**第 5 個真新建（R² 揭，被「配糧」措辭蓋住）＝通用食物撥付/top-up 機制**：food 從不因 cost 補（`OUTPOST_COST` outpost_system:10-18 只有 material/tools 無 food key、`_fund_subteam` faction_ai:2856-2885 只補 cost dict）→ B1 要建通用糧 top-up（母隊撥 food 給子隊到夠 burn×ETA），非既有機制換名。
  - ★**R② ②引用訂正**：真派建造子隊 = **`_dispatch_builder`（faction_ai:2603-2698，經 `_dispatch_goal_delegate`:2836）**，非 1250-1252（那是 `_evaluate_independent_strategy` 母隊獨立隊路，`parent_team_id!=-1 return`、無子隊 create）。gate（2616-2639 查 leader_team 母隊付得起）沒錯；唯一子隊存活相關=**礦山 ad-hoc bootstrap（2651-2674，BOOTSTRAP_DAYS=50 TEST）**，非礦山無此層。**B1 通用糧橋 top-up 收編取代這礦山 bootstrap（+2721 upgrade 附近同款），非兩層補貼疊加/打架**。
- **半路求生重算**：每日 cadence 算子隊 runway（SLICE A 感官）；`runway < return_ETA` 且橋真斷（無內生補給可達）→ 撤退（返家/最近 outpost），非硬撐餓死。
- **★橋真斷才撤**（非一有壓力就撤）：留 edge-riding（載重+沿路打獵撐得到才續）。

## 3. 打獵 EV 估算器（B2，★純數學禁 randf；R② ③訂正措辭+折扣）
- **`hunt_ev = hunt_chance(隊 survival skill) × hunt_yield(隊 skill)`**（★**chance/yield 是隊技能算、非 tile**——tile 只決定有沒有獵物/耗盡速度）。★**既有 `hunt_preview`（hunt_system.gd:40-46）直接可抽=非新建**（`chance=clampf(0.4+survival×0.4,0,0.95)`/`yield=12×(1+survival×0.3)` 純算術零 randf）；**禁呼 `hunt_small_game`（:22 真 randf 擲骰=污染世界，feedback_observer_no_global_rng 血證）**。
- **★真新的是路線聚合 + 存量遞減折扣（B2 R² 具體寫、非口號）**：`route_ev = Σ_route_tiles hunt_ev × discount(tile.wild_game 存量)`。折扣公式 B2 R² 定（候選：`discount = clampf(wild_game / expected_take, 0, 1)`〔存量少於預期取用→打折〕或累積遞減 `e^(−cumulative_take/stock)`）——**B2 dispatch 前必具體落公式，非留 implementer 發揮**。★估算唯讀不改世界（不真打獵、不耗 wild_game、不耗 RNG）。
- ★規模訂正：B2「抽現成 hunt_preview 公式」≠「發明新公式」——真工作量=路線聚合+折扣公式（別混記）。

## 4. 立國假設 inflow 投影器（B3，what-if）
- **`projected_inflow(tile, pop) = collection 公式`**（resource_system:63-76 outpost_mult×pop_mult×skill）**投影到還沒蓋的據點**（假設 outpost_level=1 的產量）。現成 sustainable inflow（decision_context:283-294）只認 home outpost + 布林——本投影器是**新 what-if 連續量估**（R① 揭）。
- 餵「立國候選地評估」（該去這立國否＝projected_inflow − burn 正且夠）。★純算術唯讀。

## 5. 遠征 ETA（travel + build）
- `ETA_total = ETA_travel(距離/MOVE_TILES_PER_DAY) + ETA_build(BUILD_TICKS/pop)`（立國含建程；純派遣只 travel）。

## 6. 派遣閘接線（B1 現有 + B4 全）
- **B1**：builder dispatch（_dispatch_builder settle/construct/expand/upgrade）加糧橋 go/no-go。
- **B4**：其餘 dispatch call site（raid/trade/envoy 遠行）全接（R① 揭 4-5 site）。

## 7. 憲法對齊
- utility weigh 非 scripted（go/no-go 是糧橋 util gate，非寫死）。★**純算術禁 RNG**（打獵 EV/投影器唯讀期望值，feedback_observer_no_global_rng）。內生-only（外生不預測）。非硬鎖（撤退是反應非凍死）。**接 tap**（bridge_go/no_go/hunt_ev/projected_inflow/撤退，禁耗 RNG）。

## 8. ★cross-slice tripwire（memory 精化 4/5 守）
- **驗 target 真 fire**：A1 子隊（真 victim）**真被糧橋 gate/配糧**（在 trace、被算），非只 aggregate 派遣數升。B1 execution-verified：**A1 子隊真不餓死**（construct.complete_build>0 或子隊 arrive 率升 vs baseline never-arrive）。

## 9. TDD + 驗（execution-verified）
- 糧橋 go/no-go 單測（carry vs 需糧、子隊 carry 非母隊、safe_margin）。
- 打獵 EV/投影器**純算術零 RNG**（★specimen ON==OFF byte-identical、determinism、無 randf）。
- **★A1 子隊真不餓死**（execution-verified：子隊 arrive 率/complete_build vs baseline never-arrive/dissolved）。
- **★世界不凍**（specimen-off、attrition/teams 活）。
- 閘：headless 0-new + gate 74 + determinism 3跑 byte-identical。

## 10. 交付
→ R²（★異質：規模當真 build/打獵 EV 純數學禁 randf/投影器 what-if 唯讀/子隊 carry/cross-slice A1 真 victim fire）→ implementer（**B1 先**）→ measurer specimen-off（落地標 path）→ QA A1 子隊真不餓死稽核 → B2/B3/B4 增量 → SLICE C。
