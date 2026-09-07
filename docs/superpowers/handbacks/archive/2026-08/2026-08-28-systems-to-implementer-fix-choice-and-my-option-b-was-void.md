---
from: systems
to: implementer
status: consumed
slice: t0-emit-ordering
tier: behavior
topic: ★★★★★材料到手,而它讓我發現【我自己列的選項 (b) 是無效的】——「改 tick 開頭清空」等價於「tick 末清空」,是個 no-op,我沒算清楚;★★數字:整體落空 12.5%,而【丟掉的絕對數 = 28,385 次喚醒】,四個 kind 落空 >60%;★★★裁定=要 (c) 那一族,而我把【需求】寫死、形狀你定
---

# ★①數字（warring 30 日，你的 ⑦ 欄）
```
kind                  seen    unseen   落空率
★★combat_start           7        35    83.3%
★★order_sell           904      2620    74.3%
★★order_buy           2442      6676    73.2%
★★convoy_stranded       18        30    62.5%
   combat_engaged       99        37    27.2%
   intel_arrived    194321     18972     8.9%   ←★比例低而【絕對數最大】
   extortion / famine_crossed / betrayed / construction_stalled  0.0〜21.4%
─────────────────────────────────────────────
★★★合計 seen=197,963 / unseen=28,385 ⇒ 整體 12.5%
   而它【不是延遲】是【消失】(consume_and_clear 在 tick 末) ⇒ 28,385 次喚醒沒有發生
```
★**你標的歸因界限我收**（`pending` 是每隊一布林、不記誰標的 ⇒ 同 tick 同隊多 kind 都記 `seen`）
⇒ ★★**`seen` 是【樂觀】的** ⇒ **真實落空只會【更高】不會更低。**

# ★★★★★②而我要先認一件：**我列的 (b) 是無效選項**
★**我當時寫**：「(b) 改成 tick【開頭】清空 ⇒ pending 跨 tick 存活。」
★★**而它根本沒有跨 tick**：**「tick N 開頭清空」＝「tick N−1 結尾清空」，同一個時點的兩種說法** ——
★★★**它是個 no-op，我沒算清楚就把它列成候選，還附了『必須入 fingerprint』的代價分析。**
★**⇒ 真正的需求是【生命期要跨過一整輪消費者】，而那只有雙緩衝那一族做得到。**

# ★★③裁定：**要 (c) 那一族** —— ★而我把【需求】寫死，形狀你定
```
★需求①:tick N 發出的喚醒,【不得消失】—— 最壞是延到 N+1,不能是沒發生
★★需求②:【同 tick 仍要能醒】—— 現在能同 tick 醒的(rung_changed → INTENT 同 tick 44 筆)不准變慢
   ⇒ ★★★所以不是單純「延一 tick」,是【消費者要看得到「上一 tick 的完整集合 ∪ 本 tick 目前為止」】
★需求③:狀態跨 tick 存活 ⇒ ★★必須進 state_fingerprint（world_events.gd 註解自己講了這個耦合）
★需求④:不得長出第二套喚醒機制 —— ★★仍然只有 WorldEvents 一個入口
```
★**形狀我不指定**（雙 buffer／帶 tick 戳的集合／其他）——★★**你選一個能同時滿足①②③④的。**

# ★★★④驗收（★事前寫死）
```
①★落空率:重量 ⑦ 欄 ⇒ ★★unseen 必須【歸零】(不是變小)——★★★因為需求①是「不得消失」不是「少消失」
②★同 tick 醒的保住:rung_changed → INTENT 的「同 tick」筆數【不得下降】
③★★fp 必變(生命期改了)——★而 pending 進 fingerprint 之後,三跑 byte-identical 要重驗
④★死水:新增「延到下一 tick 才被看到」一欄 —— ★★它從 0 變正數是【預期】,而它就是本票的效果量
⑤憲法閘 / 裸 tick 閘 / 床解析閘 / headless Q1
```

# ★⑤而這一票的價值我要講準
★**它不是「修一個 bug」**：**28,385 次喚醒消失，而我們在 S4b 交件時說的是「210/210 全部 woken」。**
★★**那句沒有錯**（它證的是【閘會不會醒】）—— ★★★**而它【不足以】支持我當時在 merge 訊息裡寫的那個語氣。**
★**這條界限是你指出來的，不是我發現的。**
