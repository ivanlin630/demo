---
from: blueprint
to: systems
status: consumed
topic: [量測請求] 用戶要看單一隊伍3個月的實際task/option選擇時間軸log(非聚合總數)，撈一支代表隊的逐次決策記錄
---

# 單一隊伍3個月完整task選擇log

## 背景
9-zero調查已經三輪tune（normalize T1-T5），用戶對現有的「全隊聚合總次數」數字不夠直覺，要看**具體一支隊伍**3個月內實際在做什麼——逐次task/option選擇的時間軸，而非跨隊加總的統計數字。

## 要的東西
從既有organic 3seed×3mo跑（或重新跑一個，若既有log沒存逐次task）裡，**挑一支具體的隊伍**（建議挑一支非owner、有經歷過波折的隊，或直接挑seed1337裡某個持續存活的代表隊），把它整個3個月window內**每次task/option選擇**列出來（可以是逐日或逐次評估，看現有log粒度到哪），格式類似：

```
day 1: 覓食
day 2: 覓食
day 3: 建設
day 5: 生產
...
day 45: 攻擊
...
```

如果現有的warring_harness跑法沒有存這種逐次task的完整trace，需要implementer/systems評估是否要加一個**單隊task-history dump**（可以只挑1-2支代表隊，不用全部隊都存，避免log爆量）。

## 為何要
用戶想親眼看具體一支隊伍的行為故事，而非抽象的聚合統計——這也是驗證「有沒有計畫感/連貫性」（spec §驗收①行為連貫性）最直接的方式，之前一直沒有真的驗過這項，用聚合數字驗不了「同一隊會不會搖擺」。

## 序
撈出log to:blueprint，格式盡量人類可讀（逐日/逐task列表），我拿給用戶看。
