# manufacturing per-labor-allocation de-patch HOW（2026-08-03）

**WHAT owner**：blueprint（裁 (i) de-patch）。**HOW**：systems。**目標**：領導軸 size-matter 真根＝**蓋出的 facility 從不 RUN**（mfg:67 `current_task != TASK_MANUFACTURE → skip` 補丁閘 pre-empt 勞力池、飽和度 6.7%+材料消耗 0.000 全程證）。de-patch＝**manufacturing per labor allocation 跑**（如 gather 對稱）→ 完成勞力池統一、非新機制、[[feedback-patch-gate-first]] 教科書 de-patch。

## §0 grounding（mfg:62-96、file:line）
tick_all **已整合勞力池**：`LaborSystem.ensure_fresh(tile)` + `labor_share = team.population / pool_of(tile)`（多隊防雙算、單隊=1）+ `worker_rate = level × LaborSystem.labor_mult(tile, "mfg:Lk") × labor_share × (0.5+avg_skill)`。**唯一擋住＝:67 `if current_task != TASK_MANUFACTURE: continue`**（補丁閘）。其餘 gate 已對：outpost（:71）/works_tile（:76）/PRODUCE resident（:80）/recipe materials（`_run_recipe_group`→`_can_consume_scaled`）。

## §1 de-patch（移閘、minimal）
- **移除 `manufacturing_system.gd:67` 的 `current_task != TASK_MANUFACTURE` gate**。
- manufacturing 改**為 PRODUCE 隊在自家 outpost 就跑**（existing outpost+PRODUCE checks 已 position+type gate、如 gather）。
- ★**reframe（憲法一致）**：production 從「leader 選 manufacture 任務」解耦成「**共址 pop 自動工作 facility per 勞力配置**」——production 是**執行層 per-allocation**（勞力池驅動）、非決策（leader current_task 是 leader 導向 build/defend、pop 照工作 facility）。gather 已如此、manufacture 對稱。

## §2 保留 gate（全不動、防過度生產/economy 衝擊）
- **need-gated（§51 憲法、自動保留）**：`worker_rate` 含 `labor_mult(tile,"mfg:Lk")=fill×LABOR_SCALE`；need_oracle 給該 facility 產物 need=0 → 勞力池 fill=0 → labor_mult=0 → **worker_rate=0 → 不產**（無需求貨不產、full-stop 保留）。
- **materials-gated**：`_run_recipe_group`→`_can_consume_scaled`（input 材料不足→不跑）。
- **dedup**：`labor_share=team_pop/pool`（多隊 Σ=tile 分配、無雙算）。
- **position**：outpost_level>0 at team.tile_pos（移走→不產、如 gather）。
- **軍隊不算**：pool_of 只 PRODUCE（TAG_MILITARY 天然排除）。

## §3 ★blast-radius 驗（blueprint 5 必驗、全經濟非只大隊）
移閘＝所有 PRODUCE-at-outpost 隊 facility 都跑（per fill+materials+need）。dev-verify + measurer 硬驗：
1. **①不過度生產**：need-gated 守——滿足經濟（need=0）facility fill=0 不產（驗一 satisfied 隊 facility 產出=0、非亂產）。
2. **②不 economy 衝擊**：production/coin/資源水位 before(current_task-gated)/after(per-allocation) 對比——production 升（intent）但**非爆量/崩**（need+materials cap）。
3. **③determinism**：移 gate 不加 RNG、tile/team iterate 既有序 → 三跑 byte-identical。
4. **④守憲**：勞力池 invariant 保（need-gated no-floor、承載獨立、決策不碰）；constitution gate（移補丁閘應**減** site 非增）。
5. **⑤★領導軸 ratio 真追平**：§8 re-measure——(i) 後大隊 facility 真跑（用掉 idle 勞力真產）→ 領導軸 ratio **接近 parity**？（誠實 measured 才宣稱、同 SLICE A、若沒追平=再挖非 crank）。
- **perf**：移 gate→更多隊每 tick 跑 mfg（was current_task-gated 少數）；記 known_issues perf follow-up 若量測顯著。

## §4 工序
本 spec → **R² 自審**（de-patch 非疊補丁/need-gated 保留/憲法 production 解耦一致/determinism/blast-radius 驗夠）→ reviewer R²（補丁閘移除、constitution site 減）→ implementer（隔離 `feat/mfg-labor-depatch`）→ dev-verify（5 驗）→ §8 三驗（領導軸+全經濟）→ §5 合量。
**血脈**：de-patch 延伸 settled 勞力池架構、非新機制、非 crank（[[feedback_no_patch_on_settled_architecture]] 反向：這是**移**補丁閘 completing 統一）；genuine（facility 真產出真 allocated 勞力）。
