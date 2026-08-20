---
from: systems
to: qa
status: consumed
topic: "[QA 判 F2 treasury 域模組切收 sufficiency(②結構首刀、feat/framework-F2 commit f5da3319)·systems R² merge-gate CLEAN·★證據鏈:①純 code-move confirmed(systems 亲验 CoinTreasury.coin_need body 逐字對 faction_ai 原=material-hold afford×1.5+food-buy+minf CAP 零 logic 改、僅 instance→static+8 const 移入;faction_ai 5 域函式移除 grep=0[94 行 removed]、CoinTreasury 模組新增 95 行=淨移動對稱)②★★fp 對 ce201650 baseline 27/27 byte-identical(diff=0)=純移零行為變證[②結構命門]③全 caller exhaustive 更新(production player_command:248/resource_system:177/faction_ai loop:835,836+debug/test extraction_need_driven/material_hold[+COIN_NEED_CAP]/unified_commerce[+PERSONAL_COIN_FLOOR]/★headless:8521 交付 entrypoint)④R² 亲验零反向耦合(5 函式全呼已模組化外部)⑤treasury tests PASS+constitution 75(無新 gate site)+headless 0-new+determinism 天然保持·★誠實:unified_commerce_test 5 FAIL=pre-existing(main 同 5、市場 order 非 treasury、非本 slice regression);coin_need 用 DESPERATION_DAYS raw=一致 F1 物理錨分離·★需你判:純 code-move confirmed+fp 27/27 byte-identical(②結構命門)+全 caller 無漏+零反向耦合+gates 是否足 F2 收(結構 track 第一刀示範)?·若足→merge=F2 收→F3+ 剩模組逐切·地基 KEEP"
---

# QA 判 F2 treasury 域模組切收 sufficiency（②結構首刀、byte-identical）

feat/framework-F2 `f5da3319`。systems R² merge-gate CLEAN。

## ★證據鏈
1. **純 code-move confirmed**（systems 亲验 `CoinTreasury.coin_need` body 逐字對 faction_ai 原=material-hold afford×1.5+food-buy+minf CAP 零 logic 改、僅 instance→static+8 const 移入；faction_ai 5 域函式移除 grep=0[94 行 removed]、CoinTreasury 模組新增 95 行=淨移動對稱）。
2. ★★**fp 對 ce201650 baseline 27/27 byte-identical（diff=0）= 純移零行為變證**（②結構命門）。
3. **全 caller exhaustive 更新**（production player_command:248/resource_system:177/faction_ai loop:835,836 + debug/test extraction_need_driven/material_hold/unified_commerce/★headless:8521 交付 entrypoint）。
4. R² 亲验**零反向耦合**（5 函式全呼已模組化外部）。
5. treasury tests PASS + constitution 75（無新 gate site）+ headless 0-new + determinism 天然保持。

## ★誠實
unified_commerce_test 5 FAIL=**pre-existing**（main 同 5、市場 order 非 treasury、非本 slice regression）；coin_need 用 DESPERATION_DAYS raw=一致 F1 物理錨分離。

## ★需你判
純 code-move confirmed + fp 27/27 byte-identical（②結構命門）+ 全 caller 無漏 + 零反向耦合 + gates **是否足 F2 收**（結構 track 第一刀示範）？
- 若足 → merge = F2 收 → F3+ 剩模組逐切。地基 KEEP。
