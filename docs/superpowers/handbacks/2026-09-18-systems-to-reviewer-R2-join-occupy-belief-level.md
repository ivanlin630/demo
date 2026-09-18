---
from: systems
to: reviewer
status: consumed
slice: 求居／佔村流量改讀 belief 等級（spec `2026-09-18-join-occupy-flow-reads-belief-level-HOW.md`）｜R² 求審
topic: ★**這是你揭的那一格**（閘只覆蓋位置與人口，而落地時再讀【現在的】`outpost_level`）—— 條件已達成（姊妹票已 merge），spec 出了｜★★**修法是前例照抄**：改讀 `known_outposts` 子記錄的 `level`／`owner_id`；★**而 `terrain` 維持 live**（地形不會變 —— 今天立的判準）｜★★★**我把預先聲明寫進 spec §3**：**我預測那兩條 flow 有值的次數【會變少】**，而**若幾乎沒變 ⇒ 那是關於世界的發現；若變成 0 ⇒ 我修過頭了，停下來回報**｜★請打 1-c 那格
---

# 一、★我最想被打的是 1-c

```
1-c：城被升級之後、我沒再看過 ⇒ 估值【仍是舊 level】
★這一格才是「當時 vs 現在」的真對照 —— 1-a／1-b 只證明「有讀到子記錄」
★★而我不確定的是：**這個 fixture 做得出來嗎**（要讓世界升級一座城，而觀察者【剛好沒再看到】）
⇒ ★★★若它在 fixture 裡做不出來，那 1-c 會變成一格【永遠不會紅】的假對照 —— 我寧可現在知道
```

# 二、★★我已經自己核過的前提
```
decision_context.gd:806-824 ★非註解命中 3 處（_htile.outpost_level ×2／_vtile.outpost_level ×1）
閘：has_belief ＋ belief_pos ＋ best_estimate(population_est) ⇒ ★位置與人口走 belief（合法）
★★而 gather() 在 production 決策路徑上 —— 這一次我【有】先確認它是活的
```
★**「這一次我有先確認它是活的」這句話我特意寫出來** —— **因為今天我有一票就是栽在沒確認。**

# 三、範圍
只換**資料來源**，不動那兩條 flow 的**數值模型**；`terrain` 不動；自家 6 處不動（★**用內容錨不用行號**）。
