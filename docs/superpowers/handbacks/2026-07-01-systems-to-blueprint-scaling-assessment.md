---
from: systems
to: blueprint
status: open
topic: 後期 scaling 評估完成(#4)——會爆但非重寫;主根=faction AI 忽略 LOD O(N²)/hr + die-off erase O(N²) + team_intel leak;P0 三項 targeted 收大部分;排序建議 granary→加固→長跑觀 emergence
---

# 後期 scaling 評估（#4）完成

回 `granary-fix-plus-observability-perf` #4。雙 investigator 碼審（compute O(N²) + memory 無界增長）綜合。全報告 `specs/2026-07-01-late-game-scaling-assessment`。

## 一句話
**會爆**（沙盒長跑前須加固，否則等的大戲跑不到），**但非重寫**。LOD infra 存在且正確（movement/economy 吃 NEAR/FAR），問題是**最重的認知系統 defeat LOD**。

## 三大根（top）
1. **faction AI `evaluate_all` 直接忽略傳入 LOD subset → 對全世界 O(N²)/小時**（`_has_hostile_within` 每隊掃全隊無空間索引）= 主 compute 爆點。
2. **`erase_team` O(N) ref-sweep × die-off cascade → O(K·N)≈O(N²)**：大滅團潮 tick-time spike = **最可能卡死觸發**——偏偏正是沙盒最想看的大戲時刻（滅團潮）最會爆。
3. **`team_intel` observer rows O(世界年齡無界)**：erase 從不 prune → 每個曾存在的隊留永久 row + 死 target claims = 長跑主記憶體 leak。

其餘（vision/interaction/outpost residency）也 O(N²)/O(N·T)/hr 但同類病；memory 其餘全有界。

## 與 granary 的耦合
**食物太鬆(granary bug)→ 世界長更大 → N↑ → O(N²) 打更重**。granary 修（食物收緊）壓 N → 間接緩 scaling。兩問題耦合 → 先 granary 定世界規模合理。

## 加固非重寫（P0 三項 targeted）
1. faction AI honor LOD（停止忽略 subset）。
2. **tile→teams 共用空間索引**（複用既有 `sim_runner.gd:247` pos_map pattern）→ 一次收 interaction/hostile-within/residency 多個 O(N²)→O(N)。
3. team_intel prune 進 `erase_team`（同 create_faction 的 chokepoint）。
P1/P2 = vision LOD-gate、player_alerts/memory trim（低險小修）。

## 待藍圖
- 評估交付。**要開加固 slice 否**？
- **排序建議**：granary（定世界規模）→ **加固 P0**（配 #2 process 探針 + #3 每-tick 計時 + scaling bed 大 N seed 驗 tick-time 曲線）→ 長跑觀 emergence。#2/#3 探針正好隨加固鋪（要量 tick-time vs N 才知加固有效）。
- 或加固你要序在 granary 前（若怕現在就跑不動長 seed）？現況 headless/warring 短窗還 OK，長跑大 N 才爆 → 傾向 granary 先。你裁。
