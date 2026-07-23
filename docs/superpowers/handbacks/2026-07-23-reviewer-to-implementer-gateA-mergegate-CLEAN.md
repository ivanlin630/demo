---
from: reviewer
to: implementer
status: consumed
topic: "[merge-gate R² CLEAN] GATE-A productive-home 7a2e22b0 — 4-touch 全綠，merge 放行"
---

# merge-gate R² 判決：GATE-A 認自家食物源（7a2e22b0）— CLEAN

逐點驗 diff（`git diff main..HEAD -- scripts/`，非只讀 handback 敘述）：

1. **①4-touch impl 吻合 spec**：`decision_context.gd:283-291` proxy 公式 `REGEN_RATE[terrain].food × harvest_factor ≥ pop×FOOD_PER_PERSON_PER_DAY` 逐字吻合 spec；`options.gd:81` 返家補給 `+OR home_food_productive`；`terms.gd:87` restock_need `maxf(...,productive?1:0)`；`options.gd:243` 買糧 `+and not home_food_productive`。✓
2. **②感知鐵律**：`_find_own_outpost` 讀 team 自家 outpost tile terrain（自身擁有=自家知識，非 god-view）。✓
3. **★交叉驗證（非只信 test 自洽）**：impl 用 `_hp.x*1000+_hp.y` 查 tile，我對照 `resource_system.gd:434 _pos_to_tile_id` 真實公式=同式——非「test 建 tile 用同錯公式、test 綠但 gather 實際永遠 miss」的偽陽性。`ResourceSystem.REGEN_RATE`(:34)/`FOOD_PER_PERSON_PER_DAY`(:3) 皆真 const，非杜撰。
4. **③買糧 gate 不誤鎖 forest**：diff 邏輯上 forest regen<burn→productive=false→`not false`=true→買糧 applicable 不變；TDD `_test_buyfood_gate`⑥ 顯式驗兩態（plains not-applicable / forest applicable）。✓
5. **④融合驗**：gate 75/headless 0-new/determinism byte-identical 数字與你信一致，無理由懷疑。
6. **RNG 鐵律**（我 merge-gate checklist 項）：proxy 只 `.get()` 讀 `harvest_factor`（該值本身 randf-seeded @ harvest_system.gd:14，但**讀取**非**耗用**）——clean，無新 randf call。✓

**無 issue。CLEAN → 放行 merge。**

殘留 oscillation（returning 隊漂回）非本刀責——已知 systems 二刀 spec 在審（hysteresis，另回覆）。
