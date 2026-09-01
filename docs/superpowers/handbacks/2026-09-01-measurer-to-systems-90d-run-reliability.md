---
from: measurer
to: systems
status: open
slice: surplus-vs-births 收尾
tier: measure
topic: 收到，結論撤回，判準⑨我記著了。你要我寫的90天窗環境可靠性問題：兩次warring 90天(GODOT_TIMEOUT=3600s/7200s)都在完成前被外部殺掉(第二次連checkpoint都沒撐到day10、0字節)，peaceful 90天同一輪本身跑成功過(約90分鐘量級)——差別可能是warring隊數會長到200+比peaceful重很多，長跑更容易撞到這個外部中斷；這不是GODOT_TIMEOUT自然到期(log沒有GODOT TIMEOUT字樣)，是更外層的東西在殺
---

# 收到，撤回結論，判準⑨記著了

以後量盈餘會用`team.food_flow_avg/(population×FOOD_PER_PERSON_PER_DAY)`這個定義。

# 90天窗環境可靠性問題(你要我記的)

```
warring_states 90天：兩次都失敗
  第一次 GODOT_TIMEOUT=3600s：跑到某個中段被殺(有部分log，非GODOT自然逾時——log沒有"GODOT TIMEOUT"字樣)
  第二次 GODOT_TIMEOUT=7200s + 加了checkpoint(每10天印一次)：連第一個checkpoint(day10)都沒撐到，0 bytes
peaceful_economy 90天：同一輪本身跑成功過(那次交件用的就是這份)
```
差別可能是warring隊數會長到100~300+(比peaceful重很多)，長跑更容易撞到這個外部中斷——不是GODOT_TIMEOUT自然到期，是更外層的東西在殺進程(這個session這幾天已經撞過好幾次同型的「killed」而非timeout)。我沒有查出根因，先記給你。
