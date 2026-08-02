---
from: blueprint
to: systems
status: consumed
topic: "[QA 抓真 bug·TASK_FLEE 缺 stall-detection=我『傻站餓死』判準的 bug 格·非 economy 內在] team58 卡逃跑活活餓死(flee_from 全程-1,-1、ladder 不覆蓋 TASK_FLEE)。修=TASK_FLEE 納 stall-detection/release(無效/過期 flee_from or famine 爬→放回求生選項)。★污染 doom-delta:先修再讀乾淨 economy doom。+量化 54% 逃跑真vs broken。"
---

# QA 抓真 bug：TASK_FLEE 缺 stall-detection（= 我「傻站餓死」判準的 bug 格）

## WHAT 裁定：這是真 bug，優先修
QA 獨立讀 raw trace（`2026-07-19-mainworld-seed1337-flee-lockpoint-a5495461-decoded.log`）坐實：
- **team58 ❌**：`task=逃跑` 鎖住、`flee_from` 全程 `(-1,-1)`（無威脅）、famine 爬到 33.3 **活活餓死**、ladder stall-detection **從沒接住**。= **正中我判準（game-design:359-363）的「傻站餓死＝絕境出路沒 fire＝bug」那格。** 確認 unacceptable。
- **team75 ❌**：`task=逃跑` 鎖 29 天、tile 不動、`flee_from (-1,-1)`、food_days 181→213 極安全＝**對空氣逃跑**（凍結浪費，不死但空轉）。
- ✅ team10/13/48/79 proper 窮死、team53/66 真威脅戰術撤退＝coherent（不動）。

## ★這是新 bug 類，非 economy 內在（區分清楚）
- **根因**：絕境階梯（②ladder-feedback）stall-detection **只認 `SURVIVAL_OPTION_SET`，`TASK_FLEE` 不在集合**→ 一旦標記逃跑（真威脅 or 過期/從未 validated），**無機制換回求生選項**。
- **≠ doom 搬家家族**（你/我判過三次的 intrinsic economy doom 是「用盡選項才 proper 窮死」）。**這是結構覆蓋 gap**（安全網有洞），非 RNG 分岔運氣。
- **= 第 3 種 doom 來源**：除了 ①economy 內在 ②propagation 弱(人為盲)，現在 ③flee-lock bug。**污染 doom-delta 判準**（部分「doom」是這 bug 非 economy）。

## 修（WHAT，HOW 你定）
1. **TASK_FLEE 納 stall-detection/release 安全網**（同 SURVIVAL_OPTION_SET）：卡逃跑 + `flee_from` 無效/過期 **或** famine 爬 → **釋放換回真求生選項**（覓食/遷移/…）。
2. **★連 belief-staleness（接 belief-store 模型）**：`flee_from (-1,-1)` = 威脅的位置 belief 過期（belief_pos 3 天 staleness）。**決策的輸入 belief 過期 → 該決策必須 re-evaluate**，而非 FLEE 無限持續。「無當前有效威脅 belief 的 FLEE 必須釋放」= 原則；stall-detection 覆蓋 TASK_FLEE = 機制。
3. **量化 54% 逃跑**：measurer 用 `flee_from 曾否 valid + 是否持續移動` 兩訊號分類真威脅逃跑 vs stale flee-lock → 告訴我們「人口重摔 135→40」多少是這 bug、多少是真 economy。

## 序（優先）
- **這 bug 污染 doom-delta economy 讀** → **建議先修（或至少先量化分類）再做 D-後的乾淨 economy doom 讀**（否則 flee-bug 混進 doom，economy 診斷髒）。
- **屬 survival-ladder 覆蓋完整性 = 框架清潔**（安全網覆蓋全 task state 非只 SURVIVAL_OPTION_SET）→ 合「框架先」。slot soon（你定 exact HOW/序，走 R②）。
- **注意**：② ladder 我 release-pass 過，這**非 ② 回歸**（②scope=SURVIVAL_OPTION_SET stall,對;TASK_FLEE 是相鄰未覆蓋 gap）——但揭示 **② 覆蓋不完整**，此為補完。

## ★給用戶偏好記一功
「長跑→QA」偏好（用戶今定）**立刻兌現**:聚合數字（逃跑 54%）藏著 broken,QA 讀 raw trace 才挖出 team58/75。這型 bug 短 seeded 回歸床可能漏,長跑故事審抓到。**驗證這偏好的價值。**

## 溯源
QA current-world-story-verdict（獨立 trace 驗 team58/75 BROKEN + 根因 TASK_FLEE stall gap）;我判準 game-design:359-363（傻站餓死=bug）;belief-store 模型（過期 belief→re-evaluate）;doom-delta 判準（此為第 3 種 doom 來源污染）;用戶「長跑→QA」偏好兌現。
