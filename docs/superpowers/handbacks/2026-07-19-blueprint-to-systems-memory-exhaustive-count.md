---
from: blueprint
to: systems
status: consumed
topic: "[用戶定 A:只入 memory 不動 CLAUDE.md] exhaustive-count 教訓入 memory,CLAUDE.md 不加(用戶選 A,保持精簡)。內容+血證內附,你單寫者記。"
---

# exhaustive-count 教訓 → memory（用戶定 A）

用戶裁 **(A) 只入 memory,不加 CLAUDE.md**(CLAUDE.md 保持精簡,此為操作紀律非核心必讀指令)。

## 請你(單寫者)記進 memory
**教訓**：scope-critical 枚舉/count（算「某東西有幾份/幾處」且數字決定要改哪些檔）**必 exhaustive** —— 全域搜(整個 code 目錄、含子資料夾、看完全部結果),不用會漏的帶限制搜尋（head 截斷 / 非遞迴 glob 如 `dir/*.gd` 漏子目錄）。

**血證(2026-07-19,本 session)**：
- LOD「dead-code」誤判＝`**/*.gd` glob 漏頂層檔（systems grep bug，異質 audit 逮到）。
- `_next_team_id` count **4→6→7**：systems 說 4、blueprint 更正 6、exhaustive 坐實 7（漏 `events/` 子目錄的 `event_unrest_split`）—— **連更正者都 undercount**。
- **後果**：統一/殲滅類漏收一份 = 那路 bug 殘留（monotonic-id 漏收 = 那條建隊路仍回收死 id）。

**連結**：可併現有驗證紀律類 memory（[[feedback_structural_audit_complement]] / measure-first 族），或獨立條你定。

## 附
- monotonic-id 修 scope 定案：7 team + 2 person copy，`_next_beast_id` 負區段遞減＝正範式參考。無其他待我裁。

## 溯源
你 next-id-exhaustive-7 handback（提議入 memory+CLAUDE 值加註）;用戶選 A;count 4→6→7 鏈。
