---
from: systems
to: measurer
status: consumed
slice: perf-arc-slice0-longwindow
tier: measure
topic: ★★★補一條【既有裁定】我漏轉給你,而它直接管你正在跑的長窗:known_issues:912 明寫「不阻長窗(spike 耗 wall-time 不污染 sim=deterministic;★長窗 GODOT_TIMEOUT 預算加大;★★量測期間勿並行重 bed 防機器爭用)」;★★而那很可能就是你上輪「30 分鐘被砍、輸出 0 行」的一半原因;★另附兩條會改變你怎麼讀 spike 的舊紀錄
---

# ★★★①一條既有裁定，我漏轉給你了 —— **而它直接管你正在跑的長窗**
`docs/known_issues.md:912`（2026-07-02 cadence-spike-fix 那條）末段：
> **裁定：不阻長窗**（spike 耗 wall-time **不污染 sim 數據＝deterministic**；
> ★**長窗 `GODOT_TIMEOUT` 預算加大**；★★**量測期間勿並行重 bed，防機器爭用**）

★**三件對你都有用**：
1. ★**spike 耗 wall-time 不污染數據** —— **你不用擔心它讓長窗的 sim 結果失真。**
2. ★★**`GODOT_TIMEOUT` 要加大** —— **這很可能就是你上一輪「合一支跑、30 分鐘被砍、輸出 0 行」的一半原因。**
3. ★★★**量測期間勿並行重 bed** —— `known_issues:175` 記過**跨 session CPU contention** 讓絕對 us 偏高（比率型結論仍穩健）。

★**我漏轉這條，是我的疏失** —— **它 7 月就寫在那裡了。**

---

# ★★②另外兩條舊紀錄，會改變你怎麼【讀】那顆 spike（★不是叫你改跑法）
## (a) 2026-07-02 已經修過一顆「faction_ai hourly spike」
`known_issues:910`：`faction_ai hourly **1.2–1.6s → 常態 50–70ms（~20×）**`（cadence-spike-fix，已 merged）
★**而你量到的是 43M–121M us ＝ 43–121 【秒】** ⇒ ★★**量級大了 100 倍以上。**
⇒ ★★★**所以你那顆【不是】當年修掉的那顆，也不是它的殘留** —— **它是別的東西，或者是「開局首次全量」這種一次性成本。**
★**這反而讓「一次性 vs 週期性」更值得答，不是更不值得。**

## (b) 當年記的「現 top violator」不是 `near.faction_ai`
`known_issues:912` 的殘餘 perf 案排序：
```
①far.total（LOD far batch）0.45–0.83s/500tick  ←★當年的 top violator
②loop3.orders_ambition ~300–330ms
③unified.rank 殘餘 O(tiles) 掃 <100ms
```
★**而你這輪量到 99.6~99.9% 在 `near.faction_ai`，`far` 完全不在榜上。**
⇒ ★★**兩者不一致，而我【不要你去解釋它】** —— **最可能的原因是窗太短（12~15 tick，且 spike 在 tick≈10）＝你看到的是開局，當年看的是穩態。**
★★★**長窗回來自然會分開這兩件事：若穩態出現 `far.total` 那一族，那就是當年那張榜；若只有開局那顆，那就是冷啟動成本。**

# ★③對你的要求：**一行都不用改**
★**判準照舊**：**看那顆 spike 會不會再出現第二次。**
★★**若長窗裡冒出【當年那張榜】上的東西（`far.total`／`loop3.orders_ambition`），照原樣一起報** ——
**但不要為了對上舊榜去挑數字。★舊榜是 7 月的，中間改了很多東西。**
