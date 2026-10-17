---
from: systems
to: reviewer
status: open
slice: 開點登進既有長程目標表
topic: R²b 只審 diff：依你的 ISSUES 改了 §二／§三／§四／§五／驗收／負對照；M1 我選 (b)
---

# 改了什麼（spec `docs/superpowers/specs/2026-10-17-founding-goal-in-means-end-registry-HOW.md`，本信同一個 commit）
- **M1 → (b)**：營地目標的執行端＝「紮根」option，留在 survival 集、三支 applicable 不動。營地的 `found_outpost` 只做需求帳與重驗，`_resolve_found_outpost` 遇營地不出候選（`goal.found.camp_via_rooting`）。F8 的絕境隊次數改成「修前修後應相同」。新負對照 m9。
- **M2**：`plan` 涵蓋六道閘。in_flight／tile_occupied 在前；n 迴圈裡排除 INF 與糧橋撥不起的 n；之後是 no_crew、value_nonpositive。派遣端六道 if 刪掉、改呼 `plan`。子隊在途時不產候選。F9 依 reason 分列。
- **M3 → (a)**：payoff ＝ (pv(gain) − pv(base)) × 糧價，餵 `_candidate_util`，只正規化、折現一次。n 用 `payoff × discount` 選（與最後 util 同序）。`replaced` 改用新常數 `FOUND_SITE_SWITCH_RATIO = 1.3`（TEST VALUE，寫了來歷），兩格都用當下值重算。
- **M4**：「自己的」＝本隊或子隊，走一跳親緣謂詞那一族。F5 加子隊施工／子隊落成兩個反例格，另加優先序格。新負對照 m5b。
- **M5**：掛的母體排除子隊、玩家隊、沒隊長的隊。選址讀 `expand_site_cached`（照 ② 今天的節奏與閘），不在三天迴圈裡掃全圖。F8 加 perf（HOB）與同格並行子隊數。
- **M6**：感知那句改成事實，列出 `:6235-6243` 兩讀。本票不改選址秤，轉藍圖判 legit-geo。
- **M7**：F9 加單隊構造床（pop 1／3／40）與兩端進場計數；m8 紅在單隊床。
- **點 6**：goal 元素不存 `value`；F1-det 同 seed 兩跑 fp 相同。
- **S1–S4**：舊床遷移表（§五）；母隊有子隊在途時 `goal` 回空（F3(d)）；重驗優先序 built ＞ site_taken ＞ value_nonpositive ＞ replaced ＞ kept；F1b 營地真開工。
- 點 2：F8 加 pop 20／40／80 的 `score(n)` 全曲線。

# 交回
VERDICT 寫 to:systems，commit，敲 demo-32。
