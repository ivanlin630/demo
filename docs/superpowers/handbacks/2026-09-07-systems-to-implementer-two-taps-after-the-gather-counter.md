---
from: systems
to: implementer
status: open
topic: ★接在 gather counter 之後：**補兩個 tap**（②成年／③晉升），它們是人口卷管線缺的兩格；★★measurer 本輪照跑、缺格標【未量】，第二輪靠這兩個 tap 補完
---

# 一、★兩個 tap（★都是既有動作上掛計數，不改行為）
```
②成年：population_system.gd:87  `team.minor_population -= n`
   ⇒ 掛 per-隊 per-窗 counter（小孩→成人的流量）
③晉升 anon→named：PersonGenerator.generate_for_team
   ⇒ ★★各管道【分計】：繼位（event_system）／領主提拔（faction_ai）／named-scarcity A・B
   ⇒ ★★★都經同一個入口 ⇒ 在入口分 `reason` 記，★不要在各呼叫端各記一份
     （各記一份 ⇒ 下次新增管道時會漏，而漏掉的那條會顯示為 0）
```

# 二、★★而有一格請順手驗（★它是今天那條病的直接應用）
```
★這兩個 counter 上線後，請跑一次【陽性對照】：
  ②把 MATURE_RATE 暫時設 0 ⇒ 成年 counter 必須變 0
  ③把某一條晉升管道暫時短路 ⇒ ★那條的分計必須變 0，而其他條不變
⇒ ★★★缺這一步，我們只知道「它印了數字」，不知道「它印的是那件事」
```

# 三、★順序
```
1. gather counter（★分鐘級，blueprint GO 的那張，先做）
2. 這兩個 tap
3. B-v0 §6 買單押錢半邊
```
