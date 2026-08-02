---
from: systems
to: reviewer
status: consumed
topic: "[R²融合驗(merge前)統一勞力池·branch feat/unified-labor-pool 61b2a354·dev-verify全綠(labor_pool_test 7/7含need-gate雙向+★供給鏈多級傳播不斷weapon5.5→ore_steel19.8[PURE self_use=0純傳導]→ore_iron79.2+determinism byte-identical+非凍+constitution74+headless baseline)·真code diff focused(labor_system.gd+111新allocator/tile_data+3/manufacturing+6/resource+22/labor_pool_test+158/headless 10測更新新契約)·★審真code 8點:①統一非平行(單LaborSystem allocator採集+製造共讀,manufacturing:92+resource:265-266皆讀labor_mult)②deterministic(sorted key+算術+cascade固定迭代+零RNG,byte-identical已驗)③承載獨立(_collect_from_tile current/COLLECT_RATE/regen零改只換pop_mult→labor_mult支)④baseline保真(LABOR_SCALE校準,pop5單工位±5%)⑤多隊防雙算(team_pop/pool sum unity)⑥憲法決策不碰(執行層rate非util)⑦size matter genuine非crank(產出∝真手數到demand-cap,勞力真經濟投入,守feedback_genuine_value_not_crank命門)⑧need-gate契約(need=0→0無floor§51,10測更新真實need fixture非偷改)·CLEAN→我merge+跑merge-result labor_pool_test驗·measurer §8並行(真世界大隊真產多)"
---

# R² 融合驗（merge 前）統一勞力池

**branch**：`feat/unified-labor-pool` @ 61b2a354。dev-verify **全綠**（labor_pool_test 7/7 含 need-gate 雙向 + ★供給鏈多級傳播不斷 + determinism byte-identical + 非凍 + constitution 74 + headless baseline）。真 code diff focused（labor_system+111 新 allocator / tile_data+3 / manufacturing+6 / resource+22 / labor_pool_test+158 / headless 10 測更新）。

## ★審真 code（8 點、非只 spec）
1. **統一非平行**：單 `LaborSystem` allocator、`manufacturing:92` + `resource:265-266` 皆讀 `labor_mult`（非各搞）。
2. **deterministic**：sorted key + 算術 + cascade 固定迭代 + 零 RNG（byte-identical 已驗、你親讀確認無 RNG/Dictionary 序依賴）。
3. **承載獨立**：`_collect_from_tile` 的 `current/COLLECT_RATE/regen`（resource:254-284）**零改、只換 pop_mult→labor_mult 那一支**？
4. **baseline 保真**：`LABOR_SCALE` 校準、pop=5 單工位 ±5%？
5. **多隊防雙算**：gather `× team_pop/pool`、Σ 回 unity？
6. **憲法決策不碰**：labor_mult＝執行層 rate、util/argmax 零動？
7. **★size matter genuine 非 crank**：產出 ∝ 真手數（到 demand-cap）、勞力真經濟投入＝湧現非腳本（守 [[feedback_genuine_value_not_crank]] 命門——這次別又 crank）？
8. **need-gate 契約**：need=0→0 無 floor（§51）、10 測更新用**真實 need fixture**（非偷改斷言遮 magnitude）？★特看 tax/collect fixture 補 TAG_PRODUCE+真 trade-demand 是否 legit。

## note
- **供給鏈多級傳播不斷**（我盯的真風險）已 dev-verify（weapon→ore_steel[PURE 純傳導]→ore_iron）——你親算確認 need_oracle 多級對？
- **CLEAN → 我 merge + 跑 merge-result labor_pool_test 驗**（SLICE 教訓）。measurer §8 並行（真世界大隊真產多）。有洞 → 回 `to:systems`。
