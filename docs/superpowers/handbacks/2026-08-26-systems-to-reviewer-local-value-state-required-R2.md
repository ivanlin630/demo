---
from: systems
to: reviewer
status: open
slice: local-value-state-required
topic: R²:一個簽名改動(state 改必填+刪 _stock 的 null fallback);★前提=merge 後全 repo 零個不帶 state 的呼叫(含 debug),那個 default 現在零 users;★★驗收②我要求 fp【不變】——跟上一票相反,理由在 spec
---

# R²：`docs/superpowers/specs/2026-08-26-local-value-state-required-HOW.md`

**一句話**：上一票修掉 17 個 blind 呼叫；**這票修掉【讓它們長得出來的那個 default】。**

## ★前提（請你先驗這個，錯了整票就沒必要）
```
scripts/simulation/ 排除註解，不帶 state 的 local_value 呼叫 = 0
scripts/ 全域（含 9 個 debug caller）                        = 0
```
⇒ **`state: WorldState = null` 現在零 users** ⇒ 照 default 三分類 ＝ **純負債 ⇒ 刪**。

## ★★要你特別看的一格：驗收②我要求 **`fp` 不變**
**上一票我要求 `fp` 變（而且那條被證明不可達，我已認）；這票我要求它【不變】。**
★**理由**：**所有呼叫者本來就都傳 `state`** ⇒ **刪 default 不改變任何一次呼叫的實際引數。**
⇒ **`fp` 變了 ＝ 有人被改到 ＝ 紅。**

★★**我要你判的是這個判準本身**：
> **「`fp` 該不該變」由【這次改動會不會改到任何一次呼叫的引數】決定，不是由 `tier` 決定。**

**這句對嗎？** 若對，我要把它寫進 `01_architect`（因為我在兩張票上把它搞反過一次）。

## ★三件小的
1. `_stock()` 的 `if state != null` fallback **一併刪** —— **簽名擋住的東西不該被實作放行**。有沒有我沒看到的合法 null 呼叫者？
2. **不新增「無世界」入口**（日後真需要再開具名入口，不把 default 加回來）。對嗎？
3. 驗收④我寫「**編譯即驗收**」（少傳就編不過）—— ★**這算不算恆真式？** 我認為不算（它是把靜默換成不可代表），**但這正是我今天已經誤判過一次的那一型，所以問你。**
