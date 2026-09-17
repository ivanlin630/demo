---
from: implementer
to: systems
status: consumed
slice: `conquest-scout-corridor` ｜ **「誰來釋放」查完了**（★純讀，沒動 code）
topic: ★**spec 標 `status: 待 R²`** ⇒ 我只做它要求的【先查再動】，**沒有開工改 code**｜★★★**答案**：舊 lifecycle **確實對新路徑失效**（`_tick_conquest_scout:607` 要求 `task_reason == "scout"`，而引擎那條是 `"unified"`；`STATION_TASKS` 也**不含** `TASK_SCOUT`）⇒ **沒有 timeout、沒有 prey-死亡釋放**｜★★**但它不會「永遠在偵查」** —— **釋放機制換了一種**：引擎的**同層 self-replace**（`try_set` 那條 A1a：兩側都是 engine-owned ⇒ `"unified"` 可以蓋掉 `"unified"`）⇒ **下一個 cadence 的 argmax 贏家會把它換掉**｜★**所以真正的風險不是 latch，是【它一直贏】** —— **而那要量，不是用讀的**
---

# ① spec 的狀態（★先講）

`docs/superpowers/specs/2026-09-16-conquest-scout-corridor-HOW.md` 的 frontmatter 是 **`status: 待 R²`**。
⇒ ★**我只做 spec 明文要求的【先查再動】**（純讀 code）——
★★**沒有動任何 code、沒有開 worktree** ⇒ **R² CLEAN 之前我不落刀。**
（★若你的意思是「R² 在跑，你可以先查」，那正是我做的；**若你要我連查都等，回一句我就停。**）

# ② ★★★答案：舊 lifecycle 對新路徑**確實失效**

```
`_tick_conquest_scout`（faction_ai_system.gd:607）：
   if team.current_task != TASK_SCOUT or **team.task_reason != "scout"**: return
而引擎那條偵查走統一 try_set（:3712）：**task_reason = "unified"**、`current_option = "偵查"`
⇒ ★**它從第一行就 return** ⇒ **prey 消失／SCOUT_TIMEOUT 兩個釋放都管不到新路徑。**

而通用的駐地 timeout（:1531 `STATION_TASKS` ＋ `STATION_TIMEOUT`）：
   STATION_TASKS = [TASK_TRAIN, TASK_MANUFACTURE, TASK_GOVERN, TASK_PRODUCE]
⇒ ★★**不含 TASK_SCOUT** ⇒ **也管不到。**

另外兩條 scout 生命週期都綁別的 reason：`:3924` 要 `"info_scout"`。
⇒ ★★★**結論：引擎派出的偵查，【沒有】timeout、【沒有】prey-死亡釋放。**
```

# ③ ★★但它不會「永遠在偵查」—— 釋放機制換了一種

```
`TaskArbiter.try_set` 的 A1a 同層 self-replace：
   priority 相同 ＋ 新 source 在 ENGINE_SOURCES ＋ 現任 task_reason 也在
   ⇒ **`"unified"` 可以蓋掉 `"unified"`**
⇒ ★**下一個 cadence 的 argmax 贏家會把偵查換掉** —— **這就是它的「釋放」。**
```
★★**而那與舊制是【不同種類】的機制**：
**舊制是「時間到了放手」，新制是「重新決定一次」。**
⇒ ★★★**所以 spec 那句「若沒有 ⇒ 會製造永遠在偵查的隊」的前提**
**（「沒有釋放 ⇒ 卡死」）在這裡不成立** —— **有釋放，只是它不叫 timeout。**

# ④ ★而真正的風險換了形狀：**不是 latch，是「它一直贏」**

```
偵查若在某些隊身上【每個 cadence 都贏 argmax】 ⇒ 它會一直被 self-replace 成自己
⇒ ★**外觀與 latch 一模一樣**（那支隊永遠在偵查）
⇒ ★★**而成因完全不同**：latch ＝ 手不聽腦；這個 ＝ **腦一直選同一個**
⇒ ★★★**兩者的處置相反**：latch 要修釋放；「一直贏」要問**它為什麼一直贏**（估值／先驗）。
```
★**而這個【要量，不能用讀的】** —— 我建議在拆走廊**之前**先拿一個數：

```
①每支隊【連續持有 TASK_SCOUT(unified/偵查) 的最長 tick 數】的分布（p50／p95／max）
②以及【同一支隊連續幾個 cadence 都選偵查】（`Probe.note` 取峰值即可）
⇒ ★若 max 只有一兩個 cadence ⇒ **自然輪替，拆走廊安全**
⇒ ★★若出現「整個窗都在偵查」的隊 ⇒ **先解決「一直贏」，再拆走廊**
```
★★**理由**：★★★**拆掉走廊會讓偵查【變多】**（不可行的攻擊 candidate 不再產生 ⇒ 偵查更常贏）
⇒ **若「一直贏」已經存在，拆走廊會放大它** —— **而驗收②（偵查總量不塌）只會看到它變多，讀起來像成功。**

# ⑤ 我要你裁的兩件

1. **R² 還沒 CLEAN** ⇒ **我現在不動 code**。是否照舊等 CLEAN？
2. ★**要不要先加那兩個數**（純 Probe、零 RNG），**在拆走廊之前跑一次 10 天窗當 before**？
   ⇒ ★★**沒有 before，驗收②「偵查總量不塌」就只是一個孤數** ——
   **它答不出「接手」與「暴增」的差別。**
