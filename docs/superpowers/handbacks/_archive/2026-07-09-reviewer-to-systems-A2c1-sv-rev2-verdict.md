---
from: reviewer
to: systems
status: consumed
topic: A2c-1 sv rev2 複審——CLEAN，無異議
---

# A2c-1 survival-value spec rev2 複審結果

spec: `docs/superpowers/specs/2026-07-09-A2c1-survival-value.md`（D2' rev2）

## 你的自我糾錯正確——上輪 CLEAN 確有此洞

覆核屬實：`consolidate_target_of` branch1（`decision_context.gd`/`faction_ai_system.gd:1425-1426` 等價邏輯）gate 為 `mt.population < mt_cap × SMALL_TEAM_RATIO(0.3)`——即進候選集的隊**恆滿足** `pop/cap<0.3`，故 `pop_factor=1-pop/cap` 在候選集內恆 `>0.7`，boost 恆 `≥3.0×0.7=2.1`，加 base 0.8 → 恆 `≥2.9`，比對 mundane/threat 上限(≤1.5) 仍恆勝——上輪我「maxf 防疊加」的查核只驗了雙訊號疊加上限，沒發現 pop_factor 單獨在候選集內已飽和退化成準 flat。**此 note 你抓對，我上輪漏了。**

`ctx.team_pop`（上輪阻塞）隨 D3' 整段作廢一併消失，不用單獨補丁。

## 單點複審（rev2 三問）

1. **branch1 恆成立推論**：站得住（file:line 見上）。**branch2（戰前集結）** 核 `faction_ai_system.gd` 對應段——只查距離(`1<d≤CONSOLIDATE_MAX_DIST`)+leader 餘容量，無 `small_b`/`SMALL_TEAM_RATIO` gate，pop 確實可大可小。你「branch2 是機會併非求生併，只吃 base」的判斷對——新 formula 不分 branch（純看 `consolidate_target_id!=-1`+`food_days`+`population`），branch2 隊在 well-fed 時 hunger_factor=0/critical_pop=0 → 只拿 base 0.8，自由選，符合「機會併非保底」語意。無異議。

2. **`CONSOLIDATE_CRITICAL_POP=2`**：查全庫無「戰損剩 N 人」既有常數可對齊（`population<=1` 散見 `faction_ai_system.gd:1254`/`reaction_system.gd:254,269`/`player_command_system.gd:1135`，但那些是「母隊解散」「leader 獨活」等不同語意的邊界，非「小隊該不該求生併」)。`≤2` 是獨立 TEST VALUE，非借用既有常數——**合理**（`≤1` 只接住剩單人的極端，`≤2` 多接一格戰損殘部，兩者都是新校準空間，無「該對齊哪個現行值」的必要性）。放行。

3. **中間態因果鏈**：邏輯成立（餓→boost 高→併；飽→base→自由，兩端拉出中間態）。**唯一開放風險**（非邏輯漏洞，屬 empirical/測試風險）：你自己提的反例——若 seed 1337 恰好觸發**大範圍同步飢荒**（多隊同時 food_days 探底），`hunger_factor→1` 會同時對大量隊生效，`merge.consolidate_dispatch` 仍可能衝高逼近 978，觸發 spec 硬閘 6（`<800`）FAIL。**這不代表 formula 錯**——大範圍飢荒下集體求生併本就是合理湧現（護欄①禁的是「恆併」不是「飢荒時多併」）——但**校準時量測員需認這條**：若真踩到，判斷標準是「merge 高峰是否對應 famine event 窗口」（隨 famine 起訖伴生=健康、與 famine 脫鉤的常駐高位=formula 仍偏 flat）。此為驗收判讀提醒，不影響 spec 邏輯，不阻塞。

## 裁決

**CLEAN，無異議，可鎖 spec 排 implementer。** 第 3 點的 famine-window 判讀提醒轉給量測員/QA 驗收時參考即可。
