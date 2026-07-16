---
from: systems
to: blueprint
status: consumed
topic: [常數來源·零跑] PASSIVE_BASE_CHANCE=0.08 + FORAGE_FLOOR_DAYS=1.5 皆feature引入commit的TEST VALUE,從未balance調校—抬它們非違背刻意平衡,green light
---

# forage 常數來源：都是 placeholder TEST VALUE，從未調校

git 歷史查完。**兩常數都是 feature 引入當下設的 TEST VALUE，之後零 balance 調校。**

## PASSIVE_BASE_CHANCE = 0.08（hunt_system:6）
- comment：`TEST VALUE — 覓食被動小獵命中（低）`。
- git：唯一出現 = `2614396 feat: HuntSystem.hunt_small_game`（HuntSystem **原始 feature commit**）。**之後無任何調校 commit**（`git log -S` 只此一筆）。
- ∴ = feature 引入隨手放的低值,非平衡過。ACTIVE=0.4 vs PASSIVE=0.08 的 5× 差也是引入時拍的。

## FORAGE_FLOOR_DAYS = 1.5（resource_system:7）
- comment：`TEST VALUE — 覓食淨貢獻上限=幾日餬口`。
- git：`06221fe feat(resource): 覓食=苟活地板`（**苟活地板 feature 引入 commit**）。**之後無調校**。
- ∴ = 苟活地板機制引入時設的 placeholder。

## 判讀（給你/用戶）
- **設計語意（覓食=苟活地板 latch）是刻意的**（有明確 comment/feature）——那個機制不動。
- **但兩個數字（1.5 天 / 0.08 命中）是 placeholder，從未 balance**——呼應 [[feedback_tick_balance]]（所有時間/平衡常數目前測試值,正式需大幅調整）。
- ∴ **抬它們非違背任何刻意平衡決策 = green light**。45% 死是這兩個 un-tuned placeholder（+ latch 太薄 + entry 太晚）疊出來的,非「世界本該如此」的平衡結果。

## 對修的意涵
- tune FORAGE_FLOOR_DAYS(1.5→高) + PASSIVE_BASE_CHANCE(0.08→高) **不是 override 平衡,是首次給它們真值**。
- 仍建議 measurer 先確認死隊有無在 forage（定脆點:floor 太薄 vs entry 沒觸發）→ 再決定抬哪個 + 抬多少（量測校，非拍）。
- **這是 tune 現有常數（小改），非新 slice**——反冗餘 + 常數本就待調,雙重確認別大動。
