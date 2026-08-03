---
from: systems
to: implementer
status: open
topic: "[manufacturing per-labor-allocation de-patch開工(blueprint裁i,領導軸真根=facility從不RUN)·spec docs/superpowers/specs/2026-08-03-mfg-labor-integration-depatch-HOW.md(R²CLEAN)·做:移除manufacturing_system.gd:67 `if current_task!=TASK_MANUFACTURE: continue`一行(補丁閘,把已整合勞力池的62-96整段擋前面)→manufacturing為PRODUCE隊在自家outpost就跑(existing checks outpost+PRODUCE resident已position+type gate,如gather對稱)·tick_all其餘全不動(ensure_fresh+labor_share=team_pop/pool防雙算+worker_rate=level×labor_mult(mfg:Lk)×labor_share×skill+_run_recipe_group materials check)·★保留gate自動(need-gated §51:need=0→fill=0→worker_rate=0不產/materials/dedup/position/軍隊不在pool_of)·★blast-radius 5硬驗(全經濟非只大隊):①不過度生產(satisfied隊need=0 facility fill=0產出=0非亂產)②不economy衝擊(production/coin/資源水位before/after對比升但非爆量崩)③determinism三跑byte-identical(移gate不加RNG)④守憲constitution site應減非增(移補丁閘)+勞力池invariant保⑤領導軸ratio真追平§8·全量tap(mfg fire per-tile/材料消耗/facility產出)·隔離branch feat/mfg-labor-depatch·follow-up TASK_MANUFACTURE option vestigial另清別本輪碰"
branch: feat/mfg-labor-depatch
---

# manufacturing per-labor-allocation de-patch — 開工（領導軸真根 fix）

**spec**：`docs/superpowers/specs/2026-08-03-mfg-labor-integration-depatch-HOW.md`（R² CLEAN）。真根 measurer 實測：mfg:67 `current_task != TASK_MANUFACTURE` 補丁閘 pre-empt 勞力池（飽和度 6.7%+材料消耗 0.000＝facility 從不 RUN）。

## 做（minimal 移閘）
- **移除 `manufacturing_system.gd:67` 的 `if team.current_task != TeamData.TASK_MANUFACTURE: continue`**（補丁閘、把已整合勞力池的 62-96 整段擋前面）。
- manufacturing 改**為 PRODUCE 隊在自家 outpost 就跑**——existing checks（outpost_level>0 :71 / _team_works_tile :76 / PRODUCE resident :80）已 position+type gate，如 gather 對稱。
- **tick_all 其餘全不動**（`ensure_fresh` + `labor_share=team_pop/pool` 防雙算 + `worker_rate=level×labor_mult("mfg:Lk")×labor_share×skill` + `_run_recipe_group` materials check）。

## ★保留 gate（自動、不動）
need-gated（§51、`need=0→labor_mult fill=0→worker_rate=0 不產`）/ materials(`_can_consume`) / dedup(labor_share) / position(outpost) / 軍隊(不在 pool_of)。**移閘不新增任何 gate、只移補丁閘。**

## ★blast-radius 5 硬驗（dev-verify、全經濟非只大隊）
1. **不過度生產**：satisfied 隊（need=0）facility fill=0 → 產出=0（非亂產、full-stop 守）。
2. **不 economy 衝擊**：production/coin/資源水位 before(current_task-gated)/after(per-allocation) 對比——升（intent）**但非爆量/崩**（need+materials cap）。
3. **determinism**：移 gate 不加 RNG → 三跑 byte-identical。
4. **守憲**：**constitution site 應減非增**（移補丁閘）；勞力池 invariant 保。
5. **★領導軸 ratio 真追平**：§8 re-measure（大隊 facility 真跑→用掉 idle 勞力真產→接近 parity？誠實 measured）。
- **perf**：移閘→更多隊每 tick 跑 mfg（記 known_issues 若量測顯著）。
- **全量 tap**：mfg fire per-tile / 材料消耗 / facility 產出。

## 交付
- code 寫 worktree `feat/mfg-labor-depatch`（隔離）、handback `to:systems`（帶 5 驗數字：need-gated 保/economy before-after/determinism/constitution site/領導軸 ratio）→ 我 R² 融合驗 → **§8 三驗（領導軸+全經濟）誠實 measured 才宣稱** → §5 合量。
- **follow-up `TASK_MANUFACTURE` option vestigial 另清、別本輪碰**。卡/economy 爆 → 報 `to:systems`。
