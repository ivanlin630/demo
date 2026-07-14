---
from: implementer
to: systems
status: consumed
topic: "[完] 求和/外交 grounded — HEAD d277259b;TDD 10綠;憲法 sites=29 零新 try_set;seeded warring byte-identical base(零退化)"
---
# Hand Back：求和/外交 grounded

branch `feat/diplomacy-grounded` @ `d277259b`（已 push），base = origin/main `2ac47373`。

## 實作（照 spec，2 commit）
- **Fix1 look-before-leap**（鏡射 A-2 rejection-learning）：`decision_context` 加 `pacify_target_on_cooldown`(threat_id)/`diplo_target_on_cooldown`(faction_diplo_target)＝該 target 在 `team.diplomacy_reject_cooldown` 內（純讀自隊記憶，非 god-view）。`options.gd` 求和(:160)/外交(:138) applicable 加 `and not <on cooldown>`。
- **Fix2 求和 seam**（R² 定死）：`interaction_system._try_diplomacy` 偵 `initiator.order_task == TASK_TRIBUTE_OFFER`（求和）→ `TaskArbiter.release` + `diplomacy_reject_cooldown[target] = +REJECT_COOLDOWN` + 清 `order_task`，**★不呼 `handle_diplomacy_message`**（不誤觸發 propose_alliance）。外交/結盟 `order_task=""`→不入此支→走 propose_alliance 不動。

## 實作決定（透明，非 scope 改）
- **清 `order_task=""` 於 seam**（dispatch 未明列）：因 外交 to_task 不設 order_task、`_wire_threat_task` 對外交不 clear → 若求和後 order_task 殘留 TRIBUTE，下次外交會誤路由為求和。清之防殘留誤路由（honest cleanup，比照 resolve）。TDD Test 3 驗外交 order_task="" 走 propose_alliance 未誤入 seam。
- **求和真息兵 handler 缺＝backlog（dispatch/spec §33 明示）**：本刀只讓求和 grounded no-op（fire→release+cooldown→不 loop、不偽裝求盟），**未自建 sue_for_peace handler**（超 scope，WHAT=blueprint 裁）。→ 建議 systems 記 `known_issues`（求和真息兵行為待 blueprint）。

## 驗（TDD + sanity；log docs/measurements/*-d277259b.log）
- **TDD 10/10 PASS**：Fix1 gate（cooldown 內不入/未 cooldown 入，求和+外交）；Fix2 求和 seam（release+cooldown+清 order_task+不成盟）；外交不誤傷（order_task="" 走 propose_alliance，current_task 仍 DIPLOMACY 非 seam release）。
- **憲法閘 sites=29 removed=0**（gate + resolver 路由，零新 try_set）。
- **headless 3+3 baseline 零新增**（stash 3 檔跑 base 亦 3+3）。
- **零退化**：`seeded warring reproducible OK`；final byte-identical base（`teams:64 pop:444`）。determinism 逐點重現。

## 完成後（measurer 中性重驗）
求和不 loop、不偽裝求盟；外交/結盟不誤傷；A/B/A-2/掠奪不動 → QA 故事複判 → blueprint 批 merge。

## 待確認
- §實作決定 2 點（清 order_task / 求和真息兵記 known_issues）請 systems 過目。完成判定 = systems + reviewer/QA + measurer 中性驗。context hold warm 等裁決信。
