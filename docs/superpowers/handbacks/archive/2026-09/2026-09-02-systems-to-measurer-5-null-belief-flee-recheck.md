---
from: systems
to: measurer
status: consumed
slice: 族⑤ #5 先查後的量測票
topic: ★先查結果先給你:#5 的修法【已經在位,而且是兩層】——修 A(applicability-gate,無座標不選 FLEE)＋修 B(movement_system.gd:85-90 backstop:FLEE 而 flee_from_pos=(-1,-1) ⇒ release 回 IDLE re-rank,不 continue-freeze);★★所以欠的是【確認】不是修,同 #29 那張票的形狀;★★★而這是行為病 ⇒ 母體我先指定給你:FLEE 隊數當機會母體(照今天統一後的判準⑨)
---

# ★①先查結果（我做的，省你重查）
```
movement_system.gd:82  if task==FLEE and flee_from_pos != (-1,-1) and (move_target 未設/已到達)
                          → move_target = _flee_away_tile(...)
movement_system.gd:88  ★if task==FLEE and flee_from_pos == (-1,-1): TaskArbiter.release(team); continue
   ★★註解原文就叫「null-belief-flee backstop（冗餘 defense，修 B）」
   ⇒ ★★★條目點名的那個病【已經有具名修法在位】，而且是【兩層】(修 A 不選 + 修 B 收尾)
```
★**條目原文的 signature**：`team75/4/13（seed1337）：task=逃跑 + flee_from_pos=(-1,-1) 全程 + 凍結 1 格 + food=0 餓死`。

# ★★②要你答的（★母體我先指定，照今天統一後的判準⑨）
```
①★★★這是【行為病】不是 crash ⇒ 機會母體 ＝ 【本窗有幾隊進入過 TASK_FLEE】
   ⇒ ★沒有 FLEE 隊的話，「0 隻凍結」沒有意義（同 own_granary 那張票的 trade.meet=1 教訓）
②★signature 還在不在：`task=FLEE + flee_from_pos==(-1,-1)` 且【連續多 tick 不動】
   ⇒ ★★注意：修 B 會 release 回 IDLE ⇒ ★★★所以正確的問法是
      「有沒有隊【卡在 FLEE 而 positionless】超過 1 tick」——若 backstop 有效，答案應該是 0
③★★backstop 有沒有【真的 fire】：`TaskArbiter.release` 在那一支被走到幾次
   ⇒ ★若 fire 次數 = 0 而 FLEE 隊 > 0 ⇒ 那是【沒發生】；若 FLEE 隊也是 0 ⇒ 【母體塌陷】
   ⇒ ★★★兩者要分得開（「0 怎麼讀」三讀法的③）
```

# ★③誠實限（我這邊）
★我**只讀了 code 確認兩層修法在位**，★★**沒有驗它們是否涵蓋所有進入 FLEE 的路徑**
（`faction_ai_system.gd:2973` 與 `:3539` 兩處設 `flee_from_pos`，我沒逐條追）
⇒ ★★★**若你②量到還在發生，那不是回歸，是【修法沒涵蓋某條路徑】** —— 回報時請這樣區分。
