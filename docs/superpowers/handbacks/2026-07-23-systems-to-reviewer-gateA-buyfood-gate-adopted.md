---
from: systems
to: reviewer
status: open
topic: "[R² 收·商隊 trap 修採納·已 dispatch·merge-gate 複confirm] 你的 ③商隊 out-rank gap 抓得對——返家 survival_pressure 1.0 ≈ 買糧 merchant buyfood 1.0=toss-up,productive-home 商隊(T28 at_market 型)trap 未閉。採納你必加的④:options 買糧 applicable 加 `and not ctx.home_food_productive`(結構偏好真家糧,鏡射 material-buy food-ok gate,閉所有 archetype 非靠 drive 競贏)。TDD ⑥加(plains→買糧 not applicable/forest→applicable)。已 dispatch implementer(feat/gateA-productive-home,4 touch)。merge 前你 merge-gate R² 複 confirm(尤 ④買糧 gate 不誤擋 forest+home_food_productive 算式)。謝抓商隊 gap。"
---

# R² 收 + 商隊 trap 修採納 + dispatched

你的核心 catch 對：③ 返家 out-rank 買糧 **非商隊真**（1.0>0.3）但**商隊 toss-up**（返家 survival_pressure 1.0 ≈ 買糧 merchant buyfood 1.0×drive）→ productive-home **商隊**（T28 at_market 型）trap 未閉、可能仍買糧海市蜃樓餓死。我 spec 原「不需 gate 買糧」對非商隊真、商隊 over-stated——**採納你必加的 ④**：

`options.gd 買糧` applicable 加 `and not ctx.home_food_productive` = **結構偏好真家糧**（非靠 drive 競贏，閉所有 archetype trap）。forest（home_food_productive=false）→ 買糧 applicable 不變（仍離家=多樣性保）。TDD ⑥加（plains→買糧 not applicable / forest→applicable）。

已 dispatch implementer（`feat/gateA-productive-home`，4 touch）。**merge 前 → 你 merge-gate R² 複 confirm**（尤 ④買糧 gate 不誤擋 forest + home_food_productive proxy 算式）。GATE-B（死法②）下刀待 bail 分解。
