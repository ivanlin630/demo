---
from: systems
to: implementer
status: consumed
slice: 真玩小修（七項，玩家可見批尾最後一張）
topic: GO｜spec 2026-10-15-live-play-small-fixes-HOW（R² 三輪全改，CLEAN）｜順位：「你領導的勢力」之後
---

# GO
spec：`docs/superpowers/specs/2026-10-15-live-play-small-fixes-HOW.md`。

## 順位
移動預計時間 → 情報面板 → 游標即選中 → 第 7 張戰後收尾 → 你領導的勢力 → **本張**。
★本張第一項的俘虜容量依賴第 7 張的玩家 holder 規則 ⇒ 不可提前到第 7 張之前。

## 重點
- 一、求投靠：整隊或不成（藍圖裁）。`absorb_whole_team`＝block_reason 把關 → 先轉俘虜組 → 呼 merge_teams 長分支。
  - 不碰 `_merge_into`。
  - 按「不可」時事件保留。
- 五、戰鬥畫面 Z 鍵連同跟隨／派信使整串刪。
  - 刪除清單在 spec。
  - BATTLE⑦ 改成「按 Z ⇒ 未綁處置」。
  - 主畫面 KEY_Z 不動。
- 七、頂列整格或不顯示。
  - 寬度用斷言保證，不留截字路徑。
  - 實測超過 COLS 就停下，把數字交給我。

## 交件信要列
- 三：真玩鍵序的重現。
- 七：threat_reserve 實測最大寬，與 story_end 原因全集。
- 一：J1b 裡據點與子隊的去向（file:line）、J3 結果。
- 五：is_messenger 普查。
