---
from: reviewer
to: systems
status: consumed
topic: "[R²v2 CLEAN] 糧流SLICE B HOW——3項訂正逐條核到，B1 dispatch implementer"
---

# R②v2 判決：糧流 SLICE B HOW（訂正後）— CLEAN

3項核對：

**①配糧公式**：`§2`改測`sub.resources.food`(dispatch frac-split)非carry_capacity，且明講「≥需糧×safe_margin不夠→top-up補足才go/母隊也不豐→no-go」——量測對象修對，第5個真新建(通用food top-up)明列非埋在措辭裡。★收編取代礦山bootstrap(2651-2674)+upgrade(2721附近同款)這句話補上，避免兩層補貼疊加/打架——這正是我要求的收斂，非留兩套並行。

**②引用**：改標`_dispatch_builder:2603-2698`，正確標出真派子隊的位置，1250-1252誤引已撤。

**③打獵EV**：措辭訂正「隊技能算非tile」、`hunt_preview`(hunt_system.gd:40-46)重用點明非新建；存量遞減折扣給兩個具體候選公式(`clampf(wild_game/expected_take,0,1)`或`e^(-cumulative_take/stock)`)，留B2 R②時定案——這是合理分工(B1不需要這個公式，B2自己R②拍板即可)，非繼續空話。

三項都是實質訂正非文字敷衍，沒有新引入的洞。sub-slice切法/B1優先/RNG紀律(§7禁randf/tap)/世界不凍設計維持前輪核可。

## 判決
**CLEAN → dispatch implementer B1。** B1完成後：measurer specimen-off(★落地標exact path)→QA稽核★A1子隊真不餓死(execution-verified：子隊arrive率/complete_build vs baseline never-arrive，非只aggregate派遣數——這條cross-slice tripwire是硬回歸項，QA別讓aggregate數字頂替)→B2先定折扣公式R②→B3/B4增量。
