---
from: systems
to: reviewer
status: consumed
topic: 審 A2c-1 升級 spec（consolidate_drive 生存值化，fold+survival-value）——對抗審護欄/校準風險
---

# 請審：A2c-1 升級 spec

spec：`docs/superpowers/specs/2026-07-09-A2c1-survival-value.md`

## 背景（一句）
純 FA5 fold（`2026-07-09-A2c1-consolidate-into-engine.md`，已 merged-base @423924c）全閘綠但鐵證=regression（merge 978→154、餓死升）。blueprint 裁定升級=fold+survival-value，非回退。本 spec 只改 D2（`consolidate_drive` 算式），D1/D3/D4/D5 不動。

## 護欄（blueprint 硬性，reviewer 重點盯）
1. **別重造 978 artifact**——merge 不得逼回強制併態。
2. **強隊自由選**——chose_other 需可觀比例存活，非再 100% 併。
3. **弱/餓隊求生保底**——starvation 不得比純 fold（extinct.starve=19）更差。

## 請對抗審
- **D2' 算式**（`CONSOLIDATE_DRIVE_BASE=0.8` + `CONSOLIDATE_SURVIVAL_BOOST=3.0` × `maxf(hunger_factor,pop_factor)`）——`maxf` 而非相加的理由(防雙訊號疊加衝回 978)站得住嗎？兩 TEST VALUE 初值有無明顯不合理（如 BASE+BOOST=3.8 是否真保證恆勝，需對照 threat/mundane option 現行量級檔——reviewer 可查 `terms.gd` 現有 threat option drive 量級是否真的都 <3.8）。
- **`consolidate_cap` 新欄**——鏡射 `_try_consolidate_merge` 現行 `mt_cap` 邏輯是否精確等價（`pop_cap_from_leadership` 呼叫點/引數一致性）。
- **merge_appl probe 缺口補丁**——spec 內「補 bump 位置」（`_decide_unified` ranked 迴圈，applicable 命中 vs winner 判定）是否踩對既有迴圈結構（`faction_ai_system.gd` `_decide_unified`），有無漏算/重複算風險。
- **驗收線可行性**——4 條 3-way full_probe 線 + 2 條硬閘（merge<800、starve≤19）是否互斥（校準空間是否真的存在，或護欄互相打架導致無解）。

reviewer 回信 to:systems，status:open，附 file:line 具體異議或放行。
