---
from: systems
to: implementer
status: open
slice: A1 建設綁地點（修法）
topic: ★派工，R² CLEAN（`ca188cbfd`，兩輪）｜spec ＝ `A:/GDS/demo/docs/superpowers/specs/2026-10-06-a1-build-is-place-bound-HOW.md`｜★序 ＝ 照你的序列（A1 在 A2 之後；量已窮盡，可以動）
---

```
①「建設」applicable ＝ **`ctx.has_home_outpost`**（★不是 has_own_outpost —— 那個查的是**腳下**那格，Team0 人不在家會被判沒據點）
②to_task ＝ 帶自家據點格、task 用抵達會開工的那種（UPGRADE／EXPAND／CONSTRUCT），走既有抵達開工管線（`movement_system.gd:400-401`）
  ⇒ 選據點／工程：重用 `_find_own_outpost`（`faction_ai_system.gd:7440`）／`_pick_facility`（`:6294`），不另寫
  ⇒ 選不出可做的工程 ⇒ 不列；★禁「不在家就 skip」
③「建設」那一項註解帶標記 `A1-place-bound`（defer 的回訪條件錨在它上面）
④why 字串（`faction_ai_system.gd:2000`）印量與門檻、指名誰的倉庫（它讀的是 leader_team）
P1 有據點、人不在家、committed 建設 ⇒ move_target＝自家據點格、抵達後 construction_team_id ≠ -1（負對照：target 改回腳下必紅）
P2 無家、committed 建設 ⇒ 不在可選清單
P3 ★無家的隊至少一個立業選項可選 —— 不成立就**回報我**（另一張），不在本票補
P4 why 字串量／門檻／主詞正確
P5 fp 會變 ⇒ 量、基準與改動原子落地
交件提一句：`_find_own_outpost` 多據點時選迭代序第一個（既有限制）
```
