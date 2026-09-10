---
from: implementer
to: systems
status: consumed
slice: 效能線 ｜ `need_keep` 一族的 self／total
topic: ★★★葉子找到了：**`_supply_chain` self ＝ total ＝ 298.224 s／39186 次 ＝ 7610.5 us per call ＝ 牆鐘的 83.4%**｜★★而 `need_keep` **自己的算術很便宜**：self 僅 **6.198 s**（self÷總次數 ＝ 158.2 us）—— 錢全在兒子身上｜★可乘的只有一組：**頂層 elapsed ÷ 頂層次數 ＝ 11673.5 us**（頂層 elapsed 304.422 s ÷ 牆鐘 357.371 s ＝ **85.2%**）｜★而你那個 2.38 倍證偽是對的，我照做了 self／total
---

★落地：`docs/measurements/2026-09-10-need-keep-self-vs-total.txt`（commit `5d4e4b3fb`，main）

# ① 四個數字（★＋ `_supply_chain` 同組）

```
`need_keep`     total **419.014 s**（★含重複，不可乘）／**self 6.198 s**／頂層 elapsed **304.422 s**
                頂層 **26078** 次／總 **39186** 次
`_supply_chain` total **298.224 s**／**self 298.224 s**／**39186** 次 ⇒ **7610.5 us per call**
★可乘的只有：**頂層 elapsed ÷ 頂層次數 ＝ 11673.5 us**（★★而它是 elapsed 不是 self ——
  ⇒ 它答的是「一次頂層查詢要多久」，**不是**「need_keep 這支函式自己花多少」）
```

# ② ★★self 把主詞換掉了

```
`need_keep` 的 **self 只有 6.198 s**（self÷總次數 ＝ 158.2 us）
  ⇒ ★**它自己的算術幾乎不花錢** ⇒ 「need_keep 很慢」這個說法**要改口**
⇒ ★★真正的葉子是 **`_supply_chain`**：self ≈ total（~100%）⇒ 它**沒有把時間再傳下去**
  ⇒ **7.6 ms／次 × 39186 次 ＝ 298 s ＝ 牆鐘 83.4%**
⇒ ★★★而這是今天第三次「self 把榜首換掉」（相位樹兩次、函式層一次）——
  ★同一個工具、同一個症狀、換一個容器。
```

# ③ 兩個能跟牆鐘比的數字（★同趟、同母體）

```
`need_keep` 頂層 elapsed 304.422 s ÷ 牆鐘 357.371 s ＝ **85.2%**
`_supply_chain` self      298.224 s ÷ 牆鐘 357.371 s ＝ **83.4%**
（對照：frontier 子樹 ÷ 牆鐘 ＝ **45.84%**）
⇒ ★★所以你 §③ 那件事現在有數字了：**`need_keep` 不是那 45% 子樹裡的一段**，
  它**比子樹大** —— 因為全世界都在問它（頂層 26078 次，goal_resolver 只佔 **13.4%**）。
⇒ ★★★而這把你 §③ 的 (a)／(b) 岔路推向 **(a)**：**改善它會惠及所有呼叫端**；
  ★但 (b)（「是不是被問太多次」）**還沒被排除** —— 見 §④ 的誠實限①。
```

# ④ 誠實限（★逐條，第一條會影響你怎麼裁）

```
①★`_construction_facility_need` 的 **self 還沒分出來**：它沒有自己的堆疊層，
  而它會**間接回呼 `need_keep`**（`_facility_deficit` → `need_keep(outputs)`，code 註解自述）
  ⇒ 它的時間目前被拆成【巢狀 need_keep】＋【混在 need_keep self 的一小塊】
  ⇒ ★★要它的 self，我再加一層即可（★一行等級，等你說）
②Probe=ON，而**這條路上的儀器佔比沒有單獨量過** ——★★frontier 那條是 14.5%／21%，**不可直接套用**（明寫）
③跑間噪音大（本窗牆鐘 357 s，前幾趟 261–327 s）⇒ ★只看比例
④fp 不變（`16bb6924789c18ac031e61d34c2aeae7`）＋零 RNG
★★★而我照你 §④③：本信**沒有出現任何「總次數 × total 單價」** —— 唯一的乘法是頂層×頂層，且已標明。
```
