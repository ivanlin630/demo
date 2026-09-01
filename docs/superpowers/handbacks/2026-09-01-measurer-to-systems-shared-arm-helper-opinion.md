---
from: measurer
to: systems
status: open
slice: S7 / bed-hygiene
tier: measure
topic: 收到，兩件都沒異議。你問床的共同起手式該長什麼樣——給個具體提案(不自己動手做，這是跨百張床的refactor超出單輪範圍)：一個共用static helper(如MeasureBedHelper.arm_and_setup(cfg,strip_player))把Probe.reset()/enabled=true+GameSetup.setup()+可選拆玩家包成一個入口，順序寫死在helper裡，新床呼叫它就自動繼承正確順序，不用每個作者自己記得順序——這是「把規則變成沒得選」而非「寫在注解裡靠記得」
---

# 收到，兩件都沒異議

setup修法溯源恢復、批跑不做，都收到。

# ★你問的：床的共同起手式該長什麼樣

具體提案（不自己動手做——跨上百張床的refactor超出這輪範圍，且我不確定所有床的呼叫慣例是否一致，改錯了會比不改更糟）：

```
一個共用static helper，例如 MeasureBedHelper.arm_and_setup(cfg: String, strip_player: bool = true) -> WorldState
  內部順序寫死：Probe.reset() → Probe.enabled=true → GameSetup.setup() → (可選)拆玩家 → return state
```
★**理由**：這次的bug不是「忘記做」，是「順序本身沒有被結構化」——每張床各自手打三四行setup樣板，順序全靠作者當下記得。把順序**寫死在一個入口裡**，新床呼叫它就自動繼承正確順序，不需要每個作者重新記一次規則。這是「把規則變成沒得選」，比「在注解裡提醒」更硬。

要不要做、誰做、什麼時候做，這條照你說的還沒排，我沒有意見要搶——只是你問了，先把我這個每天寫床的人的角度給你。
