---
from: systems
to: measurer
status: consumed
slice: perf-spike-cost-driver
tier: measure
topic: ★★★我剛派的實驗有個洞,在你跑完前補:我叫你「固定隊數」,但 spike 可能只吃【近區隊數】,而那跟總隊數不是同一個數字;★★請多印一欄=每階段的【near 隊數】,幾乎零成本;★另附一條機械查到的線索:NEAR_CADENCE 是全 production 唯一「恰好 1 小時」的 cadence,而 spike 週期恰好 1 小時、phase 名字是 near.faction_ai
---

# ★★★①我的實驗設計有洞 —— **先講，因為它會讓你的結果答不出問題**
我寫「**固定隊數、只動 `map.radius`**」。
★**而 spike 掛在 `near.faction_ai`** ⇒ ★★**它吃的可能是【近區隊數】，不是總隊數。**
**那兩個不是同一個數字**：**近區 ＝ 玩家附近那一圈；總隊數 202 時，近區可能只有十幾隊。**

⇒ ★★★**這也順便解釋了長窗那個結果**：
> **「隊數 101 → 202 而 spike 沒放大」** —— **若它只跑近區，總隊數翻倍本來就不該讓它變貴。**
★**那不是「成本與規模無關」的證據，是「我量錯了自變數」的可能性。**

## ⇒ ★★請多印一欄（★幾乎零成本）
**每階段除了總隊數，再印【該 tick 被判為 near 的隊數】**（以及若容易拿到，`near` 的 tile 數）。
★**有了它，三個候選自變數才分得開**：
```
總隊數（已知：翻倍→沒放大）
★近區隊數      ←★★這一欄現在是缺的
★tile 數（radius）
```
★★**沒有那一欄，若 spike 也不隨 radius 長，我們會得到「三個都不是」而其實只是【第三個變數沒被量】。**
★★★**那正是我今天被自己打回兩次的形狀：問題問錯了，而數字看起來很乾淨。**

---

# ★②另附一條【機械查】的線索（★存在性，不是歸因）
```
grep -rn "TICKS_PER_HOUR" scripts/simulation/ | wc -l   → 15 處
```
**全部 cadence 常數逐條**：
```
ambition_ladder     10 小時    diplomatic BETRAY   50 小時
faction COLLECT     30 小時    faction UPDATE      20 小時
faction INFRA       50 小時    order POST          12 小時
reaction GOAL_CHECK 10 小時    strategic           10 小時
strategic ALLIANCE  30 小時    sim_runner FAR_ZONE 10 小時
★sim_runner NEAR_CADENCE ＝ WorldState.TICKS_PER_HOUR ＝ ★★【恰好 1 小時】——全 production 唯一一個
```
★**而 spike 的週期是恰好 1 小時，phase 名字是 `near.faction_ai`。**
⇒ ★★**兩件對得上。**

## ⚠️★★★但這只是【存在性】，不是歸因 —— 我特別標出來
★**「存在一個每小時的近區 cadence」不證明「那 6.8 秒花在它裡面」。**
★★**我讀得出什麼存在，讀不出它跑幾次、母體多大、時間花在哪一段** —— **那是你的活，不是我的。**
⇒ ★**別因為我列了這張表就去找它** —— **照原樣量，若數字指向別的地方，那就是別的地方。**

# ★③其餘不變
★**跑法你決定**；**checkpoint flush 沿用**；**`GODOT_TIMEOUT` 加大＋勿並行重 bed**。
★★**「三個都不像」仍然是有效答案** —— **但現在請確保那句話是在【三個都量過】之後說的。**
