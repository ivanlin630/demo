---
from: systems
to: reviewer
status: consumed
slice: 開點登進既有長程目標表
topic: R²c 只審 N1–N3 對應段＋S1–S4 收沒收（spec 第三版，本信同一個 commit）
---

# 改了什麼（`docs/superpowers/specs/2026-10-17-founding-goal-in-means-end-registry-HOW.md`）
- **N1 → (a)**：`_delegate_variant` 只有紮根走 `plan`，判法是謂詞 `is_founding_task(to_task)`（有 `settle_site` 或 `build_type`）。建設、自救建田照原檢查、不動，範圍外列一條；交件信列 `MIN_PARENT_POP_AFTER_DISPATCH` 剩下的讀者與類別。
- **N2 → (a)**：選址快取拿掉 `idle_labor > 0` 前置，改成「有自家據點 ∧ 屬掛的母體」，節奏與 `advance` 閘照舊。F8 加 perf 那一拍、母體比例（修前 ③④ 嘗試隊對照）。F2 先推一個 `INFRA_INTERVAL`。
- **N3**：`no_crew` 改成步驟 0，在 n 迴圈之前；空範圍不得落進 `site_barren`／`food_bridge`。混合情形看「拿掉糧橋還有沒有可行 n」：有 ⇒ `food_bridge`，沒有 ⇒ `site_barren`。
- **S1**：F8 加開點列 `x` 值分布與維持列、設施列並排，並印 `gu2.payoff_val`；貼頂照實寫、不自己調。
- **S2**：鍵名對照表（`in_flight` 沿用 `busy_subteam`；`no_crew` 取代 `pop`＋`no_advisor`；`value_nonpositive` 新鍵）。
- **S3**：F5 反例格用真實流程造，並印落成當 tick 謂詞的輸入。
- **S4**：generic 分支（`:5904`）升人也移到 `plan.ok` 之後；F7 兩處各驗。
- 另：選址讀遠端存量那條照藍圖裁，另開一張（known_issues 已登），本票範圍外。

# 交回
VERDICT 寫 to:systems，commit，敲 demo-32。CLEAN 就派實作。
