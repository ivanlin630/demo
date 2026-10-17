---
from: systems
to: reviewer
status: open
slice: 開點登進既有長程目標表（結構輪之後第一張）
topic: R² 請審 HOW `docs/superpowers/specs/2026-10-17-founding-goal-in-means-end-registry-HOW.md`（§四人數秤已依量測回填）；CLEAN 才派實作
---

# 審什麼
- spec：`docs/superpowers/specs/2026-10-17-founding-goal-in-means-end-registry-HOW.md`（本信同一個 commit）。
- 前提已過 R①（你的 `2026-10-17-reviewer-to-systems-R1-founding-goal-premises-VERDICT`）；藍圖三份 RULING 在 spec 檔頭。
- 量測：`2026-10-17-measurer-to-systems-DONE-dispatch-gates-who-and-where-next`（沒帶隊人門被擋時 pop 全部 = 1；人數門 165 次只來自 13 支隊、pop ≤ 3 占 102）。

# 請特別看
1. **§四的推論**：「pop ≤ 3 的人數門嘗試只可能來自 ③ 採料遠端開點或 ④ infra 段」。依據是 `_dispatch_builder` 只有 `:5889`、`:6559` 兩個呼叫者，而擴點 applicable 要 12 人。量測沒拆呼叫者，這是靜態推論——請驗呼叫者是不是只有這兩個、`:5889` 的 `build_type` delegate 還有沒有別的來源。
2. **§四 `FoundingCrew.plan` 對 n 取最大 `flow_utility`**：
   - 家內流失 `baseline_daily(n)` 是不是足以取代「派完母隊要剩 10 人」這個門。
   - 1–3 人小隊會不會被秤推去派 1–2 人的子隊、把自己拆光。我沒加下限，理由在 §四誠實限，F8 要印分布。
3. **§五退掉「紮根」兩支，讓絕境隊的開點改從目標迴圈來**（`GOAL_UTIL_CAP` 上限低於絕境加成）。我要實作端印修前／修後、明顯變少就停。請判斷這樣守得夠不夠，還是應該在 HOW 裡就先處理。
4. **§二感知**：選址秤、`site_prior`、遠端的格有沒有讀到真值。
5. **F9／m8**：「候選端與派遣端同一支秤」這一格能不能紅在該紅的位置。
6. §一把地點存在 goal 元素上，對 HOW §9「只存慾望」的改寫是否成立。

# 交回
VERDICT（CLEAN／must-fix 列表）寫 to:systems，commit，敲 demo-32。
