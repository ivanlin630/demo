---
from: systems
to: implementer
slice: camp-access
tier: full
qa: required
status: open
topic: "[派工·接入 arc『滿池餓死』(R2 CLEAN)·★目前最大的一張:97.6% 的零採集是母隊,它擋著的是【村莊這個概念能不能存在】·spec=docs/superpowers/specs/2026-08-21-camp-access-arc-HOW.md·★序:本刀 → subteam-ladder 緊接 → eta-single-model(breed-anon 已 DONE 待 QA/merge)·★★診斷先行:三分流(卡絕境門檻/找不到無主可耕地/applicable 但秤輸)先用 tap 分流【逐隊歸格】再動手;修法形狀=每個不 fire 的接入動詞找到閘 de-patch 或接失敗反饋,【禁補償補丁】·★起點線索(別當結論):紮營 applicable 卡著絕境門檻 food_days < desperation_entry_threshold ⇒ 沒有被動收入的隊會慢慢燒到門檻,那時可能已來不及·★已驗掉的別重查:applicable 的 has_farmable_tile 就是 _find_unowned_farmable_tile 的結果(decision_context:366-368)同一查詢;★但 R2 追加保險:to_task 是 fresh 重查非讀快取、有時間差,請加 camp.applicable_but_idle tap·★gate 點名:pop=1 村消失≠用生育補(要驗是沒掉下去不是掉了又生回來);不是基建狂魔(紮營次數+L0→L1 晉級率+L0 廢棄率一起報,亂蓋的特徵是蓋了就丟)"
---

# 派工：接入 arc「滿池餓死」（**R2 CLEAN**）

★ **目前最大的一張**：**97.6% 的零採集是母隊**，它擋著的是「**村莊這個概念能不能存在**」。
**spec**：`docs/superpowers/specs/2026-08-21-camp-access-arc-HOW.md`

## ★序
**本刀 → `subteam-ladder` 緊接 → `eta-single-model`**（`breed-anon` 已 DONE，待 QA／merge）。

## ★★診斷先行
**三分流**（**卡絕境門檻** ／ **找不到無主可耕地** ／ **applicable 但秤輸**）
**先用 tap 分流、逐隊歸格，再動手**。修法形狀（blueprint 定）：
> **每個不 fire 的接入動詞 ＝ 找到閘 de-patch，或接失敗反饋。⛔禁補償補丁。**

★ **必須先分流**：**三種的修法完全不同，而總計數看起來一模一樣。**

## ★起點線索（**別當結論**）
`紮營` 的 `applicable` **卡著絕境門檻**：`ctx.food_days < ctx.desperation_entry_threshold`
⇒ **沒有被動收入的隊會慢慢燒到門檻**，**而那時可能已經來不及**（或找不到地）。

## ★已驗掉的別重查
`applicable` 的 **`has_farmable_tile` 就是 `_find_unowned_farmable_tile` 的結果**
（`decision_context:366-368`）⇒ **同一個查詢**。

★ **但 R2 追加一條保險**：**`to_task` 是 fresh 重查、不是讀 `ctx` 快取，有時間差**
⇒ **請加 `camp.applicable_but_idle` tap**（applicable 為真、`to_task` 卻回 `TASK_IDLE` ⇒ bump）。
**理由：「我證明不出它會發生」不等於「它不會發生」。**

## ★gate 兩條特別點名
- **`pop=1` 村消失 ≠ 用生育補** —— **要驗那些村是「沒掉下去」而不是「掉了又生回來」**（`death.*` 與 `breed.born` 分開看）
- **「不是基建狂魔」** —— **紮營次數 ＋ `L0→L1` 晉級率 ＋ L0 廢棄率一起報**（**亂蓋的特徵是蓋了就丟**）

`qa: required`（會下長跑因果結論 ⇒ merge 閘驗 QA verdict 存在）。
