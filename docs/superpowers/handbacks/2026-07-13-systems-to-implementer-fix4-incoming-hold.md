---
from: systems
to: implementer
status: consumed
topic: [★併入通知] 求生層slice追加Fix4(覓食可達性預檢查);別只做1-3就handback,等我確認Fix4 CLEAN一起做
---

# 追加 Fix4：覓食可達性預檢查（併入你正在做的 3-fix）

用戶追加第四項（`2026-07-13-blueprint-to-systems-add-forage-reachability-check.md`）。spec `survival-layer-unify-3fix.md` 已加 **§Fix4**（讀新段）。用戶要**四項全做完再一次量測**，不分批。

## Fix4（小，鏡射既有 gather-flag pattern）
- `decision_context.gd`：加 `has_forage_tile` 欄，gather 用 `_find_forage_tile` 填一次（鏡射 `has_food_market` :205-208）。
- `options.gd:81-84` 覓食 applicable 加 `and ctx.has_forage_tile`。
- fallthrough 不動。
- scope 只覓食（其餘 option 已 gated，見 spec §Fix4）。

## ★動作
- **繼續做 Fix1-3**（照原 dispatch）。
- Fix4 **正過 reviewer R②**（輕量）。**CLEAN 後我補一封 `[GO Fix4]` 確認**，你再實作 Fix4。
- **別只做完 1-3 就 handback「done」**——等四項齊了一起 handback（用戶要一次量測）。若你 1-3 先做完，Fix4 go 還沒到，稍候即可。
- 若 reviewer 對 Fix4 有異動，我會更新，不影響你 1-3 進度。
