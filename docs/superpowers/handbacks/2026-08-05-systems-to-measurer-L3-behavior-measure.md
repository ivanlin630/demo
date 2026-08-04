---
from: systems
to: measurer
status: open
topic: "[L3 循環貿易 behavior 量(feat/L3-circuit-trade 06c8b452、R² merge-gate CLEAN reviewer 親讀 diff 三塊對 spec+archetype gain-only=TDD sign-flip 正向修正)·驗 L3 真效果(非只 gate 綠):①★遠距跨勢力 deal>0(多床:warring/settled 經濟床/rep 床 config/infonet_faction_rich_rep.json——§5 L3 症『隔格跨勢力貿易死』是否解、板讀 fire、商路湧現)②★訪市人格分化(per-option util dump:重商 archetype 多跑遠/膽小[慎重高]近跑/懶不跑=非齊一,gain[arb+staleness]×archetype−trip×慎重公式真人格 MODULATE)③板 staleness 下降(資訊流通加速可觀測)④economy 不爆/determinism byte-identical·godot --path worktree GODOT_TIMEOUT=1200 禁原地 checkout·★長跑掛 specimen dump(SpecimenDumpHelper)→QA 故事稽核(商人 motive→訪市→撮合→資訊帶回鏈、人格分化真;新常態長跑因果需 QA ref 才過 merge)·回 systems→QA→systems merge·地基 KEEP"
---

# L3 循環貿易 behavior 量（驗真效果、非只 gate 綠）

R² merge-gate CLEAN（reviewer 親讀 diff：三塊對 spec、archetype gain-only=TDD 抓 sign-flip 正向修正）。→ measurer 量真效果（[[feedback_verify_execution_end]] 驗執行端非只生成/gate）。

## 量（湧現式、dump 真值）
1. **★遠距跨勢力 deal>0**（多床：warring / settled 經濟床 / **rep 床 `config/infonet_faction_rich_rep.json`**）——§5 L3 症「隔格跨勢力貿易死（賣方從不讀外市集板）」是否解？板讀 fire？商路湧現？
2. **★訪市人格分化**（per-option util dump）：重商 archetype 多跑遠 / 膽小（慎重高）近跑 / 懶不跑＝**非齊一**（`gain[arb+staleness]×archetype − trip×慎重` 真人格 MODULATE、非死常數門檻）。
3. **板 staleness 下降**（`team_market_last_read` 資訊流通加速可觀測）。
4. economy 不爆 / determinism byte-identical。

## 交付 + 序
- `godot --path .worktrees/L3-circuit-trade`、`GODOT_TIMEOUT=1200`、**禁原地 checkout**。
- **★長跑掛 specimen dump**（`SpecimenDumpHelper`）→ **QA 故事稽核**（商人 motive→訪市→撮合→資訊帶回鏈、人格分化真；**新常態：長跑因果需 QA ref 才過 merge**）。
- 回 systems → QA → systems merge。落地 `docs/measurements/`。地基 KEEP。
