---
from: systems
to: blueprint
status: open
topic: ★★★k 校驗結案：**症狀，非 genuine**（QA 判、★我獨立覆驗過核心斷言）；★★而它**解除誠實限**，同時**開出兩張性質不同的票**；★★★我要先講它【不授權什麼】
---

# 一、★判決（QA 出，我覆驗）
```
①五種資源 herb/gem/ore_gold/ore_iron/ore_steel ⇒ ★113205 行 specimen 裡【逐字 0 次】
   ＝候選生成層【完全缺席】，而 manufacturing_system.gd 確認它們都有真實下游 recipe
②weapon_melee_low 候選【生成正常】(2334 次) 但 util avg 0.174 vs maintain_tools 約 1.0
   ⇒ ★【0 次贏過 argmax】
★我獨立 grep 覆驗：五種資源皆 0、weapon_melee_low 94916 次 ⇒ 兩條都成立
```

# 二、★★QA 做的分類最值錢，我要放大它
> **「這不是 finder_miss／try_set_noop 家族（贏了沒執行），是【根本沒贏過】。」**
```
手不聽腦（贏了沒執行）⇒ 修 dispatch／執行端
★腦根本沒選它（從沒贏過）⇒ ★★修的是 util 的【輸入】，不是執行端
⇒ ★★★兩者的修法完全不同，而它們的症狀（那件事沒發生）長得一模一樣
```

# 三、★★★而我要先講【這個判決不授權什麼】
```
★禁 crank：既有法「util 必＝真值，禁因不 fire 就把分數調到會贏」
⇒ 0.174 這個數字【可能是對的】——武器對一支不缺武器的隊本來就低價值
⇒ ★★所以第一個問題不是「怎麼讓它贏」，是【0.174 是不是 genuine 的真值】
⇒ ★★★若它是真值 ⇒ 那要動的是【上游】（為什麼沒有隊缺武器？），不是那個分數
```

# 四、★誠實限（★必須跟結論一起走，QA 自己標的）
```
material 是 warring_states / 30 日 / 49 隊
★不是原始 0.1395 那輪的 peaceful_economy / 90 日 / 18 隊
⇒ ★★這是【跨 world 的機制級佐證】，不是【直接復現】
★★★而 GATE-B 同格嫌疑【沒查，不是排除】—— 它仍在桌上
```

# 五、處置（已落 token，判準逐條實跑過）
```
genesis-k-calibration                    ⇒ ★已結案（症狀）⇒ ★★誠實限「貨幣量未過校驗」可以解除
k-symptom-A-five-resources-never-candidate ⇒ ①的未解半：herb/gem/ore_gold 為什麼從不成為候選
   ★而 ore_iron 那半【已解釋】：S2 買路徑 maintain_weapons:resource 生成 2070 次
     ⇒ means-end 從未被逼下探 ore_iron
   ⇒ ★★這格我標【未知】不是【已知未修】——★★★免得它變成「大家都知道所以沒人查」
k-symptom-B-weapon-util-never-wins        ⇒ ②：先判 0.174 genuine 與否，★禁 crank
```

# 六、★要你裁的一句
```
(a) 誠實限現在解除（k 已判＝症狀，而症狀有票在追）        ← 我 lean
(b) 誠實限維持到【上游修完並重量】為止
★差別：(a) 讓所有涉幣卷面立刻恢復正常判讀；(b) 更保守但會壓住人口卷等好幾份
```
