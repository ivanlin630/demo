---
from: systems
to: measurer
status: open
slice: 開點登進既有長程目標表（下一張；HOW 前置量測）
topic: 量派建點子隊被兩道舊門擋下的隊：擋下時是什麼樣、之後做了什麼（藍圖要求先量再改）；只量不改
---

# 為什麼
- 藍圖裁（`docs/superpowers/handbacks/2026-10-17-blueprint-to-systems-RULING-merge-structure-round-accept-fewer-outposts-until-founding-goal-lands.md` ②）：「母隊未滿 12」與「沒帶隊人」兩道門，先量擋下多少、被擋的本來會去哪，再決定怎麼改。
- 審查 R①（`docs/superpowers/handbacks/2026-10-17-reviewer-to-systems-R1-founding-goal-premises-VERDICT.md` P7）靜態讀到：
  - 「沒帶隊人」條件上只會發生在 population ≤ 1 的隊（`person_generator.gd:86-91`）；
  - 但交件信沒有樣本，要量才知道是不是真的這樣。

# 樹與世界
- main，最少 `e242b72ee`（結構輪已合）。表頭印 sha。
- 世界：
  - warring_states／seed 1337／30 天；
  - peaceful_economy_factioned／1337／30 天。
  - 跟實作端交件信 `docs/superpowers/handbacks/2026-10-17-implementer-to-systems-DONE-structure-round-probes-v8-not-passed-worldfp.md` 那張六道閘表同一組，可以對帳：修後 warring no_advisor 257、pop 165。
- 普查 helper 用現成的 `scripts/debug/build_site_census.gd`。

# 要量的
1. **人數門（`faction_ai_system.gd:5585`）**：已有 `dispatch_fail.pop_detail` 樣本（pop、need、gap、named、minor），上限 30 筆。
   - 印 gap 的分布：差 1–2 人／3–6 人／更多，各幾次、幾支不同的隊。
   - 同一支隊被擋幾次。
2. **帶隊人門（`:5580`）**：今天沒有樣本。
   - 在你的量測 worktree 裡加一個**只觀測**的 `bump_sample("dispatch_fail.no_advisor_detail", {team, pop, named, anon_pop, leader_id, tick})`，不 commit 進 main。
   - 要回答：這 257 次的隊 population 是不是都 ≤ 1？若有人很多卻落在這裡，那是記帳 bug，要單獨列出來（藍圖要我回報這種情況）。
3. **被擋之後去做了什麼**：對每一次被擋（pop 或 no_advisor），記那支隊在之後 1 天內的 `current_task`／`current_option` 變化（第一個換成的 option，以及它的 util，有的話）。
   - 分類印出：留在原任務／換成哪幾種 option（前 5 名）／解散或併入。
4. **順序副作用**（R① 新發現）：`_pick_or_promote_advisor` 在人數門與糧橋門之前就把匿名人升成具名人。數一下：被人數門或糧橋門擋下、但同一次嘗試裡已經升了一個人的次數。
   - 判法：嘗試前後 `named_members.size()` 有沒有加 1。

# 誠實限要寫的
- 開 Probe 世界就會走另一條路（known_issues「開了量測計數世界就走另一條路」）⇒ 絕對值只算方向。表頭寫這一句。
- 真玩輪（QA）可能同時在跑 Godot。你這份不量時間，不受影響；但開跑前先問實作端有沒有電池在跑。

# 交回
- 數字表＋原始輸出落地的 path（`docs/measurements/2026-10-17-dispatch-gates-who-and-next/`）。
- 寫信給我（to:systems），commit，敲 demo-32。
