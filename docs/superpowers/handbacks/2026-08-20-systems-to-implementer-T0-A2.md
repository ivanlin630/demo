---
from: systems
to: implementer
status: open
topic: "[dispatch T0-A2 輪詢退場(效能 arc 第一刀的下半、A1 的對照組)·spec=2026-08-20-T0-event-bus-HOW.md §0(A1/A2 拆分理由)·★A1 已給出對照基線(你量的):wall/day 98.0→133.1ms(+35.8%)、決策 2732→3938(+44.1%)、reeval.event 443、reeval.cadence 843→529、skip_in_transit 11、t0.emit 2805·★A2 目標=把【沒事發生也每 cadence 想一次】的輪詢降下來,靠 A1 的事件接住反應性→【決策次數與 wall 雙降】,且【A1 的反應性 gate 全部仍綠】·★做法(你判實作形狀、我給約束):①DECISION_CADENCE 拉長(倍率可調、先試 ×3 與 ×6 兩檔各量一次,報兩組數字供裁)②★保留一條【慢心跳】:即使零事件,隊仍必須【最終】會重新思考(禁『沒事件就永遠不想』=思考餓死);心跳長度就是拉長後的 cadence 本身③其餘不動(不碰 T2/T3 層級制=那是時間包的活)·★★硬約束(不得為了省算力換掉靈敏度):A1 的 gate①(事件瞬醒真發生)②(守衛有牙)③(順序穩定+單 tick 清空)④(在途不想:被襲仍瞬醒)【全部重跑並仍綠】;若任何一條紅=A2 方向錯,回報別硬調·★量化(對齊 A1 同法:全新檔名+序列跑+同 ADHOC_TICKS+同 7 日窗):報 wall/day、決策次數/日、reeval.event vs reeval.cadence 比例、以及【與 A1 基線和 main 基線的三方對照】(main 98.0 / A1 133.1 / A2 ?)——★A2 的成功判準【不是】比 A1 低,而是【比 main 低】(A1 是加反應性的必要成本、A2 要把它賺回來還有餘)·★若 ×6 仍高於 main:照實報,別為了好看繼續加倍(倍率過大=世界變遲鈍,那是拿真實換效能=紅線)·gate:上述 A1 四條全綠+det×3+constitution<=75+headless 0-new+fp intended-change+三方對照數字·worktree 沿用 feat/t0-event-bus 或新開隨你·完→handback to:systems·地基KEEP"
---

# dispatch：T0-A2 輪詢退場（A1 的對照組）

★**A1 已給出對照基線**（你量的）：`wall/day 98.0 → 133.1 ms（+35.8%）`、`決策 2732 → 3938（+44.1%）`、`reeval.event 443`、`reeval.cadence 843→529`、`skip_in_transit 11`、`t0.emit 2805`。

**A2 目標**：把「**沒事發生也每 cadence 想一次**」的輪詢降下來，靠 A1 的事件接住反應性 → **決策次數與 wall 雙降**，且 **A1 的反應性 gate 全部仍綠**。

**做法**（實作形狀你判、我給約束）：
1. `DECISION_CADENCE` 拉長（倍率可調；**先試 ×3 與 ×6 兩檔各量一次**，報兩組數字供裁）。
2. ★**保留一條慢心跳**：即使零事件，隊仍必須**最終**會重新思考（**禁「沒事件就永遠不想」＝思考餓死**）；心跳長度就是拉長後的 cadence 本身。
3. 其餘不動（**不碰 T2/T3 層級制**＝那是時間包的活）。

## ★★硬約束（不得為了省算力換掉靈敏度）
A1 的 gate ①事件瞬醒真發生 ②守衛有牙 ③順序穩定 + 單 tick 清空 ④在途不想（**被襲仍瞬醒**）→ **全部重跑並仍綠**。任一條紅 ＝ **A2 方向錯，回報、別硬調**。

## 量化（對齊 A1 同法：全新檔名 + 序列跑 + 同 `ADHOC_TICKS` + 同 7 日窗）
報 `wall/day`、決策次數/日、`reeval.event` vs `reeval.cadence` 比例，以及**與 A1 基線和 main 基線的三方對照**（main 98.0 ／ A1 133.1 ／ A2 ?）。
★**A2 的成功判準不是「比 A1 低」，而是「比 main 低」**——A1 是加反應性的必要成本，**A2 要把它賺回來還有餘**。
★**若 ×6 仍高於 main：照實報，別為了好看繼續加倍**（倍率過大＝世界變遲鈍 ＝ 拿真實換效能 ＝ 紅線）。

**gate**：上述 A1 四條全綠 + det×3 + constitution ≤75 + headless 0-new + fp intended-change + 三方對照數字。完 → handback to:systems。地基 KEEP。
