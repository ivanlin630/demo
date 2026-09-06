---
from: systems
to: implementer
status: consumed
slice: cadence-stagger
tier: behavior
topic: ★★★DISPATCH(R² CLEAN):cadence 錯峰;★★三個最容易做錯的:①cycle_index 必須是 current_tick 的純函式(禁另存計數器)②wrap 會讓同隊相鄰思考塌成 1 tick⇒必須 clamp MIN_GAP 且 MIN_GAP 由 CADENCE 導出禁手抄③CADENCE 常數逐位元不變是【機械 guard】不是文字;★★★★而驗收 4 要送 QA 故事稽核,不得自判
---

# ★★★DISPATCH：`docs/superpowers/specs/2026-08-27-cadence-stagger-HOW.md`（R² CLEAN）
**WHAT**：blueprint 裁 —— ★**錯峰＝行為改動**（「誰在哪個 tick 想事情」是世界的一部分）。

## ★病
```
ambition 每 ~100 tick 爆一次（105~110 隊同批）｜order 每 ~120 tick 爆一次
burst tick dt 中位數 14.9M vs non-burst 4.2M ＝ 3.5×
根：faction_ai_system.gd:843-849 一律 next = current_tick + CADENCE ⇒ ★同時起跑的隊永遠同批到期
```

## ★★三個最容易做錯的
| # | 要求 | 為什麼 |
|---|---|---|
| ① | ★**`cycle_index = current_tick / CADENCE` 純函式** | ★★**禁另存遞增計數器** —— 存檔／重播／多執行緒都要跟著同步一個新變數 |
| ★② | **wrap 邊界必須 clamp** | ★★`+1/cycle` 輪轉在 `offset: C−1 → 0` 那次，差值 `−(C−1)` ⇒ ★★★**同隊相鄰思考間隔塌成 1 tick**；★**wrap 是模數輪轉的內在性質，換公式消不掉，只能夾住後果** |
| ③ | ★**`CADENCE` 常數逐位元不變 ＝ 機械 guard** | ★★**「不得改 cadence 長度」只寫在 spec 是文字，擋不住** |

```
next_tick = max( cycle_index 算出的 tick , last_eval_tick + MIN_GAP )
★MIN_GAP 由 CADENCE 導出（例如 C/2）——★★不得手抄一個新的魔術常數
★★★偏移禁用 randf()/randi_range()（血證：濾鏈含 RNG 副作用曾讓 pointwise dirty）
```

## ★★★★兩層偏移（★只做第一層不夠，理由要懂）
```
①打散：offset 由 team_id 經混合函式導出（不直接 %）⇒ 相位與 id 順序無關
★②輪轉：逐 cycle 變化 ⇒ 長期沒有人固定排在前面
```
★**R² 的理由比我原本寫的更根本**：
> ★★**就算 hash 完全打散，只要 offset 是【固定終身】的，「誰抽到好位置」會【隨時間複利成優勢】** ——
> **早想的隊先搶資源，優勢滾雪球。①防「起手不公平」，②防「起手公平但機制自己把它變不公平」。**

# ★★★★★驗收 4 ＝ **QA 故事稽核，禁自判**
★**「offset 分桶沒有系統性優勢」是【behavior 因果結論】，不是聚合 metric。**
⇒ ★★**產出必須是：分桶統計 ＋ `SpecimenDumpHelper` specimen trace（motive→action→outcome）→ 送 QA。**
★★★**禁止拿分桶統計自己判「看起來很平均所以沒優勢」** —— **當日 3 次翻案全因結論建在未經 QA 驗證的 metric 上。**
★**驗收 1／2／5／6 是純機械指標，不受此限。**

# ★其餘驗收（spec 有全文）
①**「單一 tick 過閘 ≥100 隊」的 tick 數 → 0** ②**burst/non-burst dt 中位數比值 3.5× → 趨近 1**
③★**spike 中位數【不保證】下降**（靶 B 不在本票，★**沒降照原樣回報，不得調任何東西去追**）
⑤`CADENCE` 逐位元 ⑥**同隊相鄰思考最小間隔 ≥ `MIN_GAP`，無 1~2 tick 連思**
⑦守恆帳／headless(7)／憲法閘 ⑧★**`fp` 會變（兩床都會）＝預期，並當場重測新基線寫進 handback**

★★**驗收 ③⑤⑥ 是【配套】**：**若 `CADENCE` 可被改長度繞過，本票就能靠①②的表面改善＋③的「不保證」交出一張看起來合格實則空的票。**
★**禁用全局 wall-clock 宣稱加速**（雜訊 ±4~8% > 效果）。
