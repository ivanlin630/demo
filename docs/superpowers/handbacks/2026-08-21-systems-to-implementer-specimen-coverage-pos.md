---
from: systems
to: implementer
slice: specimen-coverage-pos
tier: probe
status: open
topic: "[派工·★優先(卡住 convoy 的 QA 站,而且是 T3 那刀的前置)·三件觀測修,純觀測零行為:①黏著式範圍——porter19 在 tick 12900 left_convoy 後以 ghost_alive 活到窗末,但 specimen 從 12860 起就再也沒錄過它=約 36 天無追蹤;★根因我沒查出來,窮盡 grep 過 parent_team_id 所有寫入點(只有母隊被 erase 時才清子隊 parent,不該是這條)⇒【要你先查出真根因再修,別直接套黏著式蓋過去】,不然我們不知道還有什麼會讓隊伍靜默掉出範圍 ②_snapshot 補 tile_pos(porter 自己的座標整份不存在;QA 的『追到哪裡算合理』『路徑像不像回家』本質是空間問題)③rehome 可見:現在 rehome 只 Probe.bump、不改任何 snapshot 欄位 ⇒ specimen 看不出第幾次 rehome,請在 snapshot 加 rehome 次數(或於 rehome 當下寫一筆 entry)·★硬要求同上輪:det×3 byte-identical 不變、禁耗 global RNG、交件前自己 grep 驗涵蓋(用 tile_pos 與 rehome 欄位驗,別用中文任務名)·★覆蓋窗訂正:QA 說三隻都斷在結局前,實際 porter12/20 只差 40 tick(=一個 heartbeat cadence,之後隊伍就 merge 消失)=覆蓋其實完整;真正掉的只有 porter19"
---

# 派工：specimen 覆蓋與座標（★優先）

**優先於 t3-budget** —— 它**卡住 convoy 的 QA 站**，而且**是 T3 那刀的前置**
（R² 要求的「`stranded(timeout)` 時 porter 距母隊 ≤2 格」**證偽誤殺硬 gate 需要座標**）。

## ① 黏著式範圍 —— ★但**先查根因，別直接套黏著式蓋過去**
`porter19` 在 **tick 12900 `left_convoy`** 後以 **`ghost_alive` 活到窗末**，
specimen **從 12860 起就再也沒錄過它** ＝ **約 36 天無追蹤**。

★ **我沒查出真根因**：窮盡 grep 過 `parent_team_id` 的所有寫入點——
**只有母隊被 `erase` 時才清子隊的 parent**（`world_state.gd:380`），**不該是這條**。
⇒ **要你先查出「它為什麼掉出範圍」再修**。
**別直接套黏著式把症狀蓋過去** —— 否則我們不知道**還有什麼會讓隊伍靜默掉出觀測範圍**
（這正是這兩輪一直在栽的同一族：**觀測盲點看起來跟正常運作一模一樣**）。

## ② `_snapshot` 補 `tile_pos`
porter **自己的座標整份 specimen 不存在**（母隊只有 `target` 與對別隊的 `beliefs[].est.tile_pos`）。
QA 的「追到哪裡算合理」「路徑像不像回家」**本質是空間問題**。
（母隊座標若便宜也一併給——判「距離有沒有收斂」需要兩邊。）

## ③ rehome 可見
現在 rehome **只 `Probe.bump("convoy.rehome")`、不改任何 snapshot 欄位**
⇒ **specimen 看不出第幾次 rehome**。請在 snapshot 加 **rehome 次數**（或**於 rehome 當下寫一筆 entry**，你選）。

## ★硬要求（同上輪）
**det×3 byte-identical 不變**、**禁耗 global RNG**、**純觀測零行為改動**。
**交件前自己 grep 驗涵蓋** —— 用 **`tile_pos` 與 rehome 欄位**驗，**別用中文任務名**。

## ★順帶訂正一個誤讀（不是你的）
QA 說「三隻 porter 都斷在結局前」——實際 **porter12/20 只差 40 tick**
（＝**一個 heartbeat cadence**，之後隊伍就 merge 消失）＝ **覆蓋其實完整**。
**真正掉的只有 porter19。** 別把時間浪費在修不存在的問題上。
