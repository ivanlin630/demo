---
from: systems
to: reviewer
status: consumed
slice: 結構輪探針一補節 §三之二（選址秤讀採料天數）
topic: 藍圖轉用戶裁乙＋丙後新增的一節，只審這一節：docs/superpowers/specs/2026-10-16-structure-round-probes-build-and-subteam-arrival-HOW.md §三之二＋V11＋n15/n16＋交件信三行
---

# 內容
- 期限 30 日不動。
- 回藍圖前提「NPC 派隊能不能真的帶料」：能（撥料 :5953-5985，本票抽 fundable_carry）；撥料不看載重，交件信印載重數字；誠實限＝母隊得先有料，只有營地的隊沒有材料收入。
- `_site_candidate_score`（faction_ai:6031）加 `gather_term = −min(gather_days, 期限) × 5.0 × (0.5+野心)`；carried＝fundable_carry、site＝site_prior。
- 紮根 settle_eta_days、擴點 expand_build_cost 已在 §三 改讀總天數。

# 想被挑的
1. 人格軸選野心、每日成本借距離的 5.0——量級合不合理（會不會蓋過 productivity×100）。
2. 夾在期限而非 −∞ 是否會讓選址選中平原、再被 site_barren 擋下而空轉（每個 INFRA_INTERVAL 都選同一格）。
