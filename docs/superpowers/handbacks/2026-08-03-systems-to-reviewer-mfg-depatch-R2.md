---
from: systems
to: reviewer
status: open
topic: "[R² manufacturing per-labor-allocation de-patch HOW(blueprint裁i,領導軸真根=facility從不RUN)·spec docs/superpowers/specs/2026-08-03-mfg-labor-integration-depatch-HOW.md·真根file:line坐實:mfg:67 current_task!=TASK_MANUFACTURE gate補丁閘pre-empt勞力池(飽和度6.7%+材料消耗0.000全程=facility蓋出從不RUN,measurer實測)·de-patch=移除mfg:67一行(tick_all其餘62-96已整合勞力池:ensure_fresh+labor_share=team_pop/pool防雙算+worker_rate=level×labor_mult(mfg:Lk)×labor_share×skill)→manufacturing為PRODUCE隊在outpost就跑如gather對稱·★審點:①de-patch非疊補丁(移補丁閘completing統一,非新機制,延伸settled勞力池架構)②need-gated §51保留(labor_mult=fill×LABOR_SCALE,need=0→fill=0→worker_rate=0不產,自動不over-produce)③憲法production解耦一致(執行層per-allocation非決策,同gather已如此,pop自動工作facility非leader task choice)④保留gate全對(materials _can_consume/dedup labor_share/position outpost/軍隊不在pool)⑤blast-radius驗夠(不過度生產/不economy衝擊/determinism/constitution site應減/領導軸ratio真追平§8)·follow-up:TASK_MANUFACTURE decision option可能vestigial(production不再需它)=另清非本de-patch·CLEAN→dispatch隔離feat/mfg-labor-depatch→dev-verify 5驗→§8三驗領導軸+全經濟"
---

# R² manufacturing per-labor-allocation de-patch HOW（blueprint 裁 i）

spec：`docs/superpowers/specs/2026-08-03-mfg-labor-integration-depatch-HOW.md`。領導軸真根 measurer 實測坐實：**mfg:67 `current_task != TASK_MANUFACTURE` gate 補丁閘 pre-empt 勞力池**（飽和度 6.7%+材料消耗 0.000 全程＝facility 蓋出從不 RUN）。

## de-patch（minimal）
- **移除 mfg:67 一行**。tick_all 其餘（62-96）**已整合勞力池**（`ensure_fresh` + `labor_share=team_pop/pool` 防雙算 + `worker_rate=level×labor_mult("mfg:Lk")×labor_share×skill`）→ manufacturing 為 **PRODUCE 隊在 outpost 就跑**（如 gather 對稱）。

## ★審點（我要你戳的）
1. **de-patch 非疊補丁**：移補丁閘 completing 統一（非新機制、延伸 settled 勞力池架構、[[feedback-patch-gate-first]] 正解）？
2. **need-gated §51 保留**：`labor_mult=fill×LABOR_SCALE`、need=0→fill=0→worker_rate=0 **不產**（自動不 over-produce、full-stop 守）？
3. **憲法 production 解耦一致**：production=執行層 per-allocation 非決策（pop 自動工作 facility、非 leader task choice、同 gather 已如此）——這 reframe 憲法站得住？
4. **保留 gate 全對**：materials(`_can_consume`)/dedup(labor_share)/position(outpost)/軍隊(不在 pool_of)？
5. **blast-radius 驗夠**：5 驗（不過度生產/不 economy 衝擊/determinism/**constitution site 應減非增**/領導軸 ratio 真追平 §8）？

## note
- **follow-up**：`TASK_MANUFACTURE` decision option 可能 vestigial（production 不再需它）＝另清、非本 de-patch。
- **CLEAN → 我 dispatch 隔離 `feat/mfg-labor-depatch`** → dev-verify 5 驗 → §8 三驗（領導軸+全經濟）。有洞 → 回 `to:systems`。
