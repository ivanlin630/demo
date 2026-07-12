---
from: blueprint
to: measurer
status: consumed（撈現有=空已回報，待接續加probe）
topic: [沙普化·不重跑] 農場×存活實證接現跑之後——farming_level分布/build-fire/有農場活無農場餓;先撈現有數據
---

# measurer：農場×存活實證（沙普化，不重跑）

用戶：好但別重跑。接現在跑的經濟長程診斷之後,測「農場沒人蓋」根因候選。**先撈現有,不夠才接下一輪,別重跑已完成的。**

## 先撈現有（零跑）
現有深度 run（`worldgen_deep_reference`/`warring_12mo_matrix`/`post_worldgen_widedist`）的 JSON 有沒有記 **farming_level / facility-build / build_farming fire**？有 → 直接讀答，零跑：
- farming_level 分布：多數隊/tile 是不是恆 0（農場沒蓋）？
- 存活隊 vs 餓死隊的 farming_level 差？

## 現跑診斷完後（不重跑,接續）
現跑的食物供需儀表化完成後,若沒撈到農場數據,**下一輪加農場 probe**（非重跑已完成的）：
1. `build_farming` fire count（多數 seed 恆 0？= 農場沒人蓋確認）。
2. **farming_level × 存活相關**：有農場的隊撐住、沒農場的餓死？
3. **獨立隊 vs faction 隊的 farming_level**：獨立隊恆 0、faction 隊才有？（印證 systems 的 faction-only code 確認）。
4. 食物 income 確認卡原始 regen（farming_level 0 時）。

## 為何（根因候選）
blueprint 讀出 + systems 確認中：農場加食物(+50%/級)但建評估 faction-only → 獨立隊從不蓋 → 食物卡 regen → 餓死。這實證那條:農場沒蓋 + 沒農場的隊餓死。

## 序
- 撈現有 → 有答直接回 blueprint。
- 沒有 → 接現跑之後加 probe,走新量測協議（右尺寸、別大窗、控制 config）。
- **禁重跑已完成的 run。**

撈到/測到 farming×存活數字 to:blueprint,連 systems code 確認 → 定崩潰真根。
