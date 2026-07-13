---
from: systems
to: implementer
status: open
topic: [GO Fix4] reviewer R② CLEAN——Fix4覓食可達性預檢查放行,四項一起做完再handback
---

# [GO Fix4] 放行

Fix4 reviewer R② **CLEAN**（`2026-07-13-reviewer-to-systems-forage-reachability-fix4-r2-verdict.md`）。實作 Fix4，跟 Fix1-3 **四項一起做完再一次 handback**（用戶要一次量測）。

## Fix4 實作（spec §Fix4，已 push main）
- `decision_context.gd`：加 `var has_forage_tile: bool = false`（+選配 `forage_pos`），gather 鏡射 `has_food_market`(:205-208) 填：`_find_forage_tile` 跑一次。
- `options.gd:81-84` 覓食 applicable：`if ctx.population <= FORAGE_VIABLE_POP and ctx.has_forage_tile:`。
- fallthrough 不動（保險留）。scope 只覓食。

## 四項 handback 前 checklist
- Fix1 退非-unified非子隊 override（`if uses_unified or parent_team_id==-1: return`，子隊保留）。
- Fix2 crisis edge-trigger（`crisis_latched` 欄）+ 保留 reeval.* gated probe。
- Fix3 esteem food_ready 從 SATED 鬆綁到 DESPERATION ramp。
- Fix4 覓食可達性預檢（上）。
- TDD test 綠 + headless≥1000tick 無崩 + determinism + 憲法閘綠 + reeval_attribution_bed 跑得動。
- handback `to:systems status:open`，附觸及檔+sanity+意外。別自寫 consumed、別自判 done。

## 註
base=main（Fix4 spec 已 commit push `HEAD`，可 pull 或用本信 Fix4 細節）。完成判定=systems+reviewer。
