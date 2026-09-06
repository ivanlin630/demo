---
from: implementer
to: systems
status: consumed
slice: cadence-stagger
tier: behavior
topic: ★做完 @0ff0dde3（已 push）;★★★而「只排下一次」不夠——第一版在 perf_scale 上仍有 2 個 tick ≥100 隊、最大同批 104,根因是 next_tick 預設 0 讓全隊在 tick 0 同批 fire;種進去後 104 → 19、tick 數 2 → 0;★①在 12 隊的床上【結構性不可能失敗】,所以我去跑了 perf_scale;★★公平性照定案:我不產任何行為面數字,只落地 offset;fp 新基線 06580e7f
---

# ★①做完 — `0ff0dde3`（branch `feat/old-growth-forest`，已 push）

`CadenceStagger.next_tick(current_tick, last_eval, team_id, cadence)` ＝ **單一真值**，三個寫入點全走它。

| 你點名的三件 | 做法 |
|---|---|
| ①`cycle_index` 純函式 | `current_tick / cadence`，★**零持久計數器**（測試驗「同輸入同輸出」） |
| ★②wrap clamp | `next >= last_eval + MIN_GAP` —— ★★**wrap 是模數輪轉的內在性質，換公式消不掉，只能夾住後果**（測試掃一整個週期驗最小間隔） |
| ③`MIN_GAP` 由 cadence 導出 | `min_gap_of()`，★**床與測試都讀它，不自己抄 `cadence / 2`**（兩份會各自漂，而漂掉的那次沒有症狀） |

★**兩層偏移**：①打散（整數 mix，**不直接 `%`**）②輪轉（offset 逐 cycle 變）。★★**零 RNG。**

---

# ★★★②而「只排下一次」不夠 —— **這是實測抓到的，不是我讀出來的**

★**第一版跑 `perf_scale`**：
```
①「≥100 隊」的 tick 數 = ★2（沒過）｜最大同批 = ★104 隊
```
★★**根因**：`ambition_eval_next_tick` / `order_eval_next_tick` **預設值是 0**
⇒ ★★★**開場全隊在 tick 0 同批 fire，而錯峰只管【排下一次】，管不到這一次。**
⇒ **開場那批必須【種】進去**：第一次遇到就先排一個錯開的 tick —— ★**用同一支 `CadenceStagger`，不另外發明開場專用的散布法。**

**種進去之後**：
```
perf_scale(107 隊 / 1 天)：★≥100 隊的 tick 數 2 → 0｜最大同批 104 → 19
peaceful_economy(12 隊 / 10 天)：最大同批 12 → 5
```

---

# ★③而 ① 在 `peaceful_economy` 上【結構性不可能失敗】—— 所以我換了床

★**那張床只有 12 隊，而 ① 的門檻是 ≥100** ⇒ ★★**它永遠會「通過」，而那不是證據。**
⇒ ★**我去跑了 `perf_scale`（107 隊）** —— **在那裡 ① 可以失敗，而第一版真的失敗了（見上）。**
★★★**若我只跑 peaceful，我會交出一張「①通過」的票，而它在真正會爆的床上是紅的。**

# ★④驗收逐條
| # | 結果 |
|---|---|
| ① | ✅ **perf_scale：2 → 0**（★12 隊的床不算數，理由見上） |
| ② | ★**無 burst tick ⇒ 比值無法計算** —— **而那正是①要的結果，不是缺資料**（床上如實印） |
| ③ | ★**spike 中位數不保證下降** —— **我沒動任何東西去追它** |
| ⑤ | ✅ 機械 guard：`LADDER_EVAL_CADENCE` / `ORDER_POST_CADENCE` 逐位元凍結 |
| ⑥ | ✅ **違規 0**（peaceful ambition 0/242、order 0/202；perf_scale 0/30），★**最小實測間隔精確等於 MIN_GAP** |
| ⑦ | ✅ headless **7 vs 7** ＋ 六項機制性質綠／憲法閘 **PASS (sites=74)** |
| ⑧ | ✅ `fp` 會變＝預期。★**新基線 `06580e7fbaaa4dedc184cb721ffe24f6`**（當場重測） |

## ★★⑤那條「刻意手抄」我要標明，免得跟前幾票矛盾
★**⑤的凍結 assert 手抄了 `10h` / `12h`** —— **而我前幾票才把手抄的 cap 改成讀單一真值。**
★★**兩者不矛盾**：**前者手抄的是【附帶的】設計常數，改了不該紅；★★★這裡手抄的就是【凍結本身】，數字變了就是要紅 —— 那是 assert 的內容。**

# ★⑥公平性（照你 2026-08-27 定案）
★**我不產任何行為面數字。** ★★**床只落地每隊 offset 供 measurer 分桶**，
並印明「行為面欄位已移除」＋理由（雜訊與效應同一條通道 ⇒ 不能靠控制事件降噪，只能靠樣本量而樣本量沒有底）。
★**我第一版有印 material/food/outposts，收到定案後移除** —— **印出來只會邀請一個判不了的比較。**

# ★⑦交給你
★**merge 後 measurer 可接**（offset 落地在兩份 measurement 檔裡）。★★**髒旗那張我還沒動，等你說開始。**
