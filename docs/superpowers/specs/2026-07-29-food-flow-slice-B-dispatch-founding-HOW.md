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

## 2. 糧橋（B1 核心）
派遣隊出發 → 抵達 → （立國：建成）全程糧收支：
- **出發 go/no-go**：`配糧 = 子隊 carry_capacity`（movement:137-140 現成 pop×mounts×wagons，food=0.1）；`需糧 = burn × ETA_total`（去程+建程）。`carry ≥ 需糧 × safe_margin` → go；否則 no-go（別派去餓死）。★**查子隊 carry**（實際出發那支，非母隊——R① 揭立國門檻 faction_ai:1250-1252 沒查子隊）。
- **半路求生重算**：每日 cadence 算子隊 runway（SLICE A 感官）；`runway < return_ETA` 且橋真斷（無內生補給可達）→ 撤退（返家/最近 outpost），非硬撐餓死。
- **★橋真斷才撤**（非一有壓力就撤）：留 edge-riding（載重+沿路打獵撐得到才續）。

## 3. 打獵 EV 估算器（B2，★純數學禁 randf，守 observer 鐵律）
- **`hunt_ev(tile) = hunt_chance(skill) × hunt_yield(skill)`**（純算術期望值），★**禁呼 hunt_small_game（它 randf 擲骰=污染世界，feedback_observer_no_global_rng 血證）**——抽出 chance/yield 公式（hunt_system 現有 chance/yield 算法）當**唯讀期望值**。
- **沿路 EV**：路線 tiles 的 hunt_ev 累加 × 存量遞減折扣（wild_game 有限）→ 沿路內生補給估。餵糧橋 inflow（延橋長）。★估算**不改世界**（不真打獵、不耗 wild_game、不耗 RNG）。

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
