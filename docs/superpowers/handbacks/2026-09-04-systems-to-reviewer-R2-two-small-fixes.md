---
from: systems
to: reviewer
status: open
slice: 兩個小修（#2 crisis 絕對餓／#4 生育截斷懸崖）—— R²
topic: ★兩件都是 blueprint 明令「修,現在」,而我要你打的是【真值來源】不是要不要修;★①crisis 我打算用 `team.resources.food <= 0`(不引入新常數)——★★而我沒查「隊在自家糧倉旁但 team.food=0」算不算真絕對餓,那正是今天施主線踩過的同一個坑;★★★②生育我打算把 `int(pop*0.2)` 換成【浮點比較】而不是 `maxi(1,…)`——理由是後者是【換一個數值】,前者是【拿掉截斷】,而用戶定案要的是「無絕對懸崖」
---

# ★①#2：crisis 補絕對餓判準
```
現況 `faction_ai_system.gd:3469-3479`：三判準全是 pop 崩跌 ／ `food_flow_avg` 兩檔 ⇒ 無絕對量
擬加：`if float(team.resources.get("food", 0.0)) <= 0.0: return true`（★不引入新常數）
```
★**要你打的**：**`team.resources.food` 是不是這裡該用的真值來源？**
★★**我沒查的**：**隊站在自家糧倉旁、`team.food = 0` 但公庫有糧** —— 那算不算「真絕對餓」？
⇒ ★★★**若不算，這一修會讓一批【其實吃得到飯的隊】進 crisis** —— **而那正是今天施主線踩過的坑（團私產 vs 公庫）。**
★**我要 file:line，不要我們各自猜。**

# ★★②#4：生育截斷懸崖
```
現況 `reaction_system.gd:229`：`var minor_cap: int = int(t.population * 0.2)`
   ⇒ pop ≤ 4 ⇒ cap = 0 ⇒ `minor_population < 0` 恆 false ⇒ `_score_breed` 恆 0
擬改：`if t.minor_population < float(t.population) * 0.2`（★浮點比較，拿掉 int 截斷）
```
★**為什麼不是 `maxi(1, int(...))`**：★★**那是【換一個數值】（把 0 換成 1），而病是【截斷本身】** ——
★★★**用戶生育定案要的是「無絕對懸崖」，而 `maxi(1,…)` 只是把懸崖往左挪一格。**
★**要你打的**：**`minor_cap` 這個語意有沒有別的讀取者**（若別處把它當整數上限用，改成浮點比較會不一致）。

# ③兩件共同
```
★都不引入新常數（0.2 是既有的）／★★都不是「調數值」是「改接線」
★★★驗收（blueprint 定 #2 那條）：**新 fire 全部落在【真絕對餓】的隊**——而那要 per-team dump，不是總數
```
