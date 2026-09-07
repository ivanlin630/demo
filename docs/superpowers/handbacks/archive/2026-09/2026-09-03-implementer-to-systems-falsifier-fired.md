---
from: implementer
to: systems
status: consumed
slice: 施主五道濾網 ＋ #10 option 名（3 seed × 30 日）
touches: scripts/simulation/faction_ai_system.gd, scripts/simulation/decision/decision_engine.gd, scripts/simulation/decision/decision_context.gd, scripts/simulation/interaction_system.gd, scripts/simulation/distortion_engine.gd
topic: ★★★你自己寫死的判準【打死了你的假說】:③通過的相異 target ＝ ②的 84~90%（150/175、126/150、162/181）⇒ food_est 不稀有;★★而它與【次數】相反(③擋 10.5~13 萬次、佔 57~60%)——★兩個數字都對,差在【同一批沒有 food_est 的隊被每 tick 重掃】;★#10 的 option 名出來了:【紮根】9/10,而 stall cooldown ＝ 0 ⇒ 是【條件本身不成立】
---

# ★★★①可證偽那一格：**你的假說死了，照你自己先寫死的判準**

```
                    ②has_belief 通過   ③food_est 通過    ③/②
seed 1337               175                150            ★86%
seed 42                 150                126            ★84%
seed 7                  181                162            ★90%
```
★**你的判讀表寫的是**：`③ ≈ ② ⇒ ★★假說死 ⇒ 擋人的是④⑤，別再往資訊層修`。
★★**而量到的就是 ③ ≈ ②**（84–90%）⇒ ★★★**`food_est` 不稀有：有 belief 的隊，八九成都知道他的存糧。**

## ★★而它與【次數】完全相反 —— ★★★而兩個數字都對
```
              ①母體空  ②沒belief   ★③沒food_est    ④不夠分    ⑤到不了
seed 1337       423        2        ★105,162        29,339     49,010
seed 42         438        0        ★105,839        27,368     40,166
seed 7          430       33        ★129,525        32,723     41,675
⇒ ③【次數】佔拒絕總數 57~60% —— ★看起來像「資訊門檻是主因」
```
★**而集合大小說相反的話** ⇒ ★★**唯一同時成立的解釋：一小撮【沒有 food_est 的隊】被【每 tick 重掃】。**
★★★**這正是你要求「集合大小不是次數」的理由，而它在這一格真的分出了勝負** ——
**若只看次數，我會回報「假說成立」，而那會把修法推去資訊層。**

# ★★②而「找不到施主」的整體圖，與最深帶【不一致】
```
整體：找到施主 3559/10750（33.1%）／3437/10176（33.8%）／4354/11582（37.6%）
      ⇒ ★三分之一的呼叫【真的找得到】⇒ 世界整體【不是】沒有施主
最深帶（前一輪量的）：統一路施主可及 7.2%；階梯路 seed1337/42 ＝ ★0.0%
```
★★★**兩者要一起讀**：**世界有施主，而【餓到最深的那些隊】沒有。**
★**而我【沒有】量 band × filter 的交叉** ⇒ ★★**「深帶的施主是被④還是⑤擋掉」我答不出來。**
⇒ **那是下一格最便宜的一刀**（同一個 tap 加一維 band key 即可），**而我不在拿到它之前推論。**

# ★★★③#10：不在候選集的 option 是【紮根】
```
seed 1337  紮根=2        ｜ stall cooldown 排除 = 0｜條件本身不成立 = 2
seed 42    紮根=4｜覓食=1 ｜ stall cooldown 排除 = 0｜條件本身不成立 = 5
seed 7     紮根=3        ｜ stall cooldown 排除 = 0｜條件本身不成立 = 3
⇒ ★9/10 是【紮根】；★★stall cooldown 三 seed 全 0 ⇒ 【不是被 cooldown 排除】，是條件本身不成立
```
★**這就是你要的第一步** ⇒ ★★**下一步才是在【紮根 那一個】的 `applicable` 裡接條件級 tap。**
★★★**我沒有做那一步，也沒有猜它為什麼不成立**（blueprint 明令禁猜）。
（母體：6／7／12，合計 25；★而 `not_in_ranked` 合計 10 —— 母體仍小，這一格的形狀比比例可信。）

# ★④順帶：我把 `food_est` 的負斷言驗完了（★窮盡，非一次 grep）
```
全站 76 處；★production 側【產生】點只有一個：
   scripts/simulation/interaction_system.gd:1067   snap["food_est"] = float(tgt.resources.get("food", 0.0))
★★而 scripts/simulation/distortion_engine.gd:85/98 是 `*=` —— ★★★【改既有值】不是產生
   （沒互動過就沒有那個鍵可乘）
★同名不同物一格：`village_estimate.gd` 有自己的 `food_est` 欄位，與 belief snap 的鍵無關
   ⇒ ★★用 grep 數「寫入點」而不看型別的話，會把它算進去，然後負斷言變成假的
⇒ ★★★所以你的【機制描述】是對的（只在互動時產生），★而它推出的【預測】被數字打掉了
   —— 兩件事可以同時成立：來源稀有 ≠ 結果稀有（互動夠多，八九成都互動過了）
```

# ⑤落地
```
量測  docs/measurements/2026-09-03-aid-filters-warring-seed{1337,42,7}-30d.txt
床    scripts/debug/three_tickets_bed.gd
commit a087239f（五道濾網＋#10 option 名）→ f47208ba（可證偽那一格）
★誠實限：①單 config（warring）②#10 母體 25，比例不可信、形狀（紮根）可信
   ③★★band × filter 交叉【沒量】—— 而深帶的成因就卡在那一格
```
