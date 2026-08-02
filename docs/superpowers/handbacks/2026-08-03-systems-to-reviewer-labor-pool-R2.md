---
from: systems
to: reviewer
status: open
topic: "[R²(可升R①)統一勞力池HOW·讓size在生產matter治CASE B(genuine-value非crank,用戶size-matter裁定)·spec docs/superpowers/specs/2026-08-03-unified-labor-pool-HOW.md·premise §0全G0 grounded(manufacturing:82/resource:63,265-266/need_oracle:13-15/outpost:166/faction_ai:106)·設計:新LaborSystem單一共享allocator採集+製造共讀,per-tile勞力池=共址PRODUCE pop總和,workstation demand=規模×K,need_oracle加權比例+demand-cap+溢出串聯deterministic,頻率解耦lazy-on-cadence(LABOR_CADENCE 3天+危機food<2觸發),labor_mult取代兩套pop_mult(baseline-preserving校準±5%+linear到demand-cap=size matter)·★審點:①統一非平行patch(單allocator採集製造共讀非各搞)②deterministic(sorted+算術+cascade固定迭代+零RNG三跑byte-identical)③承載獨立(只改pop_mult→labor_mult,current/COLLECT_RATE/regen零改)④baseline保真(LABOR_SCALE校準±5%現況防偷改量級)⑤憲法決策不碰(執行層rate非util/argmax)⑥size matter genuine非crank(產出∝真手數到demand-cap,大隊餵多工位,勞力真經濟投入)⑦大隊一格遞減靠demand-cap+current非sqrt⑧R②自審補§2b多隊防雙算/perf·可升R①若你認新seam大框需premise深驗·CLEAN→dispatch隔離branch"
---

# R²（可升 R①）統一勞力池 HOW

spec：`docs/superpowers/specs/2026-08-03-unified-labor-pool-HOW.md`。用戶裁定 size-matter（case A、genuine-value 非 crank [[feedback_genuine_value_not_crank]]）。premise §0 全 G0 grounded（file:line）。

## 設計摘要
新 `LaborSystem` 單一共享 allocator（採集+製造共讀）；per-tile 勞力池＝共址 PRODUCE pop 總和；workstation demand＝規模×K；need_oracle 加權比例 + demand-cap + 溢出串聯（deterministic sorted）；頻率解耦 lazy-on-cadence（LABOR_CADENCE 3 天 + 危機 food<2 觸發）；labor_mult 取代兩套 pop_mult（baseline-preserving 校準 ±5% + linear 到 demand-cap ＝ size matter）。

## ★審點（我要你戳的）
1. **統一非平行 patch**：單 allocator 採集+製造共讀（§1）、非各搞一套？
2. **deterministic**：sorted key + 算術 + cascade 固定迭代上限 + 零 RNG → 三跑 byte-identical？
3. **承載獨立**：只改 `pop_mult→labor_mult` 那一支、`current/COLLECT_RATE/regen`（resource:254-284）零改？
4. **★baseline 保真**：`LABOR_SCALE` 校準 ±5% 現況（§4）＝防偷改量級/防生產崩或爆——校準邏輯站得住嗎？（最delicate、dev-verify 硬斷）。
5. **憲法決策不碰**：勞力池＝執行層 rate、非 util/argmax 決策？
6. **★size matter genuine 非 crank**：產出 ∝ 真手數（到 demand-cap）、大隊餵多工位、勞力真經濟投入＝湧現非腳本？（守 [[feedback_genuine_value_not_crank]] 命門、別又是 crank）。
7. **大隊一格遞減**：靠 demand-cap + current 承載（非 sqrt）、游牧大隊仍餓？
8. **R② 自審補 §2b**：多隊 gather 防雙算（team_pop/pool 比例）、output ownership 不變、perf tile→teams index——夠嗎？

## note
- **可升 R①**：若你認新 seam 大框需 premise 深驗（G0 已 file:line 但 allocator 是新概念），升 R① factcheck。
- CLEAN → 我 dispatch implementer（隔離 branch `feat/unified-labor-pool`）→ dev-verify（baseline 保真 + size matter + 承載）→ measurer。有洞 → 回 `to:systems`。
