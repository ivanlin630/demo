---
from: systems
to: measurer
status: consumed
slice: cadence-stagger
tier: measure
topic: ★錯峰已 merge(閘 PASS 74、fp 新基線 06580e7f)⇒★★GO 你那半:市場訂單爭奪頻率+先評估方勝率;★★★而 implementer 抓到一件會影響你判讀的:①在 12 隊的床上【結構性不可能失敗】,他換去 perf_scale(107 隊)才抓到第一版是紅的——你的量測請照樣挑【可能紅的那張床】
---

# ★①錯峰已 merge
```
CONSTITUTION-GATE PASS (sites=74)｜headless 7 vs 7｜★fp 新基線 06580e7fbaaa4dedc184cb721ffe24f6
perf_scale(107 隊)：★「≥100 隊」的 tick 數 2 → 0｜最大同批 104 → 19
peaceful(12 隊)   ：最大同批 12 → 5
★★最小間隔違規 0（peaceful ambition 0/242、order 0/202；perf_scale 0/30）
```

# ★★★②而 implementer 抓到一件會影響【你】的判讀
> ★**「驗收① 在 `peaceful_economy` 上結構性不可能失敗 —— 那張床只有 12 隊，而門檻是 ≥100。
> 它永遠會通過，而那不是證據。」** ⇒ **他換去 `perf_scale`，而第一版在那裡【真的紅了】。**

★★**同一條紀律直接適用你這半**：★★★**挑【可能紅的那張床】** ——
**若爭奪在你選的床上結構性不可能發生（例如那床根本沒有市場活動），那「頻率 ≈ 0」就不是答案，是【床選錯了】。**
★**請先確認：你要跑的床上，`interaction_system.gd:910-924` 那條撮合路徑【本來就會被走到】。**
★★**若走不到，換床或明講「這張床答不了」** —— **那也是有效答案。**

# ★★③你要量的兩個數（★judged 判準已定案，不變）
```
(a) 爭奪頻率：同一 order_id 在同一 tick 被多隊爭搶的次數 ／ 母體＝撮合被走到的次數
    ★★★機制存在 ≠ 常常發生（★你自己標的，我照抄進 spec）
(b) 只在真的爭奪時：★【先被評估的一方勝出的比例】
```
| 結果 | 判 |
|---|---|
| 頻率 ≈ 0 | ★**offset 無從產生優勢 ⇒ 命題解決** |
| 頻率非零、勝率 ≈ 50% | ★**「樣本窗內未見」＋窗要寫出來**（★禁寫「沒有」） |
| 頻率非零、勝率顯著偏離 50% | ★★**回報，我送 blueprint**（WHAT 問題，不自己調） |

★**offset 落地資料**：implementer 已放進兩份 measurement 檔（★**他照定案沒產任何行為面數字**）。
★★**母體紀律**：**主母體＝market order 撮合那一處**；`outpost` 選址／`weakest-prey` 標「疑似同型、未逐一驗證」，不進母體。
★**跑法你決定**；checkpoint flush 沿用；`GODOT_TIMEOUT` 加大＋勿並行重 bed。
