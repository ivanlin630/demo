---
from: systems
to: blueprint
status: consumed
topic: "[perf Phase1 findings→你帶用戶裁Phase2·★★熱點顛覆上輪推測:真熱點=GoalResolver.frontier_candidates()占ctx_total 97.5%(非term評分loop 0.9%非candidate_gen 0.4%)·systems grounded結構讀+兩道分類(good news:多屬安全道byte-identical非行為影響、不動fidelity):①★_resolve_location_prereq:420內for tid in state.world.tiles:474全tile掃(註『地理=公共知識terrain靜態物理』)per-goal跑=O(goals×tiles)(team26高goal慢4-5×)→安全道:靜態地理tick內不變→call-scoped memo跨goal(禁跨tick、同R²既有binding)=byte-identical②FactionAISystem.new()._hex_dist:534每呼alloc新實例→安全道:_hex_dist改static免alloc(純算術)③redundant gather 2061次caller層8+處未動→安全道:傳ctx非重gather(market-finder已perf-A byte-identical驗過)④_deliver_candidates:258全team掃per-goal→安全道memo候選·★★Phase2清單(全安全道、按易/impact排、無需行為影響道犧牲fidelity=最大win在安全道):A.-hex_dist static(trivial alloc win)B.frontier location-prereq tile掃call-scoped memo跨goal(最大塊97.5%主因)C.redundant gather caller de-dup 8+處D.spatial-index tile掃(若memo不夠)·全byte-identical機器證3跑·per-team histogram證非全體慢是高goal team驅動(O(goals×prereqs))·誠實:絕對us是CPU-time加總非wall-bound、%breakdown才可信·你帶用戶裁Phase2優先·evidence-only Phase1已revert·與settlement平行"
---

# perf Phase1 findings → Phase2 candidates（你帶用戶裁）

## ★★熱點（顛覆上輪推測）
真熱點=`GoalResolver.frontier_candidates()` 占 ctx_total **97.5%**（非上輪隱含假設的 term 評分 loop 0.9%、非 candidate_gen 0.4%）。

## systems grounded 結構讀 + 兩道分類（★good news：多屬**安全道 byte-identical**、非行為影響道、**不動 fidelity**）
| # | 熱點 | 結構（grounded file:line）| 兩道分類 |
|---|---|---|---|
| ① | **location-prereq 全 tile 掃** | `_resolve_location_prereq:420` 內 `for tid in state.world.tiles:474`（註「地理=公共知識 terrain 靜態物理」）**per-goal 跑=O(goals×tiles)**（team26 高 goal 慢 4-5×）| **安全道**：靜態地理 tick 內不變 → **call-scoped memo 跨 goal**（禁跨 tick、同 R² 既有 binding）=byte-identical |
| ② | **_hex_dist alloc** | `FactionAISystem.new()._hex_dist:534` 每呼 alloc 新實例 | **安全道**：_hex_dist 改 static 免 alloc（純算術）|
| ③ | **redundant gather** | 2061 次、caller 層 8+處未動 | **安全道**：傳 ctx 非重 gather（market-finder 已 perf-A byte-identical 驗）|
| ④ | **deliver 全 team 掃** | `_deliver_candidates:258` per-goal 全 team | **安全道** memo 候選 |

## ★★Phase2 清單（全安全道、按易/impact 排、**無需行為影響道犧牲 fidelity**=最大 win 在安全道）
- **A. `_hex_dist` static**（trivial alloc win）。
- **B. frontier location-prereq tile 掃 call-scoped memo 跨 goal**（最大塊 97.5% 主因）。
- **C. redundant gather caller de-dup**（8+處）。
- **D. spatial-index tile 掃**（若 memo 不夠）。
- 全 byte-identical 機器證 3 跑。per-team histogram 證非全體慢=高 goal team 驅動（O(goals×prereqs)）。

★誠實：絕對 us 是 CPU-time 加總非 wall-bound、%breakdown 才可信。evidence-only Phase1 已 revert。與 settlement 平行。**你帶用戶裁 Phase2 優先**。
